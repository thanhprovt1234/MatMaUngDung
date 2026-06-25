package ute.shop.utils;

import java.io.IOException;
import java.math.BigInteger;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.security.KeyFactory;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.security.interfaces.RSAPublicKey;
import java.security.spec.RSAPublicKeySpec;
import java.time.Instant;
import java.util.Base64;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.StringJoiner;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;

public final class GoogleOidcUtils {
	private static final ObjectMapper MAPPER = new ObjectMapper();
	private static final HttpClient HTTP_CLIENT = HttpClient.newHttpClient();
	private static final SecureRandom SECURE_RANDOM = new SecureRandom();
	private static final Base64.Encoder BASE64_URL_ENCODER = Base64.getUrlEncoder().withoutPadding();
	private static final Base64.Decoder BASE64_URL_DECODER = Base64.getUrlDecoder();
	private static final long JWKS_CACHE_SECONDS = 60 * 60;

	private static volatile JsonNode cachedJwks;
	private static volatile Instant cachedJwksUntil = Instant.EPOCH;

	private GoogleOidcUtils() {
	}

	public static String randomUrlSafeValue() {
		byte[] bytes = new byte[32];
		SECURE_RANDOM.nextBytes(bytes);
		return BASE64_URL_ENCODER.encodeToString(bytes);
	}

	public static String codeChallenge(String codeVerifier) {
		try {
			MessageDigest digest = MessageDigest.getInstance("SHA-256");
			byte[] hashed = digest.digest(codeVerifier.getBytes(StandardCharsets.US_ASCII));
			return BASE64_URL_ENCODER.encodeToString(hashed);
		} catch (GeneralSecurityException e) {
			throw new IllegalStateException("SHA-256 is not available.", e);
		}
	}

	public static String buildAuthorizationUrl(String clientId, String redirectUri, String state, String nonce,
			String codeChallenge) {
		Map<String, String> params = new LinkedHashMap<>();
		params.put("client_id", clientId);
		params.put("redirect_uri", redirectUri);
		params.put("response_type", "code");
		params.put("scope", "openid email profile");
		params.put("state", state);
		params.put("nonce", nonce);
		params.put("code_challenge", codeChallenge);
		params.put("code_challenge_method", "S256");
		params.put("prompt", "select_account");
		return GoogleOidcConfig.AUTHORIZATION_ENDPOINT + "?" + formEncode(params);
	}

	public static JsonNode exchangeCodeForTokens(String code, String redirectUri, String codeVerifier,
			String clientId, String clientSecret) throws IOException, InterruptedException {
		Map<String, String> params = new LinkedHashMap<>();
		params.put("code", code);
		params.put("client_id", clientId);
		params.put("client_secret", clientSecret);
		params.put("redirect_uri", redirectUri);
		params.put("grant_type", "authorization_code");
		params.put("code_verifier", codeVerifier);

		HttpRequest request = HttpRequest.newBuilder(URI.create(GoogleOidcConfig.TOKEN_ENDPOINT))
				.header("Content-Type", "application/x-www-form-urlencoded")
				.POST(HttpRequest.BodyPublishers.ofString(formEncode(params)))
				.build();
		HttpResponse<String> response = HTTP_CLIENT.send(request, HttpResponse.BodyHandlers.ofString());
		JsonNode body = MAPPER.readTree(response.body());
		if (response.statusCode() < 200 || response.statusCode() >= 300) {
			String error = body.path("error").asText("token_exchange_failed");
			String description = body.path("error_description").asText("");
			throw new IllegalStateException(("Google token exchange failed: " + error + " " + description).trim());
		}
		return body;
	}

	public static GoogleIdentity verifyIdToken(String idToken, String expectedClientId, String expectedNonce) {
		try {
			JsonNode header = decodeJwtPart(idToken, 0);
			if (!"RS256".equals(header.path("alg").asText())) {
				throw new IllegalStateException("Unsupported Google ID token algorithm.");
			}

			String keyId = header.path("kid").asText();
			RSAPublicKey publicKey = findGooglePublicKey(keyId);
			Claims claims = Jwts.parser()
					.verifyWith(publicKey)
					.build()
					.parseSignedClaims(idToken)
					.getPayload();

			validateIssuer(claims.getIssuer());
			validateAudience(claims, expectedClientId);
			validateNonce(claims.get("nonce", String.class), expectedNonce);

			String email = claims.get("email", String.class);
			if (email == null || email.isBlank()) {
				throw new IllegalStateException("Google ID token does not contain email.");
			}

			return new GoogleIdentity(
					claims.getSubject(),
					email,
					booleanClaim(claims.get("email_verified")),
					claims.get("name", String.class),
					claims.get("given_name", String.class),
					claims.get("family_name", String.class),
					claims.get("picture", String.class));
		} catch (JwtException | IOException | GeneralSecurityException | InterruptedException e) {
			if (e instanceof InterruptedException) {
				Thread.currentThread().interrupt();
			}
			throw new IllegalStateException("Invalid Google ID token.", e);
		}
	}

	private static void validateIssuer(String issuer) {
		if (!"https://accounts.google.com".equals(issuer) && !"accounts.google.com".equals(issuer)) {
			throw new IllegalStateException("Invalid Google ID token issuer.");
		}
	}

	private static void validateAudience(Claims claims, String expectedClientId) {
		Object audience = claims.get("aud");
		if (audience instanceof String text && expectedClientId.equals(text)) {
			return;
		}
		if (audience instanceof Iterable<?> values) {
			for (Object value : values) {
				if (expectedClientId.equals(String.valueOf(value))) {
					return;
				}
			}
		}
		throw new IllegalStateException("Invalid Google ID token audience.");
	}

	private static void validateNonce(String actualNonce, String expectedNonce) {
		if (expectedNonce == null || !expectedNonce.equals(actualNonce)) {
			throw new IllegalStateException("Invalid Google ID token nonce.");
		}
	}

	private static boolean booleanClaim(Object value) {
		if (value instanceof Boolean booleanValue) {
			return booleanValue;
		}
		return Boolean.parseBoolean(String.valueOf(value));
	}

	private static JsonNode decodeJwtPart(String jwt, int index) throws IOException {
		String[] parts = jwt.split("\\.");
		if (parts.length != 3) {
			throw new IllegalStateException("Invalid JWT format.");
		}
		byte[] decoded = BASE64_URL_DECODER.decode(parts[index]);
		return MAPPER.readTree(decoded);
	}

	private static RSAPublicKey findGooglePublicKey(String keyId)
			throws IOException, GeneralSecurityException, InterruptedException {
		JsonNode keys = googleJwks().path("keys");
		for (JsonNode key : keys) {
			if (keyId.equals(key.path("kid").asText())) {
				BigInteger modulus = new BigInteger(1, BASE64_URL_DECODER.decode(key.path("n").asText()));
				BigInteger exponent = new BigInteger(1, BASE64_URL_DECODER.decode(key.path("e").asText()));
				RSAPublicKeySpec keySpec = new RSAPublicKeySpec(modulus, exponent);
				return (RSAPublicKey) KeyFactory.getInstance("RSA").generatePublic(keySpec);
			}
		}
		throw new IllegalStateException("No matching Google public key found.");
	}

	private static JsonNode googleJwks() throws IOException, InterruptedException {
		if (cachedJwks != null && Instant.now().isBefore(cachedJwksUntil)) {
			return cachedJwks;
		}

		HttpRequest request = HttpRequest.newBuilder(URI.create(GoogleOidcConfig.JWKS_ENDPOINT))
				.GET()
				.build();
		HttpResponse<String> response = HTTP_CLIENT.send(request, HttpResponse.BodyHandlers.ofString());
		if (response.statusCode() < 200 || response.statusCode() >= 300) {
			throw new IllegalStateException("Unable to load Google public keys.");
		}
		cachedJwks = MAPPER.readTree(response.body());
		cachedJwksUntil = Instant.now().plusSeconds(JWKS_CACHE_SECONDS);
		return cachedJwks;
	}

	private static String formEncode(Map<String, String> params) {
		StringJoiner joiner = new StringJoiner("&");
		for (Map.Entry<String, String> entry : params.entrySet()) {
			joiner.add(urlEncode(entry.getKey()) + "=" + urlEncode(entry.getValue()));
		}
		return joiner.toString();
	}

	private static String urlEncode(String value) {
		return URLEncoder.encode(value == null ? "" : value, StandardCharsets.UTF_8);
	}
}

package ute.shop.utils;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Duration;
import java.util.Base64;
import java.util.Map;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

public final class VaultTransitClient {
	private static final String DEFAULT_VAULT_ADDR = "http://127.0.0.1:8200";
	private static final String DEFAULT_TOKEN_FILE = "C:/secure/uteshop/vault-agent-token";
	private static final String DEFAULT_TRANSIT_KEY = "uteshop-field-encryption";
	private static final Duration REQUEST_TIMEOUT = Duration.ofSeconds(10);
	private static final ObjectMapper MAPPER = new ObjectMapper();
	private static final HttpClient HTTP_CLIENT = HttpClient.newBuilder()
			.connectTimeout(REQUEST_TIMEOUT)
			.build();

	private VaultTransitClient() {
	}

	public static boolean isEnabled() {
		return "true".equalsIgnoreCase(SecretsConfig.get("vault.transit.enabled", "VAULT_TRANSIT_ENABLED", "false"));
	}

	public static String encrypt(String plaintext) {
		String encodedPlaintext = Base64.getEncoder().encodeToString(plaintext.getBytes(StandardCharsets.UTF_8));
		Map<String, Object> response = post("/v1/transit/encrypt/" + transitKey(),
				Map.of("plaintext", encodedPlaintext));
		Object ciphertext = data(response).get("ciphertext");
		if (!(ciphertext instanceof String value) || value.isBlank()) {
			throw new IllegalStateException("Vault Transit encrypt response did not include ciphertext.");
		}
		return value;
	}

	public static String decrypt(String ciphertext) {
		Map<String, Object> response = post("/v1/transit/decrypt/" + transitKey(),
				Map.of("ciphertext", ciphertext));
		Object plaintext = data(response).get("plaintext");
		if (!(plaintext instanceof String value) || value.isBlank()) {
			throw new IllegalStateException("Vault Transit decrypt response did not include plaintext.");
		}
		byte[] decoded = Base64.getDecoder().decode(value);
		return new String(decoded, StandardCharsets.UTF_8);
	}

	private static Map<String, Object> post(String path, Map<String, ?> payload) {
		try {
			String body = MAPPER.writeValueAsString(payload);
			HttpRequest request = HttpRequest.newBuilder()
					.uri(URI.create(vaultAddr() + path))
					.timeout(REQUEST_TIMEOUT)
					.header("Content-Type", "application/json")
					.header("X-Vault-Token", vaultToken())
					.POST(HttpRequest.BodyPublishers.ofString(body, StandardCharsets.UTF_8))
					.build();

			HttpResponse<String> response = HTTP_CLIENT.send(request, HttpResponse.BodyHandlers.ofString());
			if (response.statusCode() < 200 || response.statusCode() >= 300) {
				throw new IllegalStateException("Vault Transit request failed with HTTP " + response.statusCode()
						+ ": " + response.body());
			}
			return MAPPER.readValue(response.body(), new TypeReference<Map<String, Object>>() {
			});
		} catch (IOException e) {
			throw new IllegalStateException("Unable to call Vault Transit.", e);
		} catch (InterruptedException e) {
			Thread.currentThread().interrupt();
			throw new IllegalStateException("Interrupted while calling Vault Transit.", e);
		}
	}

	@SuppressWarnings("unchecked")
	private static Map<String, Object> data(Map<String, Object> response) {
		Object data = response.get("data");
		if (!(data instanceof Map<?, ?> values)) {
			throw new IllegalStateException("Vault Transit response did not include data.");
		}
		return (Map<String, Object>) values;
	}

	private static String vaultAddr() {
		String value = SecretsConfig.get("vault.addr", "VAULT_ADDR", DEFAULT_VAULT_ADDR);
		return trimTrailingSlash(value);
	}

	private static String vaultToken() {
		String token = SecretsConfig.get("vault.token", "VAULT_TOKEN", null);
		if (!SecretsConfig.isBlank(token)) {
			return token;
		}

		String tokenFile = SecretsConfig.get("vault.token.file", "VAULT_TOKEN_FILE", DEFAULT_TOKEN_FILE);
		try {
			return Files.readString(Path.of(tokenFile), StandardCharsets.UTF_8).trim();
		} catch (IOException e) {
			throw new IllegalStateException("Unable to read Vault token file: " + tokenFile, e);
		}
	}

	private static String transitKey() {
		return SecretsConfig.get("vault.transit.key", "VAULT_TRANSIT_KEY", DEFAULT_TRANSIT_KEY);
	}

	private static String trimTrailingSlash(String value) {
		String result = value == null ? DEFAULT_VAULT_ADDR : value.trim();
		while (result.endsWith("/")) {
			result = result.substring(0, result.length() - 1);
		}
		return result;
	}
}

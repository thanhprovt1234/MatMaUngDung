package ute.shop.utils;

import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Date;

import javax.crypto.SecretKey;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import ute.shop.entity.User;

public final class JwtUtils {
	public static final String ACCESS_TOKEN_COOKIE = "ACCESS_TOKEN";
	public static final long ACCESS_TOKEN_MAX_AGE_SECONDS = 2 * 60 * 60;

	private static final String ISSUER = "uteshop";
	private static final String DEFAULT_DEV_SECRET = "uteshop-local-dev-secret-change-this-value-32chars";

	private JwtUtils() {
	}

	public static String createAccessToken(User user) {
		Instant now = Instant.now();
		Instant expiresAt = now.plusSeconds(ACCESS_TOKEN_MAX_AGE_SECONDS);

		return Jwts.builder()
				.issuer(ISSUER)
				.subject(user.getEmail())
				.claim("uid", user.get_id())
				.claim("role", user.getRole().toString())
				.issuedAt(Date.from(now))
				.expiration(Date.from(expiresAt))
				.signWith(getSigningKey())
				.compact();
	}

	public static Claims parseAccessToken(String token) {
		try {
			return Jwts.parser()
					.verifyWith(getSigningKey())
					.requireIssuer(ISSUER)
					.build()
					.parseSignedClaims(token)
					.getPayload();
		} catch (JwtException | IllegalArgumentException e) {
			return null;
		}
	}

	public static String resolveAccessToken(HttpServletRequest request) {
		String authHeader = request.getHeader("Authorization");
		if (authHeader != null && authHeader.startsWith("Bearer ")) {
			return authHeader.substring("Bearer ".length()).trim();
		}

		Cookie[] cookies = request.getCookies();
		if (cookies == null) {
			return null;
		}
		for (Cookie cookie : cookies) {
			if (ACCESS_TOKEN_COOKIE.equals(cookie.getName())) {
				return cookie.getValue();
			}
		}
		return null;
	}

	public static void addAccessTokenCookie(HttpServletRequest request, HttpServletResponse response, String token) {
		Cookie cookie = new Cookie(ACCESS_TOKEN_COOKIE, token);
		cookie.setHttpOnly(true);
		cookie.setSecure(isSecureRequest(request));
		cookie.setPath(cookiePath(request));
		cookie.setMaxAge((int) ACCESS_TOKEN_MAX_AGE_SECONDS);
		cookie.setAttribute("SameSite", "Lax");
		response.addCookie(cookie);
	}

	public static void clearAccessTokenCookie(HttpServletRequest request, HttpServletResponse response) {
		Cookie cookie = new Cookie(ACCESS_TOKEN_COOKIE, "");
		cookie.setHttpOnly(true);
		cookie.setSecure(isSecureRequest(request));
		cookie.setPath(cookiePath(request));
		cookie.setMaxAge(0);
		cookie.setAttribute("SameSite", "Lax");
		response.addCookie(cookie);
	}

	public static Integer getUserId(Claims claims) {
		if (claims == null) {
			return null;
		}
		Object value = claims.get("uid");
		if (value instanceof Number number) {
			return number.intValue();
		}
		if (value instanceof String text) {
			try {
				return Integer.parseInt(text);
			} catch (NumberFormatException e) {
				return null;
			}
		}
		return null;
	}

	private static SecretKey getSigningKey() {
		String secret = SecretsConfig.get("jwt.secret", "JWT_SECRET", DEFAULT_DEV_SECRET);
		return Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
	}

	private static String cookiePath(HttpServletRequest request) {
		String contextPath = request.getContextPath();
		return contextPath == null || contextPath.isEmpty() ? "/" : contextPath;
	}

	private static boolean isSecureRequest(HttpServletRequest request) {
		if (request.isSecure()) {
			return true;
		}
		if ("true".equalsIgnoreCase(SecretsConfig.get("app.cookie.secure", "FORCE_SECURE_COOKIE", "false"))) {
			return true;
		}
		if ("https".equalsIgnoreCase(request.getHeader("X-Forwarded-Proto"))) {
			return true;
		}
		if ("on".equalsIgnoreCase(request.getHeader("X-Forwarded-Ssl"))) {
			return true;
		}
		String forwarded = request.getHeader("Forwarded");
		return forwarded != null && forwarded.toLowerCase().contains("proto=https");
	}
}

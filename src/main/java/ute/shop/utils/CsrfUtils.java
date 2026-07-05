package ute.shop.utils;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

public final class CsrfUtils {
	public static final String TOKEN_ATTRIBUTE = "csrfToken";
	public static final String TOKEN_PARAMETER = "csrfToken";

	private static final SecureRandom SECURE_RANDOM = new SecureRandom();
	private static final int TOKEN_BYTES = 32;

	private CsrfUtils() {
	}

	public static String getOrCreateToken(HttpServletRequest request) {
		HttpSession session = request.getSession(true);
		Object existing = session.getAttribute(TOKEN_ATTRIBUTE);
		if (existing instanceof String token && !token.isBlank()) {
			return token;
		}
		String token = newToken();
		session.setAttribute(TOKEN_ATTRIBUTE, token);
		return token;
	}

	public static void exposeToken(HttpServletRequest request) {
		request.setAttribute(TOKEN_ATTRIBUTE, getOrCreateToken(request));
	}

	public static boolean isValid(HttpServletRequest request) {
		HttpSession session = request.getSession(false);
		if (session == null) {
			return false;
		}

		Object expected = session.getAttribute(TOKEN_ATTRIBUTE);
		String actual = request.getParameter(TOKEN_PARAMETER);
		if (!(expected instanceof String expectedToken) || expectedToken.isBlank() || actual == null || actual.isBlank()) {
			return false;
		}

		byte[] expectedBytes = expectedToken.getBytes(StandardCharsets.UTF_8);
		byte[] actualBytes = actual.getBytes(StandardCharsets.UTF_8);
		return MessageDigest.isEqual(expectedBytes, actualBytes);
	}

	private static String newToken() {
		byte[] bytes = new byte[TOKEN_BYTES];
		SECURE_RANDOM.nextBytes(bytes);
		return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
	}
}

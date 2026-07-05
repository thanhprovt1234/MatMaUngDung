package ute.shop.utils;

import jakarta.servlet.http.HttpServletRequest;

public final class GoogleOidcConfig {
	public static final String AUTHORIZATION_ENDPOINT = "https://accounts.google.com/o/oauth2/v2/auth";
	public static final String TOKEN_ENDPOINT = "https://oauth2.googleapis.com/token";
	public static final String JWKS_ENDPOINT = "https://www.googleapis.com/oauth2/v3/certs";

	private GoogleOidcConfig() {
	}

	public static String clientId() {
		return SecretsConfig.require("google.client.id", "GOOGLE_CLIENT_ID");
	}

	public static String clientSecret() {
		return SecretsConfig.require("google.client.secret", "GOOGLE_CLIENT_SECRET");
	}

	public static String redirectUri(HttpServletRequest request) {
		String configured = SecretsConfig.get("google.redirect.uri", "GOOGLE_REDIRECT_URI", null);
		if (configured != null && !configured.isBlank()) {
			return configured.trim();
		}
		return externalBaseUrl(request) + request.getContextPath() + "/oauth2/google/callback";
	}

	private static String externalBaseUrl(HttpServletRequest request) {
		String proto = firstHeaderValue(request, "X-Forwarded-Proto");
		if (proto == null || proto.isBlank()) {
			proto = request.getScheme();
		}

		String host = firstHeaderValue(request, "X-Forwarded-Host");
		if (host == null || host.isBlank()) {
			host = request.getHeader("Host");
		}
		if (host == null || host.isBlank()) {
			host = request.getServerName();
			int port = request.getServerPort();
			boolean defaultPort = ("https".equalsIgnoreCase(proto) && port == 443)
					|| ("http".equalsIgnoreCase(proto) && port == 80);
			if (!defaultPort) {
				host += ":" + port;
			}
		}
		return proto + "://" + host;
	}

	private static String firstHeaderValue(HttpServletRequest request, String name) {
		String value = request.getHeader(name);
		if (value == null || value.isBlank()) {
			return null;
		}
		return value.split(",", 2)[0].trim();
	}
}

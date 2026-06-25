package ute.shop.controller.oauth;

import java.io.IOException;

import com.fasterxml.jackson.databind.JsonNode;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import ute.shop.entity.User;
import ute.shop.services.IUserService;
import ute.shop.services.implement.UserServiceImpl;
import ute.shop.utils.GoogleIdentity;
import ute.shop.utils.GoogleOidcConfig;
import ute.shop.utils.GoogleOidcUtils;
import ute.shop.utils.JwtUtils;

@SuppressWarnings("serial")
@WebServlet(urlPatterns = "/oauth2/google/callback")
public class GoogleOAuthCallbackController extends HttpServlet {
	private final IUserService userService = new UserServiceImpl();

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		HttpSession session = req.getSession(false);
		try {
			String googleError = req.getParameter("error");
			if (googleError != null && !googleError.isBlank()) {
				throw new IllegalStateException("Google login was cancelled or rejected: " + googleError);
			}

			if (session == null) {
				throw new IllegalStateException("Google login session expired. Please try again.");
			}

			String expectedState = sessionValue(session, GoogleOAuthStartController.GOOGLE_OAUTH_STATE);
			String expectedNonce = sessionValue(session, GoogleOAuthStartController.GOOGLE_OAUTH_NONCE);
			String codeVerifier = sessionValue(session, GoogleOAuthStartController.GOOGLE_OAUTH_CODE_VERIFIER);
			String redirectUri = sessionValue(session, GoogleOAuthStartController.GOOGLE_OAUTH_REDIRECT_URI);

			String actualState = req.getParameter("state");
			if (expectedState == null || !expectedState.equals(actualState)) {
				throw new IllegalStateException("Invalid Google login state.");
			}

			String code = req.getParameter("code");
			if (code == null || code.isBlank()) {
				throw new IllegalStateException("Google did not return an authorization code.");
			}

			String clientId = GoogleOidcConfig.clientId();
			JsonNode tokenResponse = GoogleOidcUtils.exchangeCodeForTokens(code, redirectUri, codeVerifier, clientId,
					GoogleOidcConfig.clientSecret());
			String idToken = tokenResponse.path("id_token").asText(null);
			if (idToken == null || idToken.isBlank()) {
				throw new IllegalStateException("Google did not return an ID token.");
			}

			GoogleIdentity identity = GoogleOidcUtils.verifyIdToken(idToken, clientId, expectedNonce);
			if (!identity.emailVerified()) {
				throw new IllegalStateException("Google account email is not verified.");
			}

			User user = userService.findOrCreateGoogleUser(identity.email(), identity.givenName(),
					identity.familyName(), identity.fullName(), identity.pictureUrl(), identity.subject());

			session.removeAttribute(GoogleOAuthStartController.GOOGLE_OAUTH_STATE);
			session.removeAttribute(GoogleOAuthStartController.GOOGLE_OAUTH_NONCE);
			session.removeAttribute(GoogleOAuthStartController.GOOGLE_OAUTH_CODE_VERIFIER);
			session.removeAttribute(GoogleOAuthStartController.GOOGLE_OAUTH_REDIRECT_URI);
			session.setAttribute("account", user);
			session.setAttribute("userId", user.get_id());
			JwtUtils.addAccessTokenCookie(req, resp, JwtUtils.createAccessToken(user));

			redirectByRole(req, resp, user);
		} catch (InterruptedException e) {
			Thread.currentThread().interrupt();
			showLoginError(req, resp, "Google login was interrupted. Please try again.");
		} catch (RuntimeException e) {
			showLoginError(req, resp, e.getMessage());
		}
	}

	private String sessionValue(HttpSession session, String name) {
		Object value = session.getAttribute(name);
		return value instanceof String text ? text : null;
	}

	private void redirectByRole(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
		if ("ADMIN".equalsIgnoreCase(user.getRole().toString())) {
			resp.sendRedirect(req.getContextPath() + "/admin/home");
		} else {
			resp.sendRedirect(req.getContextPath() + "/home");
		}
	}

	private void showLoginError(HttpServletRequest req, HttpServletResponse resp, String message)
			throws ServletException, IOException {
		req.setAttribute("alert", message == null || message.isBlank() ? "Google login failed." : message);
		req.getRequestDispatcher("/views/login.jsp").forward(req, resp);
	}
}

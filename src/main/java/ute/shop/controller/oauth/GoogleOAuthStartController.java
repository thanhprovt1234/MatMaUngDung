package ute.shop.controller.oauth;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import ute.shop.utils.GoogleOidcConfig;
import ute.shop.utils.GoogleOidcUtils;

@SuppressWarnings("serial")
@WebServlet(urlPatterns = "/oauth2/google/start")
public class GoogleOAuthStartController extends HttpServlet {
	static final String GOOGLE_OAUTH_STATE = "googleOauthState";
	static final String GOOGLE_OAUTH_NONCE = "googleOauthNonce";
	static final String GOOGLE_OAUTH_CODE_VERIFIER = "googleOauthCodeVerifier";
	static final String GOOGLE_OAUTH_REDIRECT_URI = "googleOauthRedirectUri";

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		try {
			String clientId = GoogleOidcConfig.clientId();
			String redirectUri = GoogleOidcConfig.redirectUri(req);
			String state = GoogleOidcUtils.randomUrlSafeValue();
			String nonce = GoogleOidcUtils.randomUrlSafeValue();
			String codeVerifier = GoogleOidcUtils.randomUrlSafeValue();
			String codeChallenge = GoogleOidcUtils.codeChallenge(codeVerifier);

			HttpSession session = req.getSession(true);
			session.setAttribute(GOOGLE_OAUTH_STATE, state);
			session.setAttribute(GOOGLE_OAUTH_NONCE, nonce);
			session.setAttribute(GOOGLE_OAUTH_CODE_VERIFIER, codeVerifier);
			session.setAttribute(GOOGLE_OAUTH_REDIRECT_URI, redirectUri);

			String authorizationUrl = GoogleOidcUtils.buildAuthorizationUrl(clientId, redirectUri, state, nonce,
					codeChallenge);
			resp.sendRedirect(authorizationUrl);
		} catch (IllegalStateException e) {
			req.setAttribute("alert", e.getMessage());
			req.getRequestDispatcher("/views/login.jsp").forward(req, resp);
		}
	}
}

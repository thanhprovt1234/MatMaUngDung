package ute.shop.config;

import java.io.IOException;
import java.util.Set;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import ute.shop.utils.CsrfUtils;
import ute.shop.utils.SecurityAuditLogger;

@WebFilter(urlPatterns = "/*")
public class CsrfFilter implements Filter {
	private static final Set<String> PROTECTED_POST_PATHS = Set.of(
			"/login",
			"/forgot-password",
			"/register",
			"/guest/register",
			"/cart/add",
			"/cart/update",
			"/cart/remove",
			"/payments/create-intent",
			"/orders/place",
			"/orders/cancel",
			"/reviews/add",
			"/user/follow",
			"/user/unfollow",
			"/edit-profile",
			"/change-password",
			"/upload-avatar");

	@Override
	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
			throws IOException, ServletException {
		HttpServletRequest httpRequest = (HttpServletRequest) request;
		HttpServletResponse httpResponse = (HttpServletResponse) response;

		if (!isStaticAsset(httpRequest)) {
			CsrfUtils.exposeToken(httpRequest);
		}

		if (requiresCsrfCheck(httpRequest) && !CsrfUtils.isValid(httpRequest)) {
			SecurityAuditLogger.log("csrf_failed", httpRequest,
					SecurityAuditLogger.fields("reason", "missing_or_invalid_token"));
			httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, "Invalid CSRF token.");
			return;
		}

		chain.doFilter(request, response);
	}

	private boolean requiresCsrfCheck(HttpServletRequest request) {
		return "POST".equalsIgnoreCase(request.getMethod()) && PROTECTED_POST_PATHS.contains(request.getServletPath());
	}

	private boolean isStaticAsset(HttpServletRequest request) {
		String path = request.getRequestURI();
		return path.contains("/assets/")
				|| path.contains("/common/")
				|| path.contains("/css/")
				|| path.contains("/Eshopper/")
				|| path.contains("/fonts/")
				|| path.contains("/images/")
				|| path.contains("/js/");
	}
}

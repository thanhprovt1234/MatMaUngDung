package ute.shop.config;

import java.io.IOException;

import io.jsonwebtoken.Claims;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import ute.shop.entity.User;
import ute.shop.security.Permission;
import ute.shop.security.PermissionUtils;
import ute.shop.services.IUserService;
import ute.shop.services.implement.UserServiceImpl;
import ute.shop.utils.JwtUtils;
import ute.shop.utils.SecurityAuditLogger;

@WebFilter(urlPatterns = { "/account", "/cart", "/cart/*", "/orders", "/orders/*", "/payments", "/payments/*" })
public class PermissionFilter implements jakarta.servlet.Filter {
	private final IUserService userService = new UserServiceImpl();

	@Override
	public void doFilter(jakarta.servlet.ServletRequest request, jakarta.servlet.ServletResponse response,
			FilterChain chain) throws IOException, ServletException {
		HttpServletRequest req = (HttpServletRequest) request;
		HttpServletResponse resp = (HttpServletResponse) response;

		if (isPublicPaymentCallback(req)) {
			chain.doFilter(request, response);
			return;
		}

		Permission requiredPermission = requiredPermission(req);
		User user = resolveAccount(req);
		if (user == null) {
			SecurityAuditLogger.log("permission_auth_required", req,
					SecurityAuditLogger.fields("permission", requiredPermission, "reason", "anonymous"));
			resp.sendRedirect(req.getContextPath() + "/login");
			return;
		}

		if (!PermissionUtils.hasPermission(user, requiredPermission)) {
			SecurityAuditLogger.log("permission_denied", req,
					SecurityAuditLogger.fields("actor", SecurityAuditLogger.actor(user),
							"permission", requiredPermission));
			resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Missing permission: " + requiredPermission);
			return;
		}

		chain.doFilter(request, response);
	}

	private boolean isPublicPaymentCallback(HttpServletRequest req) {
		return "/payments/stripe/webhook".equals(req.getServletPath());
	}

	private Permission requiredPermission(HttpServletRequest req) {
		String path = req.getServletPath();
		if (path != null && path.startsWith("/payments")) {
			return Permission.PAYMENT_AUTHORIZE;
		}
		if (path != null && (path.startsWith("/cart") || path.startsWith("/orders") || "/account".equals(path))) {
			return Permission.ORDER_WRITE;
		}
		return Permission.CATALOG_READ;
	}

	private User resolveAccount(HttpServletRequest req) {
		HttpSession session = req.getSession(false);
		User account = session == null ? null : (User) session.getAttribute("account");
		if (account != null) {
			return account;
		}

		String token = JwtUtils.resolveAccessToken(req);
		Claims claims = JwtUtils.parseAccessToken(token);
		Integer userId = JwtUtils.getUserId(claims);
		if (userId == null) {
			return null;
		}

		User user = userService.findById(userId);
		if (user != null) {
			HttpSession newSession = req.getSession(true);
			newSession.setAttribute("account", user);
			newSession.setAttribute("userId", user.get_id());
		}
		return user;
	}
}

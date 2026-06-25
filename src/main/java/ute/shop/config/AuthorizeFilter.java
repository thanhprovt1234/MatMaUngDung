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
import ute.shop.services.IUserService;
import ute.shop.services.implement.UserServiceImpl;
import ute.shop.utils.JwtUtils;

@WebFilter(urlPatterns = { "/admin/*" })
public class AuthorizeFilter implements jakarta.servlet.Filter {
	private final IUserService userService = new UserServiceImpl();

	@Override
	public void doFilter(jakarta.servlet.ServletRequest request, jakarta.servlet.ServletResponse response,
			FilterChain chain) throws IOException, ServletException {

		HttpServletRequest req = (HttpServletRequest) request;
		HttpServletResponse resp = (HttpServletResponse) response;

		User account = resolveAccount(req);
		if (account == null) {
			resp.sendRedirect(req.getContextPath() + "/login");
			return;
		}

		String role = account.getRole() == null ? "" : account.getRole().toString();
		if (!"ADMIN".equalsIgnoreCase(role)) {
			resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Forbidden");
			return;
		}

		chain.doFilter(request, response);
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

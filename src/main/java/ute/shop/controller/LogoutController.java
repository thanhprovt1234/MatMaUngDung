package ute.shop.controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import ute.shop.utils.JwtUtils;

@WebServlet(urlPatterns = "/logout")
public class LogoutController extends HttpServlet {
	private static final long serialVersionUID = 1L;

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		HttpSession session = req.getSession(false);
		if (session != null) {
			session.invalidate();
		}

		JwtUtils.clearAccessTokenCookie(req, resp);
		clearRememberMeCookie(resp);

		resp.sendRedirect(req.getContextPath() + "/login");
	}

	private void clearRememberMeCookie(HttpServletResponse resp) {
		Cookie cookie = new Cookie("email", "");
		cookie.setMaxAge(0);
		cookie.setPath("/");
		resp.addCookie(cookie);
	}
}

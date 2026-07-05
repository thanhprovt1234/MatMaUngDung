package ute.shop.controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = {
		"/Eshopper/cart.html",
		"/Eshopper/checkout.html",
		"/cart.html",
		"/checkout.html",
		"/cart.jsp" })
public class LegacyTemplateRedirectController extends HttpServlet {
	private static final long serialVersionUID = 1L;

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		String path = req.getServletPath();
		if (path.contains("checkout")) {
			resp.sendRedirect(req.getContextPath() + "/orders/place");
			return;
		}

		resp.sendRedirect(req.getContextPath() + "/cart/view");
	}
}

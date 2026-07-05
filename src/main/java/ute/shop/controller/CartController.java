package ute.shop.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import ute.shop.entity.Cart;
import ute.shop.entity.User;
import ute.shop.services.ICartService;
import ute.shop.services.implement.CartServiceImpl;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;

@WebServlet(urlPatterns = { "/cart", "/cart/add", "/cart/update", "/cart/remove", "/cart/view" })
public class CartController extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private final ICartService cartService = new CartServiceImpl();

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		String action = req.getServletPath();

		switch (action) {
		case "/cart":
		case "/cart/view":
			viewCart(req, resp);
			break;
		default:
			resp.sendRedirect(req.getContextPath() + "/home");
			break;
		}
	}

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		String action = req.getServletPath();

		switch (action) {
		case "/cart/add":
			addToCart(req, resp);
			break;
		case "/cart/update":
			updateCart(req, resp);
			break;
		case "/cart/remove":
			removeFromCart(req, resp);
			break;
		default:
			resp.sendRedirect(req.getContextPath() + "/home");
			break;
		}
	}

	private void viewCart(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		User currentUser = (User) req.getSession().getAttribute("account");
		if (currentUser == null) {
			resp.sendRedirect(req.getContextPath() + "/login");
			return;
		}

		Cart cart = cartService.findCartByUserId(currentUser.get_id());
		if (cart == null) {
			cart = new Cart();
			cart.setCartItems(new ArrayList<>());
		}

		req.setAttribute("cart", cart);
		req.getRequestDispatcher("/views/cart.jsp").forward(req, resp);
	}

	private void addToCart(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		User currentUser = (User) req.getSession().getAttribute("account");
		if (currentUser == null) {
			resp.sendRedirect(req.getContextPath() + "/login");
			return;
		}

		try {
			int productId = Integer.parseInt(req.getParameter("productId"));
			int quantity = Integer.parseInt(req.getParameter("quantity"));

			Cart updatedCart = cartService.addOrUpdateCartItem(currentUser.get_id(), productId, quantity);
			req.getSession().setAttribute("cart", updatedCart);
			resp.sendRedirect(req.getContextPath() + "/cart/view?success=product-added");
		} catch (NumberFormatException e) {
			redirectWithError(req, resp, "Invalid input format.");
		} catch (IllegalArgumentException e) {
			redirectWithError(req, resp, e.getMessage());
		} catch (Exception e) {
			e.printStackTrace();
			redirectWithError(req, resp, "Unexpected error occurred.");
		}
	}

	private void updateCart(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		User currentUser = (User) req.getSession().getAttribute("account");
		if (currentUser == null) {
			resp.sendRedirect(req.getContextPath() + "/login");
			return;
		}

		try {
			int productId = Integer.parseInt(req.getParameter("productId"));
			int newCount = Integer.parseInt(req.getParameter("count"));

			Cart updatedCart = cartService.setCartItemQuantity(currentUser.get_id(), productId, newCount);
			req.getSession().setAttribute("cart", updatedCart);
			resp.sendRedirect(req.getContextPath() + "/cart/view");
		} catch (NumberFormatException e) {
			redirectWithError(req, resp, "Invalid input format.");
		} catch (IllegalArgumentException e) {
			redirectWithError(req, resp, e.getMessage());
		} catch (Exception e) {
			e.printStackTrace();
			redirectWithError(req, resp, "Unexpected error occurred.");
		}
	}

	private void removeFromCart(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		User currentUser = (User) req.getSession().getAttribute("account");
		if (currentUser == null) {
			resp.sendRedirect(req.getContextPath() + "/login");
			return;
		}

		try {
			int productId = Integer.parseInt(req.getParameter("productId"));
			cartService.removeCartItem(currentUser.get_id(), productId);

			Cart updatedCart = cartService.findCartByUserId(currentUser.get_id());
			req.getSession().setAttribute("cart", updatedCart);
			resp.sendRedirect(req.getContextPath() + "/cart/view");
		} catch (NumberFormatException e) {
			redirectWithError(req, resp, "Invalid product ID format.");
		} catch (IllegalArgumentException e) {
			redirectWithError(req, resp, e.getMessage());
		} catch (Exception e) {
			e.printStackTrace();
			redirectWithError(req, resp, "Unexpected error occurred.");
		}
	}

	@SuppressWarnings("unused")
	private void clearCart(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		User currentUser = (User) req.getSession().getAttribute("account");
		if (currentUser == null) {
			resp.sendRedirect(req.getContextPath() + "/login");
			return;
		}

		try {
			cartService.clearCart(currentUser.get_id());
			req.getSession().removeAttribute("cart");
			resp.sendRedirect(req.getContextPath() + "/cart/view?success=cart-cleared");
		} catch (Exception e) {
			e.printStackTrace();
			redirectWithError(req, resp, "Unable to clear cart.");
		}
	}

	private void redirectWithError(HttpServletRequest req, HttpServletResponse resp, String message) throws IOException {
		String encodedMessage = URLEncoder.encode(message, StandardCharsets.UTF_8);
		resp.sendRedirect(req.getContextPath() + "/error?message=" + encodedMessage);
	}
}

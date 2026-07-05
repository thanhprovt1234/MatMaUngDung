package ute.shop.controller.payment;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.stripe.Stripe;
import com.stripe.model.PaymentIntent;
import com.stripe.net.RequestOptions;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import ute.shop.config.StripeConfig;
import ute.shop.entity.Cart;
import ute.shop.entity.User;
import ute.shop.services.ICartService;
import ute.shop.services.implement.CartServiceImpl;

@WebServlet(urlPatterns = "/payments/create-intent")
public class StripePaymentIntentController extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private final ICartService cartService = new CartServiceImpl();
	private final ObjectMapper objectMapper = new ObjectMapper();

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		User user = resolveCurrentUser(req);
		if (user == null) {
			resp.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Login is required.");
			return;
		}

		String idempotencyKey = req.getParameter("idempotencyKey");
		if (idempotencyKey == null || idempotencyKey.isBlank()) {
			resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "idempotencyKey is required.");
			return;
		}

		Cart cart = cartService.findCartByUserId(user.get_id());
		if (cart == null || cart.getCartItems() == null || cart.getCartItems().isEmpty()) {
			resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Cart is empty.");
			return;
		}

		long amountCents = Math.round(cart.getTotalAmount() * 100);
		if (amountCents <= 0) {
			resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Payment amount must be positive.");
			return;
		}

		try {
			Stripe.apiKey = StripeConfig.secretKey();

			Map<String, Object> metadata = new HashMap<>();
			metadata.put("userId", String.valueOf(user.get_id()));
			metadata.put("userEmail", user.getEmail());
			metadata.put("checkoutIdempotencyKey", idempotencyKey);
			metadata.put("panRetainedByApp", "false");
			metadata.put("cvvRetainedByApp", "false");

			Map<String, Object> params = new HashMap<>();
			params.put("amount", amountCents);
			params.put("currency", StripeConfig.currency());
			params.put("payment_method_types", List.of("card"));
			params.put("metadata", metadata);

			RequestOptions options = RequestOptions.builder()
					.setIdempotencyKey("checkout-" + user.get_id() + "-" + idempotencyKey)
					.build();
			PaymentIntent intent = PaymentIntent.create(params, options);

			Map<String, Object> response = new HashMap<>();
			response.put("paymentIntentId", intent.getId());
			response.put("clientSecret", intent.getClientSecret());
			response.put("amount", amountCents);
			response.put("currency", StripeConfig.currency());

			resp.setContentType("application/json");
			resp.setCharacterEncoding("UTF-8");
			objectMapper.writeValue(resp.getWriter(), response);
		} catch (Exception e) {
			throw new ServletException("Unable to create Stripe PaymentIntent.", e);
		}
	}

	private User resolveCurrentUser(HttpServletRequest req) {
		Object account = req.getSession().getAttribute("account");
		return account instanceof User user ? user : null;
	}
}

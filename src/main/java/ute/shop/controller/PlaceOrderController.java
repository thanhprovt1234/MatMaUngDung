package ute.shop.controller;

import java.io.IOException;
import java.util.List;
import java.util.UUID;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import ute.shop.config.StripeConfig;
import ute.shop.entity.Cart;
import ute.shop.entity.Delivery;
import ute.shop.entity.Order;
import ute.shop.entity.Store;
import ute.shop.entity.User;
import ute.shop.services.ICartService;
import ute.shop.services.IDeliveryService;
import ute.shop.services.IOrderService;
import ute.shop.services.IPaymentService;
import ute.shop.services.IStoreService;
import ute.shop.services.IUserService;
import ute.shop.services.implement.CartServiceImpl;
import ute.shop.services.implement.DeliveryServiceImpl;
import ute.shop.services.implement.OrderServiceImpl;
import ute.shop.services.implement.PaymentServiceImpl;
import ute.shop.services.implement.StoreServiceImpl;
import ute.shop.services.implement.UserServiceImpl;

@WebServlet(urlPatterns = { "/orders/place" })
public class PlaceOrderController extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private static final String CHECKOUT_IDEMPOTENCY_KEY = "checkoutIdempotencyKey";
	private static final String CHECKOUT_IN_PROGRESS_KEY = "checkoutInProgressKey";
	private static final String CHECKOUT_RESULT_PREFIX = "checkoutResult:";

	private final IOrderService orderService = new OrderServiceImpl();
	private final IDeliveryService deliveryService = new DeliveryServiceImpl();
	private final IStoreService storeService = new StoreServiceImpl();
	private final ICartService cartService = new CartServiceImpl();
	private final IUserService userService = new UserServiceImpl();
	private final IPaymentService paymentService = new PaymentServiceImpl();

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		try {
			User currentUser = resolveCurrentUser(req);
			if (currentUser == null) {
				resp.sendRedirect(req.getContextPath() + "/login.jsp");
				return;
			}

			int userId = currentUser.get_id();
			User user = userService.findById(userId);
			if (user == null) {
				throw new RuntimeException("User not found for ID: " + userId);
			}

			Cart cart = cartService.findCartByUserId(userId);
			if (cart == null || cart.getCartItems() == null || cart.getCartItems().isEmpty()) {
				resp.sendRedirect(req.getContextPath() + "/cart/view");
				return;
			}

			Integer storeId = cart.getCartItems().get(0).getProduct().getStore().get_id();
			Store store = storeService.findById(storeId);
			if (store == null) {
				throw new RuntimeException("Store not found for ID: " + storeId);
			}

			List<Delivery> deliveryList = deliveryService.getAllDeliveries();
			if (deliveryList == null || deliveryList.isEmpty()) {
				throw new RuntimeException("No delivery methods available.");
			}

			req.setAttribute("user", user);
			req.setAttribute("cart", cart);
			req.setAttribute("store", store);
			req.setAttribute("deliveryList", deliveryList);
			req.setAttribute("idempotencyKey", issueIdempotencyKey(req.getSession()));
			req.setAttribute("stripePublishableKey", StripeConfig.publishableKey());

			req.getRequestDispatcher("/views/placeOrder.jsp").forward(req, resp);
		} catch (Exception e) {
			e.printStackTrace();
			req.setAttribute("errorMessage", "Unable to load the order form. Please try again.");
			req.getRequestDispatcher("/views/500.jsp").forward(req, resp);
		}
	}

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		String idempotencyKey = req.getParameter("idempotencyKey");
		try {
			User currentUser = resolveCurrentUser(req);
			if (currentUser == null) {
				resp.sendRedirect(req.getContextPath() + "/login.jsp");
				return;
			}
			if (!reserveIdempotencyKey(req, resp, idempotencyKey)) {
				return;
			}

			int userId = currentUser.get_id();
			String address = req.getParameter("address");
			String phone = req.getParameter("phone");
			int deliveryId = Integer.parseInt(req.getParameter("deliveryId"));
			int storeId = Integer.parseInt(req.getParameter("storeId"));
			String paymentIntentId = req.getParameter("paymentIntentId");
			if (paymentIntentId == null || paymentIntentId.isBlank()) {
				resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Stripe paymentIntentId is required.");
				return;
			}

			Order order = orderService.placeOrder(userId, storeId, deliveryId, address, phone);
			paymentService.recordStripePayment(order, paymentIntentId);
			cartService.clearCart(userId);
			completeIdempotencyKey(req.getSession(), idempotencyKey, order.get_id());
			resp.sendRedirect(req.getContextPath() + "/home?success=order-placed&orderId=" + order.get_id());
		} catch (Exception e) {
			clearInProgressKey(req.getSession(false), idempotencyKey);
			e.printStackTrace();
			req.setAttribute("errorMessage", "An unexpected error occurred. Please try again.");
			req.getRequestDispatcher("/views/500.jsp").forward(req, resp);
		}
	}

	private User resolveCurrentUser(HttpServletRequest req) {
		Object account = req.getSession().getAttribute("account");
		if (account instanceof User user) {
			req.getSession().setAttribute("userId", user.get_id());
			return user;
		}

		Object userId = req.getSession().getAttribute("userId");
		if (userId instanceof Integer id) {
			return userService.findById(id);
		}

		return null;
	}

	private String issueIdempotencyKey(HttpSession session) {
		synchronized (session) {
			String key = UUID.randomUUID().toString();
			session.setAttribute(CHECKOUT_IDEMPOTENCY_KEY, key);
			return key;
		}
	}

	private boolean reserveIdempotencyKey(HttpServletRequest req, HttpServletResponse resp, String submittedKey)
			throws IOException {
		HttpSession session = req.getSession();
		synchronized (session) {
			Integer previousOrderId = previousOrderId(session, submittedKey);
			if (previousOrderId != null) {
				resp.sendRedirect(req.getContextPath() + "/home?success=order-placed&orderId=" + previousOrderId);
				return false;
			}

			Object inProgress = session.getAttribute(CHECKOUT_IN_PROGRESS_KEY);
			if (submittedKey != null && submittedKey.equals(inProgress)) {
				resp.sendError(HttpServletResponse.SC_CONFLICT, "Checkout request is already being processed.");
				return false;
			}

			Object expected = session.getAttribute(CHECKOUT_IDEMPOTENCY_KEY);
			if (submittedKey == null || submittedKey.isBlank() || !submittedKey.equals(expected)) {
				resp.sendError(HttpServletResponse.SC_CONFLICT, "Invalid or reused checkout idempotency key.");
				return false;
			}

			session.removeAttribute(CHECKOUT_IDEMPOTENCY_KEY);
			session.setAttribute(CHECKOUT_IN_PROGRESS_KEY, submittedKey);
			return true;
		}
	}

	private void completeIdempotencyKey(HttpSession session, String submittedKey, int orderId) {
		synchronized (session) {
			if (submittedKey != null && !submittedKey.isBlank()) {
				session.setAttribute(CHECKOUT_RESULT_PREFIX + submittedKey, orderId);
			}
			session.removeAttribute(CHECKOUT_IN_PROGRESS_KEY);
		}
	}

	private void clearInProgressKey(HttpSession session, String submittedKey) {
		if (session == null || submittedKey == null || submittedKey.isBlank()) {
			return;
		}
		synchronized (session) {
			Object inProgress = session.getAttribute(CHECKOUT_IN_PROGRESS_KEY);
			if (submittedKey.equals(inProgress)) {
				session.removeAttribute(CHECKOUT_IN_PROGRESS_KEY);
			}
		}
	}

	private Integer previousOrderId(HttpSession session, String submittedKey) {
		if (submittedKey == null || submittedKey.isBlank()) {
			return null;
		}
		Object value = session.getAttribute(CHECKOUT_RESULT_PREFIX + submittedKey);
		return value instanceof Integer orderId ? orderId : null;
	}
}

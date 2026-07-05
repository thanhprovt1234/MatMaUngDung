package ute.shop.controller.payment;

import java.io.IOException;
import java.nio.charset.StandardCharsets;

import com.stripe.exception.SignatureVerificationException;
import com.stripe.model.Event;
import com.stripe.model.PaymentIntent;
import com.stripe.net.Webhook;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import ute.shop.config.StripeConfig;
import ute.shop.services.IPaymentService;
import ute.shop.services.implement.PaymentServiceImpl;

@WebServlet(urlPatterns = "/payments/stripe/webhook")
public class StripeWebhookController extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private final IPaymentService paymentService = new PaymentServiceImpl();

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		String payload = new String(req.getInputStream().readAllBytes(), StandardCharsets.UTF_8);
		String signature = req.getHeader("Stripe-Signature");
		if (signature == null || signature.isBlank()) {
			resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing Stripe-Signature header.");
			return;
		}

		Event event;
		try {
			event = Webhook.constructEvent(payload, signature, StripeConfig.webhookSecret());
		} catch (SignatureVerificationException e) {
			resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid Stripe webhook signature.");
			return;
		}

		switch (event.getType()) {
			case "payment_intent.succeeded", "payment_intent.payment_failed", "payment_intent.canceled" ->
				handlePaymentIntentEvent(event);
			default -> {
				// Unknown or irrelevant Stripe event. Return 200 so Stripe does not retry forever.
			}
		}

		resp.setStatus(HttpServletResponse.SC_OK);
		resp.setContentType("application/json");
		resp.getWriter().write("{\"received\":true}");
	}

	private void handlePaymentIntentEvent(Event event) {
		Object object = event.getDataObjectDeserializer().getObject().orElse(null);
		if (!(object instanceof PaymentIntent intent)) {
			throw new IllegalStateException("Stripe webhook does not contain a PaymentIntent object.");
		}
		paymentService.recordStripeWebhookStatus(intent.getId(), intent.getStatus(), event.getId());
	}
}

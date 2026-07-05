package ute.shop.services.implement;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import com.stripe.Stripe;
import com.stripe.model.PaymentIntent;
import com.stripe.model.PaymentMethod;
import ute.shop.config.JPAConfig;
import ute.shop.config.StripeConfig;
import ute.shop.entity.Order;
import ute.shop.entity.OrderStatus;
import ute.shop.entity.PaymentTransaction;
import ute.shop.entity.PaymentTransaction.PaymentStatus;
import ute.shop.services.IPaymentService;
import ute.shop.utils.PaymentTokenUtils;
import ute.shop.utils.SecurityAuditLogger;

public class PaymentServiceImpl implements IPaymentService {
	@Override
	public PaymentTransaction tokenizeAndAuthorize(Order order, String cardNumber, String expiry, String cvv) {
		if (order == null || order.get_id() <= 0) {
			throw new IllegalArgumentException("A saved order is required before payment authorization.");
		}

		PaymentTokenUtils.validateCardInput(cardNumber, expiry, cvv);

		EntityManager em = JPAConfig.getEntityManager();
		EntityTransaction transaction = em.getTransaction();
		try {
			transaction.begin();

			Order managedOrder = em.find(Order.class, order.get_id());
			if (managedOrder == null) {
				throw new IllegalArgumentException("Order not found for payment authorization.");
			}

			PaymentTransaction payment = new PaymentTransaction();
			payment.setOrder(managedOrder);
			payment.setPaymentToken(PaymentTokenUtils.generatePaymentToken());
			payment.setCardLast4(PaymentTokenUtils.last4(cardNumber));
			payment.setCardBrand(PaymentTokenUtils.detectBrand(cardNumber));
			payment.setAmount(managedOrder.getAmountFromUser());
			payment.setStatus(PaymentStatus.AUTHORIZED);
			payment.setGatewayReference(PaymentTokenUtils.generateGatewayReference());
			payment.setGatewayResponseCode("MOCK_APPROVED");
			payment.setPanRetained(false);
			payment.setCvvRetained(false);

			managedOrder.setIsPaidBefore(true);
			managedOrder.setStatus(OrderStatus.PROCESSED);

			em.persist(payment);
			transaction.commit();
			SecurityAuditLogger.log("payment_authorized",
					SecurityAuditLogger.fields("orderId", managedOrder.get_id(), "userId",
							managedOrder.getUser().get_id(), "amount", payment.getAmount(), "brand",
							payment.getCardBrand(), "last4", payment.getCardLast4(), "gatewayReference",
							payment.getGatewayReference()));
			return payment;
		} catch (RuntimeException e) {
			if (transaction.isActive()) {
				transaction.rollback();
			}
			throw e;
		} catch (Exception e) {
			if (transaction.isActive()) {
				transaction.rollback();
			}
			throw new RuntimeException("Unable to authorize mock payment.", e);
		} finally {
			em.close();
		}
	}

	@Override
	public PaymentTransaction recordStripePayment(Order order, String paymentIntentId) {
		if (order == null || order.get_id() <= 0) {
			throw new IllegalArgumentException("A saved order is required before payment authorization.");
		}
		if (paymentIntentId == null || paymentIntentId.isBlank()) {
			throw new IllegalArgumentException("Stripe paymentIntentId is required.");
		}

		try {
			Stripe.apiKey = StripeConfig.secretKey();
			PaymentIntent intent = PaymentIntent.retrieve(paymentIntentId);
			if (!"succeeded".equalsIgnoreCase(intent.getStatus())) {
				throw new IllegalStateException("Stripe PaymentIntent is not succeeded. status=" + intent.getStatus());
			}

			String paymentMethodId = String.valueOf(intent.getPaymentMethod());
			if (paymentMethodId == null || paymentMethodId.isBlank() || "null".equals(paymentMethodId)) {
				throw new IllegalStateException("Stripe PaymentIntent does not contain a payment method.");
			}
			PaymentMethod paymentMethod = PaymentMethod.retrieve(paymentMethodId);
			String cardBrand = paymentMethod.getCard() == null ? "UNKNOWN" : paymentMethod.getCard().getBrand();
			String cardLast4 = paymentMethod.getCard() == null ? "0000" : paymentMethod.getCard().getLast4();

			EntityManager em = JPAConfig.getEntityManager();
			EntityTransaction transaction = em.getTransaction();
			try {
				transaction.begin();

				Order managedOrder = em.find(Order.class, order.get_id());
				if (managedOrder == null) {
					throw new IllegalArgumentException("Order not found for payment authorization.");
				}

				PaymentTransaction payment = new PaymentTransaction();
				payment.setOrder(managedOrder);
				payment.setPaymentToken(intent.getId());
				payment.setCardLast4(cardLast4);
				payment.setCardBrand(cardBrand == null ? "UNKNOWN" : cardBrand.toUpperCase());
				payment.setAmount(managedOrder.getAmountFromUser());
				payment.setStatus(PaymentStatus.AUTHORIZED);
				payment.setGatewayReference(intent.getId());
				payment.setGatewayResponseCode("STRIPE_" + intent.getStatus().toUpperCase());
				payment.setPanRetained(false);
				payment.setCvvRetained(false);

				managedOrder.setIsPaidBefore(true);
				managedOrder.setStatus(OrderStatus.PROCESSED);

				em.persist(payment);
				transaction.commit();
				SecurityAuditLogger.log("payment_authorized",
						SecurityAuditLogger.fields("gateway", "stripe", "orderId", managedOrder.get_id(), "userId",
								managedOrder.getUser().get_id(), "amount", payment.getAmount(), "brand",
								payment.getCardBrand(), "last4", payment.getCardLast4(), "gatewayReference",
								payment.getGatewayReference(), "panRetained", false, "cvvRetained", false));
				return payment;
			} catch (RuntimeException e) {
				if (transaction.isActive()) {
					transaction.rollback();
				}
				throw e;
			} finally {
				em.close();
			}
		} catch (Exception e) {
			throw new RuntimeException("Unable to verify Stripe payment.", e);
		}
	}

	@Override
	public boolean recordStripeWebhookStatus(String paymentIntentId, String stripeStatus, String eventId) {
		if (paymentIntentId == null || paymentIntentId.isBlank()) {
			throw new IllegalArgumentException("Stripe paymentIntentId is required.");
		}
		String normalizedStatus = stripeStatus == null ? "" : stripeStatus.trim().toLowerCase();
		EntityManager em = JPAConfig.getEntityManager();
		EntityTransaction transaction = em.getTransaction();
		try {
			transaction.begin();
			PaymentTransaction payment = em
					.createQuery("SELECT p FROM PaymentTransaction p JOIN FETCH p.order WHERE p.gatewayReference = :gatewayReference",
							PaymentTransaction.class)
					.setParameter("gatewayReference", paymentIntentId)
					.getResultStream()
					.findFirst()
					.orElse(null);
			if (payment == null) {
				transaction.rollback();
				SecurityAuditLogger.log("payment_webhook_unmatched",
						SecurityAuditLogger.fields("gateway", "stripe", "paymentIntentId", paymentIntentId,
								"stripeStatus", normalizedStatus, "eventId", eventId));
				return false;
			}

			if ("succeeded".equals(normalizedStatus)) {
				payment.setStatus(PaymentStatus.AUTHORIZED);
				payment.setGatewayResponseCode("STRIPE_SUCCEEDED");
				payment.getOrder().setIsPaidBefore(true);
				payment.getOrder().setStatus(OrderStatus.PROCESSED);
			} else if ("requires_payment_method".equals(normalizedStatus) || "canceled".equals(normalizedStatus)
					|| "payment_failed".equals(normalizedStatus)) {
				payment.setStatus(PaymentStatus.DECLINED);
				payment.setGatewayResponseCode("STRIPE_" + normalizedStatus.toUpperCase());
				payment.getOrder().setIsPaidBefore(false);
			} else {
				payment.setGatewayResponseCode("STRIPE_" + normalizedStatus.toUpperCase());
			}

			transaction.commit();
			SecurityAuditLogger.log("payment_webhook_status",
					SecurityAuditLogger.fields("gateway", "stripe", "paymentIntentId", paymentIntentId,
							"stripeStatus", normalizedStatus, "eventId", eventId, "localStatus",
							payment.getStatus()));
			return true;
		} catch (RuntimeException e) {
			if (transaction.isActive()) {
				transaction.rollback();
			}
			throw e;
		} finally {
			em.close();
		}
	}
}

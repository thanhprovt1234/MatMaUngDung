package ute.shop.services;

import ute.shop.entity.Order;
import ute.shop.entity.PaymentTransaction;

public interface IPaymentService {
	PaymentTransaction tokenizeAndAuthorize(Order order, String cardNumber, String expiry, String cvv);

	PaymentTransaction recordStripePayment(Order order, String paymentIntentId);

	boolean recordStripeWebhookStatus(String paymentIntentId, String stripeStatus, String eventId);
}

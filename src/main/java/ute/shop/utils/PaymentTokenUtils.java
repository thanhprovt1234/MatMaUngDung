package ute.shop.utils;

import java.security.SecureRandom;
import java.time.YearMonth;
import java.util.Base64;

public final class PaymentTokenUtils {
	private static final SecureRandom SECURE_RANDOM = new SecureRandom();
	private static final Base64.Encoder TOKEN_ENCODER = Base64.getUrlEncoder().withoutPadding();

	private PaymentTokenUtils() {
	}

	public static String generatePaymentToken() {
		byte[] randomBytes = new byte[24];
		SECURE_RANDOM.nextBytes(randomBytes);
		return "pay_tok_" + TOKEN_ENCODER.encodeToString(randomBytes);
	}

	public static String generateGatewayReference() {
		byte[] randomBytes = new byte[12];
		SECURE_RANDOM.nextBytes(randomBytes);
		return "mock_auth_" + TOKEN_ENCODER.encodeToString(randomBytes);
	}

	public static String normalizePan(String cardNumber) {
		return cardNumber == null ? "" : cardNumber.replaceAll("[\\s-]", "");
	}

	public static void validateCardInput(String cardNumber, String expiry, String cvv) {
		String pan = normalizePan(cardNumber);
		if (!pan.matches("\\d{13,19}") || !passesLuhn(pan)) {
			throw new IllegalArgumentException("Invalid card number.");
		}
		if (!isValidExpiry(expiry)) {
			throw new IllegalArgumentException("Invalid card expiry.");
		}
		if (cvv == null || !cvv.matches("\\d{3,4}")) {
			throw new IllegalArgumentException("Invalid card security code.");
		}
	}

	public static String last4(String cardNumber) {
		String pan = normalizePan(cardNumber);
		if (pan.length() < 4) {
			throw new IllegalArgumentException("Invalid card number.");
		}
		return pan.substring(pan.length() - 4);
	}

	public static String detectBrand(String cardNumber) {
		String pan = normalizePan(cardNumber);
		if (pan.startsWith("4")) {
			return "VISA";
		}
		if (pan.matches("5[1-5].*") || pan.matches("2(2[2-9]|[3-6][0-9]|7[01]|720).*")) {
			return "MASTERCARD";
		}
		if (pan.matches("3[47].*")) {
			return "AMEX";
		}
		return "UNKNOWN";
	}

	private static boolean passesLuhn(String pan) {
		int sum = 0;
		boolean doubleDigit = false;
		for (int i = pan.length() - 1; i >= 0; i--) {
			int digit = pan.charAt(i) - '0';
			if (doubleDigit) {
				digit *= 2;
				if (digit > 9) {
					digit -= 9;
				}
			}
			sum += digit;
			doubleDigit = !doubleDigit;
		}
		return sum % 10 == 0;
	}

	private static boolean isValidExpiry(String expiry) {
		if (expiry == null || !expiry.matches("(0[1-9]|1[0-2])/\\d{2}")) {
			return false;
		}
		int month = Integer.parseInt(expiry.substring(0, 2));
		int year = 2000 + Integer.parseInt(expiry.substring(3, 5));
		return !YearMonth.of(year, month).isBefore(YearMonth.now());
	}
}

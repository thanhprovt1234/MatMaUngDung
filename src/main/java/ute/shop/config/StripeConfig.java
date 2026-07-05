package ute.shop.config;

import ute.shop.utils.SecretsConfig;

public final class StripeConfig {
	private static final String DEFAULT_CURRENCY = "usd";

	private StripeConfig() {
	}

	public static String publishableKey() {
		return SecretsConfig.require("stripe.publishable.key", "STRIPE_PUBLISHABLE_KEY");
	}

	public static String secretKey() {
		return SecretsConfig.require("stripe.secret.key", "STRIPE_SECRET_KEY");
	}

	public static String webhookSecret() {
		return SecretsConfig.require("stripe.webhook.secret", "STRIPE_WEBHOOK_SECRET");
	}

	public static String currency() {
		return SecretsConfig.get("stripe.currency", "STRIPE_CURRENCY", DEFAULT_CURRENCY).toLowerCase();
	}
}

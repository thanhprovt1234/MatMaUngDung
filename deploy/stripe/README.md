# Stripe Test Mode Setup For UTEShop

This integration uses Stripe test mode for a production-like card checkout flow:

- Browser loads Stripe.js from `https://js.stripe.com/v3/`.
- `/payments/create-intent` creates a Stripe PaymentIntent with the server-side secret key.
- Browser confirms the card payment with Stripe, including 3DS/SCA when required.
- `/orders/place` receives only `paymentIntentId`.
- Server retrieves the PaymentIntent and PaymentMethod from Stripe, then stores only gateway identifiers and non-sensitive card metadata.
- `/payments/stripe/webhook` verifies the `Stripe-Signature` header before accepting webhook events.

## Required Secrets

Put these values into Vault KV at `secret/uteshop/prod`:

```text
STRIPE_PUBLISHABLE_KEY=pk_test_xxx
STRIPE_SECRET_KEY=sk_test_xxx
STRIPE_WEBHOOK_SECRET=whsec_xxx
STRIPE_CURRENCY=usd
```

Then restart Vault Agent so it renders `C:\secure\uteshop\secrets.properties`, and restart Jetty.

## Stripe Dashboard

In Stripe test mode:

1. Open **Developers -> API keys** and copy the publishable and secret test keys.
2. Open **Developers -> Webhooks -> Add endpoint**.
3. Endpoint URL:

```text
https://YOUR_DOMAIN/uteshop/payments/stripe/webhook
```

4. Select events:

```text
payment_intent.succeeded
payment_intent.payment_failed
payment_intent.canceled
```

5. Copy the signing secret `whsec_...`.

## Test Cards

```text
Normal success: 4242 4242 4242 4242
3DS/SCA required: 4000 0025 0000 3155
Expiry: any future MM/YY
CVC: any 3 digits
ZIP: any value if Stripe asks
```

The app never receives or stores PAN/CVV. Card entry is handled by Stripe.js.

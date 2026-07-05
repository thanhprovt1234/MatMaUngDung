<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<html>
<head>
<title>Place Order</title>
</head>
<body>
	<h1>Place Your Order</h1>

	<form action="${pageContext.request.contextPath}/orders/place"
		method="post" id="checkout-form">
		<input type="hidden" name="csrfToken" value="${csrfToken}" />
		<input type="hidden" name="idempotencyKey" value="${idempotencyKey}" />
		<input type="hidden" id="paymentIntentId" name="paymentIntentId" />

		<label for="address">Address:</label>
		<input type="text" id="address" name="address"
			value="${not empty user.address ? user.address : ''}" required
			placeholder="Enter your address" />
		<br>

		<label for="phone">Phone:</label>
		<input type="text" id="phone" name="phone"
			value="${not empty user.phone ? user.phone : ''}" required
			placeholder="Enter your phone number" />
		<br>

		<label for="deliveryId">Delivery Method:</label>
		<select id="deliveryId" name="deliveryId" required>
			<c:forEach var="delivery" items="${deliveryList}">
				<option value="${delivery._id}">${delivery.name} -
					${delivery.price} USD</option>
			</c:forEach>
		</select>
		<input type="hidden" name="storeId" value="${store._id}" />
		<br>

		<label>Card:</label>
		<div id="card-element"
			style="max-width: 420px; min-height: 22px; padding: 12px; border: 1px solid #ccc;"></div>
		<div id="card-errors" style="color: #c00; margin-top: 8px;"></div>
		<br>

		<button type="submit" id="submit-button">Place Order</button>
	</form>

	<script>
		const form = document.getElementById('checkout-form');
		const submitButton = document.getElementById('submit-button');
		const errorBox = document.getElementById('card-errors');
		const publishableKey = '${stripePublishableKey}';
		let stripe;
		let card;

		function loadStripeJs() {
			return new Promise(function(resolve, reject) {
				if (window.Stripe) {
					resolve();
					return;
				}

				const script = document.createElement('script');
				script.src = 'https://js.stripe.com/v3/';
				script.onload = function() {
					window.Stripe ? resolve() : reject(new Error('Stripe.js loaded but window.Stripe is missing.'));
				};
				script.onerror = function() {
					reject(new Error('Cannot load Stripe.js. Check CSP, ad blocker, or network.'));
				};
				document.head.appendChild(script);
			});
		}

		async function initializeStripeCard() {
			if (!publishableKey || publishableKey.indexOf('pk_') !== 0 || publishableKey.indexOf('_xxx') !== -1) {
				throw new Error('Stripe publishable key is not configured correctly.');
			}

			await loadStripeJs();
			stripe = window.Stripe(publishableKey);
			const elements = stripe.elements();
			card = elements.create('card');
			card.mount('#card-element');
		}

		initializeStripeCard().catch(function(error) {
			errorBox.textContent = error.message;
			submitButton.disabled = true;
		});

		form.addEventListener('submit', async function(event) {
			event.preventDefault();
			if (!stripe || !card) {
				errorBox.textContent = 'Stripe is not ready. Check STRIPE_PUBLISHABLE_KEY and Stripe.js loading.';
				return;
			}

			submitButton.disabled = true;
			errorBox.textContent = '';

			const params = new URLSearchParams();
			params.set('csrfToken', form.elements['csrfToken'].value);
			params.set('idempotencyKey', form.elements['idempotencyKey'].value);

			const intentResponse = await fetch('${pageContext.request.contextPath}/payments/create-intent', {
				method: 'POST',
				headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
				body: params
			});

			if (!intentResponse.ok) {
				errorBox.textContent = await intentResponse.text();
				submitButton.disabled = false;
				return;
			}

			const intent = await intentResponse.json();
			const result = await stripe.confirmCardPayment(intent.clientSecret, {
				payment_method: { card: card }
			});

			if (result.error) {
				errorBox.textContent = result.error.message;
				submitButton.disabled = false;
				return;
			}

			document.getElementById('paymentIntentId').value = result.paymentIntent.id;
			form.submit();
		});
	</script>
</body>
</html>

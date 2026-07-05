<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<section id="cart_items">
	<div class="container">
		<div class="breadcrumbs">
			<ol class="breadcrumb">
				<li><a href="${pageContext.request.contextPath}/home">Home</a></li>
				<li class="active">Shopping Cart</li>
			</ol>
		</div>
		<div class="table-responsive cart_info">
			<table class="table table-condensed">
				<thead>
					<tr class="cart_menu">
						<td class="image">Item</td>
						<td class="description"></td>
						<td class="price">Price</td>
						<td class="quantity">Quantity</td>
						<td class="total">Total</td>
						<td></td>
					</tr>
				</thead>
				<tbody>
					<c:if test="${empty cart.cartItems}">
						<tr>
							<td colspan="6" style="text-align: center; padding: 30px;">
								Your cart is empty.
								<a href="${pageContext.request.contextPath}/home">Continue shopping</a>
							</td>
						</tr>
					</c:if>
					<c:forEach var="item" items="${cart.cartItems}">
						<tr>
							<td class="cart_product">
								<img src="${pageContext.request.contextPath}/images/product/${item.product.firstImage}"
									alt="${item.product.name}">
							</td>
							<td class="cart_description">
								<h4>
									<a href="${pageContext.request.contextPath}/home/productDetail?id=${item.product._id}">
										${item.product.name}
									</a>
								</h4>
								<p>Product ID: ${item.product._id}</p>
							</td>
							<td class="cart_price">
								<p>${item.product.price}</p>
							</td>
							<td class="cart_quantity">
								<form action="${pageContext.request.contextPath}/cart/update"
									method="post">
									<input type="hidden" name="csrfToken" value="${csrfToken}">
									<input type="hidden" name="productId"
										value="${item.product._id}">
									<div class="cart_quantity_button">
										<input class="cart_quantity_input" type="number" name="count"
											value="${item.count}" min="1" required>
									</div>
									<button type="submit" class="btn btn-default">Update</button>
								</form>
							</td>
							<td class="cart_total">
								<p class="cart_total_price">${item.product.price * item.count}</p>
							</td>
							<td class="cart_delete">
								<form action="${pageContext.request.contextPath}/cart/remove"
									method="post">
									<input type="hidden" name="csrfToken" value="${csrfToken}">
									<input type="hidden" name="productId"
										value="${item.product._id}">
									<button type="submit" class="btn-danger">
										<i class="fa fa-times"></i>
									</button>
								</form>
							</td>
						</tr>
					</c:forEach>
				</tbody>
			</table>
		</div>
	</div>
</section>

<c:if test="${not empty cart.cartItems}">
	<section id="do_action">
		<div class="container">
			<div class="heading">
				<h3>What would you like to do next?</h3>
				<p>Choose if you have a discount code or reward points you want
					to use or would like to estimate your delivery cost.</p>
			</div>
			<div class="row">
				<div class="col-sm-6">
					<div class="chose_area">
						<ul class="user_option">
							<li><input type="checkbox"> <label>Use Coupon Code</label></li>
							<li><input type="checkbox"> <label>Use Gift Voucher</label></li>
							<li><input type="checkbox"> <label>Estimate Shipping & Taxes</label></li>
						</ul>
						<ul class="user_info">
							<li class="single_field"><label>Country:</label> <select>
									<option>United States</option>
									<option>Bangladesh</option>
									<option>UK</option>
									<option>India</option>
									<option>Pakistan</option>
									<option>Ucrane</option>
									<option>Canada</option>
									<option>Dubai</option>
							</select></li>
							<li class="single_field"><label>Region / State:</label> <select>
									<option>Select</option>
									<option>Dhaka</option>
									<option>London</option>
									<option>Dillih</option>
									<option>Lahore</option>
									<option>Alaska</option>
									<option>Canada</option>
									<option>Dubai</option>
							</select></li>
							<li class="single_field zip-field"><label>Zip Code:</label>
								<input type="text"></li>
						</ul>
						<a class="btn btn-default update" href="#">Get Quotes</a>
						<a class="btn btn-default check_out"
							href="${pageContext.request.contextPath}/home">Continue Shopping</a>
					</div>
				</div>
				<div class="col-sm-6">
					<div class="total_area">
						<ul>
							<li>Cart Sub Total <span>${totalSum}</span></li>
							<li>Eco Tax <span>$2</span></li>
							<li>Shipping Cost <span>Free</span></li>
							<li>Total <span>${totalSum + 2}</span></li>
						</ul>
						<a class="btn btn-default check_out"
							href="${pageContext.request.contextPath}/orders/place">Check Out</a>
					</div>
				</div>
			</div>
		</div>
	</section>
</c:if>

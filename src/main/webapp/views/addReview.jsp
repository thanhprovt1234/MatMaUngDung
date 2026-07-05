<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<body
	style="font-family: Arial, sans-serif; color: #333; margin: 0; padding: 0;">
	<div
		style="background-color: white; padding: 30px; border-radius: 8px; box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1); width: 100%; max-width: 600px;">
		<h1 style="text-align: center; color: #333; margin-bottom: 20px;">Thêm
			đánh giá</h1>

		<form action="${pageContext.request.contextPath}/reviews/add"
			method="post"
			style="display: flex; flex-direction: column; gap: 20px;">
			<input type="hidden" name="csrfToken" value="${csrfToken}" />
			<!-- Loop over orderItems to add productId for each product -->
			<c:forEach var="item" items="${order.orderItems}">
				<input type="hidden" name="productId" value="${item.product._id}" />
			</c:forEach>
			<input type="hidden" name="orderId" value="${order._id}" /> <input
				type="hidden" name="storeId" value="${store._id}" /> <label
				for="stars" style="font-size: 16px; color: #333;">Đánh giá
				(1-5 sao):</label> <select name="stars" id="stars" required
				style="padding: 10px; font-size: 16px; border: 1px solid #ccc; border-radius: 5px;">
				<option value="1">1 sao</option>
				<option value="2">2 sao</option>
				<option value="3">3 sao</option>
				<option value="4">4 sao</option>
				<option value="5">5 sao</option>
			</select> <label for="content" style="font-size: 16px; color: #333;">Nội
				dung:</label>
			<textarea name="content" id="content" required
				style="padding: 10px; font-size: 16px; border: 1px solid #ccc; border-radius: 5px; height: 150px;"></textarea>

			<button type="submit"
				style="padding: 12px 20px; background-color: #28a745; color: white; border: none; border-radius: 5px; cursor: pointer; font-size: 16px;">Gửi
				đánh giá</button>
		</form>
	</div>
</body>

<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<body
	style="font-family: Arial, sans-serif; color: #333; margin: 0; padding: 0;">
	<div
		style="background-color: white; padding: 30px; border-radius: 8px; box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1); width: 100%; max-width: 1000px;">
		<h1 style="text-align: center; color: #333; margin-bottom: 20px;">Lịch
			sử mua hàng</h1>

		<c:choose>
			<c:when test="${not empty orders}">
				<table border="1"
					style="width: 100%; border-collapse: collapse; margin-bottom: 20px;">
					<thead>
						<tr style="background-color: #007bff; color: white;">
							<th style="padding: 12px 15px; text-align: center;">Mã đơn
								hàng</th>
							<th style="padding: 12px 15px; text-align: center;">Ngày đặt</th>
							<th style="padding: 12px 15px; text-align: center;">Trạng
								thái</th>
							<th style="padding: 12px 15px; text-align: center;">Tổng
								tiền</th>
							<th style="padding: 12px 15px; text-align: center;">Store Name</th>
							<th style="padding: 12px 15px; text-align: center;">Product
								Name</th>
							<th style="padding: 12px 15px; text-align: center;">Hành
								động</th>
						</tr>
					</thead>
					<tbody>
						<c:forEach var="order" items="${orders}">
							<tr style="border-bottom: 1px solid #ddd;">
								<!-- Hiển thị Mã đơn hàng và các thông tin khác -->
								<td style="padding: 12px 15px; text-align: center;">${order._id}</td>
								<td style="padding: 12px 15px; text-align: center;">${order.createdAt}</td>
								<td style="padding: 12px 15px; text-align: center;">${order.status}</td>
								<td style="padding: 12px 15px; text-align: center;">${order.amountFromUser}</td>
								<!-- Hiển thị tên cửa hàng thay vì Store ID -->
								<td style="padding: 12px 15px; text-align: center;">${order.store.name}</td>
								<!-- Hiển thị tên sản phẩm thay vì Product ID -->
								<td style="padding: 12px 15px; text-align: center;"><c:forEach
										var="item" items="${order.orderItems}">
										<p>${item.product.name}</p>
									</c:forEach></td>
								<td style="padding: 12px 15px; text-align: center;">
									<!-- Hủy đơn hàng nếu trạng thái là 'NOT_PROCESSED' --> <c:if
										test="${order.status == 'NOT_PROCESSED'}">
										<form
											action="${pageContext.request.contextPath}/orders/cancel"
											method="post" style="display: inline;">
											<input type="hidden" name="csrfToken" value="${csrfToken}" />
											<input type="hidden" name="orderId" value="${order._id}" />
											<button type="submit"
												style="background-color: #dc3545; color: white; padding: 8px 16px; border: none; border-radius: 5px; cursor: pointer;">Hủy</button>
										</form>
									</c:if> <!-- Đánh giá nếu trạng thái là 'DELIVERED' --> <c:if
										test="${order.status == 'DELIVERED'}">
										<form action="${pageContext.request.contextPath}/reviews/add"
											method="get" style="display: inline;">
											<input type="hidden" name="orderId" value="${order._id}" />
											<input type="hidden" name="storeId"
												value="${order.store._id}" />
											<c:forEach var="item" items="${order.orderItems}">
												<input type="hidden" name="productId"
													value="${item.product._id}" />
											</c:forEach>
											<button type="submit"
												style="background-color: #28a745; color: white; padding: 8px 16px; border: none; border-radius: 5px; cursor: pointer;">Đánh
												giá</button>
										</form>
									</c:if>
								</td>
							</tr>
						</c:forEach>
					</tbody>

				</table>
			</c:when>
			<c:otherwise>
				<p style="text-align: center; color: #555;">Bạn chưa có đơn hàng
					nào.</p>
			</c:otherwise>
		</c:choose>
	</div>
</body>

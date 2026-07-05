<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<body
	style="font-family: Arial, sans-serif; color: #333; margin: 0; padding: 0;">
	<div
		style="background-color: white; width: 100%; max-width: 600px; padding: 30px; border-radius: 8px; box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);">
		<h1 style="text-align: center; color: #333; margin-bottom: 20px;">Sửa
			thông tin cá nhân</h1>
		<form action="${pageContext.request.contextPath}/edit-profile"
			method="post" style="display: flex; flex-direction: column;">
			<input type="hidden" name="csrfToken" value="${csrfToken}" />
			<div style="margin-bottom: 15px;">
				<label for="email"
					style="font-size: 16px; margin-bottom: 8px; color: #333;">Email:</label>
				<input type="email" id="email" name="email" value="${account.email}"
					required
					style="padding: 10px; margin-bottom: 20px; border: 1px solid #ccc; border-radius: 5px; font-size: 16px;">
			</div>
			<div style="margin-bottom: 15px;">
				<label for="phone"
					style="font-size: 16px; margin-bottom: 8px; color: #333;">Số
					điện thoại:</label> <input type="text" id="phone" name="phone"
					value="${account.phone}" required
					style="padding: 10px; margin-bottom: 20px; border: 1px solid #ccc; border-radius: 5px; font-size: 16px;">
			</div>
			<div style="margin-bottom: 15px;">
				<label for="address"
					style="font-size: 16px; margin-bottom: 8px; color: #333;">Địa
					chỉ:</label> <input type="text" id="address" name="address"
					value="${account.address}" required
					style="padding: 10px; margin-bottom: 20px; border: 1px solid #ccc; border-radius: 5px; font-size: 16px;">
			</div>
			<div style="margin-bottom: 15px;">
				<label for="firstname"
					style="font-size: 16px; margin-bottom: 8px; color: #333;">Họ:</label>
				<input type="text" id="firstname" name="firstname"
					value="${account.firstname}" required
					style="padding: 10px; margin-bottom: 20px; border: 1px solid #ccc; border-radius: 5px; font-size: 16px;">
			</div>
			<div style="margin-bottom: 15px;">
				<label for="lastname"
					style="font-size: 16px; margin-bottom: 8px; color: #333;">Tên:</label>
				<input type="text" id="lastname" name="lastname"
					value="${account.lastname}" required
					style="padding: 10px; margin-bottom: 20px; border: 1px solid #ccc; border-radius: 5px; font-size: 16px;">
			</div>
			<div style="margin-bottom: 15px;">
				<label for="id_card"
					style="font-size: 16px; margin-bottom: 8px; color: #333;">Chứng
					minh nhân dân:</label> <input type="text" id="id_card" name="id_card"
					value="${account.id_card}" required
					style="padding: 10px; margin-bottom: 20px; border: 1px solid #ccc; border-radius: 5px; font-size: 16px;">
			</div>
			<div
				style="display: flex; justify-content: space-between; align-items: center;">
				<button type="submit"
					style="background-color: #007bff; color: white; padding: 12px 20px; border: none; border-radius: 5px; cursor: pointer; font-size: 16px; transition: background-color 0.3s;">Lưu
					thay đổi</button>
				<button type="button"
					onclick="window.location.href='${pageContext.request.contextPath}/profile'"
					style="background-color: #28a745; color: white; padding: 12px 20px; border: none; border-radius: 5px; cursor: pointer; font-size: 16px; transition: background-color 0.3s;">Hủy</button>
			</div>
		</form>
	</div>
</body>

<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<body
	style="font-family: Arial, sans-serif; color: #333; margin: 0; padding: 0;">
	<div
		style="width: 80%; margin: 0 auto; padding: 20px; background-color: #fff; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1); border-radius: 8px;">
		<h1 style="text-align: center; margin-top: 20px; color: #333;">Thông
			tin tài khoản</h1>

		<c:choose>
			<c:when test="${not empty account}">
				<div style="margin-bottom: 20px; text-align: center;">
					<p>
						<c:choose>
							<c:when test="${not empty account.avatar}">
								<img
									src="${pageContext.request.contextPath}/images/${account.avatar}"
									alt="Avatar" width="150" height="150"
									style="border-radius: 50%; display: block; margin: 0 auto;">
							</c:when>
							<c:otherwise>
								<img
									src="${pageContext.request.contextPath}/images/default-avatar.jpg"
									alt="Default Avatar" width="150" height="150"
									style="border-radius: 50%; display: block; margin: 0 auto;">
							</c:otherwise>
						</c:choose>
					</p>

					<form action="${pageContext.request.contextPath}/upload-avatar"
						method="post" enctype="multipart/form-data"
						style="margin-top: 20px; display: flex; flex-direction: column; align-items: center;">
						<input type="hidden" name="csrfToken" value="${csrfToken}" />
						<input type="file" name="avatar" accept="image/*" required
							style="padding: 10px; margin: 5px 0; border: 1px solid #ccc; border-radius: 5px;">
						<button type="submit"
							style="padding: 10px; background-color: #007bff; color: white; border: none; border-radius: 5px; cursor: pointer; margin-top: 10px;">Upload</button>
					</form>

					<div
						style="max-width: 800px; margin: 0 auto; padding: 20px; background-color: #f9f9f9; border-radius: 8px; box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);">
						<p style="font-size: 18px; margin: 10px 0; line-height: 1.6;">
							<strong style="color: #007bff;">Email:</strong> ${account.email}
						</p>
						<p style="font-size: 18px; margin: 10px 0; line-height: 1.6;">
							<strong style="color: #007bff;">Số điện thoại:</strong>
							${account.phone}
						</p>
						<p style="font-size: 18px; margin: 10px 0; line-height: 1.6;">
							<strong style="color: #007bff;">Họ và tên:</strong>
							${account.firstname} ${account.lastname}
						</p>
						<p style="font-size: 18px; margin: 10px 0; line-height: 1.6;">
							<strong style="color: #007bff;">Chứng minh nhân dân:</strong>
							${account.id_card}
						</p>
						<p style="font-size: 18px; margin: 10px 0; line-height: 1.6;">
							<strong style="color: #007bff;">Kích hoạt email:</strong>
							${account.isEmailActive ? "Đã kích hoạt" : "Chưa kích hoạt"}
						</p>
						<p style="font-size: 18px; margin: 10px 0; line-height: 1.6;">
							<strong style="color: #007bff;">Kích hoạt số điện thoại:</strong>
							${account.isPhoneActive ? "Đã kích hoạt" : "Chưa kích hoạt"}
						</p>
						<p style="font-size: 18px; margin: 10px 0; line-height: 1.6;">
							<strong style="color: #007bff;">Vai trò:</strong> ${account.role == 'ADMIN' ? "Admin" : "Người dùng"}
						</p>
						<p style="font-size: 18px; margin: 10px 0; line-height: 1.6;">
							<strong style="color: #007bff;">Địa chỉ:</strong>
							${account.address != null ? account.address : "Chưa cập nhật"}
						</p>
						<p style="font-size: 18px; margin: 10px 0; line-height: 1.6;">
							<strong style="color: #007bff;">Số dư ví điện tử:</strong>
							${account.e_wallet} USD
						</p>
						<p style="font-size: 18px; margin: 10px 0; line-height: 1.6;">
							<strong style="color: #007bff;">Ngày tạo:</strong>
							${account.createdAt}
						</p>
						<p style="font-size: 18px; margin: 10px 0; line-height: 1.6;">
							<strong style="color: #007bff;">Ngày cập nhật:</strong>
							${account.updatedAt}
						</p>
					</div>

					<div
						style="display: flex; justify-content: center; margin-top: 20px;">
						<button
							onclick="window.location.href='${pageContext.request.contextPath}/edit-profile'"
							style="padding: 10px 20px; background-color: #28a745; color: white; border: none; border-radius: 5px; cursor: pointer; margin-right: 10px;">Sửa
							thông tin</button>
						<button onclick="showChangePasswordForm()"
							style="padding: 10px 20px; background-color: #28a745; color: white; border: none; border-radius: 5px; cursor: pointer;">Thay
							đổi mật khẩu</button>
					</div>


					<div id="changePasswordForm"
						style="display: none; margin-top: 20px; text-align: center;">
						<h3>Thay đổi mật khẩu</h3>
						<form action="${pageContext.request.contextPath}/change-password"
							method="post" style="display: inline-block; text-align: left;">
							<input type="hidden" name="csrfToken" value="${csrfToken}" />
							<div>
								<label for="oldPassword">Mật khẩu cũ:</label> <input
									type="password" id="oldPassword" name="oldPassword" required
									style="padding: 10px; margin: 5px 0; border: 1px solid #ccc; border-radius: 5px;">
							</div>
							<div>
								<label for="newPassword">Mật khẩu mới:</label> <input
									type="password" id="newPassword" name="newPassword" required
									style="padding: 10px; margin: 5px 0; border: 1px solid #ccc; border-radius: 5px;">
							</div>
							<div>
								<label for="confirmPassword">Xác nhận mật khẩu mới:</label> <input
									type="password" id="confirmPassword" name="confirmPassword"
									required
									style="padding: 10px; margin: 5px 0; border: 1px solid #ccc; border-radius: 5px;">
							</div>
							<button type="submit"
								style="padding: 10px; background-color: #007bff; color: white; border: none; border-radius: 5px; cursor: pointer; margin-top: 10px;">Thay
								đổi mật khẩu</button>
						</form>
					</div>
			</c:when>
			<c:otherwise>
				<p>
					Bạn chưa đăng nhập. Vui lòng <a
						href="${pageContext.request.contextPath}/login">đăng nhập</a>.
				</p>
			</c:otherwise>
		</c:choose>

	</div>

	<script>
		function showChangePasswordForm() {
			var form = document.getElementById("changePasswordForm");
			form.style.display = form.style.display === "none" ? "block"
					: "none";
		}
	</script>
</body>

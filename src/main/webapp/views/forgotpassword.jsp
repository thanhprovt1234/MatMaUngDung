<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<body style="font-family: Arial, sans-serif; margin: 0; padding: 0;">
	<div class="container"
		style="max-width: 600px; margin: 100px auto; background-color: white; padding: 30px; border-radius: 8px; box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1); text-align: center;">
		<h2 class="my-4" style="color: #333;">Khôi phục mật khẩu</h2>

		<c:if test="${error != null}">
			<div class="alert alert-danger" role="alert"
				style="background-color: #f8d7da; color: #721c24; padding: 15px; border-radius: 5px; border: 1px solid #f5c6cb; margin-bottom: 20px;">
				${error}</div>
		</c:if>

		<c:if test="${message != null}">
			<div class="alert alert-success" role="alert"
				style="background-color: #d4edda; color: #155724; padding: 15px; border-radius: 5px; border: 1px solid #c3e6cb; margin-bottom: 20px;">
				${message}</div>
		</c:if>

		<c:choose>
			<c:when test="${forgotStep == 'otp'}">
				<p>Mã OTP đã được gửi tới ${maskedEmail}.</p>
				<form action="${pageContext.request.contextPath}/forgot-password"
					method="post" style="display: inline-block; text-align: left;">
					<input type="hidden" name="csrfToken" value="${csrfToken}" />
					<input type="hidden" name="action" value="verifyOtp" />
					<div class="form-group" style="margin-bottom: 20px;">
						<label for="otp" style="font-size: 16px; color: #333;">Nhập mã OTP:</label>
						<input type="text" id="otp" name="otp" maxlength="6" pattern="[0-9]{6}"
							class="form-control"
							style="padding: 10px; font-size: 16px; border: 1px solid #ccc; border-radius: 5px;"
							required>
					</div>
					<button type="submit" class="btn btn-primary"
						style="padding: 12px 20px; background-color: #007bff; color: white; border: none; border-radius: 5px; cursor: pointer; font-size: 16px;">
						Xác thực OTP</button>
				</form>
			</c:when>

			<c:when test="${forgotStep == 'reset'}">
				<form action="${pageContext.request.contextPath}/forgot-password"
					method="post" style="display: inline-block; text-align: left;">
					<input type="hidden" name="csrfToken" value="${csrfToken}" />
					<input type="hidden" name="action" value="resetPassword" />
					<div class="form-group" style="margin-bottom: 20px;">
						<label for="password" style="font-size: 16px; color: #333;">Mật khẩu mới:</label>
						<input type="password" id="password" name="password" class="form-control"
							style="padding: 10px; font-size: 16px; border: 1px solid #ccc; border-radius: 5px;"
							required>
					</div>
					<div class="form-group" style="margin-bottom: 20px;">
						<label for="confirmPassword" style="font-size: 16px; color: #333;">Nhập lại mật khẩu:</label>
						<input type="password" id="confirmPassword" name="confirmPassword"
							class="form-control"
							style="padding: 10px; font-size: 16px; border: 1px solid #ccc; border-radius: 5px;"
							required>
					</div>
					<button type="submit" class="btn btn-primary"
						style="padding: 12px 20px; background-color: #007bff; color: white; border: none; border-radius: 5px; cursor: pointer; font-size: 16px;">
						Đổi mật khẩu</button>
				</form>
			</c:when>

			<c:otherwise>
				<form action="${pageContext.request.contextPath}/forgot-password"
					method="post" style="display: inline-block; text-align: left;">
					<input type="hidden" name="csrfToken" value="${csrfToken}" />
					<input type="hidden" name="action" value="requestOtp" />
					<div class="form-group" style="margin-bottom: 20px;">
						<label for="email" style="font-size: 16px; color: #333;">Nhập email của bạn:</label>
						<input type="email" id="email" name="email" class="form-control"
							style="padding: 10px; font-size: 16px; border: 1px solid #ccc; border-radius: 5px;"
							required>
					</div>
					<button type="submit" class="btn btn-primary"
						style="padding: 12px 20px; background-color: #007bff; color: white; border: none; border-radius: 5px; cursor: pointer; font-size: 16px;">
						Gửi mã OTP</button>
				</form>
			</c:otherwise>
		</c:choose>

		<div class="mt-3" style="margin-top: 20px; text-align: center;">
			<a href="${pageContext.request.contextPath}/login"
				style="color: #007bff; text-decoration: none;">Quay lại trang đăng nhập</a>
		</div>
	</div>
</body>

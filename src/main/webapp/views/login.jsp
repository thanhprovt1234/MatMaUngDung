<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Login or Signup</title>
<link rel="stylesheet" href="path/to/your/styles.css">
<!-- Link file CSS -->
</head>

<body>
	<div class="form_wrapper">
		<div class="form_container">
			<div class="title_container">
				<h2>Welcome Back</h2>
				<p>Login to your account</p>
			</div>
			<c:if test="${alert != null}">
				<div class="message">
					<p style="color: red;">${alert}</p>
				</div>
			</c:if>
			<c:if test="${message != null}">
				<div class="message">
					<p style="color: green;">${message}</p>
				</div>
			</c:if>
			<div class="row clearfix">
				<c:choose>
					<c:when test="${mfaRequired}">
						<p style="text-align: center;">Enter the OTP sent to ${mfaEmail}</p>
						<form action="${pageContext.request.contextPath}/login" method="post">
							<input type="hidden" name="csrfToken" value="${csrfToken}" />
							<input type="hidden" name="action" value="verifyOtp" />
							<div class="input_field">
								<span><i aria-hidden="true" class="fa fa-key"></i></span> <input
									type="text" name="otp" placeholder="6-digit OTP" maxlength="6"
									pattern="[0-9]{6}" required />
							</div>
							<input class="button" type="submit" value="Verify OTP" />
						</form>
						<form action="${pageContext.request.contextPath}/login" method="post"
							style="margin-top: 10px; text-align: center;">
							<input type="hidden" name="csrfToken" value="${csrfToken}" />
							<input type="hidden" name="action" value="resendOtp" />
							<button type="submit" style="background: none; border: 0; color: #007bff; cursor: pointer;">
								Resend OTP
							</button>
						</form>
					</c:when>
					<c:otherwise>
						<form action="${pageContext.request.contextPath}/login" method="post">
							<input type="hidden" name="csrfToken" value="${csrfToken}" />
							<div class="input_field">
								<span><i aria-hidden="true" class="fa fa-envelope"></i></span> <input
									type="email" name="email" placeholder="Email Address" required />
							</div>
							<div class="input_field">
								<span><i aria-hidden="true" class="fa fa-lock"></i></span> <input
									type="password" name="password" placeholder="Password" required />
							</div>
							<div class="checkbox_field">
								<input type="checkbox" name="keepSignedIn"> <label>Keep
									me signed in</label>
							</div>
							<input class="button" type="submit" value="Login" />
						</form>
						<div style="margin: 14px 0; text-align: center; color: #777;">or</div>
						<a href="${pageContext.request.contextPath}/oauth2/google/start"
							style="display: block; width: 100%; box-sizing: border-box; padding: 10px 12px; border: 1px solid #dadce0; border-radius: 4px; color: #3c4043; text-align: center; text-decoration: none; font-weight: 600; background: #fff;">
							Login with Google
						</a>
					</c:otherwise>
				</c:choose>
			</div>
			<div style="text-align: center; margin-top: 10px;">
				<a href="${pageContext.request.contextPath}/forgot-password"
					style="color: #007bff; text-decoration: none;">Forgot Password?</a>
			</div>
		</div>
		<p class="credit">
			Don't have an account? <a
				href="${pageContext.request.contextPath}/guest/register">Signup</a>
		</p>
	</div>
</body>
</html>

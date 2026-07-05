<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>V-shopper Register</title>
</head>
<body>
	<div class="form_wrapper">
		<div class="form_container">
			<div class="title_container">
				<h2>Đăng kí tài khoản !</h2>
			</div>
			
			<!-- Phần hiển thị thông báo -->
        <c:if test="${not empty message}">
            <div class="message">
                <p style="color: red; font-weight: bold;">${message}</p>
            </div>
        </c:if>
        
			<div class="row clearfix">
				<div class="">
					<form method="post" action="${pageContext.request.contextPath}/guest/register">
						<input type="hidden" name="csrfToken" value="${csrfToken}" />
						<div class="input_field">
							<span><i aria-hidden="true" class="fa fa-envelope"></i></span> <input
								type="email" name="email" placeholder="Email" required />
						</div>
						<div class="input_field">
							<span><i aria-hidden="true" class="fa fa-lock"></i></span> <input
								type="password" name="password" placeholder="Password" required />
						</div>
						<div class="input_field">
							<span><i aria-hidden="true" class="fa fa-lock"></i></span> <input
								type="password" name="re-password" placeholder="Re-type Password"
								required />
						</div>
						<div class="row clearfix">
							<div class="col_half">
								<div class="input_field">
									<span><i aria-hidden="true" class="fa fa-user"></i></span> <input
										type="text" name="firstname" placeholder="First Name" />
								</div>
							</div>
							<div class="col_half">
								<div class="input_field">
									<span><i aria-hidden="true" class="fa fa-user"></i></span> <input
										type="text" name="lastname" placeholder="Last Name" required />
								</div>
							</div>
						</div>
						<input class="button" type="submit" value="Register" />
					</form>
				</div>
			</div>
		</div>
	</div>
	<p class="credit">
		Đã có tài khoản ? <a href="${pageContext.request.contextPath}/login" target="_blank">Đăng nhập</a>
	</p>
</body>

<script>
	$(function() {
		$("#slider-range").slider({
			range : true,
			min : 0,
			max : 200,
			values : [ 0, 0 ],
			slide : function(event, ui) {
				$("#amount").val("$" + ui.values[0] + " - $" + ui.values[1]);
				$("#amount_start").val(ui.values[0]);
				$("#amount_end").val(ui.values[1]);
			}
		});
		/* $("#amount").val(
				"$" + $("#slider-range").slider("values", 0) + " - $"
						+ $("#slider-range").slider("values", 1)); */
	});

	function readURL(input) {
		if (input.files && input.files[0]) {

			var reader = new FileReader();

			reader.onload = function(e) {
				$('.image-upload-wrap').hide();

				$('.file-upload-image').attr('src', e.target.result);
				$('.file-upload-content').show();

				$('.image-title').html(input.files[0].name);
			};

			reader.readAsDataURL(input.files[0]);

		} else {
			removeUpload();
		}
	}

	function removeUpload() {
		$('.file-upload-input').replaceWith($('.file-upload-input').clone());
		$('.file-upload-content').hide();
		$('.image-upload-wrap').show();
	}
	$('.image-upload-wrap').bind('dragover', function() {
		$('.image-upload-wrap').addClass('image-dropping');
	});
	$('.image-upload-wrap').bind('dragleave', function() {
		$('.image-upload-wrap').removeClass('image-dropping');
	});
</script>
</html>

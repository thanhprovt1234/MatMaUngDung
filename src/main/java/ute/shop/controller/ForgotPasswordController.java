package ute.shop.controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import ute.shop.entity.User;
import ute.shop.services.IUserService;
import ute.shop.services.implement.UserServiceImpl;
import ute.shop.utils.BCryptUtils;
import ute.shop.utils.OtpChallenge;
import ute.shop.utils.SmtpMailService;

@WebServlet(urlPatterns = "/forgot-password")
public class ForgotPasswordController extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private static final String FORGOT_OTP_SESSION = "forgotPasswordOtpChallenge";
	private static final String FORGOT_VERIFIED_USER_ID = "forgotPasswordVerifiedUserId";
	private static final long OTP_TTL_MILLIS = 5 * 60 * 1000;

	private final IUserService userService = new UserServiceImpl();
	private final SmtpMailService mailService = new SmtpMailService();

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		req.setAttribute("forgotStep", "email");
		req.getRequestDispatcher("/views/forgotpassword.jsp").forward(req, resp);
	}

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		req.setCharacterEncoding("UTF-8");
		resp.setCharacterEncoding("UTF-8");

		String action = valueOrDefault(req.getParameter("action"), "requestOtp");
		if ("verifyOtp".equals(action)) {
			verifyOtp(req, resp);
			return;
		}
		if ("resetPassword".equals(action)) {
			resetPassword(req, resp);
			return;
		}

		requestOtp(req, resp);
	}

	private void requestOtp(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		String email = valueOrDefault(req.getParameter("email"), "").trim();
		User user = userService.findByEmail(email);

		if (user == null) {
			req.setAttribute("forgotStep", "email");
			req.setAttribute("error", "Email không tồn tại.");
			req.getRequestDispatcher("/views/forgotpassword.jsp").forward(req, resp);
			return;
		}

		try {
			String otp = OtpChallenge.generateOtp();
			HttpSession session = req.getSession(true);
			session.removeAttribute(FORGOT_VERIFIED_USER_ID);
			session.setAttribute(FORGOT_OTP_SESSION,
					new OtpChallenge(user.get_id(), user.getEmail(), otp, OTP_TTL_MILLIS, false));
			mailService.sendOtp(user.getEmail(), "UTESHOP password reset verification code", otp);

			req.setAttribute("forgotStep", "otp");
			req.setAttribute("maskedEmail", maskEmail(user.getEmail()));
			req.setAttribute("message", "Mã OTP đã được gửi tới email của bạn.");
		} catch (RuntimeException e) {
			req.setAttribute("forgotStep", "email");
			req.setAttribute("error", e.getMessage());
		}

		req.getRequestDispatcher("/views/forgotpassword.jsp").forward(req, resp);
	}

	private void verifyOtp(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		HttpSession session = req.getSession(false);
		OtpChallenge challenge = session == null ? null : (OtpChallenge) session.getAttribute(FORGOT_OTP_SESSION);
		String otp = valueOrDefault(req.getParameter("otp"), "").trim();

		if (challenge == null) {
			req.setAttribute("forgotStep", "email");
			req.setAttribute("error", "Phiên OTP không tồn tại. Vui lòng gửi lại OTP.");
			req.getRequestDispatcher("/views/forgotpassword.jsp").forward(req, resp);
			return;
		}

		if (challenge.isExpired()) {
			session.removeAttribute(FORGOT_OTP_SESSION);
			req.setAttribute("forgotStep", "email");
			req.setAttribute("error", "Mã OTP đã hết hạn. Vui lòng gửi lại OTP.");
			req.getRequestDispatcher("/views/forgotpassword.jsp").forward(req, resp);
			return;
		}

		if (!challenge.matches(otp)) {
			req.setAttribute("forgotStep", "otp");
			req.setAttribute("maskedEmail", maskEmail(challenge.getEmail()));
			req.setAttribute("error", "Mã OTP không đúng.");
			req.getRequestDispatcher("/views/forgotpassword.jsp").forward(req, resp);
			return;
		}

		session.removeAttribute(FORGOT_OTP_SESSION);
		session.setAttribute(FORGOT_VERIFIED_USER_ID, challenge.getUserId());
		req.setAttribute("forgotStep", "reset");
		req.setAttribute("message", "OTP hợp lệ. Vui lòng đặt mật khẩu mới.");
		req.getRequestDispatcher("/views/forgotpassword.jsp").forward(req, resp);
	}

	private void resetPassword(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		HttpSession session = req.getSession(false);
		Integer userId = session == null ? null : (Integer) session.getAttribute(FORGOT_VERIFIED_USER_ID);

		if (userId == null) {
			req.setAttribute("forgotStep", "email");
			req.setAttribute("error", "Bạn cần xác thực OTP trước khi đổi mật khẩu.");
			req.getRequestDispatcher("/views/forgotpassword.jsp").forward(req, resp);
			return;
		}

		String password = valueOrDefault(req.getParameter("password"), "");
		String confirmPassword = valueOrDefault(req.getParameter("confirmPassword"), "");

		if (!password.equals(confirmPassword)) {
			req.setAttribute("forgotStep", "reset");
			req.setAttribute("error", "Mật khẩu nhập lại không khớp.");
			req.getRequestDispatcher("/views/forgotpassword.jsp").forward(req, resp);
			return;
		}

		if (!isStrongPassword(password)) {
			req.setAttribute("forgotStep", "reset");
			req.setAttribute("error", "Mật khẩu phải có ít nhất 8 ký tự, gồm chữ hoa, số và ký tự đặc biệt.");
			req.getRequestDispatcher("/views/forgotpassword.jsp").forward(req, resp);
			return;
		}

		User user = userService.findById(userId);
		if (user == null) {
			session.removeAttribute(FORGOT_VERIFIED_USER_ID);
			req.setAttribute("forgotStep", "email");
			req.setAttribute("error", "Không tìm thấy tài khoản.");
			req.getRequestDispatcher("/views/forgotpassword.jsp").forward(req, resp);
			return;
		}

		user.setPassword(BCryptUtils.hashPassword(password));
		userService.update(user);
		session.removeAttribute(FORGOT_VERIFIED_USER_ID);

		req.setAttribute("forgotStep", "email");
		req.setAttribute("message", "Đổi mật khẩu thành công. Bạn có thể đăng nhập bằng mật khẩu mới.");
		req.getRequestDispatcher("/views/forgotpassword.jsp").forward(req, resp);
	}

	private boolean isStrongPassword(String password) {
		return password != null
				&& password.matches("^(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$");
	}

	private String maskEmail(String email) {
		if (email == null || !email.contains("@")) {
			return "email của bạn";
		}
		String[] parts = email.split("@", 2);
		String name = parts[0];
		String maskedName = name.length() <= 2 ? name.charAt(0) + "***" : name.substring(0, 2) + "***";
		return maskedName + "@" + parts[1];
	}

	private String valueOrDefault(String value, String defaultValue) {
		return value == null ? defaultValue : value;
	}
}

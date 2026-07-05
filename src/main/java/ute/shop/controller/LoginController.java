package ute.shop.controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import ute.shop.entity.User;
import ute.shop.services.IUserService;
import ute.shop.services.implement.UserServiceImpl;
import ute.shop.utils.JwtUtils;
import ute.shop.utils.OtpChallenge;
import ute.shop.utils.SecurityAuditLogger;
import ute.shop.utils.SimpleRateLimiter;
import ute.shop.utils.SmtpMailService;

@SuppressWarnings("serial")
@WebServlet(urlPatterns = "/login")
public class LoginController extends HttpServlet {
	private static final String COOKIE_REMEMBER = "email";
	private static final String LOGIN_OTP_SESSION = "loginOtpChallenge";
	private static final long OTP_TTL_MILLIS = 5 * 60 * 1000;
	private static final long LOGIN_RATE_WINDOW_MILLIS = 15 * 60 * 1000;
	private static final long OTP_RATE_WINDOW_MILLIS = 5 * 60 * 1000;
	private static final int MAX_LOGIN_ATTEMPTS_PER_WINDOW = 10;
	private static final int MAX_OTP_ATTEMPTS_PER_WINDOW = 5;
	private static final int MAX_OTP_RESENDS_PER_WINDOW = 3;

	private final IUserService userService = new UserServiceImpl();
	private final SmtpMailService mailService = new SmtpMailService();

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		req.getRequestDispatcher("/views/login.jsp").forward(req, resp);
	}

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		resp.setContentType("text/html");
		resp.setCharacterEncoding("UTF-8");
		req.setCharacterEncoding("UTF-8");

		String action = valueOrDefault(req.getParameter("action"), "login");
		if ("verifyOtp".equals(action)) {
			verifyLoginOtp(req, resp);
			return;
		}
		if ("resendOtp".equals(action)) {
			resendLoginOtp(req, resp);
			return;
		}

		String email = valueOrDefault(req.getParameter("email"), "").trim();
		String password = valueOrDefault(req.getParameter("password"), "");
		boolean rememberMe = "on".equals(req.getParameter("remember"))
				|| "on".equals(req.getParameter("keepSignedIn"));

		if (email.isEmpty() || password.isEmpty()) {
			req.setAttribute("alert", "Tài khoản hoặc mật khẩu không được rỗng.");
			req.getRequestDispatcher("/views/login.jsp").forward(req, resp);
			return;
		}

		if (!SimpleRateLimiter.allow("login:" + clientKey(req) + ":" + email.toLowerCase(),
				MAX_LOGIN_ATTEMPTS_PER_WINDOW, LOGIN_RATE_WINDOW_MILLIS)) {
			SecurityAuditLogger.log("login_failed", req,
					SecurityAuditLogger.fields("email", email, "reason", "rate_limited"));
			req.setAttribute("alert", "Too many login attempts. Please wait before trying again.");
			req.getRequestDispatcher("/views/login.jsp").forward(req, resp);
			return;
		}

		try {
			User user = userService.login1(email, password);
			HttpSession session = req.getSession(true);
			sendAndStoreLoginOtp(session, user, rememberMe);

			req.setAttribute("mfaRequired", true);
			req.setAttribute("mfaEmail", maskEmail(user.getEmail()));
			req.setAttribute("message", "Mã OTP đã được gửi tới email của bạn.");
			req.getRequestDispatcher("/views/login.jsp").forward(req, resp);
		} catch (RuntimeException e) {
			SecurityAuditLogger.log("login_failed", req,
					SecurityAuditLogger.fields("email", email, "reason", e.getMessage()));
			req.setAttribute("alert", e.getMessage());
			req.getRequestDispatcher("/views/login.jsp").forward(req, resp);
		}
	}

	private void verifyLoginOtp(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		HttpSession session = req.getSession(false);
		OtpChallenge challenge = session == null ? null : (OtpChallenge) session.getAttribute(LOGIN_OTP_SESSION);
		String otp = valueOrDefault(req.getParameter("otp"), "").trim();

		if (challenge == null) {
			SecurityAuditLogger.log("otp_failed", req, SecurityAuditLogger.fields("reason", "missing_challenge"));
			req.setAttribute("alert", "Phiên xác thực OTP không tồn tại. Vui lòng đăng nhập lại.");
			req.getRequestDispatcher("/views/login.jsp").forward(req, resp);
			return;
		}

		if (!SimpleRateLimiter.allow("otp-verify:" + clientKey(req) + ":" + challenge.getEmail().toLowerCase(),
				MAX_OTP_ATTEMPTS_PER_WINDOW, OTP_RATE_WINDOW_MILLIS)) {
			SecurityAuditLogger.log("otp_failed", req,
					SecurityAuditLogger.fields("email", challenge.getEmail(), "reason", "rate_limited"));
			req.setAttribute("mfaRequired", true);
			req.setAttribute("mfaEmail", maskEmail(challenge.getEmail()));
			req.setAttribute("alert", "Too many OTP attempts. Please request a new code later.");
			req.getRequestDispatcher("/views/login.jsp").forward(req, resp);
			return;
		}

		if (challenge.isExpired()) {
			session.removeAttribute(LOGIN_OTP_SESSION);
			SecurityAuditLogger.log("otp_failed", req,
					SecurityAuditLogger.fields("email", challenge.getEmail(), "reason", "expired"));
			req.setAttribute("alert", "Mã OTP đã hết hạn. Vui lòng đăng nhập lại.");
			req.getRequestDispatcher("/views/login.jsp").forward(req, resp);
			return;
		}

		if (!challenge.matches(otp)) {
			SecurityAuditLogger.log("otp_failed", req,
					SecurityAuditLogger.fields("email", challenge.getEmail(), "reason", "invalid_code"));
			req.setAttribute("mfaRequired", true);
			req.setAttribute("mfaEmail", maskEmail(challenge.getEmail()));
			req.setAttribute("alert", "Mã OTP không đúng.");
			req.getRequestDispatcher("/views/login.jsp").forward(req, resp);
			return;
		}

		User user = userService.findById(challenge.getUserId());
		if (user == null) {
			session.removeAttribute(LOGIN_OTP_SESSION);
			SecurityAuditLogger.log("otp_failed", req,
					SecurityAuditLogger.fields("userId", challenge.getUserId(), "reason", "user_not_found"));
			req.setAttribute("alert", "Không tìm thấy tài khoản. Vui lòng đăng nhập lại.");
			req.getRequestDispatcher("/views/login.jsp").forward(req, resp);
			return;
		}

		session.removeAttribute(LOGIN_OTP_SESSION);
		session.setAttribute("account", user);
		session.setAttribute("userId", user.get_id());
		JwtUtils.addAccessTokenCookie(req, resp, JwtUtils.createAccessToken(user));

		if (challenge.isRememberMe()) {
			saveRememberMe(resp, user.getEmail());
		}
		SecurityAuditLogger.log("login_success", req,
				SecurityAuditLogger.fields("actor", SecurityAuditLogger.actor(user), "method", "password_otp"));

		redirectByRole(req, resp, user);
	}

	private void resendLoginOtp(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		HttpSession session = req.getSession(false);
		OtpChallenge challenge = session == null ? null : (OtpChallenge) session.getAttribute(LOGIN_OTP_SESSION);

		if (challenge == null) {
			req.setAttribute("alert", "Phiên xác thực OTP không tồn tại. Vui lòng đăng nhập lại.");
			req.getRequestDispatcher("/views/login.jsp").forward(req, resp);
			return;
		}

		User user = userService.findById(challenge.getUserId());
		if (user == null) {
			session.removeAttribute(LOGIN_OTP_SESSION);
			req.setAttribute("alert", "Không tìm thấy tài khoản. Vui lòng đăng nhập lại.");
			req.getRequestDispatcher("/views/login.jsp").forward(req, resp);
			return;
		}

		if (!SimpleRateLimiter.allow("otp-resend:" + clientKey(req) + ":" + user.getEmail().toLowerCase(),
				MAX_OTP_RESENDS_PER_WINDOW, OTP_RATE_WINDOW_MILLIS)) {
			req.setAttribute("mfaRequired", true);
			req.setAttribute("mfaEmail", maskEmail(user.getEmail()));
			req.setAttribute("alert", "Too many OTP resend requests. Please wait before trying again.");
			req.getRequestDispatcher("/views/login.jsp").forward(req, resp);
			return;
		}

		try {
			sendAndStoreLoginOtp(session, user, challenge.isRememberMe());
			req.setAttribute("message", "Mã OTP mới đã được gửi.");
		} catch (RuntimeException e) {
			req.setAttribute("alert", e.getMessage());
		}

		req.setAttribute("mfaRequired", true);
		req.setAttribute("mfaEmail", maskEmail(user.getEmail()));
		req.getRequestDispatcher("/views/login.jsp").forward(req, resp);
	}

	private void sendAndStoreLoginOtp(HttpSession session, User user, boolean rememberMe) {
		String otp = OtpChallenge.generateOtp();
		session.setAttribute(LOGIN_OTP_SESSION,
				new OtpChallenge(user.get_id(), user.getEmail(), otp, OTP_TTL_MILLIS, rememberMe));
		mailService.sendOtp(user.getEmail(), "UTESHOP login verification code", otp);
	}

	private void redirectByRole(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
		if ("ADMIN".equalsIgnoreCase(user.getRole().toString())) {
			resp.sendRedirect(req.getContextPath() + "/admin/home");
		} else {
			resp.sendRedirect(req.getContextPath() + "/home");
		}
	}

	private void saveRememberMe(HttpServletResponse response, String email) {
		Cookie cookie = new Cookie(COOKIE_REMEMBER, email);
		cookie.setMaxAge(30 * 60);
		cookie.setPath("/");
		response.addCookie(cookie);
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

	private String clientKey(HttpServletRequest request) {
		String forwardedFor = request.getHeader("X-Forwarded-For");
		if (forwardedFor != null && !forwardedFor.isBlank()) {
			return forwardedFor.split(",", 2)[0].trim();
		}
		return request.getRemoteAddr();
	}
}

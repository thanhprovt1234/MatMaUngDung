package ute.shop.utils;

import java.io.UnsupportedEncodingException;
import java.util.Properties;

import javax.mail.Authenticator;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

public class SmtpMailService {
	private static final String DEFAULT_HOST = "smtp.gmail.com";
	private static final String DEFAULT_PORT = "587";
	private static final String DEFAULT_FROM_NAME = "UTESHOP Security";

	public void sendOtp(String toEmail, String subject, String otp) {
		String body = "Your UTESHOP verification code is: " + otp + "\n\n"
				+ "This code expires in 5 minutes. If you did not request this code, please ignore this email.";
		sendText(toEmail, subject, body);
	}

	public void sendText(String toEmail, String subject, String body) {
		MailSettings settings = MailSettings.load();

		Properties props = new Properties();
		props.put("mail.smtp.host", settings.host);
		props.put("mail.smtp.port", settings.port);
		props.put("mail.smtp.auth", "true");
		props.put("mail.smtp.starttls.enable", settings.startTls);
		props.put("mail.smtp.ssl.trust", settings.host);

		Session session = Session.getInstance(props, new Authenticator() {
			@Override
			protected PasswordAuthentication getPasswordAuthentication() {
				return new PasswordAuthentication(settings.username, settings.password);
			}
		});

		try {
			Message message = new MimeMessage(session);
			message.setHeader("Content-Type", "text/plain; charset=UTF-8");
			try {
				message.setFrom(new InternetAddress(settings.fromEmail, settings.fromName, "UTF-8"));
			} catch (UnsupportedEncodingException e) {
				message.setFrom(new InternetAddress(settings.fromEmail));
			}
			message.setRecipient(Message.RecipientType.TO, new InternetAddress(toEmail));
			message.setSubject(subject);
			message.setText(body);
			Transport.send(message);
		} catch (MessagingException e) {
			throw new RuntimeException("Không thể gửi email OTP. Kiểm tra cấu hình SMTP.", e);
		}
	}

	private static class MailSettings {
		private final String host;
		private final String port;
		private final String username;
		private final String password;
		private final String fromEmail;
		private final String fromName;
		private final String startTls;

		private MailSettings(String host, String port, String username, String password, String fromEmail,
				String fromName, String startTls) {
			this.host = host;
			this.port = port;
			this.username = username;
			this.password = password;
			this.fromEmail = fromEmail;
			this.fromName = fromName;
			this.startTls = startTls;
		}

		private static MailSettings load() {
			String host = getSetting("smtp.host", "SMTP_HOST", DEFAULT_HOST);
			String port = getSetting("smtp.port", "SMTP_PORT", DEFAULT_PORT);
			String username = getSetting("smtp.username", "SMTP_USERNAME", null);
			String password = getSetting("smtp.password", "SMTP_PASSWORD", null);
			String fromEmail = getSetting("smtp.from", "SMTP_FROM", username);
			String fromName = getSetting("smtp.fromName", "SMTP_FROM_NAME", DEFAULT_FROM_NAME);
			String startTls = getSetting("smtp.starttls", "SMTP_STARTTLS", "true");

			if (isBlank(username) || isBlank(password) || isBlank(fromEmail)) {
				throw new IllegalStateException(
						"Chưa cấu hình SMTP. Hãy đặt SMTP_USERNAME, SMTP_PASSWORD và SMTP_FROM hoặc truyền -Dsmtp.* khi chạy Maven.");
			}

			return new MailSettings(host, port, username, password, fromEmail, fromName, startTls);
		}

		private static String getSetting(String propertyName, String envName, String defaultValue) {
			String value = System.getProperty(propertyName);
			if (!isBlank(value)) {
				return value.trim();
			}
			value = System.getenv(envName);
			if (!isBlank(value)) {
				return value.trim();
			}
			return defaultValue;
		}

		private static boolean isBlank(String value) {
			return value == null || value.trim().isEmpty();
		}
	}
}

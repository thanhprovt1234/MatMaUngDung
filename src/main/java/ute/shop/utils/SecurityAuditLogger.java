package ute.shop.utils;

import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.StringJoiner;
import java.util.logging.FileHandler;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.logging.SimpleFormatter;

import jakarta.servlet.http.HttpServletRequest;
import ute.shop.entity.User;

public final class SecurityAuditLogger {
	private static final Logger LOGGER = Logger.getLogger("uteshop.security.audit");
	private static final String LOG_PATH_PROPERTY = "security.audit.log.path";
	private static final String LOG_PATH_ENV = "SECURITY_AUDIT_LOG_PATH";
	private static final String DEFAULT_LOG_PATH = "logs/security-audit.log";

	static {
		configureFileHandler();
	}

	private SecurityAuditLogger() {
	}

	public static void log(String event, Map<String, ?> fields) {
		Map<String, Object> safeFields = new LinkedHashMap<>();
		safeFields.put("event", event);
		if (fields != null) {
			safeFields.putAll(fields);
		}
		LOGGER.log(Level.INFO, format(safeFields));
	}

	public static void log(String event, HttpServletRequest request, Map<String, ?> fields) {
		Map<String, Object> safeFields = new LinkedHashMap<>();
		safeFields.put("ip", clientIp(request));
		safeFields.put("method", request == null ? null : request.getMethod());
		safeFields.put("path", request == null ? null : request.getRequestURI());
		if (fields != null) {
			safeFields.putAll(fields);
		}
		log(event, safeFields);
	}

	public static Map<String, Object> fields(Object... values) {
		Map<String, Object> fields = new LinkedHashMap<>();
		if (values == null) {
			return fields;
		}
		for (int i = 0; i + 1 < values.length; i += 2) {
			fields.put(String.valueOf(values[i]), values[i + 1]);
		}
		return fields;
	}

	public static String actor(User user) {
		if (user == null) {
			return "anonymous";
		}
		return user.get_id() + ":" + nullToDash(user.getEmail()) + ":" + user.getRole();
	}

	private static String clientIp(HttpServletRequest request) {
		if (request == null) {
			return "-";
		}
		String forwardedFor = request.getHeader("X-Forwarded-For");
		if (forwardedFor != null && !forwardedFor.isBlank()) {
			return forwardedFor.split(",", 2)[0].trim();
		}
		return request.getRemoteAddr();
	}

	private static String format(Map<String, ?> fields) {
		StringJoiner joiner = new StringJoiner(" ");
		for (Map.Entry<String, ?> entry : fields.entrySet()) {
			joiner.add(entry.getKey() + "=" + sanitize(entry.getValue()));
		}
		return joiner.toString();
	}

	private static String sanitize(Object value) {
		if (value == null) {
			return "-";
		}
		return String.valueOf(value).replace('\n', '_').replace('\r', '_').replace(' ', '_');
	}

	private static String nullToDash(String value) {
		return value == null || value.isBlank() ? "-" : value;
	}

	private static void configureFileHandler() {
		try {
			Path logPath = Paths.get(setting(LOG_PATH_PROPERTY, LOG_PATH_ENV, DEFAULT_LOG_PATH));
			Path parent = logPath.toAbsolutePath().getParent();
			if (parent != null) {
				Files.createDirectories(parent);
			}

			FileHandler fileHandler = new FileHandler(logPath.toString(), true);
			fileHandler.setEncoding("UTF-8");
			fileHandler.setFormatter(new SimpleFormatter());
			fileHandler.setLevel(Level.INFO);

			LOGGER.setLevel(Level.INFO);
			LOGGER.addHandler(fileHandler);
		} catch (IOException e) {
			throw new UncheckedIOException("Unable to configure security audit log file.", e);
		}
	}

	private static String setting(String propertyName, String envName, String defaultValue) {
		String value = System.getProperty(propertyName);
		if (value != null && !value.trim().isEmpty()) {
			return value.trim();
		}
		value = System.getenv(envName);
		if (value != null && !value.trim().isEmpty()) {
			return value.trim();
		}
		return defaultValue;
	}
}

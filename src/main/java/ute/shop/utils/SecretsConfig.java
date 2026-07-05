package ute.shop.utils;

import java.io.IOException;
import java.io.InputStream;
import java.io.UncheckedIOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Properties;

public final class SecretsConfig {
	private static final String SECRETS_FILE_PROPERTY = "uteshop.secrets.file";
	private static final String SECRETS_FILE_ENV = "UTESHOP_SECRETS_FILE";
	private static final String DEFAULT_SECRETS_FILE = "config/secrets.properties";
	private static final String SECURE_SECRETS_FILE = "C:/secure/uteshop/secrets.properties";
	private static final Properties FILE_SECRETS = loadFileSecrets();

	private SecretsConfig() {
	}

	public static String get(String propertyName, String envName, String defaultValue) {
		String value = System.getProperty(propertyName);
		if (!isBlank(value)) {
			return value.trim();
		}

		value = fileSecret(envName);
		if (!isBlank(value)) {
			return value.trim();
		}

		value = fileSecret(propertyName);
		if (!isBlank(value)) {
			return value.trim();
		}

		value = System.getenv(envName);
		if (!isBlank(value)) {
			return value.trim();
		}

		return defaultValue;
	}

	public static String require(String propertyName, String envName) {
		String value = get(propertyName, envName, null);
		if (isBlank(value)) {
			throw new IllegalStateException(envName + " is not configured.");
		}
		return value.trim();
	}

	public static boolean isBlank(String value) {
		if (value == null || value.trim().isEmpty()) {
			return true;
		}
		String trimmed = value.trim();
		return "<no value>".equalsIgnoreCase(trimmed) || "null".equalsIgnoreCase(trimmed);
	}

	private static String fileSecret(String key) {
		if (key == null || key.isBlank()) {
			return null;
		}
		return FILE_SECRETS.getProperty(key);
	}

	private static Properties loadFileSecrets() {
		Properties properties = new Properties();
		Path path = secretsFilePath();
		if (!Files.exists(path)) {
			return properties;
		}
		try (InputStream input = Files.newInputStream(path)) {
			properties.load(input);
			return properties;
		} catch (IOException e) {
			throw new UncheckedIOException("Unable to read secrets file: " + path.toAbsolutePath(), e);
		}
	}

	private static Path secretsFilePath() {
		String value = System.getProperty(SECRETS_FILE_PROPERTY);
		if (!isBlank(value)) {
			return Paths.get(value.trim());
		}
		value = System.getenv(SECRETS_FILE_ENV);
		if (!isBlank(value)) {
			return Paths.get(value.trim());
		}

		Path defaultPath = Paths.get(DEFAULT_SECRETS_FILE);
		if (Files.exists(defaultPath)) {
			return defaultPath;
		}

		Path securePath = Paths.get(SECURE_SECRETS_FILE);
		if (Files.exists(securePath)) {
			return securePath;
		}
		return defaultPath;
	}
}

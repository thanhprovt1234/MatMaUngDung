package ute.shop.utils;

import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.security.SecureRandom;
import java.util.Base64;

import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;

public final class FieldEncryptionUtils {
	public static final String PREFIX = "ENC:v1:";

	private static final String KEY_PROPERTY = "field.encryption.key";
	private static final String KEY_ENV = "FIELD_ENCRYPTION_KEY";
	private static final int IV_LENGTH_BYTES = 12;
	private static final int TAG_LENGTH_BITS = 128;
	private static final SecureRandom SECURE_RANDOM = new SecureRandom();
	private static final Base64.Encoder ENCODER = Base64.getEncoder();
	private static final Base64.Decoder DECODER = Base64.getDecoder();

	private FieldEncryptionUtils() {
	}

	public static String encrypt(String plaintext) {
		if (plaintext == null || plaintext.isBlank() || isEncrypted(plaintext)) {
			return plaintext;
		}

		try {
			byte[] iv = new byte[IV_LENGTH_BYTES];
			SECURE_RANDOM.nextBytes(iv);

			Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
			cipher.init(Cipher.ENCRYPT_MODE, encryptionKey(), new GCMParameterSpec(TAG_LENGTH_BITS, iv));
			byte[] ciphertext = cipher.doFinal(plaintext.getBytes(StandardCharsets.UTF_8));

			return PREFIX + ENCODER.encodeToString(iv) + ":" + ENCODER.encodeToString(ciphertext);
		} catch (GeneralSecurityException e) {
			throw new IllegalStateException("Unable to encrypt field value.", e);
		}
	}

	public static String decrypt(String storedValue) {
		if (storedValue == null || storedValue.isBlank() || !isEncrypted(storedValue)) {
			return storedValue;
		}

		String[] parts = storedValue.split(":", 4);
		if (parts.length != 4) {
			throw new IllegalStateException("Invalid encrypted field format.");
		}

		try {
			byte[] iv = DECODER.decode(parts[2]);
			byte[] ciphertext = DECODER.decode(parts[3]);

			Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
			cipher.init(Cipher.DECRYPT_MODE, encryptionKey(), new GCMParameterSpec(TAG_LENGTH_BITS, iv));
			byte[] plaintext = cipher.doFinal(ciphertext);
			return new String(plaintext, StandardCharsets.UTF_8);
		} catch (GeneralSecurityException | IllegalArgumentException e) {
			throw new IllegalStateException("Unable to decrypt field value.", e);
		}
	}

	public static boolean isEncrypted(String value) {
		return value != null && value.startsWith(PREFIX);
	}

	private static SecretKey encryptionKey() {
		String encodedKey = setting(KEY_PROPERTY, KEY_ENV);
		if (encodedKey == null || encodedKey.isBlank()) {
			throw new IllegalStateException(KEY_ENV + " is not configured.");
		}

		byte[] keyBytes;
		try {
			keyBytes = DECODER.decode(encodedKey);
		} catch (IllegalArgumentException e) {
			throw new IllegalStateException(KEY_ENV + " must be a Base64-encoded AES key.", e);
		}

		if (keyBytes.length != 16 && keyBytes.length != 24 && keyBytes.length != 32) {
			throw new IllegalStateException(KEY_ENV + " must decode to 16, 24, or 32 bytes.");
		}
		return new SecretKeySpec(keyBytes, "AES");
	}

	private static String setting(String propertyName, String envName) {
		String value = System.getProperty(propertyName);
		if (value != null && !value.trim().isEmpty()) {
			return value.trim();
		}
		value = System.getenv(envName);
		if (value != null && !value.trim().isEmpty()) {
			return value.trim();
		}
		return null;
	}
}

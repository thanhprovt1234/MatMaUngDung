package ute.shop.utils;

import java.io.Serializable;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.Instant;
import java.util.HexFormat;

public class OtpChallenge implements Serializable {
	private static final long serialVersionUID = 1L;
	private static final SecureRandom RANDOM = new SecureRandom();

	private final int userId;
	private final String email;
	private final String otpHash;
	private final long expiresAtMillis;
	private final boolean rememberMe;

	public OtpChallenge(int userId, String email, String otp, long ttlMillis, boolean rememberMe) {
		this.userId = userId;
		this.email = email;
		this.otpHash = hashOtp(otp);
		this.expiresAtMillis = Instant.now().toEpochMilli() + ttlMillis;
		this.rememberMe = rememberMe;
	}

	public int getUserId() {
		return userId;
	}

	public String getEmail() {
		return email;
	}

	public boolean isRememberMe() {
		return rememberMe;
	}

	public boolean isExpired() {
		return Instant.now().toEpochMilli() > expiresAtMillis;
	}

	public boolean matches(String otp) {
		return otp != null && otpHash.equals(hashOtp(otp.trim()));
	}

	public static String generateOtp() {
		return String.format("%06d", RANDOM.nextInt(1_000_000));
	}

	private static String hashOtp(String otp) {
		try {
			MessageDigest digest = MessageDigest.getInstance("SHA-256");
			byte[] hash = digest.digest(otp.getBytes(StandardCharsets.UTF_8));
			return HexFormat.of().formatHex(hash);
		} catch (NoSuchAlgorithmException e) {
			throw new IllegalStateException("SHA-256 is not available", e);
		}
	}
}

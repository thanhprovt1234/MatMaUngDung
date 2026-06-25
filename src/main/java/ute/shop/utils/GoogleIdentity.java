package ute.shop.utils;

public record GoogleIdentity(
		String subject,
		String email,
		boolean emailVerified,
		String fullName,
		String givenName,
		String familyName,
		String pictureUrl) {
}

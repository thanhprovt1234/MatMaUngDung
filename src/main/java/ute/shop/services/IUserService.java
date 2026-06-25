package ute.shop.services;

import java.util.List;

import ute.shop.entity.User;

public interface IUserService {
	// Login user with email and password
	User login(String email, String password);

	User login1(String email, String rawPassword);

	User findOrCreateGoogleUser(String email, String givenName, String familyName, String fullName, String pictureUrl,
			String googleSubject);

	// Update existing user
	void update(User user);

	// Tăng số lần đăng nhập sai
	void incrementFailedAttempts(String email);

	// Reset số lần đăng nhập sai khi login thành công
	void resetFailedAttempts(String email);

	// Delete a user by their ID
	void delete(int userId) throws Exception;

	// Get all users
	List<User> findAll();

	// Find a user by their email
	User findByEmail(String email);

	// Find a user by their ID
	User findById(int userId);

	// find top user
	List<Object[]> findTopUser();
}

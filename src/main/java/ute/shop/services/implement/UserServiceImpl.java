package ute.shop.services.implement;

import java.util.List;
import java.util.UUID;

import ute.shop.utils.BCryptUtils;
import ute.shop.dao.IUserDao;
import ute.shop.dao.implement.UserDaoImpl;
import ute.shop.entity.User;
import ute.shop.services.IUserService;

public class UserServiceImpl implements IUserService {

	IUserDao userDao = new UserDaoImpl();

	@Override
	public User login(String email, String password) {
		User user = userDao.findByEmail(email);

		// Kiểm tra user tồn tại
		if (user == null) {
			throw new RuntimeException("Email does not exist");
		}

		// Kiểm tra tài khoản bị khóa
		if (user.getIsLocked()) {
			// Kiểm tra đã hết thời gian khóa chưa (30 phút)
			if (user.getLockoutTime() != null) {
				long lockDuration = System.currentTimeMillis() - user.getLockoutTime().getTime();
				if (lockDuration < 30 * 60 * 1000) { // 30 phút
					throw new RuntimeException("Tài khoản bị khóa. Vui lòng thử lại sau 30 phút");
				} else {
					// Hết thời gian khóa -> mở khóa
					user.setIsLocked(false);
					user.setFailedLoginAttempts(0);
					user.setLockoutTime(null);
					userDao.update(user);
				}
			}
		}

		// Kiểm tra mật khẩu
		if (!user.getPassword().equals(password)) {
			incrementFailedAttempts(email);
			int remaining = 5 - user.getFailedLoginAttempts() - 1;
			if (remaining <= 0) {
				throw new RuntimeException("Tài khoản đã bị khóa do nhập sai quá 5 lần");
			}
			throw new RuntimeException("Mật khẩu sai. Còn " + remaining + " lần thử");
		}

		// Login thành công -> reset counter
		resetFailedAttempts(email);
		return user;
	}

	@Override
	public void update(User user) {
		// Update the user information in the database
		userDao.update(user);

	}

	@Override
	public void delete(int userId) throws Exception {
		// Delete the user by ID
		userDao.delete(userId);

	}

	@Override
	public List<User> findAll() {
		// Return all users from the database
		return userDao.findAll();
	}

	@Override
	public User findByEmail(String email) {
		// Find and return a user by email
		return userDao.findByEmail(email);
	}

	@Override
	public User findById(int userId) {
		// Find and return a user by ID
		return userDao.findById(userId);
	}

	@Override
	public List<Object[]> findTopUser() {

		return userDao.findTopUser();
	}

	@Override
	public void incrementFailedAttempts(String email) {
		User user = userDao.findByEmail(email);
		if (user != null) {
			int attempts = user.getFailedLoginAttempts() + 1;
			user.setFailedLoginAttempts(attempts);

			// Nếu đã sai 5 lần -> khóa tài khoản
			if (attempts >= 5) {
				user.setIsLocked(true);
				user.setLockoutTime(new java.util.Date());
			}

			userDao.update(user);
		}
	}

	@Override
	public void resetFailedAttempts(String email) {
		User user = userDao.findByEmail(email);
		if (user != null) {
			user.setFailedLoginAttempts(0);
			user.setIsLocked(false);
			user.setLockoutTime(null);
			userDao.update(user);
		}
	}
	@Override
	public User login1(String email, String rawPassword) {
		try {
			User user = userDao.findByEmail(email);
			if (user == null) {
				throw new RuntimeException("Email does not exist");
			}
			enforceLockout(user);

			String storedPassword = user.getPassword();
			boolean isBcryptPassword = storedPassword != null && storedPassword.startsWith("$2");
			boolean passwordMatched = isBcryptPassword
					? BCryptUtils.checkPassword(rawPassword, storedPassword)
					: storedPassword != null && storedPassword.equals(rawPassword);

			if (!passwordMatched) {
				registerFailedPassword(user);
			}

			// Tu dong nang cap mat khau cu dang plain text sang BCrypt sau lan dang nhap hop le.
			if (!isBcryptPassword) {
				user.setPassword(BCryptUtils.hashPassword(rawPassword));
				userDao.update(user);
			}
			resetFailedAttempts(email);

			return user; // Successful login
		} catch (RuntimeException e) {
			throw e;
		} catch (Exception e) {
			throw new RuntimeException("Error during login", e);
		}
	}

	@Override
	public User findOrCreateGoogleUser(String email, String givenName, String familyName, String fullName,
			String pictureUrl, String googleSubject) {
		if (email == null || email.isBlank()) {
			throw new RuntimeException("Google account did not provide an email address.");
		}

		User existing = userDao.findByEmail(email);
		if (existing != null) {
			if (Boolean.FALSE.equals(existing.getIsEmailActive())) {
				existing.setIsEmailActive(true);
			}
			if ((existing.getAvatar() == null || existing.getAvatar().isBlank()) && pictureUrl != null
					&& !pictureUrl.isBlank()) {
				existing.setAvatar(pictureUrl);
			}
			userDao.update(existing);
			return userDao.findByEmail(email);
		}

		User user = new User();
		user.setEmail(email);
		user.setFirstname(trimToLength(firstUsable(givenName, firstPartOfName(fullName), "Google"), 32));
		user.setLastname(trimToLength(firstUsable(familyName, lastPartOfName(fullName), "User"), 32));
		user.setPassword(BCryptUtils.hashPassword("GOOGLE_OIDC:" + googleSubject + ":" + UUID.randomUUID()));
		user.setRole(User.Role.USER);
		user.setIsEmailActive(true);
		user.setIsPhoneActive(false);
		user.setIsLocked(false);
		user.setFailedLoginAttempts(0);
		user.setAvatar(pictureUrl);
		userDao.insert(user);
		return userDao.findByEmail(email);
	}

	private void enforceLockout(User user) {
		if (Boolean.TRUE.equals(user.getIsLocked())) {
			if (user.getLockoutTime() == null) {
				throw new RuntimeException("Account is locked. Please try again later.");
			}

			long lockDuration = System.currentTimeMillis() - user.getLockoutTime().getTime();
			if (lockDuration < 30 * 60 * 1000) {
				throw new RuntimeException("Account is locked. Please try again after 30 minutes.");
			}

			user.setIsLocked(false);
			user.setFailedLoginAttempts(0);
			user.setLockoutTime(null);
			userDao.update(user);
		}
	}

	private void registerFailedPassword(User user) {
		int attempts = user.getFailedLoginAttempts() + 1;
		user.setFailedLoginAttempts(attempts);
		if (attempts >= 5) {
			user.setIsLocked(true);
			user.setLockoutTime(new java.util.Date());
			userDao.update(user);
			throw new RuntimeException("Account has been locked after 5 failed login attempts.");
		}

		userDao.update(user);
		int remaining = 5 - attempts;
		throw new RuntimeException("Invalid password. Remaining attempts: " + remaining);
	}

	private String firstUsable(String... values) {
		for (String value : values) {
			if (value != null && !value.isBlank()) {
				return value.trim();
			}
		}
		return "User";
	}

	private String trimToLength(String value, int maxLength) {
		if (value == null || value.isBlank()) {
			return "User";
		}
		String trimmed = value.trim();
		return trimmed.length() <= maxLength ? trimmed : trimmed.substring(0, maxLength);
	}

	private String firstPartOfName(String fullName) {
		if (fullName == null || fullName.isBlank()) {
			return null;
		}
		return fullName.trim().split("\\s+", 2)[0];
	}

	private String lastPartOfName(String fullName) {
		if (fullName == null || fullName.isBlank()) {
			return null;
		}
		String[] parts = fullName.trim().split("\\s+");
		return parts.length < 2 ? null : parts[parts.length - 1];
	}
}

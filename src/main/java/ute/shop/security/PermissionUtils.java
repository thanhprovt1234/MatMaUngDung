package ute.shop.security;

import java.util.EnumSet;
import java.util.Set;

import ute.shop.entity.User;
import ute.shop.entity.User.Role;

public final class PermissionUtils {
	private static final Set<Permission> USER_PERMISSIONS = EnumSet.of(
			Permission.CATALOG_READ,
			Permission.ORDER_WRITE,
			Permission.PAYMENT_AUTHORIZE);
	private static final Set<Permission> ADMIN_PERMISSIONS = EnumSet.allOf(Permission.class);

	private PermissionUtils() {
	}

	public static boolean hasPermission(User user, Permission permission) {
		if (permission == null) {
			return true;
		}
		if (user == null || user.getRole() == null) {
			return false;
		}
		return permissionsFor(user.getRole()).contains(permission);
	}

	public static Set<Permission> permissionsFor(Role role) {
		if (role == Role.ADMIN) {
			return ADMIN_PERMISSIONS;
		}
		return USER_PERMISSIONS;
	}
}

package ute.shop.services;

import ute.shop.entity.Cart;
import ute.shop.entity.User;

public interface ICartService {
	Cart findCartByUserId(int userId);

	Cart getCartByUser(User user);

	Cart createCart(User user);

	Cart addOrUpdateCartItem(int userId, int productId, int quantity);

	Cart setCartItemQuantity(int userId, int productId, int quantity);

	void removeCartItem(int userId, int productId);

	void clearCart(int userId);
}

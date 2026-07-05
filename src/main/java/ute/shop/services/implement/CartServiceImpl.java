package ute.shop.services.implement;

import ute.shop.dao.ICartDao;
import ute.shop.dao.implement.CartDaoImpl;
import ute.shop.entity.Cart;
import ute.shop.entity.CartItem;
import ute.shop.entity.Product;
import ute.shop.entity.User;
import ute.shop.services.ICartService;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class CartServiceImpl implements ICartService {

	private final ICartDao cartDao = new CartDaoImpl();

	@Override
	public Cart findCartByUserId(int userId) {
		return cartDao.findByUserId(userId);
	}

	@Override
	public Cart getCartByUser(User user) {
		Cart cart = cartDao.getCartByUser(user);
		if (cart == null) {
			throw new IllegalArgumentException("Cart not found for this user.");
		}
		return cart;
	}

	@Override
	public Cart createCart(User user) {
		if (user == null) {
			throw new IllegalArgumentException("Invalid user.");
		}

		Cart cart = new Cart();
		cart.setUser(user);
		cart.setCreatedAt(new Date());
		cart.setUpdatedAt(new Date());
		cart.setCartItems(List.of());
		return cartDao.save(cart);
	}

	@Override
	public Cart addOrUpdateCartItem(int userId, int productId, int quantity) {
		if (quantity <= 0) {
			throw new IllegalArgumentException("Quantity must be greater than 0.");
		}

		Cart cart = findOrCreateCart(userId);
		CartItem cartItem = cartDao.findCartItemByCartAndProduct(cart.get_id(), productId);
		if (cartItem != null) {
			cartItem.setCount(cartItem.getCount() + quantity);
		} else {
			cartItem = new CartItem();
			cartItem.setCart(cart);
			cartItem.setProduct(new Product(productId));
			cartItem.setCount(quantity);
		}

		CartItem savedItem = cartDao.addOrUpdateCartItem(cartItem);
		if (savedItem == null) {
			throw new IllegalStateException("Unable to add product to cart.");
		}

		return cartDao.findByUserId(userId);
	}

	@Override
	public Cart setCartItemQuantity(int userId, int productId, int quantity) {
		if (quantity <= 0) {
			throw new IllegalArgumentException("Quantity must be greater than 0.");
		}

		Cart cart = cartDao.findByUserId(userId);
		if (cart == null) {
			throw new IllegalArgumentException("Cart not found for user ID: " + userId);
		}

		CartItem cartItem = cartDao.findCartItemByCartAndProduct(cart.get_id(), productId);
		if (cartItem == null) {
			throw new IllegalArgumentException("Product is not in the cart.");
		}

		cartItem.setCount(quantity);
		CartItem savedItem = cartDao.addOrUpdateCartItem(cartItem);
		if (savedItem == null) {
			throw new IllegalStateException("Unable to update cart item quantity.");
		}

		return cartDao.findByUserId(userId);
	}

	@Override
	public void removeCartItem(int userId, int productId) {
		Cart cart = cartDao.findByUserId(userId);
		if (cart == null) {
			throw new IllegalArgumentException("Cart not found for user ID: " + userId);
		}

		CartItem itemToRemove = cartDao.findCartItemByCartAndProduct(cart.get_id(), productId);
		if (itemToRemove == null) {
			throw new IllegalArgumentException("Product is not in the cart.");
		}

		if (!cartDao.removeCartItem(itemToRemove)) {
			throw new IllegalStateException("Unable to remove product from cart.");
		}
	}

	@Override
	public void clearCart(int userId) {
		Cart cart = cartDao.findByUserId(userId);
		if (cart == null) {
			throw new IllegalArgumentException("Cart not found for user ID: " + userId);
		}

		if (cart.getCartItems() == null || cart.getCartItems().isEmpty()) {
			return;
		}

		for (CartItem item : new ArrayList<>(cart.getCartItems())) {
			if (!cartDao.removeCartItem(item)) {
				throw new IllegalStateException("Unable to clear cart.");
			}
		}
	}

	private Cart findOrCreateCart(int userId) {
		Cart cart = cartDao.findByUserId(userId);
		if (cart != null) {
			return cart;
		}

		cart = new Cart();
		cart.setUser(new User(userId));
		cart.setCartItems(new ArrayList<>());
		Cart savedCart = cartDao.save(cart);
		if (savedCart == null) {
			throw new IllegalStateException("Unable to create cart for user ID: " + userId);
		}
		return savedCart;
	}
}

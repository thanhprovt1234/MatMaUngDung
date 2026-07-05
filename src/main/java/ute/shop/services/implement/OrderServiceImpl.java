package ute.shop.services.implement;

import java.util.List;

import ute.shop.dao.IOrderDao;
import ute.shop.dao.implement.OrderDaoImpl;
import ute.shop.entity.Cart;
import ute.shop.entity.CartItem;
import ute.shop.entity.Commission;
import ute.shop.entity.Delivery;
import ute.shop.entity.Order;
import ute.shop.entity.OrderItem;
import ute.shop.entity.OrderStatus;
import ute.shop.entity.Store;
import ute.shop.entity.User;
import ute.shop.services.IOrderService;
import ute.shop.services.*;
import ute.shop.services.ICommissonService;

public class OrderServiceImpl implements IOrderService {
	private IOrderDao orderDao = new OrderDaoImpl();
	private ICartService cartService = new CartServiceImpl();
	private IStoreService storeService = new StoreServiceImpl();
	private IDeliveryService deliveryService = new DeliveryServiceImpl();
	private ICommissonService commissionService = new CommissionServiceImpl();
	private IUserService userService = new UserServiceImpl();

	@Override
	public List<Order> getAllOrdersByUser(int userId) {
		try {
			return orderDao.getAllOrdersByUser(userId);
		} catch (Exception e) {
			throw new RuntimeException("Error fetching orders for user ID: " + userId, e);
		}
	}

	@Override
	public boolean updateOrderStatus(int orderId, OrderStatus status) {
		try {
			return orderDao.updateOrderStatus(orderId, status);
		} catch (Exception e) {
			throw new RuntimeException("Error updating order status for order ID: " + orderId, e);
		}
	}

	@Override
	public boolean cancelOrder(int orderId) {
		try {
			return orderDao.cancelOrder(orderId);
		} catch (Exception e) {
			throw new RuntimeException("Error cancelling order with ID: " + orderId, e);
		}
	}

	@Override
	public Order findById(int orderId) {
		try {
			return orderDao.findById(orderId);
		} catch (Exception e) {
			throw new RuntimeException("Error finding order by ID: " + orderId, e);
		}
	}

	@Override
	public Order placeOrder(int userId, int storeId, int deliveryId, String address, String phone) {
		try {
			// Lấy thông tin từ các service
			User user = userService.findById(userId);
			Store store = storeService.findById(storeId);
			Delivery delivery = deliveryService.findById(deliveryId);
			Commission commission = commissionService.findCommissionByStore(storeId);

			if (user == null || store == null || delivery == null || commission == null) {
				throw new RuntimeException("Missing required references for placing order.");
			}

			Cart cart = cartService.findCartByUserId(userId);
			if (cart == null || cart.getCartItems().isEmpty()) {
				throw new RuntimeException("Cart is empty.");
			}

			// Tính toán chi phí
			double amountFromUser = cart.getTotalAmount();
			double commissionRate = commission.getCost();
			double amountToSystem = amountFromUser * commissionRate;
			double amountToStore = amountFromUser - amountToSystem;

			// Tạo đối tượng Order
			Order order = new Order();
			order.setUser(user);
			order.setStore(store);
			order.setDelivery(delivery);
			order.setCommission(commission);
			order.setAddress(address);
			order.setPhone(phone);
			order.setAmountFromUser(amountFromUser);
			order.setAmountFromStore(amountToSystem);
			order.setAmountToStore(amountToStore);
			order.setAmountToGD(amountToSystem);
			order.setIsPaidBefore(false);
			order.setStatus(OrderStatus.NOT_PROCESSED);

			// Thêm OrderItem vào Order
			for (CartItem item : cart.getCartItems()) {
				OrderItem orderItem = new OrderItem();
				orderItem.setOrder(order);
				orderItem.setProduct(item.getProduct());
				orderItem.setCount(item.getCount());
				order.getOrderItems().add(orderItem);
			}

			// Lưu Order
			Order savedOrder = orderDao.save(order);

			// Xóa giỏ hàng sau khi đặt hàng thành công
			return savedOrder;
		} catch (Exception e) {
			throw new RuntimeException("Error placing order", e);
		}
	}

	@Override
	public boolean makePayment(int orderId) {
		Order order = orderDao.findById(orderId);
		if (order == null) {
			throw new IllegalArgumentException("Order not found.");
		}
		order.setIsPaidBefore(true);
		order.setStatus(OrderStatus.PROCESSED);
		return orderDao.save(order) != null;
	}

	@Override
	public void save(Order order) {
		try {
			// Delegate to OrderDao to save the order
			orderDao.save(order); // Assuming orderDao.save() persists the order in the database
		} catch (Exception e) {
			// Handle any exceptions that might occur during saving
			throw new RuntimeException("Error saving the order", e);
		}
	}

	public long countTotalOrders() {
		return orderDao.countTotalOrders();
	}

	@Override
	public List<Order> findLatestOrders() {
		return orderDao.findLatestOrders();
	}

}

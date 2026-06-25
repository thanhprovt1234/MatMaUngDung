package ute.shop.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import ute.shop.config.EncryptedStringConverter;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name = "orders")
@NamedQuery(name = "Order.findAll", query = "SELECT o FROM Order o")
public class Order {

	@Id
	@GeneratedValue(strategy = GenerationType.AUTO)
	private int _id;

	@ManyToOne
	@JoinColumn(name = "user_id", referencedColumnName = "_id", nullable = false)
	private User user; // Tham chiếu đến User

	@ManyToOne
	@JoinColumn(name = "store_id", nullable = false)
	private Store store; // Tham chiếu tới Store

	@ManyToOne
	@JoinColumn(name = "delivery_id", referencedColumnName = "_id", nullable = false)
	private Delivery delivery;

	@ManyToOne
	@JoinColumn(name = "commission_id", referencedColumnName = "_id", nullable = false)
	private Commission commission; // Tham chiếu đến Commission

	@Column(nullable = false, length = 1024)
	@Convert(converter = EncryptedStringConverter.class)
	private String address; // User's address

	@Column(nullable = false, length = 512)
	@Convert(converter = EncryptedStringConverter.class)
	private String phone; // User's phone number

	@Enumerated(EnumType.STRING)
	@Column(nullable = false)
	private OrderStatus status; // Order status

	@Column(nullable = false)
	private Boolean isPaidBefore = false; // Payment status

	@Column(nullable = false)
	private double amountFromUser; // Amount paid by the user

	@Column(nullable = false)
	private double amountFromStore; // Amount paid by the store to the system

	@Column(nullable = false)
	private double amountToStore; // Amount received by the store

	@Column(nullable = false)
	private double amountToGD; // Amount received by the system

	@Temporal(TemporalType.TIMESTAMP)
	@Column(updatable = false)
	private Date createdAt;

	@Temporal(TemporalType.TIMESTAMP)
	private Date updatedAt;

	@PrePersist
	protected void onCreate() {
		createdAt = new Date();
		updatedAt = new Date();
		status = OrderStatus.NOT_PROCESSED; // Default status
	}

	@PreUpdate
	protected void onUpdate() {
		updatedAt = new Date();
	}

	@OneToMany(mappedBy = "order", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
	private List<Review> reviews = new ArrayList<>(); // Một Order có thể có nhiều Review

	@OneToMany(mappedBy = "order", cascade = CascadeType.ALL, fetch = FetchType.EAGER)
	private List<OrderItem> orderItems = new ArrayList<>(); // Một Order có thể có nhiều OrderItem
}

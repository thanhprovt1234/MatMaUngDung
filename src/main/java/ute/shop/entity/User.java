package ute.shop.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;
import java.util.List;

import java.util.ArrayList;

import ute.shop.config.EncryptedStringConverter;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name = "user")
@NamedQuery(name = "User.findAll", query = "SELECT u FROM User u")
public class User {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private int _id;

	@Column(nullable = false, length = 32)
	private String firstname;

	@Column(nullable = false, length = 32)
	private String lastname;

	@Column(unique = true)
	private String id_card;

	// Số lần nhập sai mật khẩu (tối đa 5)
	@Column(nullable = false)
	private int failedLoginAttempts = 0;

	// Thời điểm bị khóa tài khoản
	@Temporal(TemporalType.TIMESTAMP)
	private Date lockoutTime;

	// Tài khoản có bị khóa không
	@Column(nullable = false)
	private Boolean isLocked = false;

	@Column(unique = true)
	private String email;

	@Column(unique = true)
	private String phone;

	@Column(nullable = false)
	private Boolean isEmailActive = false;

	@Column(nullable = false)
	private Boolean isPhoneActive = false;

	@Column(nullable = false)
	private String password;

	@Enumerated(EnumType.STRING)
	@Column(nullable = false)
	private Role role = Role.USER;

	@Column(nullable = true, length = 1024)
	@Convert(converter = EncryptedStringConverter.class)
	private String address;

	private String avatar;
	private String cover;

	@Column(nullable = false)
	private double e_wallet = 0.0;

	@Temporal(TemporalType.TIMESTAMP)
	@Column(updatable = false)
	private Date createdAt;

	@Temporal(TemporalType.TIMESTAMP)
	private Date updatedAt;

	@PrePersist
	protected void onCreate() {
		createdAt = new Date();
	}

	@PreUpdate
	protected void onUpdate() {
		updatedAt = new Date();
	}

	public User(int id) {
		this._id = id;
	}

	public enum Role {
		USER, ADMIN;

		public static Role fromString(String role) {
			return Role.valueOf(role.toUpperCase());
		}
	}

	// One-to-One Relationship to Store
	@OneToOne(mappedBy = "owner", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
	private Store ownedStore;

	@ManyToMany(mappedBy = "staffs")
	private List<Store> staffedStores;

	@OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
	private List<Transaction> transactions;

	@OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
	private List<Review> reviews = new ArrayList<>();

	@OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
	private List<UserFollowStore> userFollowStores = new ArrayList<>();

	@OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
	private List<Order> orders = new ArrayList<>();

	@OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
	private List<Cart> carts = new ArrayList<>();

	@OneToMany(mappedBy = "user", cascade = CascadeType.ALL)
	private List<UserFollowProduct> userFollowProducts = new ArrayList<>();

}

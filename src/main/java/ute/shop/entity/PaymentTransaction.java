package ute.shop.entity;

import java.util.Date;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name = "payment_transaction")
public class PaymentTransaction {
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private int _id;

	@OneToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "order_id", nullable = false, unique = true)
	private Order order;

	@Column(nullable = false, unique = true, length = 128)
	private String paymentToken;

	@Column(nullable = false, length = 4)
	private String cardLast4;

	@Column(nullable = false, length = 32)
	private String cardBrand;

	@Column(nullable = false)
	private double amount;

	@Enumerated(EnumType.STRING)
	@Column(nullable = false, length = 32)
	private PaymentStatus status = PaymentStatus.AUTHORIZED;

	@Column(nullable = false, length = 64)
	private String gatewayReference;

	@Column(nullable = false, length = 32)
	private String gatewayResponseCode;

	@Column(nullable = false)
	private Boolean panRetained = false;

	@Column(nullable = false)
	private Boolean cvvRetained = false;

	@Column(updatable = false)
	private Date createdAt;

	@PrePersist
	protected void onCreate() {
		createdAt = new Date();
	}

	public enum PaymentStatus {
		AUTHORIZED, DECLINED
	}
}

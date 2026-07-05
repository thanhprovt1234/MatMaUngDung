package ute.shop.config;

import java.util.HashMap;
import java.util.Map;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;
import ute.shop.utils.SecretsConfig;

public class JPAConfig {
	private static final EntityManagerFactory factory = Persistence.createEntityManagerFactory("dataSource",
			databaseOverrides());

	public static EntityManager getEntityManager() {
		return factory.createEntityManager();
	}

	private static Map<String, String> databaseOverrides() {
		Map<String, String> properties = new HashMap<>();
		putIfConfigured(properties, "jakarta.persistence.jdbc.url", "db.url", "DB_URL");
		putIfConfigured(properties, "jakarta.persistence.jdbc.user", "db.user", "DB_USER");
		putIfConfigured(properties, "jakarta.persistence.jdbc.password", "db.password", "DB_PASSWORD");
		putIfConfigured(properties, "jakarta.persistence.jdbc.driver", "db.driver", "DB_DRIVER");
		putIfConfigured(properties, "hibernate.dialect", "hibernate.dialect", "HIBERNATE_DIALECT");
		putIfConfigured(properties, "hibernate.globally_quoted_identifiers",
				"hibernate.globally_quoted_identifiers", "HIBERNATE_GLOBALLY_QUOTED_IDENTIFIERS");
		putIfConfigured(properties, "jakarta.persistence.schema-generation.database.action",
				"db.schema.action", "DB_SCHEMA_ACTION");
		return properties;
	}

	private static void putIfConfigured(Map<String, String> properties, String jpaName, String propertyName,
			String envName) {
		String value = SecretsConfig.get(propertyName, envName, null);
		if (!SecretsConfig.isBlank(value)) {
			properties.put(jpaName, value.trim());
		}
	}
}

package ute.shop.dao.guest.implement;

import java.util.List;

import jakarta.persistence.EntityManager;
import jakarta.persistence.TypedQuery;
import ute.shop.config.JPAConfig;
import ute.shop.entity.Product;

public class ProductDAO {
    public ProductDAO() {
    }

    public ProductDAO(EntityManager em) {
    }

    public Product findById(int id) {
        EntityManager em = JPAConfig.getEntityManager();
        try {
            return em.find(Product.class, id);
        } finally {
            em.close();
        }
    }

    public List<Product> searchProducts(String keywords, Integer categoryId, Double minPrice, Double maxPrice, int page, int pageSize) {
        StringBuilder queryStr = new StringBuilder("SELECT p FROM Product p WHERE p.isSelling = true");

        if (keywords != null && !keywords.isEmpty()) {
            queryStr.append(" AND p.name LIKE :keywords");
        }
        if (categoryId != null) {
            queryStr.append(" AND p.category._id = :categoryId");
        }
        if (minPrice != null) {
            queryStr.append(" AND p.price >= :minPrice");
        }
        if (maxPrice != null) {
            queryStr.append(" AND p.price <= :maxPrice");
        }

        EntityManager em = JPAConfig.getEntityManager();
        try {
            TypedQuery<Product> query = em.createQuery(queryStr.toString(), Product.class);

            if (keywords != null && !keywords.isEmpty()) {
                query.setParameter("keywords", "%" + keywords + "%");
            }
            if (categoryId != null) {
                query.setParameter("categoryId", categoryId);
            }
            if (minPrice != null) {
                query.setParameter("minPrice", minPrice);
            }
            if (maxPrice != null) {
                query.setParameter("maxPrice", maxPrice);
            }

            query.setFirstResult((page - 1) * pageSize);
            query.setMaxResults(pageSize);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    public int countSearchResults(String keywords, Integer categoryId, Double minPrice, Double maxPrice) {
        StringBuilder queryStr = new StringBuilder("SELECT COUNT(p) FROM Product p WHERE p.isSelling = true");

        if (keywords != null && !keywords.isEmpty()) {
            queryStr.append(" AND p.name LIKE :keywords");
        }
        if (categoryId != null) {
            queryStr.append(" AND p.category._id = :categoryId");
        }
        if (minPrice != null) {
            queryStr.append(" AND p.price >= :minPrice");
        }
        if (maxPrice != null) {
            queryStr.append(" AND p.price <= :maxPrice");
        }

        EntityManager em = JPAConfig.getEntityManager();
        try {
            TypedQuery<Long> query = em.createQuery(queryStr.toString(), Long.class);

            if (keywords != null && !keywords.isEmpty()) {
                query.setParameter("keywords", "%" + keywords + "%");
            }
            if (categoryId != null) {
                query.setParameter("categoryId", categoryId);
            }
            if (minPrice != null) {
                query.setParameter("minPrice", minPrice);
            }
            if (maxPrice != null) {
                query.setParameter("maxPrice", maxPrice);
            }

            return query.getSingleResult().intValue();
        } finally {
            em.close();
        }
    }

    public List<Product> getProductsBySales(int limit) {
        EntityManager em = JPAConfig.getEntityManager();
        try {
            String jpql = "SELECT p FROM Product p ORDER BY p.sold DESC";
            return em.createQuery(jpql, Product.class)
                    .setMaxResults(limit)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    public List<Product> getProductsByCategory(int categoryId) {
        EntityManager em = JPAConfig.getEntityManager();
        try {
            TypedQuery<Product> query = em.createQuery(
                    "SELECT p FROM Product p WHERE p.category._id = :categoryId",
                    Product.class
            );
            query.setParameter("categoryId", categoryId);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    public List<Product> getProductsSortedByPriceAsc() {
        EntityManager em = JPAConfig.getEntityManager();
        try {
            return em.createQuery("SELECT p FROM Product p ORDER BY p.price ASC", Product.class)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    public List<Product> getProductsSortedByPriceDesc() {
        EntityManager em = JPAConfig.getEntityManager();
        try {
            return em.createQuery("SELECT p FROM Product p ORDER BY p.price DESC", Product.class)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    public List<Product> getProductsByPriceRange(double minPrice, double maxPrice) {
        EntityManager em = JPAConfig.getEntityManager();
        try {
            return em.createQuery("SELECT p FROM Product p WHERE p.price BETWEEN :minPrice AND :maxPrice", Product.class)
                    .setParameter("minPrice", minPrice)
                    .setParameter("maxPrice", maxPrice)
                    .getResultList();
        } finally {
            em.close();
        }
    }
}

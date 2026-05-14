package com.nownow.dao;

import com.nownow.model.Package;
import com.nownow.util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Data Access Object for the {@code packages} table.
 */
public class PackageDAO {

    // -------------------------------------------------------
    // CREATE
    // -------------------------------------------------------

    public int create(Package pkg) throws SQLException {
        String sql = "INSERT INTO packages (tracking_number, sender_id, description, weight_kg, "
                   + "pickup_address, delivery_address, recipient_name, recipient_phone, "
                   + "status, estimated_price) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, pkg.getTrackingNumber());
            ps.setInt(2, pkg.getSenderId());
            ps.setString(3, pkg.getDescription());
            setBigDecimal(ps, 4, pkg.getWeightKg());
            ps.setString(5, pkg.getPickupAddress());
            ps.setString(6, pkg.getDeliveryAddress());
            ps.setString(7, pkg.getRecipientName());
            ps.setString(8, pkg.getRecipientPhone());
            ps.setString(9, Package.Status.PENDING.name());
            setBigDecimal(ps, 10, pkg.getEstimatedPrice());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        throw new SQLException("Creating package failed, no generated key returned.");
    }

    // -------------------------------------------------------
    // READ
    // -------------------------------------------------------

    public Optional<Package> findById(int id) throws SQLException {
        String sql = "SELECT p.*, u.full_name AS sender_name FROM packages p "
                   + "JOIN users u ON u.id = p.sender_id WHERE p.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return Optional.of(mapRow(rs));
            }
        }
        return Optional.empty();
    }

    public Optional<Package> findByTrackingNumber(String trackingNumber) throws SQLException {
        String sql = "SELECT p.*, u.full_name AS sender_name FROM packages p "
                   + "JOIN users u ON u.id = p.sender_id WHERE p.tracking_number = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, trackingNumber);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return Optional.of(mapRow(rs));
            }
        }
        return Optional.empty();
    }

    /** Returns all packages belonging to a customer. */
    public List<Package> findBySender(int senderId) throws SQLException {
        List<Package> list = new ArrayList<>();
        String sql = "SELECT p.*, u.full_name AS sender_name FROM packages p "
                   + "JOIN users u ON u.id = p.sender_id "
                   + "WHERE p.sender_id = ? ORDER BY p.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, senderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    /** Returns all packages in the system (admin use). */
    public List<Package> findAll() throws SQLException {
        List<Package> list = new ArrayList<>();
        String sql = "SELECT p.*, u.full_name AS sender_name FROM packages p "
                + "JOIN users u ON u.id = p.sender_id ORDER BY p.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        }
        return list;
    }

    public Map<Integer, BigDecimal> findEstimatedPricesByIds(Collection<Integer> packageIds) throws SQLException {
        if (packageIds == null || packageIds.isEmpty()) {
            return Collections.emptyMap();
        }
        String placeholders = packageIds.stream()
                .map(id -> "?")
                .collect(Collectors.joining(","));
        String sql = "SELECT id, estimated_price FROM packages WHERE id IN (" + placeholders + ")";
        Map<Integer, BigDecimal> prices = new HashMap<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            int index = 1;
            for (Integer id : packageIds) {
                ps.setInt(index++, id);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    prices.put(rs.getInt("id"), rs.getBigDecimal("estimated_price"));
                }
            }
        }
        return prices;
    }

    /** Returns all packages with a given status. */
    public List<Package> findByStatus(Package.Status status) throws SQLException {
        List<Package> list = new ArrayList<>();
        String sql = "SELECT p.*, u.full_name AS sender_name FROM packages p "
                   + "JOIN users u ON u.id = p.sender_id WHERE p.status = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status.name());
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    // -------------------------------------------------------
    // UPDATE
    // -------------------------------------------------------

    public void updateStatus(int packageId, Package.Status status) throws SQLException {
        String sql = "UPDATE packages SET status = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status.name());
            ps.setInt(2, packageId);
            ps.executeUpdate();
        }
    }

    // -------------------------------------------------------
    // PRIVATE HELPERS
    // -------------------------------------------------------

    private Package mapRow(ResultSet rs) throws SQLException {
        Package p = new Package();
        p.setId(rs.getInt("id"));
        p.setTrackingNumber(rs.getString("tracking_number"));
        p.setSenderId(rs.getInt("sender_id"));
        p.setSenderName(rs.getString("sender_name"));
        p.setDescription(rs.getString("description"));
        p.setWeightKg(rs.getBigDecimal("weight_kg"));
        p.setPickupAddress(rs.getString("pickup_address"));
        p.setDeliveryAddress(rs.getString("delivery_address"));
        p.setRecipientName(rs.getString("recipient_name"));
        p.setRecipientPhone(rs.getString("recipient_phone"));
        p.setStatus(Package.Status.valueOf(rs.getString("status")));
        p.setEstimatedPrice(rs.getBigDecimal("estimated_price"));
        Timestamp created = rs.getTimestamp("created_at");
        if (created != null) p.setCreatedAt(created.toLocalDateTime());
        Timestamp updated = rs.getTimestamp("updated_at");
        if (updated != null) p.setUpdatedAt(updated.toLocalDateTime());
        return p;
    }

    private void setBigDecimal(PreparedStatement ps, int idx, BigDecimal value) throws SQLException {
        if (value != null) ps.setBigDecimal(idx, value);
        else ps.setNull(idx, Types.DECIMAL);
    }
}

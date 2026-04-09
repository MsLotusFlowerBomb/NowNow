package com.nownow.dao;

import com.nownow.model.Delivery;
import com.nownow.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Data Access Object for the {@code deliveries} table.
 */
public class DeliveryDAO {

    // -------------------------------------------------------
    // CREATE
    // -------------------------------------------------------

    public int create(Delivery delivery) throws SQLException {
        String sql = "INSERT INTO deliveries (package_id, driver_id, status) VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, delivery.getPackageId());
            ps.setInt(2, delivery.getDriverId());
            ps.setString(3, Delivery.Status.ASSIGNED.name());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        throw new SQLException("Creating delivery failed, no generated key returned.");
    }

    // -------------------------------------------------------
    // READ
    // -------------------------------------------------------

    public Optional<Delivery> findById(int id) throws SQLException {
        String sql = "SELECT d.*, u.full_name AS driver_name, p.tracking_number "
                   + "FROM deliveries d "
                   + "JOIN drivers dr ON dr.id = d.driver_id "
                   + "JOIN users   u  ON u.id  = dr.user_id "
                   + "JOIN packages p ON p.id  = d.package_id "
                   + "WHERE d.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return Optional.of(mapRow(rs));
            }
        }
        return Optional.empty();
    }

    public Optional<Delivery> findByPackageId(int packageId) throws SQLException {
        String sql = "SELECT d.*, u.full_name AS driver_name, p.tracking_number "
                   + "FROM deliveries d "
                   + "JOIN drivers dr ON dr.id = d.driver_id "
                   + "JOIN users   u  ON u.id  = dr.user_id "
                   + "JOIN packages p ON p.id  = d.package_id "
                   + "WHERE d.package_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, packageId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return Optional.of(mapRow(rs));
            }
        }
        return Optional.empty();
    }

    /** Returns all deliveries assigned to a specific driver. */
    public List<Delivery> findByDriverId(int driverId) throws SQLException {
        List<Delivery> list = new ArrayList<>();
        String sql = "SELECT d.*, u.full_name AS driver_name, p.tracking_number "
                   + "FROM deliveries d "
                   + "JOIN drivers dr ON dr.id = d.driver_id "
                   + "JOIN users   u  ON u.id  = dr.user_id "
                   + "JOIN packages p ON p.id  = d.package_id "
                   + "WHERE d.driver_id = ? ORDER BY d.assigned_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, driverId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    /** Returns all deliveries (admin use). */
    public List<Delivery> findAll() throws SQLException {
        List<Delivery> list = new ArrayList<>();
        String sql = "SELECT d.*, u.full_name AS driver_name, p.tracking_number "
                   + "FROM deliveries d "
                   + "JOIN drivers dr ON dr.id = d.driver_id "
                   + "JOIN users   u  ON u.id  = dr.user_id "
                   + "JOIN packages p ON p.id  = d.package_id "
                   + "ORDER BY d.assigned_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        }
        return list;
    }

    // -------------------------------------------------------
    // UPDATE
    // -------------------------------------------------------

    public void updateStatus(int deliveryId, Delivery.Status status) throws SQLException {
        String col = switch (status) {
            case PICKED_UP  -> ", picked_up_at = NOW()";
            case DELIVERED  -> ", delivered_at = NOW()";
            default         -> "";
        };
        String sql = "UPDATE deliveries SET status = ?" + col + " WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status.name());
            ps.setInt(2, deliveryId);
            ps.executeUpdate();
        }
    }

    // -------------------------------------------------------
    // PRIVATE HELPERS
    // -------------------------------------------------------

    private Delivery mapRow(ResultSet rs) throws SQLException {
        Delivery d = new Delivery();
        d.setId(rs.getInt("id"));
        d.setPackageId(rs.getInt("package_id"));
        d.setTrackingNumber(rs.getString("tracking_number"));
        d.setDriverId(rs.getInt("driver_id"));
        d.setDriverName(rs.getString("driver_name"));
        d.setStatus(Delivery.Status.valueOf(rs.getString("status")));
        d.setNotes(rs.getString("notes"));
        Timestamp assigned = rs.getTimestamp("assigned_at");
        if (assigned != null) d.setAssignedAt(assigned.toLocalDateTime());
        Timestamp pickedUp = rs.getTimestamp("picked_up_at");
        if (pickedUp != null) d.setPickedUpAt(pickedUp.toLocalDateTime());
        Timestamp delivered = rs.getTimestamp("delivered_at");
        if (delivered != null) d.setDeliveredAt(delivered.toLocalDateTime());
        return d;
    }
}

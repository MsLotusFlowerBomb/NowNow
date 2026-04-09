package com.nownow.dao;

import com.nownow.model.Driver;
import com.nownow.util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Data Access Object for the {@code drivers} table.
 */
public class DriverDAO {

    // -------------------------------------------------------
    // CREATE
    // -------------------------------------------------------

    public int create(Driver driver) throws SQLException {
        String sql = "INSERT INTO drivers (user_id, vehicle_type, license_number, "
                   + "availability_status, current_latitude, current_longitude) "
                   + "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, driver.getUserId());
            ps.setString(2, driver.getVehicleType().name());
            ps.setString(3, driver.getLicenseNumber());
            ps.setString(4, driver.getAvailabilityStatus() != null
                    ? driver.getAvailabilityStatus().name() : Driver.Availability.OFFLINE.name());
            setBigDecimal(ps, 5, driver.getCurrentLatitude());
            setBigDecimal(ps, 6, driver.getCurrentLongitude());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        throw new SQLException("Creating driver failed, no generated key returned.");
    }

    // -------------------------------------------------------
    // READ
    // -------------------------------------------------------

    public Optional<Driver> findByUserId(int userId) throws SQLException {
        String sql = "SELECT d.*, u.full_name, u.email FROM drivers d "
                   + "JOIN users u ON u.id = d.user_id WHERE d.user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return Optional.of(mapRow(rs));
            }
        }
        return Optional.empty();
    }

    public Optional<Driver> findById(int id) throws SQLException {
        String sql = "SELECT d.*, u.full_name, u.email FROM drivers d "
                   + "JOIN users u ON u.id = d.user_id WHERE d.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return Optional.of(mapRow(rs));
            }
        }
        return Optional.empty();
    }

    /** Returns all drivers, joined with their user info. */
    public List<Driver> findAll() throws SQLException {
        List<Driver> list = new ArrayList<>();
        String sql = "SELECT d.*, u.full_name, u.email FROM drivers d "
                   + "JOIN users u ON u.id = d.user_id ORDER BY d.id";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        }
        return list;
    }

    /** Returns only drivers whose availability_status = 'AVAILABLE'. */
    public List<Driver> findAvailable() throws SQLException {
        List<Driver> list = new ArrayList<>();
        String sql = "SELECT d.*, u.full_name, u.email FROM drivers d "
                   + "JOIN users u ON u.id = d.user_id "
                   + "WHERE d.availability_status = 'AVAILABLE'";
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

    public void updateAvailability(int driverId, Driver.Availability status) throws SQLException {
        String sql = "UPDATE drivers SET availability_status = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status.name());
            ps.setInt(2, driverId);
            ps.executeUpdate();
        }
    }

    public void updateLocation(int driverId, BigDecimal lat, BigDecimal lng) throws SQLException {
        String sql = "UPDATE drivers SET current_latitude = ?, current_longitude = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            setBigDecimal(ps, 1, lat);
            setBigDecimal(ps, 2, lng);
            ps.setInt(3, driverId);
            ps.executeUpdate();
        }
    }

    public void incrementDeliveryCount(int driverId) throws SQLException {
        String sql = "UPDATE drivers SET total_deliveries = total_deliveries + 1 WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, driverId);
            ps.executeUpdate();
        }
    }

    // -------------------------------------------------------
    // PRIVATE HELPERS
    // -------------------------------------------------------

    private Driver mapRow(ResultSet rs) throws SQLException {
        Driver d = new Driver();
        d.setId(rs.getInt("id"));
        d.setUserId(rs.getInt("user_id"));
        d.setDriverFullName(rs.getString("full_name"));
        d.setDriverEmail(rs.getString("email"));
        d.setVehicleType(Driver.VehicleType.valueOf(rs.getString("vehicle_type")));
        d.setLicenseNumber(rs.getString("license_number"));
        d.setAvailabilityStatus(Driver.Availability.valueOf(rs.getString("availability_status")));
        d.setCurrentLatitude(rs.getBigDecimal("current_latitude"));
        d.setCurrentLongitude(rs.getBigDecimal("current_longitude"));
        d.setRating(rs.getBigDecimal("rating"));
        d.setTotalDeliveries(rs.getInt("total_deliveries"));
        Timestamp created = rs.getTimestamp("created_at");
        if (created != null) d.setCreatedAt(created.toLocalDateTime());
        Timestamp updated = rs.getTimestamp("updated_at");
        if (updated != null) d.setUpdatedAt(updated.toLocalDateTime());
        return d;
    }

    private void setBigDecimal(PreparedStatement ps, int idx, BigDecimal value) throws SQLException {
        if (value != null) ps.setBigDecimal(idx, value);
        else ps.setNull(idx, Types.DECIMAL);
    }
}

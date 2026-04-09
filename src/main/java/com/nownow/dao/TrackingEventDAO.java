package com.nownow.dao;

import com.nownow.model.TrackingEvent;
import com.nownow.util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for the {@code tracking_events} table.
 */
public class TrackingEventDAO {

    public void create(TrackingEvent event) throws SQLException {
        String sql = "INSERT INTO tracking_events (package_id, status, description, "
                   + "latitude, longitude) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, event.getPackageId());
            ps.setString(2, event.getStatus());
            ps.setString(3, event.getDescription());
            setBigDecimal(ps, 4, event.getLatitude());
            setBigDecimal(ps, 5, event.getLongitude());
            ps.executeUpdate();
        }
    }

    /** Returns all tracking events for a given package, oldest first. */
    public List<TrackingEvent> findByPackageId(int packageId) throws SQLException {
        List<TrackingEvent> list = new ArrayList<>();
        String sql = "SELECT * FROM tracking_events WHERE package_id = ? ORDER BY event_time ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, packageId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    private TrackingEvent mapRow(ResultSet rs) throws SQLException {
        TrackingEvent e = new TrackingEvent();
        e.setId(rs.getInt("id"));
        e.setPackageId(rs.getInt("package_id"));
        Timestamp ts = rs.getTimestamp("event_time");
        if (ts != null) e.setEventTime(ts.toLocalDateTime());
        e.setStatus(rs.getString("status"));
        e.setDescription(rs.getString("description"));
        e.setLatitude(rs.getBigDecimal("latitude"));
        e.setLongitude(rs.getBigDecimal("longitude"));
        return e;
    }

    private void setBigDecimal(PreparedStatement ps, int idx, BigDecimal val) throws SQLException {
        if (val != null) ps.setBigDecimal(idx, val);
        else ps.setNull(idx, Types.DECIMAL);
    }
}

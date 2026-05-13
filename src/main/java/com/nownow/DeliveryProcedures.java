package com.nownow;

import java.sql.*;

public class DeliveryProcedures {

    /**
     * Logic for assigning a driver to a package.
     * Updates package status, driver availability, and creates a delivery record.
     */
    public static void assignDriverToPackage(int pkgId, int driverId) throws SQLException {
        Connection conn = DriverManager.getConnection("jdbc:default:connection");
        
        try {
            // 1. Update Package status
            PreparedStatement psPkg = conn.prepareStatement(
                "UPDATE packages SET status = 'ASSIGNED' WHERE id = ?");
            psPkg.setInt(1, pkgId);
            psPkg.executeUpdate();

            // 2. Update Driver status
            PreparedStatement psDrv = conn.prepareStatement(
                "UPDATE drivers SET availability_status = 'ON_DELIVERY' WHERE id = ?");
            psDrv.setInt(1, driverId);
            psDrv.executeUpdate();

            // 3. Create Delivery record
            PreparedStatement psDel = conn.prepareStatement(
                "INSERT INTO deliveries (package_id, driver_id, status) VALUES (?, ?, 'ASSIGNED')");
            psDel.setInt(1, pkgId);
            psDel.setInt(2, driverId);
            psDel.executeUpdate();
            
        } finally {
            conn.close();
        }
    }

    /**
     * Logic for completing a delivery.
     */
    public static void completeDelivery(int delId, int pkgId, int driverId) throws SQLException {
        Connection conn = DriverManager.getConnection("jdbc:default:connection");
        
        try {
            Timestamp now = new Timestamp(System.currentTimeMillis());

            // 1. Update Delivery
            PreparedStatement psDel = conn.prepareStatement(
                "UPDATE deliveries SET status = 'DELIVERED', delivered_at = ? WHERE id = ?");
            psDel.setTimestamp(1, now);
            psDel.setInt(2, delId);
            psDel.executeUpdate();

            // 2. Update Package
            PreparedStatement psPkg = conn.prepareStatement(
                "UPDATE packages SET status = 'DELIVERED' WHERE id = ?");
            psPkg.setInt(1, pkgId);
            psPkg.executeUpdate();

            // 3. Update Driver back to AVAILABLE
            PreparedStatement psDrv = conn.prepareStatement(
                "UPDATE drivers SET availability_status = 'AVAILABLE', total_deliveries = total_deliveries + 1 WHERE id = ?");
            psDrv.setInt(1, driverId);
            psDrv.executeUpdate();

        } finally {
            conn.close();
        }
    }
}

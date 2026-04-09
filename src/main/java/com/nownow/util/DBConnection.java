package com.nownow.util;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Provides JDBC connections to the MySQL database.
 *
 * <p>Connection parameters are read from {@code /db.properties} on the classpath.
 * Example contents:
 * <pre>
 *   db.url=jdbc:mysql://localhost:3306/nownow_db?useSSL=false&amp;serverTimezone=UTC
 *   db.username=nownow_user
 *   db.password=changeme
 * </pre>
 *
 * <p>Usage:
 * <pre>{@code
 *   try (Connection conn = DBConnection.getConnection()) {
 *       // ... execute SQL ...
 *   }
 * }</pre>
 */
public class DBConnection {

    private static final String PROPERTIES_FILE = "/db.properties";

    private static String url;
    private static String username;
    private static String password;

    static {
        try (InputStream in = DBConnection.class.getResourceAsStream(PROPERTIES_FILE)) {
            if (in == null) {
                throw new ExceptionInInitializerError(
                        "Cannot find " + PROPERTIES_FILE + " on the classpath");
            }
            Properties props = new Properties();
            props.load(in);
            url      = props.getProperty("db.url");
            username = props.getProperty("db.username");
            password = props.getProperty("db.password");

            // Force MySQL JDBC driver registration (required for some JVM setups)
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (IOException | ClassNotFoundException e) {
            throw new ExceptionInInitializerError(e);
        }
    }

    private DBConnection() {
        // Utility class – no instantiation
    }

    /**
     * Returns a new JDBC {@link Connection}.
     * The caller is responsible for closing it (use try-with-resources).
     *
     * @return an open {@link Connection}
     * @throws SQLException if a database access error occurs
     */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(url, username, password);
    }
}

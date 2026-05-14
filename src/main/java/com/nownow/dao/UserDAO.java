package com.nownow.dao;

import com.nownow.model.User;
import com.nownow.util.DBConnection;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Data Access Object for the {@code users} table.
 *
 * <p>All SQL is parameterised (PreparedStatement) to prevent SQL injection.
 */
public class UserDAO {

    // -------------------------------------------------------
    // CREATE
    // -------------------------------------------------------

    /**
     * Inserts a new user into the database.
     *
     * @param user the user to persist (id is ignored; it is assigned by the DB)
     * @return the generated primary-key id
     * @throws SQLException on any database error
     */
    public int create(User user) throws SQLException {
        String sql = "INSERT INTO users (full_name, email, phone, role, password) "
                   + "VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPhone());
            ps.setString(4, user.getRole().name());
            ps.setString(5, user.getPassword());
            ps.executeUpdate();

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        }
        throw new SQLException("Creating user failed, no generated key returned.");
    }

    // -------------------------------------------------------
    // READ
    // -------------------------------------------------------

    /**
     * Finds a user by primary key.
     *
     * @param id the user's database id
     * @return an {@link Optional} containing the user, or empty if not found
     * @throws SQLException on any database error
     */
    public Optional<User> findById(int id) throws SQLException {
        String sql = "SELECT * FROM users WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapRow(rs));
                }
            }
        }
        return Optional.empty();
    }

    /**
     * Finds a user by their email address (used during login).
     *
     * @param email the email to search for
     * @return an {@link Optional} containing the user, or empty if not found
     * @throws SQLException on any database error
     */
    public Optional<User> findByEmail(String email) throws SQLException {
        String sql = "SELECT * FROM users WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapRow(rs));
                }
            }
        }
        return Optional.empty();
    }

    /**
     * Returns all users in the system (admin use).
     *
     * @return list of all users
     * @throws SQLException on any database error
     */
    public List<User> findAll() throws SQLException {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM users ORDER BY created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                users.add(mapRow(rs));
            }
        }
        return users;
    }

    // -------------------------------------------------------
    // UPDATE
    // -------------------------------------------------------

    /**
     * Updates the mutable fields of an existing user.
     *
     * @param user the user with updated values (id must be set)
     * @throws SQLException on any database error
     */
    public void update(User user) throws SQLException {
        String sql = "UPDATE users SET full_name=?, phone=?, role=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getPhone());
            ps.setString(3, user.getRole().name());
            ps.setInt(4, user.getId());
            ps.executeUpdate();
        }
    }

    /**
     * Updates the password for a user (used when rehashing legacy passwords).
     *
     * @param userId the user id
     * @param hashedPassword the new hashed password
     * @throws SQLException on any database error
     */
    public void updatePassword(int userId, String hashedPassword) throws SQLException {
        String sql = "UPDATE users SET password=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, hashedPassword);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }

    // -------------------------------------------------------
    // PRIVATE HELPERS
    // -------------------------------------------------------

    private User mapRow(ResultSet rs) throws SQLException {
        User u = new User();
        u.setId(rs.getInt("id"));
        u.setFullName(rs.getString("full_name"));
        u.setEmail(rs.getString("email"));
        u.setPassword(rs.getString("password"));
        u.setPhone(rs.getString("phone"));
        u.setRole(User.Role.valueOf(rs.getString("role")));
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) u.setCreatedAt(createdAt.toLocalDateTime());
        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) u.setUpdatedAt(updatedAt.toLocalDateTime());
        return u;
    }
}

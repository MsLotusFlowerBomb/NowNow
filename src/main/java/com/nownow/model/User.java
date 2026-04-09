package com.nownow.model;

import java.time.LocalDateTime;

/**
 * Represents an application user.
 * Role distinguishes customers, drivers, and administrators.
 */
public class User {

    public enum Role { CUSTOMER, DRIVER, ADMIN }

    private int id;
    private String fullName;
    private String email;
    private String passwordHash;
    private String phone;
    private Role role;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public User() {}

    public User(int id, String fullName, String email, String passwordHash,
                String phone, Role role) {
        this.id = id;
        this.fullName = fullName;
        this.email = email;
        this.passwordHash = passwordHash;
        this.phone = phone;
        this.role = role;
    }

    // ---- Getters ----

    public int getId()                  { return id; }
    public String getFullName()         { return fullName; }
    public String getEmail()            { return email; }
    public String getPasswordHash()     { return passwordHash; }
    public String getPhone()            { return phone; }
    public Role getRole()               { return role; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }

    // ---- Setters ----

    public void setId(int id)                          { this.id = id; }
    public void setFullName(String fullName)           { this.fullName = fullName; }
    public void setEmail(String email)                 { this.email = email; }
    public void setPasswordHash(String passwordHash)   { this.passwordHash = passwordHash; }
    public void setPhone(String phone)                 { this.phone = phone; }
    public void setRole(Role role)                     { this.role = role; }
    public void setCreatedAt(LocalDateTime createdAt)  { this.createdAt = createdAt; }
    public void setUpdatedAt(LocalDateTime updatedAt)  { this.updatedAt = updatedAt; }

    @Override
    public String toString() {
        return "User{id=" + id + ", fullName='" + fullName + "', email='" + email
                + "', role=" + role + "}";
    }
}

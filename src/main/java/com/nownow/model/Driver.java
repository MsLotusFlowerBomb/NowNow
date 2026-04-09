package com.nownow.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Extended profile for a user who has the DRIVER role.
 * Linked 1-to-1 with the users table.
 */
public class Driver {

    public enum VehicleType   { BICYCLE, MOTORBIKE, CAR, VAN }
    public enum Availability  { AVAILABLE, ON_DELIVERY, OFFLINE }

    private int id;
    private int userId;
    private String driverFullName;   // denormalised for convenience
    private String driverEmail;      // denormalised for convenience
    private VehicleType vehicleType;
    private String licenseNumber;
    private Availability availabilityStatus;
    private BigDecimal currentLatitude;
    private BigDecimal currentLongitude;
    private BigDecimal rating;
    private int totalDeliveries;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public Driver() {}

    // ---- Getters ----

    public int getId()                          { return id; }
    public int getUserId()                      { return userId; }
    public String getDriverFullName()           { return driverFullName; }
    public String getDriverEmail()              { return driverEmail; }
    public VehicleType getVehicleType()         { return vehicleType; }
    public String getLicenseNumber()            { return licenseNumber; }
    public Availability getAvailabilityStatus() { return availabilityStatus; }
    public BigDecimal getCurrentLatitude()      { return currentLatitude; }
    public BigDecimal getCurrentLongitude()     { return currentLongitude; }
    public BigDecimal getRating()               { return rating; }
    public int getTotalDeliveries()             { return totalDeliveries; }
    public LocalDateTime getCreatedAt()         { return createdAt; }
    public LocalDateTime getUpdatedAt()         { return updatedAt; }

    // ---- Setters ----

    public void setId(int id)                                        { this.id = id; }
    public void setUserId(int userId)                                { this.userId = userId; }
    public void setDriverFullName(String driverFullName)             { this.driverFullName = driverFullName; }
    public void setDriverEmail(String driverEmail)                   { this.driverEmail = driverEmail; }
    public void setVehicleType(VehicleType vehicleType)              { this.vehicleType = vehicleType; }
    public void setLicenseNumber(String licenseNumber)               { this.licenseNumber = licenseNumber; }
    public void setAvailabilityStatus(Availability availabilityStatus) { this.availabilityStatus = availabilityStatus; }
    public void setCurrentLatitude(BigDecimal currentLatitude)       { this.currentLatitude = currentLatitude; }
    public void setCurrentLongitude(BigDecimal currentLongitude)     { this.currentLongitude = currentLongitude; }
    public void setRating(BigDecimal rating)                         { this.rating = rating; }
    public void setTotalDeliveries(int totalDeliveries)              { this.totalDeliveries = totalDeliveries; }
    public void setCreatedAt(LocalDateTime createdAt)                { this.createdAt = createdAt; }
    public void setUpdatedAt(LocalDateTime updatedAt)                { this.updatedAt = updatedAt; }

    @Override
    public String toString() {
        return "Driver{id=" + id + ", userId=" + userId
                + ", vehicleType=" + vehicleType
                + ", availability=" + availabilityStatus + "}";
    }
}

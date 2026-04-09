package com.nownow.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * An immutable event in the lifecycle of a package
 * (e.g., "Picked up", "In transit", "Delivered").
 */
public class TrackingEvent {

    private int id;
    private int packageId;
    private LocalDateTime eventTime;
    private String status;
    private String description;
    private BigDecimal latitude;
    private BigDecimal longitude;

    public TrackingEvent() {}

    public TrackingEvent(int packageId, String status, String description) {
        this.packageId   = packageId;
        this.status      = status;
        this.description = description;
        this.eventTime   = LocalDateTime.now();
    }

    // ---- Getters ----

    public int getId()                  { return id; }
    public int getPackageId()           { return packageId; }
    public LocalDateTime getEventTime() { return eventTime; }
    public String getStatus()           { return status; }
    public String getDescription()      { return description; }
    public BigDecimal getLatitude()     { return latitude; }
    public BigDecimal getLongitude()    { return longitude; }

    // ---- Setters ----

    public void setId(int id)                          { this.id = id; }
    public void setPackageId(int packageId)            { this.packageId = packageId; }
    public void setEventTime(LocalDateTime eventTime)  { this.eventTime = eventTime; }
    public void setStatus(String status)               { this.status = status; }
    public void setDescription(String description)     { this.description = description; }
    public void setLatitude(BigDecimal latitude)       { this.latitude = latitude; }
    public void setLongitude(BigDecimal longitude)     { this.longitude = longitude; }
}

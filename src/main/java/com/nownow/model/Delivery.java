package com.nownow.model;

import java.time.LocalDateTime;

/**
 * Links a Package to the Driver assigned to deliver it.
 */
public class Delivery {

    public enum Status { ASSIGNED, PICKED_UP, IN_TRANSIT, DELIVERED, FAILED }

    private int id;
    private int packageId;
    private String trackingNumber;    // denormalised for display
    private int driverId;
    private String driverName;        // denormalised for display
    private LocalDateTime assignedAt;
    private LocalDateTime pickedUpAt;
    private LocalDateTime deliveredAt;
    private Status status;
    private String notes;

    public Delivery() {}

    // ---- Getters ----

    public int getId()                        { return id; }
    public int getPackageId()                 { return packageId; }
    public String getTrackingNumber()         { return trackingNumber; }
    public int getDriverId()                  { return driverId; }
    public String getDriverName()             { return driverName; }
    public LocalDateTime getAssignedAt()      { return assignedAt; }
    public LocalDateTime getPickedUpAt()      { return pickedUpAt; }
    public LocalDateTime getDeliveredAt()     { return deliveredAt; }
    public Status getStatus()                 { return status; }
    public String getNotes()                  { return notes; }

    // ---- Setters ----

    public void setId(int id)                          { this.id = id; }
    public void setPackageId(int packageId)            { this.packageId = packageId; }
    public void setTrackingNumber(String tn)           { this.trackingNumber = tn; }
    public void setDriverId(int driverId)              { this.driverId = driverId; }
    public void setDriverName(String driverName)       { this.driverName = driverName; }
    public void setAssignedAt(LocalDateTime assignedAt){ this.assignedAt = assignedAt; }
    public void setPickedUpAt(LocalDateTime pickedUpAt){ this.pickedUpAt = pickedUpAt; }
    public void setDeliveredAt(LocalDateTime deliveredAt){ this.deliveredAt = deliveredAt; }
    public void setStatus(Status status)               { this.status = status; }
    public void setNotes(String notes)                 { this.notes = notes; }

    @Override
    public String toString() {
        return "Delivery{id=" + id + ", packageId=" + packageId
                + ", driverId=" + driverId + ", status=" + status + "}";
    }
}

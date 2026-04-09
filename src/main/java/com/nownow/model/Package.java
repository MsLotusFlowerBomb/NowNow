package com.nownow.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Represents a package/parcel that a customer wants to ship.
 */
public class Package {

    public enum Status {
        PENDING, ASSIGNED, PICKED_UP, IN_TRANSIT, DELIVERED, CANCELLED
    }

    private int id;
    private String trackingNumber;
    private int senderId;
    private String senderName;       // denormalised for display
    private String description;
    private BigDecimal weightKg;
    private String pickupAddress;
    private String deliveryAddress;
    private String recipientName;
    private String recipientPhone;
    private Status status;
    private BigDecimal estimatedPrice;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public Package() {}

    // ---- Getters ----

    public int getId()                        { return id; }
    public String getTrackingNumber()         { return trackingNumber; }
    public int getSenderId()                  { return senderId; }
    public String getSenderName()             { return senderName; }
    public String getDescription()            { return description; }
    public BigDecimal getWeightKg()           { return weightKg; }
    public String getPickupAddress()          { return pickupAddress; }
    public String getDeliveryAddress()        { return deliveryAddress; }
    public String getRecipientName()          { return recipientName; }
    public String getRecipientPhone()         { return recipientPhone; }
    public Status getStatus()                 { return status; }
    public BigDecimal getEstimatedPrice()     { return estimatedPrice; }
    public LocalDateTime getCreatedAt()       { return createdAt; }
    public LocalDateTime getUpdatedAt()       { return updatedAt; }

    // ---- Setters ----

    public void setId(int id)                              { this.id = id; }
    public void setTrackingNumber(String trackingNumber)   { this.trackingNumber = trackingNumber; }
    public void setSenderId(int senderId)                  { this.senderId = senderId; }
    public void setSenderName(String senderName)           { this.senderName = senderName; }
    public void setDescription(String description)         { this.description = description; }
    public void setWeightKg(BigDecimal weightKg)           { this.weightKg = weightKg; }
    public void setPickupAddress(String pickupAddress)     { this.pickupAddress = pickupAddress; }
    public void setDeliveryAddress(String deliveryAddress) { this.deliveryAddress = deliveryAddress; }
    public void setRecipientName(String recipientName)     { this.recipientName = recipientName; }
    public void setRecipientPhone(String recipientPhone)   { this.recipientPhone = recipientPhone; }
    public void setStatus(Status status)                   { this.status = status; }
    public void setEstimatedPrice(BigDecimal estimatedPrice){ this.estimatedPrice = estimatedPrice; }
    public void setCreatedAt(LocalDateTime createdAt)      { this.createdAt = createdAt; }
    public void setUpdatedAt(LocalDateTime updatedAt)      { this.updatedAt = updatedAt; }

    @Override
    public String toString() {
        return "Package{id=" + id + ", trackingNumber='" + trackingNumber
                + "', status=" + status + "}";
    }
}

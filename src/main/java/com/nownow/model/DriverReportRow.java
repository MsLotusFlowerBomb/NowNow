package com.nownow.model;

/**
 * Summary row for driver performance reporting.
 */
public class DriverReportRow {

    private final int driverId;
    private final String driverName;
    private final String vehicleType;
    private final String availabilityStatus;
    private int totalAssigned;
    private int deliveredCount;
    private int failedCount;
    private int activeCount;
    private int successRate;

    public DriverReportRow(Driver driver) {
        this.driverId = driver.getId();
        this.driverName = driver.getDriverFullName();
        this.vehicleType = driver.getVehicleType() != null ? driver.getVehicleType().name() : "";
        this.availabilityStatus = driver.getAvailabilityStatus() != null ? driver.getAvailabilityStatus().name() : "";
    }

    public int getDriverId() { return driverId; }
    public String getDriverName() { return driverName; }
    public String getVehicleType() { return vehicleType; }
    public String getAvailabilityStatus() { return availabilityStatus; }
    public int getTotalAssigned() { return totalAssigned; }
    public int getDeliveredCount() { return deliveredCount; }
    public int getFailedCount() { return failedCount; }
    public int getActiveCount() { return activeCount; }
    public int getSuccessRate() { return successRate; }

    public void incrementTotalAssigned() { totalAssigned++; }
    public void incrementDelivered() { deliveredCount++; }
    public void incrementFailed() { failedCount++; }
    public void incrementActive() { activeCount++; }

    public void calculateSuccessRate() {
        int completed = deliveredCount + failedCount;
        if (completed == 0) {
            successRate = 0;
            return;
        }
        successRate = (int) Math.round((deliveredCount * 100.0) / completed);
    }
}

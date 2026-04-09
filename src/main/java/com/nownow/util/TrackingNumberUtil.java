package com.nownow.util;

import java.security.SecureRandom;

/**
 * Generates unique tracking numbers for packages.
 *
 * <p>Format: {@code NN-YYYYMMDD-XXXXXXXX}
 * where {@code XXXXXXXX} is a random hex string for uniqueness.
 */
public class TrackingNumberUtil {

    private static final SecureRandom RANDOM = new SecureRandom();

    private TrackingNumberUtil() {
        // Utility class – no instantiation
    }

    /**
     * Generates a new unique tracking number.
     *
     * @return a tracking number of the form {@code NN-20240313-A3F9C21B}
     */
    public static String generate() {
        java.time.LocalDate today = java.time.LocalDate.now();
        String datePart  = String.format("%04d%02d%02d",
                today.getYear(), today.getMonthValue(), today.getDayOfMonth());
        String randomPart = String.format("%08X", RANDOM.nextInt());
        return "NN-" + datePart + "-" + randomPart;
    }
}

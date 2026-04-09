package com.nownow.util;

import org.mindrot.jbcrypt.BCrypt;

/**
 * Utility class for securely hashing and verifying passwords using BCrypt.
 *
 * <p>BCrypt is a slow, adaptive hashing algorithm specifically designed for
 * passwords. The work factor (log rounds) determines how slow it is –
 * a value of 12 is a reasonable default in 2024.
 */
public class PasswordUtil {

    /** BCrypt work factor (log-rounds). Increase as hardware gets faster. */
    private static final int LOG_ROUNDS = 12;

    private PasswordUtil() {
        // Utility class – no instantiation
    }

    /**
     * Hashes a plain-text password using BCrypt.
     *
     * @param plainText the raw password entered by the user
     * @return a BCrypt hash string (60 characters, includes salt)
     */
    public static String hash(String plainText) {
        return BCrypt.hashpw(plainText, BCrypt.gensalt(LOG_ROUNDS));
    }

    /**
     * Checks whether a plain-text password matches a previously stored hash.
     *
     * @param plainText     the password to verify
     * @param hashedPassword the stored BCrypt hash
     * @return {@code true} if the password matches the hash
     */
    public static boolean verify(String plainText, String hashedPassword) {
        return BCrypt.checkpw(plainText, hashedPassword);
    }
}

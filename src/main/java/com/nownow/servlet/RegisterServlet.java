package com.nownow.servlet;

import com.nownow.dao.DriverDAO;
import com.nownow.dao.UserDAO;
import com.nownow.model.Driver;
import com.nownow.model.User;
import com.nownow.util.PasswordUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Optional;

/**
 * Handles new user registration (GET = show form, POST = process registration).
 *
 * <p>Customers are registered with role = CUSTOMER.
 * Drivers are registered with role = DRIVER and an additional row is created
 * in the {@code drivers} table.
 */
@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private final UserDAO   userDAO   = new UserDAO();
    private final DriverDAO driverDAO = new DriverDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String fullName  = req.getParameter("fullName");
        String email     = req.getParameter("email");
        String password  = req.getParameter("password");
        String phone     = req.getParameter("phone");
        String roleParam = req.getParameter("role");    // "CUSTOMER" or "DRIVER"
        String vehicle   = req.getParameter("vehicleType"); // optional – drivers only
        String license   = req.getParameter("licenseNumber"); // optional – drivers only

        // --- Basic server-side validation ---
        if (isEmpty(fullName) || isEmpty(email) || isEmpty(password)) {
            req.setAttribute("errorMessage", "Full name, email, and password are required.");
            req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
            return;
        }

        if (password.length() < 8) {
            req.setAttribute("errorMessage", "Password must be at least 8 characters.");
            req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
            return;
        }

        User.Role role;
        try {
            role = User.Role.valueOf(roleParam == null ? "CUSTOMER" : roleParam.toUpperCase());
            if (role == User.Role.ADMIN) role = User.Role.CUSTOMER; // self-registration can't create admin
        } catch (IllegalArgumentException e) {
            role = User.Role.CUSTOMER;
        }

        try {
            // Check duplicate email
            Optional<User> existing = userDAO.findByEmail(email.trim().toLowerCase());
            if (existing.isPresent()) {
                req.setAttribute("errorMessage", "An account with that email already exists.");
                req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
                return;
            }

            // Build and persist the User
            User user = new User();
            user.setFullName(fullName.trim());
            user.setEmail(email.trim().toLowerCase());
            user.setPasswordHash(PasswordUtil.hash(password));
            user.setPhone(phone != null ? phone.trim() : null);
            user.setRole(role);
            int userId = userDAO.create(user);

            // If registering as a driver, create the driver profile too
            if (role == User.Role.DRIVER) {
                Driver driver = new Driver();
                driver.setUserId(userId);
                driver.setAvailabilityStatus(Driver.Availability.OFFLINE);
                if (vehicle != null && !vehicle.isBlank()) {
                    try {
                        driver.setVehicleType(Driver.VehicleType.valueOf(vehicle.toUpperCase()));
                    } catch (IllegalArgumentException ex) {
                        driver.setVehicleType(Driver.VehicleType.MOTORBIKE);
                    }
                } else {
                    driver.setVehicleType(Driver.VehicleType.MOTORBIKE);
                }
                driver.setLicenseNumber(license != null ? license.trim() : null);
                driverDAO.create(driver);
            }

            req.setAttribute("successMessage",
                    "Registration successful! Please log in.");
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);

        } catch (SQLException e) {
            throw new ServletException("Registration failed", e);
        }
    }

    private boolean isEmpty(String s) {
        return s == null || s.isBlank();
    }
}

package com.nownow.servlet;

import com.nownow.dao.PackageDAO;
import com.nownow.dao.TrackingEventDAO;
import com.nownow.model.Package;
import com.nownow.model.TrackingEvent;
import com.nownow.model.User;
import com.nownow.util.TrackingNumberUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;

/**
 * Manages package CRUD operations for customers.
 *
 * <p>URL patterns:
 * <ul>
 *   <li>GET  /customer/packages          – list customer's packages</li>
 *   <li>GET  /customer/packages/new      – show "send a package" form</li>
 *   <li>POST /customer/packages          – create a new package</li>
 * </ul>
 */
@WebServlet({"/customer/packages", "/customer/packages/new"})
public class PackageServlet extends HttpServlet {

    private final PackageDAO       packageDAO       = new PackageDAO();
    private final TrackingEventDAO trackingEventDAO = new TrackingEventDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = requireCustomer(req, resp);
        if (user == null) return;

        String pathInfo = req.getServletPath();
        if (pathInfo != null && pathInfo.endsWith("/new")) {
            // Show the "send a package" form
            req.getRequestDispatcher("/WEB-INF/views/customer/new-package.jsp").forward(req, resp);
        } else {
            // List all packages for this customer
            try {
                List<Package> packages = packageDAO.findBySender(user.getId());
                req.setAttribute("packages", packages);
                req.getRequestDispatcher("/WEB-INF/views/customer/packages.jsp").forward(req, resp);
            } catch (SQLException e) {
                throw new ServletException("Could not load packages", e);
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = requireCustomer(req, resp);
        if (user == null) return;

        // --- Read form fields ---
        String description      = req.getParameter("description");
        String weightStr        = req.getParameter("weight");
        String pickupAddress    = req.getParameter("pickupAddress");
        String deliveryAddress  = req.getParameter("deliveryAddress");
        String recipientName    = req.getParameter("recipientName");
        String recipientPhone   = req.getParameter("recipientPhone");

        // --- Basic validation ---
        if (isEmpty(pickupAddress) || isEmpty(deliveryAddress) || isEmpty(recipientName)) {
            req.setAttribute("errorMessage",
                    "Pickup address, delivery address, and recipient name are required.");
            req.getRequestDispatcher("/WEB-INF/views/customer/new-package.jsp").forward(req, resp);
            return;
        }

        BigDecimal weight = null;
        if (weightStr != null && !weightStr.isBlank()) {
            try { weight = new BigDecimal(weightStr); }
            catch (NumberFormatException ignored) {}
        }

        // --- Build the package ---
        Package pkg = new Package();
        pkg.setTrackingNumber(TrackingNumberUtil.generate());
        pkg.setSenderId(user.getId());
        pkg.setDescription(description != null ? description.trim() : null);
        pkg.setWeightKg(weight);
        pkg.setPickupAddress(pickupAddress.trim());
        pkg.setDeliveryAddress(deliveryAddress.trim());
        pkg.setRecipientName(recipientName.trim());
        pkg.setRecipientPhone(recipientPhone != null ? recipientPhone.trim() : null);

        // Estimate price: base R5 + R3.50/kg
        BigDecimal estimated = BigDecimal.valueOf(50.0);
        if (weight != null) {
            estimated = estimated.add(weight.multiply(BigDecimal.valueOf(3.50)));
        }
        pkg.setEstimatedPrice(estimated);

        try {
            int pkgId = packageDAO.create(pkg);

            // Log the initial tracking event
            TrackingEvent event = new TrackingEvent(pkgId, "PENDING",
                    "Package registered and awaiting driver assignment.");
            trackingEventDAO.create(event);

            resp.sendRedirect(req.getContextPath()
                    + "/customer/packages?created=" + pkg.getTrackingNumber());

        } catch (SQLException e) {
            throw new ServletException("Failed to create package", e);
        }
    }

    // ---- Helpers ----

    /** Returns the logged-in CUSTOMER user, or null after redirecting to login. */
    private User requireCustomer(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("loggedInUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return null;
        }
        User user = (User) session.getAttribute("loggedInUser");
        if (user.getRole() != User.Role.CUSTOMER && user.getRole() != User.Role.ADMIN) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return null;
        }
        return user;
    }

    private boolean isEmpty(String s) {
        return s == null || s.isBlank();
    }
}

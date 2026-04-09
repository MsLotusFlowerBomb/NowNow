package com.nownow.servlet;

import com.nownow.dao.DeliveryDAO;
import com.nownow.dao.DriverDAO;
import com.nownow.dao.PackageDAO;
import com.nownow.dao.TrackingEventDAO;
import com.nownow.model.*;
import com.nownow.model.Package;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * Driver dashboard and delivery status management.
 *
 * <p>URL patterns:
 * <ul>
 *   <li>GET  /driver/dashboard  – show driver's active and past deliveries</li>
 *   <li>POST /driver/dashboard  – update delivery status (pickup / delivered / failed)</li>
 * </ul>
 */
@WebServlet("/driver/dashboard")
public class DriverDashboardServlet extends HttpServlet {

    private final DeliveryDAO      deliveryDAO      = new DeliveryDAO();
    private final PackageDAO       packageDAO       = new PackageDAO();
    private final DriverDAO        driverDAO        = new DriverDAO();
    private final TrackingEventDAO trackingEventDAO = new TrackingEventDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = requireDriver(req, resp);
        if (user == null) return;

        try {
            Driver driver = driverDAO.findByUserId(user.getId())
                    .orElseThrow(() -> new ServletException("Driver profile not found"));

            List<Delivery> deliveries = deliveryDAO.findByDriverId(driver.getId());
            req.setAttribute("driver", driver);
            req.setAttribute("deliveries", deliveries);
            req.getRequestDispatcher("/WEB-INF/views/driver/dashboard.jsp").forward(req, resp);

        } catch (SQLException e) {
            throw new ServletException("Failed to load driver dashboard", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = requireDriver(req, resp);
        if (user == null) return;

        String action     = req.getParameter("action");    // "pickup" | "deliver" | "fail"
        String deliveryIdStr = req.getParameter("deliveryId");

        if (deliveryIdStr == null || deliveryIdStr.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/driver/dashboard");
            return;
        }

        int deliveryId = Integer.parseInt(deliveryIdStr);

        try {
            Delivery.Status newDeliveryStatus;
            Package.Status  newPackageStatus;
            String eventDescription;

            switch (action == null ? "" : action) {
                case "pickup" -> {
                    newDeliveryStatus = Delivery.Status.PICKED_UP;
                    newPackageStatus  = Package.Status.PICKED_UP;
                    eventDescription  = "Package picked up by driver.";
                }
                case "deliver" -> {
                    newDeliveryStatus = Delivery.Status.DELIVERED;
                    newPackageStatus  = Package.Status.DELIVERED;
                    eventDescription  = "Package delivered successfully.";
                }
                case "fail" -> {
                    newDeliveryStatus = Delivery.Status.FAILED;
                    newPackageStatus  = Package.Status.CANCELLED;
                    eventDescription  = "Delivery attempt failed.";
                }
                default -> {
                    resp.sendRedirect(req.getContextPath() + "/driver/dashboard");
                    return;
                }
            }

            // Update delivery status
            deliveryDAO.updateStatus(deliveryId, newDeliveryStatus);

            // Update package status
            Delivery delivery = deliveryDAO.findByPackageId(deliveryId).orElse(null);
            if (delivery != null) {
                packageDAO.updateStatus(delivery.getPackageId(), newPackageStatus);

                // Log the tracking event
                TrackingEvent event = new TrackingEvent(
                        delivery.getPackageId(),
                        newPackageStatus.name(),
                        eventDescription);
                trackingEventDAO.create(event);

                // If delivered, increment driver's counter and mark available
                if (newDeliveryStatus == Delivery.Status.DELIVERED) {
                    Driver driver = driverDAO.findByUserId(user.getId()).orElse(null);
                    if (driver != null) {
                        driverDAO.incrementDeliveryCount(driver.getId());
                        driverDAO.updateAvailability(driver.getId(), Driver.Availability.AVAILABLE);
                    }
                }
            }

            resp.sendRedirect(req.getContextPath() + "/driver/dashboard?updated=true");

        } catch (SQLException e) {
            throw new ServletException("Failed to update delivery status", e);
        }
    }

    private User requireDriver(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("loggedInUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return null;
        }
        User user = (User) session.getAttribute("loggedInUser");
        if (user.getRole() != User.Role.DRIVER) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return null;
        }
        return user;
    }
}

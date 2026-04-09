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
 * Admin dashboard – overview of all packages, drivers, and deliveries.
 *
 * <p>POST with action=assign lets an admin assign a pending package to
 * an available driver.
 */
@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {

    private final PackageDAO       packageDAO       = new PackageDAO();
    private final DriverDAO        driverDAO        = new DriverDAO();
    private final DeliveryDAO      deliveryDAO      = new DeliveryDAO();
    private final TrackingEventDAO trackingEventDAO = new TrackingEventDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = requireAdmin(req, resp);
        if (user == null) return;

        try {
            List<Package> pendingPackages    = packageDAO.findByStatus(Package.Status.PENDING);
            List<Package> allPackages        = packageDAO.findAll();
            List<Driver>  availableDrivers   = driverDAO.findAvailable();
            List<Driver>  allDrivers         = driverDAO.findAll();
            List<Delivery> activeDeliveries  = deliveryDAO.findAll();

            req.setAttribute("pendingPackages",   pendingPackages);
            req.setAttribute("allPackages",       allPackages);
            req.setAttribute("availableDrivers",  availableDrivers);
            req.setAttribute("allDrivers",        allDrivers);
            req.setAttribute("activeDeliveries",  activeDeliveries);

            req.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(req, resp);

        } catch (SQLException e) {
            throw new ServletException("Failed to load admin dashboard", e);
        }
    }

    /** Assigns a pending package to a selected driver. */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = requireAdmin(req, resp);
        if (user == null) return;

        String action      = req.getParameter("action");
        String packageIdStr = req.getParameter("packageId");
        String driverIdStr  = req.getParameter("driverId");

        if (!"assign".equals(action)
                || packageIdStr == null || packageIdStr.isBlank()
                || driverIdStr  == null || driverIdStr.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
            return;
        }

        int packageId = Integer.parseInt(packageIdStr);
        int driverId  = Integer.parseInt(driverIdStr);

        try {
            // Update package status → ASSIGNED
            packageDAO.updateStatus(packageId, Package.Status.ASSIGNED);

            // Create delivery record
            Delivery delivery = new Delivery();
            delivery.setPackageId(packageId);
            delivery.setDriverId(driverId);
            deliveryDAO.create(delivery);

            // Mark driver as ON_DELIVERY
            driverDAO.updateAvailability(driverId, Driver.Availability.ON_DELIVERY);

            // Log tracking event
            Driver driver = driverDAO.findById(driverId).orElse(null);
            String driverName = driver != null ? driver.getDriverFullName() : "driver";
            TrackingEvent event = new TrackingEvent(packageId, "ASSIGNED",
                    "Package assigned to " + driverName + ".");
            trackingEventDAO.create(event);

            resp.sendRedirect(req.getContextPath() + "/admin/dashboard?assigned=true");

        } catch (SQLException e) {
            throw new ServletException("Failed to assign driver", e);
        }
    }

    private User requireAdmin(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("loggedInUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return null;
        }
        User u = (User) session.getAttribute("loggedInUser");
        if (u.getRole() != User.Role.ADMIN) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return null;
        }
        return u;
    }
}

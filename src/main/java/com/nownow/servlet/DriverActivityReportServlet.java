package com.nownow.servlet;

import com.nownow.dao.DeliveryDAO;
import com.nownow.dao.DriverDAO;
import com.nownow.model.Delivery;
import com.nownow.model.Driver;
import com.nownow.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Report 3 – Driver Activity Report
 * Shows each driver's delivery breakdown and rating.
 * Data comes from: drivers + users + deliveries + packages tables.
 */
@WebServlet("/admin/reports/drivers")
public class DriverActivityReportServlet extends HttpServlet {

    private final DriverDAO   driverDAO   = new DriverDAO();
    private final DeliveryDAO deliveryDAO = new DeliveryDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = requireAdmin(req, resp);
        if (user == null) return;

        LocalDate defaultStart = LocalDate.now().withDayOfMonth(1);
        LocalDate defaultEnd   = LocalDate.now();

        LocalDate startDate = parseDate(req.getParameter("startDate")).orElse(defaultStart);
        LocalDate endDate   = parseDate(req.getParameter("endDate")).orElse(defaultEnd);

        List<String> warnings = new ArrayList<>();
        if (endDate.isBefore(startDate)) {
            endDate = startDate;
            warnings.add("End date cannot be before start date. Using start date instead.");
        }

        String availFilter = req.getParameter("availability");
        if (availFilter != null && availFilter.isBlank()) availFilter = null;

        try {
            List<Driver> allDrivers = driverDAO.findAll();

            // Filter by availability if requested
            List<Driver> filteredDrivers = allDrivers;
            if (availFilter != null) {
                final String af = availFilter;
                filteredDrivers = allDrivers.stream()
                    .filter(d -> d.getAvailabilityStatus() != null
                              && d.getAvailabilityStatus().name().equals(af))
                    .collect(Collectors.toList());
            }

            LocalDateTime start = startDate.atStartOfDay();
            LocalDateTime end   = endDate.plusDays(1).atStartOfDay();

            // Build per-driver row data
            List<Map<String, Object>> rows = new ArrayList<>();
            int totalDelivered = 0;
            int totalFailed    = 0;

            for (Driver driver : filteredDrivers) {
                List<Delivery> driverDeliveries =
                    deliveryDAO.findByDriverAndAssignedRange(driver.getId(), start, end);

                long delivered = driverDeliveries.stream()
                    .filter(d -> d.getStatus() == Delivery.Status.DELIVERED).count();
                long failed = driverDeliveries.stream()
                    .filter(d -> d.getStatus() == Delivery.Status.FAILED).count();
                long active = driverDeliveries.stream()
                    .filter(d -> d.getStatus() == Delivery.Status.ASSIGNED
                              || d.getStatus() == Delivery.Status.PICKED_UP
                              || d.getStatus() == Delivery.Status.IN_TRANSIT).count();

                int completed = (int)(delivered + failed);
                int successRate = completed == 0 ? 0
                    : (int) Math.round((delivered * 100.0) / completed);

                Map<String, Object> row = new LinkedHashMap<>();
                row.put("driverName",    driver.getDriverFullName());
                row.put("email",         driver.getDriverEmail());
                row.put("vehicleType",   driver.getVehicleType() != null ? driver.getVehicleType().name() : "—");
                row.put("availability",  driver.getAvailabilityStatus() != null ? driver.getAvailabilityStatus().name() : "—");
                row.put("rating",        driver.getRating() != null ? driver.getRating().toString() : "—");
                row.put("totalLifetime", driver.getTotalDeliveries());
                row.put("periodTotal",   driverDeliveries.size());
                row.put("delivered",     delivered);
                row.put("failed",        failed);
                row.put("active",        active);
                row.put("successRate",   successRate);
                rows.add(row);

                totalDelivered += delivered;
                totalFailed    += failed;
            }

            // Sort by deliveries descending
            rows.sort((a, b) -> Integer.compare(
                (int)(long)(Long)((Number)b.get("delivered")).longValue(),
                (int)(long)(Long)((Number)a.get("delivered")).longValue()
            ));

            DateTimeFormatter display = DateTimeFormatter.ofPattern("dd MMM yyyy");
            String rangeLabel = startDate.format(display) + " – " + endDate.format(display);

            int totalSuccessRate = (totalDelivered + totalFailed) == 0 ? 0
                : (int) Math.round((totalDelivered * 100.0) / (totalDelivered + totalFailed));

            req.setAttribute("rows",             rows);
            req.setAttribute("availabilities",   Driver.Availability.values());
            req.setAttribute("availFilter",      availFilter);
            req.setAttribute("startDate",        startDate);
            req.setAttribute("endDate",          endDate);
            req.setAttribute("rangeLabel",       rangeLabel);
            req.setAttribute("warnings",         warnings);
            req.setAttribute("totalDrivers",     filteredDrivers.size());
            req.setAttribute("totalDelivered",   totalDelivered);
            req.setAttribute("totalFailed",      totalFailed);
            req.setAttribute("totalSuccessRate", totalSuccessRate);

            req.getRequestDispatcher("/WEB-INF/views/admin/report-drivers.jsp").forward(req, resp);

        } catch (SQLException e) {
            throw new ServletException("Failed to load driver activity report", e);
        }
    }

    private Optional<LocalDate> parseDate(String value) {
        if (value == null || value.isBlank()) return Optional.empty();
        try { return Optional.of(LocalDate.parse(value, DateTimeFormatter.ISO_LOCAL_DATE)); }
        catch (DateTimeParseException e) { return Optional.empty(); }
    }

    private User requireAdmin(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("loggedInUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/login"); return null;
        }
        User u = (User) session.getAttribute("loggedInUser");
        if (u.getRole() != User.Role.ADMIN) {
            resp.sendRedirect(req.getContextPath() + "/login"); return null;
        }
        return u;
    }
}

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
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Report 2 – Delivery History Report
 * Shows all deliveries with tracking number, driver name, status, and timestamps.
 * Data comes from: deliveries + packages + drivers + users tables (via DeliveryDAO JOIN).
 */
@WebServlet("/admin/reports/deliveries")
public class DeliveryHistoryReportServlet extends HttpServlet {

    private final DeliveryDAO deliveryDAO = new DeliveryDAO();
    private final DriverDAO   driverDAO   = new DriverDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = requireAdmin(req, resp);
        if (user == null) return;

        // ── Defaults: current month ───────────────────────────────────
        LocalDate defaultStart = LocalDate.now().withDayOfMonth(1);
        LocalDate defaultEnd   = LocalDate.now();

        LocalDate startDate = parseDate(req.getParameter("startDate")).orElse(defaultStart);
        LocalDate endDate   = parseDate(req.getParameter("endDate")).orElse(defaultEnd);

        List<String> warnings = new ArrayList<>();
        if (endDate.isBefore(startDate)) {
            endDate = startDate;
            warnings.add("End date cannot be before start date. Using start date instead.");
        }

        String statusFilter   = req.getParameter("status");
        if (statusFilter != null && statusFilter.isBlank()) statusFilter = null;

        Integer driverFilter = parseDriverId(req.getParameter("driverId"));

        try {
            List<Driver> drivers = driverDAO.findAll().stream()
                .sorted(Comparator.comparing(Driver::getDriverFullName))
                .collect(Collectors.toList());

            LocalDateTime start = startDate.atStartOfDay();
            LocalDateTime end   = endDate.plusDays(1).atStartOfDay();

            List<Delivery> deliveries;
            if (driverFilter != null) {
                deliveries = deliveryDAO.findByDriverAndAssignedRange(driverFilter, start, end);
            } else {
                deliveries = deliveryDAO.findByAssignedRange(start, end);
            }

            // Status filter
            if (statusFilter != null) {
                final String sf = statusFilter;
                deliveries = deliveries.stream()
                    .filter(d -> d.getStatus().name().equals(sf))
                    .collect(Collectors.toList());
            }

            // Summary counts
            long delivered = deliveries.stream().filter(d -> d.getStatus() == Delivery.Status.DELIVERED).count();
            long failed    = deliveries.stream().filter(d -> d.getStatus() == Delivery.Status.FAILED).count();
            long active    = deliveries.stream().filter(d ->
                d.getStatus() == Delivery.Status.ASSIGNED
             || d.getStatus() == Delivery.Status.PICKED_UP
             || d.getStatus() == Delivery.Status.IN_TRANSIT).count();

            DateTimeFormatter display = DateTimeFormatter.ofPattern("dd MMM yyyy");
            String rangeLabel = startDate.format(display) + " – " + endDate.format(display);

            req.setAttribute("deliveries",    deliveries);
            req.setAttribute("drivers",       drivers);
            req.setAttribute("statuses",      Delivery.Status.values());
            req.setAttribute("statusFilter",  statusFilter);
            req.setAttribute("driverFilter",  driverFilter);
            req.setAttribute("startDate",     startDate);
            req.setAttribute("endDate",       endDate);
            req.setAttribute("rangeLabel",    rangeLabel);
            req.setAttribute("warnings",      warnings);
            req.setAttribute("countTotal",    deliveries.size());
            req.setAttribute("countDelivered", delivered);
            req.setAttribute("countFailed",   failed);
            req.setAttribute("countActive",   active);

            req.getRequestDispatcher("/WEB-INF/views/admin/report-deliveries.jsp").forward(req, resp);

        } catch (SQLException e) {
            throw new ServletException("Failed to load delivery history report", e);
        }
    }

    private Optional<LocalDate> parseDate(String value) {
        if (value == null || value.isBlank()) return Optional.empty();
        try { return Optional.of(LocalDate.parse(value, DateTimeFormatter.ISO_LOCAL_DATE)); }
        catch (DateTimeParseException e) { return Optional.empty(); }
    }

    private Integer parseDriverId(String value) {
        if (value == null || value.isBlank()) return null;
        try { return Integer.parseInt(value); }
        catch (NumberFormatException e) { return null; }
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

package com.nownow.servlet;

import com.nownow.dao.PackageDAO;
import com.nownow.model.Package;
import com.nownow.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Report 3 – Revenue Report
 * Shows estimated revenue from packages, filterable by date range and status.
 * URL: GET /admin/reports/revenue
 */
@WebServlet("/admin/reports/revenue")
public class RevenueReportServlet extends HttpServlet {

    private final PackageDAO packageDAO = new PackageDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = requireAdmin(req, resp);
        if (user == null) return;

        // ── Date range defaults: current month ────────────────────────
        LocalDate defaultStart = LocalDate.now().withDayOfMonth(1);
        LocalDate defaultEnd   = LocalDate.now();

        LocalDate startDate = parseDate(req.getParameter("startDate")).orElse(defaultStart);
        LocalDate endDate   = parseDate(req.getParameter("endDate")).orElse(defaultEnd);

        List<String> warnings = new ArrayList<>();
        if (endDate.isBefore(startDate)) {
            endDate = startDate;
            warnings.add("End date cannot be before start date. Using start date instead.");
        }

        // Optional status filter (only delivered = confirmed revenue)
        String statusFilter = req.getParameter("status");
        if (statusFilter != null && statusFilter.isBlank()) statusFilter = null;

        try {
            List<Package> allPackages = packageDAO.findAll();

            // Filter by date range
            final LocalDate fStart = startDate;
            final LocalDate fEnd   = endDate;
            List<Package> filtered = allPackages.stream()
                .filter(p -> p.getCreatedAt() != null
                    && !p.getCreatedAt().toLocalDate().isBefore(fStart)
                    && !p.getCreatedAt().toLocalDate().isAfter(fEnd))
                .collect(Collectors.toList());

            // Filter by status if selected
            if (statusFilter != null) {
                final String sf = statusFilter;
                filtered = filtered.stream()
                    .filter(p -> p.getStatus().name().equals(sf))
                    .collect(Collectors.toList());
            }

            // ── Revenue calculations ───────────────────────────────────
            BigDecimal totalRevenue = filtered.stream()
                .filter(p -> p.getEstimatedPrice() != null)
                .map(Package::getEstimatedPrice)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

            BigDecimal confirmedRevenue = filtered.stream()
                .filter(p -> p.getStatus() == Package.Status.DELIVERED
                          && p.getEstimatedPrice() != null)
                .map(Package::getEstimatedPrice)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

            BigDecimal pendingRevenue = filtered.stream()
                .filter(p -> p.getStatus() != Package.Status.DELIVERED
                          && p.getStatus() != Package.Status.CANCELLED
                          && p.getEstimatedPrice() != null)
                .map(Package::getEstimatedPrice)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

            long deliveredCount = filtered.stream()
                .filter(p -> p.getStatus() == Package.Status.DELIVERED).count();

            BigDecimal avgRevenue = deliveredCount > 0
                ? confirmedRevenue.divide(BigDecimal.valueOf(deliveredCount), 2, RoundingMode.HALF_UP)
                : BigDecimal.ZERO;

            // ── Format display range label ─────────────────────────────
            DateTimeFormatter display = DateTimeFormatter.ofPattern("dd MMM yyyy");
            String rangeLabel = startDate.format(display) + " – " + endDate.format(display);

            // ── Set request attributes ─────────────────────────────────
            req.setAttribute("packages",         filtered);
            req.setAttribute("statuses",         Package.Status.values());
            req.setAttribute("statusFilter",     statusFilter);
            req.setAttribute("startDate",        startDate);
            req.setAttribute("endDate",          endDate);
            req.setAttribute("rangeLabel",       rangeLabel);
            req.setAttribute("warnings",         warnings);
            req.setAttribute("totalRevenue",     totalRevenue);
            req.setAttribute("confirmedRevenue", confirmedRevenue);
            req.setAttribute("pendingRevenue",   pendingRevenue);
            req.setAttribute("avgRevenue",       avgRevenue);
            req.setAttribute("totalPackages",    filtered.size());
            req.setAttribute("deliveredCount",   deliveredCount);

            req.getRequestDispatcher("/WEB-INF/views/admin/report-revenue.jsp").forward(req, resp);

        } catch (SQLException e) {
            req.setAttribute("errorMessage",
                "Unable to load revenue data. Please try again or contact your system administrator.");
            req.getRequestDispatcher("/WEB-INF/views/admin/report-revenue.jsp").forward(req, resp);
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

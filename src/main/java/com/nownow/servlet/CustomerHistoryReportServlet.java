package com.nownow.servlet;

import com.nownow.dao.PackageDAO;
import com.nownow.dao.UserDAO;
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
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Report 4 – Customer Delivery History Report
 * Shows per-customer package statistics, filterable by date range and customer.
 * URL: GET /admin/reports/customers
 */
@WebServlet("/admin/reports/customers")
public class CustomerHistoryReportServlet extends HttpServlet {

    private final PackageDAO packageDAO = new PackageDAO();
    private final UserDAO    userDAO    = new UserDAO();

    /** Simple DTO to hold per-customer summary data. */
    public static class CustomerRow {
        public String     customerName;
        public String     email;
        public int        totalPackages;
        public long       delivered;
        public long       inTransit;
        public long       pending;
        public long       cancelled;
        public BigDecimal totalSpent;

        public String getCustomerName()  { return customerName; }
        public String getEmail()         { return email; }
        public int    getTotalPackages() { return totalPackages; }
        public long   getDelivered()     { return delivered; }
        public long   getInTransit()     { return inTransit; }
        public long   getPending()       { return pending; }
        public long   getCancelled()     { return cancelled; }
        public BigDecimal getTotalSpent(){ return totalSpent; }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User admin = requireAdmin(req, resp);
        if (admin == null) return;

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

        // Optional: filter by a specific customer email
        String customerFilter = req.getParameter("customerEmail");
        if (customerFilter != null && customerFilter.isBlank()) customerFilter = null;

        try {
            // Load all customers for the filter dropdown
            List<User> allCustomers = userDAO.findAll().stream()
                .filter(u -> u.getRole() == User.Role.CUSTOMER)
                .collect(Collectors.toList());

            // Load all packages and filter by date
            List<Package> allPackages = packageDAO.findAll();
            final LocalDate fStart = startDate;
            final LocalDate fEnd   = endDate;

            List<Package> filtered = allPackages.stream()
                .filter(p -> p.getCreatedAt() != null
                    && !p.getCreatedAt().toLocalDate().isBefore(fStart)
                    && !p.getCreatedAt().toLocalDate().isAfter(fEnd))
                .collect(Collectors.toList());

            // Group packages by sender ID
            Map<Integer, List<Package>> byCustomer = filtered.stream()
                .collect(Collectors.groupingBy(Package::getSenderId));

            // Build a CustomerRow per customer who has packages in range
            List<CustomerRow> rows = new ArrayList<>();
            for (User customer : allCustomers) {

                // If a customer filter is applied, skip others
                if (customerFilter != null && !customer.getEmail().equals(customerFilter)) continue;

                List<Package> pkgs = byCustomer.getOrDefault(customer.getId(), Collections.emptyList());
                if (pkgs.isEmpty() && customerFilter == null) continue; // skip customers with no activity

                CustomerRow row = new CustomerRow();
                row.customerName   = customer.getFullName();
                row.email          = customer.getEmail();
                row.totalPackages  = pkgs.size();
                row.delivered      = pkgs.stream().filter(p -> p.getStatus() == Package.Status.DELIVERED).count();
                row.inTransit      = pkgs.stream().filter(p -> p.getStatus() == Package.Status.IN_TRANSIT
                                                             || p.getStatus() == Package.Status.PICKED_UP
                                                             || p.getStatus() == Package.Status.ASSIGNED).count();
                row.pending        = pkgs.stream().filter(p -> p.getStatus() == Package.Status.PENDING).count();
                row.cancelled      = pkgs.stream().filter(p -> p.getStatus() == Package.Status.CANCELLED).count();
                row.totalSpent     = pkgs.stream()
                                        .filter(p -> p.getEstimatedPrice() != null)
                                        .map(Package::getEstimatedPrice)
                                        .reduce(BigDecimal.ZERO, BigDecimal::add);
                rows.add(row);
            }

            // Sort by most active customer first
            rows.sort(Comparator.comparingInt(CustomerRow::getTotalPackages).reversed());

            // Totals
            int  totalPackages  = rows.stream().mapToInt(CustomerRow::getTotalPackages).sum();
            long totalDelivered = rows.stream().mapToLong(CustomerRow::getDelivered).sum();
            BigDecimal totalRevenue = rows.stream()
                .map(CustomerRow::getTotalSpent)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

            DateTimeFormatter display = DateTimeFormatter.ofPattern("dd MMM yyyy");
            String rangeLabel = startDate.format(display) + " – " + endDate.format(display);

            req.setAttribute("rows",           rows);
            req.setAttribute("allCustomers",   allCustomers);
            req.setAttribute("customerFilter", customerFilter);
            req.setAttribute("startDate",      startDate);
            req.setAttribute("endDate",        endDate);
            req.setAttribute("rangeLabel",     rangeLabel);
            req.setAttribute("warnings",       warnings);
            req.setAttribute("totalPackages",  totalPackages);
            req.setAttribute("totalDelivered", totalDelivered);
            req.setAttribute("totalRevenue",   totalRevenue);

            req.getRequestDispatcher("/WEB-INF/views/admin/report-customers.jsp").forward(req, resp);

        } catch (SQLException e) {
            req.setAttribute("errorMessage",
                "Unable to load customer history. Please try again or contact your system administrator.");
            req.getRequestDispatcher("/WEB-INF/views/admin/report-customers.jsp").forward(req, resp);
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

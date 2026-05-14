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
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Report 1 – Package Status Report
 * Shows all packages joined with sender info, filterable by status and date range.
 * Data comes from: packages + users tables.
 */
@WebServlet("/admin/reports/packages")
public class PackageStatusReportServlet extends HttpServlet {

    private final PackageDAO packageDAO = new PackageDAO();

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

        String statusFilter = req.getParameter("status");
        if (statusFilter != null && statusFilter.isBlank()) statusFilter = null;

        try {
            List<Package> allPackages = packageDAO.findAll();

            // Filter by date
            final LocalDate fStart = startDate;
            final LocalDate fEnd   = endDate;
            List<Package> filtered = allPackages.stream()
                .filter(p -> p.getCreatedAt() != null
                    && !p.getCreatedAt().toLocalDate().isBefore(fStart)
                    && !p.getCreatedAt().toLocalDate().isAfter(fEnd))
                .collect(Collectors.toList());

            // Filter by status
            if (statusFilter != null) {
                final String sf = statusFilter;
                filtered = filtered.stream()
                    .filter(p -> p.getStatus().name().equals(sf))
                    .collect(Collectors.toList());
            }

            // Summary counts
            long pending   = filtered.stream().filter(p -> p.getStatus() == Package.Status.PENDING).count();
            long assigned  = filtered.stream().filter(p -> p.getStatus() == Package.Status.ASSIGNED).count();
            long inTransit = filtered.stream().filter(p -> p.getStatus() == Package.Status.IN_TRANSIT
                                                        || p.getStatus() == Package.Status.PICKED_UP).count();
            long delivered = filtered.stream().filter(p -> p.getStatus() == Package.Status.DELIVERED).count();
            long cancelled = filtered.stream().filter(p -> p.getStatus() == Package.Status.CANCELLED).count();

            DateTimeFormatter display = DateTimeFormatter.ofPattern("dd MMM yyyy");
            String rangeLabel = startDate.format(display) + " – " + endDate.format(display);

            req.setAttribute("packages",     filtered);
            req.setAttribute("statuses",     Package.Status.values());
            req.setAttribute("statusFilter", statusFilter);
            req.setAttribute("startDate",    startDate);
            req.setAttribute("endDate",      endDate);
            req.setAttribute("rangeLabel",   rangeLabel);
            req.setAttribute("warnings",     warnings);
            req.setAttribute("countPending",   pending);
            req.setAttribute("countAssigned",  assigned);
            req.setAttribute("countInTransit", inTransit);
            req.setAttribute("countDelivered", delivered);
            req.setAttribute("countCancelled", cancelled);
            req.setAttribute("countTotal",     filtered.size());

            req.getRequestDispatcher("/WEB-INF/views/admin/report-packages.jsp").forward(req, resp);

        } catch (SQLException e) {
            throw new ServletException("Failed to load package report", e);
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

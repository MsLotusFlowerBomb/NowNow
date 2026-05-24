package com.nownow.servlet;

import com.nownow.dao.DeliveryDAO;
import com.nownow.dao.DriverDAO;
import com.nownow.dao.PackageDAO;
import com.nownow.model.Delivery;
import com.nownow.model.Driver;
import com.nownow.model.DriverReportRow;
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
import java.text.NumberFormat;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

@WebServlet("/admin/reports")
public class AdminReportsServlet extends HttpServlet {

    private final DeliveryDAO deliveryDAO = new DeliveryDAO();
    private final DriverDAO driverDAO = new DriverDAO();
    private final PackageDAO packageDAO = new PackageDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = requireAdmin(req, resp);
        if (user == null) return;

        LocalDate defaultStart = LocalDate.now().withDayOfMonth(1);
        LocalDate defaultEnd = LocalDate.now();

        LocalDate startDate = parseDate(req.getParameter("startDate")).orElse(defaultStart);
        LocalDate endDate = parseDate(req.getParameter("endDate")).orElse(defaultEnd);
        List<String> filterWarnings = new ArrayList<>();
        if (endDate.isBefore(startDate)) {
            endDate = startDate;
            filterWarnings.add("End date cannot be before start date. Using the start date instead.");
        }

        Integer driverFilter = parseDriverId(req.getParameter("driverId"));

        try {
            List<Driver> drivers = loadDrivers();
            Optional<Driver> selectedDriver = Optional.empty();
            if (driverFilter != null) {
                int driverIdValue = driverFilter;
                selectedDriver = drivers.stream()
                        .filter(driver -> driver.getId() == driverIdValue)
                        .findFirst();
                if (selectedDriver.isEmpty()) {
                    driverFilter = null;
                    filterWarnings.add("Selected driver was not found. Showing all drivers.");
                }
            }

            List<Driver> reportDrivers = selectedDriver.map(List::of).orElse(drivers);

            LocalDateTime startDateTime = startDate.atStartOfDay();
            LocalDateTime endDateTime = endDate.plusDays(1).atStartOfDay();
            List<Delivery> deliveries = loadDeliveries(driverFilter, startDateTime, endDateTime);
            Set<Integer> deliveredPackageIds = deliveries.stream()
                    .filter(delivery -> delivery.getStatus() == Delivery.Status.DELIVERED)
                    .map(Delivery::getPackageId)
                    .collect(Collectors.toSet());
            Map<Integer, BigDecimal> estimatedPrices = loadEstimatedPrices(deliveredPackageIds);

            Map<Integer, DriverReportRow> rows = new LinkedHashMap<>();
            for (Driver driver : reportDrivers) {
                rows.put(driver.getId(), new DriverReportRow(driver));
            }

            int totalAssigned = 0;
            int deliveredCount = 0;
            int failedCount = 0;
            int activeCount = 0;
            BigDecimal revenue = BigDecimal.ZERO;

            for (Delivery delivery : deliveries) {
                DriverReportRow row = rows.get(delivery.getDriverId());
                if (row == null) {
                    continue;
                }

                row.incrementTotalAssigned();
                totalAssigned++;

                switch (delivery.getStatus()) {
                    case DELIVERED -> {
                        row.incrementDelivered();
                        deliveredCount++;
                        BigDecimal price = estimatedPrices.get(delivery.getPackageId());
                        if (price != null) {
                            revenue = revenue.add(price);
                        }
                    }
                    case FAILED -> {
                        row.incrementFailed();
                        failedCount++;
                    }
                    case ASSIGNED, PICKED_UP, IN_TRANSIT -> {
                        row.incrementActive();
                        activeCount++;
                    }
                    default -> {
                    }
                }
            }

            List<DriverReportRow> reportRows = new ArrayList<>(rows.values());
            reportRows.forEach(DriverReportRow::calculateSuccessRate);

            int successRate = DriverReportRow.calculateSuccessRate(deliveredCount, failedCount);
            String revenueDisplay = NumberFormat.getCurrencyInstance(new Locale("en","ZA")).format(revenue);

            DateTimeFormatter displayFormatter = DateTimeFormatter.ofPattern("dd MMM yyyy");
            String rangeLabel = startDate.format(displayFormatter) + " - " + endDate.format(displayFormatter);

            req.setAttribute("reportRows", reportRows);
            req.setAttribute("drivers", drivers.stream()
                    .sorted(Comparator.comparing(Driver::getDriverFullName))
                    .collect(Collectors.toList()));
            req.setAttribute("selectedDriverId", driverFilter);
            req.setAttribute("startDate", startDate);
            req.setAttribute("endDate", endDate);
            req.setAttribute("rangeLabel", rangeLabel);
            req.setAttribute("totalAssigned", totalAssigned);
            req.setAttribute("deliveredCount", deliveredCount);
            req.setAttribute("failedCount", failedCount);
            req.setAttribute("activeCount", activeCount);
            req.setAttribute("successRate", successRate);
            req.setAttribute("revenueDisplay", revenueDisplay);
            req.setAttribute("filterWarnings", filterWarnings);

            req.getRequestDispatcher("/WEB-INF/views/admin/report.jsp").forward(req, resp);

        } catch (SQLException e) {
            throw new ServletException(e.getMessage(), e);
        }
    }

    private List<Driver> loadDrivers() throws SQLException {
        try {
            return driverDAO.findAll();
        } catch (SQLException e) {
            throw new SQLException("Failed to load drivers for the report.", e);
        }
    }

    private List<Delivery> loadDeliveries(Integer driverFilter, LocalDateTime start, LocalDateTime end) throws SQLException {
        try {
            if (driverFilter != null) {
                return deliveryDAO.findByDriverAndAssignedRange(driverFilter, start, end);
            }
            return deliveryDAO.findByAssignedRange(start, end);
        } catch (SQLException e) {
            throw new SQLException("Failed to load deliveries for the report.", e);
        }
    }

    private Map<Integer, BigDecimal> loadEstimatedPrices(Set<Integer> packageIds) throws SQLException {
        try {
            return packageDAO.findEstimatedPricesByIds(packageIds);
        } catch (SQLException e) {
            throw new SQLException("Failed to load package pricing for the report.", e);
        }
    }

    private Optional<LocalDate> parseDate(String value) {
        if (value == null || value.isBlank()) return Optional.empty();
        try {
            return Optional.of(LocalDate.parse(value, DateTimeFormatter.ISO_LOCAL_DATE));
        } catch (DateTimeParseException ex) {
            return Optional.empty();
        }
    }

    private Integer parseDriverId(String value) {
        if (value == null || value.isBlank()) return null;
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException ex) {
            return null;
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

package com.nownow.servlet;

import com.nownow.dao.PackageDAO;
import com.nownow.dao.TrackingEventDAO;
import com.nownow.model.Package;
import com.nownow.model.TrackingEvent;
import com.nownow.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Optional;

/**
 * Admin – edit a package's status and details.
 *
 * GET  /admin/packages/edit?id=123  → show edit form
 * POST /admin/packages/edit         → save changes
 * POST /admin/packages/delete       → delete package (action=delete)
 */
@WebServlet({"/admin/packages/edit", "/admin/packages/delete"})
public class EditPackageServlet extends HttpServlet {

    private final PackageDAO       packageDAO       = new PackageDAO();
    private final TrackingEventDAO trackingEventDAO = new TrackingEventDAO();

    // ── GET: show edit form ───────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User admin = requireAdmin(req, resp);
        if (admin == null) return;

        String idStr = req.getParameter("id");
        if (idStr == null || idStr.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
            return;
        }

        try {
            int pkgId = Integer.parseInt(idStr);
            Optional<Package> opt = packageDAO.findById(pkgId);
            if (opt.isEmpty()) {
                req.setAttribute("errorMessage", "Package not found.");
                req.getRequestDispatcher("/WEB-INF/views/admin/edit-package.jsp").forward(req, resp);
                return;
            }
            req.setAttribute("pkg",      opt.get());
            req.setAttribute("statuses", Package.Status.values());
            req.getRequestDispatcher("/WEB-INF/views/admin/edit-package.jsp").forward(req, resp);

        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
        } catch (SQLException e) {
            throw new ServletException("Failed to load package", e);
        }
    }

    // ── POST: save update OR delete ───────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User admin = requireAdmin(req, resp);
        if (admin == null) return;

        String path = req.getServletPath();

        // ── DELETE branch ─────────────────────────────────────────────
        if (path.endsWith("/delete")) {
            handleDelete(req, resp);
            return;
        }

        // ── UPDATE branch ─────────────────────────────────────────────
        String idStr         = req.getParameter("id");
        String statusParam   = req.getParameter("status");
        String recipientName = req.getParameter("recipientName");
        String deliveryAddr  = req.getParameter("deliveryAddress");
        String description   = req.getParameter("description");

        // Validation
        if (idStr == null || idStr.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
            return;
        }

        if (isEmpty(recipientName)) {
            req.setAttribute("errorMessage", "Recipient name is required.");
            repopulateAndForward(req, resp, idStr);
            return;
        }

        if (isEmpty(deliveryAddr)) {
            req.setAttribute("errorMessage", "Delivery address is required.");
            repopulateAndForward(req, resp, idStr);
            return;
        }

        if (recipientName.length() > 100) {
            req.setAttribute("errorMessage", "Recipient name must be 100 characters or fewer.");
            repopulateAndForward(req, resp, idStr);
            return;
        }

        if (deliveryAddr.length() > 255) {
            req.setAttribute("errorMessage", "Delivery address must be 255 characters or fewer.");
            repopulateAndForward(req, resp, idStr);
            return;
        }

        Package.Status newStatus;
        try {
            newStatus = Package.Status.valueOf(statusParam);
        } catch (IllegalArgumentException | NullPointerException e) {
            req.setAttribute("errorMessage", "Invalid status selected.");
            repopulateAndForward(req, resp, idStr);
            return;
        }

        try {
            int pkgId = Integer.parseInt(idStr);
            Optional<Package> opt = packageDAO.findById(pkgId);
            if (opt.isEmpty()) {
                resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
                return;
            }

            Package existing = opt.get();

            // Update status if changed
            if (existing.getStatus() != newStatus) {
                packageDAO.updateStatus(pkgId, newStatus);
                // Log a tracking event for the status change
                TrackingEvent event = new TrackingEvent(pkgId, newStatus.name(),
                        "Status manually updated to " + newStatus + " by admin.");
                trackingEventDAO.create(event);
            }

            // Update editable fields
            packageDAO.updateDetails(pkgId, recipientName.trim(), deliveryAddr.trim(),
                    description != null ? description.trim() : null);

            resp.sendRedirect(req.getContextPath() + "/admin/dashboard?updated=true");

        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
        } catch (SQLException e) {
            throw new ServletException("Failed to update package", e);
        }
    }

    // ── Delete handler ────────────────────────────────────────────────
    private void handleDelete(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {

        String idStr = req.getParameter("id");
        if (idStr == null || idStr.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
            return;
        }

        try {
            int pkgId = Integer.parseInt(idStr);
            packageDAO.delete(pkgId);
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard?deleted=true");
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
        } catch (SQLException e) {
            throw new ServletException("Failed to delete package", e);
        }
    }

    // ── Helpers ───────────────────────────────────────────────────────
    private void repopulateAndForward(HttpServletRequest req, HttpServletResponse resp, String idStr)
            throws ServletException, IOException {
        try {
            int pkgId = Integer.parseInt(idStr);
            packageDAO.findById(pkgId).ifPresent(p -> req.setAttribute("pkg", p));
        } catch (SQLException | NumberFormatException ignored) {}
        req.setAttribute("statuses", Package.Status.values());
        req.getRequestDispatcher("/WEB-INF/views/admin/edit-package.jsp").forward(req, resp);
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

    private boolean isEmpty(String s) {
        return s == null || s.isBlank();
    }
}

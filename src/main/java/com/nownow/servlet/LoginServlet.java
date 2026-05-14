package com.nownow.servlet;

import com.google.gson.Gson;
import com.nownow.dao.UserDAO;
import com.nownow.model.User;
import com.nownow.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Map;
import java.util.Optional;

/**
 * Handles GET (show login form) and POST (process login) for /login.
 *
 * <p>On successful authentication the authenticated {@link User} is stored in
 * the HTTP session as attribute {@code "loggedInUser"} and the client is
 * redirected to the appropriate dashboard based on the user's role.
 */
@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private static final Gson GSON = new Gson();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // If already logged in, redirect to dashboard
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("loggedInUser") != null) {
            redirectToDashboard(resp, (User) session.getAttribute("loggedInUser"));
            return;
        }
        req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String email    = req.getParameter("email");
        String password = req.getParameter("password");
        if (email == null) {
            email = req.getParameter("j_username");
        }
        if (password == null) {
            password = req.getParameter("j_password");
        }

        if (email == null || email.isBlank() || password == null || password.isBlank()) {
            handleLoginError(req, resp, "Email and password are required.", HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        String normalizedEmail = email.trim().toLowerCase();
        try {
            Optional<User> optUser = userDAO.findByEmail(normalizedEmail);
            if (optUser.isEmpty() || !PasswordUtil.verifyPassword(password, optUser.get().getPassword())) {
                handleLoginError(req, resp, "Invalid email or password.", HttpServletResponse.SC_UNAUTHORIZED);
                return;
            }
            User user = optUser.get();
            if (!PasswordUtil.isHashed(user.getPassword())) {
                userDAO.updatePassword(user.getId(), PasswordUtil.hashPassword(password));
            }
            HttpSession existingSession = req.getSession(false);
            if (existingSession != null) {
                existingSession.invalidate();
            }
            HttpSession session = req.getSession(true);
            session.setAttribute("loggedInUser", user);
            session.setMaxInactiveInterval(30 * 60); // 30 minutes
            String redirectUrl = dashboardUrl(req, user);
            if (wantsJson(req)) {
                writeJson(resp, HttpServletResponse.SC_OK, Map.of("redirectUrl", redirectUrl));
                return;
            }
            resp.sendRedirect(redirectUrl);
        } catch (SQLException e) {
            throw new ServletException("Error during login", e);
        }
    }

    private String dashboardUrl(HttpServletRequest req, User user) {
        String ctx = req.getContextPath();
        return switch (user.getRole()) {
            case ADMIN -> ctx + "/admin/dashboard";
            case DRIVER -> ctx + "/driver/dashboard";
            default -> ctx + "/customer/dashboard";
        };
    }

    private void handleLoginError(HttpServletRequest req, HttpServletResponse resp,
                                  String message, int status) throws ServletException, IOException {
        if (wantsJson(req)) {
            writeJson(resp, status, Map.of("error", message));
            return;
        }
        req.setAttribute("errorMessage", message);
        req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
    }

    private boolean wantsJson(HttpServletRequest req) {
        String accept = req.getHeader("Accept");
        String requestedWith = req.getHeader("X-Requested-With");
        return (accept != null && accept.contains("application/json"))
                || "XMLHttpRequest".equalsIgnoreCase(requestedWith);
    }

    private void writeJson(HttpServletResponse resp, int status, Object payload) throws IOException {
        resp.setStatus(status);
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        resp.getWriter().write(GSON.toJson(payload));
    }
}

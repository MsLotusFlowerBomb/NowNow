package com.nownow.servlet;

import com.nownow.dao.UserDAO;
import com.nownow.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
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

        if (email == null || email.isBlank() || password == null || password.isBlank()) {
            req.setAttribute("errorMessage", "Email and password are required.");
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
            return;
        }

        try {
            Optional<User> optUser = userDAO.findByEmail(email.trim().toLowerCase());
            if (optUser.isPresent() && password.equals(optUser.get().getPassword())) {
                User user = optUser.get();
                HttpSession session = req.getSession(true);
                session.setAttribute("loggedInUser", user);
                session.setMaxInactiveInterval(30 * 60); // 30 minutes
                redirectToDashboard(resp, user);
            } else {
                req.setAttribute("errorMessage", "Invalid email or password.");
                req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            throw new ServletException("Error during login", e);
        }
    }

    private void redirectToDashboard(HttpServletResponse resp, User user) throws IOException {
        String ctx = resp.encodeRedirectURL("");
        switch (user.getRole()) {
            case ADMIN    -> resp.sendRedirect(ctx + "admin/dashboard");
            case DRIVER   -> resp.sendRedirect(ctx + "driver/dashboard");
            default       -> resp.sendRedirect(ctx + "customer/dashboard");
        }
    }
}

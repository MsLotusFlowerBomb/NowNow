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
import java.util.List;

/**
 * Customer dashboard – overview of the customer's packages.
 */
@WebServlet("/customer/dashboard")
public class CustomerDashboardServlet extends HttpServlet {

    private final PackageDAO packageDAO = new PackageDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("loggedInUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("loggedInUser");

        try {
            List<Package> packages = packageDAO.findBySender(user.getId());
            req.setAttribute("packages", packages);
            req.getRequestDispatcher("/WEB-INF/views/customer/dashboard.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException("Failed to load customer dashboard", e);
        }
    }
}

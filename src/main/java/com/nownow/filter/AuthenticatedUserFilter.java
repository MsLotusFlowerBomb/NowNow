package com.nownow.filter;

import com.nownow.dao.UserDAO;
import com.nownow.model.User;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.security.Principal;
import java.sql.SQLException;
import java.util.Optional;

/**
 * Ensures container-authenticated users are reflected in the app session.
 */
@WebFilter("/*")
public class AuthenticatedUserFilter implements Filter {

    private UserDAO userDAO;

    @Override
    public void init(FilterConfig filterConfig) {
        userDAO = new UserDAO();
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        if (request instanceof HttpServletRequest req) {
            HttpSession session = req.getSession(false);
            if (session == null || session.getAttribute("loggedInUser") == null) {
                Principal principal = req.getUserPrincipal();
                if (principal != null) {
                    try {
                        Optional<User> user = userDAO.findByEmail(principal.getName().trim().toLowerCase());
                        if (user.isPresent()) {
                            session = req.getSession(true);
                            session.setAttribute("loggedInUser", user.get());
                            session.setMaxInactiveInterval(30 * 60);
                        } else {
                            req.logout();
                        }
                    } catch (SQLException | ServletException e) {
                        try {
                            req.logout();
                        } catch (ServletException ignored) {
                        }
                        throw new ServletException("Failed to load authenticated user", e);
                    }
                }
            }
        }
        chain.doFilter(request, response);
    }
}

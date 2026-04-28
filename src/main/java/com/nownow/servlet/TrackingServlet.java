package com.nownow.servlet;

import com.nownow.dao.PackageDAO;
import com.nownow.dao.TrackingEventDAO;
import com.nownow.model.Package;
import com.nownow.model.TrackingEvent;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Optional;

/**
 * Public tracking endpoint – no login required.
 *
 * <p>GET /track?number=NN-20240313-ABCD1234 returns the tracking history
 * for the given tracking number.
 */
@WebServlet("/track")
public class TrackingServlet extends HttpServlet {

    private final PackageDAO       packageDAO       = new PackageDAO();
    private final TrackingEventDAO trackingEventDAO = new TrackingEventDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String trackingNumber = req.getParameter("number");

        if (trackingNumber != null && !trackingNumber.isBlank()) {
            try {
                Optional<Package> optPkg = packageDAO.findByTrackingNumber(trackingNumber.trim().toUpperCase());

                if (optPkg.isPresent()) {
                    Package pkg = optPkg.get();
                    List<TrackingEvent> events = trackingEventDAO.findByPackageId(pkg.getId());
                    req.setAttribute("pkg", pkg);
                    req.setAttribute("events", events);
                } else {
                    req.setAttribute("notFound", true);
                }
            } catch (SQLException e) {
                throw new ServletException("Tracking lookup failed", e);
            }
        }

        req.getRequestDispatcher("/WEB-INF/views/track.jsp").forward(req, resp);
    }
}

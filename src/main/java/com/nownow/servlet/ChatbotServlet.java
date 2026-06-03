package com.nownow.servlet;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.nownow.dao.DriverDAO;
import com.nownow.model.Driver;
import java.util.List;

import com.nownow.dao.PackageDAO;
import com.nownow.dao.DeliveryDAO;
import com.nownow.model.Package;
import com.nownow.model.Delivery;
import java.util.Optional;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonSyntaxException;
import com.nownow.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.sql.SQLException;
import java.time.Duration;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Proxies chat messages to the Groq API (OpenAI-compatible format).
 *
 * <p>Add API_KEY as a context-param in web.xml.
 *
 * POST /chatbot
 *   Request : { "message": "text" }
 *   Response: { "reply": "text" }  OR  { "error": "message" }
 */
@WebServlet("/chatbot")
public class ChatbotServlet extends HttpServlet {

  private static final Gson   GSON        = new Gson();
  private static final String API_URL     = "https://api.groq.com/openai/v1/chat/completions";
  private static final String MODEL       = "openai/gpt-oss-120b"; // same model as your existing project
  private static final int    MAX_HISTORY = 12;                     // keep last 12 messages in session
  private static final String HIST_KEY    = "nn_chat_history";

  private HttpClient httpClient;

  @Override
  public void init() {
    httpClient = HttpClient.newBuilder()
      .connectTimeout(Duration.ofSeconds(10))
      .build();
  }

  // ── POST /chatbot ─────────────────────────────────────────────────
  @Override
  protected void doPost(HttpServletRequest req, HttpServletResponse resp)
    throws ServletException, IOException {

    resp.setContentType("application/json");
    resp.setCharacterEncoding("UTF-8");

    // 1. API key from web.xml  ──────────────────────────────────────
    String apiKey = getServletContext().getInitParameter("API_KEY");
    if (apiKey == null || apiKey.isBlank() || apiKey.startsWith("YOUR_")) {
      writeJson(resp, 503, Map.of("error",
            "Chatbot not configured. Add API_KEY to web.xml."));
      return;
    }

    // 2. Parse incoming JSON  ──────────────────────────────────────
    String body = req.getReader().lines().collect(Collectors.joining());
    JsonObject incoming;
    try {
      incoming = GSON.fromJson(body, JsonObject.class);
    } catch (JsonSyntaxException e) {
      writeJson(resp, 400, Map.of("error", "Invalid JSON."));
      return;
    }

    String userMessage = incoming.has("message")
      ? incoming.get("message").getAsString().trim()
      : "";
    // 1. Extract intents from the user's message
    String trackingNumber = extractTrackingNumber(userMessage);
    Double weightKg = extractWeight(userMessage);

    // Simple keyword check for Admin Dispatch intent
    String lowerMsg = userMessage.toLowerCase();
    boolean asksForDrivers = lowerMsg.contains("available driver") || 
      lowerMsg.contains("who is available") || 
      lowerMsg.contains("dispatch") ||
      lowerMsg.contains("available drivers");

    String extraContext = "";
    HttpSession session = req.getSession(true);
    User user = (User) session.getAttribute("loggedInUser");

    // ── ROUTER LOGIC ──────────────────────────────────────────

    if (trackingNumber != null) {
      // INTENT 1: Tracking a package

      if (user == null) {
        // SECURITY CHECK 1: User must be logged in
        extraContext = "SYSTEM FACT: The user is trying to track " + trackingNumber + 
          ", but they are NOT logged in. Politely tell them to log in at /login to view package statuses.";
      } else {
        try {
          PackageDAO packageDao = new PackageDAO();
          Optional<Package> pkgOpt = packageDao.findByTrackingNumber(trackingNumber);

          if (pkgOpt.isPresent()) {
            Package pkg = pkgOpt.get();

            // SECURITY CHECK 2: Role & Ownership Verification
            boolean isAdmin = "ADMIN".equals(user.getRole().name());
            boolean isDriver = "DRIVER".equals(user.getRole().name());
            boolean isSender = (pkg.getSenderId() == user.getId());

            if (!isAdmin && !isDriver && !isSender) {
              // They are logged in, but trying to snoop on someone else's package!
              extraContext = "SYSTEM FACT: The package exists, but it belongs to another account. " +
                "Tell the user they are not authorized to view this tracking number.";
            } else {
              // Authorized! Build the facts.
              StringBuilder facts = new StringBuilder();
              facts.append("SYSTEM FACT: Tracking number ").append(trackingNumber)
                .append(" is currently ").append(pkg.getStatus().name())
                .append(". It is addressed to ").append(pkg.getRecipientName())
                .append(" at ").append(pkg.getDeliveryAddress()).append(". ");

              DeliveryDAO deliveryDao = new DeliveryDAO();
              Optional<Delivery> delOpt = deliveryDao.findByPackageId(pkg.getId());
              if (delOpt.isPresent()) {
                facts.append("The assigned driver is ").append(delOpt.get().getDriverName()).append(". ");
              }
              extraContext = facts.toString();
            }
          } else {
            extraContext = "SYSTEM FACT: The tracking number " + trackingNumber + " does NOT exist in the database.";
          }
        } catch (SQLException e) {
          extraContext = "SYSTEM FACT: Database unavailable.";
        }
      }

    } else if (asksForDrivers && user != null && "ADMIN".equals(user.getRole().name())) {
      // INTENT 2: Admin Dispatch (Only works if user is an ADMIN)
      try {
        DriverDAO driverDao = new DriverDAO();
        List<Driver> availableDrivers = driverDao.findAvailable(); // Uses your existing method!

        if (availableDrivers.isEmpty()) {
          extraContext = "SYSTEM FACT: There are currently NO available drivers.";
        } else {
          StringBuilder drvStr = new StringBuilder("SYSTEM FACT: The following drivers are currently AVAILABLE:\n");
          for (Driver d : availableDrivers) {
            drvStr.append("- ").append(d.getDriverFullName())
              .append(" (").append(d.getVehicleType().name())
              .append(", Rating: ").append(d.getRating()).append(")\n");
          }
          extraContext = drvStr.toString();
        }
      } catch (SQLException e) {
        extraContext = "SYSTEM FACT: Database unavailable to fetch drivers.";
      }

    } else if (weightKg != null) {
      // INTENT 3: Shipping Estimator
      extraContext = "SYSTEM FACT: The user wants a shipping estimate for a " + weightKg + "kg package. " +
        "Rule: Shipping costs a base fee of R50, plus R15 per kilogram. " +
        "Do the math yourself and give them the exact estimated total in ZAR (R). Explain the breakdown briefly.";
    }

    // 3. Load history from session and proceed with the API call...
    JsonArray history = loadHistory(session);
    // 4. Append user message ───────────────────────────────────────
    JsonObject userMsg = new JsonObject();
    userMsg.addProperty("role",    "user");
    userMsg.addProperty("content", userMessage);
    history.add(userMsg);
    history = trim(history, MAX_HISTORY);

    // 5. Build Groq request body (same structure as your Chatbot.java) ──
    JsonObject root = new JsonObject();
    root.addProperty("model",       MODEL);
    root.addProperty("temperature", 1);
    root.add("messages",            buildMessages(req, history,extraContext));

    // 6. Call Groq API ─────────────────────────────────────────────
    try {
      HttpRequest apiReq = HttpRequest.newBuilder()
        .uri(URI.create(API_URL))
        .header("Authorization", "Bearer " + apiKey)
        .header("Content-Type",  "application/json")
        .timeout(Duration.ofSeconds(30))
        .POST(HttpRequest.BodyPublishers.ofString(GSON.toJson(root)))
        .build();

      HttpResponse<String> apiResp = httpClient.send(apiReq,
          HttpResponse.BodyHandlers.ofString());

      if (apiResp.statusCode() == 200) {
        // Same parsing logic as your parseChatbotResponse()
        String botResponse = parseChatbotResponse(apiResp.body());

        JsonObject botMsg = new JsonObject();
        botMsg.addProperty("role",    "assistant");
        botMsg.addProperty("content", botResponse);
        history.add(botMsg);

        // Save updated history back to session
        session.setAttribute(HIST_KEY, history.toString());

        writeJson(resp, 200, Map.of("reply", botResponse));
      } else {
        writeJson(resp, 502, Map.of("error",
              "API error " + apiResp.statusCode() + ": " + apiResp.body()));
      }

    } catch (InterruptedException e) {
      Thread.currentThread().interrupt();
      writeJson(resp, 503, Map.of("error", "Request timed out. Please try again."));
    } catch (Exception e) {
      throw new ServletException("Groq API call failed", e);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────

  /**
   * Extracts a weight in kg (e.g., "3kg", "2.5 kg") from user text.
   */
  private Double extractWeight(String text) {
    if (text == null) return null;
    // Looks for a number (with optional decimals) followed by "kg"
    Pattern pattern = Pattern.compile("(\\d+(?:\\.\\d+)?)\\s*kg", Pattern.CASE_INSENSITIVE);
    Matcher matcher = pattern.matcher(text);
    if (matcher.find()) {
      try {
        return Double.parseDouble(matcher.group(1));
      } catch (NumberFormatException e) {
        return null;
      }
    }
    return null;
  }

  /**
   * Prepends a system message then appends the full history.
   * The system role is how Groq / OpenAI-compatible APIs receive context.
   */
  private JsonArray buildMessages(HttpServletRequest req, JsonArray history, String extraContext) {
    JsonArray messages = new JsonArray();

    JsonObject systemMsg = new JsonObject();
    systemMsg.addProperty("role",    "system");
    systemMsg.addProperty("content", buildSystemPrompt(req, extraContext));
    messages.add(systemMsg);

    for (var el : history) {
      messages.add(el);
    }
    return messages;
  }

  /** Role-aware system prompt with dynamic facts injected. */
  private String buildSystemPrompt(HttpServletRequest req, String extraContext) {
    HttpSession session = req.getSession(false);
    User user = session != null ? (User) session.getAttribute("loggedInUser") : null;

    StringBuilder sb = new StringBuilder(
        "You are the NowNow Courier assistant — a helpful, concise AI inside a same-day " +
        "package delivery platform. Keep answers short and practical. " +
        "Package lifecycle: PENDING → ASSIGNED → PICKED_UP → IN_TRANSIT → DELIVERED (or CANCELLED). " +
        "Tracking numbers look like: NN-YYYYMMDD-XXXXXXXX. "
        );

    if (user != null) {
      sb.append("Logged-in user: '").append(user.getFullName())
        .append("', role: ").append(user.getRole().name()).append(". ");
    } else {
      sb.append("User is not logged in. Help with tracking or guide to /login or /register. ");
    }

    sb.append("Always be friendly and professional. Do not invent tracking data. ");

    // This is where the magic happens: injecting the DB data!
    if (extraContext != null && !extraContext.isEmpty()) {
      sb.append("\n\n").append(extraContext);
    }

    return sb.toString();
  }

  /**
   * Extracts a NowNow tracking number (e.g., NN-20240001) from user text.
   */
  private String extractTrackingNumber(String text) {
    if (text == null) return null;
    Pattern pattern = Pattern.compile("NN-[A-Z0-9\\-]+", Pattern.CASE_INSENSITIVE);
    Matcher matcher = pattern.matcher(text);
    if (matcher.find()) {
      return matcher.group().toUpperCase();
    }
    return null;
  }

  /** Identical logic to your existing parseChatbotResponse(). */
  private String parseChatbotResponse(String body) {
    try {
      JsonObject json    = GSON.fromJson(body, JsonObject.class);
      JsonArray  choices = json.getAsJsonArray("choices");
      if (choices != null && choices.size() > 0) {
        return choices.get(0).getAsJsonObject()
          .getAsJsonObject("message")
          .get("content").getAsString();
      }
      return "No response from the chatbot.";
    } catch (Exception e) {
      e.printStackTrace();
      return "Error parsing chatbot response.";
    }
  }

  /** Load conversation history stored as JSON string in the HTTP session. */
  private JsonArray loadHistory(HttpSession session) {
    String stored = (String) session.getAttribute(HIST_KEY);
    if (stored == null || stored.isBlank()) return new JsonArray();
    try {
      return GSON.fromJson(stored, JsonArray.class);
    } catch (Exception e) {
      return new JsonArray();
    }
  }

  /** Keep only the most recent {@code max} messages. */
  private JsonArray trim(JsonArray arr, int max) {
    if (arr.size() <= max) return arr;
    JsonArray out = new JsonArray();
    for (int i = arr.size() - max; i < arr.size(); i++) out.add(arr.get(i));
    return out;
  }

  private void writeJson(HttpServletResponse resp, int status, Object payload) throws IOException {
    resp.setStatus(status);
    resp.getWriter().write(GSON.toJson(payload));
  }
}

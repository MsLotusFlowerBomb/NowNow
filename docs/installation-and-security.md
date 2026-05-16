# Installation, Deployment & Security Guide

## 1. Security Information

The application uses GlassFish Container-Managed Security (Form-Based Authentication) via the `file` realm. 

### System Roles
* `ADMIN`: Full access to all dashboards, package assignments, and reporting.
* `DRIVER`: Access to driver dashboard to manage active deliveries.
* `CUSTOMER`: Access to customer dashboard to create and track packages.

### Demo Credentials
To log in, the following users exist in the database and **must** also be added to the GlassFish `file` realm. 

| User | Role | Email | Password |
|------|------|-------|----------|
| Alice Admin | `ADMIN` | `admin@nownow.com` | `Admin@1234` |
| Carol Customer | `CUSTOMER` | `carol@example.com` | `Carol@1234` |
| Dan Deliverer | `DRIVER` | `dan@nownow.com` | `Driver@1234` |

---

## 2. Deployment Instructions (3-Tiered Setup)

To meet the 3-tiered architecture requirement, the Database (Tier 3) runs on a separate machine from the Application Server (Tier 2).

### Step 1: Database Setup (Machine A)
1. Install MySQL 8.x on the database server.
2. Execute `database/schema.sql` to create the tables.
3. Execute `database/seed-data.sql` to populate the 10+ required records.
4. Ensure MySQL is configured to accept remote connections (bind-address updated).

### Step 2: Application Configuration (Machine B)
1. Open `src/main/resources/db.properties`.
2. Update the `db.url` to point to Machine A's IP address:
   `db.url=jdbc:mysql://<MACHINE_A_IP>:3306/nownow_db`
3. Build the application into a `.war` file:
   `mvn clean package`

### Step 3: GlassFish Server Setup (Machine B)
1. Start the GlassFish domain: `asadmin start-domain`
2. Open the Admin Console (`http://localhost:4848`).
3. **Configure Security:** Navigate to `Configuration -> server-config -> Security -> Realms -> file -> Manage Users`. Add the three demo users listed above, assigning them their exact group (`ADMIN`, `DRIVER`, or `CUSTOMER`).
4. **Deploy Application:** Navigate to `Applications -> Deploy`. Upload `target/nownow.war` and deploy.
5. The application is now accessible at `http://<MACHINE_B_IP>:8080/nownow`.

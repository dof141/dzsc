package com.ecommerce.config;

import org.springframework.context.annotation.Configuration;
import javax.sql.DataSource;
import java.sql.*;

@Configuration
public class RlsConfig {

    private final DataSource dataSource;

    public RlsConfig(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    /**
     * Set the admin context for DBMS_RLS.
     * Call this at the start of each request to set which admin is making the request.
     */
    public void setCurrentAdmin(Long adminId) {
        try (Connection conn = dataSource.getConnection();
             CallableStatement stmt = conn.prepareCall(
                 "BEGIN ECOMMERCE_CTX_PKG.set_admin_id(?); END;")) {
            stmt.setLong(1, adminId);
            stmt.execute();
        } catch (SQLException e) {
            // Log error but don't throw - RLS may not be fully configured
            System.err.println("Warning: Failed to set admin context: " + e.getMessage());
        }
    }
}

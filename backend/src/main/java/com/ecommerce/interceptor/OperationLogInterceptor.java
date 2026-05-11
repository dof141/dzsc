package com.ecommerce.interceptor;

import com.ecommerce.entity.AdminUser;
import com.ecommerce.mapper.AuditLogMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@Component
public class OperationLogInterceptor implements HandlerInterceptor {

    @Autowired
    private AuditLogMapper auditLogMapper;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        // Skip OPTIONS requests
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            return true;
        }

        // Skip login/logout requests
        String uri = request.getRequestURI();
        if (uri.contains("/auth/login") || uri.contains("/auth/logout")) {
            return true;
        }

        // Get current user
        HttpSession session = request.getSession(false);
        if (session == null) {
            return true;
        }

        AdminUser user = (AdminUser) session.getAttribute("currentUser");
        if (user == null) {
            return true;
        }

        // Log operation
        try {
            String method = request.getMethod();
            String operation = getOperationType(method);
            String detail = method + " " + uri;

            auditLogMapper.insertOperationLog(
                user.getAdminId(),
                uri,
                operation,
                detail,
                request.getRemoteAddr()
            );
        } catch (Exception e) {
            // Don't block request if logging fails
        }

        return true;
    }

    private String getOperationType(String method) {
        switch (method.toUpperCase()) {
            case "GET": return "QUERY";
            case "POST": return "CREATE";
            case "PUT": return "UPDATE";
            case "DELETE": return "DELETE";
            default: return "OTHER";
        }
    }
}

package com.ecommerce.controller;

import com.ecommerce.common.Result;
import com.ecommerce.config.RlsConfig;
import com.ecommerce.entity.AdminUser;
import com.ecommerce.mapper.AdminCategoryMapper;
import com.ecommerce.service.AdminUserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.util.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private AdminUserService adminUserService;

    @Autowired
    private AdminCategoryMapper adminCategoryMapper;

    @Autowired
    private RlsConfig rlsConfig;

    @PostMapping("/login")
    public Result<AdminUser> login(@RequestBody Map<String, String> body, HttpSession session) {
        String username = body.get("username");
        String password = body.get("password");

        try {
            AdminUser user = adminUserService.login(username, password);
            session.setAttribute("currentUser", user);
            rlsConfig.setCurrentAdmin(user.getAdminId());
            return Result.success(user);
        } catch (RuntimeException e) {
            return Result.error(e.getMessage());
        }
    }

    @PostMapping("/logout")
    public Result<Void> logout(HttpSession session) {
        session.invalidate();
        return Result.success(null);
    }

    @GetMapping("/info")
    public Result<AdminUser> info(HttpSession session) {
        AdminUser user = (AdminUser) session.getAttribute("currentUser");
        if (user == null) {
            return Result.error(401, "未登录");
        }
        return Result.success(user);
    }

    @PutMapping("/password")
    public Result<Void> updatePassword(@RequestBody Map<String, String> body, HttpSession session) {
        AdminUser user = (AdminUser) session.getAttribute("currentUser");
        String oldPwd = body.get("oldPwd");
        String newPwd = body.get("newPwd");

        try {
            adminUserService.updatePassword(user.getAdminId(), oldPwd, newPwd);
            return Result.success(null);
        } catch (RuntimeException e) {
            return Result.error(e.getMessage());
        }
    }

    @PutMapping("/profile")
    public Result<Void> updateProfile(@RequestBody Map<String, String> body, HttpSession session) {
        AdminUser user = (AdminUser) session.getAttribute("currentUser");
        String realName = body.get("realName");
        String avatar = body.get("avatar");

        try {
            adminUserService.updateProfile(user.getAdminId(), realName, avatar);
            user.setRealName(realName);
            user.setAvatar(avatar);
            session.setAttribute("currentUser", user);
            return Result.success(null);
        } catch (RuntimeException e) {
            return Result.error(e.getMessage());
        }
    }

    @GetMapping("/permissions")
    public Result<Map<String, Object>> getPermissions(HttpSession session) {
        AdminUser user = (AdminUser) session.getAttribute("currentUser");
        if (user == null) {
            return Result.error(401, "未登录");
        }

        Map<String, Object> permissions = new HashMap<>();

        // Category permissions
        List<Long> categoryIds = adminCategoryMapper.selectCategoryIdsByAdminId(user.getAdminId());
        permissions.put("categoryIds", categoryIds);

        // Feature permissions based on role
        List<String> features = new ArrayList<>();
        if ("SUPER_ADMIN".equals(user.getRole())) {
            features.addAll(Arrays.asList(
                "dashboard", "products", "categories", "orders",
                "inventory", "payments", "reports", "audit", "admin-users", "profile"
            ));
        } else {
            features.addAll(Arrays.asList(
                "dashboard", "products", "categories", "orders",
                "inventory", "payments", "reports", "audit", "profile"
            ));
        }
        permissions.put("features", features);
        permissions.put("role", user.getRole());

        return Result.success(permissions);
    }
}

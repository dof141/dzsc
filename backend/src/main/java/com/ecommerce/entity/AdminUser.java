package com.ecommerce.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("ADMIN_USER")
public class AdminUser {

    @TableId(value = "ADMIN_ID", type = IdType.INPUT)
    private Long adminId;

    @TableField("USERNAME")
    private String username;

    @TableField("PASSWORD")
    private String password;

    @TableField("REAL_NAME")
    private String realName;

    @TableField("ROLE")
    private String role;

    @TableField("STATUS")
    private Integer status;

    @TableField("AVATAR")
    private String avatar;

    @TableField("CREATED_AT")
    private LocalDateTime createdAt;

    @TableField("UPDATED_AT")
    private LocalDateTime updatedAt;

    public static AdminUser fromEntity(AdminUser user) {
        if (user == null) return null;
        AdminUser safe = new AdminUser();
        safe.setAdminId(user.getAdminId());
        safe.setUsername(user.getUsername());
        safe.setRealName(user.getRealName());
        safe.setRole(user.getRole());
        safe.setStatus(user.getStatus());
        safe.setAvatar(user.getAvatar());
        safe.setCreatedAt(user.getCreatedAt());
        safe.setUpdatedAt(user.getUpdatedAt());
        return safe;
    }
}

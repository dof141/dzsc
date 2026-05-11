package com.ecommerce.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("AUDIT_LOG")
public class AuditLog {
    @TableId(value = "AUDIT_ID", type = IdType.AUTO)
    private Long auditId;
    private String tableName;
    private Long recordId;
    private String operation;
    private String oldValue;
    private String newValue;
    private LocalDateTime operatedAt;
    private String operatedBy;
}

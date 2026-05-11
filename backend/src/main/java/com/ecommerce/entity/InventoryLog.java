package com.ecommerce.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("INVENTORY_LOG")
public class InventoryLog {
    @TableId(value = "LOG_ID", type = IdType.AUTO)
    private Long logId;
    private Long inventoryId;
    private Integer oldQty;
    private Integer newQty;
    private String changeType;
    private LocalDateTime changedAt;
    private String changedBy;

    @TableField(exist = false)
    private String productName;
}

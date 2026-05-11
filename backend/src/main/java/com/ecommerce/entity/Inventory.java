package com.ecommerce.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("INVENTORY")
public class Inventory {
    @TableId(value = "INVENTORY_ID", type = IdType.AUTO)
    private Long inventoryId;
    private Long productId;
    private Integer quantity;
    private Integer safetyStock;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    @TableField(exist = false)
    private String productName;
    @TableField(exist = false)
    private String productPrice;
}

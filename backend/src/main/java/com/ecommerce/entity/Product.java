package com.ecommerce.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("PRODUCT")
public class Product {
    @TableId(value = "PRODUCT_ID", type = IdType.AUTO)
    private Long productId;
    private Long categoryId;
    private String name;
    private BigDecimal price;
    private String unit;
    private Integer status;
    private String description;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    @TableField(exist = false)
    private String categoryName;
}

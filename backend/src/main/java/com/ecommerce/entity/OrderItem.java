package com.ecommerce.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.math.BigDecimal;

@Data
@TableName("ORDER_ITEM")
public class OrderItem {
    @TableId(value = "ITEM_ID", type = IdType.AUTO)
    private Long itemId;
    private Long orderId;
    private Long productId;
    private Integer quantity;
    private BigDecimal unitPrice;
    @TableField(exist = false)
    private BigDecimal subtotal;

    @TableField(exist = false)
    private String productName;
}

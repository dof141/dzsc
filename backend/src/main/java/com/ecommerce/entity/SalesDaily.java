package com.ecommerce.entity;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;

@Data
public class SalesDaily {
    private LocalDate statDate;
    private Long categoryId;
    private String categoryName;
    private Long orderCount;
    private BigDecimal totalAmount;
    private Long totalQuantity;
}

package com.ecommerce.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;

@Data
@TableName("CATEGORY")
public class Category {
    @TableId(value = "CATEGORY_ID", type = IdType.AUTO)
    private Long categoryId;
    private String name;
    private Long parentId;
    @TableField("CATEGORY_LEVEL")
    private Integer categoryLevel;
    private Integer sortOrder;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(exist = false)
    private List<Category> children;
}

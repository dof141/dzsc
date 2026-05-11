package com.ecommerce.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.ecommerce.entity.Category;
import org.apache.ibatis.annotations.*;
import java.util.List;

@Mapper
public interface CategoryMapper extends BaseMapper<Category> {
    // CONNECT BY hierarchical query for category tree
    @Select("SELECT category_id, name, parent_id, category_level, sort_order, created_at " +
            "FROM category START WITH parent_id IS NULL " +
            "CONNECT BY PRIOR category_id = parent_id " +
            "ORDER SIBLINGS BY sort_order")
    List<Category> selectCategoryTree();
}

package com.ecommerce.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.ecommerce.entity.Product;
import org.apache.ibatis.annotations.*;

@Mapper
public interface ProductMapper extends BaseMapper<Product> {
    @Select("<script>" +
            "SELECT p.*, c.name as category_name FROM product p " +
            "LEFT JOIN category c ON p.category_id = c.category_id " +
            "<where>" +
            "  <if test='name != null and name != \"\"'> AND p.name LIKE '%' || #{name} || '%' </if>" +
            "  <if test='categoryId != null'> AND p.category_id = #{categoryId} </if>" +
            "  <if test='status != null'> AND p.status = #{status} </if>" +
            "</where>" +
            " ORDER BY p.created_at DESC" +
            "</script>")
    IPage<Product> selectProductPage(Page<Product> page,
                                      @Param("name") String name,
                                      @Param("categoryId") Long categoryId,
                                      @Param("status") Integer status);
}

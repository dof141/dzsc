package com.ecommerce.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.ecommerce.entity.AdminCategory;
import org.apache.ibatis.annotations.*;

import java.util.List;

@Mapper
public interface AdminCategoryMapper extends BaseMapper<AdminCategory> {

    @Delete("DELETE FROM admin_category WHERE admin_id = #{adminId}")
    void deleteByAdminId(@Param("adminId") Long adminId);

    @Insert("INSERT INTO admin_category (admin_id, category_id) VALUES (#{adminId}, #{categoryId})")
    void insertAdminCategory(@Param("adminId") Long adminId, @Param("categoryId") Long categoryId);

    @Select("SELECT category_id FROM admin_category WHERE admin_id = #{adminId}")
    List<Long> selectCategoryIdsByAdminId(@Param("adminId") Long adminId);
}

package com.ecommerce.service.impl;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.ecommerce.entity.AuditLog;
import com.ecommerce.mapper.AuditLogMapper;
import com.ecommerce.service.AuditService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@Service
public class AuditServiceImpl implements AuditService {

    @Autowired
    private AuditLogMapper auditLogMapper;

    // Map table names to their ID column names
    private static final Map<String, String> TABLE_ID_MAP = new HashMap<>();
    static {
        TABLE_ID_MAP.put("PRODUCT", "PRODUCT_ID");
        TABLE_ID_MAP.put("CATEGORY", "CATEGORY_ID");
        TABLE_ID_MAP.put("ORDER_TABLE", "ORDER_ID");
        TABLE_ID_MAP.put("INVENTORY", "INVENTORY_ID");
        TABLE_ID_MAP.put("PAYMENT", "PAYMENT_ID");
    }

    @Override
    public IPage<AuditLog> getAuditPage(int page, int size, String tableName, String operation,
                                         LocalDateTime startTime, LocalDateTime endTime) {
        return auditLogMapper.selectAuditPage(new Page<>(page, size), tableName, operation, startTime, endTime);
    }

    @Override
    public Map<String, Object> flashbackCompare(String tableName, Long recordId, LocalDateTime flashTime) {
        String idColumn = TABLE_ID_MAP.get(tableName.toUpperCase());
        if (idColumn == null) {
            throw new RuntimeException("不支持的表: " + tableName);
        }

        Map<String, Object> result = new HashMap<>();
        // Current data
        result.put("current", auditLogMapper.getCurrentData(tableName, idColumn, recordId));
        // Historical data via Flashback
        try {
            result.put("historical", auditLogMapper.flashbackQuery(tableName, flashTime, idColumn, recordId));
        } catch (Exception e) {
            result.put("historical", null);
            result.put("flashbackError", "闪回查询失败: " + e.getMessage() + " (可能超出撤销保留时间)");
        }
        result.put("flashTime", flashTime);
        result.put("tableName", tableName);
        result.put("recordId", recordId);
        return result;
    }
}

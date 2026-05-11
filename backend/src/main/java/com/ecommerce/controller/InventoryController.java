package com.ecommerce.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.ecommerce.common.Result;
import com.ecommerce.entity.Inventory;
import com.ecommerce.entity.InventoryLog;
import com.ecommerce.service.InventoryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

@RestController
@RequestMapping("/api/inventory")
public class InventoryController {
    @Autowired
    private InventoryService inventoryService;

    @GetMapping
    public Result<IPage<Inventory>> page(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        return Result.success(inventoryService.getInventoryPage(page, size));
    }

    @GetMapping("/low-stock")
    public Result<IPage<Inventory>> lowStock(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        return Result.success(inventoryService.getLowStockPage(page, size));
    }

    @PostMapping("/in")
    public Result<Void> stockIn(@RequestBody Map<String, Object> params) {
        Long productId = Long.valueOf(params.get("productId").toString());
        Integer quantity = Integer.valueOf(params.get("quantity").toString());
        inventoryService.stockIn(productId, quantity);
        return Result.success(null);
    }

    @PostMapping("/out")
    public Result<Void> stockOut(@RequestBody Map<String, Object> params) {
        Long productId = Long.valueOf(params.get("productId").toString());
        Integer quantity = Integer.valueOf(params.get("quantity").toString());
        inventoryService.stockOut(productId, quantity);
        return Result.success(null);
    }

    @GetMapping("/logs")
    public Result<IPage<InventoryLog>> logs(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        return Result.success(inventoryService.getLogPage(page, size));
    }
}

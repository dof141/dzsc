package com.ecommerce.service.impl;

import com.ecommerce.entity.DashboardStats;
import com.ecommerce.mapper.DashboardMapper;
import com.ecommerce.service.DashboardService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class DashboardServiceImpl implements DashboardService {

    @Autowired
    private DashboardMapper dashboardMapper;

    @Override
    public DashboardStats getDashboardStats() {
        DashboardStats stats = new DashboardStats();
        stats.setTodaySales(dashboardMapper.getTodaySales());
        stats.setTodayOrders(dashboardMapper.getTodayOrders());
        stats.setMonthSales(dashboardMapper.getMonthSales());
        stats.setMonthOrders(dashboardMapper.getMonthOrders());
        stats.setTotalProducts(dashboardMapper.getTotalProducts());
        stats.setLowStockCount(dashboardMapper.getLowStockCount());
        stats.setSalesTrend(dashboardMapper.getSalesTrend());
        stats.setCategorySales(dashboardMapper.getCategorySales());
        stats.setOrderStatusDist(dashboardMapper.getOrderStatusDist());
        stats.setLowStockList(dashboardMapper.getLowStockList());
        return stats;
    }
}

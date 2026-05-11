package com.ecommerce.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.ecommerce.entity.OrderTable;

public interface OrderService extends IService<OrderTable> {
    IPage<OrderTable> getOrderPage(int page, int size, String orderNo, String status);

    OrderTable getById(Long id);

    Long createOrder(OrderTable order);
    void cancelOrder(Long orderId);
    void updateStatus(Long orderId, String status);
}

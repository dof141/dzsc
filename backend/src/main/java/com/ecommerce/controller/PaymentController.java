package com.ecommerce.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.ecommerce.common.Result;
import com.ecommerce.entity.Payment;
import com.ecommerce.service.PaymentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/payments")
public class PaymentController {
    @Autowired
    private PaymentService paymentService;

    @GetMapping
    public Result<IPage<Payment>> page(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) String orderNo,
            @RequestParam(required = false) String status) {
        return Result.success(paymentService.getPaymentPage(page, size, orderNo, status));
    }

    @PostMapping("/notify")
    public Result<Void> notifyPayment(@RequestBody Payment payment) {
        paymentService.processPayment(payment);
        return Result.success(null);
    }

    @PostMapping("/{id}/refund")
    public Result<Void> refund(@PathVariable Long id) {
        paymentService.refundPayment(id);
        return Result.success(null);
    }
}

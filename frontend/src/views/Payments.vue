<template>
  <el-card class="page-card">
    <template #header>
      <div class="card-header">
        <span>支付管理</span>
        <el-button type="primary" @click="openPayDialog">模拟支付</el-button>
      </div>
    </template>

    <!-- Search Bar -->
    <el-form :inline="true" :model="searchForm" class="search-form">
      <el-form-item label="订单编号">
        <el-input v-model="searchForm.orderNo" placeholder="请输入订单编号" clearable @clear="loadPayments" />
      </el-form-item>
      <el-form-item label="支付状态">
        <el-select v-model="searchForm.status" placeholder="全部" clearable @clear="loadPayments">
          <el-option label="全部" value="" />
          <el-option label="待支付" value="PENDING" />
          <el-option label="成功" value="SUCCESS" />
          <el-option label="失败" value="FAILED" />
          <el-option label="已退款" value="REFUNDED" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="loadPayments">查询</el-button>
        <el-button @click="resetSearch">重置</el-button>
      </el-form-item>
    </el-form>

    <!-- Payment List Table -->
    <el-table
      :data="paymentList"
      stripe
      border
      v-loading="loading"
      style="width: 100%"
    >
      <el-table-column prop="orderNo" label="订单编号" min-width="160" />
      <el-table-column label="支付金额" width="120" align="right">
        <template #default="{ row }">
          {{ formatAmount(row.amount) }}
        </template>
      </el-table-column>
      <el-table-column label="支付方式" width="120" align="center">
        <template #default="{ row }">
          <el-tag v-if="row.paymentMethod === 'ALIPAY'" type="primary">支付宝</el-tag>
          <el-tag v-else-if="row.paymentMethod === 'WECHAT'" type="success">微信</el-tag>
          <el-tag v-else-if="row.paymentMethod === 'BANK'" type="info">银行卡</el-tag>
          <span v-else>{{ row.paymentMethod }}</span>
        </template>
      </el-table-column>
      <el-table-column label="支付状态" width="120" align="center">
        <template #default="{ row }">
          <el-tag v-if="row.status === 'PENDING'" type="warning">待支付</el-tag>
          <el-tag v-else-if="row.status === 'SUCCESS'" type="success">成功</el-tag>
          <el-tag v-else-if="row.status === 'FAILED'" type="danger">失败</el-tag>
          <el-tag v-else-if="row.status === 'REFUNDED'" type="info">已退款</el-tag>
          <el-tag v-else type="info">{{ row.status }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="transactionNo" label="交易流水号" min-width="200" />
      <el-table-column label="支付时间" width="180" align="center">
        <template #default="{ row }">
          {{ formatDate(row.paymentTime) }}
        </template>
      </el-table-column>
      <el-table-column label="操作" width="120" align="center" fixed="right">
        <template #default="{ row }">
          <el-button
            v-if="row.status === 'SUCCESS'"
            type="danger"
            size="small"
            @click="handleRefund(row)"
          >
            退款
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- Pagination -->
    <div class="pagination-wrapper">
      <el-pagination
        v-model:current-page="pagination.page"
        v-model:page-size="pagination.size"
        :page-sizes="[10, 20, 50]"
        :total="pagination.total"
        layout="total, sizes, prev, pager, next, jumper"
        @size-change="loadPayments"
        @current-change="loadPayments"
      />
    </div>

    <!-- Simulate Payment Dialog -->
    <el-dialog v-model="payDialogVisible" title="模拟支付" width="450px" destroy-on-close>
      <el-form :model="payForm" label-width="100px">
        <el-form-item label="选择订单" required>
          <el-select
            v-model="payForm.orderId"
            placeholder="请选择待支付订单"
            style="width: 100%"
            filterable
          >
            <el-option
              v-for="order in pendingOrders"
              :key="order.orderId"
              :label="order.orderNo + ' (¥' + order.totalAmount + ')'"
              :value="order.orderId"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="支付金额" required>
          <el-input-number
            v-model="payForm.amount"
            :min="0.01"
            :precision="2"
            :step="10"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="支付方式" required>
          <el-radio-group v-model="payForm.paymentMethod">
            <el-radio value="ALIPAY">支付宝</el-radio>
            <el-radio value="WECHAT">微信</el-radio>
            <el-radio value="BANK">银行卡</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="payDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="paySubmitting" @click="submitPayment">确认支付</el-button>
      </template>
    </el-dialog>
  </el-card>
</template>

<script setup>
import { ref, reactive, inject, watch, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getPayments, notifyPayment, refundPayment, getOrders } from '@/api/modules'

// 管理员切换时刷新数据
const refreshKey = inject('refreshKey', ref(0))
watch(refreshKey, () => loadPayments())

// Payment list state
const paymentList = ref([])
const loading = ref(false)
const pagination = reactive({ page: 1, size: 10, total: 0 })

// Search form
const searchForm = reactive({
  orderNo: '',
  status: ''
})

// Payment dialog state
const payDialogVisible = ref(false)
const paySubmitting = ref(false)
const pendingOrders = ref([])
const payForm = reactive({
  orderId: null,
  amount: 0,
  paymentMethod: 'ALIPAY'
})

// Load payment list
const loadPayments = async () => {
  loading.value = true
  try {
    const res = await getPayments({
      page: pagination.page,
      size: pagination.size,
      orderNo: searchForm.orderNo || undefined,
      status: searchForm.status || undefined
    })
    paymentList.value = res.data.records
    pagination.total = res.data.total
  } catch (e) {
    // error handled by interceptor
  } finally {
    loading.value = false
  }
}

// Reset search
const resetSearch = () => {
  searchForm.orderNo = ''
  searchForm.status = ''
  pagination.page = 1
  loadPayments()
}

// Open payment dialog
const openPayDialog = async () => {
  // Load pending orders
  try {
    const res = await getOrders({ page: 1, size: 100, status: 'PENDING' })
    pendingOrders.value = res.data.records || []
  } catch (e) {
    pendingOrders.value = []
  }
  payForm.orderId = null
  payForm.amount = 0
  payForm.paymentMethod = 'ALIPAY'
  payDialogVisible.value = true
}

// Auto-fill amount when order is selected
const onOrderSelect = () => {
  const order = pendingOrders.value.find(o => o.orderId === payForm.orderId)
  if (order) {
    payForm.amount = Number(order.totalAmount)
  }
}

// Watch order selection to auto-fill amount
watch(() => payForm.orderId, () => {
  onOrderSelect()
})

// Submit payment
const submitPayment = async () => {
  if (!payForm.orderId) {
    ElMessage.warning('请选择订单')
    return
  }
  if (!payForm.amount || payForm.amount <= 0) {
    ElMessage.warning('请输入有效金额')
    return
  }
  paySubmitting.value = true
  try {
    await notifyPayment({
      orderId: payForm.orderId,
      amount: payForm.amount,
      paymentMethod: payForm.paymentMethod
    })
    ElMessage.success('支付成功')
    payDialogVisible.value = false
    loadPayments()
  } catch (e) {
    // error handled by interceptor
  } finally {
    paySubmitting.value = false
  }
}

// Handle refund
const handleRefund = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确认对订单 ${row.orderNo} 的支付 (¥${row.amount}) 进行退款吗？`,
      '退款确认',
      { type: 'warning' }
    )
    await refundPayment(row.paymentId)
    ElMessage.success('退款成功')
    loadPayments()
  } catch (e) {
    if (e !== 'cancel') {
      // error handled by interceptor
    }
  }
}

// Format amount to currency
const formatAmount = (amount) => {
  if (amount == null) return ''
  return '¥' + Number(amount).toFixed(2)
}

// Format date
const formatDate = (dateStr) => {
  if (!dateStr) return ''
  return dateStr.replace('T', ' ').substring(0, 19)
}

onMounted(() => {
  loadPayments()
})
</script>

<style scoped>
.page-card {
  height: 100%;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.search-form {
  margin-bottom: 16px;
}

.pagination-wrapper {
  display: flex;
  justify-content: flex-end;
  margin-top: 16px;
}
</style>

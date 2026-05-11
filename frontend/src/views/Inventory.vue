<template>
  <el-card class="page-card">
    <template #header>
      <div class="card-header">
        <span>库存管理</span>
      </div>
    </template>

    <el-tabs v-model="activeTab">
      <!-- Tab 1: Inventory List -->
      <el-tab-pane label="库存列表" name="list">
        <el-table
          :data="inventoryList"
          stripe
          border
          v-loading="inventoryLoading"
          :row-class-name="tableRowClassName"
          style="width: 100%"
        >
          <el-table-column prop="productName" label="商品名称" min-width="150" />
          <el-table-column prop="quantity" label="当前库存" width="120" align="center" />
          <el-table-column prop="safetyStock" label="安全库存" width="120" align="center" />
          <el-table-column label="库存状态" width="120" align="center">
            <template #default="{ row }">
              <el-tag v-if="row.quantity >= row.safetyStock" type="success">正常</el-tag>
              <el-tag v-else type="danger">库存不足</el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="productPrice" label="商品单价" width="120" align="center" />
          <el-table-column label="更新时间" width="180" align="center">
            <template #default="{ row }">
              {{ formatDate(row.updatedAt) }}
            </template>
          </el-table-column>
          <el-table-column label="操作" width="200" align="center" fixed="right">
            <template #default="{ row }">
              <el-button type="primary" size="small" @click="openStockIn(row)">入库</el-button>
              <el-button type="warning" size="small" @click="openStockOut(row)">出库</el-button>
            </template>
          </el-table-column>
        </el-table>

        <div class="pagination-wrapper">
          <el-pagination
            v-model:current-page="inventoryPagination.page"
            v-model:page-size="inventoryPagination.size"
            :page-sizes="[10, 20, 50]"
            :total="inventoryPagination.total"
            layout="total, sizes, prev, pager, next, jumper"
            @size-change="loadInventory"
            @current-change="loadInventory"
          />
        </div>
      </el-tab-pane>

      <!-- Tab 2: Change Logs -->
      <el-tab-pane label="变更日志" name="logs">
        <el-table
          :data="logList"
          stripe
          border
          v-loading="logLoading"
          style="width: 100%"
        >
          <el-table-column prop="productName" label="商品名称" min-width="150" />
          <el-table-column prop="oldQty" label="变更前数量" width="120" align="center" />
          <el-table-column prop="newQty" label="变更后数量" width="120" align="center" />
          <el-table-column label="变更类型" width="120" align="center">
            <template #default="{ row }">
              <el-tag v-if="row.changeType === 'IN'" type="success">入库</el-tag>
              <el-tag v-else-if="row.changeType === 'OUT'" type="danger">出库</el-tag>
              <el-tag v-else type="warning">调整</el-tag>
            </template>
          </el-table-column>
          <el-table-column label="变更时间" width="180" align="center">
            <template #default="{ row }">
              {{ formatDate(row.changedAt) }}
            </template>
          </el-table-column>
          <el-table-column prop="changedBy" label="操作人" width="120" align="center" />
        </el-table>

        <div class="pagination-wrapper">
          <el-pagination
            v-model:current-page="logPagination.page"
            v-model:page-size="logPagination.size"
            :page-sizes="[10, 20, 50]"
            :total="logPagination.total"
            layout="total, sizes, prev, pager, next, jumper"
            @size-change="loadLogs"
            @current-change="loadLogs"
          />
        </div>
      </el-tab-pane>
    </el-tabs>

    <!-- Stock In Dialog -->
    <el-dialog v-model="stockInVisible" title="入库" width="400px" destroy-on-close>
      <el-form :model="stockForm" label-width="80px">
        <el-form-item label="商品名称">
          <el-input :model-value="stockForm.productName" disabled />
        </el-form-item>
        <el-form-item label="当前库存">
          <el-input :model-value="stockForm.currentQty" disabled />
        </el-form-item>
        <el-form-item label="入库数量" required>
          <el-input-number v-model="stockForm.quantity" :min="1" :max="99999" style="width: 100%" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="stockInVisible = false">取消</el-button>
        <el-button type="primary" :loading="stockSubmitting" @click="submitStockIn">确定</el-button>
      </template>
    </el-dialog>

    <!-- Stock Out Dialog -->
    <el-dialog v-model="stockOutVisible" title="出库" width="400px" destroy-on-close>
      <el-form :model="stockForm" label-width="80px">
        <el-form-item label="商品名称">
          <el-input :model-value="stockForm.productName" disabled />
        </el-form-item>
        <el-form-item label="当前库存">
          <el-input :model-value="stockForm.currentQty" disabled />
        </el-form-item>
        <el-form-item label="出库数量" required>
          <el-input-number v-model="stockForm.quantity" :min="1" :max="stockForm.currentQty" style="width: 100%" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="stockOutVisible = false">取消</el-button>
        <el-button type="primary" :loading="stockSubmitting" @click="submitStockOut">确定</el-button>
      </template>
    </el-dialog>
  </el-card>
</template>

<script setup>
import { ref, reactive, inject, watch, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getInventoryList, stockIn, stockOut, getInventoryLogs } from '@/api/modules'

// 管理员切换时刷新数据
const refreshKey = inject('refreshKey', ref(0))
watch(refreshKey, () => {
  loadInventory()
  loadLogs()
})

const activeTab = ref('list')

// Inventory list state
const inventoryList = ref([])
const inventoryLoading = ref(false)
const inventoryPagination = reactive({ page: 1, size: 10, total: 0 })

// Log list state
const logList = ref([])
const logLoading = ref(false)
const logPagination = reactive({ page: 1, size: 10, total: 0 })

// Dialog state
const stockInVisible = ref(false)
const stockOutVisible = ref(false)
const stockSubmitting = ref(false)
const stockForm = reactive({
  productId: null,
  productName: '',
  currentQty: 0,
  quantity: 1
})

// Load inventory list
const loadInventory = async () => {
  inventoryLoading.value = true
  try {
    const res = await getInventoryList({
      page: inventoryPagination.page,
      size: inventoryPagination.size
    })
    inventoryList.value = res.data.records
    inventoryPagination.total = res.data.total
  } catch (e) {
    // error handled by interceptor
  } finally {
    inventoryLoading.value = false
  }
}

// Load log list
const loadLogs = async () => {
  logLoading.value = true
  try {
    const res = await getInventoryLogs({
      page: logPagination.page,
      size: logPagination.size
    })
    logList.value = res.data.records
    logPagination.total = res.data.total
  } catch (e) {
    // error handled by interceptor
  } finally {
    logLoading.value = false
  }
}

// Open stock-in dialog
const openStockIn = (row) => {
  stockForm.productId = row.productId
  stockForm.productName = row.productName
  stockForm.currentQty = row.quantity
  stockForm.quantity = 1
  stockInVisible.value = true
}

// Open stock-out dialog
const openStockOut = (row) => {
  stockForm.productId = row.productId
  stockForm.productName = row.productName
  stockForm.currentQty = row.quantity
  stockForm.quantity = 1
  stockOutVisible.value = true
}

// Submit stock-in
const submitStockIn = async () => {
  if (stockForm.quantity <= 0) {
    ElMessage.warning('请输入入库数量')
    return
  }
  stockSubmitting.value = true
  try {
    await stockIn({
      productId: stockForm.productId,
      quantity: stockForm.quantity
    })
    ElMessage.success('入库成功')
    stockInVisible.value = false
    loadInventory()
  } catch (e) {
    // error handled by interceptor
  } finally {
    stockSubmitting.value = false
  }
}

// Submit stock-out
const submitStockOut = async () => {
  if (stockForm.quantity <= 0) {
    ElMessage.warning('请输入出库数量')
    return
  }
  if (stockForm.quantity > stockForm.currentQty) {
    ElMessage.warning('出库数量不能大于当前库存')
    return
  }
  stockSubmitting.value = true
  try {
    await stockOut({
      productId: stockForm.productId,
      quantity: stockForm.quantity
    })
    ElMessage.success('出库成功')
    stockOutVisible.value = false
    loadInventory()
  } catch (e) {
    // error handled by interceptor
  } finally {
    stockSubmitting.value = false
  }
}

// Row class for low-stock highlight
const tableRowClassName = ({ row }) => {
  if (row.quantity < row.safetyStock) {
    return 'warning-row'
  }
  return ''
}

// Format date
const formatDate = (dateStr) => {
  if (!dateStr) return ''
  return dateStr.replace('T', ' ').substring(0, 19)
}

onMounted(() => {
  loadInventory()
  loadLogs()
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

.pagination-wrapper {
  display: flex;
  justify-content: flex-end;
  margin-top: 16px;
}

:deep(.el-table .warning-row) {
  --el-table-tr-bg-color: var(--el-color-warning-light-9);
}
</style>

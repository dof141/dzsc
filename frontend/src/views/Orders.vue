<template>
  <el-card class="page-card">
    <template #header>
      <div class="card-header">
        <span class="header-title">订单管理</span>
        <el-button type="primary" @click="openCreateDialog">
          <el-icon><Plus /></el-icon>创建内部订单
        </el-button>
      </div>
    </template>

    <!-- 搜索栏 -->
    <el-form :inline="true" :model="searchForm" class="search-form">
      <el-form-item label="订单编号">
        <el-input v-model="searchForm.orderNo" placeholder="输入订单编号" clearable @clear="handleSearch" />
      </el-form-item>
      <el-form-item label="订单状态">
        <el-select v-model="searchForm.status" placeholder="全部状态" clearable style="width: 140px;">
          <el-option label="待付款" value="PENDING" />
          <el-option label="已付款" value="PAID" />
          <el-option label="已发货" value="SHIPPED" />
          <el-option label="已完成" value="COMPLETED" />
          <el-option label="已取消" value="CANCELLED" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="handleSearch">查询</el-button>
        <el-button @click="resetSearch">重置</el-button>
      </el-form-item>
    </el-form>

    <!-- 订单表格 -->
    <el-table :data="tableData" style="width: 100%" v-loading="loading">
      <el-table-column prop="orderNo" label="订单编号" min-width="180" show-overflow-tooltip>
        <template #default="{ row }">
          <span style="font-weight: 700; color: #111827;">{{ row.orderNo }}</span>
        </template>
      </el-table-column>
      <el-table-column prop="totalAmount" label="订单金额" width="120" align="right">
        <template #default="{ row }">
          <span style="font-weight: 800; color: #f97316;">
            {{ row.totalAmount != null ? '¥' + Number(row.totalAmount).toFixed(2) : '-' }}
          </span>
        </template>
      </el-table-column>
      <el-table-column prop="status" label="订单状态" width="100" align="center">
        <template #default="{ row }">
          <el-tag :type="statusTagType(row.status)" disable-transitions style="font-weight: 800;">
            {{ statusLabel(row.status) }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="receiverName" label="收货人" width="120" />
      <el-table-column prop="receiverPhone" label="联系电话" width="140" />
      <el-table-column prop="createdAt" label="创建时间" width="180">
        <template #default="{ row }">
          {{ formatDate(row.createdAt) }}
        </template>
      </el-table-column>
      <el-table-column label="操作" width="320" fixed="right" align="center">
        <template #default="{ row }">
          <el-button type="primary" plain size="small" @click="openDetail(row)">查看详情</el-button>
          
          <el-button
            type="warning" 
            plain 
            size="small"
            :disabled="!(row.status === 'PENDING' || row.status === 'PAID' || row.status === 'SHIPPED')"
            @click="openStatusDialog(row)"
          >
            修改状态
          </el-button>

          <el-popconfirm
            title="确定取消该订单？"
            :disabled="row.status !== 'PENDING'"
            @confirm="handleCancel(row.orderId)"
          >
            <template #reference>
              <el-button 
                type="danger" 
                plain 
                size="small"
                :disabled="row.status !== 'PENDING'"
              >
                取消订单
              </el-button>
            </template>
          </el-popconfirm>
        </template>
      </el-table-column>
    </el-table>

    <!-- 分页 -->
    <div class="pagination-wrapper">
      <el-pagination
        v-model:current-page="pagination.page"
        v-model:page-size="pagination.size"
        :page-sizes="[10, 20, 50]"
        :total="pagination.total"
        layout="total, sizes, prev, pager, next"
        @size-change="loadData"
        @current-change="loadData"
      />
    </div>

    <!-- 订单详情对话框 -->
    <el-dialog v-model="detailVisible" title="订单明细" width="700px" destroy-on-close>
      <template v-if="detailOrder">
        <el-descriptions :column="2" border class="custom-desc">
          <el-descriptions-item label="订单编号"><b>{{ detailOrder.orderNo }}</b></el-descriptions-item>
          <el-descriptions-item label="订单状态">
            <el-tag :type="statusTagType(detailOrder.status)">{{ statusLabel(detailOrder.status) }}</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="收货人">{{ detailOrder.receiverName }}</el-descriptions-item>
          <el-descriptions-item label="联系电话">{{ detailOrder.receiverPhone }}</el-descriptions-item>
          <el-descriptions-item label="收货地址" :span="2">{{ detailOrder.address }}</el-descriptions-item>
          <el-descriptions-item label="订单总额">
            <span style="color: #f97316; font-weight: 800; font-size: 16px;">¥{{ Number(detailOrder.totalAmount).toFixed(2) }}</span>
          </el-descriptions-item>
          <el-descriptions-item label="创建时间">{{ formatDate(detailOrder.createdAt) }}</el-descriptions-item>
        </el-descriptions>

        <div style="margin-top: 24px; font-weight: 800; font-size: 15px; color: #374151;">包含商品</div>
        <el-table :data="detailOrder.items || []" border style="margin-top: 12px; border-radius: 8px; overflow: hidden;">
          <el-table-column prop="productName" label="商品名称" min-width="150" />
          <el-table-column prop="quantity" label="数量" width="100" align="center">
            <template #default="{ row }"><b>{{ row.quantity }}</b></template>
          </el-table-column>
          <el-table-column prop="unitPrice" label="单价" width="120" align="right">
            <template #default="{ row }">¥{{ Number(row.unitPrice).toFixed(2) }}</template>
          </el-table-column>
          <el-table-column prop="subtotal" label="小计" width="120" align="right">
            <template #default="{ row }"><b style="color: #f97316;">¥{{ Number(row.subtotal).toFixed(2) }}</b></template>
          </el-table-column>
        </el-table>

        <div v-if="nextStatus(detailOrder.status)" style="margin-top: 20px; text-align: right;">
          <el-button type="success" size="large" @click="advanceStatus(detailOrder)">
            推进流程：{{ nextStatusLabel(detailOrder.status) }}
          </el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 修改状态对话框 -->
    <el-dialog v-model="statusDialogVisible" title="强制修改订单状态" width="400px" destroy-on-close>
      <el-form :model="statusForm" label-width="80px">
        <el-form-item label="当前状态">
          <el-tag :type="statusTagType(statusForm.currentStatus)">{{ statusLabel(statusForm.currentStatus) }}</el-tag>
        </el-form-item>
        <el-form-item label="目标状态">
          <el-select v-model="statusForm.newStatus" placeholder="请选择目标状态" style="width: 100%;">
            <el-option
              v-for="s in availableStatuses(statusForm.currentStatus)"
              :key="s.value"
              :label="s.label"
              :value="s.value"
            />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="statusDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="statusSubmitting" @click="submitStatusChange">确定</el-button>
      </template>
    </el-dialog>

    <!-- 创建订单对话框 -->
    <el-dialog v-model="createVisible" title="内部测试：模拟创建订单" width="750px" destroy-on-close>
      <el-form ref="createFormRef" :model="createForm" :rules="createRules" label-width="90px">
        <div class="form-section-title">收货信息</div>
        <el-form-item label="收货人" prop="receiverName">
          <el-input v-model="createForm.receiverName" placeholder="如：张三" />
        </el-form-item>
        <el-form-item label="联系电话" prop="receiverPhone">
          <el-input v-model="createForm.receiverPhone" placeholder="如：13800138000" />
        </el-form-item>
        <el-form-item label="收货地址" prop="address">
          <el-input v-model="createForm.address" type="textarea" :rows="2" placeholder="详细地址" />
        </el-form-item>

        <div class="form-section-title" style="margin-top: 24px;">购买商品</div>
        <div v-for="(item, index) in createForm.items" :key="index" class="order-item-row">
          <el-row :gutter="12">
            <el-col :span="10">
              <el-form-item
                :prop="'items.' + index + '.productId'"
                :rules="[{ required: true, message: '请选择商品', trigger: 'change' }]"
                label="商品"
              >
                <el-select
                  v-model="item.productId"
                  placeholder="检索商品"
                  filterable
                  style="width: 100%"
                  @change="(val) => onProductSelect(index, val)"
                >
                  <el-option
                    v-for="p in productList"
                    :key="p.productId"
                    :label="p.name"
                    :value="p.productId"
                  >
                    <span>{{ p.name }}</span>
                    <span style="float: right; color: #f97316; font-weight: 700;">¥{{ Number(p.price).toFixed(2) }}</span>
                  </el-option>
                </el-select>
              </el-form-item>
            </el-col>
            <el-col :span="5">
              <el-form-item
                :prop="'items.' + index + '.unitPrice'"
                :rules="[{ required: true, message: '请输入单价', trigger: 'blur' }]"
                label="单价"
              >
                <el-input-number v-model="item.unitPrice" :precision="2" :min="0.01" controls-position="right" style="width: 100%" />
              </el-form-item>
            </el-col>
            <el-col :span="5">
              <el-form-item
                :prop="'items.' + index + '.quantity'"
                :rules="[{ required: true, message: '请输入数量', trigger: 'blur' }]"
                label="数量"
              >
                <el-input-number v-model="item.quantity" :min="1" :max="9999" controls-position="right" style="width: 100%" />
              </el-form-item>
            </el-col>
            <el-col :span="3">
              <div class="item-subtotal">¥{{ (item.unitPrice * item.quantity).toFixed(2) }}</div>
            </el-col>
            <el-col :span="1">
              <el-button type="danger" :icon="Delete" circle size="small" @click="removeItem(index)" v-if="createForm.items.length > 1" />
            </el-col>
          </el-row>
        </div>
        <el-button type="primary" plain @click="addItem" style="margin-bottom: 20px;">
          <el-icon><Plus /></el-icon>继续添加商品
        </el-button>
        <div style="text-align: right; font-size: 18px; font-weight: 800; color: #f97316;">
          订单总计: ¥{{ createTotal }}
        </div>
      </el-form>
      <template #footer>
        <el-button @click="createVisible = false" size="large">取消</el-button>
        <el-button type="primary" size="large" :loading="createSubmitting" @click="submitCreate">提交订单</el-button>
      </template>
    </el-dialog>
  </el-card>
</template>

<script setup>
import { ref, reactive, computed, inject, watch, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Delete, Plus } from '@element-plus/icons-vue'
import {
  getOrders, getOrder, createOrder, cancelOrder, updateOrderStatus, getProducts
} from '../api/modules'

const refreshKey = inject('refreshKey', ref(0))
watch(refreshKey, () => loadData())

const searchForm = reactive({ orderNo: '', status: '' })
const tableData = ref([])
const loading = ref(false)
const pagination = reactive({ page: 1, size: 10, total: 0 })

const detailVisible = ref(false)
const detailOrder = ref(null)

const statusDialogVisible = ref(false)
const statusSubmitting = ref(false)
const statusForm = reactive({ orderId: null, currentStatus: '', newStatus: '' })

const createVisible = ref(false)
const createSubmitting = ref(false)
const createFormRef = ref(null)
const productList = ref([])
const createForm = reactive({
  receiverName: '',
  receiverPhone: '',
  address: '',
  items: [{ productId: null, unitPrice: 0, quantity: 1 }]
})

const createRules = {
  receiverName: [{ required: true, message: '请输入收货人姓名', trigger: 'blur' }],
  receiverPhone: [{ required: true, message: '请输入联系电话', trigger: 'blur' }],
  address: [{ required: true, message: '请输入收货地址', trigger: 'blur' }]
}

const statusMap = {
  PENDING: { label: '待付款', type: 'warning', next: 'PAID', nextLabel: '标记已付款' },
  PAID: { label: '已付款', type: 'primary', next: 'SHIPPED', nextLabel: '标记已发货' },
  SHIPPED: { label: '已发货', type: 'info', next: 'COMPLETED', nextLabel: '标记已完成' },
  COMPLETED: { label: '已完成', type: 'success', next: null, nextLabel: '' },
  CANCELLED: { label: '已取消', type: 'danger', next: null, nextLabel: '' }
}

const statusTagType = (s) => statusMap[s]?.type || 'info'
const statusLabel = (s) => statusMap[s]?.label || s
const nextStatus = (s) => statusMap[s]?.next || null
const nextStatusLabel = (s) => statusMap[s]?.nextLabel || ''

const availableStatuses = (current) => {
  const flow = ['PENDING', 'PAID', 'SHIPPED', 'COMPLETED']
  const idx = flow.indexOf(current)
  if (idx < 0) return []
  return flow.slice(idx + 1).map(v => ({ value: v, label: statusMap[v].label }))
}

const createTotal = computed(() => {
  const total = createForm.items.reduce((sum, item) => sum + (item.unitPrice || 0) * (item.quantity || 0), 0)
  return total.toFixed(2)
})

const formatDate = (val) => {
  if (!val) return '-'
  if (Array.isArray(val)) {
    const [y, m, d, h = 0, mi = 0, s = 0] = val
    return `${y}-${String(m).padStart(2, '0')}-${String(d).padStart(2, '0')} ${String(h).padStart(2, '0')}:${String(mi).padStart(2, '0')}:${String(s).padStart(2, '0')}`
  }
  return String(val).replace('T', ' ').substring(0, 19)
}

const loadData = async () => {
  loading.value = true
  try {
    const params = { page: pagination.page, size: pagination.size }
    if (searchForm.orderNo) params.orderNo = searchForm.orderNo
    if (searchForm.status) params.status = searchForm.status
    const res = await getOrders(params)
    tableData.value = res.data.records || []
    pagination.total = res.data.total || 0
  } finally {
    loading.value = false
  }
}

const handleSearch = () => { pagination.page = 1; loadData() }
const resetSearch = () => { searchForm.orderNo = ''; searchForm.status = ''; handleSearch() }

const openDetail = async (row) => {
  const res = await getOrder(row.orderId)
  detailOrder.value = res.data
  detailVisible.value = true
}

const handleCancel = async (orderId) => {
  await cancelOrder(orderId)
  ElMessage.success('订单已取消')
  loadData()
}

const openStatusDialog = (row) => {
  statusForm.orderId = row.orderId
  statusForm.currentStatus = row.status
  statusForm.newStatus = nextStatus(row.status) || ''
  statusDialogVisible.value = true
}

const submitStatusChange = async () => {
  if (!statusForm.newStatus) return ElMessage.warning('请选择目标状态')
  statusSubmitting.value = true
  try {
    await updateOrderStatus(statusForm.orderId, statusForm.newStatus)
    ElMessage.success('状态更新成功')
    statusDialogVisible.value = false
    loadData()
  } finally {
    statusSubmitting.value = false
  }
}

const advanceStatus = async (order) => {
  const next = nextStatus(order.status)
  if (!next) return
  await updateOrderStatus(order.orderId, next)
  ElMessage.success('状态已推进')
  const res = await getOrder(order.orderId)
  detailOrder.value = res.data
  loadData()
}

const loadProducts = async () => {
  const res = await getProducts({ page: 1, size: 999 })
  productList.value = res.data.records || []
}

const openCreateDialog = () => {
  createForm.receiverName = ''
  createForm.receiverPhone = ''
  createForm.address = ''
  createForm.items = [{ productId: null, unitPrice: 0, quantity: 1 }]
  createVisible.value = true
  loadProducts()
}

const addItem = () => createForm.items.push({ productId: null, unitPrice: 0, quantity: 1 })
const removeItem = (index) => createForm.items.splice(index, 1)

const onProductSelect = (index, productId) => {
  const product = productList.value.find(p => p.productId === productId)
  if (product) createForm.items[index].unitPrice = Number(product.price)
}

const submitCreate = async () => {
  await createFormRef.value.validate()
  if (createForm.items.length === 0) return ElMessage.warning('请添加商品')
  if (createForm.items.some(item => !item.productId)) return ElMessage.warning('请选择商品')
  
  createSubmitting.value = true
  try {
    await createOrder({
      receiverName: createForm.receiverName,
      receiverPhone: createForm.receiverPhone,
      address: createForm.address,
      items: createForm.items.map(i => ({ productId: i.productId, unitPrice: i.unitPrice, quantity: i.quantity }))
    })
    ElMessage.success('订单已生成')
    createVisible.value = false
    loadData()
  } finally {
    createSubmitting.value = false
  }
}

onMounted(() => loadData())
</script>

<style scoped>
.page-card { height: 100%; }
.header-title { font-size: 16px; font-weight: 800; color: #111827; }
.card-header { display: flex; justify-content: space-between; align-items: center; }
.search-form { margin-bottom: 20px; background: #f9fafb; padding: 18px 24px; border-radius: 12px; border: 1px solid #e5e7eb; }
.pagination-wrapper { display: flex; justify-content: flex-end; margin-top: 24px; }
.form-section-title { font-size: 14px; font-weight: 800; color: #6b7280; text-transform: uppercase; margin-bottom: 12px; border-bottom: 1px solid #e5e7eb; padding-bottom: 8px; }
.order-item-row { margin-bottom: 12px; padding: 16px; background: #f9fafb; border-radius: 8px; border: 1px solid #e5e7eb; }
.item-subtotal { line-height: 32px; text-align: center; font-weight: 800; color: #f97316; font-size: 16px; }
.custom-desc :deep(.el-descriptions__label) { background-color: #f9fafb !important; font-weight: 800; color: #6b7280; }
</style>

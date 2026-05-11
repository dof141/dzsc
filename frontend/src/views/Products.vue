<template>
  <el-card class="page-card">
    <template #header>
      <div class="card-header">
        <span class="header-title">商品管理档案</span>
        <el-button type="primary" @click="openDialog(null)">
          <el-icon><Plus /></el-icon>新增商品
        </el-button>
      </div>
    </template>

    <!-- RLS 安全策略提示 -->
    <el-alert
      title="当前已启用行级安全策略(DBMS_RLS)，不同管理员只能看到其权限范围内的商品"
      type="info"
      show-icon
      :closable="false"
      style="margin-bottom: 16px; border-radius: 8px;"
    />

    <!-- 搜索栏 -->
    <el-form :inline="true" :model="searchForm" class="search-form">
      <el-form-item label="商品名称">
        <el-input v-model="searchForm.name" placeholder="输入名称查询" clearable @clear="handleSearch" />
      </el-form-item>
      <el-form-item label="商品分类">
        <el-tree-select
          v-model="searchForm.categoryId"
          :data="categoryTree"
          :props="{ value: 'categoryId', label: 'name', children: 'children' }"
          placeholder="全部品类"
          clearable
          check-strictly
        />
      </el-form-item>
      <el-form-item label="状态">
        <el-select v-model="searchForm.status" placeholder="全部状态" clearable style="width: 120px;">
          <el-option label="已上架" :value="1" />
          <el-option label="已下架" :value="0" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="handleSearch">搜索</el-button>
        <el-button @click="resetSearch">重置</el-button>
      </el-form-item>
    </el-form>

    <!-- 商品表格 -->
    <el-table :data="tableData" style="width: 100%" v-loading="loading">
      <el-table-column prop="productId" label="ID" width="70" align="center" />
      <el-table-column prop="name" label="商品名称" min-width="200" show-overflow-tooltip>
        <template #default="{ row }">
          <span style="font-weight: 700; color: #1f2937;">{{ row.name }}</span>
        </template>
      </el-table-column>
      <el-table-column prop="categoryName" label="分类" width="130" />
      <el-table-column prop="price" label="销售价" width="120" align="right">
        <template #default="{ row }">
          <span style="font-weight: 800; color: #f97316;">
            {{ row.price != null ? '¥' + Number(row.price).toFixed(2) : '-' }}
          </span>
        </template>
      </el-table-column>
      <el-table-column prop="unit" label="单位" width="80" align="center" />
      <el-table-column prop="status" label="状态" width="120" align="center">
        <template #default="{ row }">
          <div :style="{ color: row.status === 1 ? '#10b981' : '#6b7280', fontWeight: '800', display: 'flex', alignItems: 'center', justifyContent: 'center' }">
            <span :class="['status-dot', row.status === 1 ? 'success' : 'info']"></span>
            {{ row.status === 1 ? '已上架' : '已下架' }}
          </div>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="280" fixed="right" align="center">
        <!-- 重点：摒弃 Link，采用高可视度的 Plain Button，彻底解决看不清的问题 -->
        <template #default="{ row }">
          <el-button 
            v-if="row.status === 0"
            type="success" 
            plain
            size="small"
            @click="toggleStatus(row)"
          >
            <el-icon><Top /></el-icon>上架
          </el-button>
          <el-button 
            v-else
            type="info" 
            plain
            size="small"
            @click="toggleStatus(row)"
          >
            <el-icon><Bottom /></el-icon>下架
          </el-button>
          
          <el-button 
            type="primary" 
            plain
            size="small"
            @click="openDialog(row)"
          >
            <el-icon><Edit /></el-icon>编辑
          </el-button>
          
          <el-popconfirm title="确定删除此商品？" @confirm="handleDelete(row.productId)">
            <template #reference>
              <el-button type="danger" plain size="small">
                <el-icon><Delete /></el-icon>删除
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

    <!-- 对话框 -->
    <el-dialog v-model="dialogVisible" :title="isEdit ? '修改商品信息' : '录入新商品'" width="550px">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="商品名称" prop="name">
          <el-input v-model="form.name" />
        </el-form-item>
        <el-form-item label="所属分类" prop="categoryId">
          <el-tree-select
            v-model="form.categoryId"
            :data="categoryTree"
            :props="{ value: 'categoryId', label: 'name', children: 'children' }"
            check-strictly
          />
        </el-form-item>
        <el-form-item label="销售单价" prop="price">
          <el-input-number v-model="form.price" :precision="2" :min="0" style="width: 100%" />
        </el-form-item>
        <el-form-item label="计件单位" prop="unit">
          <el-input v-model="form.unit" placeholder="如：件 / 盒 / 台" />
        </el-form-item>
        <el-form-item label="当前状态">
          <el-radio-group v-model="form.status">
            <el-radio :label="1">上架销售</el-radio>
            <el-radio :label="0">下架暂存</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="备注说明">
          <el-input v-model="form.description" type="textarea" :rows="3" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">返回</el-button>
        <el-button type="primary" @click="handleSubmit">确认保存</el-button>
      </template>
    </el-dialog>
  </el-card>
</template>

<script setup>
import { ref, reactive, inject, watch, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Edit, Delete, Top, Bottom, Plus } from '@element-plus/icons-vue'
import {
  getProducts, createProduct, updateProduct, deleteProduct,
  getCategoryTree
} from '../api/modules'

const refreshKey = inject('refreshKey', ref(0))
watch(refreshKey, () => loadData())

const searchForm = reactive({ name: '', categoryId: null, status: null })
const tableData = ref([])
const loading = ref(false)
const pagination = reactive({ page: 1, size: 10, total: 0 })
const categoryTree = ref([])
const dialogVisible = ref(false)
const isEdit = ref(false)
const formRef = ref(null)

const defaultForm = { productId: null, name: '', categoryId: null, price: 0, unit: '', status: 1, description: '' }
const form = ref({ ...defaultForm })

const rules = {
  name: [{ required: true, message: '必填', trigger: 'blur' }],
  categoryId: [{ required: true, message: '必选', trigger: 'change' }],
  price: [{ required: true, message: '必填', trigger: 'blur' }],
  unit: [{ required: true, message: '必填', trigger: 'blur' }]
}

const loadCategoryTree = async () => {
  const res = await getCategoryTree()
  categoryTree.value = res.data || []
}

const loadData = async () => {
  loading.value = true
  try {
    const params = { page: pagination.page, size: pagination.size, ...searchForm }
    const res = await getProducts(params)
    tableData.value = res.data.records || []
    pagination.total = res.data.total || 0
  } finally {
    loading.value = false
  }
}

const handleSearch = () => { pagination.page = 1; loadData() }
const resetSearch = () => { Object.assign(searchForm, { name: '', categoryId: null, status: null }); handleSearch() }

const openDialog = (row) => {
  if (row) { isEdit.value = true; form.value = { ...row } } 
  else { isEdit.value = false; form.value = { ...defaultForm } }
  dialogVisible.value = true
}

const handleSubmit = async () => {
  await formRef.value.validate()
  if (isEdit.value) await updateProduct(form.value.productId, form.value)
  else await createProduct(form.value)
  ElMessage.success('操作成功')
  dialogVisible.value = false
  loadData()
}

const handleDelete = async (id) => {
  await deleteProduct(id)
  ElMessage.success('已删除')
  loadData()
}

const toggleStatus = async (row) => {
  const newStatus = row.status === 1 ? 0 : 1
  await updateProduct(row.productId, { ...row, status: newStatus })
  ElMessage.success(newStatus === 1 ? '商品已上架' : '商品已下架')
  loadData()
}

onMounted(() => { loadCategoryTree(); loadData() })
</script>

<style scoped>
.page-card { height: 100%; }
.header-title { font-size: 16px; font-weight: 800; color: #111827; }
.card-header { display: flex; justify-content: space-between; align-items: center; }
.search-form { margin-bottom: 20px; background: #f9fafb; padding: 18px 24px; border-radius: 12px; border: 1px solid #e5e7eb; }
.pagination-wrapper { display: flex; justify-content: flex-end; margin-top: 24px; }
.status-dot { display: inline-block; width: 10px; height: 10px; border-radius: 50%; margin-right: 8px; }
.status-dot.success { background-color: #10b981; box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.2); }
.status-dot.info { background-color: #9ca3af; }
</style>

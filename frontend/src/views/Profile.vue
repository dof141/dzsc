<template>
  <el-card class="page-card">
    <template #header>
      <span class="header-title">个人中心</span>
    </template>

    <el-tabs v-model="activeTab" @tab-change="onTabChange">
      <!-- Tab 1: 基本信息 -->
      <el-tab-pane label="基本信息" name="info">
        <el-row :gutter="20">
          <el-col :span="8">
            <el-card shadow="never">
              <div class="profile-info">
                <el-avatar :size="100" :src="user.avatar || defaultAvatar" />
                <h3>{{ user.realName }}</h3>
                <p class="username">{{ user.username }}</p>
                <el-tag :type="user.role === 'SUPER_ADMIN' ? 'danger' : 'primary'" size="large">
                  {{ user.role === 'SUPER_ADMIN' ? '超级管理员' : '普通管理员' }}
                </el-tag>
              </div>
            </el-card>
          </el-col>

          <el-col :span="16">
            <el-card shadow="never">
              <template #header>修改个人信息</template>
              <el-form :model="profileForm" label-width="100px">
                <el-form-item label="用户名">
                  <el-input v-model="user.username" disabled />
                </el-form-item>
                <el-form-item label="真实姓名">
                  <el-input v-model="profileForm.realName" />
                </el-form-item>
                <el-form-item label="头像URL">
                  <el-input v-model="profileForm.avatar" placeholder="输入头像URL" />
                </el-form-item>
                <el-form-item>
                  <el-button type="primary" @click="handleUpdateProfile" :loading="updating">
                    保存修改
                  </el-button>
                </el-form-item>
              </el-form>
            </el-card>

            <el-card shadow="never" style="margin-top: 20px;">
              <template #header>修改密码</template>
              <el-form :model="pwdForm" :rules="pwdRules" ref="pwdFormRef" label-width="100px">
                <el-form-item label="原密码" prop="oldPwd">
                  <el-input v-model="pwdForm.oldPwd" type="password" show-password />
                </el-form-item>
                <el-form-item label="新密码" prop="newPwd">
                  <el-input v-model="pwdForm.newPwd" type="password" show-password />
                </el-form-item>
                <el-form-item label="确认密码" prop="confirmPwd">
                  <el-input v-model="pwdForm.confirmPwd" type="password" show-password />
                </el-form-item>
                <el-form-item>
                  <el-button type="primary" @click="handleUpdatePassword" :loading="updatingPwd">
                    修改密码
                  </el-button>
                </el-form-item>
              </el-form>
            </el-card>
          </el-col>
        </el-row>
      </el-tab-pane>

      <!-- Tab 2: 权限信息 -->
      <el-tab-pane label="权限信息" name="permissions">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-card shadow="never">
              <template #header>
                <div class="card-header">
                  <span>分类权限</span>
                  <el-tag :type="user.role === 'SUPER_ADMIN' ? 'danger' : 'primary'">
                    {{ user.role === 'SUPER_ADMIN' ? '全部分类' : '指定分类' }}
                  </el-tag>
                </div>
              </template>
              <div v-if="user.role === 'SUPER_ADMIN'" class="permission-tip">
                <el-icon><CircleCheck /></el-icon>
                <span>超级管理员拥有所有分类的访问权限</span>
              </div>
              <div v-else>
                <el-table :data="categoryPermissions" border stripe>
                  <el-table-column prop="categoryId" label="分类ID" width="100" />
                  <el-table-column prop="categoryName" label="分类名称" />
                </el-table>
                <div v-if="categoryPermissions.length === 0" class="empty-tip">
                  暂无分配的分类权限
                </div>
              </div>
            </el-card>
          </el-col>

          <el-col :span="12">
            <el-card shadow="never">
              <template #header>功能权限</template>
              <el-table :data="featurePermissions" border stripe>
                <el-table-column prop="feature" label="功能模块" width="150">
                  <template #default="{ row }">
                    <span style="font-weight: 600;">{{ row.name }}</span>
                  </template>
                </el-table-column>
                <el-table-column prop="description" label="说明" />
                <el-table-column prop="access" label="权限" width="100" align="center">
                  <template #default="{ row }">
                    <el-tag :type="row.access ? 'success' : 'danger'">
                      {{ row.access ? '允许' : '禁止' }}
                    </el-tag>
                  </template>
                </el-table-column>
              </el-table>
            </el-card>
          </el-col>
        </el-row>
      </el-tab-pane>

      <!-- Tab 3: 操作记录 -->
      <el-tab-pane label="操作记录" name="logs">
        <el-card shadow="never">
          <template #header>
            <div class="card-header">
              <span>最近操作记录</span>
              <el-button type="primary" plain size="small" @click="loadLogs">
                <el-icon><Refresh /></el-icon>刷新
              </el-button>
            </div>
          </template>

          <el-table :data="operationLogs" border stripe v-loading="logsLoading">
            <el-table-column prop="operatedAt" label="操作时间" width="180">
              <template #default="{ row }">
                {{ formatDate(row.operatedAt) }}
              </template>
            </el-table-column>
            <el-table-column prop="operation" label="操作类型" width="100" align="center">
              <template #default="{ row }">
                <el-tag :type="getOperationType(row.operation)">
                  {{ getOperationLabel(row.operation) }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="tableName" label="请求路径" min-width="200" show-overflow-tooltip />
            <el-table-column prop="newValue" label="详情" min-width="200" show-overflow-tooltip />
            <el-table-column prop="operatedBy" label="IP地址" width="140" />
          </el-table>

          <div class="pagination-wrapper">
            <el-pagination
              v-model:current-page="logsPagination.page"
              v-model:page-size="logsPagination.size"
              :page-sizes="[10, 20, 50]"
              :total="logsPagination.total"
              layout="total, sizes, prev, pager, next"
              @size-change="loadLogs"
              @current-change="loadLogs"
            />
          </div>
        </el-card>
      </el-tab-pane>
    </el-tabs>
  </el-card>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { CircleCheck, Refresh } from '@element-plus/icons-vue'
import {
  updateProfile, updatePassword, getUserPermissions,
  getMyAuditLogs, getCategoryTree
} from '../api/modules'

const defaultAvatar = 'https://cube.elemecdn.com/3/7c/3ea6beec64369c2642b92c6726f1epng.png'

const activeTab = ref('info')
const user = ref(JSON.parse(localStorage.getItem('user') || '{}'))
const updating = ref(false)
const updatingPwd = ref(false)
const pwdFormRef = ref(null)

// Profile form
const profileForm = reactive({
  realName: '',
  avatar: ''
})

// Password form
const pwdForm = reactive({
  oldPwd: '',
  newPwd: '',
  confirmPwd: ''
})

const pwdRules = {
  oldPwd: [{ required: true, message: '请输入原密码', trigger: 'blur' }],
  newPwd: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, message: '密码至少6位', trigger: 'blur' }
  ],
  confirmPwd: [
    { required: true, message: '请确认密码', trigger: 'blur' },
    {
      validator: (rule, value, callback) => {
        if (value !== pwdForm.newPwd) {
          callback(new Error('两次密码不一致'))
        } else {
          callback()
        }
      },
      trigger: 'blur'
    }
  ]
}

// Permissions
const categoryPermissions = ref([])
const featurePermissions = ref([])

// Operation logs
const operationLogs = ref([])
const logsLoading = ref(false)
const logsPagination = reactive({ page: 1, size: 10, total: 0 })

// Feature list for permissions table
const allFeatures = [
  { key: 'dashboard', name: '首页大屏', description: '业务概览和数据可视化' },
  { key: 'products', name: '商品管理', description: '商品增删改查和上下架' },
  { key: 'categories', name: '分类管理', description: '商品分类树形管理' },
  { key: 'orders', name: '订单管理', description: '订单全生命周期管理' },
  { key: 'inventory', name: '库存管理', description: '库存入库出库和预警' },
  { key: 'payments', name: '支付管理', description: '支付记录和模拟支付' },
  { key: 'reports', name: '销售报表', description: '日报和月度报表' },
  { key: 'audit', name: '审计日志', description: '操作记录和闪回查询' },
  { key: 'admin-users', name: '管理员管理', description: '管理员CRUD和权限分配' },
  { key: 'profile', name: '个人中心', description: '个人信息和密码修改' }
]

onMounted(() => {
  profileForm.realName = user.value.realName || ''
  profileForm.avatar = user.value.avatar || ''
})

const onTabChange = (tab) => {
  if (tab === 'permissions') {
    loadPermissions()
  } else if (tab === 'logs') {
    loadLogs()
  }
}

// Load permissions
const loadPermissions = async () => {
  try {
    const res = await getUserPermissions()
    const data = res.data

    // Category permissions
    if (data.categoryIds && data.categoryIds.length > 0) {
      const treeRes = await getCategoryTree()
      const categories = treeRes.data || []
      categoryPermissions.value = findCategoriesByIds(categories, data.categoryIds)
    } else {
      categoryPermissions.value = []
    }

    // Feature permissions
    featurePermissions.value = allFeatures.map(f => ({
      ...f,
      access: data.features.includes(f.key)
    }))
  } catch (e) {
    console.error('Failed to load permissions:', e)
  }
}

// Find categories by IDs in tree
const findCategoriesByIds = (tree, ids) => {
  const result = []
  const find = (nodes) => {
    for (const node of nodes) {
      if (ids.includes(node.categoryId)) {
        result.push({ categoryId: node.categoryId, categoryName: node.name })
      }
      if (node.children) {
        find(node.children)
      }
    }
  }
  find(tree)
  return result
}

// Load operation logs
const loadLogs = async () => {
  logsLoading.value = true
  try {
    const res = await getMyAuditLogs({
      page: logsPagination.page,
      size: logsPagination.size
    })
    operationLogs.value = res.data?.records || []
    logsPagination.total = res.data?.total || 0
  } catch (e) {
    console.error('Failed to load logs:', e)
  } finally {
    logsLoading.value = false
  }
}

// Format date
const formatDate = (date) => {
  if (!date) return ''
  if (typeof date === 'string') return date.substring(0, 19).replace('T', ' ')
  return date
}

// Operation type tag
const getOperationType = (op) => {
  switch (op) {
    case 'QUERY': return 'info'
    case 'CREATE': return 'success'
    case 'UPDATE': return 'warning'
    case 'DELETE': return 'danger'
    default: return 'info'
  }
}

// Operation label
const getOperationLabel = (op) => {
  switch (op) {
    case 'QUERY': return '查询'
    case 'CREATE': return '新增'
    case 'UPDATE': return '修改'
    case 'DELETE': return '删除'
    default: return op
  }
}

// Update profile
const handleUpdateProfile = async () => {
  updating.value = true
  try {
    await updateProfile(profileForm)
    user.value.realName = profileForm.realName
    user.value.avatar = profileForm.avatar
    localStorage.setItem('user', JSON.stringify(user.value))
    ElMessage.success('更新成功')
  } finally {
    updating.value = false
  }
}

// Update password
const handleUpdatePassword = async () => {
  const valid = await pwdFormRef.value.validate().catch(() => false)
  if (!valid) return

  updatingPwd.value = true
  try {
    await updatePassword({ oldPwd: pwdForm.oldPwd, newPwd: pwdForm.newPwd })
    ElMessage.success('密码修改成功')
    Object.assign(pwdForm, { oldPwd: '', newPwd: '', confirmPwd: '' })
  } finally {
    updatingPwd.value = false
  }
}
</script>

<style scoped>
.page-card {
  height: 100%;
}

.header-title {
  font-size: 16px;
  font-weight: 800;
}

.profile-info {
  text-align: center;
  padding: 20px;
}

.profile-info h3 {
  margin: 15px 0 5px;
  font-size: 18px;
}

.profile-info .username {
  color: #999;
  margin-bottom: 15px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.permission-tip {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #67c23a;
  font-size: 14px;
  padding: 20px;
  text-align: center;
  justify-content: center;
}

.permission-tip .el-icon {
  font-size: 18px;
}

.empty-tip {
  text-align: center;
  color: #999;
  padding: 20px;
}

.pagination-wrapper {
  margin-top: 16px;
  display: flex;
  justify-content: flex-end;
}
</style>

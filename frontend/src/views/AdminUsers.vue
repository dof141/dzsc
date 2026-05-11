<template>
  <el-card class="page-card">
    <template #header>
      <div class="card-header">
        <span>管理员管理</span>
        <el-button type="primary" @click="handleAdd">新增管理员</el-button>
      </div>
    </template>

    <el-table :data="adminList" border stripe v-loading="loading">
      <el-table-column prop="adminId" label="ID" width="80" />
      <el-table-column prop="username" label="用户名" width="150" />
      <el-table-column prop="realName" label="真实姓名" width="150" />
      <el-table-column prop="role" label="角色" width="120">
        <template #default="{ row }">
          <el-tag :type="row.role === 'SUPER_ADMIN' ? 'danger' : 'primary'">
            {{ row.role === 'SUPER_ADMIN' ? '超级管理员' : '普通管理员' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="status" label="状态" width="100">
        <template #default="{ row }">
          <el-tag :type="row.status === 1 ? 'success' : 'info'">
            {{ row.status === 1 ? '启用' : '禁用' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="280">
        <template #default="{ row }">
          <el-button size="small" @click="handleEdit(row)">编辑</el-button>
          <el-button size="small" type="warning" @click="handlePermission(row)">权限</el-button>
          <el-button size="small" type="danger" @click="handleDelete(row)" :disabled="row.adminId === 1">
            删除
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- Add/Edit Dialog -->
    <el-dialog v-model="dialogVisible" :title="isEdit ? '编辑管理员' : '新增管理员'" width="500px">
      <el-form :model="form" :rules="rules" ref="formRef" label-width="100px">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="form.username" :disabled="isEdit" />
        </el-form-item>
        <el-form-item label="密码" :prop="isEdit ? '' : 'password'">
          <el-input v-model="form.password" type="password" :placeholder="isEdit ? '留空则不修改' : '请输入密码'" show-password />
        </el-form-item>
        <el-form-item label="真实姓名" prop="realName">
          <el-input v-model="form.realName" />
        </el-form-item>
        <el-form-item label="角色" prop="role">
          <el-select v-model="form.role">
            <el-option label="超级管理员" value="SUPER_ADMIN" />
            <el-option label="普通管理员" value="ADMIN" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-switch v-model="form.status" :active-value="1" :inactive-value="0" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :loading="submitting">确定</el-button>
      </template>
    </el-dialog>

    <!-- Permission Dialog -->
    <el-dialog v-model="permDialogVisible" title="分配分类权限" width="500px">
      <el-tree
        ref="treeRef"
        :data="categoryTree"
        :props="{ label: 'name', children: 'children' }"
        show-checkbox
        node-key="categoryId"
        :default-checked-keys="checkedKeys"
      />
      <template #footer>
        <el-button @click="permDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handlePermSubmit" :loading="submitting">确定</el-button>
      </template>
    </el-dialog>
  </el-card>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  getAdminUsers, createAdminUser, updateAdminUser,
  deleteAdminUser, assignAdminCategories, getCategoryTree
} from '../api/modules'

const loading = ref(false)
const adminList = ref([])
const dialogVisible = ref(false)
const permDialogVisible = ref(false)
const isEdit = ref(false)
const submitting = ref(false)
const formRef = ref(null)
const treeRef = ref(null)
const categoryTree = ref([])
const checkedKeys = ref([])
const currentAdminId = ref(null)

const form = reactive({
  username: '',
  password: '',
  realName: '',
  role: 'ADMIN',
  status: 1
})

const rules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }],
  realName: [{ required: true, message: '请输入真实姓名', trigger: 'blur' }],
  role: [{ required: true, message: '请选择角色', trigger: 'change' }]
}

const loadList = async () => {
  loading.value = true
  try {
    const res = await getAdminUsers()
    adminList.value = res.data || []
  } finally {
    loading.value = false
  }
}

const loadCategoryTree = async () => {
  const res = await getCategoryTree()
  categoryTree.value = res.data || []
}

onMounted(() => {
  loadList()
  loadCategoryTree()
})

const handleAdd = () => {
  isEdit.value = false
  Object.assign(form, { username: '', password: '', realName: '', role: 'ADMIN', status: 1 })
  dialogVisible.value = true
}

const handleEdit = (row) => {
  isEdit.value = true
  Object.assign(form, { ...row, password: '' })
  dialogVisible.value = true
}

const handleSubmit = async () => {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return

  submitting.value = true
  try {
    if (isEdit.value) {
      await updateAdminUser(form.adminId, form)
      ElMessage.success('更新成功')
    } else {
      await createAdminUser(form)
      ElMessage.success('创建成功')
    }
    dialogVisible.value = false
    loadList()
  } finally {
    submitting.value = false
  }
}

const handleDelete = async (row) => {
  await ElMessageBox.confirm('确定删除该管理员？', '提示', { type: 'warning' })
  try {
    await deleteAdminUser(row.adminId)
    ElMessage.success('删除成功')
    loadList()
  } catch (e) {
    // Error handled by interceptor
  }
}

const handlePermission = async (row) => {
  currentAdminId.value = row.adminId
  checkedKeys.value = row.categories || []
  permDialogVisible.value = true
}

const handlePermSubmit = async () => {
  submitting.value = true
  try {
    const keys = treeRef.value.getCheckedKeys()
    await assignAdminCategories(currentAdminId.value, { categoryIds: keys })
    ElMessage.success('权限分配成功')
    permDialogVisible.value = false
    loadList()
  } finally {
    submitting.value = false
  }
}
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
</style>

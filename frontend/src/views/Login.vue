<template>
  <div class="login-screen">
    <div class="login-wrapper">
      <div class="brand-section">
        <div class="logo-box">
          <el-icon><ShoppingBag /></el-icon>
        </div>
        <h2>电商云管理平台</h2>
        <p>专业、高效的订单与库存中心</p>
      </div>

      <div class="form-section">
        <el-form :model="form" @submit.prevent="handleLogin" size="large" class="login-form">
          <div class="input-group">
            <label>管理员账号</label>
            <el-input v-model="form.username" placeholder="请输入账号" prefix-icon="User" />
          </div>
          <div class="input-group">
            <label>访问密码</label>
            <el-input v-model="form.password" type="password" placeholder="请输入密码" prefix-icon="Lock" show-password />
          </div>
          
          <el-button type="primary" class="login-btn" :loading="loading" @click="handleLogin">
            立即进入系统
          </el-button>
        </el-form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { User, Lock, ShoppingBag } from '@element-plus/icons-vue'
import { login } from '../api/modules'

const router = useRouter()
const loading = ref(false)
const form = reactive({ username: '', password: '' })

const handleLogin = async () => {
  if (!form.username || !form.password) return
  loading.value = true
  try {
    const res = await login(form)
    localStorage.setItem('user', JSON.stringify(res.data))
    localStorage.setItem('currentAdminId', String(res.data.adminId))
    router.push('/dashboard')
  } catch (e) {
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-screen {
  min-height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  background: linear-gradient(135deg, #fffbeb 0%, #fff7ed 100%);
}

.login-wrapper {
  display: flex;
  width: 900px;
  height: 500px;
  background: #ffffff;
  border-radius: 24px;
  box-shadow: 0 20px 40px -10px rgba(255, 106, 0, 0.15);
  overflow: hidden;
}

.brand-section {
  flex: 1;
  background: linear-gradient(135deg, #ff8a00 0%, #e52e71 100%);
  padding: 60px 40px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  text-align: center;
  color: white;
}

.logo-box {
  width: 80px;
  height: 80px;
  background: rgba(255,255,255,0.2);
  backdrop-filter: blur(10px);
  border-radius: 20px;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 40px;
  margin-bottom: 24px;
}

.brand-section h2 {
  font-size: 28px;
  font-weight: 800;
  margin: 0 0 12px;
  letter-spacing: 1px;
}

.brand-section p {
  font-size: 15px;
  opacity: 0.9;
  margin: 0;
}

.form-section {
  flex: 1;
  padding: 60px 50px;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.input-group {
  margin-bottom: 24px;
}

.input-group label {
  display: block;
  font-size: 14px;
  font-weight: 700;
  color: #374151;
  margin-bottom: 8px;
}

.login-form :deep(.el-input__wrapper) {
  padding: 12px 16px;
  border-radius: 12px;
  background: #f9fafb;
}

.login-btn {
  width: 100%;
  height: 52px;
  font-size: 16px;
  font-weight: 800;
  margin-top: 16px;
  border-radius: 12px;
  box-shadow: 0 8px 16px -4px rgba(255, 106, 0, 0.3);
}
</style>

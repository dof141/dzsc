<template>
  <el-container class="sys-layout">
    <!-- 侧边栏：大圆角、现代感 -->
    <el-aside :width="isCollapse ? '80px' : '240px'" class="sys-sidebar">
      <div class="sys-logo">
        <div class="logo-icon"><el-icon><ShoppingBag /></el-icon></div>
        <span v-if="!isCollapse">电商管理台</span>
      </div>

      <el-scrollbar>
        <el-menu
          :default-active="activeMenu"
          class="sys-menu"
          :collapse="isCollapse"
          router
        >
          <div class="menu-title" v-if="!isCollapse">导航</div>
          
          <el-menu-item index="/dashboard">
            <el-icon><Monitor /></el-icon>
            <template #title>总览控制台</template>
          </el-menu-item>
          
          <div class="menu-title" v-if="!isCollapse">核心业务</div>
          
          <el-menu-item index="/products">
            <el-icon><Goods /></el-icon>
            <template #title>商品档案</template>
          </el-menu-item>
          <el-menu-item index="/categories">
            <el-icon><Grid /></el-icon>
            <template #title>品类管理</template>
          </el-menu-item>
          <el-menu-item index="/orders">
            <el-icon><List /></el-icon>
            <template #title>订单列表</template>
          </el-menu-item>
          <el-menu-item index="/inventory">
            <el-icon><Box /></el-icon>
            <template #title>库存监控</template>
          </el-menu-item>

          <div class="menu-title" v-if="!isCollapse">数据与配置</div>
          
          <el-menu-item index="/reports">
            <el-icon><PieChart /></el-icon>
            <template #title>经营报表</template>
          </el-menu-item>
          <el-menu-item index="/audit">
            <el-icon><DataBoard /></el-icon>
            <template #title>审计日志</template>
          </el-menu-item>

          <el-menu-item v-if="user && user.role === 'SUPER_ADMIN'" index="/admin-users">
            <el-icon><User /></el-icon>
            <template #title>账号权限</template>
          </el-menu-item>
        </el-menu>
      </el-scrollbar>
    </el-aside>

    <el-container>
      <!-- 顶栏：通透、明亮 -->
      <el-header class="sys-header">
        <div class="header-tools">
          <div class="tool-btn" @click="isCollapse = !isCollapse">
            <el-icon><Expand v-if="isCollapse" /><Fold v-else /></el-icon>
          </div>
          <div class="breadcrumb">{{ currentRouteName }}</div>
        </div>

        <div class="header-profile">
          <div class="tool-btn" @click="refreshKey++" title="刷新页面数据">
            <el-icon><Refresh /></el-icon>
          </div>
          <el-divider direction="vertical" />
          <el-dropdown @command="handleCommand">
            <div class="user-avatar-box">
              <el-avatar :size="36" class="avatar">{{ user ? user.realName.charAt(0) : 'A' }}</el-avatar>
              <div class="user-desc">
                <span class="name">{{ user ? user.realName : '管理员' }}</span>
                <span class="role">Admin</span>
              </div>
              <el-icon><ArrowDown /></el-icon>
            </div>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="profile">
                  <el-icon><User /></el-icon>个人中心
                </el-dropdown-item>
                <el-dropdown-item divided command="logout" style="color: #ef4444; font-weight: 800;">
                  <el-icon><SwitchButton /></el-icon>退出系统
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </el-header>

      <el-main class="sys-main">
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { computed, ref, provide } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import {
  ArrowDown, Expand, Fold, ShoppingBag, Monitor,
  Goods, Grid, List, Box, PieChart, DataBoard,
  User, Refresh, SwitchButton
} from '@element-plus/icons-vue'
import { logout } from '../api/modules'

const route = useRoute()
const router = useRouter()
const isCollapse = ref(false)
const activeMenu = computed(() => route.path)
const user = ref(JSON.parse(localStorage.getItem('user') || 'null'))

const refreshKey = ref(0)
provide('refreshKey', refreshKey)

const currentRouteName = computed(() => {
  const map = {
    '/dashboard': '总览控制台',
    '/products': '商品档案',
    '/categories': '品类管理',
    '/orders': '订单列表',
    '/inventory': '库存监控',
    '/reports': '经营报表',
    '/audit': '审计日志',
    '/admin-users': '账号权限',
    '/profile': '个人中心'
  }
  return map[route.path] || '主页'
})

const handleCommand = async (command) => {
  if (command === 'profile') {
    router.push('/profile')
  } else if (command === 'logout') {
    try { await logout() } catch (e) {}
    localStorage.clear()
    router.push('/login')
  }
}
</script>

<style scoped>
.sys-layout {
  height: 100vh;
}

.sys-sidebar {
  background: #ffffff;
  box-shadow: 4px 0 20px rgba(0,0,0,0.02);
  display: flex;
  flex-direction: column;
  z-index: 10;
}

.sys-logo {
  height: 80px;
  display: flex;
  align-items: center;
  padding: 0 20px;
  gap: 12px;
}

.logo-icon {
  width: 40px;
  height: 40px;
  background: linear-gradient(135deg, #ff8a00 0%, #ff6a00 100%);
  border-radius: 12px;
  display: flex;
  justify-content: center;
  align-items: center;
  color: white;
  font-size: 24px;
}

.sys-logo span {
  font-weight: 800;
  font-size: 18px;
  color: #111827;
  letter-spacing: 1px;
}

.sys-menu {
  border-right: none !important;
  padding: 10px;
}

.menu-title {
  padding: 16px 12px 8px;
  font-size: 12px;
  font-weight: 800;
  color: #9ca3af;
  text-transform: uppercase;
  letter-spacing: 1px;
}

.sys-menu :deep(.el-menu-item) {
  height: 48px;
  line-height: 48px;
  border-radius: 10px;
  margin-bottom: 4px;
  color: #4b5563;
  font-weight: 700;
}

.sys-menu :deep(.el-menu-item.is-active) {
  background: #fff7ed !important;
  color: #ea580c !important;
}

.sys-menu :deep(.el-menu-item:hover) {
  background-color: #f3f4f6 !important;
}

.sys-header {
  background: rgba(255,255,255,0.9);
  backdrop-filter: blur(12px);
  border-bottom: 1px solid #f3f4f6;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 30px;
  height: 72px !important;
}

.header-tools {
  display: flex;
  align-items: center;
  gap: 20px;
}

.tool-btn {
  width: 40px;
  height: 40px;
  border-radius: 10px;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 20px;
  color: #6b7280;
  cursor: pointer;
  transition: all 0.2s;
}

.tool-btn:hover {
  background: #f3f4f6;
  color: #ff6a00;
}

.breadcrumb {
  font-size: 18px;
  font-weight: 800;
  color: #111827;
}

.header-profile {
  display: flex;
  align-items: center;
  gap: 16px;
}

.user-avatar-box {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 6px 12px;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.2s;
}

.user-avatar-box:hover {
  background: #f3f4f6;
}

.avatar {
  background: linear-gradient(135deg, #ff8a00 0%, #ff6a00 100%);
  font-weight: 800;
}

.user-desc {
  display: flex;
  flex-direction: column;
  line-height: 1.2;
}

.user-desc .name {
  font-weight: 800;
  font-size: 14px;
  color: #1f2937;
}

.user-desc .role {
  font-size: 12px;
  color: #6b7280;
}

.sys-main {
  background-color: #f8fafc;
  padding: 30px;
}
</style>

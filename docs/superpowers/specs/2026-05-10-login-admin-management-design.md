# 登录功能与管理员管理系统设计文档

**日期**: 2026-05-10
**项目**: Oracle数据库课程作业 - 电商订单管理系统
**技术栈**: Vue3 + SpringBoot + Oracle

---

## 1. 需求概述

### 1.1 功能需求

1. **登录功能**: 用户名 + 密码登录，密码使用 SHA-256 哈希存储
2. **管理员管理**: 超级管理员可增删改查管理员账户并分配分类权限
3. **个人中心**: 管理员可查看/修改个人信息、修改密码
4. **个性化仪表盘**: 不同管理员看到不同统计数据
5. **权限控制**: 基于角色的菜单可见性和 API 访问控制

### 1.2 角色定义

| 角色 | 说明 | 权限范围 |
|------|------|----------|
| SUPER_ADMIN | 超级管理员 | 所有功能 + 管理员管理 |
| ADMIN | 普通管理员 | 个人权限范围内的功能 |

---

## 2. 数据库设计

### 2.1 新增表：admin_user

```sql
CREATE TABLE admin_user (
  admin_id    NUMBER PRIMARY KEY,
  username    VARCHAR2(50) UNIQUE NOT NULL,
  password    VARCHAR2(64) NOT NULL,       -- SHA-256 哈希
  real_name   VARCHAR2(50),
  role        VARCHAR2(20) DEFAULT 'ADMIN', -- SUPER_ADMIN / ADMIN
  status      NUMBER DEFAULT 1,            -- 1=启用, 0=禁用
  avatar      VARCHAR2(200),
  created_at  TIMESTAMP DEFAULT SYSTIMESTAMP,
  updated_at  TIMESTAMP DEFAULT SYSTIMESTAMP
);
```

### 2.2 现有表修改

`admin_category` 表结构不变，`admin_id` 外键关联到 `admin_user.admin_id`。

### 2.3 初始数据

```sql
-- 超级管理员 (密码: admin123)
INSERT INTO admin_user (admin_id, username, password, real_name, role)
VALUES (1, 'admin', '<SHA256哈希值>', '超级管理员', 'SUPER_ADMIN');

-- 电子产品管理员 (密码: 123456)
INSERT INTO admin_user (admin_id, username, password, real_name, role)
VALUES (2, 'elec_admin', '<SHA256哈希值>', '电子产品管理员', 'ADMIN');

-- 服装管理员 (密码: 123456)
INSERT INTO admin_user (admin_id, username, password, real_name, role)
VALUES (3, 'cloth_admin', '<SHA256哈希值>', '服装管理员', 'ADMIN');
```

### 2.4 序列

```sql
CREATE SEQUENCE seq_admin_user START WITH 4 INCREMENT BY 1;
```

---

## 3. 后端设计

### 3.1 新增文件

| 文件路径 | 说明 |
|----------|------|
| `entity/AdminUser.java` | 管理员实体类 |
| `mapper/AdminUserMapper.java` | 管理员数据访问 |
| `service/AdminUserService.java` | 管理员服务接口 |
| `service/impl/AdminUserServiceImpl.java` | 管理员服务实现 |
| `controller/AuthController.java` | 登录认证接口 |
| `controller/AdminUserController.java` | 管理员管理接口 |
| `interceptor/AuthInterceptor.java` | 登录拦截器 |
| `interceptor/RoleInterceptor.java` | 角色权限拦截器 |
| `annotation/RequireRole.java` | 角色注解 |
| `util/PasswordUtil.java` | 密码哈希工具 |

### 3.2 API 设计

#### 认证相关

| 接口 | 方法 | 参数 | 返回 | 说明 |
|------|------|------|------|------|
| `/api/auth/login` | POST | `{username, password}` | `Result<AdminUser>` | 登录 |
| `/api/auth/logout` | POST | - | `Result<Void>` | 登出 |
| `/api/auth/info` | GET | - | `Result<AdminUser>` | 获取当前用户信息 |
| `/api/auth/password` | PUT | `{oldPwd, newPwd}` | `Result<Void>` | 修改密码 |
| `/api/auth/profile` | PUT | `{realName, avatar}` | `Result<Void>` | 修改个人信息 |

#### 管理员管理（仅 SUPER_ADMIN）

| 接口 | 方法 | 参数 | 返回 | 说明 |
|------|------|------|------|------|
| `/api/admin-users` | GET | - | `Result<List<AdminUser>>` | 管理员列表 |
| `/api/admin-users` | POST | `AdminUser` | `Result<AdminUser>` | 创建管理员 |
| `/api/admin-users/{id}` | PUT | `AdminUser` | `Result<Void>` | 更新管理员 |
| `/api/admin-users/{id}` | DELETE | - | `Result<Void>` | 删除管理员 |
| `/api/admin-users/{id}/categories` | PUT | `List<Long>` | `Result<Void>` | 分配分类权限 |

### 3.3 认证流程

```
1. 用户提交 username + password
2. 后端查询 admin_user 表
3. 对密码进行 SHA-256 哈希比较
4. 验证通过，将用户信息存入 HttpSession
5. 返回用户信息（不含密码）
```

### 3.4 拦截器配置

```java
// AuthInterceptor - 检查登录状态
// 排除: /api/auth/login
// 拦截: /api/** 其他所有接口

// RoleInterceptor - 检查角色权限
// 检查 @RequireRole 注解
// SUPER_ADMIN 可访问所有接口
// ADMIN 只能访问非管理员管理接口
```

### 3.5 RLS 策略集成

修改现有 RLS 策略函数，从 Session 中获取 admin_id：

```sql
-- 现有方式: SYS_CONTEXT('ECOMMERCE_CTX', 'ADMIN_ID')
-- 保持不变，登录时调用 ECOMMERCE_CTX_PKG.set_admin_id()
```

---

## 4. 前端设计

### 4.1 新增页面

| 页面 | 路由 | 说明 |
|------|------|------|
| 登录页 | `/login` | 用户名密码登录表单 |
| 管理员管理 | `/admin-users` | CRUD + 权限分配 |
| 个人中心 | `/profile` | 个人信息 + 修改密码 |

### 4.2 修改页面

| 页面 | 修改内容 |
|------|----------|
| MainLayout | 移除管理员下拉，显示当前用户 + 退出按钮 |
| Dashboard | 个性化统计数据（基于权限范围） |
| 侧边栏 | 新增"管理员管理"菜单（仅 SUPER_ADMIN 可见） |

### 4.3 路由守卫

```javascript
router.beforeEach((to, from, next) => {
  const isLoggedIn = !!localStorage.getItem('user')

  if (to.path === '/login') {
    isLoggedIn ? next('/dashboard') : next()
  } else {
    isLoggedIn ? next() : next('/login')
  }
})
```

### 4.4 状态管理

使用 localStorage 存储登录用户信息：

```javascript
// 登录成功后
localStorage.setItem('user', JSON.stringify({
  adminId: 1,
  username: 'admin',
  realName: '超级管理员',
  role: 'SUPER_ADMIN'
}))

// 退出时
localStorage.removeItem('user')
```

### 4.5 侧边栏菜单

```vue
<!-- 管理员管理菜单，仅超级管理员可见 -->
<el-menu-item v-if="user.role === 'SUPER_ADMIN'" index="/admin-users">
  <el-icon><User /></el-icon>
  <template #title>管理员管理</template>
</el-menu-item>
```

### 4.6 登录页设计

- 居中卡片布局
- 用户名输入框
- 密码输入框
- 登录按钮
- 系统标题

### 4.7 管理员管理页设计

- 表格展示管理员列表
- 新增/编辑弹窗（用户名、密码、真实姓名、角色、状态）
- 分配权限弹窗（树形分类选择）
- 删除确认

### 4.8 个人中心页设计

- 左侧：头像、基本信息展示
- 右侧：修改密码表单
- 编辑个人信息按钮

---

## 5. 实现计划

### 5.1 数据库脚本

1. 创建 `admin_user` 表
2. 创建序列 `seq_admin_user`
3. 插入初始管理员数据
4. 修改 `admin_category` 表添加外键约束

### 5.2 后端实现

1. 实体类 `AdminUser`
2. Mapper `AdminUserMapper`
3. 工具类 `PasswordUtil`
4. Service 层 `AdminUserService`
5. Controller 层 `AuthController`、`AdminUserController`
6. 拦截器 `AuthInterceptor`、`RoleInterceptor`
7. 配置拦截器注册

### 5.3 前端实现

1. 登录页 `Login.vue`
2. API 接口封装
3. 路由守卫
4. 修改 `MainLayout.vue`
5. 管理员管理页 `AdminUsers.vue`
6. 个人中心页 `Profile.vue`
7. 修改 `Dashboard.vue` 个性化统计

---

## 6. 测试计划

### 6.1 功能测试

- [ ] 登录/登出流程
- [ ] 密码验证
- [ ] 路由守卫
- [ ] 管理员 CRUD
- [ ] 权限分配
- [ ] 个人信息修改
- [ ] 密码修改
- [ ] 超级管理员权限验证
- [ ] 普通管理员权限验证

### 6.2 RLS 集成测试

- [ ] 登录后 RLS 上下文设置
- [ ] 不同管理员数据隔离
- [ ] 切换管理员后数据刷新

---

## 7. 安全考虑

1. 密码 SHA-256 哈希存储，不存明文
2. 登录接口防暴力破解（可选：登录失败次数限制）
3. Session 超时设置
4. API 权限拦截，防止越权访问
5. SQL 注入防护（MyBatis 参数化查询）

---

## 8. 更新记录

| 日期 | 版本 | 说明 |
|------|------|------|
| 2026-05-10 | 1.0 | 初始设计文档 |

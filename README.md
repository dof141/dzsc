# 电商订单管理系统 - 实施计划

## Phase 1: 基础搭建

### Task 1: 初始化 SpringBoot 后端项目
- 创建 Maven pom.xml（SpringBoot 3.x + MyBatis-Plus + Oracle JDBC + Lombok）
- 创建 application.yml（Oracle 数据源、MyBatis-Plus 配置）
- 创建 EcommerceApplication.java 主类
- 创建基础包结构（controller/service/mapper/entity/config）

### Task 2: Oracle 建表脚本
- 编写 init.sql（6 张核心表 + 2 张辅助表）
- 编写 sequences.sql（9 个序列）
- 编写 triggers.sql（订单编号生成、库存变更日志、数据审计）
- 编写 test_data.sql（中等规模测试数据）

### Task 3: 初始化 Vue3 前端项目
- 用 Vite 创建 Vue3 项目
- 安装 Element Plus + ECharts + Axios + Vue Router
- 创建 Layout 组件（侧边栏 + 顶栏 + 内容区）
- 配置路由和 Axios 基础封装

## Phase 2: 核心功能

### Task 4: 商品管理模块
- 后端：Product 实体 + Mapper + Service + Controller
- Oracle: CONNECT BY 分类层级树查询
- 前端：商品列表 + 新增/编辑弹窗 + 分类树选择器

### Task 5: 库存管理模块
- 后端：Inventory 实体 + Mapper + Service + Controller
- Oracle: MERGE 语句库存同步 + 触发器日志
- 前端：库存列表 + 入库/出库操作 + 变更日志查看

### Task 6: 订单管理模块
- 后端：Order + OrderItem 实体 + Mapper + Service + Controller
- Oracle: PKG_ORDER 存储过程（下单事务、取消恢复库存）
- 前端：订单列表 + 详情 + 状态流转

### Task 7: 支付管理模块
- 后端：Payment 实体 + Mapper + Service + Controller
- Oracle: AQ 队列模拟异步支付回调
- 前端：支付记录列表

## Phase 3: 高级特性

### Task 8: 销售报表模块
- 后端：ReportService + ReportController
- Oracle: 物化视图 MV_SALES_DAILY + PIVOT 交叉报表 + PKG_REPORT
- 前端：日报/月报页面 + ECharts 图表

### Task 9: 数据审计模块
- 后端：AuditService + AuditController
- Oracle: 闪回查询对比数据变更
- 前端：审计日志列表 + 变更对比视图

### Task 10: 行级安全策略
- Oracle: DBMS_RLS 策略实现
- 后端：RLS 配置初始化
- 验证不同管理员看到不同数据

## Phase 4: 前端大屏 & 联调

### Task 11: Dashboard 统计大屏
- ECharts: 销售趋势折线图 + 分类饼图 + 订单状态柱状图
- 数字卡片：今日/本月销售额
- 库存预警列表

### Task 12: 整体联调与测试
- 前后端联调
- 所有 Oracle 特性验证
- 测试数据补充

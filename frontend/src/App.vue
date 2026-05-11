<template>
  <router-view />
</template>

<style>
:root {
  /* 活力电商橙：温暖、现代、极具辨识度 */
  --el-color-primary: #ff6a00;
  --el-color-primary-light-3: #ff954d;
  --el-color-primary-light-5: #ffb380;
  --el-color-primary-light-7: #ffd1b3;
  --el-color-primary-light-8: #ffe0cc;
  --el-color-primary-light-9: #fff0e6;
  --el-color-primary-dark-2: #cc5500;
  
  --el-color-success: #10b981;
  --el-color-warning: #f59e0b;
  --el-color-danger: #ef4444;
  --el-color-info: #6b7280;
  
  --app-bg: #f8fafc;
  --app-card-bg: #ffffff;
  --app-text-main: #1f2937;
  --app-text-muted: #6b7280;
  --app-border: #e5e7eb;
}

body {
  margin: 0;
  background-color: var(--app-bg);
  color: var(--app-text-main);
  font-family: -apple-system, BlinkMacSystemFont, "PingFang SC", "Helvetica Neue", sans-serif;
  -webkit-font-smoothing: antialiased;
}

/* 卡片风格：大圆角，柔和阴影 */
.el-card {
  border: none !important;
  border-radius: 16px !important;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.03) !important;
}

.el-card__header {
  border-bottom: 1px solid var(--app-border) !important;
  padding: 16px 24px !important;
  font-weight: 800 !important;
  font-size: 16px !important;
  color: #111827 !important;
}

/* 按钮风格：圆润饱满，拒绝纯文字链接的模糊感 */
.el-button {
  border-radius: 8px !important;
  font-weight: 700 !important;
  transition: all 0.2s ease !important;
}

/* 表格风格：极简、清晰，高对比度 */
.el-table {
  border-radius: 12px;
  overflow: hidden;
  border: 1px solid var(--app-border) !important;
}
.el-table th.el-table__cell {
  background-color: #f9fafb !important;
  color: #374151 !important;
  font-weight: 800 !important;
  padding: 14px 0 !important;
}
.el-table td.el-table__cell {
  padding: 14px 0 !important;
  border-bottom: 1px solid #f3f4f6 !important;
}
.el-table--enable-row-hover .el-table__body tr:hover > td {
  background-color: #fff7ed !important;
}

/* 弹窗表单 */
.el-form-item__label {
  font-weight: 700 !important;
  color: #374151 !important;
}

/* 选择项高对比度：彻底解决看不清的问题 */
.el-select-dropdown__item.selected {
  background-color: var(--el-color-primary) !important;
  color: #ffffff !important;
  font-weight: 800 !important;
}

.el-tree-node.is-current > .el-tree-node__content {
  background-color: var(--el-color-primary) !important;
  color: #ffffff !important;
  border-radius: 8px;
}
.el-tree-node.is-current > .el-tree-node__content .el-tree-node__label {
  color: #ffffff !important;
  font-weight: 800 !important;
}

/* 交互控件高亮 */
.el-radio__input.is-checked .el-radio__inner {
  border-color: var(--el-color-primary) !important;
  background: var(--el-color-primary) !important;
}
.el-radio__input.is-checked + .el-radio__label {
  color: var(--el-color-primary) !important;
  font-weight: 800;
}

.el-checkbox__input.is-checked .el-checkbox__inner {
  background-color: var(--el-color-primary) !important;
  border-color: var(--el-color-primary) !important;
}
.el-checkbox__input.is-checked + .el-checkbox__label {
  color: var(--el-color-primary) !important;
  font-weight: 800;
}

/* 输入框焦点 */
.el-input__wrapper.is-focus {
  box-shadow: 0 0 0 1px var(--el-color-primary) inset !important;
}

/* 滚动条 */
::-webkit-scrollbar {
  width: 8px;
  height: 8px;
}
::-webkit-scrollbar-thumb {
  background: #d1d5db;
  border-radius: 4px;
}
::-webkit-scrollbar-thumb:hover {
  background: #9ca3af;
}
</style>

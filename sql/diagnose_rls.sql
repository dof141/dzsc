-- ============================================================
-- RLS 诊断脚本
-- 用于检查 RLS 策略是否正确配置
-- ============================================================

SET SERVEROUTPUT ON;

-- 1. 检查上下文是否存在
PROMPT === 1. 检查应用上下文 ===
SELECT * FROM ALL_CONTEXT WHERE NAMESPACE = 'ECOMMERCE_CTX';

-- 2. 检查策略是否存在
PROMPT === 2. 检查 RLS 策略 ===
SELECT OBJECT_NAME, POLICY_NAME, FUNCTION_NAME, STATEMENT_TYPES
FROM ALL_POLICIES
WHERE OBJECT_OWNER = 'JW_ADMIN';

-- 3. 检查管理员映射数据
PROMPT === 3. 检查管理员映射 ===
SELECT * FROM admin_category;

-- 4. 测试上下文设置
PROMPT === 4. 测试上下文设置 ===
BEGIN
  ECOMMERCE_CTX_PKG.set_admin_id(1);
  DBMS_OUTPUT.PUT_LINE('Admin ID after set: ' || SYS_CONTEXT('ECOMMERCE_CTX', 'ADMIN_ID'));
END;
/

-- 5. 测试不设置上下文时的查询
PROMPT === 5. 测试无上下文查询 ===
BEGIN
  ECOMMERCE_CTX_PKG.set_admin_id(NULL);
END;
/
SELECT COUNT(*) AS "无上下文-商品数" FROM product;
SELECT COUNT(*) AS "无上下文-库存数" FROM inventory;

-- 6. 测试超级管理员
PROMPT === 6. 测试超级管理员 (admin_id=1) ===
BEGIN
  ECOMMERCE_CTX_PKG.set_admin_id(1);
END;
/
SELECT COUNT(*) AS "超级管理员-商品数" FROM product;
SELECT COUNT(*) AS "超级管理员-库存数" FROM inventory;

-- 7. 测试电子产品管理员
PROMPT === 7. 测试电子产品管理员 (admin_id=2) ===
BEGIN
  ECOMMERCE_CTX_PKG.set_admin_id(2);
END;
/
SELECT COUNT(*) AS "电子产品管理员-商品数" FROM product;
SELECT COUNT(*) AS "电子产品管理员-库存数" FROM inventory;

-- 8. 测试服装管理员
PROMPT === 8. 测试服装管理员 (admin_id=3) ===
BEGIN
  ECOMMERCE_CTX_PKG.set_admin_id(3);
END;
/
SELECT COUNT(*) AS "服装管理员-商品数" FROM product;
SELECT COUNT(*) AS "服装管理员-库存数" FROM inventory;

-- 9. 重置上下文
PROMPT === 9. 重置上下文 ===
BEGIN
  ECOMMERCE_CTX_PKG.set_admin_id(NULL);
END;
/

-- 10. 检查 RLS 函数源码
PROMPT === 10. 检查 fn_product_rls 函数 ===
SELECT TEXT FROM ALL_SOURCE WHERE NAME = 'FN_PRODUCT_RLS' AND TYPE = 'FUNCTION' ORDER BY LINE;

PROMPT === 11. 检查 fn_inventory_rls 函数 ===
SELECT TEXT FROM ALL_SOURCE WHERE NAME = 'FN_INVENTORY_RLS' AND TYPE = 'FUNCTION' ORDER BY LINE;

PROMPT ==========================================
PROMPT 诊断完成
PROMPT ==========================================

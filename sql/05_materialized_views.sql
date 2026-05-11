-- ============================================================
-- Oracle E-Commerce Order Management System - Materialized Views
-- 文件: 05_materialized_views.sql
-- 说明: 创建物化视图及日志，用于销售报表预聚合
--       - MV_SALES_DAILY: 按日期+分类聚合的销售日报
--       - 支持 FAST REFRESH (快速刷新)
--       - 启用 QUERY REWRITE (查询重写)
-- ============================================================

SET SERVEROUTPUT ON;

-- 删除已有的物化视图和日志（忽略不存在的错误）
BEGIN
  DBMS_MVIEW.DROP_MVIEW('MV_SALES_DAILY');
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW LOG ON order_table';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW LOG ON order_item';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW LOG ON product';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW LOG ON category';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- ============================================================
-- 创建物化视图日志（WITH ROWID 用于快速刷新）
-- ============================================================
CREATE MATERIALIZED VIEW LOG ON order_table WITH ROWID;
CREATE MATERIALIZED VIEW LOG ON order_item WITH ROWID;
CREATE MATERIALIZED VIEW LOG ON product WITH ROWID;
CREATE MATERIALIZED VIEW LOG ON category WITH ROWID;

-- ============================================================
-- MV_SALES_DAILY - 销售日报物化视图
-- 按日期 + 商品分类聚合已支付/已发货/已完成的订单
-- ============================================================
CREATE MATERIALIZED VIEW MV_SALES_DAILY
BUILD IMMEDIATE
REFRESH FAST ON DEMAND
ENABLE QUERY REWRITE
AS
SELECT TRUNC(o.created_at) AS stat_date,
       c.category_id,
       c.name AS category_name,
       COUNT(DISTINCT o.order_id) AS order_count,
       SUM(oi.subtotal) AS total_amount,
       SUM(oi.quantity) AS total_quantity
FROM order_table o
JOIN order_item oi ON o.order_id = oi.order_id
JOIN product p ON oi.product_id = p.product_id
JOIN category c ON p.category_id = c.category_id
WHERE o.status IN ('PAID', 'SHIPPED', 'DELIVERED', 'COMPLETED')
GROUP BY TRUNC(o.created_at), c.category_id, c.name;

-- 创建索引提升查询性能
CREATE INDEX idx_mv_sales_date ON MV_SALES_DAILY(stat_date);
CREATE INDEX idx_mv_sales_cat  ON MV_SALES_DAILY(category_id);

COMMIT;

PROMPT ==========================================
PROMPT 05_materialized_views.sql - MV created
PROMPT   - MV_SALES_DAILY (FAST REFRESH on demand)
PROMPT   - Materialized view logs on 4 tables
PROMPT ==========================================

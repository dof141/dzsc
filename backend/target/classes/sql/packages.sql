-- ============================================================
-- Oracle E-Commerce Order Management System - PL/SQL Packages
-- 文件: 04_packages.sql
-- 说明: 创建三个核心业务包:
--       - PKG_ORDER: 订单处理（下单事务、取消订单、状态更新）
--       - PKG_INVENTORY: 库存管理（批量同步、库存检查）
--       - PKG_REPORT: 报表统计（物化视图刷新、PIVOT 交叉报表）
-- ============================================================

SET SERVEROUTPUT ON;

-- ============================================================
-- 1. PKG_ORDER - 订单处理包
-- ============================================================

CREATE OR REPLACE PACKAGE PKG_ORDER AS
  /**
   * 创建订单（事务处理）
   * 流程: 扣减库存 -> 创建订单 -> 创建订单明细
   * p_product_ids: 商品ID列表
   * p_quantities:  对应数量列表
   */
  PROCEDURE create_order(
    p_product_ids    IN SYS.ODCINUMBERLIST,
    p_quantities     IN SYS.ODCINUMBERLIST,
    p_receiver_name  IN VARCHAR2,
    p_receiver_phone IN VARCHAR2,
    p_address        IN VARCHAR2,
    p_order_id       OUT NUMBER,
    p_order_no       OUT VARCHAR2
  );

  /**
   * 取消订单（恢复库存）
   * 仅允许取消 PENDING 状态的订单
   */
  PROCEDURE cancel_order(p_order_id IN NUMBER);

  /**
   * 更新订单状态
   * 支持: PENDING -> PAID -> SHIPPED -> DELIVERED
   */
  PROCEDURE update_status(p_order_id IN NUMBER, p_status IN VARCHAR2);
END PKG_ORDER;
/

CREATE OR REPLACE PACKAGE BODY PKG_ORDER AS

  PROCEDURE create_order(
    p_product_ids    IN SYS.ODCINUMBERLIST,
    p_quantities     IN SYS.ODCINUMBERLIST,
    p_receiver_name  IN VARCHAR2,
    p_receiver_phone IN VARCHAR2,
    p_address        IN VARCHAR2,
    p_order_id       OUT NUMBER,
    p_order_no       OUT VARCHAR2
  ) AS
    v_total_amount NUMBER(12,2) := 0;
    v_price        NUMBER(10,2);
    v_stock_qty    NUMBER;
    v_new_order_id NUMBER;
    v_new_order_no VARCHAR2(30);
  BEGIN
    -- 生成订单ID和编号
    SELECT SEQ_ORDER_ID.NEXTVAL INTO v_new_order_id FROM dual;
    SELECT 'ORD' || TO_CHAR(SYSDATE, 'YYYYMMDD') || LPAD(SEQ_ORDER_NO.NEXTVAL, 6, '0')
      INTO v_new_order_no FROM dual;

    -- 第一步: 检查库存并扣减
    FOR i IN 1..p_product_ids.COUNT LOOP
      SELECT price INTO v_price FROM product WHERE product_id = p_product_ids(i);
      SELECT quantity INTO v_stock_qty FROM inventory WHERE product_id = p_product_ids(i) FOR UPDATE;

      IF v_stock_qty < p_quantities(i) THEN
        RAISE_APPLICATION_ERROR(-20001, '商品ID=' || p_product_ids(i) || ' 库存不足，当前库存: ' || v_stock_qty);
      END IF;

      -- 扣减库存（触发器会自动记录库存日志）
      UPDATE inventory SET quantity = quantity - p_quantities(i), updated_at = SYSTIMESTAMP
        WHERE product_id = p_product_ids(i);

      v_total_amount := v_total_amount + (v_price * p_quantities(i));
    END LOOP;

    -- 第二步: 创建订单
    INSERT INTO order_table (order_id, order_no, total_amount, status, receiver_name, receiver_phone, address, created_at, updated_at)
    VALUES (v_new_order_id, v_new_order_no, v_total_amount, 'PENDING', p_receiver_name, p_receiver_phone, p_address, SYSTIMESTAMP, SYSTIMESTAMP);

    -- 第三步: 创建订单明细
    FOR i IN 1..p_product_ids.COUNT LOOP
      SELECT price INTO v_price FROM product WHERE product_id = p_product_ids(i);
      INSERT INTO order_item (item_id, order_id, product_id, quantity, unit_price)
      VALUES (SEQ_ORDER_ITEM_ID.NEXTVAL, v_new_order_id, p_product_ids(i), p_quantities(i), v_price);
    END LOOP;

    p_order_id := v_new_order_id;
    p_order_no := v_new_order_no;

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END create_order;

  PROCEDURE cancel_order(p_order_id IN NUMBER) AS
    v_status VARCHAR2(20);
  BEGIN
    SELECT status INTO v_status FROM order_table WHERE order_id = p_order_id FOR UPDATE;

    IF v_status <> 'PENDING' THEN
      RAISE_APPLICATION_ERROR(-20002, '只能取消 PENDING 状态的订单，当前状态: ' || v_status);
    END IF;

    -- 恢复库存
    FOR item IN (SELECT product_id, quantity FROM order_item WHERE order_id = p_order_id) LOOP
      UPDATE inventory SET quantity = quantity + item.quantity, updated_at = SYSTIMESTAMP
        WHERE product_id = item.product_id;
    END LOOP;

    -- 更新订单状态
    UPDATE order_table SET status = 'CANCELLED', updated_at = SYSTIMESTAMP
      WHERE order_id = p_order_id;

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END cancel_order;

  PROCEDURE update_status(p_order_id IN NUMBER, p_status IN VARCHAR2) AS
  BEGIN
    UPDATE order_table SET status = p_status, updated_at = SYSTIMESTAMP
      WHERE order_id = p_order_id;

    IF SQL%ROWCOUNT = 0 THEN
      RAISE_APPLICATION_ERROR(-20003, '订单不存在: ' || p_order_id);
    END IF;

    COMMIT;
  END update_status;

END PKG_ORDER;
/

-- ============================================================
-- 2. PKG_INVENTORY - 库存管理包
-- ============================================================

CREATE OR REPLACE PACKAGE PKG_INVENTORY AS
  /**
   * 批量库存同步（使用 MERGE 语句）
   * 如果商品已有库存记录则累加，否则新建记录
   */
  PROCEDURE sync_inventory(
    p_product_ids IN SYS.ODCINUMBERLIST,
    p_quantities  IN SYS.ODCINUMBERLIST
  );

  /**
   * 检查库存是否充足
   * 返回 TRUE 表示充足，FALSE 表示不足
   */
  FUNCTION check_stock(
    p_product_id IN NUMBER,
    p_quantity   IN NUMBER
  ) RETURN BOOLEAN;
END PKG_INVENTORY;
/

CREATE OR REPLACE PACKAGE BODY PKG_INVENTORY AS

  PROCEDURE sync_inventory(
    p_product_ids IN SYS.ODCINUMBERLIST,
    p_quantities  IN SYS.ODCINUMBERLIST
  ) AS
  BEGIN
    FOR i IN 1..p_product_ids.COUNT LOOP
      MERGE INTO inventory inv
      USING (SELECT p_product_ids(i) AS product_id, p_quantities(i) AS qty FROM dual) src
      ON (inv.product_id = src.product_id)
      WHEN MATCHED THEN
        UPDATE SET inv.quantity = inv.quantity + src.qty, inv.updated_at = SYSTIMESTAMP
      WHEN NOT MATCHED THEN
        INSERT (inventory_id, product_id, quantity, safety_stock, updated_at)
        VALUES (SEQ_INVENTORY_ID.NEXTVAL, src.product_id, src.qty, 10, SYSTIMESTAMP);
    END LOOP;

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END sync_inventory;

  FUNCTION check_stock(
    p_product_id IN NUMBER,
    p_quantity   IN NUMBER
  ) RETURN BOOLEAN AS
    v_qty NUMBER;
  BEGIN
    SELECT quantity INTO v_qty FROM inventory WHERE product_id = p_product_id;
    RETURN v_qty >= p_quantity;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN FALSE;
  END check_stock;

END PKG_INVENTORY;
/

-- ============================================================
-- 3. PKG_REPORT - 报表统计包
-- ============================================================

CREATE OR REPLACE PACKAGE PKG_REPORT AS
  /**
   * 刷新销售物化视图（快速刷新）
   */
  PROCEDURE refresh_sales_mv;

  /**
   * 获取月度 PIVOT 交叉报表
   * 按分类统计12个月的销售额
   */
  PROCEDURE get_monthly_pivot(p_year IN NUMBER, p_cursor OUT SYS_REFCURSOR);

  /**
   * 获取指定日期范围的日报数据
   */
  PROCEDURE get_daily_summary(
    p_start_date IN DATE,
    p_end_date   IN DATE,
    p_cursor     OUT SYS_REFCURSOR
  );
END PKG_REPORT;
/

CREATE OR REPLACE PACKAGE BODY PKG_REPORT AS

  PROCEDURE refresh_sales_mv IS
  BEGIN
    DBMS_MVIEW.REFRESH('MV_SALES_DAILY', 'F');
  END refresh_sales_mv;

  PROCEDURE get_monthly_pivot(p_year IN NUMBER, p_cursor OUT SYS_REFCURSOR) IS
    v_sql VARCHAR2(4000);
  BEGIN
    v_sql := 'SELECT category_name, ';
    FOR i IN 1..12 LOOP
      v_sql := v_sql || 'NVL("M' || LPAD(i, 2, '0') || '", 0) AS "' || i || '"';
      IF i < 12 THEN
        v_sql := v_sql || ', ';
      END IF;
    END LOOP;
    v_sql := v_sql || ' FROM (
      SELECT category_name,
             TO_CHAR(stat_date, ''MM'') AS month_num,
             total_amount
      FROM MV_SALES_DAILY
      WHERE EXTRACT(YEAR FROM stat_date) = :1
    )
    PIVOT (SUM(total_amount) FOR month_num IN (
      ''01'' AS "M01", ''02'' AS "M02", ''03'' AS "M03", ''04'' AS "M04",
      ''05'' AS "M05", ''06'' AS "M06", ''07'' AS "M07", ''08'' AS "M08",
      ''09'' AS "M09", ''10'' AS "M10", ''11'' AS "M11", ''12'' AS "M12"
    ))
    ORDER BY category_name';
    OPEN p_cursor FOR v_sql USING p_year;
  END get_monthly_pivot;

  PROCEDURE get_daily_summary(
    p_start_date IN DATE,
    p_end_date   IN DATE,
    p_cursor     OUT SYS_REFCURSOR
  ) IS
  BEGIN
    OPEN p_cursor FOR
      SELECT stat_date, category_id, category_name,
             order_count, total_amount, total_quantity
      FROM MV_SALES_DAILY
      WHERE stat_date BETWEEN p_start_date AND p_end_date
      ORDER BY stat_date, category_name;
  END get_daily_summary;

END PKG_REPORT;
/

COMMIT;

PROMPT ==========================================
PROMPT 04_packages.sql - PL/SQL packages created
PROMPT   - PKG_ORDER (create_order/cancel_order/update_status)
PROMPT   - PKG_INVENTORY (sync_inventory/check_stock)
PROMPT   - PKG_REPORT (refresh_sales_mv/get_monthly_pivot/get_daily_summary)
PROMPT ==========================================

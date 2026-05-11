-- ============================================================
-- Oracle E-Commerce Order Management System - Triggers
-- 文件: 03_triggers.sql
-- 说明: 创建所有触发器，包括:
--       - 主键自动生成触发器 (9个)
--       - 库存变更日志触发器 (1个)
--       - 数据审计触发器 (4个: product, order_table, payment, category)
-- ============================================================

SET SERVEROUTPUT ON;

-- ============================================================
-- Part 1: 主键自动生成触发器 (BEFORE INSERT)
-- ============================================================

-- 1. TRG_CATEGORY_ID - 分类ID自动生成
CREATE OR REPLACE TRIGGER TRG_CATEGORY_ID
BEFORE INSERT ON category
FOR EACH ROW
BEGIN
  :NEW.category_id := SEQ_CATEGORY_ID.NEXTVAL;
END;
/

-- 2. TRG_PRODUCT_ID - 商品ID自动生成
CREATE OR REPLACE TRIGGER TRG_PRODUCT_ID
BEFORE INSERT ON product
FOR EACH ROW
BEGIN
  :NEW.product_id := SEQ_PRODUCT_ID.NEXTVAL;
END;
/

-- 3. TRG_INVENTORY_ID - 库存ID自动生成
CREATE OR REPLACE TRIGGER TRG_INVENTORY_ID
BEFORE INSERT ON inventory
FOR EACH ROW
BEGIN
  :NEW.inventory_id := SEQ_INVENTORY_ID.NEXTVAL;
END;
/

-- 4. TRG_ORDER_ID - 订单ID自动生成
CREATE OR REPLACE TRIGGER TRG_ORDER_ID
BEFORE INSERT ON order_table
FOR EACH ROW
BEGIN
  :NEW.order_id := SEQ_ORDER_ID.NEXTVAL;
END;
/

-- 5. TRG_ORDER_NO - 订单编号自动生成
--    格式: ORD + yyyyMMdd + 6位序号 (如: ORD20260510000001)
CREATE OR REPLACE TRIGGER TRG_ORDER_NO
BEFORE INSERT ON order_table
FOR EACH ROW
BEGIN
  :NEW.order_no := 'ORD' || TO_CHAR(SYSDATE, 'YYYYMMDD') || LPAD(SEQ_ORDER_NO.NEXTVAL, 6, '0');
END;
/

-- 6. TRG_ORDER_ITEM_ID - 订单明细ID自动生成
CREATE OR REPLACE TRIGGER TRG_ORDER_ITEM_ID
BEFORE INSERT ON order_item
FOR EACH ROW
BEGIN
  :NEW.item_id := SEQ_ORDER_ITEM_ID.NEXTVAL;
END;
/

-- 7. TRG_PAYMENT_ID - 支付ID自动生成
CREATE OR REPLACE TRIGGER TRG_PAYMENT_ID
BEFORE INSERT ON payment
FOR EACH ROW
BEGIN
  :NEW.payment_id := SEQ_PAYMENT_ID.NEXTVAL;
END;
/

-- 8. TRG_INVENTORY_LOG_ID - 库存日志ID自动生成
CREATE OR REPLACE TRIGGER TRG_INVENTORY_LOG_ID
BEFORE INSERT ON inventory_log
FOR EACH ROW
BEGIN
  :NEW.log_id := SEQ_INVENTORY_LOG_ID.NEXTVAL;
END;
/

-- 9. TRG_AUDIT_LOG_ID - 审计日志ID自动生成
CREATE OR REPLACE TRIGGER TRG_AUDIT_LOG_ID
BEFORE INSERT ON audit_log
FOR EACH ROW
BEGIN
  :NEW.audit_id := SEQ_AUDIT_LOG_ID.NEXTVAL;
END;
/

-- 10. TRG_NOTIFY_LOG_ID - 通知日志ID自动生成
CREATE OR REPLACE TRIGGER TRG_NOTIFY_LOG_ID
BEFORE INSERT ON payment_notification_log
FOR EACH ROW
BEGIN
  :NEW.log_id := SEQ_NOTIFY_LOG_ID.NEXTVAL;
END;
/

-- ============================================================
-- Part 2: 业务逻辑触发器
-- ============================================================

-- 11. TRG_INVENTORY_LOG - 库存变更日志
--     当 inventory.quantity 发生 UPDATE 时，自动记录变更日志
CREATE OR REPLACE TRIGGER TRG_INVENTORY_LOG
AFTER UPDATE ON inventory
FOR EACH ROW
DECLARE
  v_change_type VARCHAR2(20);
BEGIN
  IF :NEW.quantity > :OLD.quantity THEN
    v_change_type := 'IN';
  ELSIF :NEW.quantity < :OLD.quantity THEN
    v_change_type := 'OUT';
  ELSE
    v_change_type := 'ADJUST';
  END IF;

  INSERT INTO inventory_log (log_id, inventory_id, old_qty, new_qty, change_type, changed_at, changed_by)
  VALUES (SEQ_INVENTORY_LOG_ID.NEXTVAL, :NEW.inventory_id, :OLD.quantity, :NEW.quantity, v_change_type, SYSTIMESTAMP, USER);
END;
/

-- ============================================================
-- Part 3: 数据审计触发器 (AFTER INSERT/UPDATE/DELETE)
--         记录变更前后的 JSON 快照，支持闪回查询对比
-- ============================================================

-- 12. TRG_AUDIT_PRODUCT - 商品表审计
CREATE OR REPLACE TRIGGER TRG_AUDIT_PRODUCT
AFTER INSERT OR UPDATE OR DELETE ON product
FOR EACH ROW
DECLARE
  v_operation  VARCHAR2(10);
  v_old_value  CLOB;
  v_new_value  CLOB;
BEGIN
  IF INSERTING THEN
    v_operation := 'INSERT';
    v_new_value := '{"product_id":' || :NEW.product_id
      || ',"name":"' || :NEW.name || '"'
      || ',"price":' || :NEW.price
      || ',"category_id":' || :NEW.category_id
      || ',"status":' || :NEW.status || '}';
  ELSIF UPDATING THEN
    v_operation := 'UPDATE';
    v_old_value := '{"product_id":' || :OLD.product_id
      || ',"name":"' || :OLD.name || '"'
      || ',"price":' || :OLD.price
      || ',"category_id":' || :OLD.category_id
      || ',"status":' || :OLD.status || '}';
    v_new_value := '{"product_id":' || :NEW.product_id
      || ',"name":"' || :NEW.name || '"'
      || ',"price":' || :NEW.price
      || ',"category_id":' || :NEW.category_id
      || ',"status":' || :NEW.status || '}';
  ELSIF DELETING THEN
    v_operation := 'DELETE';
    v_old_value := '{"product_id":' || :OLD.product_id
      || ',"name":"' || :OLD.name || '"'
      || ',"price":' || :OLD.price
      || ',"category_id":' || :OLD.category_id
      || ',"status":' || :OLD.status || '}';
  END IF;

  INSERT INTO audit_log (audit_id, table_name, record_id, operation, old_value, new_value, operated_at, operated_by)
  VALUES (SEQ_AUDIT_LOG_ID.NEXTVAL, 'PRODUCT',
          COALESCE(:NEW.product_id, :OLD.product_id),
          v_operation, v_old_value, v_new_value, SYSTIMESTAMP, USER);
END;
/

-- 13. TRG_AUDIT_ORDER - 订单表审计
CREATE OR REPLACE TRIGGER TRG_AUDIT_ORDER
AFTER INSERT OR UPDATE OR DELETE ON order_table
FOR EACH ROW
DECLARE
  v_operation  VARCHAR2(10);
  v_old_value  CLOB;
  v_new_value  CLOB;
BEGIN
  IF INSERTING THEN
    v_operation := 'INSERT';
    v_new_value := '{"order_id":' || :NEW.order_id
      || ',"order_no":"' || :NEW.order_no || '"'
      || ',"status":"' || :NEW.status || '"'
      || ',"total_amount":' || :NEW.total_amount || '}';
  ELSIF UPDATING THEN
    v_operation := 'UPDATE';
    v_old_value := '{"order_id":' || :OLD.order_id
      || ',"order_no":"' || :OLD.order_no || '"'
      || ',"status":"' || :OLD.status || '"'
      || ',"total_amount":' || :OLD.total_amount || '}';
    v_new_value := '{"order_id":' || :NEW.order_id
      || ',"order_no":"' || :NEW.order_no || '"'
      || ',"status":"' || :NEW.status || '"'
      || ',"total_amount":' || :NEW.total_amount || '}';
  ELSIF DELETING THEN
    v_operation := 'DELETE';
    v_old_value := '{"order_id":' || :OLD.order_id
      || ',"order_no":"' || :OLD.order_no || '"'
      || ',"status":"' || :OLD.status || '"'
      || ',"total_amount":' || :OLD.total_amount || '}';
  END IF;

  INSERT INTO audit_log (audit_id, table_name, record_id, operation, old_value, new_value, operated_at, operated_by)
  VALUES (SEQ_AUDIT_LOG_ID.NEXTVAL, 'ORDER_TABLE',
          COALESCE(:NEW.order_id, :OLD.order_id),
          v_operation, v_old_value, v_new_value, SYSTIMESTAMP, USER);
END;
/

-- 14. TRG_AUDIT_PAYMENT - 支付表审计
CREATE OR REPLACE TRIGGER TRG_AUDIT_PAYMENT
AFTER INSERT OR UPDATE OR DELETE ON payment
FOR EACH ROW
DECLARE
  v_operation  VARCHAR2(10);
  v_old_value  CLOB;
  v_new_value  CLOB;
BEGIN
  IF INSERTING THEN
    v_operation := 'INSERT';
    v_new_value := '{"payment_id":' || :NEW.payment_id
      || ',"order_id":' || :NEW.order_id
      || ',"amount":' || :NEW.amount
      || ',"status":"' || :NEW.status || '"}';
  ELSIF UPDATING THEN
    v_operation := 'UPDATE';
    v_old_value := '{"payment_id":' || :OLD.payment_id
      || ',"order_id":' || :OLD.order_id
      || ',"amount":' || :OLD.amount
      || ',"status":"' || :OLD.status || '"}';
    v_new_value := '{"payment_id":' || :NEW.payment_id
      || ',"order_id":' || :NEW.order_id
      || ',"amount":' || :NEW.amount
      || ',"status":"' || :NEW.status || '"}';
  ELSIF DELETING THEN
    v_operation := 'DELETE';
    v_old_value := '{"payment_id":' || :OLD.payment_id
      || ',"order_id":' || :OLD.order_id
      || ',"amount":' || :OLD.amount
      || ',"status":"' || :OLD.status || '"}';
  END IF;

  INSERT INTO audit_log (audit_id, table_name, record_id, operation, old_value, new_value, operated_at, operated_by)
  VALUES (SEQ_AUDIT_LOG_ID.NEXTVAL, 'PAYMENT',
          COALESCE(:NEW.payment_id, :OLD.payment_id),
          v_operation, v_old_value, v_new_value, SYSTIMESTAMP, USER);
END;
/

-- 15. TRG_AUDIT_CATEGORY - 分类表审计
CREATE OR REPLACE TRIGGER TRG_AUDIT_CATEGORY
AFTER INSERT OR UPDATE OR DELETE ON category
FOR EACH ROW
DECLARE
  v_operation  VARCHAR2(10);
  v_old_value  CLOB;
  v_new_value  CLOB;
BEGIN
  IF INSERTING THEN
    v_operation := 'INSERT';
    v_new_value := '{"category_id":' || :NEW.category_id
      || ',"name":"' || :NEW.name || '"'
      || ',"category_level":' || :NEW.category_level || '}';
  ELSIF UPDATING THEN
    v_operation := 'UPDATE';
    v_old_value := '{"category_id":' || :OLD.category_id
      || ',"name":"' || :OLD.name || '"'
      || ',"category_level":' || :OLD.category_level || '}';
    v_new_value := '{"category_id":' || :NEW.category_id
      || ',"name":"' || :NEW.name || '"'
      || ',"category_level":' || :NEW.category_level || '}';
  ELSIF DELETING THEN
    v_operation := 'DELETE';
    v_old_value := '{"category_id":' || :OLD.category_id
      || ',"name":"' || :OLD.name || '"'
      || ',"category_level":' || :OLD.category_level || '}';
  END IF;

  INSERT INTO audit_log (audit_id, table_name, record_id, operation, old_value, new_value, operated_at, operated_by)
  VALUES (SEQ_AUDIT_LOG_ID.NEXTVAL, 'CATEGORY',
          COALESCE(:NEW.category_id, :OLD.category_id),
          v_operation, v_old_value, v_new_value, SYSTIMESTAMP, USER);
END;
/

COMMIT;

PROMPT ==========================================
PROMPT 03_triggers.sql - All triggers created
PROMPT   - 10 ID generation triggers
PROMPT   - 1 inventory log trigger
PROMPT   - 4 audit triggers (product/order/payment/category)
PROMPT ==========================================

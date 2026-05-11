SET SERVEROUTPUT ON;
SET LINESIZE 200;
SET PAGESIZE 100;

-- Check admin_category data
PROMPT === Checking admin_category ===
SELECT admin_id, category_id FROM admin_category;

-- Insert data if empty
PROMPT === Inserting admin_category data ===
DELETE FROM admin_category;
INSERT INTO admin_category (admin_id, category_id) VALUES (1, NULL);
INSERT INTO admin_category (admin_id, category_id) VALUES (2, 1);
INSERT INTO admin_category (admin_id, category_id) VALUES (3, 2);
COMMIT;

-- Verify
PROMPT === Verify admin_category ===
SELECT admin_id, category_id FROM admin_category;

-- Test RLS function
PROMPT === Testing RLS function ===
DECLARE
  v_result VARCHAR2(4000);
BEGIN
  ECOMMERCE_CTX_PKG.set_admin_id(1);
  v_result := fn_product_rls('JW_ADMIN', 'PRODUCT');
  DBMS_OUTPUT.PUT_LINE('Admin 1 RLS: ' || v_result);
END;
/

-- Test query with context
PROMPT === Testing queries ===
BEGIN
  ECOMMERCE_CTX_PKG.set_admin_id(1);
END;
/
SELECT COUNT(*) AS admin1_count FROM product;

BEGIN
  ECOMMERCE_CTX_PKG.set_admin_id(2);
END;
/
SELECT COUNT(*) AS admin2_count FROM product;

BEGIN
  ECOMMERCE_CTX_PKG.set_admin_id(3);
END;
/
SELECT COUNT(*) AS admin3_count FROM product;

-- Reset
BEGIN
  ECOMMERCE_CTX_PKG.set_admin_id(NULL);
END;
/

PROMPT Done!

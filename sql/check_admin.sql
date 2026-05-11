-- Check admin_category table
SELECT * FROM admin_category;

-- Check context value
BEGIN
  ECOMMERCE_CTX_PKG.set_admin_id(1);
  DBMS_OUTPUT.PUT_LINE('Context value: ' || SYS_CONTEXT('ECOMMERCE_CTX', 'ADMIN_ID'));
END;
/

-- Test the RLS function directly
DECLARE
  v_result VARCHAR2(4000);
BEGIN
  ECOMMERCE_CTX_PKG.set_admin_id(1);
  v_result := fn_product_rls('JW_ADMIN', 'PRODUCT');
  DBMS_OUTPUT.PUT_LINE('RLS result for admin 1: ' || v_result);
END;
/

DECLARE
  v_result VARCHAR2(4000);
BEGIN
  ECOMMERCE_CTX_PKG.set_admin_id(2);
  v_result := fn_product_rls('JW_ADMIN', 'PRODUCT');
  DBMS_OUTPUT.PUT_LINE('RLS result for admin 2: ' || v_result);
END;
/

-- Reset
BEGIN
  ECOMMERCE_CTX_PKG.set_admin_id(NULL);
END;
/

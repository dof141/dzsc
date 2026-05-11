-- ============================================================
-- Oracle 用户创建及授权脚本
-- 文件: 00_create_user.sql
-- 说明: 创建 jw_admin 用户并授予所有必要权限
-- 执行: 使用 sys 或 system 用户连接后执行
-- ============================================================

SET SERVEROUTPUT ON;

-- ============================================================
-- 1. 删除已存在的用户（忽略不存在的错误）
-- ============================================================
BEGIN
  EXECUTE IMMEDIATE 'DROP USER jw_admin CASCADE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- ============================================================
-- 2. 创建用户
--    密码: oracle123
--    默认表空间: USERS
--    临时表空间: TEMP
-- ============================================================
CREATE USER jw_admin
  IDENTIFIED BY oracle123
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP
  QUOTA UNLIMITED ON USERS;

-- ============================================================
-- 3. 基础权限
-- ============================================================
GRANT CREATE SESSION TO jw_admin;          -- 登录权限
GRANT CREATE TABLE TO jw_admin;            -- 建表权限
GRANT CREATE VIEW TO jw_admin;             -- 创建视图
GRANT CREATE SEQUENCE TO jw_admin;         -- 创建序列
GRANT CREATE PROCEDURE TO jw_admin;        -- 创建存储过程/函数
GRANT CREATE TRIGGER TO jw_admin;          -- 创建触发器
GRANT CREATE TYPE TO jw_admin;             -- 创建类型

-- ============================================================
-- 4. 高级特性权限（Oracle课程演示用）
-- ============================================================
GRANT CREATE MATERIALIZED VIEW TO jw_admin;   -- 物化视图
GRANT QUERY REWRITE TO jw_admin;              -- 查询重写
GRANT CREATE ANY CONTEXT TO jw_admin;         -- 应用上下文（RLS用）
GRANT EXECUTE ON DBMS_SESSION TO jw_admin;    -- 会话管理（RLS用）
GRANT EXECUTE ON DBMS_RLS TO jw_admin;        -- 行级安全策略
GRANT EXECUTE ON DBMS_AQADM TO jw_admin;      -- 高级队列管理
GRANT EXECUTE ON DBMS_AQ TO jw_admin;         -- 高级队列操作
GRANT EXECUTE ON DBMS_MVIEW TO jw_admin;      -- 物化视图刷新

-- ============================================================
-- 5. 其他常用权限
-- ============================================================
GRANT CREATE ANY INDEX TO jw_admin;
GRANT ALTER ANY TABLE TO jw_admin;
GRANT ALTER ANY INDEX TO jw_admin;
GRANT DROP ANY TABLE TO jw_admin;
GRANT DROP ANY INDEX TO jw_admin;
GRANT DROP ANY VIEW TO jw_admin;
GRANT DROP ANY SEQUENCE TO jw_admin;
GRANT DROP ANY PROCEDURE TO jw_admin;
GRANT DROP ANY TRIGGER TO jw_admin;

-- ============================================================
-- 6. 验证
-- ============================================================
SELECT username, account_status, default_tablespace
FROM dba_users
WHERE username = 'JW_ADMIN';

PROMPT ==========================================
PROMPT 用户 jw_admin 创建完成
PROMPT   - 密码: oracle123
PROMPT   - 表空间: USERS
PROMPT   - 已授权: 基础权限 + 高级特性权限
PROMPT ==========================================

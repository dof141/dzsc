-- ============================================================
-- Oracle Advanced Queueing (AQ) Setup
-- 文件: 06_aq_setup.sql
-- 说明: 创建支付通知队列，演示 Oracle AQ 高级队列功能
--       - Q_PAYMENT_NOTIFY: 支付通知队列
--       - SP_ENQUEUE_PAYMENT_NOTIFY: 入队存储过程
--       - SP_DEQUEUE_PAYMENT_NOTIFY: 出队存储过程
--       - payment_notification_log: 通知日志表
-- 注意: 需要 DBA 授权: GRANT EXECUTE ON DBMS_AQADM TO jw_admin;
-- ============================================================

SET SERVEROUTPUT ON;

-- ============================================================
-- 1. 清理已有的队列资源（忽略不存在的错误）
-- ============================================================
BEGIN
  DBMS_AQADM.STOP_QUEUE('Q_PAYMENT_NOTIFY');
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  DBMS_AQADM.DROP_QUEUE(queue_name => 'Q_PAYMENT_NOTIFY');
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  DBMS_AQADM.DROP_QUEUE_TABLE(queue_table => 'QT_PAYMENT_NOTIFY');
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- ============================================================
-- 2. 创建队列表 (Queue Table)
--    使用 SYS.AQ$_JMS_TEXT_MESSAGE 作为消息载荷类型
-- ============================================================
BEGIN
  DBMS_AQADM.CREATE_QUEUE_TABLE(
    queue_table        => 'QT_PAYMENT_NOTIFY',
    queue_payload_type => 'SYS.AQ$_JMS_TEXT_MESSAGE',
    multiple_consumers => FALSE,
    compatible         => '10.0.0'
  );
END;
/

-- ============================================================
-- 3. 创建队列
-- ============================================================
BEGIN
  DBMS_AQADM.CREATE_QUEUE(
    queue_name  => 'Q_PAYMENT_NOTIFY',
    queue_table => 'QT_PAYMENT_NOTIFY'
  );
END;
/

-- ============================================================
-- 4. 启动队列
-- ============================================================
BEGIN
  DBMS_AQADM.START_QUEUE(
    queue_name => 'Q_PAYMENT_NOTIFY'
  );
END;
/

-- ============================================================
-- 5. 入队存储过程 - 发送支付通知消息
-- ============================================================
CREATE OR REPLACE PROCEDURE SP_ENQUEUE_PAYMENT_NOTIFY(
  p_payment_id IN NUMBER,
  p_message    IN VARCHAR2
) AS
  enqueue_options    DBMS_AQ.ENQUEUE_OPTIONS_T;
  message_properties DBMS_AQ.MESSAGE_PROPERTIES_T;
  message_handle     RAW(16);
  payload            SYS.AQ$_JMS_TEXT_MESSAGE;
BEGIN
  payload := SYS.AQ$_JMS_TEXT_MESSAGE.construct();
  payload.set_text(p_message);

  DBMS_AQ.ENQUEUE(
    queue_name         => 'Q_PAYMENT_NOTIFY',
    enqueue_options    => enqueue_options,
    message_properties => message_properties,
    payload            => payload,
    msgid              => message_handle
  );

  COMMIT;
END SP_ENQUEUE_PAYMENT_NOTIFY;
/

-- ============================================================
-- 6. 出队存储过程 - 接收支付通知消息
-- ============================================================
CREATE OR REPLACE PROCEDURE SP_DEQUEUE_PAYMENT_NOTIFY(
  p_message OUT VARCHAR2
) AS
  dequeue_options    DBMS_AQ.DEQUEUE_OPTIONS_T;
  message_properties DBMS_AQ.MESSAGE_PROPERTIES_T;
  message_handle     RAW(16);
  payload            SYS.AQ$_JMS_TEXT_MESSAGE;
BEGIN
  dequeue_options.wait := DBMS_AQ.NO_WAIT;

  DBMS_AQ.DEQUEUE(
    queue_name         => 'Q_PAYMENT_NOTIFY',
    dequeue_options    => dequeue_options,
    message_properties => message_properties,
    payload            => payload,
    msgid              => message_handle
  );

  payload.get_text(p_message);
  COMMIT;
EXCEPTION
  WHEN DBMS_AQ.NO_DATA_FOUND THEN
    p_message := NULL;
END SP_DEQUEUE_PAYMENT_NOTIFY;
/

COMMIT;

PROMPT ==========================================
PROMPT 06_aq_setup.sql - AQ queue created
PROMPT   - Q_PAYMENT_NOTIFY (payment notification queue)
PROMPT   - SP_ENQUEUE_PAYMENT_NOTIFY (enqueue procedure)
PROMPT   - SP_DEQUEUE_PAYMENT_NOTIFY (dequeue procedure)
PROMPT ==========================================

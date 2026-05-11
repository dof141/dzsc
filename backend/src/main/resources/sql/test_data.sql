-- ============================================================
-- Oracle E-Commerce Order Management System - Test Data
-- 文件: 08_test_data.sql
-- 说明: 插入完整测试数据，包括:
--       - 15个分类（5个一级 + 10个二级）
--       - 50个商品
--       - 50条库存记录
--       - 20个订单及明细
--       - 20条支付记录
--       - 库存变更日志示例
--       - 审计日志示例
-- 注意: category_level 而非 level（Oracle 保留字修复）
-- ============================================================

SET SERVEROUTPUT ON;

-- 清理已有测试数据（按依赖关系逆序）
DELETE FROM payment_notification_log;
DELETE FROM audit_log;
DELETE FROM inventory_log;
DELETE FROM payment;
DELETE FROM order_item;
DELETE FROM order_table;
DELETE FROM inventory;
DELETE FROM product;
DELETE FROM admin_category;
DELETE FROM category;
COMMIT;

-- ============================================================
-- 1. 商品分类 (15个: 5个一级分类 + 10个二级分类)
-- ============================================================

-- 一级分类
INSERT INTO category (name, parent_id, category_level, sort_order) VALUES ('电子产品', NULL, 1, 1);
INSERT INTO category (name, parent_id, category_level, sort_order) VALUES ('服装',     NULL, 1, 2);
INSERT INTO category (name, parent_id, category_level, sort_order) VALUES ('食品',     NULL, 1, 3);
INSERT INTO category (name, parent_id, category_level, sort_order) VALUES ('图书',     NULL, 1, 4);
INSERT INTO category (name, parent_id, category_level, sort_order) VALUES ('家居',     NULL, 1, 5);

-- 电子产品子分类 (parent_id = 1)
INSERT INTO category (name, parent_id, category_level, sort_order) VALUES ('手机',       1, 2, 1);
INSERT INTO category (name, parent_id, category_level, sort_order) VALUES ('笔记本电脑', 1, 2, 2);
INSERT INTO category (name, parent_id, category_level, sort_order) VALUES ('耳机/音箱',  1, 2, 3);

-- 服装子分类 (parent_id = 2)
INSERT INTO category (name, parent_id, category_level, sort_order) VALUES ('男装',     2, 2, 1);
INSERT INTO category (name, parent_id, category_level, sort_order) VALUES ('女装',     2, 2, 2);
INSERT INTO category (name, parent_id, category_level, sort_order) VALUES ('运动服饰', 2, 2, 3);

-- 食品子分类 (parent_id = 3)
INSERT INTO category (name, parent_id, category_level, sort_order) VALUES ('零食', 3, 2, 1);
INSERT INTO category (name, parent_id, category_level, sort_order) VALUES ('饮品', 3, 2, 2);

-- 图书子分类 (parent_id = 4)
INSERT INTO category (name, parent_id, category_level, sort_order) VALUES ('计算机', 4, 2, 1);
INSERT INTO category (name, parent_id, category_level, sort_order) VALUES ('文学',   4, 2, 2);

-- 家居子分类 (parent_id = 5)
INSERT INTO category (name, parent_id, category_level, sort_order) VALUES ('家具', 5, 2, 1);

COMMIT;

-- ============================================================
-- 2. 商品 (50个)
-- ============================================================

-- 手机 (category_id = 6)
INSERT INTO product (category_id, name, price, unit, description) VALUES (6, '华为 Mate 60 Pro',        6999.00, '台', '华为旗舰手机，麒麟芯片');
INSERT INTO product (category_id, name, price, unit, description) VALUES (6, 'iPhone 15 Pro Max',      9999.00, '台', 'Apple旗舰手机，A17 Pro芯片');
INSERT INTO product (category_id, name, price, unit, description) VALUES (6, '小米 14 Ultra',           5999.00, '台', '小米影像旗舰，徕卡镜头');
INSERT INTO product (category_id, name, price, unit, description) VALUES (6, 'OPPO Find X7',            4999.00, '台', 'OPPO年度旗舰，哈苏影像');
INSERT INTO product (category_id, name, price, unit, description) VALUES (6, 'vivo X100 Pro',           4999.00, '台', 'vivo影像旗舰，蔡司镜头');
INSERT INTO product (category_id, name, price, unit, description) VALUES (6, '三星 Galaxy S24 Ultra',   9699.00, '台', '三星AI手机，S Pen');

-- 笔记本电脑 (category_id = 7)
INSERT INTO product (category_id, name, price, unit, description) VALUES (7, 'MacBook Pro 14 M3',         14999.00, '台', 'Apple M3芯片，Liquid Retina XDR');
INSERT INTO product (category_id, name, price, unit, description) VALUES (7, '联想 ThinkPad X1 Carbon',   11999.00, '台', '商务旗舰轻薄本');
INSERT INTO product (category_id, name, price, unit, description) VALUES (7, '华为 MateBook X Pro',        9999.00, '台', '3.1K OLED触控屏');
INSERT INTO product (category_id, name, price, unit, description) VALUES (7, '戴尔 XPS 15',               12999.00, '台', 'InfinityEdge全面屏');
INSERT INTO product (category_id, name, price, unit, description) VALUES (7, '华硕 ROG 幻16',             13999.00, '台', '高性能游戏笔记本');

-- 耳机/音箱 (category_id = 8)
INSERT INTO product (category_id, name, price, unit, description) VALUES (8, 'AirPods Pro 2',         1899.00, '副', '主动降噪，自适应音频');
INSERT INTO product (category_id, name, price, unit, description) VALUES (8, '索尼 WH-1000XM5',       2499.00, '副', '行业领先降噪头戴耳机');
INSERT INTO product (category_id, name, price, unit, description) VALUES (8, '华为 FreeBuds Pro 3',   1499.00, '副', '智慧降噪，高清音质');
INSERT INTO product (category_id, name, price, unit, description) VALUES (8, 'JBL Flip 6 蓝牙音箱',    799.00, '台', '防水便携蓝牙音箱');
INSERT INTO product (category_id, name, price, unit, description) VALUES (8, 'Bose SoundLink Flex',    999.00, '台', '便携式蓝牙音箱');

-- 男装 (category_id = 9)
INSERT INTO product (category_id, name, price, unit, description) VALUES (9, '纯棉圆领T恤',     99.00,  '件', '100%纯棉，舒适透气');
INSERT INTO product (category_id, name, price, unit, description) VALUES (9, '商务休闲西装',    899.00,  '套', '修身剪裁，适合多种场合');
INSERT INTO product (category_id, name, price, unit, description) VALUES (9, '牛仔裤 直筒款',   299.00,  '条', '经典直筒版型，弹力面料');
INSERT INTO product (category_id, name, price, unit, description) VALUES (9, 'POLO衫 翻领短袖', 199.00,  '件', '珠地棉面料，透气舒适');
INSERT INTO product (category_id, name, price, unit, description) VALUES (9, '羽绒服 轻薄款',   599.00,  '件', '白鸭绒填充，轻便保暖');

-- 女装 (category_id = 10)
INSERT INTO product (category_id, name, price, unit, description) VALUES (10, '连衣裙 碎花款',   259.00, '件', '雪纺面料，飘逸灵动');
INSERT INTO product (category_id, name, price, unit, description) VALUES (10, '针织开衫',        189.00, '件', '柔软亲肤，百搭款式');
INSERT INTO product (category_id, name, price, unit, description) VALUES (10, '高腰阔腿裤',      239.00, '条', '显瘦高腰设计，垂感面料');
INSERT INTO product (category_id, name, price, unit, description) VALUES (10, '真丝衬衫',        399.00, '件', '桑蚕丝面料，优雅知性');
INSERT INTO product (category_id, name, price, unit, description) VALUES (10, '半身裙 A字裙',    179.00, '条', 'A字版型，显瘦百搭');

-- 运动服饰 (category_id = 11)
INSERT INTO product (category_id, name, price, unit, description) VALUES (11, '速干运动T恤',    129.00, '件', '吸湿速干，适合跑步健身');
INSERT INTO product (category_id, name, price, unit, description) VALUES (11, '瑜伽裤',         199.00, '条', '高弹力面料，四向弹力');
INSERT INTO product (category_id, name, price, unit, description) VALUES (11, '运动短裤',        99.00, '条', '网眼内衬，透气排汗');
INSERT INTO product (category_id, name, price, unit, description) VALUES (11, '冲锋衣 防水款',  699.00, '件', 'GORE-TEX面料，防风防水');

-- 零食 (category_id = 12)
INSERT INTO product (category_id, name, price, unit, description) VALUES (12, '坚果礼盒 混合装',  168.00, '盒', '每日坚果，健康零食');
INSERT INTO product (category_id, name, price, unit, description) VALUES (12, '巧克力礼盒',       128.00, '盒', '比利时进口可可脂');
INSERT INTO product (category_id, name, price, unit, description) VALUES (12, '牛肉干 原味',        79.00, '袋', '内蒙古风干牛肉');
INSERT INTO product (category_id, name, price, unit, description) VALUES (12, '曲奇饼干 礼盒装',   88.00, '盒', '丹麦配方，手工烘焙');
INSERT INTO product (category_id, name, price, unit, description) VALUES (12, '果脯蜜饯 组合装',   56.00, '袋', '天然水果制作');

-- 饮品 (category_id = 13)
INSERT INTO product (category_id, name, price, unit, description) VALUES (13, '龙井茶 特级',       298.00, '罐', '明前龙井，色绿香郁');
INSERT INTO product (category_id, name, price, unit, description) VALUES (13, '咖啡豆 意式拼配',   128.00, '袋', '深度烘焙，浓郁醇厚');
INSERT INTO product (category_id, name, price, unit, description) VALUES (13, '进口红酒 AOC级',    198.00, '瓶', '法国波尔多产区');
INSERT INTO product (category_id, name, price, unit, description) VALUES (13, '鲜榨橙汁 1L装',      28.00, '瓶', 'NFC非浓缩还原');

-- 计算机 (category_id = 14)
INSERT INTO product (category_id, name, price, unit, description) VALUES (14, 'Java编程思想 第5版',     108.00, '本', 'Java经典著作');
INSERT INTO product (category_id, name, price, unit, description) VALUES (14, '深入理解计算机系统',      139.00, '本', 'CSAPP经典教材');
INSERT INTO product (category_id, name, price, unit, description) VALUES (14, '算法导论 第4版',          128.00, '本', 'MIT经典算法教材');
INSERT INTO product (category_id, name, price, unit, description) VALUES (14, 'Spring实战 第6版',         89.00, '本', 'Spring框架权威指南');
INSERT INTO product (category_id, name, price, unit, description) VALUES (14, 'MySQL是怎样运行的',        79.00, '本', 'MySQL底层原理详解');

-- 文学 (category_id = 15)
INSERT INTO product (category_id, name, price, unit, description) VALUES (15, '百年孤独',   55.00, '本', '马尔克斯魔幻现实主义巨作');
INSERT INTO product (category_id, name, price, unit, description) VALUES (15, '三体 全集',  93.00, '套', '刘慈欣科幻经典三部曲');
INSERT INTO product (category_id, name, price, unit, description) VALUES (15, '活着',       39.00, '本', '余华经典长篇小说');
INSERT INTO product (category_id, name, price, unit, description) VALUES (15, '红楼梦',     59.00, '本', '中国古典四大名著之一');
INSERT INTO product (category_id, name, price, unit, description) VALUES (15, '小王子',     32.00, '本', '圣埃克苏佩里经典童话');

-- 家具 (category_id = 16)
INSERT INTO product (category_id, name, price, unit, description) VALUES (16, '实木书桌 简约款',  1299.00, '张', '北美白橡木，简约设计');
INSERT INTO product (category_id, name, price, unit, description) VALUES (16, '人体工学椅',       1899.00, '把', '可调节头枕腰靠，网布透气');

COMMIT;

-- ============================================================
-- 3. 库存 (50条，每个商品对应一条)
-- ============================================================

INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (1,  120, 20);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (2,   80, 15);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (3,  200, 30);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (4,  150, 20);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (5,   95, 15);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (6,   60, 10);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (7,   45, 10);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (8,   70, 10);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (9,   55, 10);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (10,  40,  8);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (11,  35,  8);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (12, 300, 50);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (13, 180, 30);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (14, 220, 40);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (15, 100, 20);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (16,  90, 15);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (17, 500, 100);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (18, 120, 20);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (19, 250, 50);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (20,  80, 15);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (21, 300, 60);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (22, 200, 40);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (23, 180, 30);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (24, 150, 25);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (25, 220, 40);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (26, 350, 70);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (27, 280, 50);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (28, 160, 30);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (29,  90, 15);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (30, 600, 100);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (31, 400, 80);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (32, 250, 50);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (33, 300, 60);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (34, 500, 100);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (35, 200, 40);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (36, 150, 30);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (37, 350, 70);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (38, 180, 35);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (39, 800, 150);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (40, 500, 100);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (41, 300, 60);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (42, 400, 80);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (43, 250, 50);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (44, 350, 70);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (45, 150, 30);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (46, 200, 40);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (47, 120, 25);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (48,  60, 10);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (49,  45, 10);
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES (50,  30,  5);

COMMIT;

-- ============================================================
-- 4. 订单 (20个订单及明细)
--    order_id 和 order_no 由触发器自动生成
-- ============================================================

-- Order 1 - PAID, 2 items
INSERT INTO order_table (total_amount, status, receiver_name, receiver_phone, address, created_at)
VALUES (11898.00, 'PAID', '张三', '13800001111', '北京市朝阳区建国路88号', SYSTIMESTAMP - INTERVAL '25' DAY);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (1, 2, 1, 9999.00);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (1, 12, 1, 1899.00);

-- Order 2 - PAID, 3 items
INSERT INTO order_table (total_amount, status, receiver_name, receiver_phone, address, created_at)
VALUES (7926.00, 'PAID', '李四', '13800002222', '上海市浦东新区陆家嘴环路1000号', SYSTIMESTAMP - INTERVAL '23' DAY);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (2, 1, 1, 6999.00);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (2, 15, 1, 799.00);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (2, 42, 1, 128.00);

-- Order 3 - SHIPPED, 1 item
INSERT INTO order_table (total_amount, status, receiver_name, receiver_phone, address, created_at)
VALUES (14999.00, 'SHIPPED', '王五', '13800003333', '深圳市南山区科技园南路', SYSTIMESTAMP - INTERVAL '20' DAY);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (3, 7, 1, 14999.00);

-- Order 4 - PAID, 4 items
INSERT INTO order_table (total_amount, status, receiver_name, receiver_phone, address, created_at)
VALUES (722.00, 'PAID', '赵六', '13800004444', '广州市天河区体育西路', SYSTIMESTAMP - INTERVAL '18' DAY);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (4, 17, 3, 99.00);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (4, 27, 2, 129.00);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (4, 36, 1, 128.00);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (4, 46, 1, 39.00);

-- Order 5 - DELIVERED, 2 items
INSERT INTO order_table (total_amount, status, receiver_name, receiver_phone, address, created_at)
VALUES (12088.00, 'DELIVERED', '孙七', '13800005555', '杭州市西湖区文三路', SYSTIMESTAMP - INTERVAL '15' DAY);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (5, 8, 1, 11999.00);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (5, 44, 1, 89.00);

-- Order 6 - PENDING, 1 item
INSERT INTO order_table (total_amount, status, receiver_name, receiver_phone, address, created_at)
VALUES (5999.00, 'PENDING', '周八', '13800006666', '成都市锦江区春熙路', SYSTIMESTAMP - INTERVAL '12' DAY);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (6, 3, 1, 5999.00);

-- Order 7 - PAID, 5 items
INSERT INTO order_table (total_amount, status, receiver_name, receiver_phone, address, created_at)
VALUES (1267.00, 'PAID', '吴九', '13800007777', '武汉市江汉区解放大道', SYSTIMESTAMP - INTERVAL '10' DAY);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (7, 31, 2, 168.00);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (7, 32, 1, 128.00);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (7, 33, 1, 79.00);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (7, 37, 2, 298.00);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (7, 38, 1, 128.00);

-- Order 8 - SHIPPED, 2 items
INSERT INTO order_table (total_amount, status, receiver_name, receiver_phone, address, created_at)
VALUES (11498.00, 'SHIPPED', '郑十', '13800008888', '南京市鼓楼区中山北路', SYSTIMESTAMP - INTERVAL '8' DAY);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (8, 9, 1, 9999.00);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (8, 14, 1, 1499.00);

-- Order 9 - PAID, 3 items
INSERT INTO order_table (total_amount, status, receiver_name, receiver_phone, address, created_at)
VALUES (1502.00, 'PAID', '钱十一', '13800009999', '重庆市渝中区解放碑', SYSTIMESTAMP - INTERVAL '7' DAY);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (9, 40, 2, 55.00);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (9, 41, 1, 93.00);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (9, 49, 1, 1299.00);

-- Order 10 - DELIVERED, 1 item
INSERT INTO order_table (total_amount, status, receiver_name, receiver_phone, address, created_at)
VALUES (1899.00, 'DELIVERED', '冯十二', '13800010000', '西安市雁塔区高新路', SYSTIMESTAMP - INTERVAL '6' DAY);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (10, 50, 1, 1899.00);

-- Order 11 - PENDING, 2 items
INSERT INTO order_table (total_amount, status, receiver_name, receiver_phone, address, created_at)
VALUES (2578.00, 'PENDING', '陈十三', '13800011111', '天津市和平区南京路', SYSTIMESTAMP - INTERVAL '5' DAY);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (11, 13, 1, 2499.00);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (11, 43, 1, 79.00);

-- Order 12 - PAID, 3 items
INSERT INTO order_table (total_amount, status, receiver_name, receiver_phone, address, created_at)
VALUES (1177.00, 'PAID', '褚十四', '13800012222', '苏州市工业园区星湖街', SYSTIMESTAMP - INTERVAL '4' DAY);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (12, 18, 1, 899.00);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (12, 28, 1, 199.00);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (12, 35, 1, 79.00);

-- Order 13 - CANCELLED, 1 item
INSERT INTO order_table (total_amount, status, receiver_name, receiver_phone, address, created_at)
VALUES (4999.00, 'CANCELLED', '卫十五', '13800013333', '厦门市思明区中山路', SYSTIMESTAMP - INTERVAL '3' DAY);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (13, 4, 1, 4999.00);

-- Order 14 - PAID, 2 items
INSERT INTO order_table (total_amount, status, receiver_name, receiver_phone, address, created_at)
VALUES (658.00, 'PAID', '蒋十六', '13800014444', '青岛市市南区香港中路', SYSTIMESTAMP - INTERVAL '3' DAY);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (14, 22, 1, 259.00);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (14, 24, 1, 399.00);

-- Order 15 - SHIPPED, 4 items
INSERT INTO order_table (total_amount, status, receiver_name, receiver_phone, address, created_at)
VALUES (537.00, 'SHIPPED', '沈十七', '13800015555', '长沙市岳麓区麓山路', SYSTIMESTAMP - INTERVAL '2' DAY);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (15, 21, 2, 189.00);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (15, 29, 1, 99.00);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (15, 45, 1, 32.00);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (15, 48, 1, 28.00);

-- Order 16 - PAID, 2 items
INSERT INTO order_table (total_amount, status, receiver_name, receiver_phone, address, created_at)
VALUES (10698.00, 'PAID', '韩十八', '13800016666', '郑州市金水区经三路', SYSTIMESTAMP - INTERVAL '2' DAY);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (16, 6, 1, 9699.00);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (16, 16, 1, 999.00);

-- Order 17 - DELIVERED, 3 items
INSERT INTO order_table (total_amount, status, receiver_name, receiver_phone, address, created_at)
VALUES (175.00, 'DELIVERED', '杨十九', '13800017777', '大连市中山区人民路', SYSTIMESTAMP - INTERVAL '1' DAY);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (17, 34, 1, 88.00);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (17, 39, 1, 28.00);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (17, 47, 1, 59.00);

-- Order 18 - PENDING, 1 item
INSERT INTO order_table (total_amount, status, receiver_name, receiver_phone, address, created_at)
VALUES (9699.00, 'PENDING', '朱二十', '13800018888', '济南市历下区泉城路', SYSTIMESTAMP - INTERVAL '1' DAY);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (18, 6, 1, 9699.00);

-- Order 19 - PAID, 2 items
INSERT INTO order_table (total_amount, status, receiver_name, receiver_phone, address, created_at)
VALUES (938.00, 'PAID', '秦二一', '13800019999', '昆明市五华区东风西路', SYSTIMESTAMP);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (19, 30, 1, 699.00);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (19, 23, 1, 239.00);

-- Order 20 - SHIPPED, 3 items
INSERT INTO order_table (total_amount, status, receiver_name, receiver_phone, address, created_at)
VALUES (950.00, 'SHIPPED', '尤二二', '13800020000', '福州市鼓楼区八一七路', SYSTIMESTAMP);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (20, 20, 1, 599.00);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (20, 26, 2, 129.00);
INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES (20, 41, 1, 93.00);

COMMIT;

-- ============================================================
-- 5. 支付记录 (20条)
-- ============================================================

-- 已支付订单: 1, 2, 4, 7, 9, 12, 14, 16, 19
INSERT INTO payment (order_id, amount, payment_method, payment_time, status, transaction_no)
VALUES (1,  11898.00, 'ALIPAY',     SYSTIMESTAMP - INTERVAL '25' DAY, 'SUCCESS', 'TXN20260415001');
INSERT INTO payment (order_id, amount, payment_method, payment_time, status, transaction_no)
VALUES (2,   7926.00, 'WECHAT',     SYSTIMESTAMP - INTERVAL '23' DAY, 'SUCCESS', 'TXN20260417001');
INSERT INTO payment (order_id, amount, payment_method, payment_time, status, transaction_no)
VALUES (4,    722.00, 'ALIPAY',     SYSTIMESTAMP - INTERVAL '18' DAY, 'SUCCESS', 'TXN20260422001');
INSERT INTO payment (order_id, amount, payment_method, payment_time, status, transaction_no)
VALUES (7,   1267.00, 'CREDIT_CARD', SYSTIMESTAMP - INTERVAL '10' DAY, 'SUCCESS', 'TXN20260430001');
INSERT INTO payment (order_id, amount, payment_method, payment_time, status, transaction_no)
VALUES (9,   1502.00, 'WECHAT',     SYSTIMESTAMP - INTERVAL '7' DAY,  'SUCCESS', 'TXN20260503001');
INSERT INTO payment (order_id, amount, payment_method, payment_time, status, transaction_no)
VALUES (12,  1177.00, 'ALIPAY',     SYSTIMESTAMP - INTERVAL '4' DAY,  'SUCCESS', 'TXN20260506001');
INSERT INTO payment (order_id, amount, payment_method, payment_time, status, transaction_no)
VALUES (14,   658.00, 'CREDIT_CARD', SYSTIMESTAMP - INTERVAL '3' DAY,  'SUCCESS', 'TXN20260507001');
INSERT INTO payment (order_id, amount, payment_method, payment_time, status, transaction_no)
VALUES (16, 10698.00, 'ALIPAY',     SYSTIMESTAMP - INTERVAL '2' DAY,  'SUCCESS', 'TXN20260508001');
INSERT INTO payment (order_id, amount, payment_method, payment_time, status, transaction_no)
VALUES (19,   938.00, 'WECHAT',     SYSTIMESTAMP,                      'SUCCESS', 'TXN20260510001');

-- 已发货订单: 3, 8, 15, 20
INSERT INTO payment (order_id, amount, payment_method, payment_time, status, transaction_no)
VALUES (3,  14999.00, 'ALIPAY',     SYSTIMESTAMP - INTERVAL '20' DAY, 'SUCCESS', 'TXN20260420001');
INSERT INTO payment (order_id, amount, payment_method, payment_time, status, transaction_no)
VALUES (8,  11498.00, 'WECHAT',     SYSTIMESTAMP - INTERVAL '8' DAY,  'SUCCESS', 'TXN20260502001');
INSERT INTO payment (order_id, amount, payment_method, payment_time, status, transaction_no)
VALUES (15,   537.00, 'CREDIT_CARD', SYSTIMESTAMP - INTERVAL '2' DAY,  'SUCCESS', 'TXN20260508002');
INSERT INTO payment (order_id, amount, payment_method, payment_time, status, transaction_no)
VALUES (20,   950.00, 'ALIPAY',     SYSTIMESTAMP,                      'SUCCESS', 'TXN20260510002');

-- 已完成订单: 5, 10, 17
INSERT INTO payment (order_id, amount, payment_method, payment_time, status, transaction_no)
VALUES (5,  12088.00, 'WECHAT',     SYSTIMESTAMP - INTERVAL '15' DAY, 'SUCCESS', 'TXN20260425001');
INSERT INTO payment (order_id, amount, payment_method, payment_time, status, transaction_no)
VALUES (10,  1899.00, 'ALIPAY',     SYSTIMESTAMP - INTERVAL '6' DAY,  'SUCCESS', 'TXN20260504001');
INSERT INTO payment (order_id, amount, payment_method, payment_time, status, transaction_no)
VALUES (17,   175.00, 'WECHAT',     SYSTIMESTAMP - INTERVAL '1' DAY,  'SUCCESS', 'TXN20260509001');

-- 待支付订单: 6, 11, 18
INSERT INTO payment (order_id, amount, payment_method, status)
VALUES (6,  5999.00, 'ALIPAY',     'PENDING');
INSERT INTO payment (order_id, amount, payment_method, status)
VALUES (11, 2578.00, 'WECHAT',     'PENDING');
INSERT INTO payment (order_id, amount, payment_method, status)
VALUES (18, 9699.00, 'CREDIT_CARD', 'PENDING');

-- 已取消订单: 13 (退款)
INSERT INTO payment (order_id, amount, payment_method, payment_time, status, transaction_no)
VALUES (13, 4999.00, 'ALIPAY', SYSTIMESTAMP - INTERVAL '3' DAY, 'REFUNDED', 'TXN20260507002');

COMMIT;

-- ============================================================
-- 6. 库存变更日志示例
--    正常情况由 TRG_INVENTORY_LOG 触发器自动写入
--    此处手动插入历史数据用于测试展示
-- ============================================================

INSERT INTO inventory_log (inventory_id, old_qty, new_qty, change_type, changed_at, changed_by)
VALUES (1, 100, 120, 'IN',   SYSTIMESTAMP - INTERVAL '30' DAY, 'SYSTEM');
INSERT INTO inventory_log (inventory_id, old_qty, new_qty, change_type, changed_at, changed_by)
VALUES (2,  60,  80, 'IN',   SYSTIMESTAMP - INTERVAL '28' DAY, 'SYSTEM');
INSERT INTO inventory_log (inventory_id, old_qty, new_qty, change_type, changed_at, changed_by)
VALUES (7,  50,  45, 'OUT',  SYSTIMESTAMP - INTERVAL '25' DAY, 'ORDER_SERVICE');
INSERT INTO inventory_log (inventory_id, old_qty, new_qty, change_type, changed_at, changed_by)
VALUES (12, 280, 300, 'IN',  SYSTIMESTAMP - INTERVAL '22' DAY, 'WAREHOUSE');
INSERT INTO inventory_log (inventory_id, old_qty, new_qty, change_type, changed_at, changed_by)
VALUES (3, 210, 200, 'OUT',  SYSTIMESTAMP - INTERVAL '20' DAY, 'ORDER_SERVICE');
INSERT INTO inventory_log (inventory_id, old_qty, new_qty, change_type, changed_at, changed_by)
VALUES (6,  65,  60, 'OUT',  SYSTIMESTAMP - INTERVAL '18' DAY, 'ORDER_SERVICE');
INSERT INTO inventory_log (inventory_id, old_qty, new_qty, change_type, changed_at, changed_by)
VALUES (49, 50,  45, 'OUT',  SYSTIMESTAMP - INTERVAL '15' DAY, 'ORDER_SERVICE');
INSERT INTO inventory_log (inventory_id, old_qty, new_qty, change_type, changed_at, changed_by)
VALUES (50, 35,  30, 'OUT',  SYSTIMESTAMP - INTERVAL '12' DAY, 'ORDER_SERVICE');
INSERT INTO inventory_log (inventory_id, old_qty, new_qty, change_type, changed_at, changed_by)
VALUES (21, 310, 300, 'OUT', SYSTIMESTAMP - INTERVAL '10' DAY, 'ORDER_SERVICE');
INSERT INTO inventory_log (inventory_id, old_qty, new_qty, change_type, changed_at, changed_by)
VALUES (30, 580, 600, 'IN',  SYSTIMESTAMP - INTERVAL '5' DAY,  'WAREHOUSE');

COMMIT;

-- ============================================================
-- 7. 审计日志示例
--    正常情况由审计触发器自动写入
--    此处手动插入历史数据用于测试展示
-- ============================================================

INSERT INTO audit_log (table_name, record_id, operation, old_value, new_value, operated_at, operated_by)
VALUES ('product', 1, 'UPDATE',
  '{"price": 6499.00, "status": 1}',
  '{"price": 6999.00, "status": 1}',
  SYSTIMESTAMP - INTERVAL '20' DAY, 'ADMIN');

INSERT INTO audit_log (table_name, record_id, operation, old_value, new_value, operated_at, operated_by)
VALUES ('product', 3, 'UPDATE',
  '{"price": 5499.00}',
  '{"price": 5999.00}',
  SYSTIMESTAMP - INTERVAL '18' DAY, 'ADMIN');

INSERT INTO audit_log (table_name, record_id, operation, old_value, new_value, operated_at, operated_by)
VALUES ('order_table', 13, 'UPDATE',
  '{"status": "PENDING"}',
  '{"status": "CANCELLED"}',
  SYSTIMESTAMP - INTERVAL '3' DAY, 'CUSTOMER_SERVICE');

INSERT INTO audit_log (table_name, record_id, operation, old_value, new_value, operated_at, operated_by)
VALUES ('inventory', 1, 'UPDATE',
  '{"quantity": 100}',
  '{"quantity": 120}',
  SYSTIMESTAMP - INTERVAL '30' DAY, 'WAREHOUSE_ADMIN');

INSERT INTO audit_log (table_name, record_id, operation, old_value, new_value, operated_at, operated_by)
VALUES ('category', 6, 'INSERT',
  NULL,
  '{"name": "手机", "parent_id": 1, "category_level": 2}',
  SYSTIMESTAMP - INTERVAL '60' DAY, 'ADMIN');

INSERT INTO audit_log (table_name, record_id, operation, old_value, new_value, operated_at, operated_by)
VALUES ('product', 50, 'INSERT',
  NULL,
  '{"name": "人体工学椅", "price": 1899.00, "category_id": 16}',
  SYSTIMESTAMP - INTERVAL '45' DAY, 'ADMIN');

INSERT INTO audit_log (table_name, record_id, operation, old_value, new_value, operated_at, operated_by)
VALUES ('order_table', 1, 'UPDATE',
  '{"status": "PENDING"}',
  '{"status": "PAID"}',
  SYSTIMESTAMP - INTERVAL '25' DAY, 'PAYMENT_SERVICE');

INSERT INTO audit_log (table_name, record_id, operation, old_value, new_value, operated_at, operated_by)
VALUES ('order_table', 5, 'UPDATE',
  '{"status": "SHIPPED"}',
  '{"status": "DELIVERED"}',
  SYSTIMESTAMP - INTERVAL '14' DAY, 'LOGISTICS_SERVICE');

COMMIT;

PROMPT ==========================================
PROMPT 08_test_data.sql - Test data inserted
PROMPT   - 15 categories (5 L1 + 10 L2)
PROMPT   - 50 products
PROMPT   - 50 inventory records
PROMPT   - 20 orders with items
PROMPT   - 20 payment records
PROMPT   - 10 inventory log entries
PROMPT   - 8 audit log entries
PROMPT ==========================================

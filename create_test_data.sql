-- ============================================
-- SQLBot 测试数据库 - 电商业务场景
-- ============================================

-- 创建测试数据库
DROP DATABASE IF EXISTS ecommerce_demo;
CREATE DATABASE ecommerce_demo;

-- 连接到新数据库
\c ecommerce_demo;

-- ============================================
-- 1. 用户表 (users)
-- ============================================
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    gender VARCHAR(10),
    birth_date DATE,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    user_level VARCHAR(20) DEFAULT 'Bronze',
    total_spent DECIMAL(10, 2) DEFAULT 0,
    city VARCHAR(50),
    province VARCHAR(50)
);

COMMENT ON TABLE users IS '用户信息表';
COMMENT ON COLUMN users.user_id IS '用户ID';
COMMENT ON COLUMN users.username IS '用户名';
COMMENT ON COLUMN users.email IS '邮箱';
COMMENT ON COLUMN users.user_level IS '会员等级: Bronze, Silver, Gold, Platinum';
COMMENT ON COLUMN users.total_spent IS '累计消费金额';

-- ============================================
-- 2. 商品分类表 (categories)
-- ============================================
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL,
    parent_category_id INT,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE categories IS '商品分类表';
COMMENT ON COLUMN categories.category_name IS '分类名称';
COMMENT ON COLUMN categories.parent_category_id IS '父分类ID';

-- ============================================
-- 3. 商品表 (products)
-- ============================================
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    category_id INT REFERENCES categories(category_id),
    brand VARCHAR(100),
    price DECIMAL(10, 2) NOT NULL,
    cost DECIMAL(10, 2),
    stock_quantity INT DEFAULT 0,
    sales_count INT DEFAULT 0,
    rating DECIMAL(3, 2) DEFAULT 0,
    review_count INT DEFAULT 0,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'active'
);

COMMENT ON TABLE products IS '商品信息表';
COMMENT ON COLUMN products.product_name IS '商品名称';
COMMENT ON COLUMN products.price IS '售价';
COMMENT ON COLUMN products.cost IS '成本';
COMMENT ON COLUMN products.stock_quantity IS '库存数量';
COMMENT ON COLUMN products.sales_count IS '销售数量';
COMMENT ON COLUMN products.rating IS '评分(1-5)';
COMMENT ON COLUMN products.status IS '状态: active, inactive, discontinued';

-- ============================================
-- 4. 订单表 (orders)
-- ============================================
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    order_number VARCHAR(50) NOT NULL UNIQUE,
    user_id INT REFERENCES users(user_id),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2) NOT NULL,
    discount_amount DECIMAL(10, 2) DEFAULT 0,
    shipping_fee DECIMAL(10, 2) DEFAULT 0,
    final_amount DECIMAL(10, 2) NOT NULL,
    payment_method VARCHAR(50),
    payment_status VARCHAR(20) DEFAULT 'pending',
    order_status VARCHAR(20) DEFAULT 'pending',
    shipping_address TEXT,
    shipping_city VARCHAR(50),
    shipping_province VARCHAR(50),
    shipped_date TIMESTAMP,
    delivered_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE orders IS '订单表';
COMMENT ON COLUMN orders.order_number IS '订单编号';
COMMENT ON COLUMN orders.payment_status IS '支付状态: pending, paid, refunded';
COMMENT ON COLUMN orders.order_status IS '订单状态: pending, processing, shipped, delivered, cancelled';

-- ============================================
-- 5. 订单明细表 (order_items)
-- ============================================
CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id),
    product_id INT REFERENCES products(product_id),
    product_name VARCHAR(200),
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE order_items IS '订单明细表';
COMMENT ON COLUMN order_items.quantity IS '购买数量';
COMMENT ON COLUMN order_items.unit_price IS '单价';
COMMENT ON COLUMN order_items.subtotal IS '小计';

-- ============================================
-- 6. 商品评价表 (reviews)
-- ============================================
CREATE TABLE reviews (
    review_id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(product_id),
    user_id INT REFERENCES users(user_id),
    order_id INT REFERENCES orders(order_id),
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    helpful_count INT DEFAULT 0
);

COMMENT ON TABLE reviews IS '商品评价表';
COMMENT ON COLUMN reviews.rating IS '评分(1-5星)';
COMMENT ON COLUMN reviews.helpful_count IS '有用数';

-- ============================================
-- 插入测试数据
-- ============================================

-- 插入用户数据
INSERT INTO users (username, email, phone, gender, birth_date, registration_date, user_level, total_spent, city, province) VALUES
('张三', 'zhangsan@example.com', '13800138001', '男', '1990-05-15', '2023-01-10', 'Gold', 15680.50, '北京', '北京市'),
('李四', 'lisi@example.com', '13800138002', '女', '1992-08-20', '2023-02-15', 'Silver', 8920.30, '上海', '上海市'),
('王五', 'wangwu@example.com', '13800138003', '男', '1988-03-12', '2023-03-20', 'Platinum', 28500.00, '深圳', '广东省'),
('赵六', 'zhaoliu@example.com', '13800138004', '女', '1995-11-08', '2023-04-05', 'Bronze', 3200.00, '杭州', '浙江省'),
('孙七', 'sunqi@example.com', '13800138005', '男', '1991-07-22', '2023-05-12', 'Silver', 9850.00, '成都', '四川省'),
('周八', 'zhouba@example.com', '13800138006', '女', '1993-09-30', '2023-06-18', 'Gold', 16200.00, '广州', '广东省'),
('吴九', 'wujiu@example.com', '13800138007', '男', '1989-12-05', '2023-07-22', 'Silver', 7500.00, '南京', '江苏省'),
('郑十', 'zhengshi@example.com', '13800138008', '女', '1994-04-18', '2023-08-30', 'Bronze', 2800.00, '武汉', '湖北省'),
('陈十一', 'chenshiyi@example.com', '13800138009', '男', '1987-06-25', '2023-09-10', 'Platinum', 32000.00, '西安', '陕西省'),
('刘十二', 'liushier@example.com', '13800138010', '女', '1996-02-14', '2023-10-05', 'Gold', 18900.00, '重庆', '重庆市');

-- 插入商品分类
INSERT INTO categories (category_name, parent_category_id, description) VALUES
('电子产品', NULL, '各类电子产品'),
('服装鞋帽', NULL, '服装、鞋子、帽子等'),
('食品饮料', NULL, '食品和饮料'),
('图书音像', NULL, '图书、音乐、影视'),
('家居用品', NULL, '家居装饰和日用品'),
('手机', 1, '智能手机及配件'),
('电脑', 1, '笔记本电脑、台式机'),
('男装', 2, '男士服装'),
('女装', 2, '女士服装'),
('零食', 3, '各类零食');

-- 插入商品数据
INSERT INTO products (product_name, category_id, brand, price, cost, stock_quantity, sales_count, rating, review_count, status) VALUES
('iPhone 15 Pro Max 256GB', 6, 'Apple', 9999.00, 7500.00, 150, 320, 4.8, 156, 'active'),
('华为 Mate 60 Pro 512GB', 6, '华为', 6999.00, 5200.00, 200, 450, 4.7, 203, 'active'),
('小米 14 Ultra 16GB+512GB', 6, '小米', 5999.00, 4500.00, 180, 380, 4.6, 178, 'active'),
('MacBook Pro 14英寸 M3', 7, 'Apple', 14999.00, 11000.00, 80, 120, 4.9, 89, 'active'),
('联想 ThinkPad X1 Carbon', 7, '联想', 9999.00, 7500.00, 100, 150, 4.5, 92, 'active'),
('戴尔 XPS 15', 7, 'Dell', 11999.00, 9000.00, 60, 85, 4.6, 67, 'active'),
('耐克 Air Max 270 运动鞋', 8, 'Nike', 899.00, 450.00, 500, 680, 4.4, 312, 'active'),
('阿迪达斯 Ultra Boost 跑鞋', 8, 'Adidas', 1299.00, 650.00, 400, 520, 4.5, 289, 'active'),
('优衣库 纯棉T恤', 9, 'UNIQLO', 99.00, 40.00, 1000, 1500, 4.3, 678, 'active'),
('ZARA 连衣裙', 9, 'ZARA', 399.00, 180.00, 300, 420, 4.4, 234, 'active'),
('三只松鼠 每日坚果', 10, '三只松鼠', 89.00, 45.00, 2000, 3500, 4.6, 1234, 'active'),
('良品铺子 零食大礼包', 10, '良品铺子', 199.00, 100.00, 1500, 2800, 4.5, 987, 'active');

-- 插入订单数据 (2024年数据)
INSERT INTO orders (order_number, user_id, order_date, total_amount, discount_amount, shipping_fee, final_amount, payment_method, payment_status, order_status, shipping_city, shipping_province) VALUES
('ORD202401001', 1, '2024-01-05 10:30:00', 9999.00, 500.00, 0, 9499.00, '支付宝', 'paid', 'delivered', '北京', '北京市'),
('ORD202401002', 2, '2024-01-08 14:20:00', 899.00, 0, 15.00, 914.00, '微信支付', 'paid', 'delivered', '上海', '上海市'),
('ORD202401003', 3, '2024-01-12 09:15:00', 14999.00, 1000.00, 0, 13999.00, '信用卡', 'paid', 'delivered', '深圳', '广东省'),
('ORD202402001', 1, '2024-02-03 16:45:00', 1299.00, 100.00, 15.00, 1214.00, '支付宝', 'paid', 'delivered', '北京', '北京市'),
('ORD202402002', 4, '2024-02-10 11:30:00', 398.00, 0, 15.00, 413.00, '微信支付', 'paid', 'delivered', '杭州', '浙江省'),
('ORD202403001', 5, '2024-03-05 13:20:00', 6999.00, 300.00, 0, 6699.00, '支付宝', 'paid', 'delivered', '成都', '四川省'),
('ORD202403002', 6, '2024-03-15 10:10:00', 9999.00, 500.00, 0, 9499.00, '微信支付', 'paid', 'delivered', '广州', '广东省'),
('ORD202404001', 7, '2024-04-08 15:30:00', 5999.00, 200.00, 0, 5799.00, '支付宝', 'paid', 'delivered', '南京', '江苏省'),
('ORD202404002', 8, '2024-04-20 09:45:00', 288.00, 0, 15.00, 303.00, '微信支付', 'paid', 'delivered', '武汉', '湖北省'),
('ORD202405001', 9, '2024-05-12 14:15:00', 11999.00, 600.00, 0, 11399.00, '信用卡', 'paid', 'delivered', '西安', '陕西省'),
('ORD202405002', 10, '2024-05-25 11:20:00', 1798.00, 100.00, 15.00, 1713.00, '支付宝', 'paid', 'delivered', '重庆', '重庆市'),
('ORD202406001', 1, '2024-06-08 16:30:00', 398.00, 0, 15.00, 413.00, '微信支付', 'paid', 'delivered', '北京', '北京市'),
('ORD202407001', 2, '2024-07-15 10:45:00', 6999.00, 300.00, 0, 6699.00, '支付宝', 'paid', 'delivered', '上海', '上海市'),
('ORD202408001', 3, '2024-08-20 13:30:00', 9999.00, 500.00, 0, 9499.00, '信用卡', 'paid', 'delivered', '深圳', '广东省'),
('ORD202409001', 4, '2024-09-10 09:20:00', 288.00, 0, 15.00, 303.00, '微信支付', 'paid', 'delivered', '杭州', '浙江省'),
('ORD202410001', 5, '2024-10-05 15:10:00', 5999.00, 200.00, 0, 5799.00, '支付宝', 'paid', 'shipped', '成都', '四川省'),
('ORD202410002', 6, '2024-10-18 11:40:00', 1299.00, 100.00, 15.00, 1214.00, '微信支付', 'paid', 'processing', '广州', '广东省'),
('ORD202411001', 7, '2024-11-02 14:25:00', 899.00, 0, 15.00, 914.00, '支付宝', 'paid', 'processing', '南京', '江苏省'),
('ORD202412001', 8, '2024-12-15 10:30:00', 398.00, 0, 15.00, 413.00, '微信支付', 'paid', 'pending', '武汉', '湖北省'),
('ORD202412002', 9, '2024-12-28 16:20:00', 14999.00, 1000.00, 0, 13999.00, '信用卡', 'pending', 'pending', '西安', '陕西省');

-- 插入订单明细数据
INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, subtotal) VALUES
(1, 1, 'iPhone 15 Pro Max 256GB', 1, 9999.00, 9999.00),
(2, 7, '耐克 Air Max 270 运动鞋', 1, 899.00, 899.00),
(3, 4, 'MacBook Pro 14英寸 M3', 1, 14999.00, 14999.00),
(4, 8, '阿迪达斯 Ultra Boost 跑鞋', 1, 1299.00, 1299.00),
(5, 10, 'ZARA 连衣裙', 1, 399.00, 399.00),
(6, 2, '华为 Mate 60 Pro 512GB', 1, 6999.00, 6999.00),
(7, 5, '联想 ThinkPad X1 Carbon', 1, 9999.00, 9999.00),
(8, 3, '小米 14 Ultra 16GB+512GB', 1, 5999.00, 5999.00),
(9, 11, '三只松鼠 每日坚果', 2, 89.00, 178.00),
(9, 9, '优衣库 纯棉T恤', 1, 99.00, 99.00),
(10, 6, '戴尔 XPS 15', 1, 11999.00, 11999.00),
(11, 7, '耐克 Air Max 270 运动鞋', 2, 899.00, 1798.00),
(12, 10, 'ZARA 连衣裙', 1, 399.00, 399.00),
(13, 2, '华为 Mate 60 Pro 512GB', 1, 6999.00, 6999.00),
(14, 5, '联想 ThinkPad X1 Carbon', 1, 9999.00, 9999.00),
(15, 11, '三只松鼠 每日坚果', 2, 89.00, 178.00),
(15, 9, '优衣库 纯棉T恤', 1, 99.00, 99.00),
(16, 3, '小米 14 Ultra 16GB+512GB', 1, 5999.00, 5999.00),
(17, 8, '阿迪达斯 Ultra Boost 跑鞋', 1, 1299.00, 1299.00),
(18, 7, '耐克 Air Max 270 运动鞋', 1, 899.00, 899.00),
(19, 10, 'ZARA 连衣裙', 1, 399.00, 399.00),
(20, 4, 'MacBook Pro 14英寸 M3', 1, 14999.00, 14999.00);

-- 插入商品评价数据
INSERT INTO reviews (product_id, user_id, order_id, rating, review_text, review_date, helpful_count) VALUES
(1, 1, 1, 5, 'iPhone 15 Pro Max 非常好用,拍照效果惊艳,性能强劲!', '2024-01-10 15:30:00', 45),
(7, 2, 2, 4, '鞋子很舒服,适合跑步,就是价格有点贵。', '2024-01-15 10:20:00', 23),
(4, 3, 3, 5, 'MacBook Pro M3 芯片太强了,视频剪辑非常流畅!', '2024-01-20 14:45:00', 67),
(8, 1, 4, 5, '阿迪达斯的鞋子质量一如既往的好,很满意!', '2024-02-08 09:30:00', 34),
(10, 4, 5, 4, 'ZARA的裙子款式不错,面料也舒服,推荐购买。', '2024-02-18 16:20:00', 28),
(2, 5, 6, 5, '华为 Mate 60 Pro 信号超强,拍照也很棒!', '2024-03-12 11:15:00', 56),
(5, 6, 7, 4, 'ThinkPad 键盘手感一流,商务办公首选。', '2024-03-22 13:40:00', 41),
(3, 7, 8, 5, '小米 14 Ultra 性价比超高,拍照不输旗舰!', '2024-04-15 10:25:00', 52),
(11, 8, 9, 5, '三只松鼠的坚果很新鲜,包装也很精美!', '2024-04-28 14:50:00', 89),
(6, 9, 10, 5, '戴尔 XPS 15 屏幕显示效果太棒了,设计师必备!', '2024-05-20 09:35:00', 38),
(7, 10, 11, 4, '耐克鞋子穿着舒适,就是容易脏。', '2024-06-02 15:10:00', 19),
(2, 1, 13, 5, '华为手机越用越好用,系统流畅度很高!', '2024-07-22 11:45:00', 43),
(3, 5, 16, 4, '小米手机拍照功能强大,夜景模式很赞!', '2024-10-12 16:30:00', 31);

-- 创建一些有用的视图
CREATE VIEW monthly_sales_summary AS
SELECT
    DATE_TRUNC('month', order_date) AS month,
    COUNT(*) AS order_count,
    SUM(final_amount) AS total_revenue,
    AVG(final_amount) AS avg_order_value
FROM orders
WHERE payment_status = 'paid'
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month DESC;

COMMENT ON VIEW monthly_sales_summary IS '月度销售汇总视图';

CREATE VIEW top_selling_products AS
SELECT
    p.product_id,
    p.product_name,
    p.brand,
    c.category_name,
    p.price,
    p.sales_count,
    p.rating,
    p.review_count,
    p.sales_count * p.price AS total_revenue
FROM products p
LEFT JOIN categories c ON p.category_id = c.category_id
ORDER BY p.sales_count DESC
LIMIT 20;

COMMENT ON VIEW top_selling_products IS '热销商品排行榜';

CREATE VIEW user_purchase_summary AS
SELECT
    u.user_id,
    u.username,
    u.email,
    u.user_level,
    u.city,
    u.province,
    COUNT(o.order_id) AS order_count,
    SUM(o.final_amount) AS total_spent,
    AVG(o.final_amount) AS avg_order_value,
    MAX(o.order_date) AS last_order_date
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id AND o.payment_status = 'paid'
GROUP BY u.user_id, u.username, u.email, u.user_level, u.city, u.province
ORDER BY total_spent DESC;

COMMENT ON VIEW user_purchase_summary IS '用户购买汇总视图';

-- 创建索引以提高查询性能
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_order_date ON orders(order_date);
CREATE INDEX idx_orders_payment_status ON orders(payment_status);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_reviews_product_id ON reviews(product_id);
CREATE INDEX idx_reviews_user_id ON reviews(user_id);

-- 显示数据统计
SELECT '数据插入完成!' AS status;
SELECT '用户数量: ' || COUNT(*) AS user_count FROM users;
SELECT '商品数量: ' || COUNT(*) AS product_count FROM products;
SELECT '订单数量: ' || COUNT(*) AS order_count FROM orders;
SELECT '订单明细数量: ' || COUNT(*) AS order_item_count FROM order_items;
SELECT '评价数量: ' || COUNT(*) AS review_count FROM reviews;


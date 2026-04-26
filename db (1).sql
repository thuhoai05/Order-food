CREATE DATABASE food_app;

USE food_app;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    avatar VARCHAR(255),
    phone VARCHAR(50),
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM(
        'customer',
        'admin',
        'shipper'
    ) DEFAULT 'customer',
    reward_points INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE stores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address TEXT NOT NULL,
    owner_id INT NOT NULL,
    phone VARCHAR(50),
    description TEXT,
    status ENUM(
        'pending',
        'active',
        'blocked'
    ) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (owner_id) REFERENCES users (id) ON DELETE CASCADE
);

CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE vouchers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    discount_percent INT DEFAULT 0,
    discount_amount DECIMAL(10, 2) DEFAULT 0,
    min_order_amount DECIMAL(10, 2) DEFAULT 0,
    max_uses INT DEFAULT 1,
    used_count INT DEFAULT 0,
    expired_at DATETIME NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ✨ NEW: Rewards Table (từ database-schema.sql)
CREATE TABLE rewards (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    points INT DEFAULT 0,
    total_points INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE (user_id),
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
);

CREATE TABLE user_address (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    address TEXT,
    is_default BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
);

CREATE TABLE shippers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    phone VARCHAR(50),
    vehicle VARCHAR(100),
    status ENUM(
        'idle',
        'delivering',
        'offline'
    ) DEFAULT 'idle',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
);

CREATE TABLE reward_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    order_id INT,
    points INT NOT NULL,
    type ENUM('earn', 'redeem') NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
);

CREATE TABLE notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT,
    type ENUM(
        'order',
        'promotion',
        'reward',
        'general'
    ) DEFAULT 'general',
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
);

CREATE TABLE system_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    action VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    store_id INT,
    name VARCHAR(255),
    category_id INT,
    image TEXT,
    price DECIMAL(10, 2),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (store_id) REFERENCES stores (id),
    FOREIGN KEY (category_id) REFERENCES categories (id)
);

CREATE TABLE carts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE TABLE cart_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cart_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
    UNIQUE (cart_id, product_id),
    FOREIGN KEY (cart_id) REFERENCES carts (id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    store_id INT,
    shipper_id INT,
    total_price DECIMAL(10, 2),
    status ENUM(
        'pending',
        'confirmed',
        'delivering',
        'completed',
        'cancelled'
    ) DEFAULT 'pending',
    payment_status ENUM('unpaid', 'paid') DEFAULT 'unpaid',
    address TEXT,
    voucher_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (id),
    FOREIGN KEY (voucher_id) REFERENCES vouchers (id),
    FOREIGN KEY (store_id) REFERENCES stores (id),
    FOREIGN KEY (shipper_id) REFERENCES shippers (id)
);

CREATE TABLE order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL DEFAULT 1,
    price DECIMAL(10, 2),
    FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products (id)
);

CREATE TABLE order_tracking (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    status ENUM(
        'pending',
        'confirmed',
        'delivering',
        'completed',
        'cancelled'
    ),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders (id)
);

CREATE TABLE payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT UNIQUE,
    method VARCHAR(50),
    status VARCHAR(50),
    paid_at TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders (id)
);

CREATE TABLE voucher_usages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    voucher_id INT,
    used_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (id),
    FOREIGN KEY (voucher_id) REFERENCES vouchers (id)
);

CREATE TABLE reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    product_id INT,
    rating INT,
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (id),
    FOREIGN KEY (product_id) REFERENCES products (id)
);

CREATE TABLE favorite (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    product_id INT,
    UNIQUE (user_id, product_id),
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE
);

CREATE TABLE support_tickets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    order_id INT,
    content TEXT,
    status ENUM(
        'open',
        'processing',
        'resolved'
    ) DEFAULT 'open',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (id),
    FOREIGN KEY (order_id) REFERENCES orders (id)
);

-- 1. TẠO USER CHỦ CỬA HÀNG (Giả sử id tự động = 1)
INSERT INTO
    users (name, email, password, role)
VALUES (
        'Admin Quán',
        'admin@foodapp.com',
        '123456',
        'admin'
    );

-- 2. TẠO CỬA HÀNG (Sử dụng owner_id = 1 từ user vừa tạo)
INSERT INTO
    stores (name, address, owner_id)
VALUES ('Food App Store', 'Hà Nội', 1);

-- 3. TẠO 3 DANH MỤC (Ép luôn ID 1, 2, 3 để phía dưới dễ móc vào)
INSERT INTO
    categories (id, name)
VALUES (1, 'Snacks'),
    (2, 'Fast Food'),
    (3, 'Drinks');

-- 4. THÊM TẤT CẢ SẢN PHẨM (Gắn với store_id = 1 và category_id tương ứng)
INSERT INTO
    products (
        store_id,
        category_id,
        name,
        image,
        price,
        description
    )
VALUES
    -- ===== SNACKS (category_id = 1) =====
    (
        1,
        1,
        'Khoai lang kén',
        'https://cdn.tgdd.vn/Files/2020/08/26/1284970/cach-lam-khoai-lang-ken-202008261116040688.jpg',
        20000,
        'Khoai lang chiên giòn, ngọt nhẹ.'
    ),
    (
        1,
        1,
        'Bánh tráng nướng',
        'https://cdn.tgdd.vn/2021/09/CookRecipe/Avatar/banh-trang-nuong-thumbnail.jpg',
        25000,
        'Bánh tráng nướng giòn, topping đầy đủ.'
    ),
    (
        1,
        1,
        'Chả cá viên chiên',
        'https://cdn.tgdd.vn/Files/2020/09/21/1295317/cach-lam-ca-vien-chien.jpg',
        22000,
        'Cá viên dai ngon, chiên vàng giòn.'
    ),
    (
        1,
        1,
        'Đậu phộng rang muối',
        'https://cdn.tgdd.vn/Files/2021/06/23/1363475/cach-rang-dau-phong.jpg',
        15000,
        'Đậu phộng rang giòn, mặn nhẹ.'
    ),
    (
        1,
        1,
        'Bắp xào bơ',
        'https://cdn.tgdd.vn/2020/07/CookRecipe/Avatar/bap-xao-thumbnail.jpg',
        25000,
        'Bắp xào bơ thơm béo, thêm hành phi.'
    ),
    (
        1,
        1,
        'Khô bò miếng',
        'https://cdn.tgdd.vn/Files/2021/12/02/1402570/kho-bo-mieng.jpg',
        40000,
        'Khô bò cay nhẹ, dai ngon.'
    ),
    (
        1,
        1,
        'Bánh flan',
        'https://cdn.tgdd.vn/2021/05/CookProductThumb/banh-flan.jpg',
        15000,
        'Flan mềm mịn, béo ngậy caramel.'
    ),
    (
        1,
        1,
        'Rong biển sấy',
        'https://cdn.tgdd.vn/Files/2021/07/12/1368428/rong-bien-say.jpg',
        20000,
        'Rong biển giòn tan, vị mặn nhẹ.'
    ),

-- ===== FAST FOOD (category_id = 2) =====
(
    1,
    2,
    'Cơm chiên dương châu',
    'https://cdn.tgdd.vn/2021/09/CookRecipe/Avatar/com-chien-duong-chau.jpg',
    45000,
    'Cơm chiên đầy đủ topping, đậm đà.'
),
(
    1,
    2,
    'Hủ tiếu Nam Vang',
    'https://cdn.tgdd.vn/2021/08/CookRecipe/Avatar/hu-tieu-nam-vang.jpg',
    50000,
    'Hủ tiếu nước trong, topping phong phú.'
),
(
    1,
    2,
    'Bánh mì thịt nướng',
    'https://cdn.tgdd.vn/2021/09/CookRecipe/Avatar/banh-mi-thit-nuong.jpg',
    30000,
    'Bánh mì giòn, thịt nướng thơm lừng.'
),
(
    1,
    2,
    'Bún thịt nướng',
    'https://cdn.tgdd.vn/2021/07/CookRecipe/Avatar/bun-thit-nuong.jpg',
    45000,
    'Bún tươi ăn kèm thịt nướng và rau.'
),
(
    1,
    2,
    'Cơm bò lúc lắc',
    'https://cdn.tgdd.vn/2021/10/CookRecipe/Avatar/com-bo-luc-lac.jpg',
    65000,
    'Bò mềm, xào đậm vị, ăn với cơm nóng.'
),
(
    1,
    2,
    'Mì cay Hàn Quốc',
    'https://cdn.tgdd.vn/2021/07/CookRecipe/Avatar/mi-cay.jpg',
    55000,
    'Mì cay cấp độ, topping đa dạng.'
),
(
    1,
    2,
    'Cơm gà nướng',
    'https://cdn.tgdd.vn/2021/09/CookRecipe/Avatar/com-ga-nuong.jpg',
    55000,
    'Gà nướng thơm, da giòn, cơm nóng.'
),
(
    1,
    2,
    'Bún riêu cua',
    'https://cdn.tgdd.vn/2021/08/CookRecipe/Avatar/bun-rieu.jpg',
    40000,
    'Bún riêu chua nhẹ, đậm đà.'
),

-- ===== DRINKS (category_id = 3) =====
(
    1,
    3,
    'Trà tắc',
    'https://cdn.tgdd.vn/2020/07/CookProductThumb/tra-tac.jpg',
    15000,
    'Trà tắc chua ngọt, giải khát.'
),
(
    1,
    3,
    'Sữa chua đá',
    'https://cdn.tgdd.vn/2021/05/CookProductThumb/sua-chua-da.jpg',
    20000,
    'Sữa chua mát lạnh, tốt cho tiêu hóa.'
),
(
    1,
    3,
    'Sinh tố dâu',
    'https://cdn.tgdd.vn/2020/07/CookProductThumb/sinh-to-dau.jpg',
    30000,
    'Sinh tố dâu chua ngọt, thơm ngon.'
),
(
    1,
    3,
    'Nước ép táo',
    'https://cdn.tgdd.vn/2020/07/CookProductThumb/nuoc-ep-tao.jpg',
    30000,
    'Nước ép táo tươi, giàu vitamin.'
),
(
    1,
    3,
    'Cacao đá',
    'https://cdn.tgdd.vn/2021/05/CookProductThumb/cacao-da.jpg',
    30000,
    'Cacao đá béo, đậm vị socola.'
),
(
    1,
    3,
    'Trà vải',
    'https://cdn.tgdd.vn/2020/07/CookProductThumb/tra-vai.jpg',
    30000,
    'Trà vải thơm, ngọt nhẹ.'
),
(
    1,
    3,
    'Soda chanh',
    'https://cdn.tgdd.vn/2020/07/CookProductThumb/soda-chanh.jpg',
    25000,
    'Soda chanh mát lạnh, sảng khoái.'
),
(
    1,
    3,
    'Nước ép dứa',
    'https://cdn.tgdd.vn/2020/07/CookProductThumb/nuoc-ep-dua.jpg',
    30000,
    'Nước ép dứa chua ngọt tự nhiên.'
);

INSERT INTO
    vouchers (
        code,
        discount_percent,
        discount_amount,
        min_order_amount,
        max_uses,
        expired_at
    )
VALUES (
        'WELCOME10',
        10,
        0,
        100000,
        100,
        '2024-12-31 23:59:59'
    ),
    (
        'FOODIE20',
        20,
        0,
        200000,
        50,
        '2024-12-31 23:59:59'
    ),
    (
        'SAVE50K',
        0,
        50000,
        300000,
        30,
        '2024-12-31 23:59:59'
    ),
    (
        'FREESHIP',
        0,
        30000,
        150000,
        200,
        '2024-12-31 23:59:59'
    );
-- =====================================================
-- INDEXES (từ database-schema.sql)
-- =====================================================
CREATE INDEX idx_voucher_code ON vouchers (code);

CREATE INDEX idx_reward_user ON rewards (user_id);

CREATE INDEX idx_notification_user ON notifications (user_id);

CREATE INDEX idx_notification_read ON notifications (user_id, is_read);

-- =====================================================
-- DỮ LIỆU MẪU (SAMPLE DATA)
-- =====================================================

-- Thêm user khách hàng để test
INSERT INTO
    users (
        name,
        email,
        password,
        role,
        phone
    )
VALUES (
        'Nguyễn Văn A',
        'user1@foodapp.com',
        '123456',
        'customer',
        '0912345678'
    ),
    (
        'Trần Thị B',
        'user2@foodapp.com',
        '123456',
        'customer',
        '0923456789'
    ),
    (
        'Lê Văn C',
        'shipper1@foodapp.com',
        '123456',
        'shipper',
        '0934567890'
    );

-- Thêm shipper
INSERT INTO
    shippers (
        user_id,
        phone,
        vehicle,
        status
    )
VALUES (
        3,
        '0934567890',
        'Xe máy',
        'idle'
    );

-- Thêm địa chỉ user
INSERT INTO
    user_address (user_id, address, is_default)
VALUES (
        1,
        '123 Nguyễn Trãi, Quận 1, TP.HCM',
        TRUE
    ),
    (
        1,
        '456 Lê Lợi, Quận 3, TP.HCM',
        FALSE
    ),
    (
        2,
        '789 Điện Biên Phủ, Quận Bình Thạnh, TP.HCM',
        TRUE
    );

-- Thêm giỏ hàng cho users
INSERT INTO carts (user_id) VALUES (1), (2);

-- Thêm sản phẩm vào giỏ hàng
INSERT INTO
    cart_items (cart_id, product_id, quantity)
VALUES (1, 1, 2), -- User 1: 2 khoai lang kén
    (1, 9, 1), -- User 1: 1 cơm chiên dương châu
    (1, 17, 2), -- User 1: 2 trà tắc
    (2, 5, 1), -- User 2: 1 bắp xào bơ
    (2, 13, 1);
-- User 2: 1 hủ tiếu Nam Vang

-- Thêm đơn hàng mẫu
INSERT INTO
    orders (
        user_id,
        store_id,
        total_price,
        status,
        payment_status,
        address
    )
VALUES (
        1,
        1,
        85000,
        'pending',
        'unpaid',
        '123 Nguyễn Trãi, Quận 1, TP.HCM'
    ),
    (
        1,
        1,
        95000,
        'confirmed',
        'paid',
        '123 Nguyễn Trãi, Quận 1, TP.HCM'
    ),
    (
        1,
        1,
        120000,
        'completed',
        'paid',
        '123 Nguyễn Trãi, Quận 1, TP.HCM'
    ),
    (
        1,
        1,
        65000,
        'cancelled',
        'unpaid',
        '123 Nguyễn Trãi, Quận 1, TP.HCM'
    ),
    (
        2,
        1,
        70000,
        'delivering',
        'paid',
        '789 Điện Biên Phủ, Quận Bình Thạnh, TP.HCM'
    );

-- Thêm chi tiết đơn hàng
INSERT INTO
    order_items (
        order_id,
        product_id,
        quantity,
        price
    )
VALUES (1, 1, 2, 20000), -- Order 1: 2 khoai lang kén
    (1, 9, 1, 45000), -- Order 1: 1 cơm chiên dương châu
    (2, 5, 1, 25000), -- Order 2: 1 bắp xào bơ
    (2, 17, 2, 30000), -- Order 2: 2 trà tắc
    (2, 10, 1, 40000), -- Order 2: 1 bánh mì thịt nướng
    (3, 2, 1, 25000), -- Order 3: 1 bánh tráng nướng
    (3, 11, 2, 90000), -- Order 3: 2 cơm bò lúc lắc
    (4, 6, 1, 40000), -- Order 4: 1 khô bò miếng
    (4, 18, 1, 25000), -- Order 4: 1 sữa chua đá
    (5, 12, 1, 55000), -- Order 5: 1 mì cay Hàn Quốc
    (5, 20, 1, 15000);
-- Order 5: 1 nước ép táo

-- Thêm tracking cho các đơn hàng
INSERT INTO
    order_tracking (order_id, status)
VALUES (1, 'pending'),
    (2, 'pending'),
    (2, 'confirmed'),
    (3, 'pending'),
    (3, 'confirmed'),
    (3, 'delivering'),
    (3, 'completed'),
    (4, 'pending'),
    (4, 'cancelled'),
    (5, 'pending'),
    (5, 'confirmed'),
    (5, 'delivering');

-- Thêm đánh giá mẫu
INSERT INTO
    reviews (
        user_id,
        product_id,
        rating,
        comment
    )
VALUES (
        1,
        1,
        5,
        'Khoai lang kén giòn ngon, ăn rất vui miệng!'
    ),
    (
        1,
        9,
        4,
        'Cơm chiên ngon, đầy đủ topping nhưng hơi mặn.'
    ),
    (
        1,
        17,
        5,
        'Trà tắc chua ngọt vừa, uống rất thích!'
    ),
    (
        2,
        5,
        4,
        'Bắp xào bơ thơm, nhưng hơi ít bơ.'
    ),
    (
        2,
        13,
        5,
        'Hủ tiếu Nam Vang nước dùng rất ngọt, đậm đà!'
    ),
    (
        2,
        1,
        3,
        'Khoai lang kén được nhưng không giòn lắm.'
    );

-- Thêm yêu thích
INSERT INTO
    favorite (user_id, product_id)
VALUES (1, 1), -- User 1 thích khoai lang kén
    (1, 9), -- User 1 thích cơm chiên dương châu
    (1, 17), -- User 1 thích trà tắc
    (1, 20), -- User 1 thích nước ép táo
    (2, 5), -- User 2 thích bắp xào bơ
    (2, 13), -- User 2 thích hủ tiếu Nam Vang
    (2, 2);
-- User 2 thích bánh tráng nướng

-- Thêm thông báo mẫu
INSERT INTO notifications (user_id, title, message, type, is_read) VALUES
(1, 'Đơn hàng mới', 'Bạn có đơn hàng mới #1 đang chờ xác nhận', 'order', FALSE),
(1, 'Khuyến mãi', 'Giảm 20% cho đơn hàng từ 200K!', 'promotion', TRUE),
(1, 'Tích điểm', 'Bạn đã được cộng 85 điểm thưởng!', 'reward', TRUE),
(2, 'Giao hàng', 'Đơn hàng #5 đang được giao đến bạn', 'order', FALSE),
(2, 'Đánh giá', 'Cảm ơn bạn đã đánh giá sản phẩm!', 'general', TRUE);

-- Thêm rewards cho users
INSERT INTO
    rewards (user_id, points, total_points)
VALUES (1, 100, 500),
    (2, 50, 200);

-- Thêm lịch sử rewards
INSERT INTO
    reward_history (
        user_id,
        order_id,
        points,
        type,
        description
    )
VALUES (
        1,
        3,
        120,
        'earn',
        'Đơn hàng #3 hoàn thành'
    ),
    (
        1,
        NULL,
        -50,
        'redeem',
        'Đổi voucher giảm 50K'
    ),
    (
        2,
        5,
        70,
        'earn',
        'Đơn hàng #5 hoàn thành'
    );

-- Thêm payments mẫu
INSERT INTO
    payments (
        order_id,
        method,
        status,
        paid_at
    )
VALUES (
        2,
        'cash',
        'paid',
        '2024-01-15 10:30:00'
    ),
    (
        3,
        'vnpay',
        'paid',
        '2024-01-16 14:20:00'
    ),
    (
        5,
        'cash',
        'paid',
        '2024-01-17 18:45:00'
    );
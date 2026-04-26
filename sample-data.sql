-- =====================================================
-- DỮ LIỆU MẪU (SAMPLE DATA) CHO FOOD_APP
-- Chạy file này sau khi đã tạo database và các bảng
-- =====================================================

USE food_app;

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
INSERT INTO
    notifications (
        user_id,
        title,
        message,
        type,
        is_read
    )
VALUES (
        1,
        'Đơn hàng mới',
        'Bạn có đơn hàng mới #1 đang chờ xác nhận',
        'order',
        FALSE
    ),
    (
        1,
        'Khuyến mãi',
        'Giảm 20% cho đơn hàng từ 200K!',
        'promotion',
        TRUE
    ),
    (
        1,
        'Tích điểm',
        'Bạn đã được cộng 85 điểm thưởng!',
        'reward',
        TRUE
    ),
    (
        2,
        'Giao hàng',
        'Đơn hàng #5 đang được giao đến bạn',
        'order',
        FALSE
    ),
    (
        2,
        'Đánh giá',
        'Cảm ơn bạn đã đánh giá sản phẩm!',
        'general',
        TRUE
    );

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

SELECT 'Dữ liệu mẫu đã được thêm thành công!' AS message;
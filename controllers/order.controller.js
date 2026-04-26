const db = require("../config/db");

// 1. Tạo đơn hàng mới (Create Order)
exports.createOrder = (req, res) => {
  const user_id = req.user.id; // LẤY TỪ TOKEN
  const { address } = req.body;

  // RÀO CHẮN: Kiểm tra địa chỉ
  if (!address || address.trim() === "") {
    return res
      .status(400)
      .json({ message: "Vui lòng nhập địa chỉ giao hàng!" });
  }

  // Bước 1: Tìm giỏ hàng và tự tính tổng tiền (Backend tự tính, không tin Frontend)
  const getCartSql = `
    SELECT c.id as cart_id, IFNULL(SUM(p.price * ci.quantity), 0) as real_total
    FROM carts c
    JOIN cart_items ci ON c.id = ci.cart_id
    JOIN products p ON ci.product_id = p.id
    WHERE c.user_id = ?
    GROUP BY c.id
  `;

  db.query(getCartSql, [user_id], (err, results) => {
    if (err) return res.status(500).json(err);
    if (results.length === 0 || results[0].real_total === 0) {
      return res.status(400).json({ message: "Giỏ hàng trống!" });
    }

    const cartId = results[0].cart_id;
    const realTotal = results[0].real_total;

    // Bước 2: Tạo đơn hàng vào bảng orders
    const createOrderSql =
      "INSERT INTO orders (user_id, total_price, address, status) VALUES (?, ?, ?, 'pending')";

    db.query(
      createOrderSql,
      [user_id, realTotal, address],
      (err, orderResult) => {
        if (err) return res.status(500).json(err);

        const newOrderId = orderResult.insertId;

        // Bước 3: Chép dữ liệu sang order_items (lấy luôn cả giá của sản phẩm lúc đặt)
        const copyItemsSql = `
        INSERT INTO order_items (order_id, product_id, quantity, price)
        SELECT ?, ci.product_id, ci.quantity, p.price 
        FROM cart_items ci
        JOIN products p ON ci.product_id = p.id
        WHERE ci.cart_id = ?
      `;

        db.query(copyItemsSql, [newOrderId, cartId], (err) => {
          if (err) return res.status(500).json(err);
          // 🔥 thêm tracking đầu tiên
          db.query(
            "INSERT INTO order_tracking (order_id, status) VALUES (?, ?)",
            [newOrderId, "pending"],
            (err) => {
              if (err) console.error("Tracking error:", err);
            },
          );

          // Bước 4: Xóa sạch giỏ hàng
          db.query(
            "DELETE FROM cart_items WHERE cart_id = ?",
            [cartId],
            (err) => {
              if (err) return res.status(500).json(err);
              res.json({
                message: "Đặt hàng thành công!",
                order_id: newOrderId,
                total_paid: realTotal,
                status: "pending",
              });
            },
          );
        });
      },
    );
  });
};

// 2. Lấy danh sách đơn hàng của user đang đăng nhập
exports.getUserOrders = (req, res) => {
  const user_id = req.user.id; // LẤY TỪ TOKEN

  db.query(
    "SELECT * FROM orders WHERE user_id = ? ORDER BY created_at DESC",
    [user_id],
    (err, orders) => {
      if (err) return res.status(500).json(err);
      res.json(orders);
    },
  );
};

// 3. Cập nhật trạng thái đơn hàng
exports.updateOrderStatus = (req, res) => {
  const { order_id } = req.params;
  const { status } = req.body;

  const validStatus = [
    "pending",
    "confirmed",
    "delivering",
    "completed",
    "cancelled",
  ];

  if (!validStatus.includes(status)) {
    return res.status(400).json({ message: "Trạng thái không hợp lệ" });
  }
  db.query(
    "UPDATE orders SET status = ? WHERE id = ?",
    [status, order_id],
    (err, result) => {
      if (err) return res.status(500).json(err);

      // 🔥 CHECK: order có tồn tại không
      if (result.affectedRows === 0) {
        return res.status(404).json({ message: "Order không tồn tại" });
      }

      // 🔥 thêm tracking mỗi lần update
      db.query("INSERT INTO order_tracking (order_id, status) VALUES (?, ?)", [
        order_id,
        status,
      ]);

      res.json({ message: `Đã cập nhật trạng thái đơn hàng thành: ${status}` });
    },
  );
};
// 4. Lấy chi tiết đơn hàng
exports.getOrderDetail = (req, res) => {
  const user_id = req.user.id; // từ token
  const { id } = req.params;

  const sql = `
    SELECT o.id, o.total_price, o.address, o.status, o.payment_status,
           oi.product_id, oi.quantity, oi.price,
           p.name, p.image
    FROM orders o
    JOIN order_items oi ON o.id = oi.order_id
    JOIN products p ON oi.product_id = p.id
    WHERE o.id = ? AND o.user_id = ?
  `;

  db.query(sql, [id, user_id], (err, data) => {
    if (err) return res.status(500).json(err);
    if (data.length === 0) {
      return res.status(404).json({ message: "Không tìm thấy đơn hàng" });
    }
    res.json(data);
  });
};
// 5. Tracking đơn hàng
exports.getTracking = (req, res) => {
  const user_id = req.user.id;
  const { id } = req.params;

  const sql = `
    SELECT ot.*
    FROM order_tracking ot
    JOIN orders o ON ot.order_id = o.id
    WHERE o.id = ? AND o.user_id = ?
    ORDER BY ot.created_at ASC
  `;

  db.query(sql, [id, user_id], (err, result) => {
    if (err) return res.status(500).json(err);
    res.json(result);
  });
};

// 6. Hủy đơn hàng (chỉ pending mới hủy được)
exports.cancelOrder = (req, res) => {
  const user_id = req.user.id;
  const { order_id } = req.params;

  // Kiểm tra đơn hàng tồn tại và thuộc về user
  db.query(
    "SELECT * FROM orders WHERE id = ? AND user_id = ?",
    [order_id, user_id],
    (err, orders) => {
      if (err) return res.status(500).json(err);
      if (orders.length === 0) {
        return res.status(404).json({ message: "Không tìm thấy đơn hàng" });
      }

      const order = orders[0];

      // Chỉ cho phép hủy đơn hàng đang ở trạng thái pending
      if (order.status !== "pending") {
        return res.status(400).json({ 
          message: "Không thể hủy đơn hàng đã được xác nhận hoặc đang giao" 
        });
      }

      // Cập nhật trạng thái thành cancelled
      db.query(
        "UPDATE orders SET status = 'cancelled' WHERE id = ?",
        [order_id],
        (err, result) => {
          if (err) return res.status(500).json(err);

          // Thêm tracking
          db.query(
            "INSERT INTO order_tracking (order_id, status) VALUES (?, 'cancelled')",
            [order_id],
            (err) => {
              if (err) console.error("Tracking error:", err);
            }
          );

          res.json({ message: "Đơn hàng đã được hủy thành công" });
        }
      );
    }
  );
};

// 7. Đặt lại đơn hàng (từ đơn đã hủy hoặc đã hoàn thành)
exports.reorder = (req, res) => {
  const user_id = req.user.id;
  const { order_id } = req.params;

  // Lấy thông tin đơn cũ
  db.query(
    "SELECT * FROM orders WHERE id = ? AND user_id = ?",
    [order_id, user_id],
    (err, orders) => {
      if (err) return res.status(500).json(err);
      if (orders.length === 0) {
        return res.status(404).json({ message: "Không tìm thấy đơn hàng" });
      }

      const oldOrder = orders[0];

      // Kiểm tra đơn hàng có thể đặt lại không (cancelled hoặc completed)
      if (!["cancelled", "completed"].includes(oldOrder.status)) {
        return res.status(400).json({ 
          message: "Chỉ có thể đặt lại đơn hàng đã hủy hoặc hoàn thành" 
        });
      }

      // Lấy các sản phẩm từ đơn cũ
      db.query(
        "SELECT product_id, quantity FROM order_items WHERE order_id = ?",
        [order_id],
        (err, items) => {
          if (err) return res.status(500).json(err);
          if (items.length === 0) {
            return res.status(400).json({ message: "Đơn hàng không có sản phẩm" });
          }

          // Lấy cart của user
          db.query(
            "SELECT id FROM carts WHERE user_id = ?",
            [user_id],
            (err, carts) => {
              if (err) return res.status(500).json(err);

              let cart_id;
              if (carts.length === 0) {
                // Tạo giỏ hàng mới nếu chưa có
                db.query(
                  "INSERT INTO carts (user_id) VALUES (?)",
                  [user_id],
                  (err, result) => {
                    if (err) return res.status(500).json(err);
                    cart_id = result.insertId;
                    addItemsToCart();
                  }
                );
              } else {
                cart_id = carts[0].id;
                addItemsToCart();
              }

              function addItemsToCart() {
                // Thêm từng sản phẩm vào giỏ (dùng INSERT IGNORE để tránh trùng)
                let addedCount = 0;
                items.forEach((item) => {
                  db.query(
                    `INSERT INTO cart_items (cart_id, product_id, quantity) 
                     VALUES (?, ?, ?) 
                     ON DUPLICATE KEY UPDATE quantity = quantity + ?`,
                    [cart_id, item.product_id, item.quantity, item.quantity],
                    (err) => {
                      if (err) console.error("Add to cart error:", err);
                      addedCount++;
                      if (addedCount === items.length) {
                        res.json({ 
                          message: "Đã thêm sản phẩm vào giỏ hàng",
                          cart_id: cart_id
                        });
                      }
                    }
                  );
                });
              }
            }
          );
        }
      );
    }
  );
};

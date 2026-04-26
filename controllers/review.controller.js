const db = require("../config/db");

// 1. Thêm đánh giá sản phẩm
exports.createReview = (req, res) => {
  const user_id = req.user.id;
  const { product_id, rating, comment } = req.body;

  // Validation
  if (!product_id || !rating) {
    return res.status(400).json({ message: "Thiếu product_id hoặc rating" });
  }

  if (rating < 1 || rating > 5) {
    return res.status(400).json({ message: "Rating phải từ 1 đến 5 sao" });
  }

  // Kiểm tra sản phẩm tồn tại
  db.query("SELECT id FROM products WHERE id = ?", [product_id], (err, products) => {
    if (err) return res.status(500).json(err);
    if (products.length === 0) {
      return res.status(404).json({ message: "Sản phẩm không tồn tại" });
    }

    // Thêm đánh giá
    const sql = "INSERT INTO reviews (user_id, product_id, rating, comment) VALUES (?, ?, ?, ?)";
    db.query(sql, [user_id, product_id, rating, comment || ""], (err, result) => {
      if (err) return res.status(500).json(err);
      res.json({ 
        message: "Đánh giá thành công", 
        review_id: result.insertId,
        rating,
        comment 
      });
    });
  });
};

// 2. Lấy đánh giá của một sản phẩm
exports.getProductReviews = (req, res) => {
  const { product_id } = req.params;

  const sql = `
    SELECT r.id, r.rating, r.comment, r.created_at, u.name as user_name, u.avatar as user_avatar
    FROM reviews r
    JOIN users u ON r.user_id = u.id
    WHERE r.product_id = ?
    ORDER BY r.created_at DESC
  `;

  db.query(sql, [product_id], (err, data) => {
    if (err) return res.status(500).json(err);
    res.json(data);
  });
};

// 3. Lấy đánh giá của user cho một sản phẩm
exports.getUserReviewForProduct = (req, res) => {
  const user_id = req.user.id;
  const { product_id } = req.params;

  db.query(
    "SELECT * FROM reviews WHERE user_id = ? AND product_id = ?",
    [user_id, product_id],
    (err, data) => {
      if (err) return res.status(500).json(err);
      res.json(data[0] || null);
    }
  );
};

// 4. Cập nhật đánh giá
exports.updateReview = (req, res) => {
  const user_id = req.user.id;
  const { review_id } = req.params;
  const { rating, comment } = req.body;

  if (!rating || rating < 1 || rating > 5) {
    return res.status(400).json({ message: "Rating không hợp lệ" });
  }

  // Chỉ cho phép user sửa đánh giá của chính mình
  db.query(
    "UPDATE reviews SET rating = ?, comment = ? WHERE id = ? AND user_id = ?",
    [rating, comment || "", review_id, user_id],
    (err, result) => {
      if (err) return res.status(500).json(err);
      if (result.affectedRows === 0) {
        return res.status(404).json({ message: "Không tìm thấy đánh giá" });
      }
      res.json({ message: "Cập nhật đánh giá thành công" });
    }
  );
};

// 5. Xóa đánh giá
exports.deleteReview = (req, res) => {
  const user_id = req.user.id;
  const { review_id } = req.params;

  db.query(
    "DELETE FROM reviews WHERE id = ? AND user_id = ?",
    [review_id, user_id],
    (err, result) => {
      if (err) return res.status(500).json(err);
      if (result.affectedRows === 0) {
        return res.status(404).json({ message: "Không tìm thấy đánh giá" });
      }
      res.json({ message: "Xóa đánh giá thành công" });
    }
  );
};

// 6. Lấy trung bình rating của sản phẩm
exports.getProductRating = (req, res) => {
  const { product_id } = req.params;

  const sql = `
    SELECT 
      COUNT(*) as total_reviews,
      AVG(rating) as average_rating
    FROM reviews
    WHERE product_id = ?
  `;

  db.query(sql, [product_id], (err, data) => {
    if (err) return res.status(500).json(err);
    res.json({
      product_id,
      average_rating: data[0].average_rating ? parseFloat(data[0].average_rating).toFixed(1) : 0,
      total_reviews: data[0].total_reviews || 0
    });
  });
};
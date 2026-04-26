const db = require("../config/db");

// 1. Thêm sản phẩm vào danh sách yêu thích
exports.addFavorite = (req, res) => {
  const user_id = req.user.id;
  const { product_id } = req.body;

  if (!product_id) {
    return res.status(400).json({ message: "Thiếu product_id" });
  }

  // Kiểm tra sản phẩm tồn tại
  db.query("SELECT id FROM products WHERE id = ?", [product_id], (err, products) => {
    if (err) return res.status(500).json(err);
    if (products.length === 0) {
      return res.status(404).json({ message: "Sản phẩm không tồn tại" });
    }

    // Thêm vào favorites
    const sql = "INSERT INTO favorite (user_id, product_id) VALUES (?, ?)";
    db.query(sql, [user_id, product_id], (err, result) => {
      if (err) {
        if (err.code === "ER_DUP_ENTRY") {
          return res.status(400).json({ message: "Sản phẩm đã có trong yêu thích" });
        }
        return res.status(500).json(err);
      }
      res.json({ message: "Đã thêm vào danh sách yêu thích", favorite_id: result.insertId });
    });
  });
};

// 2. Xóa sản phẩm khỏi danh sách yêu thích
exports.removeFavorite = (req, res) => {
  const user_id = req.user.id;
  const { product_id } = req.params;

  db.query(
    "DELETE FROM favorite WHERE user_id = ? AND product_id = ?",
    [user_id, product_id],
    (err, result) => {
      if (err) return res.status(500).json(err);
      if (result.affectedRows === 0) {
        return res.status(404).json({ message: "Sản phẩm không có trong yêu thích" });
      }
      res.json({ message: "Đã xóa khỏi danh sách yêu thích" });
    }
  );
};

// 3. Lấy danh sách yêu thích của user
exports.getFavorites = (req, res) => {
  const user_id = req.user.id;

  const sql = `
    SELECT p.id, p.name, p.image, p.price, p.description
    FROM favorite f
    JOIN products p ON f.product_id = p.id
    WHERE f.user_id = ?
  `;

  db.query(sql, [user_id], (err, data) => {
    if (err) return res.status(500).json(err);
    res.json(data);
  });
};

// 4. Kiểm tra sản phẩm có trong yêu thích không
exports.checkFavorite = (req, res) => {
  const user_id = req.user.id;
  const { product_id } = req.params;

  db.query(
    "SELECT id FROM favorite WHERE user_id = ? AND product_id = ?",
    [user_id, product_id],
    (err, data) => {
      if (err) return res.status(500).json(err);
      res.json({ isFavorite: data.length > 0 });
    }
  );
};
const router = require("express").Router();
const favorite = require("../controllers/favorite.controller");
const { verifyToken } = require("../middlewares/auth.middleware");

// Tất cả các route đều cần đăng nhập
router.post("/add", verifyToken, favorite.addFavorite);
router.delete("/remove/:product_id", verifyToken, favorite.removeFavorite);
router.get("/list", verifyToken, favorite.getFavorites);
router.get("/check/:product_id", verifyToken, favorite.checkFavorite);

module.exports = router;
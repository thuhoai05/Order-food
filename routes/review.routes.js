const router = require("express").Router();
const review = require("../controllers/review.controller");
const { verifyToken } = require("../middlewares/auth.middleware");

// Tất cả các route đều cần đăng nhập (trừ getProductReviews và getProductRating)
router.post("/create", verifyToken, review.createReview);
router.get("/product/:product_id", review.getProductReviews);
router.get("/product/:product_id/rating", review.getProductRating);
router.get("/my-review/:product_id", verifyToken, review.getUserReviewForProduct);
router.put("/:review_id", verifyToken, review.updateReview);
router.delete("/:review_id", verifyToken, review.deleteReview);

module.exports = router;
const router = require("express").Router();
const order = require("../controllers/order.controller");
// Nhúng anh bảo vệ vào
const { verifyToken } = require("../middlewares/auth.middleware");

// Gắn verifyToken vào các tuyến đường
router.post("/create", verifyToken, order.createOrder);
router.get("/history", verifyToken, order.getUserOrders); // Đổi thành /history cho chuẩn RESTful
router.put("/update-status/:order_id", verifyToken, order.updateOrderStatus);
router.get("/:id", verifyToken, order.getOrderDetail);
router.get("/:id/tracking", verifyToken, order.getTracking);
router.put("/cancel/:order_id", verifyToken, order.cancelOrder);
router.post("/reorder/:order_id", verifyToken, order.reorder);
module.exports = router;

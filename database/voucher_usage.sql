CREATE TABLE voucher_usages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    voucher_id INT,
    used_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
FOREIGN KEY (voucher_id) REFERENCES vouchers(id)
);
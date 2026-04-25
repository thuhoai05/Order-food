CREATE TABLE reward_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    points INT,
    type VARCHAR(50),
    FOREIGN KEY (user_id) REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
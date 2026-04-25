CREATE TABLE notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,

    type VARCHAR(50) NOT NULL, -- order, promo, system

    title VARCHAR(255) NOT NULL,
    content TEXT,

    is_read BOOLEAN DEFAULT FALSE,
    related_id INT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
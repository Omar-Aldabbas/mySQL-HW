CREATE DATABASE IF NOT EXISTS hw;
USE hw;

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT
);

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL,
    category_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_products_category FOREIGN KEY (category_id)
        REFERENCES categories(category_id)
        ON DELETE CASCADE
);

CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Pending','Shipped','Delivered') DEFAULT 'Pending',
    CONSTRAINT fk_orders_user FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
);

CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_orderitems_order FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_orderitems_product FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON DELETE CASCADE
);

INSERT INTO users (name, email, password) VALUES
('Omar', 'omar@example.com', 'pass123'),
('Lina', 'lina@example.com', 'pass123'),
('Ahmad', 'ahmad@example.com', 'pass123'),
('Sara', 'sara@example.com', 'pass123'),
('Yousef', 'yousef@example.com', 'pass123');

INSERT INTO categories (name, description) VALUES
('Electronics', 'Various electronic devices'),
('Clothing', 'Men and women clothing'),
('Books', 'Different types of books');

INSERT INTO products (name, description, price, stock, category_id) VALUES
('Samsung A56 Phone', 'Smartphone from Samsung', 350.00, 50, 1),
('Dell idk Laptop', 'Laptop from Dell', 800.00, 20, 1),
('Samsung Buds Core', 'High-quality Low PRice BUds', 50.00, 100, 1),
('Men Shirt', 'Cotton shirt', 25.00, 70, 2),
('Women Dress', 'Women dress', 60.00, 40, 2),
('Men Jeans', 'Jeans pants', 35.00, 60, 2),
('SQL Book', 'USefull Book', 15.00, 100, 3),
('JS Programming Book', 'Book to learn JS programming', 20.00, 80, 3),
('Jordan History Book', 'History of Jordan', 18.00, 50, 3),
('Mansaf Cooking Book', 'Jordanian cooking recipes', 22.00, 40, 3);

INSERT INTO orders (user_id, order_date, status) VALUES
(1, NOW() - INTERVAL 5 DAY, 'Delivered'),
(2, NOW() - INTERVAL 3 DAY, 'Shipped'),
(3, NOW() - INTERVAL 2 DAY, 'Pending'),
(4, NOW() - INTERVAL 7 DAY, 'Delivered'),
(5, NOW() - INTERVAL 1 DAY, 'Pending');

INSERT INTO order_items (order_id, product_id, quantity, price) VALUES
(1, 1, 1, 350.00),
(1, 4, 2, 50.00),
(1, 7, 1, 15.00),
(2, 2, 1, 800.00),
(2, 5, 1, 60.00),
(2, 9, 2, 36.00),
(3, 3, 2, 100.00),
(3, 6, 1, 35.00),
(3, 10, 1, 22.00),
(4, 1, 1, 350.00),
(4, 8, 1, 20.00),
(4, 5, 2, 120.00),
(5, 2, 1, 800.00),
(5, 3, 1, 50.00),
(5, 7, 3, 45.00);

SELECT * FROM users;
SELECT * FROM categories;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_items;

-- Part 3

SELECT name, price, stock FROM products;
SELECT * FROM orders WHERE user_id = 1;
SELECT name, price, stock FROM products WHERE category_id = 2;

-- Part 4

SELECT 
    o.order_id,
    u.name AS user_name,
    SUM(oi.quantity * oi.price) AS total_amount
FROM orders o
JOIN users u ON o.user_id = u.user_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, u.name
ORDER BY o.order_id;

SELECT 
    p.name AS product_name,
    SUM(oi.quantity) AS total_quantity_sold
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.name
ORDER BY total_quantity_sold DESC
LIMIT 1;

SELECT 
    u.name AS user_name,
    COUNT(o.order_id) AS orders_count
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id
GROUP BY u.name
ORDER BY orders_count DESC;

SELECT 
    o.order_id,
    p.name AS product_name,
    oi.quantity,
    oi.price,
    (oi.quantity * oi.price) AS total_price
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN products p ON oi.product_id = p.product_id
ORDER BY o.order_id, oi.order_item_id;

-- Part 5
UPDATE products SET stock = stock - 2 WHERE product_id = 1;
SELECT * FROM products WHERE product_id = 1;

UPDATE orders SET status = 'Shipped' WHERE order_id = 3 AND status = 'Pending';
SELECT * FROM orders WHERE order_id = 1;

DELETE FROM products WHERE product_id = 10;
SELECT * FROM products WHERE product_id = 10;


CREATE OR REPLACE VIEW order_full_details AS
SELECT 
    o.order_id,
    u.name AS user_name,
    p.name AS product_name,
    oi.quantity,
    oi.price,
    (oi.quantity * oi.price) AS total_price
FROM orders o
JOIN users u ON o.user_id = u.user_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id;

SELECT * FROM order_full_details;

DELIMITER $$
CREATE TRIGGER trigger_check_stock
BEFORE INSERT ON order_items
FOR EACH ROW
BEGIN
    DECLARE current_stock INT;
    SELECT stock INTO current_stock FROM products WHERE product_id = NEW.product_id;
    IF NEW.quantity > current_stock THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = CONCAT('Not enough stock for product_id ', NEW.product_id);
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER update_stock_after_insert
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE products SET stock = stock - NEW.quantity WHERE product_id = NEW.product_id;
END$$
DELIMITER ;

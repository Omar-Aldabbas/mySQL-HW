# HW MySQL Project

## Project Overview
This MySQL project manages users, products, categories, orders, and order items. It demonstrates data creation, querying, updates, triggers, and views for an e-commerce-style database.

---

## Database Tables

### 1. `users`
| Column Name | Type         | Key      | Description                  |
|-------------|-------------|---------|------------------------------|
| user_id     | INT         | PK      | Auto-incremented user ID     |
| name        | VARCHAR(100)|         | User's name                  |
| email       | VARCHAR(150)| UNIQUE  | User email                   |
| password    | TEXT        |         | User password                |
| created_at  | TIMESTAMP   |         | Account creation timestamp   |

### 2. `categories`
| Column Name   | Type         | Key | Description            |
|---------------|-------------|-----|------------------------|
| category_id   | INT         | PK  | Auto-incremented ID    |
| name          | VARCHAR(100)|     | Category name          |
| description   | TEXT        |     | Description of category|

### 3. `products`
| Column Name   | Type          | Key | Description                         |
|---------------|--------------|-----|-------------------------------------|
| product_id    | INT          | PK  | Auto-incremented product ID          |
| name          | VARCHAR(150) |     | Product name                         |
| description   | TEXT         |     | Product description                  |
| price         | DECIMAL(10,2)|     | Product price                        |
| stock         | INT          |     | Available stock                       |
| category_id   | INT          | FK  | References `categories(category_id)` |
| created_at    | TIMESTAMP    |     | Timestamp of product creation        |

### 4. `orders`
| Column Name | Type       | Key | Description                       |
|-------------|-----------|-----|-----------------------------------|
| order_id    | INT       | PK  | Auto-incremented order ID         |
| user_id     | INT       | FK  | References `users(user_id)`       |
| order_date  | TIMESTAMP |     | Date of the order                 |
| status      | ENUM      |     | Order status: Pending, Shipped, Delivered |

### 5. `order_items`
| Column Name    | Type          | Key | Description                         |
|----------------|--------------|-----|-------------------------------------|
| order_item_id  | INT          | PK  | Auto-incremented item ID             |
| order_id       | INT          | FK  | References `orders(order_id)`       |
| product_id     | INT          | FK  | References `products(product_id)`   |
| quantity       | INT          |     | Quantity ordered                     |
| price          | DECIMAL(10,2)|     | Price per item                       |

---

## Views & Triggers

### View: `order_full_details`
- Combines order, user, product, and order item details into a single view.
- Columns: `order_id`, `user_name`, `product_name`, `quantity`, `price`, `total_price`.

### Trigger: `trigger_check_stock`
- Runs **before inserting** into `order_items`.
- Checks if `quantity` exceeds current stock; throws an error if insufficient.

### Trigger: `update_stock_after_insert`
- Runs **after inserting** into `order_items`.
- Deducts the ordered quantity from the corresponding product stock.

---
---

## 1. Database Tables

**Users Table**  
```sql
SELECT * FROM users;
```
---
**Caregories Table**  
```sql
SELECT * FROM categories;
```
![Caregories Table](assets/categoriestable.png)

---
**Products Table**  
```sql
SELECT * FROM products;
```
![Products Table](assets/productstable.png)

---
**Orders Table**  
```sql
SELECT * FROM orders;
```
![Orders Table](assets/orderstable.png)


---
**Order Items Table**  
```sql
SELECT * FROM order_items;
```
![Order Items Table](assets/orderitemstable.png)

---

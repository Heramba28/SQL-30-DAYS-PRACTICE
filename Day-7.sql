CREATE DATABASE IF NOT EXISTS company_transcation;

-- Users Table
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    city VARCHAR(50),
    signup_date DATE
);

-- Products Table
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2)
);

-- Orders Table
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    user_id INT,
    product_id INT,
    order_date DATE,
    quantity INT,
    status VARCHAR(20),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);



-- Payments Table
CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    order_id INT,
    payment_date DATE,
    amount DECIMAL(10,2),
    method VARCHAR(50),
    success BOOLEAN,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);


-- Users
INSERT INTO users VALUES
(1, 'Alice', 'alice@email.com', 'Mumbai', '2023-01-10'),
(2, 'Bob', 'bob@email.com', 'Delhi', '2022-11-05'),
(3, 'Charlie', 'charlie@email.com', 'Bangalore', '2023-02-15'),
(4, 'Diana', 'diana@email.com', 'Hyderabad', '2021-12-30'),
(5, 'Evan', 'evan@email.com', 'Mumbai', '2023-03-10');

-- Products
INSERT INTO products VALUES
(101, 'Laptop', 'Electronics', 50000),
(102, 'Phone', 'Electronics', 30000),
(103, 'Table', 'Furniture', 7000),
(104, 'Chair', 'Furniture', 3000),
(105, 'Headphones', 'Electronics', 2000);

-- Orders
INSERT INTO orders VALUES
(201, 1, 101, '2023-03-01', 1, 'Delivered'),
(202, 2, 103, '2023-03-05', 2, 'Delivered'),
(203, 1, 102, '2023-03-10', 1, 'Cancelled'),
(204, 3, 104, '2023-03-11', 4, 'Delivered'),
(205, 4, 105, '2023-03-15', 3, 'Delivered'),
(206, 5, 105, '2023-03-17', 1, 'Pending');

-- Payments
INSERT INTO payments VALUES
(301, 201, '2023-03-01', 50000.00, 'Credit Card', 1),
(302, 202, '2023-03-05', 14000.00, 'UPI', 1),
(303, 204, '2023-03-11', 12000.00, 'Debit Card', 1),
(304, 205, '2023-03-15', 6000.00, 'Credit Card', 1);


SELECT * FROM users;
SELECT * FROM orders; 
SELECT * FROM products;
SELECT * FROM payments;

-- 1 List the names and cities of all users who made at least one successful payment.
SELECT distinct(u.name),u.city FROM users u
INNER JOIN orders o
ON u.user_id=o.user_id
INNER JOIN payments p 
ON o.order_id=p.order_id
WHERE p.success=1;

-- 2 Show the total amount spent by each user.
SELECT u.name,SUM(p.amount) as total_spend FROM users u
INNER JOIN orders o
ON u.user_id=o.user_id
INNER JOIN payments p 
ON o.order_id=p.order_id
WHERE p.success=1
GROUP BY u.name;

-- 3 Which product category has the highest number of orders?
SELECT p.category , COUNT(*) AS orders  FROM products p
INNER JOIN orders o 
ON p.product_id=o.product_id
GROUP BY p.category
ORDER BY orders DESC
LIMIT 1;

-- 4 Display all users who haven’t placed any orders.
SELECT DISTINCT u.name FROM users u 
LEFT JOIN orders o
ON u.user_id=o.user_id
WHERE o.order_id IS NULL;

-- 5 Find the most expensive product that was ever ordered.
SELECT p.name,p.price as max_price FROM orders o 
INNER JOIN products p
ON o.product_id=p.product_id
ORDER BY max_price DESC
LIMIT 1;

-- 6 Show all orders placed in March 2023.
SELECT * FROM orders
WHERE MONTH(order_date)=3;

-- 7 Find the user who made the highest single payment.
SELECT 	u.name,p.method,p.amount FROM users u 
INNER JOIN orders o
ON u.user_id=o.user_id
INNER JOIN payments p
ON o.order_id=p.order_id
WHERE p.success=1
ORDER BY p.amount DESC
LIMIT 1;

-- 8 Which user placed the most number of orders?
WITH order_counts AS (
  SELECT u.user_id, u.name, COUNT(o.order_id) AS total_orders
  FROM users u
  JOIN orders o ON u.user_id = o.user_id
  GROUP BY u.user_id, u.name
)
SELECT *
FROM order_counts
WHERE total_orders = (
  SELECT MAX(total_orders) FROM order_counts
);


-- 9 Display each user's first and last order date.
SELECT u.name, 'First Order' AS order_type, MIN(o.order_date) AS order_date
FROM users u
JOIN orders o ON u.user_id = o.user_id
GROUP BY u.name

UNION ALL

SELECT u.name, 'LAST Order' AS order_type, MIN(o.order_date) AS order_date
FROM users u
JOIN orders o ON u.user_id = o.user_id
GROUP BY u.name;

-- 10  List all products that have never been ordered.
SELECT p.name FROM orders o
RIGHT JOIN products p
ON o.product_id=p.product_id
WHERE o.order_id IS NULL;

-- 11 What is the average quantity of products ordered per order?
SELECT ROUND(AVG(quantity), 2) AS avg_quantity_per_order
FROM orders;

-- 12 List all users whose email ends with ‘@email.com’.
SELECT * FROM users
WHERE email LIKE '%@email.com';

-- 13 Find the product(s) ordered more than once by the same user.
SELECT u.name,p.name,COUNT(*) as total FROM users u
INNER JOIN orders o
ON u.user_id=o.user_id 
INNER JOIN products p 
ON o.product_id=p.product_id
GROUP BY u.name,p.name
HAVING total>1;

-- 14 Show the order IDs and payment method for failed payments.
SELECT o.order_id,p.method FROM orders o
INNER JOIN payments p
ON o.order_id=p.order_id
WHERE p.success=0;

-- 15 Find the city with the most active users (those who made orders).
SELECT u.city, COUNT(DISTINCT u.user_id) AS active_users
FROM users u
INNER JOIN orders o 
ON u.user_id = o.user_id
GROUP BY u.city
ORDER BY active_users DESC
LIMIT 1;

-- 16 Display total revenue for each product category.
SELECT p.category,SUM(p.price*o.quantity) FROM orders o 
INNER JOIN products p 
ON o.product_id=p.product_id
GROUP BY p.category;

-- 17 List all orders where quantity > 2 and product is in the 'Furniture' category.
SELECT * FROM orders o 
INNER JOIN products p 
ON o.product_id=p.product_id
WHERE o.quantity>2 AND p.category='Furniture';

-- 18 Which orders were placed but not yet paid?
SELECT * FROM orders o 
INNER JOIN payments p 
ON o.order_id=p.order_id 
WHERE p.success=0;

-- 19 Show all payments made through ‘UPI’.
SELECT * FROM payments 
WHERE method='UPI';

-- 20 List products with price between ₹5000 and ₹40000.
SELECT * FROM products 
WHERE PRICE BETWEEN 5000 AND 40000;

-- 21 Display each product and the number of times it was ordered.
SELECT p.name , count(o.order_id)  FROM orders o 
RIGHT JOIN products p 
ON o.product_id=p.product_id
GROUP BY p.name;

-- 22 Find the earliest signup date for users who ordered electronics.
SELECT * FROM users u 
INNER JOIN orders o 
ON u.user_id=o.user_id 
INNER JOIN products p 
ON o.product_id=p.product_id
WHERE p.category='Electronics'
ORDER BY signup_date ASC 
LIMIT 1;

-- 23 Show orders where user’s city is different from delivery city. (Assume orders.delivery_city exists)
SELECT * FROM users u 
INNER JOIN orders o 
ON u.user_id=o.user_id 
WHERE u.city<>o.delivery_city;

-- 24 For each user, show their most recent order’s product.
WITH cte as(
SELECT u.name as user_name,p.name as product_name,RANK() OVER(partition by u.name order by order_date desc) as ordering FROM users u 
INNER JOIN orders o 
ON u.user_id=o.user_id
INNER JOIN products p 
ON o.product_id=p.product_id
)
SELECT user_name,product_name from cte
WHERE ordering=1;

-- 25 List all users who signed up before 2022.
SELECT * FROM users 
WHERE YEAR(signup_date)<2022;
 
-- 26 Which product has generated the highest revenue?
SELECT p.name,SUM(o.quantity*p.price) as total FROM orders o 
INNER JOIN products p 
ON o.product_id=p.product_id 
group by p.name
ORDER BY total DESC
LIMIT 1;

-- 27 List all users who never made a successful payment.
SELECT DISTINCT u.name
FROM users u
LEFT JOIN orders o 
ON u.user_id = o.user_id
LEFT JOIN payments p 
ON o.order_id = p.order_id AND p.success = 1
WHERE p.payment_id IS NULL;

-- 28 Show users who placed more than 2 orders and used more than one payment method.
SELECT u.name ,COUNT(o.order_id) AS order_count, COUNT(DISTINCT p.method) as payment_count
FROM users u
INNER JOIN orders o 
ON u.user_id = o.user_id
INNER JOIN payments p 
ON o.order_id = p.order_id
GROUP BY u.name
HAVING order_count > 2 AND payment_count>1;

-- 29 Find users who only ordered products from one category.
SELECT u.name , COUNT(DISTINCT p.category) as count
FROM users u
INNER JOIN orders o 
ON u.user_id = o.user_id
INNER JOIN products p 
ON o.product_id = p.product_id
GROUP BY u.name
HAVING count=1;

-- 30 Show all products that have been ordered by more than 2 unique users.
SELECT p.name , COUNT(DISTINCT u.name) as user_count
FROM users u
INNER JOIN orders o 
ON u.user_id = o.user_id
INNER JOIN products p 
ON o.product_id = p.product_id
GROUP by p.name
HAVING user_count>2;

-- 31 Which user has the highest total quantity ordered?
SELECT u.name , SUM(o.quantity) as q FROM users u 
INNER JOIN orders o 
ON u.user_id = o.user_id
GROUP BY u.name
ORDER BY Q DESC
LIMIT 1;

-- 32 Display the difference in days between order and payment for each order.
SELECT 
  o.order_id,
  u.name,
  o.order_date,
  p.payment_date,
  DATEDIFF(p.payment_date, o.order_date) AS days_between
FROM users u
INNER JOIN orders o ON u.user_id = o.user_id
INNER JOIN payments p ON o.order_id = p.order_id;

-- 33 Show each user's latest order status.
WITH ranked_orders AS (
  SELECT u.name, o.status, o.order_date,
         RANK() OVER (PARTITION BY u.user_id ORDER BY o.order_date DESC) AS rnk
  FROM users u
  JOIN orders o ON u.user_id = o.user_id
)
SELECT name, status, order_date
FROM ranked_orders
WHERE rnk = 1;

-- 34 Find the second most expensive product ever ordered.
with cte as (
SELECT p.name,p.price,dense_rank() over(order by price desc) as rnk FROM orders o 
INNER JOIN products p 
ON o.product_id=p.product_id
)
SELECT * FROM cte
WHERE rnk = 2;

-- 35 Show all products ordered in a quantity of 1 or less.
SELECT p.name , SUM(IFNULL(o.quantity, 0)) as count FROM orders o 
RIGHT JOIN products p
ON o.product_id=p.product_id
GROUP BY p.name
HAVING count<=1;

-- 36  Which products were ordered and never paid for?
SELECT DISTINCT p.name
FROM orders o
JOIN products p ON o.product_id = p.product_id
LEFT JOIN payments py ON o.order_id = py.order_id
WHERE py.payment_id IS NULL;

-- 37 Show the count of each payment method used.
SELECT method , COUNT(method) from payments 
GROUP BY method;

-- 38 List all users along with the number of successful and failed payments.
SELECT 
  u.name,
  COUNT(CASE WHEN p.success = 1 THEN 1 END) AS successful_payments,
  COUNT(CASE WHEN p.success = 0 THEN 1 END) AS failed_payments
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id
LEFT JOIN payments p ON o.order_id = p.order_id
GROUP BY u.name;

-- 39 Show product name, total revenue, and average quantity sold per order.
SELECT 
  p.name AS product_name,
  SUM(o.quantity * p.price) AS total_revenue,
  ROUND(AVG(o.quantity), 2) AS avg_quantity_per_order
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.name;

-- 40 For each user, display the total number of distinct products they’ve ordered.
SELECT u.name ,COUNT(DISTINCT p.name) FROM users u 
INNER JOIN orders o 
ON u.user_id=o.user_id
INNER JOIN products p 
ON o.product_id=p.product_id
GROUP BY u.name;

-- 41  List pairs of users who live in the same city.
SELECT * FROM users u1
INNER JOIN users u2
ON u1.city=u2.city AND u1.user_id < u2.user_id;

-- 42 Show all users who ordered both 'Laptop' and 'Phone'.
SELECT u.name
FROM users u
JOIN orders o ON u.user_id = o.user_id
JOIN products p ON o.product_id = p.product_id
WHERE p.name IN ('Laptop', 'Phone')
GROUP BY u.name
HAVING COUNT(DISTINCT p.name) = 2;

-- 43 Find the average price of products ordered by each user.
SELECT 
  u.name AS user_name,
  ROUND(AVG(p.price), 2) AS avg_price_ordered
FROM users u
JOIN orders o ON u.user_id = o.user_id
JOIN products p ON o.product_id = p.product_id
GROUP BY u.name;

-- 44 Which product has been ordered by the most different users?
SELECT p.name , count(distinct u.user_id) as c
FROM users u
JOIN orders o
 ON u.user_id = o.user_id
JOIN products p 
ON o.product_id = p.product_id
GROUP BY p.name
ORDER BY C DESC
LIMIT 1;

-- 45 Find the longest time gap between any two orders for the same user.
WITH ordered_dates AS (
  SELECT 
    u.user_id,
    u.name,
    o.order_date,
    LAG(o.order_date) OVER (PARTITION BY u.user_id ORDER BY o.order_date) AS previous_order
  FROM users u
  JOIN orders o ON u.user_id = o.user_id
),
gaps AS (
  SELECT 
    user_id,
    name,
    DATEDIFF(order_date, previous_order) AS gap_days
  FROM ordered_dates
  WHERE previous_order IS NOT NULL
)
SELECT name, MAX(gap_days) AS longest_gap
FROM gaps
GROUP BY name
ORDER BY longest_gap DESC;

-- 46 List orders placed on weekends.
SELECT *
FROM orders
WHERE DAYOFWEEK(order_date) IN (1, 7);

-- 47 Which user’s first payment failed?
WITH ranked_payments AS (
  SELECT 
    u.name,
    p.success,
    p.payment_date,
    RANK() OVER (PARTITION BY u.user_id ORDER BY p.payment_date) AS payment_rank
  FROM users u
  JOIN orders o ON u.user_id = o.user_id
  JOIN payments p ON o.order_id = p.order_id
)
SELECT name, payment_date
FROM ranked_payments
WHERE payment_rank = 1 AND success = 0;

-- 48 Show the percentage of successful payments per user.
SELECT 
  u.name,
  ROUND(100.0 * SUM(CASE WHEN p.success = 1 THEN 1 ELSE 0 END) / COUNT(p.payment_id), 2) AS success_percentage
FROM users u
JOIN orders o ON u.user_id = o.user_id
JOIN payments p ON o.order_id = p.order_id
GROUP BY u.name;

-- 49 Find all users who ordered a product after the product price increased. (Assume a price_history table if needed.)
SELECT DISTINCT u.name, p.name AS product_name, o.order_date
FROM users u
JOIN orders o ON u.user_id = o.user_id
JOIN products p ON o.product_id = p.product_id
JOIN price_history ph ON p.product_id = ph.product_id
WHERE o.order_date > ph.changed_at;

-- 50 For each product, show the total quantity sold, number of users who bought it, and average payment success rate.
SELECT 
  p.name AS product_name,
  SUM(o.quantity) AS total_quantity_sold,
  COUNT(DISTINCT o.user_id) AS unique_users,
  ROUND(100.0 * SUM(CASE WHEN pay.success = 1 THEN 1 ELSE 0 END) / COUNT(pay.payment_id), 2) AS avg_success_rate
FROM products p
JOIN orders o 
ON p.product_id = o.product_id
JOIN payments pay 
ON o.order_id = pay.order_id
GROUP BY p.name;




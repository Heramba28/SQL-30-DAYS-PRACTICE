CREATE DATABASE IF NOT EXISTS online_store;


CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    signup_date DATE
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2),
    status VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Sample Data
INSERT INTO customers VALUES 
(1, 'Amit', '2023-01-01'),
(2, 'Priya', '2023-01-05'),
(3, 'Ravi', '2023-01-10'),
(4, 'Neha', '2023-01-15');

INSERT INTO orders VALUES 
(101, 1, '2023-01-02', 1200.00, 'Delivered'),
(102, 1, '2023-01-20', 600.00, 'Cancelled'),
(103, 1, '2023-02-05', 2000.00, 'Delivered'),
(104, 2, '2023-01-07', 300.00, 'Delivered'),
(105, 2, '2023-01-15', 150.00, 'Delivered'),
(106, 3, '2023-02-01', 400.00, 'Cancelled'),
(107, 3, '2023-02-10', 700.00, 'Delivered'),
(108, 4, '2023-02-15', 800.00, 'Delivered');


SELECT * FROM customers;
SELECT * FROM orders;

-- 1 For each customer, show their first and last order date. 
WITH orders_d AS (
    SELECT c.name,o.order_date FROM customers c
    INNER JOIN orders o 
    ON c.customer_id = o.customer_id
)
SELECT name,min(order_date),max(order_date) FROM orders_d
GROUP BY name;

-- 2 Find customers who placed more than one order and calculate the time gap (in days) between their first and second order.

WITH ranked_orders AS (
    SELECT 
        c.customer_id,
        c.name,
        o.order_date,
        ROW_NUMBER() OVER (PARTITION BY c.customer_id ORDER BY o.order_date) AS order_rank
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
),
first_second AS (
    SELECT * FROM ranked_orders
    WHERE order_rank <= 2
)
SELECT 
    f1.customer_id,
    f1.name,
    DATEDIFF(f2.order_date, f1.order_date) AS gap_days
FROM first_second f1
JOIN first_second f2 
  ON f1.customer_id = f2.customer_id AND f1.order_rank = 1 AND f2.order_rank = 2;


-- 3 Using LAG(), show each customer's previous order amount next to their current order.
SELECT 
    c.customer_id,
    c.name,
    o.order_id,
    o.order_date,
    o.total_amount AS current_amount,
    LAG(o.total_amount) OVER (
        PARTITION BY c.customer_id 
        ORDER BY o.order_date
    ) AS previous_amount
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id;

-- 4 Find customers whose last order was 'Cancelled'.
WITH  cancel as(
SELECT c.name,o.order_date , row_number() over(PARTITION BY c.name ORDER BY o.order_date) as last_order,o.status FROM customers c
    INNER JOIN orders o 
    ON c.customer_id = o.customer_id
)
SELECT * FROM cancel
WHERE last_order=1 AND status='Cancelled';

-- 5 Show customers who placed an order within 7 days of signing up.
SELECT 
    c.customer_id,
    c.name,
    c.signup_date,
    o.order_id,
    o.order_date,
    DATEDIFF(o.order_date, c.signup_date) AS days_after_signup
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE DATEDIFF(o.order_date, c.signup_date) <= 7;

-- List the top 2 highest-value orders per customer using RANK().
WITH ranked_orders AS (
    SELECT 
        c.name,
        o.total_amount,
        RANK() OVER (
            PARTITION BY c.customer_id 
            ORDER BY o.total_amount DESC
        ) AS ranking
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
)
SELECT *
FROM ranked_orders
WHERE ranking <= 2;

-- 7 Using LEAD(), display each customer's next order date.
SELECT 
    c.name,
    o.order_id,
    o.order_date AS current_order_date,
    LEAD(o.order_date) OVER (
        PARTITION BY c.customer_id 
        ORDER BY o.order_date
    ) AS next_order_date
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id;

--  8 For each customer, calculate the running total of total_amount ordered over time.
SELECT 
    c.name,
    o.order_id,
    o.order_date,
    o.total_amount,
    SUM(o.total_amount) OVER (
        PARTITION BY c.customer_id
        ORDER BY o.order_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id;

-- 9 Find customers who never cancelled any order.
SELECT *
FROM customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
      AND o.status = 'Cancelled'
);
-- 10 Using a CTE, display customers whose total spending across all delivered orders is more than ₹1000.
WITH delivered_totals AS (
    SELECT 
        c.customer_id,
        c.name,
        SUM(o.total_amount) AS total_spent
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.status = 'Delivered'
    GROUP BY c.customer_id, c.name
)
SELECT *
FROM delivered_totals
WHERE total_spent > 1000;



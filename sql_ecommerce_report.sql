-- =============================================================
--   SQL E-COMMERCE REPORT  |  Week 4
--   Topics: DDL Constraints · JOINs · NULL Handling ·
--           Top Products · Customer Spend · Aggregations
-- =============================================================


-- =============================================================
-- SECTION 1 — DDL: SCHEMA CREATION WITH CONSTRAINTS
-- =============================================================

-- Q1. Create the Customers table
CREATE TABLE Customers (
    customer_id   INT           PRIMARY KEY,
    first_name    VARCHAR(50)   NOT NULL,
    last_name     VARCHAR(50)   NOT NULL,
    email         VARCHAR(100)  UNIQUE NOT NULL,
    phone         VARCHAR(20),
    city          VARCHAR(50),
    country       VARCHAR(50)   DEFAULT 'India',
    created_at    DATE          DEFAULT CURRENT_DATE
);

-- Q2. Create the Categories table
CREATE TABLE Categories (
    category_id   INT          PRIMARY KEY,
    category_name VARCHAR(80)  NOT NULL UNIQUE
);

-- Q3. Create the Products table with FK + CHECK constraints
CREATE TABLE Products (
    product_id    INT           PRIMARY KEY,
    product_name  VARCHAR(100)  NOT NULL,
    category_id   INT           REFERENCES Categories(category_id),
    price         DECIMAL(10,2) NOT NULL CHECK (price > 0),
    stock_qty     INT           DEFAULT 0 CHECK (stock_qty >= 0),
    is_active     BOOLEAN       DEFAULT TRUE
);

-- Q4. Create the Orders table
CREATE TABLE Orders (
    order_id      INT           PRIMARY KEY,
    customer_id   INT           NOT NULL REFERENCES Customers(customer_id),
    order_date    DATE          NOT NULL DEFAULT CURRENT_DATE,
    status        VARCHAR(20)   DEFAULT 'Pending'
                                CHECK (status IN ('Pending','Processing','Shipped','Delivered','Cancelled')),
    shipping_city VARCHAR(50)
);

-- Q5. Create the Order_Items table (composite PK + FKs)
CREATE TABLE Order_Items (
    order_id      INT           NOT NULL REFERENCES Orders(order_id),
    product_id    INT           NOT NULL REFERENCES Products(product_id),
    quantity      INT           NOT NULL CHECK (quantity > 0),
    unit_price    DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    PRIMARY KEY (order_id, product_id)
);

-- Q6. Add an index on Orders.customer_id for faster lookups
CREATE INDEX idx_orders_customer ON Orders(customer_id);

-- Q7. Add an index on Order_Items.product_id
CREATE INDEX idx_items_product ON Order_Items(product_id);


-- =============================================================
-- SECTION 2 — DML: SAMPLE DATA INSERTS
-- =============================================================

-- Q8. Insert Categories
INSERT INTO Categories VALUES
(1, 'Electronics'),
(2, 'Clothing'),
(3, 'Books'),
(4, 'Home & Kitchen'),
(5, 'Sports');

-- Q9. Insert Customers (some with NULL phone/city)
INSERT INTO Customers (customer_id, first_name, last_name, email, phone, city) VALUES
(1,  'Aisha',   'Khan',     'aisha@example.com',   '9812345670', 'Mumbai'),
(2,  'Rohan',   'Mehta',    'rohan@example.com',   NULL,         'Delhi'),
(3,  'Priya',   'Sharma',   'priya@example.com',   '9988776655', 'Bangalore'),
(4,  'Carlos',  'Diaz',     'carlos@example.com',  '1234567890', NULL),
(5,  'Lily',    'Chen',     'lily@example.com',    NULL,         'Pune'),
(6,  'Amit',    'Patel',    'amit@example.com',    '9090909090', 'Chennai'),
(7,  'Sara',    'Ali',      'sara@example.com',    '8080808080', 'Hyderabad'),
(8,  'David',   'Brown',    'david@example.com',   NULL,         NULL),
(9,  'Neha',    'Joshi',    'neha@example.com',    '7070707070', 'Kolkata'),
(10, 'Vikram',  'Singh',    'vikram@example.com',  '6060606060', 'Jaipur');

-- Q10. Insert Products
INSERT INTO Products VALUES
(1,  'Smartphone X12',    1, 25999.00, 50,  TRUE),
(2,  'Laptop Pro 15',     1, 72999.00, 20,  TRUE),
(3,  'Wireless Earbuds',  1,  3499.00, 120, TRUE),
(4,  'Cotton T-Shirt',    2,   499.00, 300, TRUE),
(5,  'Denim Jeans',       2,  1299.00, 150, TRUE),
(6,  'Python Crash Course',3,  799.00, 80,  TRUE),
(7,  'Clean Code',        3,   649.00, 60,  TRUE),
(8,  'Air Fryer 5L',      4,  4999.00, 40,  TRUE),
(9,  'Yoga Mat',          5,   899.00, 200, TRUE),
(10, 'Running Shoes',     5,  2999.00, 90,  FALSE);

-- Q11. Insert Orders
INSERT INTO Orders VALUES
(101, 1, '2024-01-05', 'Delivered',  'Mumbai'),
(102, 2, '2024-01-10', 'Delivered',  'Delhi'),
(103, 3, '2024-01-15', 'Shipped',    'Bangalore'),
(104, 4, '2024-01-20', 'Processing', NULL),
(105, 5, '2024-02-01', 'Delivered',  'Pune'),
(106, 6, '2024-02-10', 'Cancelled',  'Chennai'),
(107, 7, '2024-02-15', 'Delivered',  'Hyderabad'),
(108, 1, '2024-02-20', 'Delivered',  'Mumbai'),
(109, 8, '2024-03-01', 'Pending',    NULL),
(110, 9, '2024-03-05', 'Delivered',  'Kolkata');

-- Q12. Insert Order Items
INSERT INTO Order_Items VALUES
(101, 1,  1, 25999.00),
(101, 3,  2,  3499.00),
(102, 2,  1, 72999.00),
(103, 4,  3,   499.00),
(103, 5,  2,  1299.00),
(104, 6,  1,   799.00),
(105, 8,  1,  4999.00),
(105, 9,  2,   899.00),
(106, 10, 1,  2999.00),
(107, 1,  1, 25999.00),
(108, 2,  1, 72999.00),
(108, 3,  3,  3499.00),
(109, 7,  2,   649.00),
(110, 9,  1,   899.00),
(110, 4,  5,   499.00);


-- =============================================================
-- SECTION 3 — TOP PRODUCTS ANALYSIS
-- =============================================================

-- Q13. Top 5 best-selling products by total quantity sold
SELECT
    p.product_name,
    SUM(oi.quantity)                       AS total_qty_sold,
    SUM(oi.quantity * oi.unit_price)       AS total_revenue
FROM Order_Items oi
JOIN Products p ON p.product_id = oi.product_id
GROUP BY p.product_name
ORDER BY total_qty_sold DESC
LIMIT 5;

-- Q14. Top 5 products by revenue generated
SELECT
    p.product_name,
    c.category_name,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM Order_Items oi
JOIN Products p ON p.product_id = oi.product_id
JOIN Categories c ON c.category_id = p.category_id
GROUP BY p.product_name, c.category_name
ORDER BY revenue DESC
LIMIT 5;

-- Q15. Products that have NEVER been ordered
SELECT p.product_id, p.product_name, p.price
FROM Products p
LEFT JOIN Order_Items oi ON oi.product_id = p.product_id
WHERE oi.product_id IS NULL;

-- Q16. Products with low stock (below 30 units) that are active
SELECT product_id, product_name, stock_qty
FROM Products
WHERE stock_qty < 30 AND is_active = TRUE
ORDER BY stock_qty ASC;

-- Q17. Revenue contribution % per category
SELECT
    c.category_name,
    SUM(oi.quantity * oi.unit_price)                              AS category_revenue,
    ROUND(
        SUM(oi.quantity * oi.unit_price) * 100.0 /
        (SELECT SUM(quantity * unit_price) FROM Order_Items), 2
    )                                                             AS revenue_pct
FROM Order_Items oi
JOIN Products p ON p.product_id = oi.product_id
JOIN Categories c ON c.category_id = p.category_id
GROUP BY c.category_name
ORDER BY category_revenue DESC;


-- =============================================================
-- SECTION 4 — CUSTOMER SPEND ANALYSIS
-- =============================================================

-- Q18. Total spend per customer (all orders)
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name   AS customer_name,
    COUNT(DISTINCT o.order_id)            AS total_orders,
    SUM(oi.quantity * oi.unit_price)      AS total_spend
FROM Customers c
JOIN Orders o    ON o.customer_id  = c.customer_id
JOIN Order_Items oi ON oi.order_id = o.order_id
GROUP BY c.customer_id, customer_name
ORDER BY total_spend DESC;

-- Q19. Top 3 highest-spending customers
SELECT
    c.first_name || ' ' || c.last_name  AS customer_name,
    SUM(oi.quantity * oi.unit_price)     AS total_spend
FROM Customers c
JOIN Orders o    ON o.customer_id  = c.customer_id
JOIN Order_Items oi ON oi.order_id = o.order_id
GROUP BY c.customer_id, customer_name
ORDER BY total_spend DESC
LIMIT 3;

-- Q20. Average order value per customer
SELECT
    c.first_name || ' ' || c.last_name         AS customer_name,
    ROUND(AVG(order_total), 2)                  AS avg_order_value
FROM Customers c
JOIN Orders o ON o.customer_id = c.customer_id
JOIN (
    SELECT order_id, SUM(quantity * unit_price) AS order_total
    FROM Order_Items
    GROUP BY order_id
) AS ot ON ot.order_id = o.order_id
GROUP BY c.customer_id, customer_name
ORDER BY avg_order_value DESC;

-- Q21. Customers who placed more than 1 order
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    COUNT(o.order_id)                   AS order_count
FROM Customers c
JOIN Orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, customer_name
HAVING COUNT(o.order_id) > 1
ORDER BY order_count DESC;

-- Q22. Monthly revenue trend
SELECT
    TO_CHAR(o.order_date, 'YYYY-MM')          AS month,
    SUM(oi.quantity * oi.unit_price)           AS monthly_revenue,
    COUNT(DISTINCT o.order_id)                 AS orders_count
FROM Orders o
JOIN Order_Items oi ON oi.order_id = o.order_id
WHERE o.status != 'Cancelled'
GROUP BY month
ORDER BY month;


-- =============================================================
-- SECTION 5 — NULL HANDLING
-- =============================================================

-- Q23. Customers with no phone number on record
SELECT customer_id, first_name, last_name, email
FROM Customers
WHERE phone IS NULL;

-- Q24. Replace NULL phone with a default placeholder using COALESCE
SELECT
    customer_id,
    first_name,
    COALESCE(phone, 'N/A')  AS phone,
    COALESCE(city,  'Unknown City') AS city
FROM Customers;

-- Q25. Orders with no shipping city (NULL) — potentially in-store
SELECT order_id, customer_id, order_date, status
FROM Orders
WHERE shipping_city IS NULL;

-- Q26. Count of NULL vs non-NULL phone numbers
SELECT
    COUNT(*) FILTER (WHERE phone IS NULL)     AS missing_phone,
    COUNT(*) FILTER (WHERE phone IS NOT NULL) AS has_phone
FROM Customers;

-- Q27. Find customers where both phone AND city are NULL
SELECT customer_id, first_name, last_name
FROM Customers
WHERE phone IS NULL AND city IS NULL;

-- Q28. Use NULLIF to avoid division by zero in price discount calc
SELECT
    product_name,
    price,
    stock_qty,
    price / NULLIF(stock_qty, 0)  AS price_per_unit_stock_ratio
FROM Products;


-- =============================================================
-- SECTION 6 — JOINS
-- =============================================================

-- Q29. INNER JOIN — Orders with customer details
SELECT
    o.order_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    o.order_date,
    o.status
FROM Orders o
INNER JOIN Customers c ON c.customer_id = o.customer_id;

-- Q30. LEFT JOIN — All customers including those with no orders
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    o.order_id,
    o.order_date
FROM Customers c
LEFT JOIN Orders o ON o.customer_id = c.customer_id
ORDER BY c.customer_id;

-- Q31. RIGHT JOIN — All orders even if customer data is missing
SELECT
    o.order_id,
    o.order_date,
    c.first_name,
    c.email
FROM Customers c
RIGHT JOIN Orders o ON o.customer_id = c.customer_id;

-- Q32. FULL OUTER JOIN — Customers and Orders (all records)
SELECT
    c.customer_id,
    c.first_name,
    o.order_id,
    o.status
FROM Customers c
FULL OUTER JOIN Orders o ON o.customer_id = c.customer_id;

-- Q33. Three-table JOIN — Order details with product & customer info
SELECT
    o.order_id,
    c.first_name || ' ' || c.last_name  AS customer_name,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price)        AS line_total
FROM Orders o
JOIN Customers c    ON c.customer_id  = o.customer_id
JOIN Order_Items oi ON oi.order_id    = o.order_id
JOIN Products p     ON p.product_id   = oi.product_id
ORDER BY o.order_id;

-- Q34. Self-JOIN example — Customers in the same city
SELECT
    a.first_name || ' ' || a.last_name AS customer_a,
    b.first_name || ' ' || b.last_name AS customer_b,
    a.city
FROM Customers a
JOIN Customers b ON a.city = b.city AND a.customer_id < b.customer_id
ORDER BY a.city;


-- =============================================================
-- SECTION 7 — AGGREGATIONS & SUBQUERIES
-- =============================================================

-- Q35. Total, average, min, max order value across all orders
SELECT
    COUNT(DISTINCT order_id)         AS total_orders,
    SUM(quantity * unit_price)       AS grand_total,
    ROUND(AVG(quantity * unit_price), 2) AS avg_item_value,
    MIN(unit_price)                  AS cheapest_item,
    MAX(unit_price)                  AS priciest_item
FROM Order_Items;

-- Q36. Orders above the average order total (subquery)
SELECT order_id, order_total
FROM (
    SELECT order_id, SUM(quantity * unit_price) AS order_total
    FROM Order_Items
    GROUP BY order_id
) AS totals
WHERE order_total > (
    SELECT AVG(order_total)
    FROM (
        SELECT SUM(quantity * unit_price) AS order_total
        FROM Order_Items
        GROUP BY order_id
    ) AS avg_sub
);

-- Q37. Rank customers by spend using a window function
SELECT
    c.first_name || ' ' || c.last_name        AS customer_name,
    SUM(oi.quantity * oi.unit_price)           AS total_spend,
    RANK() OVER (ORDER BY SUM(oi.quantity * oi.unit_price) DESC) AS spend_rank
FROM Customers c
JOIN Orders o       ON o.customer_id  = c.customer_id
JOIN Order_Items oi ON oi.order_id    = o.order_id
GROUP BY c.customer_id, customer_name;

-- Q38. Running total of revenue over time (window function)
SELECT
    o.order_date,
    SUM(oi.quantity * oi.unit_price)                                       AS daily_revenue,
    SUM(SUM(oi.quantity * oi.unit_price)) OVER (ORDER BY o.order_date)     AS running_total
FROM Orders o
JOIN Order_Items oi ON oi.order_id = o.order_id
WHERE o.status != 'Cancelled'
GROUP BY o.order_date
ORDER BY o.order_date;

-- Q39. Customers who spent MORE than the overall average customer spend
SELECT customer_name, total_spend
FROM (
    SELECT
        c.first_name || ' ' || c.last_name AS customer_name,
        SUM(oi.quantity * oi.unit_price)    AS total_spend
    FROM Customers c
    JOIN Orders o       ON o.customer_id  = c.customer_id
    JOIN Order_Items oi ON oi.order_id    = o.order_id
    GROUP BY c.customer_id, customer_name
) AS cust_spend
WHERE total_spend > (
    SELECT AVG(total_spend)
    FROM (
        SELECT SUM(oi.quantity * oi.unit_price) AS total_spend
        FROM Orders o
        JOIN Order_Items oi ON oi.order_id = o.order_id
        GROUP BY o.customer_id
    ) AS avg_sub
);

-- Q40. Order status breakdown with percentage
SELECT
    status,
    COUNT(*)                                            AS count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Orders), 2) AS pct
FROM Orders
GROUP BY status
ORDER BY count DESC;

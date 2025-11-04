-- 1. Drop all tables
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS geography CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS customers CASCADE;

-- 2. Create tables with surrogate keys
CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    segment VARCHAR(50)
);

CREATE TABLE geography (
    location_id SERIAL PRIMARY KEY,
    postal_code VARCHAR(20),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    region VARCHAR(50)
);

CREATE TABLE products (
    product_key SERIAL PRIMARY KEY,
    product_id VARCHAR(50),
    product_name VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    sub_category VARCHAR(100)
);

CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    order_date DATE NOT NULL,
    ship_date DATE,
    ship_mode VARCHAR(50),
    customer_id VARCHAR(50) REFERENCES customers(customer_id),
    location_id INTEGER REFERENCES geography(location_id)
);

CREATE TABLE order_items (
    row_id SERIAL PRIMARY KEY,
    order_id VARCHAR(50) REFERENCES orders(order_id),
    product_key INTEGER REFERENCES products(product_key),  -- Reference surrogate key
    quantity INTEGER NOT NULL,
    sales DECIMAL(10,2) NOT NULL,
    discount DECIMAL(5,4),
    profit DECIMAL(10,2)
);


-- Insert customers (should work fine)
INSERT INTO customers (customer_id, customer_name, segment)
SELECT DISTINCT customer_id, customer_name, segment
FROM sales;

-- Insert geography
INSERT INTO geography (postal_code, city, state, country, region)
SELECT DISTINCT postal_code, city, state, country, region
FROM sales;

-- Insert products (now with surrogate keys)
INSERT INTO products (product_id, product_name, category, sub_category)
SELECT DISTINCT product_id, product_name, category, sub_category
FROM sales;

-- Insert orders
INSERT INTO orders (order_id, order_date, ship_date, ship_mode, customer_id, location_id)
SELECT DISTINCT 
    s.order_id, 
    s.order_date, 
    s.ship_date, 
    s.ship_mode, 
    s.customer_id,
    g.location_id
FROM sales s
JOIN geography g ON s.postal_code = g.postal_code 
                 AND s.city = g.city 
                 AND s.state = g.state;

-- Insert order_items (using product_key)
INSERT INTO order_items (order_id, product_key, quantity, sales, discount, profit)
SELECT 
    s.order_id, 
    p.product_key,  -- Use the surrogate key
    s.quantity, 
    s.sales, 
    s.discount, 
    s.profit
FROM sales s
JOIN products p ON s.product_id = p.product_id 
               AND s.product_name = p.product_name 
               AND s.category = p.category;



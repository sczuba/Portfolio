-- 1. Database Schema Design

-- Create Customers Table
CREATE TABLE Customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(150),
    phone VARCHAR(20),
    registration_date DATE,
    city VARCHAR(100),
    state VARCHAR(50),
    country VARCHAR(50)
);

-- Create Products Table
CREATE TABLE Products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(200),
    category VARCHAR(100),
    price DECIMAL(10, 2)
);

-- Create Sales Table
CREATE TABLE Sales (
    sale_id SERIAL PRIMARY KEY,
    sale_date DATE,
    product_id INT REFERENCES Products(product_id),
    quantity INT,
    total_sale DECIMAL(10, 2)
);

-- Create Time Table (For Time Series Analysis)
CREATE TABLE Time (
    time_id SERIAL PRIMARY KEY,
    year INT,
    quarter INT,
    month INT,
    day INT
);

-- Create Transactions Table (For Link to Customers)
CREATE TABLE Transactions (
    transaction_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES Customers(customer_id),
    sale_id INT REFERENCES Sales(sale_id),
    transaction_date DATE
);


-- 2. ETL Process (Populating Data)

-- Inserting Sample Data into Customers
INSERT INTO Customers (first_name, last_name, email, phone, registration_date, city, state, country)
VALUES 
('John', 'Doe', 'john.doe@example.com', '555-1234', '2022-01-10', 'New York', 'NY', 'USA'),
('Jane', 'Smith', 'jane.smith@example.com', '555-5678', '2022-02-15', 'Los Angeles', 'CA', 'USA');

-- Inserting Sample Data into Products
INSERT INTO Products (product_name, category, price)
VALUES
('Product A', 'Electronics', 199.99),
('Product B', 'Clothing', 29.99);

-- Inserting Sample Data into Sales
INSERT INTO Sales (sale_date, product_id, quantity, total_sale)
VALUES
('2023-01-10', 1, 2, 399.98),
('2023-02-15', 2, 5, 149.95);

-- Inserting Sample Data into Time (Optional, for Time Series Analysis)
INSERT INTO Time (year, quarter, month, day)
VALUES
(2023, 1, 1, 10),
(2023, 1, 2, 15);


-- 3. Customer Segmentation Analysis

WITH Customer_Segmentation AS (
    SELECT 
        c.customer_id,
        c.first_name,
        c.last_name,
        SUM(s.total_sale) AS total_spend,
        COUNT(t.transaction_id) AS purchase_count
    FROM 
        Customers c
    JOIN Transactions t ON c.customer_id = t.customer_id
    JOIN Sales s ON t.sale_id = s.sale_id
    GROUP BY c.customer_id
)
SELECT 
    customer_id,
    first_name,
    last_name,
    total_spend,
    purchase_count,
    CASE 
        WHEN total_spend > 1000 AND purchase_count > 10 THEN 'High Value'
        WHEN total_spend BETWEEN 500 AND 1000 THEN 'Mid Value'
        ELSE 'Low Value'
    END AS customer_segment
FROM Customer_Segmentation;


-- 4. Sales Reporting & KPI Generation

-- Monthly Sales Report
SELECT 
    EXTRACT(YEAR FROM s.sale_date) AS year,
    EXTRACT(MONTH FROM s.sale_date) AS month,
    SUM(s.total_sale) AS monthly_sales,
    COUNT(DISTINCT s.sale_id) AS total_transactions
FROM 
    Sales s
GROUP BY EXTRACT(YEAR FROM s.sale_date), EXTRACT(MONTH FROM s.sale_date)
ORDER BY year, month;


-- Quarterly Sales Growth Rate
WITH Quarterly_Sales AS (
    SELECT 
        EXTRACT(YEAR FROM s.sale_date) AS year,
        CASE 
            WHEN EXTRACT(MONTH FROM s.sale_date) BETWEEN 1 AND 3 THEN 1
            WHEN EXTRACT(MONTH FROM s.sale_date) BETWEEN 4 AND 6 THEN 2
            WHEN EXTRACT(MONTH FROM s.sale_date) BETWEEN 7 AND 9 THEN 3
            WHEN EXTRACT(MONTH FROM s.sale_date) BETWEEN 10 AND 12 THEN 4
        END AS quarter,
        SUM(s.total_sale) AS quarterly_sales
    FROM 
        Sales s
    GROUP BY EXTRACT(YEAR FROM s.sale_date), quarter
)
SELECT 
    year,
    quarter,
    quarterly_sales,
    LAG(quarterly_sales) OVER (ORDER BY year, quarter) AS previous_quarter_sales,
    (quarterly_sales - LAG(quarterly_sales) OVER (ORDER BY year, quarter)) / NULLIF(LAG(quarterly_sales) OVER (ORDER BY year, quarter), 0) * 100 AS growth_rate
FROM Quarterly_Sales;


-- 5. Query Optimization

-- Create index on sale_date for faster queries
CREATE INDEX idx_sale_date ON Sales(sale_date);

-- Create index on customer_id for optimized joins
CREATE INDEX idx_customer_id ON Transactions(customer_id);

-- Analyzing a query execution plan
EXPLAIN ANALYZE 
SELECT 
    EXTRACT(YEAR FROM s.sale_date) AS year,
    EXTRACT(MONTH FROM s.sale_date) AS month,
    SUM(s.total_sale) AS monthly_sales
FROM 
    Sales s
GROUP BY EXTRACT(YEAR FROM s.sale_date), EXTRACT(MONTH FROM s.sale_date)
ORDER BY year, month;


-- 6. Final Reports & Insights

-- Create View for KPIs and Insights
CREATE VIEW sales_kpis AS
SELECT 
    EXTRACT(YEAR FROM s.sale_date) AS year,
    EXTRACT(MONTH FROM s.sale_date) AS month,
    SUM(s.total_sale) AS monthly_sales,
    COUNT(DISTINCT s.sale_id) AS total_transactions,
    COUNT(DISTINCT c.customer_id) AS total_customers
FROM 
    Sales s
JOIN Transactions t2 ON s.sale_id = t2.sale_id
JOIN Customers c ON t2.customer_id = c.customer_id
GROUP BY EXTRACT(YEAR FROM s.sale_date), EXTRACT(MONTH FROM s.sale_date);

-- Query for Insights
SELECT * FROM sales_kpis;

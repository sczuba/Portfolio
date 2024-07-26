/*
    Name: Shiva Czuba
    DTSC660: Data and Database Managment with SQL
    Module 7
    Assignment 5


*/

--------------------------------------------------------------------------------
/*				                 Table Creation		  		          */
--------------------------------------------------------------------------------
CREATE TABLE customer_spending (
    date DATE,
    year INTEGER,
    month VARCHAR (20),
    customer_age INTEGER,
    customer_gender VARCHAR(20),
    country VARCHAR(50),
    state VARCHAR(25),
    product_category VARCHAR(150),
    sub_category VARCHAR(150),
    quantity INTEGER,
    unit_cost NUMERIC,
    unit_price NUMERIC,
    cost NUMERIC,
    revenue NUMERIC);
--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
/*				                 Import Data           		  		          */
--------------------------------------------------------------------------------
COPY customer_spending
FROM 'C:\Users\Public\customer_spending (1).csv' 
WITH (FORMAT CSV, HEADER true);

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
/*				                 Question 1: 		  		          */
--------------------------------------------------------------------------------
SELECT product_category, SUM(revenue) AS total_revenue FROM customer_spending
WHERE YEAR=2016
GROUP BY product_category
ORDER BY product_category;
--------------------------------------------------------------------------------
/*				                  Question 2           		  		          */
--------------------------------------------------------------------------------
SELECT sub_category, AVG(unit_price) AS average_unit_price, AVG(unit_cost) AS average_unit_cost,
AVG(unit_price - unit_cost) AS margin FROM customer_spending
WHERE YEAR=2015 GROUP BY sub_category ORDER BY sub_category;
--------------------------------------------------------------------------------
/*				                  Question 3           		  		          */
--------------------------------------------------------------------------------
SELECT COUNT(*)FROM customer_spending 
WHERE customer_gender = 'F' AND product_category = 'Clothing';
--------------------------------------------------------------------------------
/*				                  Question 4           		  		          */
--------------------------------------------------------------------------------
SELECT customer_age, sub_category,AVG(quantity)AS average_quantity,
AVG(unit_cost)AS average_cost FROM customer_spending
GROUP BY customer_age, sub_category ORDER BY customer_age DESC, sub_category ASC;
--------------------------------------------------------------------------------
/*				                  Question 5           		  		          */
--------------------------------------------------------------------------------
SELECT country FROM customer_spending WHERE customer_age>=18 AND customer_age<=25
GROUP BY country HAVING COUNT(*)>30;
--------------------------------------------------------------------------------
/*				                  Question 6           		  		          */
--------------------------------------------------------------------------------
SELECT sub_category,ROUND(AVG(quantity),2)AS average_quantity,
ROUND(AVG(unit_cost),2)AS average_cost FROM customer_spending
GROUP BY sub_category HAVING COUNT(*)>=10 ORDER BY sub_category;
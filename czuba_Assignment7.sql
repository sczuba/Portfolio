/*
    Name: Shiva Czuba
    DTSC660: Data and Database Managment with SQL
    Module 9
    Assignment 7
*/

--------------------------------------------------------------------------------
/*				                 Question 1:           		  		          */
--------------------------------------------------------------------------------
SELECT c.cust_ID, c.customer_name FROM customer c WHERE EXISTS 
(SELECT 1 FROM loan l JOIN borrower b ON l.loan_number = b.loan_number
WHERE c.cust_ID = b.cust_ID) 
AND NOT EXISTS (SELECT 1 FROM account a JOIN depositor d 
ON a.account_number = d.account_number WHERE c.cust_ID = d.cust_ID);

--------------------------------------------------------------------------------
/*				                  Question 2           		  		          */
--------------------------------------------------------------------------------
SELECT c.cust_ID, c.customer_name FROM customer c
WHERE (c.customer_street, c.customer_city) IN 
(SELECT customer_street, customer_city FROM customer
WHERE cust_ID = '12345');
--------------------------------------------------------------------------------
/*				                  Question 3           		  		          */
--------------------------------------------------------------------------------
SELECT DISTINCT b.branch_name FROM branch b, customer c, account a, depositor d
WHERE b.branch_name = a.branch_name AND c.cust_ID = d.cust_ID
AND a.account_number = d.account_number AND c.customer_city = 'Harrison';
   
--------------------------------------------------------------------------------
/*				                  Question 4           		  		          */
--------------------------------------------------------------------------------
SELECT c.customer_name FROM customer c WHERE NOT EXISTS 
(SELECT 1 FROM branch b WHERE b.branch_city = 'Brooklyn' AND NOT EXISTS 
(SELECT 1 FROM account a JOIN depositor d ON a.account_number = d.account_number
WHERE d.cust_ID = c.cust_ID AND a.branch_name = b.branch_name));
--------------------------------------------------------------------------------
/*				                  Question 5           		  		          */
--------------------------------------------------------------------------------
SELECT c.cust_ID, b.branch_city, c.customer_city, a.account_number FROM customer c
JOIN depositor d ON c.cust_ID = d.cust_ID JOIN account a ON d.account_number = a.account_number
JOIN branch b ON a.branch_name = b.branch_name WHERE c.customer_city = b.branch_city;
    
--------------------------------------------------------------------------------
/*				                  Question 6           		  		          */
--------------------------------------------------------------------------------
SELECT c.customer_name, l.branch_name FROM customer c
JOIN borrower b ON c.cust_ID = b.cust_ID JOIN loan l ON b.loan_number = l.loan_number
WHERE l.branch_name = 'Yonkahs Bankahs';
    
--------------------------------------------------------------------------------
/*				                  Question 7           		  		          */
--------------------------------------------------------------------------------
SELECT c.customer_name, l.loan_number FROM customer c
JOIN borrower br ON c.cust_ID = br.cust_ID JOIN loan l ON br.loan_number = l.loan_number
WHERE l.amount > CAST(5000 AS money);
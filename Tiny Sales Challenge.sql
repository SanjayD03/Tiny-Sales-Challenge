CREATE DATABASE data_in_motion;

USE data_in_motion;

CREATE TABLE customers (
    customer_id integer PRIMARY KEY,
    first_name varchar(100),
    last_name varchar(100),
    email varchar(100)
);

CREATE TABLE products (
    product_id integer PRIMARY KEY,
    product_name varchar(100),
    price decimal
);

CREATE TABLE orders (
    order_id integer PRIMARY KEY,
    customer_id integer,
    order_date date
);

CREATE TABLE order_items (
    order_id integer,
    product_id integer,
    quantity integer
);

INSERT INTO customers (customer_id, first_name, last_name, email) VALUES
(1, 'John', 'Doe', 'johndoe@email.com'),
(2, 'Jane', 'Smith', 'janesmith@email.com'),
(3, 'Bob', 'Johnson', 'bobjohnson@email.com'),
(4, 'Alice', 'Brown', 'alicebrown@email.com'),
(5, 'Charlie', 'Davis', 'charliedavis@email.com'),
(6, 'Eva', 'Fisher', 'evafisher@email.com'),
(7, 'George', 'Harris', 'georgeharris@email.com'),
(8, 'Ivy', 'Jones', 'ivyjones@email.com'),
(9, 'Kevin', 'Miller', 'kevinmiller@email.com'),
(10, 'Lily', 'Nelson', 'lilynelson@email.com'),
(11, 'Oliver', 'Patterson', 'oliverpatterson@email.com'),
(12, 'Quinn', 'Roberts', 'quinnroberts@email.com'),
(13, 'Sophia', 'Thomas', 'sophiathomas@email.com');

INSERT INTO products (product_id, product_name, price) VALUES
(1, 'Product A', 10.00),
(2, 'Product B', 15.00),
(3, 'Product C', 20.00),
(4, 'Product D', 25.00),
(5, 'Product E', 30.00),
(6, 'Product F', 35.00),
(7, 'Product G', 40.00),
(8, 'Product H', 45.00),
(9, 'Product I', 50.00),
(10, 'Product J', 55.00),
(11, 'Product K', 60.00),
(12, 'Product L', 65.00),
(13, 'Product M', 70.00);

INSERT INTO orders (order_id, customer_id, order_date) VALUES
(1, 1, '2023-05-01'),
(2, 2, '2023-05-02'),
(3, 3, '2023-05-03'),
(4, 1, '2023-05-04'),
(5, 2, '2023-05-05'),
(6, 3, '2023-05-06'),
(7, 4, '2023-05-07'),
(8, 5, '2023-05-08'),
(9, 6, '2023-05-09'),
(10, 7, '2023-05-10'),
(11, 8, '2023-05-11'),
(12, 9, '2023-05-12'),
(13, 10, '2023-05-13'),
(14, 11, '2023-05-14'),
(15, 12, '2023-05-15'),
(16, 13, '2023-05-16');

INSERT INTO order_items (order_id, product_id, quantity) VALUES
(1, 1, 2),
(1, 2, 1),
(2, 2, 1),
(2, 3, 3),
(3, 1, 1),
(3, 3, 2),
(4, 2, 4),
(4, 3, 1),
(5, 1, 1),
(5, 3, 2),
(6, 2, 3),
(6, 1, 1),
(7, 4, 1),
(7, 5, 2),
(8, 6, 3),
(8, 7, 1),
(9, 8, 2),
(9, 9, 1),
(10, 10, 3),
(10, 11, 2),
(11, 12, 1),
(11, 13, 3),
(12, 4, 2),
(12, 5, 1),
(13, 6, 3),
(13, 7, 2),
(14, 8, 1),
(14, 9, 2),
(15, 10, 3),
(15, 11, 1),
(16, 12, 2),
(16, 13, 3);

------------------------------------------------------------------------------------------------------------------------------------------------------------------
#Questions
/*
1. Which product has the highest price? Only return a single row.
2. Which customer has made the most orders?
3. What’s the total revenue per product?
4. Find the day with the highest revenue.
5. Find the first order (by date) for each customer.
6. Find the top 3 customers who have ordered the most distinct products
7. Which product has been bought the least in terms of quantity?
8. What is the median order total?
9. For each order, determine if it was ‘Expensive’ (total over 300), ‘Affordable’ (total over 100), or ‘Cheap’.
10. Find customers who have ordered the product with the highest price.
*/
------------------------------------------------------------------------------------------------------------------------------------------------------------------
#1. Which product has the highest price? Only return a single row.

SELECT product_id,
	   product_name,
	   price
FROM products
ORDER BY price DESC
LIMIT 1;

                                /* OR */
                                
SELECT product_id,
	   product_name,
       price
FROM products
WHERE PRICE = (SELECT MAX(price) FROM products);

------------------------------------------------------------------------------------------------------------------------------------------------------------------
#2. Which customer has made the most orders?

SELECT c.customer_id,
	   c.first_name,
       c.last_name,
       COUNT(o.order_id) AS 'total orders'
FROM customers c
JOIN orders o 
USING(customer_id)
GROUP BY o.customer_id
ORDER BY COUNT(o.order_id) DESC;

------------------------------------------------------------------------------------------------------------------------------------------------------------------
#3. What’s the total revenue per product?

SELECT p.product_id,
       p.product_name,
       SUM(p.price*o.quantity) AS 'Total Revenue'
FROM products p 
JOIN order_items o 
USING(product_id)
GROUP BY o.product_id
ORDER BY SUM(p.price*o.quantity) DESC;

------------------------------------------------------------------------------------------------------------------------------------------------------------------
#4. Find the day with the highest revenue.

SELECT o.order_date AS DATE, 
	   DAYNAME(o.order_date)AS Day_name,
       SUM(p.price*ot.quantity) AS 'Total Revenue'
FROM orders o 
JOIN order_items ot 
USING(order_id)
JOIN products p 
USING(product_id)
GROUP BY o.order_date
ORDER BY  SUM(p.price*ot.quantity) DESC;

------------------------------------------------------------------------------------------------------------------------------------------------------------------
#5.Find the first order (by date) for each customer.

SELECT c.customer_id,
	   c.first_name,
       c.last_name,
       MIN(o.order_date) AS First_order_date
FROM customers c 
JOIN orders o 
USING(customer_id)
GROUP BY 1;

                               /* OR */
                               
SELECT customer_id, 
       first_name,
       last_name, 
       order_date
FROM (
  SELECT c.customer_id, c.first_name,c.last_name, o.order_date,
    RANK() OVER (PARTITION BY c.customer_id ORDER BY o.order_date) AS order_rank
  FROM customers c
  JOIN orders o 
  USING(customer_id)
) AS ranked_orders
WHERE order_rank = 1;
------------------------------------------------------------------------------------------------------------------------------------------------------------------
#6.Find the top 3 customers who have ordered the most distinct products

SELECT c.customer_id,
       CONCAT(c.first_name,' ', c.last_name) as 'Full Name', 
	   COUNT(DISTINCT ot.product_id) AS distinct_product_count
FROM customers c
JOIN orders o 
USING(customer_id)
JOIN order_items ot 
USING(order_id)
GROUP BY 1,2
ORDER BY distinct_product_count DESC
LIMIT 3;

------------------------------------------------------------------------------------------------------------------------------------------------------------------
 #7. Which product has been bought the least in terms of quantity?
 
SELECT p.product_id,
	   p.product_name,
       SUM(ot.quantity) as "Total Quantity"
FROM products p 
JOIN order_items ot 
USING(product_id)
GROUP BY 1
ORDER BY SUM(ot.quantity);

 ------------------------------------------------------------------------------------------------------------------------------------------------------------------
 #8. What is the median order total?
 
SELECT round(avg(total_order),2) AS median
FROM(
SELECT ot.order_id,sum(p.price*ot.quantity) AS total_order
FROM products p
JOIN order_items ot
USING(product_id)
GROUP BY 1
ORDER BY total_order DESC
)
as Total;

------------------------------------------------------------------------------------------------------------------------------------------------------------------
#9. For each order, determine if it was ‘Expensive’ (total over 300), ‘Affordable’ (total over 100), or ‘Cheap’.

SELECT o.order_id,
case
	WHEN SUM(ot.quantity*p.price)>300 THEN "Expensive"
	WHEN SUM(ot.quantity*p.price)>100 THEN "Affordable"
	ELSE "cheap" 
END  AS "Budget Category"
FROM order_items ot
JOIN orders o
USING(order_id)
JOIN products p 
USING(product_id)
GROUP BY 1;

------------------------------------------------------------------------------------------------------------------------------------------------------------------
#10. Find customers who have ordered the product with the highest price.

SELECT c.customer_id,
	   CONCAT(c.first_name,' ',c.last_name) AS Full_name,
       MAX(p.price) AS Highest_price
FROM customers c 
JOIN orders o 
USING(customer_id)
JOIN order_items ot
USING(order_id)
JOIN products p 
USING(product_id)
WHERE p.price = (SELECT max(price) FROM products)
GROUP BY 1,2;

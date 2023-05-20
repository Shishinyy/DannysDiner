-- Create data set

CREATE TABLE sales (
    customer_id VARCHAR(1),
    order_date DATE,
    product_id INT
);


INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');


CREATE TABLE menu (
    product_id INT,
    product_name VARCHAR(5),
    price INT
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');


CREATE TABLE members (
    customer_id VARCHAR(1),
    join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
-- total amount each customer spent at the restaurant

SELECT 
    s.customer_id, SUM(m.price) AS total_spent
FROM
    sales s
        JOIN
    menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;

-- Counts of days each customer visited the restaurant

SELECT 
    customer_id, COUNT(DISTINCT order_date)
FROM
    sales
GROUP BY customer_id;

-- first menu item purchased by each customer 

WITH the_rank as 
(
	SELECT 
		s.customer_id, m.product_name, s.order_date,
        RANK() OVER ( partition by s.customer_id order by s.order_date) as date_rank
	FROM 
		sales s
			JOIN 
		menu m ON s.product_id = m.product_id
	GROUP BY s.customer_id, m.product_name, s.order_date
)
SELECT 
	customer_id, product_name
FROM 
	the_rank
WHERE date_rank = 1;

-- Most purchased items on the menu 

SELECT 
    product_name, COUNT(product_name) AS times_purchased
FROM
    menu m
        JOIN
    sales s ON m.product_id = s.product_id
GROUP BY product_name
ORDER BY times_purchased DESC;

-- Most popular item for each customer

WITH item as 
( 
	SELECT 
		s.customer_id , m.product_name, count(m.product_name) as popular_item,
	RANK() OVER ( PARTITION BY s.customer_id ORDER BY count(m.product_name) DESC ) as the_rank
	FROM 
		sales s
			JOIN 
		menu m ON s.product_id = m.product_id
	GROUP BY s.customer_id,m.product_name
)
SELECT 
	customer_id,product_name
FROM 
	item
WHERE the_rank = 1;

-- First item purchased by each customer after becoming a member

WITH CTE as 
( 	SELECT 
		s.customer_id, m.product_name, s.order_date, me.join_date,
		RANK() OVER ( PARTITION BY s.customer_id ORDER BY order_date ) as first_item
	FROM 
		sales s 
			JOIN 
		members me ON s.customer_id = me.customer_id
			JOIN 
		menu m ON s.product_id = m.product_id 
	WHERE order_date >= join_date
)
SELECT 
	customer_id,product_name
FROM 
	CTE 
WHERE first_item = 1;

-- Last item purchased by each customer before becoming a member

WITH CTE as 
( 	SELECT 
		s.customer_id, m.product_name, s.order_date, me.join_date,
		RANK() OVER ( PARTITION BY s.customer_id ORDER BY order_date DESC ) as first_item
	FROM 
		sales s 
			JOIN 
        members me ON s.customer_id = me.customer_id
			JOIN 
		menu m ON s.product_id = m.product_id 
	WHERE order_date < join_date
)
SELECT 
	customer_id,product_name
FROM 
	CTE 
WHERE first_item = 1;

-- Total amount spent by each customer before becoming a member

SELECT 
    s.customer_id,
    COUNT(s.product_id) total_items,
    SUM(m.price) total_spent
FROM
    sales s
        JOIN
    menu m ON s.product_id = m.product_id
        JOIN
    members me ON s.customer_id = me.customer_id
WHERE
    s.order_date < me.join_date
GROUP BY s.customer_id
ORDER BY s.customer_id;

-- Points each customer have if each $1 spent equates to 10 points and sushi has a 2x points multiplier

SELECT 
    s.customer_id,
    SUM(CASE
        WHEN m.product_name = 'Sushi' THEN m.price * 10 * 2
        ELSE m.price * 10
    END) AS total_points
FROM
    Sales s
        JOIN
    menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;

-- Points customer A and B have at the end of January if they earned 2x points on all items in their first week after joining the program

SELECT 
    s.customer_id,
    SUM(CASE
        WHEN s.order_date BETWEEN me.join_date AND DATE_ADD(me.join_date, INTERVAL 6 DAY) THEN m.price * 10 * 2
        WHEN m.product_name = 'sushi' THEN m.price * 10 * 2
        ELSE m.price * 10
    END) AS total_points
FROM
    Sales s
        JOIN
    menu m ON s.product_id = m.product_id
        JOIN
    members me ON s.customer_id = me.customer_id
WHERE
    s.order_date <= '2021-01-31'
GROUP BY s.customer_id;
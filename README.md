![1](https://github.com/Shishinyy/DannysDiner/assets/134147196/4dd05675-a813-40d0-8b38-af8dbb07765e)

**Introduction**

Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen.

The restaurant has captured some very basic data from their few months of operation but have no idea how to use their data to help them run the business.

**Project Insights**

**Entity Relationship Diagram**

![](media/b80aab40727b7b71f76734568c9755ef.png)

**Questions**

1.  **What is the total amount each customer spent at the restaurant?**

```
SELECT 
    s.customer_id, SUM(m.price) AS total_spent
FROM
    sales s
        JOIN
    menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;
```

**![A screenshot of a computer Description automatically generated with low confidence](media/8e7183f2052f359c4d6a7f90b7354a9e.png)**

1.  **How many days has each customer visited the restaurant?**

```
SELECT 
    customer_id, COUNT(DISTINCT order_date)
FROM
    sales
GROUP BY customer_id;
```

**![A screenshot of a computer Description automatically generated with low confidence](media/de2246fd03c937040cf82ab59f8ecf25.png)**

1.  **What was the first item from the menu purchased by each customer?**

```
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
```

**![A screenshot of a computer Description automatically generated with low confidence](media/823e251f4f0e7ac5b49edfcda3db3003.png)**

1.  **What is the most purchased item on the menu and how many times was it purchased by all customers?**

```
SELECT 
    product_name, COUNT(product_name) AS times_purchased
FROM
    menu m
        JOIN
    sales s ON m.product_id = s.product_id
GROUP BY product_name
ORDER BY times_purchased DESC;
```

**![A screenshot of a computer Description automatically generated with low confidence](media/06f944fc9c0d6c50d8da4c4d1afaedca.png)**

1.  **Which item was the most popular for each customer?**

```
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
```

**![A screenshot of a computer Description automatically generated with low confidence](media/d081d75c8a5f0354d4b98bea0e48e62b.png)**

1.  **Which item was purchased first by the customer after they became a member?**

```
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
```

**![A screenshot of a computer Description automatically generated with low confidence](media/494b43d5b732ad43181553563dfd67fe.png)**

1.  **Which item was purchased just before the customer became a member?**

```
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
```

**![A screenshot of a computer Description automatically generated with low confidence](media/9f4dd5c687667d6935c8dae3ba2d1f2d.png)**

1.  **What is the total items and amount spent for each member before they became a member?**

```
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
```

**![A screenshot of a computer Description automatically generated with low confidence](media/b5a7ad2a7f5cc5db0ad9125d4ef91e06.png)**

1.  **If each \$1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?**

```
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
```

**![A screenshot of a computer Description automatically generated with low confidence](media/2e78ac8ee12df09e3d93db0b8228cacf.png)**

1.  **In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?**

```
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
```

![A screenshot of a computer Description automatically generated with low confidence](media/b60673304284049cb2e65c977e37bc24.png)

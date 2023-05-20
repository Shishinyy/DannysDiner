![1](https://github.com/Shishinyy/DannysDiner/assets/134147196/4dd05675-a813-40d0-8b38-af8dbb07765e)

**Introduction**

Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen.

The restaurant has captured some very basic data from their few months of operation but have no idea how to use their data to help them run the business.

**Project Insights**

**Entity Relationship Diagram**

![Danny](https://github.com/Shishinyy/DannysDiner/assets/134147196/bef29d9d-ee5d-411a-a4f2-e0517241f11b)

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

![image](https://github.com/Shishinyy/DannysDiner/assets/134147196/656d3a0c-a8a4-4c8e-886c-be481eb85c57)

2.  **How many days has each customer visited the restaurant?**

```
SELECT 
    customer_id, COUNT(DISTINCT order_date)
FROM
    sales
GROUP BY customer_id;
```

![image](https://github.com/Shishinyy/DannysDiner/assets/134147196/320b0e5d-7bfd-4a90-a049-18e0ed6ddc7d)

3.  **What was the first item from the menu purchased by each customer?**

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

![image](https://github.com/Shishinyy/DannysDiner/assets/134147196/f04e7ac9-7c31-40e3-a87e-154ef1331de4)

4.  **What is the most purchased item on the menu and how many times was it purchased by all customers?**

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

![image](https://github.com/Shishinyy/DannysDiner/assets/134147196/c1da3b8f-ba8f-427c-8e00-7cac0b33ea46)

5.  **Which item was the most popular for each customer?**

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

![image](https://github.com/Shishinyy/DannysDiner/assets/134147196/c857392c-6e5f-465e-adbe-7f89f593552c)

6.  **Which item was purchased first by the customer after they became a member?**

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

![image](https://github.com/Shishinyy/DannysDiner/assets/134147196/20c444f0-3446-452c-8fe4-12fa60cdd8b4)

7.  **Which item was purchased just before the customer became a member?**

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

![image](https://github.com/Shishinyy/DannysDiner/assets/134147196/74b9f0e2-e562-468a-b01e-aba3502d87a3)

8.  **What is the total items and amount spent for each member before they became a member?**

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

![image](https://github.com/Shishinyy/DannysDiner/assets/134147196/0681f19d-c187-461f-87f2-e6ab7809872c)

9.  **If each \$1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?**

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

![image](https://github.com/Shishinyy/DannysDiner/assets/134147196/bd7b20ff-d5aa-4a39-a55d-324ad1d388a8)

10.  **In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?**

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

![image](https://github.com/Shishinyy/DannysDiner/assets/134147196/d7ebed97-f11f-49dc-be4b-b8453d55b4fb)

![](RackMultipart20230520-1-43n830_html_ac2be78354216ff7.png)

**Introduction**

Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen.

The restaurant has captured some very basic data from their few months of operation but have no idea how to use their data to help them run the business.

**Project Insights**

**Entity Relationship Diagram**

![](RackMultipart20230520-1-43n830_html_54007ed99c90f295.png)

**Questions**

1. **What is the total amount each customer spent at the restaurant?**

SELECT

s.customer\_id, SUM(m.price) AS total\_spent

FROM

sales s

JOIN

menu m ON s.product\_id = m.product\_id

GROUP BY s.customer\_id;

![](RackMultipart20230520-1-43n830_html_83467129bf5d5fb3.png)

1. **How many days has each customer visited the restaurant?**

SELECT

customer\_id, COUNT(DISTINCT order\_date)

FROM

sales

GROUP BY customer\_id;

![](RackMultipart20230520-1-43n830_html_254da14448243ac.png)

1. **What was the first item from the menu purchased by each customer?**

WITH the\_rank as

(

SELECT

s.customer\_id, m.product\_name, s.order\_date,

RANK() OVER ( partition by s.customer\_id order by s.order\_date) as date\_rank

FROM

sales s

JOIN

menu m ON s.product\_id = m.product\_id

GROUP BY s.customer\_id, m.product\_name, s.order\_date

)

SELECT

customer\_id, product\_name

FROM

the\_rank

WHERE date\_rank = 1;

![](RackMultipart20230520-1-43n830_html_7a5be439cae675bd.png)

1. **What is the most purchased item on the menu and how many times was it purchased by all customers?**

SELECT

product\_name, COUNT(product\_name) AS times\_purchased

FROM

menu m

JOIN

sales s ON m.product\_id = s.product\_id

GROUP BY product\_name

ORDER BY times\_purchased DESC;

![](RackMultipart20230520-1-43n830_html_af57ebe2ffda8677.png)

1. **Which item was the most popular for each customer?**

WITH item as

(

SELECT

s.customer\_id , m.product\_name, count(m.product\_name) as popular\_item,

RANK() OVER ( PARTITION BY s.customer\_id ORDER BY count(m.product\_name) DESC ) as the\_rank

FROM

sales s

JOIN

menu m ON s.product\_id = m.product\_id

GROUP BY s.customer\_id,m.product\_name

)

SELECT

customer\_id,product\_name

FROM

item

WHERE the\_rank = 1;

![](RackMultipart20230520-1-43n830_html_7d7d6a2e9388aa64.png)

1. **Which item was purchased first by the customer after they became a member?**

WITH CTE as

( SELECT

s.customer\_id, m.product\_name, s.order\_date, me.join\_date,

RANK() OVER ( PARTITION BY s.customer\_id ORDER BY order\_date ) as first\_item

FROM

sales s

JOIN

members me ON s.customer\_id = me.customer\_id

JOIN

menu m ON s.product\_id = m.product\_id

WHERE order\_date \>= join\_date

)

SELECT

customer\_id,product\_name

FROM

CTE

WHERE first\_item = 1;

![](RackMultipart20230520-1-43n830_html_18fe57eeaaa04eed.png)

1. **Which item was purchased just before the customer became a member?**

WITH CTE as

( SELECT

s.customer\_id, m.product\_name, s.order\_date, me.join\_date,

RANK() OVER ( PARTITION BY s.customer\_id ORDER BY order\_date DESC ) as first\_item

FROM

sales s

JOIN

members me ON s.customer\_id = me.customer\_id

JOIN

menu m ON s.product\_id = m.product\_id

WHERE order\_date \< join\_date

)

SELECT

customer\_id,product\_name

FROM

CTE

WHERE first\_item = 1;

![](RackMultipart20230520-1-43n830_html_c6445c3d0ba74d60.png)

1. **What is the total items and amount spent for each member before they became a member?**

SELECT

s.customer\_id,

COUNT(s.product\_id) total\_items,

SUM(m.price) total\_spent

FROM

sales s

JOIN

menu m ON s.product\_id = m.product\_id

JOIN

members me ON s.customer\_id = me.customer\_id

WHERE

s.order\_date \< me.join\_date

GROUP BY s.customer\_id

ORDER BY s.customer\_id;

![](RackMultipart20230520-1-43n830_html_64fc055b56e0dcf0.png)

1. **If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?**

SELECT

s.customer\_id,

SUM(CASE

WHEN m.product\_name = 'Sushi' THEN m.price \* 10 \* 2

ELSE m.price \* 10

END) AS total\_points

FROM

Sales s

JOIN

menu m ON s.product\_id = m.product\_id

GROUP BY s.customer\_id;

![](RackMultipart20230520-1-43n830_html_870ca14588f6d246.png)

1. **In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?**

SELECT

s.customer\_id,

SUM(CASE

WHEN s.order\_date BETWEEN me.join\_date AND DATE\_ADD(me.join\_date, INTERVAL 6 DAY) THEN m.price \* 10 \* 2

WHEN m.product\_name = 'sushi' THEN m.price \* 10 \* 2

ELSE m.price \* 10

END) AS total\_points

FROM

Sales s

JOIN

menu m ON s.product\_id = m.product\_id

JOIN

members me ON s.customer\_id = me.customer\_id

WHERE

s.order\_date \<= '2021-01-31'

GROUP BY s.customer\_id;

![](RackMultipart20230520-1-43n830_html_d2634149f2224883.png)

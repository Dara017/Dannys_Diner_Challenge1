-- CASE STUDY QUESTIONS

--1) What is the total amount each customer spent at the restaurant?
SELECT s.customer_id, SUM(m.price) AS total_spent
FROM sales AS s
INNER JOIN menu AS m ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id ASC

--2) How many days has each customer visited the restaurant?
SELECT customer_id, COUNT(DISTINCT order_date) AS Days
FROM sales
GROUP BY customer_id

--3) What was the first item from the menu purchased by each customer?
WITH first_order AS (
SELECT customer_id, MIN (order_date) AS first_date
FROM sales
GROUP BY customer_id
)
SELECT s.customer_id, m.product_name, fo.first_date
FROM sales AS s
INNER JOIN menu AS m ON s.product_id = m.product_id
INNER JOIN first_order AS fo ON s.order_date = fo.first_date

--4) What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT m.product_name, COUNT(s.order_date) AS most_purchased
FROM sales AS s
INNER JOIN menu AS m ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY most_purchased DESC

--5) Which item was the most popular for each customer?
SELECT s.customer_id, m.product_name, COUNT(*) AS number_of_orders
FROM sales AS s
INNER JOIN menu AS m ON s.product_id = m.product_id
GROUP BY s.customer_id, m.product_name
ORDER BY number_of_orders DESC

--6)  Which item was purchased first by the customer after they became a member?
SELECT customer_id, product_name, order_date
FROM 
(SELECT s.customer_id, m.product_name, s.order_date, 
 RANK() OVER(PARTITION BY s.customer_id
            ORDER BY s.order_date) AS rank
FROM sales AS s
INNER JOIN menu AS m
       ON m.product_id = s.product_id
INNER JOIN members AS me 
       ON me.customer_id = s.customer_id
WHERE me.join_date < s.order_date) AS purchase_after_member
WHERE rank = 1

-- 7) Which item was purchased just before the customer became a member?
SELECT customer_id, product_name, order_date
FROM 
(SELECT s.customer_id, m.product_name, s.order_date, 
 RANK() OVER(PARTITION BY s.customer_id
            ORDER BY s.order_date) AS rank
FROM sales AS s
INNER JOIN menu AS m
       ON m.product_id = s.product_id
INNER JOIN members AS me 
       ON me.customer_id = s.customer_id
WHERE me.join_date > s.order_date) AS purchase_before_member
WHERE rank = 1

--8) What is the total items and amount spent for each member before they became a member?
SELECT customer_id, total_items, total_spent
FROM 
(SELECT s.customer_id, COUNT(S.order_date) AS total_items, SUM(m.price) AS total_spent
FROM sales AS s
INNER JOIN menu AS m
       ON m.product_id = s.product_id
INNER JOIN members AS me 
       ON me.customer_id = s.customer_id
WHERE me.join_date > s.order_date
GROUP BY s.customer_id) AS purchase_before_member
ORDER BY customer_id ASC

--9) If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT s.customer_id, SUM(
  							CASE WHEN m.product_name = 'sushi' 
  								 THEN m.price * 20
								 ELSE m.price * 10 END) AS Total_Points
FROM sales AS s
INNER JOIN menu AS m ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id ASC

--10)  In the first week after a customer joins the program (including their join date) they earn 2x 
--     points on all items, not just sushi - how many points do customer A and B have at the end of January?
SELECT customer_id, Total_Points
FROM 
(SELECT s.customer_id, SUM(CASE WHEN order_date >= join_date AND order_date <= join_date + 7 THEN price * 20 
                            WHEN product_name = 'sushi' then price * 20
                            ELSE price * 10 END) AS Total_Points
FROM sales AS s
INNER JOIN menu AS m
       ON m.product_id = s.product_id
INNER JOIN members AS me 
       ON me.customer_id = s.customer_id
WHERE s.order_date BETWEEN '2021-01-01' AND '2021-01-31'
GROUP BY s.customer_id) AS TP_Calculation
ORDER BY customer_id ASC




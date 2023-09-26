-- A schema was created (dannys_dinner) which was filled with tables sales,menu and members. sales with columns:
-- customer_id,order_date,product_id
-- MENU COLUMNS:
-- product_id
-- product_name
-- price
-- MEMBER COLUMNS:
-- customer_id
-- join_date

CREATE SCHEMA dannys_diner;
use dannys_diner;

CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
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
 select * from sales;

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  select * from menu;

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  select * from members;
  
  -- To get integrated insights by combing the table
  
  SELECT
        s.customer_id,m.join_date,me.product_id,
        me.product_name,me.price,s.order_date 
    from sales s
   left join members m on s.customer_id = m. customer_id
	join menu me on s.product_id = me.product_id
    order by s.customer_id,s.order_date ASC;
    
  -- CASE STUDY--
-- What is the total amount each customer spent at the restaurant?

select s.customer_id,sum(me.price)as total_spent
from sales s
inner join menu me on s.product_id = me.product_id
group by s.customer_id
order by s.customer_id
;

-- How many days has each customer visited the restaurant?

select customer_id,count(distinct(order_date)) as days_visited
from sales
group by customer_id
order by days_visited;

-- What was the first item from the menu purchased by each customer?--

select s.customer_id,me.product_name,me.product_id
from sales s inner join menu me on s.product_id = me.product_id
where customer_id = 'A'
order by order_date,product_id;

select s.customer_id,me.product_name,me.product_id
from sales s inner join menu me on s.product_id = me.product_id
where customer_id = 'B'
order by s.order_date,s.product_id;

select s.customer_id,me.product_name,me.product_id
from sales s inner join menu me on s.product_id = me.product_id
where customer_id = 'C'
order by s.order_date,me.product_id;

-- What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT me.product_name,count(product_name) as num_purchased 
from sales s inner join menu me on s.product_id = me.product_id
group by me.product_name
order by 2 desc
limit 1 ;

-- Which item was the most popular for each customer?--

select s.customer_id,me.product_name,count(product_name) as popular_buy
from sales s
inner join menu me on s.product_id = me.product_id
where customer_id = 'A'
group by s.customer_id,me.product_name
order by 3 desc;
    
select s.customer_id,me.product_name,count(product_name) as popular_buy
from sales s
inner join menu me on s.product_id = me.product_id
where customer_id = 'B'
group by s.customer_id,me.product_name
order by 3 desc;

select s.customer_id,me.product_name,count(product_name) as popular_buy
from sales s
inner join menu me on s.product_id = me.product_id
where customer_id = 'C'
group by s.customer_id,me.product_name
order by 3 desc;

-- Which item was purchased first by the customer after they became a member?--
 
WITH members_sales_cte as
(
SELECT		s.customer_id, s.order_date, m.join_date, s.product_id,
		DENSE_RANK () OVER (PARTITION BY s.customer_id 
ORDER BY s.order_Date) as rnk
FROM		sales s
			JOIN members m 
			ON s.customer_id = m.customer_id
WHERE	s.order_date >= m.join_date
)
SELECT		m1.customer_id, m1.order_date, m.product_name,m1.rnk
FROM		members_sales_cte as m1
			JOIN menu as m 
			ON m1.product_id = m.product_id
WHERE	m1.rnk = 1
ORDER BY	m1.customer_id;	

-- Which item was purchased just before the customer became a member?--

WITH members_priorsales_cte as
(
SELECT		s.customer_id, s.order_date, m.join_date, s.product_id,
		DENSE_RANK () OVER (PARTITION BY s.customer_id 
ORDER BY s.order_Date) as rnk
FROM		sales s
			JOIN members m 
			ON s.customer_id = m.customer_id
)
SELECT		m1.customer_id, m1.order_date,m1.join_date,me.product_name
FROM		members_priorsales_cte  m1
			JOIN menu me 
			ON m1.product_id = me.product_id
WHERE	m1.rnk = 1
ORDER BY	m1.customer_id;	

-- What is the total items and amount spent for each member before they became a member?--

select s.customer_id, count(me.product_name) as total_items,sum(me.price) as total_price
  from sales s
 inner join menu me on s.product_id = me.product_id
inner join members m on m.customer_id = s.customer_id
 where m.join_date > s.order_date
 group by s.customer_id
 order by 3;

-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?--

  SELECT points1.customer_id, sum(points1.loyalty_points) as total_points
  FROM    (
          SELECT s.customer_id,
		 CASE 
		 WHEN 
		 me.product_name = 'sushi' then me.price*20 
		 ELSE me.price*10
		 END as loyalty_points
FROM 	         sales s 
                   INNER JOIN menu me
		    ON s.product_id = me.product_id  
	 ) as points1
GROUP BY	 points1.customer_id
ORDER BY	 1, 2 DESC;
  
  
-- In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - 
-- how many points do customer A and B have at the end of January?

SELECT s.customer_id,count(m.join_date) as firstweek, sum(me.price * 20 ) as total_firstweek_points
from sales s
inner join menu me on s.product_id = me.product_id
inner join members m on s.customer_id = m.customer_id
	where join_date >= '2021-01-07' AND customer_id = A and B
GROUP BY	 firstweek
ORDER BY	 1, 2 DESC;



  
  
  
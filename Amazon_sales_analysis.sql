-- Create Tables
CREATE TABLE amazon_saless (
    index INT,
    order_id VARCHAR(50),
    order_date DATE,
    status VARCHAR(50),
    fulfilment VARCHAR(50),
    sales_channel VARCHAR(50),
    ship_service_level VARCHAR(50),
    style VARCHAR(100),
    sku VARCHAR(100),
    category VARCHAR(50),
    size VARCHAR(20),
    asin VARCHAR(50),
    courier_status VARCHAR(50),
    qty INT,
    currency VARCHAR(10),
    amount NUMERIC(10,2),
    ship_city VARCHAR(100),
    ship_state VARCHAR(100),
    ship_postal_code VARCHAR(20),
    ship_country VARCHAR(50),
    promotion_ids TEXT,
    b2b BOOLEAN,
    fulfilled_by VARCHAR(50),
	extra_column TEXT
);
drop table amazon_sales;
-- Import Data into Books Table
COPY amazon_saless(
    index,
    order_id,
    order_date,
    status,
    fulfilment,
    sales_channel,
    ship_service_level,
    style,
    sku,
    category,
    size,
    asin,
    courier_status,
    qty,
    currency,
    amount,
    ship_city,
    ship_state,
    ship_postal_code,
    ship_country,
    promotion_ids,
    b2b,
    fulfilled_by,
	extra_column
)
FROM 'C:\Users\Lenovo\Desktop\SQL Project\Amazon Sale Report.csv'
CSV HEADER;

-- Display all orders.
select * from amazon_saless;

-- Show distinct product categories.
select distinct(category) from amazon_saless;

-- Find total number of orders.
select count(order_id) from amazon_saless;

-- Find total quantity sold.
select sum(qty) from amazon_saless
where status='Shipped';

-- Find average order amount.
select round(avg(amount),2) from amazon_saless;

-- Find maximum order amount.
select max(amount) from amazon_saless;

-- Find minimum order amount.
select min(amount) from amazon_saless;

-- Show all cancelled orders.
select * from amazon_saless
where status='Cancelled';

-- Find all B2B orders.
select * from amazon_saless
where b2b='true';

-- Count orders by category.
select category,count(order_id) as orders
from amazon_saless
group by category;


-- Intermediate Questions


-- Find total revenue generated.
SELECT SUM(amount) as total_revenue
FROM amazon_saless;

-- Find revenue by category.
select category,sum(amount) as revenue 
from amazon_saless
group by category;

-- Find quantity sold by category.
select category,sum(qty) as quantity_sold
from amazon_saless
where status='Shipped'
group by category;

-- Find top 10 states by revenue.
select ship_state,sum(amount) as revenue 
from amazon_saless
where amount is not null
group by ship_state
order by revenue desc 
limit 10;

-- Find top 10 cities by revenue.
select ship_city,sum(amount) as revenue 
from amazon_saless
where amount is not null
group by ship_city
order by revenue desc 
limit 10;


-- Find number of orders by status.
select status,count(order_id) as num_of_orders
from amazon_saless
group by status;

-- Find percentage of cancelled orders.
select round(count(status)*100.0/(select count(status) from amazon_saless),2)
as cancelled_per
from amazon_saless
where status='Cancelled';    --its applied only outer query not subquery


-- Find average order amount by category.
select category,round(avg(amount),2)as avg_order_amt 
from amazon_saless
group by category;

-- Find revenue generated through each fulfillment type.

select fulfilment,sum(amount)as revenue from amazon_saless
group by fulfilment;

-- Find revenue generated through each sales channel.

select sales_channel,coalesce(sum(amount),0)as revenue from amazon_saless
group by sales_channel;

-- Find top 10 highest-value orders.

select order_id,amount
from amazon_saless
where amount is not null
order by amount desc
limit 10;

-- Find categories with revenue greater than ₹10 lakh.

select category,sum(amount) as revenue
from amazon_saless
group by category
having sum(amount)>1000000;


-- Find states where revenue exceeds ₹5 lakh.
select ship_state,sum(amount) as revenue
from amazon_saless
group by ship_state
having sum(amount)>500000;


-- Find average quantity sold per order.

select round(avg(qty),2)as avg_qty 
from amazon_saless;


-- Find categories having more than 5000 orders.

select category,count(order_id)as orders
from amazon_saless
group by category
having count(order_id)>5000;

-- Advanced Questions (Subqueries)

-- Find categories whose revenue is above overall average category revenue.

select category,sum(amount) as total_revenue
from amazon_saless
group by category
having sum(amount)>(select avg(category_revenue)from
(select sum(amount) as category_revenue from amazon_saless group by category)t
);


-- Find states with revenue higher than the average state revenue.

select ship_state,sum(amount) as revenue
from amazon_saless
group by ship_state
having sum(amount)>(select avg(state_revenue) from 
(select sum(amount) as state_revenue from amazon_saless group by ship_state)t
);


-- Find orders having amount greater than average order amount.

select order_id,amount as avg_order_amt
from amazon_saless
where amount>(select avg(amount)from amazon_saless);


-- Find the category generating the highest revenue.
select category,sum(amount) as high_revenue
from amazon_saless
group by category
order by sum(amount) desc
limit 1;

-- Find the city with maximum orders.
select ship_city,count(order_id) as max_orders
from amazon_saless
where status='Shipped'
group by ship_city
order by count(order_id) desc
limit 1;


-- CTE Practice

-- Find top 5 states by revenue using CTE.
with my_cte as (
select ship_state,sum(amount) as revenue
from amazon_saless
group by ship_state
having sum(amount) is not null
order by revenue desc
limit 5
)
select ship_state,revenue    
from my_cte;


-- Find top 5 categories by quantity sold using CTE.
with my_cte as(
select category,sum(qty) as sold_qty
from amazon_saless
where status='Shipped'
group by category
order by sold_qty desc
limit 5
)
select category,sold_qty
from my_cte;

-- Calculate monthly revenue using CTE.
with my_cte as(
select Extract (Month from order_date) as mon_no,
to_char(order_date,'Month')as months,
sum(amount) as revenue
from amazon_saless
group by EXTRACT(MONTH FROM order_date),to_char(order_date,'Month')
order by mon_no
)
select months,revenue
from my_cte;

-- Find cancelled order percentage for each category using CTE.
with my_cte as(
select category,count(*) as count_cat
from amazon_saless
where status='Cancelled'
group by category
)
select my_cte.category,round(count_cat*100.0/(select count(*)from amazon_saless 
where amazon_saless.category=my_cte.category),2) as cancelled_per
from my_cte;


-- Find revenue contribution (%) of each category.

with my_cte as(
select category,sum(amount) as revenue
from amazon_saless
group by category
)
select category,round(revenue*100.0/(select sum(amount) from amazon_saless),2) 
as revenue_contribution
from my_cte
order by revenue_contribution desc;


-- Window Function Practice


-- Rank categories based on revenue.
select category,sum(amount) as revenue,
rank() over(order by sum(amount) desc) as rank_num
from amazon_saless
group by category;


-- Rank states based on revenue.
select ship_state,sum(amount) as revenue,
rank() over(order by sum(amount) desc) as rank_state
from amazon_saless
where amount is not null
group by ship_state;

-- Find top 3 cities in each state by revenue.
with my_cte as(
select ship_state,ship_city,sum(amount) as revenue,
rank() over (partition by ship_state order by sum(amount) desc) as rank_city
from amazon_saless
where amount is not null
group by ship_state,ship_city
)
select * from my_cte
where rank_city<=3;


-- Calculate running total revenue.
with monthly_revenue as(
select extract(month from order_date) as month_no,
sum(amount) as revenue
from amazon_saless
group by month_no
)
select month_no,revenue,sum(revenue) over(order by month_no) as running_total
from monthly_revenue;


-- Calculate cumulative sales by date.
with my_cte as(
select order_date,sum(amount) as daily_sale
from amazon_saless
group by order_date
)
select order_date,daily_sale,sum(daily_sale) 
over (order by order_date) as cumulative_sale  
from my_cte;


-- Find revenue difference between current and previous order using LAG().
with daily_revenue as(
select order_date,sum(amount) as revenue
from amazon_saless
group by order_date
)
select order_date,revenue,
lag(revenue) over (order by order_date) as previous_order,
revenue-lag(revenue) over (order by order_date) as sales_diff
from daily_revenue;

-- Find highest revenue category using DENSE_RANK().
with my_cte as(
select category,sum(amount) as revenue,
dense_rank() over (order by sum(amount) desc) as rankkk
from amazon_saless
group by category
)
select * from my_cte
where rankkk=1;

-- Find top-selling category in every state.
with my_cte as(
select category,ship_state,sum(qty) as quantity,
rank() over (partition by ship_state order by sum(qty) desc) as rankkk
from amazon_saless
group by category,ship_state
)
select * from my_cte
where rankkk=1;


-- Real Data Analyst Questions

-- Which category contributes the most revenue?

select category,sum(amount) as revenue
from amazon_saless
group by category
order by sum(amount) desc
limit 1;



-- Which state generates the highest sales?

select ship_state,sum(amount) as revenue
from amazon_saless
where amount is not null
group by ship_state
order by revenue desc
limit 1;




-- Which fulfillment method performs best?
select fulfilment,sum(amount) as revenue
from amazon_saless
group by fulfilment
order by revenue desc
limit 1;


-- What percentage of sales comes from B2B customers?
select b2b,round(sum(amount)*100.0/(select sum(amount) from amazon_saless),2) as sale
from amazon_saless
group by b2b
having b2b='true';

-- Which product size is most frequently sold?

SELECT size,
       COUNT(*) AS orders
FROM amazon_saless
GROUP BY size
ORDER BY orders DESC
LIMIT 1;

-- Which month generated the highest revenue?
with my_cte as(
select to_char(order_date,'Month') as months,
sum(amount) as revenue
from amazon_saless
group by  to_char(order_date,'Month')
)
select * from my_cte
order by revenue desc
limit 1;


-- What is the cancellation rate?

SELECT ROUND(
       COUNT(CASE WHEN status = 'Cancelled' THEN 1 END) * 100.0
       / COUNT(*),
       2
       ) AS cancellation_rate
FROM amazon_saless;
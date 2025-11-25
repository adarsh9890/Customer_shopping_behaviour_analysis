CREATE DATABASE customer_behavior;
use  customer_behavior;
select * from mytable limit 10;

-- What is the total revenue genrated by male customer and female customer? 
select gender,sum(purchase_amount) as revenue
from mytable
group by(gender);

-- Which customersused discount but still spent more than the average purchase amount?
select customer_id,purchase_amount
from mytable 
where discount_applied='yes' and purchase_amount>=(select avg(purchase_amount) from mytable);

-- Which are the top 5 product with highest average rating?
 select item_purchased ,avg(review_rating) as rating
 from mytable
group by(item_purchased) 
order by(rating) desc limit 5;

-- Compare the average purchase amount between standard and express shiping?
select shipping_type,avg(purchase_amount)
from mytable
where shipping_type in ('Express', 'Standard')
group by(shipping_type);

-- Do subscribed customer spend more? Compare average spend and total revenue between subscribeer and nonsubscriber.
select  subscription_status,
count(customer_id) as total_customers,
round(sum(purchase_amount),2) as total_revenue,
round(avg(purchase_amount),2) as avg_spend 
from mytable
group by(subscription_status)
order by total_revenue  desc;

-- Which 5 products have the highest percentage of purchase with discount applied?
select item_purchased,
ROUND(100*SUM(CASE WHEN discount_applied='Yes' then 1 else 0 end)/count(*),2 )as discount_rate
from mytable
group by item_purchased
order by discount_rate desc limit 5;

-- Segment customers into New,Returning, and Loyal based on their total number
-- of previous purchases, and show the count of each segment.
with customer_type as(
select customer_id , previous_purchases,
case
   when previous_purchases=1 then 'New'
   when previous_purchases between 2 and 10 then 'Returning'
   else 'Loyal'
end as customer_segment
from mytable
)
select customer_segment,count(*) as "Number of Customers"
from customer_type
group by customer_segment;

-- What are the top 3 most purchased products within each category?
WITH item_counts AS (
    SELECT 
        category,
        item_purchased,
        COUNT(customer_id) AS total_orders
    FROM mytable
    GROUP BY category, item_purchased
),
ranked_items AS (
    SELECT
        category,
        item_purchased,
        total_orders,
        ROW_NUMBER() OVER (
            PARTITION BY category 
            ORDER BY total_orders DESC
        ) AS item_rank
    FROM item_counts
)
SELECT 
    item_rank,
    category,
    item_purchased,
    total_orders
FROM ranked_items
WHERE item_rank <= 3;

-- Are customers who are repeat buyers (more than 5 previous purchases) also likely to subscribe?
select  subscription_status,
count(customer_id)
from mytable
where previous_purchases>5
group by subscription_status;

-- What is the revenue contribution of each age group?
select age_group,
sum(purchase_amount) as total_revenue
from mytable
group by age_group
order by total_revenue desc;
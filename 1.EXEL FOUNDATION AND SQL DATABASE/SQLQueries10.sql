select * from transactions

-- 1)Retrieve all transactions where the amount is greater then 700 and display them in desending order
    select *
    FROM transactions
    WHERE total_amount> 700
    ORDER BY total_amount DESC;

--2)Count total order for each product category
    select * from products
    SELECT p.category,COUNT(*) AS total_order
    FROM order_items oi
    JOIN products p ON oi.product_id= p.product_id
    GROUP BY p.category;

--3)Calculate total revenue from tranctions
   select SUM(total_amount) as total_amount 
   from transactions;

--4)Find average order value from transaction
    select AVG(total_amount) as avg_order_value
    from transactions;

--5)Calculate monthlty revenue
    select
     Month(order_date) as month,
     sum(total_amount) as monthly_revenue
     from transactions
     group by month(order_date)
     order by month;
    
--6)Display product details with order quantity
    Select
    p.product_name,
    oi.quantity
    oi,unit_price
    from order_items oi
    inner join products p
    on oi.product_id=p.product_id;

--7)Find top 5 customers based on spending
    select *
    from customers
    where customer_id in (
    select top 5 customer_id
    from transactions
    group by customer_id
    order by sum(total_amount) desc
    );

--8)Segment customers based on spending
Select
 customer_id,
 sum(total_amount) as total_spent,
 case
  when sum(total_amount) > 1000 then 'high value'
  when sum(total_amount) between 500 and 1000
  then 'medium value'
  else 'low value'
 end as customer_segment
from transactions
group by customer_id;

--9)Rank customers based on total spending
    select
     customer_id,
     sum(total_amount) as total_spent,
     row_number() over (order by
    sum(total_amount) desc) as rank_no
    from transactions
    group by customer_id;

--10 Find top selling product
select
  p.product_name,
  sum(cast (oi.quantity as int)) as total_sold
from order_items oi
join products p 
on oi.product_id = p.product_id
group by p.product_name
order by total_sold desc;
  
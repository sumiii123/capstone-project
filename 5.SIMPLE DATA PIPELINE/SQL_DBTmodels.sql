use sales_data;


--Model 1:stg_order.sql (staging) 
DROP TABLE IF EXISTS stg_orders;
SELECT
    order_id,
    customer_id,
    CAST(order_date AS DATE) AS order_date,
    total_amount AS revenue
INTO stg_orders
FROM transactions
WHERE order_id IS NOT NULL;

SELECT * FROM stg_orders;



--Model 2:int_customer_metrics.sql(intermediate)
DROP TABLE IF EXISTS int_customer_metrics;

SELECT
    customer_id,
    COUNT(order_id) AS total_orders,
    SUM(revenue) AS total_spent,
    MAX(order_date) AS last_order_date
INTO int_customer_metrics
FROM stg_orders
GROUP BY customer_id;

select* from int_customer_metrics;


--Model 2:mart_monthly_revenue.sql(mart)
DROP TABLE IF EXISTS mart_monthly_revenue;

SELECT
    FORMAT(order_date, 'yyyy-MM') AS month,
    SUM(revenue) AS monthly_revenue
INTO mart_monthly_revenue
FROM stg_orders
GROUP BY FORMAT(order_date, 'yyyy-MM');

select* from mart_monthly_revenue;




DROP TABLE IF EXISTS mart_monthly_revenue_final;

SELECT 
    a.month,
    a.monthly_revenue,
    b.monthly_revenue AS last_month_revenue,
    (a.monthly_revenue - b.monthly_revenue) AS revenue_change
INTO mart_monthly_revenue_final
FROM mart_monthly_revenue a
LEFT JOIN mart_monthly_revenue b
ON b.month = FORMAT(
    DATEADD(MONTH, -1, CAST(a.month + '-01' AS DATE)),
    'yyyy-MM'
);

select * from mart_monthly_revenue_final;


--Test 1: unique customer_id
SELECT customer_id, COUNT(*)
FROM int_customer_metrics
GROUP BY customer_id
HAVING COUNT(*) > 1;

--Test 2: Not null order_date
SELECT * FROM stg_orders
WHERE order_date IS NULL;

-- Test 2: Revenue > 0
SELECT * FROM stg_orders
WHERE revenue <= 0;
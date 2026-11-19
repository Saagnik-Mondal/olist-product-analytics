-- Q8. How many customers ever come back? Orders per unique customer.
WITH c AS (
    SELECT cu.customer_unique_id AS cust, count(*) AS n_orders
    FROM orders o
    JOIN customers cu USING (customer_id)
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY cu.customer_unique_id
)
SELECT
    CASE WHEN n_orders >= 3 THEN '3+ orders' ELSE n_orders || ' order' || CASE WHEN n_orders > 1 THEN 's' ELSE '' END END AS orders_placed,
    count(*) AS customers,
    round(100.0 * count(*) / sum(count(*)) OVER (), 2) AS pct_of_customers
FROM c
GROUP BY 1
ORDER BY 1;

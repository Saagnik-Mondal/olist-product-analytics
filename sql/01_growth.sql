-- Q1. Is the marketplace still growing?
-- Orders, GMV (item value, excluding freight) and average order value by month.
-- Only full months (Jan 2017 - Aug 2018); the data is sparse before and after.
WITH o AS (
    SELECT
        CAST(date_trunc('month', o.order_purchase_timestamp) AS DATE) AS month,
        v.item_value
    FROM orders o
    JOIN order_value v USING (order_id)
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
)
SELECT
    strftime(month, '%Y-%m') AS month,
    count(*) AS orders,
    round(sum(item_value), 0) AS gmv_brl,
    round(avg(item_value), 1) AS avg_order_value_brl
FROM o
WHERE month BETWEEN DATE '2017-01-01' AND DATE '2018-08-01'
GROUP BY month
ORDER BY month;

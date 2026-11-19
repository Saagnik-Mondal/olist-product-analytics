-- Q11. Is lateness spread evenly, or concentrated in a few sellers?
-- Sellers with at least 30 delivered orders, ranked by late rate. How much of all lateness
-- comes from the worst 10% of them?
WITH pairs AS (
    SELECT DISTINCT i.order_id, i.seller_id
    FROM items i
),
seller_stats AS (
    SELECT
        p.seller_id,
        count(*) AS orders,
        sum(CASE WHEN d.is_late THEN 1 ELSE 0 END) AS late_orders
    FROM pairs p
    JOIN delivered d USING (order_id)
    GROUP BY p.seller_id
    HAVING count(*) >= 30
),
ranked AS (
    SELECT *, late_orders * 1.0 / orders AS late_rate,
           ntile(10) OVER (ORDER BY late_orders * 1.0 / orders DESC, seller_id) AS late_decile
    FROM seller_stats
)
SELECT
    CASE WHEN late_decile = 1 THEN 'worst 10% of sellers' ELSE 'other 90% of sellers' END AS group_name,
    count(*) AS sellers,
    sum(orders) AS delivered_orders,
    sum(late_orders) AS late_orders,
    round(100.0 * sum(late_orders) / sum(orders), 1) AS late_rate_pct,
    round(100.0 * sum(orders) / sum(sum(orders)) OVER (), 1) AS share_of_orders_pct,
    round(100.0 * sum(late_orders) / sum(sum(late_orders)) OVER (), 1) AS share_of_late_orders_pct
FROM ranked
GROUP BY 1
ORDER BY 1 DESC;

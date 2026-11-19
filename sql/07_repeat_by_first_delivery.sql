-- Q7. Does a late first delivery hurt repeat purchase?
-- Share of new customers who place a second order within 180 days, by whether their first
-- order arrived on time. Only customers whose first order was placed by 2018-02-28, so every
-- customer has a full 180 days to come back (no right-censoring).
WITH ordered AS (
    SELECT
        cu.customer_unique_id AS cust,
        o.order_id,
        o.order_purchase_timestamp AS ts,
        -- order_id breaks ties when a customer has two orders at the same instant, so the
        -- result is identical on every machine.
        row_number() OVER (
            PARTITION BY cu.customer_unique_id
            ORDER BY o.order_purchase_timestamp, o.order_id
        ) AS rn
    FROM orders o
    JOIN customers cu USING (customer_id)
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
),
first_order AS (SELECT * FROM ordered WHERE rn = 1),
second_order AS (SELECT cust, ts AS second_ts FROM ordered WHERE rn = 2)
SELECT
    CASE WHEN d.is_late THEN 'first order late' ELSE 'first order on time' END AS first_delivery,
    count(*) AS new_customers,
    sum(CASE WHEN s.second_ts <= f.ts + INTERVAL 180 DAY THEN 1 ELSE 0 END) AS repeat_customers,
    round(100.0 * avg(CASE WHEN s.second_ts <= f.ts + INTERVAL 180 DAY THEN 1 ELSE 0 END), 2) AS repeat_within_180d_pct
FROM first_order f
JOIN delivered d ON d.order_id = f.order_id
LEFT JOIN second_order s USING (cust)
WHERE f.ts <= TIMESTAMP '2018-02-28'
GROUP BY d.is_late
ORDER BY d.is_late;

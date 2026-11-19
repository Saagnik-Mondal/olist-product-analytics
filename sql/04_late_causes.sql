-- Q4. Is lateness mostly a seller problem or a carrier problem?
-- A seller "misses the deadline" when the parcel reaches the carrier after the shipping
-- limit date that Olist set for that order.
WITH lim AS (
    SELECT order_id, max(shipping_limit_date) AS limit_ts
    FROM items
    GROUP BY order_id
)
SELECT
    CASE WHEN d.is_late THEN 'late' ELSE 'on time' END AS delivery,
    count(*) AS orders,
    round(100.0 * avg(CASE WHEN o.order_delivered_carrier_date > l.limit_ts THEN 1 ELSE 0 END), 1)
        AS pct_seller_missed_handoff_deadline
FROM delivered d
JOIN orders o USING (order_id)
JOIN lim l USING (order_id)
WHERE o.order_delivered_carrier_date IS NOT NULL
GROUP BY d.is_late
ORDER BY d.is_late;

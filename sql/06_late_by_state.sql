-- Q6. Where is delivery weakest? Late rate and delivery time by customer state
-- (states with at least 500 delivered orders).
SELECT
    d.state,
    count(*) AS delivered_orders,
    round(100.0 * avg(CASE WHEN d.is_late THEN 1 ELSE 0 END), 1) AS late_pct,
    round(avg(d.delivery_days), 1) AS avg_delivery_days,
    round(avg(r.review_score), 2) AS avg_review
FROM delivered d
LEFT JOIN order_review r USING (order_id)
GROUP BY d.state
HAVING count(*) >= 500
ORDER BY late_pct DESC, d.state;

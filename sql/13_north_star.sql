-- Q13. A north-star metric: the "happy order rate".
-- Happy order = delivered on or before the promised date AND rated 4 or 5 stars.
-- Tracked monthly over delivered orders that received a review (complete months only).
SELECT
    strftime(CAST(date_trunc('month', d.purchase_ts) AS DATE), '%Y-%m') AS month,
    count(*) AS reviewed_orders,
    round(100.0 * avg(CASE WHEN NOT d.is_late AND r.review_score >= 4 THEN 1 ELSE 0 END), 1) AS happy_order_pct,
    round(100.0 * avg(CASE WHEN d.is_late THEN 1 ELSE 0 END), 1) AS late_pct,
    round(avg(r.review_score), 2) AS avg_review
FROM delivered d
JOIN order_review r USING (order_id)
WHERE d.purchase_ts >= TIMESTAMP '2017-03-01' AND d.purchase_ts < TIMESTAMP '2018-08-01'
GROUP BY 1
ORDER BY 1;

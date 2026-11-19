-- Q5. How much does delivery timing move customer satisfaction?
-- Review score by how early or late the order arrived versus the promised date.
WITH b AS (
    SELECT
        CASE
            WHEN d.days_late <= -7 THEN '1) 7+ days early'
            WHEN d.days_late <= 0 THEN '2) on time (0-7 days early)'
            WHEN d.days_late <= 3 THEN '3) 1-3 days late'
            WHEN d.days_late <= 7 THEN '4) 4-7 days late'
            WHEN d.days_late <= 14 THEN '5) 8-14 days late'
            ELSE '6) 15+ days late'
        END AS delivery_vs_promise,
        r.review_score
    FROM delivered d
    JOIN order_review r USING (order_id)
)
SELECT
    delivery_vs_promise,
    count(*) AS reviewed_orders,
    round(100.0 * count(*) / sum(count(*)) OVER (), 1) AS pct_of_orders,
    round(avg(review_score), 2) AS avg_review,
    round(100.0 * avg(CASE WHEN review_score <= 2 THEN 1 ELSE 0 END), 1) AS pct_1_2_stars,
    round(100.0 * avg(CASE WHEN review_score = 5 THEN 1 ELSE 0 END), 1) AS pct_5_stars
FROM b
GROUP BY delivery_vs_promise
ORDER BY delivery_vs_promise;

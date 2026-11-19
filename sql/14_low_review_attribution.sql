-- Q14. Of all 1-2 star reviews, how many came after a late delivery?
SELECT
    count(*) AS reviewed_delivered_orders,
    sum(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END) AS low_review_orders,
    sum(CASE WHEN r.review_score <= 2 AND d.is_late THEN 1 ELSE 0 END) AS low_review_and_late,
    round(100.0 * sum(CASE WHEN r.review_score <= 2 AND d.is_late THEN 1 ELSE 0 END)
          / sum(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END), 1) AS pct_of_low_reviews_that_were_late,
    round(100.0 * avg(CASE WHEN d.is_late THEN 1 ELSE 0 END), 1) AS pct_of_all_orders_late,
    round(avg(r.review_score), 3) AS avg_review_all,
    round(avg(CASE WHEN NOT d.is_late THEN r.review_score END), 3) AS avg_review_on_time,
    round(avg(CASE WHEN d.is_late THEN r.review_score END), 3) AS avg_review_late
FROM delivered d
JOIN order_review r USING (order_id);

-- Q9. Which categories matter, and which disappoint customers?
-- Top 15 categories by GMV with satisfaction, late rate and freight burden.
SELECT
    coalesce(c.product_category_name_english, p.product_category_name, 'unknown') AS category,
    count(DISTINCT i.order_id) AS orders,
    round(sum(i.price), 0) AS gmv_brl,
    round(100.0 * sum(i.freight_value) / sum(i.price), 1) AS freight_pct_of_item_value,
    round(avg(r.review_score), 2) AS avg_review,
    round(100.0 * avg(CASE WHEN d.is_late THEN 1 ELSE 0 END), 1) AS late_pct
FROM items i
JOIN products p USING (product_id)
LEFT JOIN categories c USING (product_category_name)
LEFT JOIN order_review r USING (order_id)
LEFT JOIN delivered d USING (order_id)
GROUP BY 1
ORDER BY gmv_brl DESC, category
LIMIT 15;

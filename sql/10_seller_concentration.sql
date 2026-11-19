-- Q10. How dependent is the marketplace on a few sellers?
-- Sellers ranked by GMV and grouped into deciles.
WITH s AS (
    SELECT seller_id, sum(price) AS gmv
    FROM items
    GROUP BY seller_id
),
ranked AS (
    SELECT gmv, ntile(10) OVER (ORDER BY gmv DESC) AS decile FROM s
)
SELECT
    decile,
    count(*) AS sellers,
    round(sum(gmv), 0) AS gmv_brl,
    round(100.0 * sum(gmv) / sum(sum(gmv)) OVER (), 1) AS pct_of_gmv,
    round(100.0 * sum(sum(gmv)) OVER (ORDER BY decile) / sum(sum(gmv)) OVER (), 1) AS cumulative_pct
FROM ranked
GROUP BY decile
ORDER BY decile;

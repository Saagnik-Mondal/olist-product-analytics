-- Q2. How many orders end well? Share of orders by final status.
SELECT
    order_status,
    count(*) AS orders,
    round(100.0 * count(*) / sum(count(*)) OVER (), 2) AS pct
FROM orders
GROUP BY order_status
ORDER BY orders DESC, order_status;

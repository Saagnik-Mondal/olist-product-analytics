-- Q3. Where does the time go, and how do late orders differ?
-- Median days spent in each stage of the journey, split by on-time vs late delivery.
SELECT
    CASE WHEN d.is_late THEN 'late' ELSE 'on time' END AS delivery,
    count(*) AS orders,
    round(median((epoch(o.order_approved_at) - epoch(o.order_purchase_timestamp)) / 86400.0), 2) AS purchase_to_approval_days,
    round(median((epoch(o.order_delivered_carrier_date) - epoch(o.order_approved_at)) / 86400.0), 2) AS seller_handoff_days,
    round(median((epoch(o.order_delivered_customer_date) - epoch(o.order_delivered_carrier_date)) / 86400.0), 2) AS carrier_transit_days,
    round(median(d.delivery_days), 1) AS total_days,
    round(median(d.promised_days), 1) AS promised_days
FROM delivered d
JOIN orders o USING (order_id)
WHERE o.order_approved_at IS NOT NULL AND o.order_delivered_carrier_date IS NOT NULL
GROUP BY d.is_late
ORDER BY d.is_late;

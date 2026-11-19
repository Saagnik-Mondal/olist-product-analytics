-- Q12. How do customers pay? Payment type mix and installment use (by order's main payment).
WITH main_payment AS (
    SELECT order_id, payment_type, payment_installments, payment_value,
           row_number() OVER (PARTITION BY order_id ORDER BY payment_value DESC) AS rk
    FROM payments
    WHERE payment_type <> 'not_defined'
)
SELECT
    payment_type,
    count(*) AS orders,
    round(100.0 * count(*) / sum(count(*)) OVER (), 1) AS pct_of_orders,
    round(avg(payment_value), 1) AS avg_order_payment_brl,
    round(100.0 * avg(CASE WHEN payment_installments > 1 THEN 1 ELSE 0 END), 1) AS pct_in_installments
FROM main_payment
WHERE rk = 1
GROUP BY payment_type
ORDER BY orders DESC;

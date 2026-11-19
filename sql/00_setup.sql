-- Base tables and shared views. {DATA} is replaced with the data folder by analysis/run.py.
CREATE OR REPLACE VIEW orders AS SELECT * FROM read_csv_auto('{DATA}/olist_orders_dataset.csv');
CREATE OR REPLACE VIEW items AS SELECT * FROM read_csv_auto('{DATA}/olist_order_items_dataset.csv');
CREATE OR REPLACE VIEW payments AS SELECT * FROM read_csv_auto('{DATA}/olist_order_payments_dataset.csv');
CREATE OR REPLACE VIEW reviews AS SELECT * FROM read_csv_auto('{DATA}/olist_order_reviews_dataset.csv');
CREATE OR REPLACE VIEW customers AS SELECT * FROM read_csv_auto('{DATA}/olist_customers_dataset.csv');
CREATE OR REPLACE VIEW products AS SELECT * FROM read_csv_auto('{DATA}/olist_products_dataset.csv');
CREATE OR REPLACE VIEW sellers AS SELECT * FROM read_csv_auto('{DATA}/olist_sellers_dataset.csv');
CREATE OR REPLACE VIEW categories AS SELECT * FROM read_csv_auto('{DATA}/product_category_name_translation.csv');

-- One row per order with its item value (GMV excludes freight) and freight.
CREATE OR REPLACE VIEW order_value AS
SELECT order_id, sum(price) AS item_value, sum(freight_value) AS freight, count(*) AS n_items
FROM items
GROUP BY order_id;

-- Some orders have more than one review; use the average per order.
CREATE OR REPLACE VIEW order_review AS
SELECT order_id, avg(review_score) AS review_score
FROM reviews
GROUP BY order_id;

-- Delivered orders with delivery performance against the date promised to the customer.
CREATE OR REPLACE VIEW delivered AS
SELECT
    o.order_id,
    c.customer_unique_id,
    c.customer_state AS state,
    o.order_purchase_timestamp AS purchase_ts,
    o.order_delivered_customer_date AS delivered_ts,
    o.order_estimated_delivery_date AS promised_ts,
    (epoch(o.order_delivered_customer_date) - epoch(o.order_purchase_timestamp)) / 86400.0 AS delivery_days,
    (epoch(o.order_estimated_delivery_date) - epoch(o.order_purchase_timestamp)) / 86400.0 AS promised_days,
    (epoch(o.order_delivered_customer_date) - epoch(o.order_estimated_delivery_date)) / 86400.0 AS days_late,
    o.order_delivered_customer_date > o.order_estimated_delivery_date AS is_late
FROM orders o
JOIN customers c USING (customer_id)
WHERE o.order_status = 'delivered' AND o.order_delivered_customer_date IS NOT NULL;

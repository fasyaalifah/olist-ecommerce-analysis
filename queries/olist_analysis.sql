CREATE OR REPLACE VIEW portfolio_ecommers_olist.vw_orders_analysis AS
SELECT
  o.order_id,
  o.customer_id,
  c.customer_city,
  c.customer_state,

  -- Translation

  COALESCE(t.string_field_1, 'Others') AS product_category,

  oi.price,
  oi.freight_value,
  IFNULL(r.review_score, 0) AS review_score,
  DATE(o.order_purchase_timestamp) AS order_date,
  DATE(o.order_delivered_customer_date) AS delivered_date,

  DATE_DIFF(o.order_delivered_customer_date, o.order_purchase_timestamp, DAY) AS delivery_days,

  CASE 
    WHEN DATE_DIFF(o.order_delivered_customer_date, o.order_purchase_timestamp, DAY) <= 30 THEN 'Normal'
    ELSE 'Outlier'
  END AS delivery_category

FROM `portfolio_ecommers_olist.orders` o

JOIN `portfolio_ecommers_olist.order_items` oi 
  ON o.order_id = oi.order_id

JOIN `portfolio_ecommers_olist.products` p 
  ON oi.product_id = p.product_id

JOIN `portfolio_ecommers_olist.customers` c 
  ON o.customer_id = c.customer_id

LEFT JOIN `portfolio_ecommers_olist.product_category_name_translation` t 
  ON p.product_category_name = t.string_field_0

LEFT JOIN `portfolio_ecommers_olist.order_reviews` r 
  ON o.order_id = r.order_id

WHERE
  o.order_delivered_customer_date IS NOT NULL
  AND oi.price > 0;

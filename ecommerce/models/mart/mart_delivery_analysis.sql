{{ config(
  materialized = 'table'
) }}

WITH fct_orders AS (
  SELECT * FROM {{ ref('fct_orders') }}
),
src_reviews AS (
  SELECT * FROM {{ ref('src_reviews') }}
),
dim_customers AS (
  SELECT * FROM {{ ref('dim_customers') }}
)
SELECT
  o.order_id,
  o.customer_id,
  c.customer_state,
  o.order_purchase_timestamp,
  o.order_delivered_customer_date,
  o.order_estimated_delivery_date,
  o.delivery_days,
  o.estimated_delivery_days,
  o.delivery_delay_days,
  CASE
    WHEN o.delivery_delay_days > 0 THEN 'late'
    WHEN o.delivery_delay_days <= 0 THEN 'on_time'
    ELSE 'not_delivered'
  END AS delivery_status,
  r.review_score,
  r.review_comment_message,
  o.total_price,
  o.item_count
FROM fct_orders o
LEFT JOIN src_reviews r ON o.order_id = r.order_id
LEFT JOIN dim_customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'

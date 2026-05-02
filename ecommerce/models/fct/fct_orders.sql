{{
  config(
    materialized = 'incremental',
    on_schema_change = 'fail'
  )
}}

WITH src_orders AS (
  SELECT * FROM {{ ref('src_orders') }}
),
src_order_items AS (
  SELECT * FROM {{ ref('src_order_items') }}
),
src_payments AS (
  SELECT * FROM {{ ref('src_payments') }}
),
order_payments AS (
  SELECT
    order_id,
    SUM(payment_value) AS total_payment_value,
    COUNT(payment_sequential) AS payment_count
  FROM src_payments
  GROUP BY order_id
),
order_items_agg AS (
  SELECT
    order_id,
    COUNT(order_item_id) AS item_count,
    SUM(price) AS total_price,
    SUM(freight_value) AS total_freight,
    COUNT(DISTINCT seller_id) AS seller_count,
    COUNT(DISTINCT product_id) AS product_count
  FROM src_order_items
  GROUP BY order_id
)
SELECT
  {{ dbt_utils.generate_surrogate_key(['o.order_id']) }} AS order_key,
  o.order_id,
  o.customer_id,
  o.order_status,
  o.order_purchase_timestamp,
  o.order_approved_at,
  o.order_delivered_carrier_date,
  o.order_delivered_customer_date,
  o.order_estimated_delivery_date,
  DATEDIFF('day', o.order_purchase_timestamp, o.order_delivered_customer_date) AS delivery_days,
  DATEDIFF('day', o.order_purchase_timestamp, o.order_estimated_delivery_date) AS estimated_delivery_days,
  DATEDIFF('day', o.order_estimated_delivery_date, o.order_delivered_customer_date) AS delivery_delay_days,
  oi.item_count,
  oi.total_price,
  oi.total_freight,
  oi.seller_count,
  oi.product_count,
  op.total_payment_value,
  op.payment_count
FROM src_orders o
LEFT JOIN order_items_agg oi ON o.order_id = oi.order_id
LEFT JOIN order_payments op ON o.order_id = op.order_id
WHERE o.order_status IS NOT NULL
{% if is_incremental() %}
  {% if var("start_date", False) and var("end_date", False) %}
    {{ log('Loading ' ~ this ~ ' incrementally (start_date: ' ~ var("start_date") ~ ', end_date: ' ~ var("end_date") ~ ')', info=True) }}
    AND o.order_purchase_timestamp >= '{{ var("start_date") }}'
    AND o.order_purchase_timestamp < '{{ var("end_date") }}'
  {% else %}
    AND o.order_purchase_timestamp > (SELECT MAX(order_purchase_timestamp) FROM {{ this }})
    {{ log('Loading ' ~ this ~ ' incrementally (all missing dates)', info=True) }}
  {% endif %}
{% endif %}

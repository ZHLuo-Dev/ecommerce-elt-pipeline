SELECT * FROM {{ ref('fct_orders') }}
WHERE order_purchase_timestamp > order_delivered_customer_date
  AND order_delivered_customer_date IS NOT NULL

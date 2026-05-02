WITH raw_payments AS (
  SELECT * FROM {{ source('ecommerce', 'payments') }}
)
SELECT
  order_id,
  payment_sequential,
  payment_type,
  payment_installments,
  payment_value
FROM raw_payments

WITH raw_customers AS (
  SELECT * FROM {{ source('ecommerce', 'customers') }}
)
SELECT
  customer_id,
  customer_unique_id,
  customer_zip_code_prefix,
  customer_city,
  customer_state
FROM raw_customers

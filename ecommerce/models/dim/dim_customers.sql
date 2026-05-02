WITH src_customers AS (
  SELECT * FROM {{ ref('src_customers') }}
)
SELECT
  customer_id,
  customer_unique_id,
  customer_zip_code_prefix,
  NVL(customer_city, 'Unknown') AS customer_city,
  NVL(customer_state, 'Unknown') AS customer_state
FROM src_customers

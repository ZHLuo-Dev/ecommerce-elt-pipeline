WITH raw_sellers AS (
  SELECT * FROM {{ source('ecommerce', 'sellers') }}
)
SELECT
  seller_id,
  seller_zip_code_prefix,
  seller_city,
  seller_state
FROM raw_sellers

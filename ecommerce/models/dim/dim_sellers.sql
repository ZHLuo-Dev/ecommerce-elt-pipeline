WITH src_sellers AS (
  SELECT * FROM {{ ref('src_sellers') }}
)
SELECT
  seller_id,
  seller_zip_code_prefix,
  NVL(seller_city, 'Unknown') AS seller_city,
  NVL(seller_state, 'Unknown') AS seller_state
FROM src_sellers

WITH src_products AS (
  SELECT * FROM {{ ref('src_products') }}
),
category_translation AS (
  SELECT * FROM {{ ref('seed_category_translation') }}
)
SELECT
  p.product_id,
  NVL(ct.product_category_name_english, 'Other') AS product_category,
  p.product_name_length,
  p.product_description_length,
  p.product_photos_qty,
  p.product_weight_g,
  p.product_length_cm,
  p.product_height_cm,
  p.product_width_cm
FROM src_products p
LEFT JOIN category_translation ct
  ON p.product_category_name = ct.product_category_name

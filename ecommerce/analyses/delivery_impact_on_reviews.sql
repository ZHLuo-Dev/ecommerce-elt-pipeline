WITH delivery_reviews AS (
  SELECT * FROM {{ ref('mart_delivery_analysis') }}
)
SELECT
  delivery_status,
  COUNT(*) AS order_count,
  AVG(review_score) AS avg_review_score,
  AVG(delivery_delay_days) AS avg_delay_days
FROM delivery_reviews
WHERE review_score IS NOT NULL
GROUP BY delivery_status
ORDER BY delivery_status

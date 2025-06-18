-- Hitung RFM + ≥ 6 segmen pelanggan

WITH rfm_base AS (
  SELECT
    customer_id,
    MAX(order_date) AS last_order,
    COUNT(order_id) AS frequency,
    SUM(payment_value) AS monetary
  FROM `abstract-block-385512.transaction_dateset.transactions` 
  GROUP BY customer_id
),

max_date AS (
  SELECT MAX(order_date) AS max_order
  FROM `abstract-block-385512.transaction_dateset.transactions`
),

rfm_scored AS (
  SELECT
    b.*,
    DATE_DIFF(m.max_order, b.last_order, DAY) AS recency,
    NTILE(4) OVER (ORDER BY DATE_DIFF(m.max_order, b.last_order, DAY) ASC) AS r_score,
    NTILE(4) OVER (ORDER BY b.frequency DESC) AS f_score,
    NTILE(4) OVER (ORDER BY b.monetary DESC) AS m_score
  FROM rfm_base b
  CROSS JOIN max_date m
)

SELECT
  customer_id,
  recency,
  frequency,
  monetary,
  r_score,
  f_score,
  m_score,
  CASE
    WHEN r_score = 4 AND f_score = 4 AND m_score = 4 THEN 'Champions'
    WHEN r_score >= 3 AND f_score >= 3 AND m_score BETWEEN 2 AND 4 THEN 'Loyal Customers'
    WHEN r_score = 1 AND f_score >= 2 AND m_score >= 2 THEN 'At Risk'
    WHEN r_score = 4 AND f_score = 1 AND m_score = 1 THEN 'New Customers'
    WHEN r_score = 1 AND f_score = 1 AND m_score <= 2 THEN 'Hibernators'
    WHEN r_score = 2 AND f_score = 1 AND m_score BETWEEN 2 AND 3 THEN 'About to Sleep'
    ELSE 'Others'
  END AS segment
FROM rfm_scored;

-- Query repeat-purchase bulanan
SELECT
  EXTRACT(YEAR FROM order_date) AS year,
  EXTRACT(MONTH FROM order_date) AS month,
  COUNT(DISTINCT customer_id) AS total_customers,
  COUNT(DISTINCT CASE WHEN tx_count > 1 THEN customer_id END) AS repeat_customers
FROM (
  SELECT
    customer_id,
    order_date,
    COUNT(*) OVER (PARTITION BY customer_id, EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)) AS tx_count
  FROM abstract-block-385512.transaction_dateset.transactions
)
GROUP BY year, month
ORDER BY year, month;
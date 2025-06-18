---

# Temuan Anomali – `decoy_noise` (SQL Analytics)

Dari dataset transaksi, terdeteksi **247 anomali** berdasarkan atribut `decoy_noise`. Kriteria deteksi mencakup:

- Nilai `decoy_noise` < 0
- Nilai `decoy_noise` > (rata-rata + 3 * standar deviasi)

Pendekatan ini memanfaatkan distribusi statistik dari seluruh dataset untuk mengidentifikasi nilai ekstrem yang berpotensi mengganggu analisis lebih lanjut. Contoh anomali termasuk nilai negatif ekstrem hingga outlier positif yang sangat tinggi (misalnya > 640). Anomali ini kemungkinan mencerminkan entri sintetis atau error sistematis dari proses data.

Deteksi dini terhadap outlier semacam ini penting untuk menjaga kualitas analitik lanjutan, seperti segmentasi pelanggan dan perilaku pembelian ulang.

---

# Query Repeat - Purchase Bulanan

```sql
SELECT
  EXTRACT(YEAR FROM order_date) AS year,
  EXTRACT(MONTH FROM order_date) AS month,
  COUNT(DISTINCT customer_id) AS total_customers,
  COUNT(DISTINCT CASE WHEN tx_count > 1 THEN customer_id END) AS repeat_customers
FROM (
  SELECT
    customer_id,
    order_date,
    COUNT(*) OVER (
      PARTITION BY customer_id,
      EXTRACT(YEAR FROM order_date),
      EXTRACT(MONTH FROM order_date)
    ) AS tx_count
  FROM abstract-block-385512.transaction_dateset.transactions
)
GROUP BY year, month
ORDER BY year, month;
```
---
✏️ Penjelasan Singkat
Query ini mengevaluasi jumlah pelanggan unik dan pelanggan yang melakukan pembelian lebih dari sekali (repeat purchase) dalam periode bulanan. Dengan menghitung transaksi per pelanggan per bulan melalui window function, kita dapat mengidentifikasi pelanggan yang loyal secara waktu dan intensitas.
---
📊 Hasil Query (Singkat)
Januari 2024: 980 pelanggan, 921 repeat customers

Februari 2024: 895 pelanggan, 670 repeat customers

Maret 2024: 763 pelanggan, 440 repeat customers

April 2024: 563 pelanggan, 201 repeat customers

Mei 2024: 388 pelanggan, 92 repeat customers
---
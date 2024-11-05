-- Langkah 1: Gabungkan data dari tabel transaksi dengan informasi produk dan cabang
WITH transaksi_data AS (
    SELECT 
        t.transaction_id,
        t.date,
        t.branch_id,
        c.branch_name,
        c.kota,
        c.provinsi,
        c.rating AS rating_cabang,
        t.customer_name,
        t.product_id,
        p.product_name,
        
        -- Mengonversi price dan discount_percentage menjadi numerik
        CAST(t.price AS numeric) AS actual_price,
        CAST(t.discount_percentage AS numeric) AS discount_percentage,
        
        t.rating AS rating_transaksi,
        
        -- Menghitung nett_sales setelah diskon dengan konversi price dan discount_percentage
        CAST(t.price AS numeric) * (1 - CAST(t.discount_percentage AS numeric) / 100.0) AS nett_sales,

        -- Menentukan persentase_gross_laba berdasarkan harga
        CASE 
            WHEN CAST(t.price AS numeric) <= 50000 THEN 10
            WHEN CAST(t.price AS numeric) > 50000 AND CAST(t.price AS numeric) <= 100000 THEN 15
            WHEN CAST(t.price AS numeric) > 100000 AND CAST(t.price AS numeric) <= 300000 THEN 20
            WHEN CAST(t.price AS numeric) > 300000 AND CAST(t.price AS numeric) <= 500000 THEN 25
            ELSE 30
        END AS persentase_gross_laba,

        -- Menghitung nett_profit berdasarkan nett_sales dan persentase laba
        (CAST(t.price AS numeric) * (1 - CAST(t.discount_percentage AS numeric) / 100.0)) * 
        (CASE 
            WHEN CAST(t.price AS numeric) <= 50000 THEN 0.10
            WHEN CAST(t.price AS numeric) > 50000 AND CAST(t.price AS numeric) <= 100000 THEN 0.15
            WHEN CAST(t.price AS numeric) > 100000 AND CAST(t.price AS numeric) <= 300000 THEN 0.20
            WHEN CAST(t.price AS numeric) > 300000 AND CAST(t.price AS numeric) <= 500000 THEN 0.25
            ELSE 0.30
        END) AS nett_profit
    FROM `quixotic-elf-340705.322006.kf_final_transaction` t
    JOIN `quixotic-elf-340705.322006.kf_product` p ON t.product_id = p.product_id
    JOIN `quixotic-elf-340705.322006.kf_kantor_cabang` c ON t.branch_id = c.branch_id
)

-- Langkah 2: Buat tabel analisis akhir
SELECT 
    transaction_id,
    date,
    branch_id,
    branch_name,
    kota,
    provinsi,
    rating_cabang,
    customer_name,
    product_id,
    product_name,
    actual_price,
    discount_percentage,
    persentase_gross_laba,
    nett_sales,
    nett_profit,
    rating_transaksi
FROM transaksi_data;

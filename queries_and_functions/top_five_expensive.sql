BEGIN;
    WITH ranked_products AS (
        SELECT product_id,
               product_price,
               product_name,
               product_desc,
               row_number() over (PARTITION BY company_id ORDER BY product_price DESC) AS rn

        FROM product p
    )

    SELECT * FROM ranked_products WHERE rn <= 5;

COMMIT;
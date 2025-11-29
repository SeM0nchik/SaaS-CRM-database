BEGIN;
WITH deals_year AS (
    SELECT
        d.deal_id,
        company_id
    FROM deal d JOIN client ON d.client_id = client.client_id
    WHERE d.close_date >= date_trunc('year', current_date)
      AND d.deal_status = 'closed'
    ),
     products_agg AS (
         SELECT
             dy.company_id,
             pbd.product_id,
             SUM(pbd.count) AS total_qty
         FROM deals_year dy
                  JOIN product_by_deal pbd ON pbd.deal_id = dy.deal_id
         GROUP BY dy.company_id, pbd.product_id
     ),
     ranked_products AS (
         SELECT
             pa.company_id,
             pa.product_id,
             pa.total_qty,
             ROW_NUMBER() OVER (
                 PARTITION BY pa.company_id
                 ORDER BY pa.total_qty DESC
                 ) AS rn
         FROM products_agg pa
     )
SELECT
    rp.company_id,
    rp.product_id,
    p.product_name,
    rp.total_qty,
    rp.rn AS product_rank_in_company
FROM ranked_products rp
         JOIN product p ON p.product_id = rp.product_id
WHERE rp.rn <= 5
ORDER BY rp.company_id, rp.rn;

COMMIT;
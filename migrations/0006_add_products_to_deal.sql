BEGIN;
    INSERT INTO schema_migrations(name)
    VALUES ('add products to the deal');

    INSERT INTO product_by_deal (deal_id, product_id, count, price)
    VALUES
        (14, 1, 10, 5000),
        (14, 2, 1, 12000),
        (14, 3, 5, 1500);


    UPDATE deal d
    SET amount = sub.sum_amount
    FROM (
             SELECT deal_id,
                    SUM(price * count * 4) AS sum_amount -- наценка 400%
             FROM product_by_deal
             WHERE deal_id = 14
             GROUP BY deal_id
         ) AS sub
    WHERE d.deal_id = sub.deal_id;

COMMIT;
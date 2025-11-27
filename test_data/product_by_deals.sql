SET search_path TO saas_crm;
INSERT INTO product_by_deal (deal_id, product_id, count, price)
VALUES
    (10, 2, 1, 12000),  -- CRM Cloud Pro
    (11, 3, 1, 30000),  -- Onboarding
    (12, 1, 1, 5000),   -- CRM Cloud Basic
    (13, 4, 1, 8000),   -- Support L1
    (13, 5, 2, 15000);  -- Support L2

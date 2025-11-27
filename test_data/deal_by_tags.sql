SET search_path TO saas_crm;
INSERT INTO deal_by_tag (tag_id, deal_id)
VALUES
    (1, 10),  -- Альфа: high_priority
    (2, 11),  -- Альфа: upsell
    (3, 12),  -- Бета: trial
    (4, 13);  -- Гамма: key_client

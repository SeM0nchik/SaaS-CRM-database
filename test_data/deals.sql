SET search_path TO saas_crm;
INSERT INTO deal (client_id, manager_id, deal_name, deal_desc, amount, deal_status)
VALUES
    (5, 20, 'Внедрение CRM для Альфа', 'Продажа CRM Cloud Pro и обучения', 75000, 'active'),
    (6, 20, 'CRM для Бета',            'Продажа CRM Cloud Basic',          5000,  'new'),
    (7, 23, 'Поддержка для Гамма',     'Контракт на Support L1 и L2',      23000, 'active'),
    (8, 23, 'Аудит IT инфраструктуры', 'Разовый аудит и консультации',     15000, 'new');

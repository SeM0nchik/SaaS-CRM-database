BEGIN;
SET search_path TO saas_crm;
INSERT INTO product (company_id, product_name, product_desc, product_price)
VALUES
    (3, 'CRM Cloud Basic',  'Базовая подписка CRM',              5000),
    (3, 'CRM Cloud Pro',    'Продвинутая подписка CRM',         12000),
    (3, 'Onboarding пакет', 'Обучение и внедрение для команды', 30000),
    (4, 'Support L1',       'Поддержка первого уровня',         8000),
    (4, 'Support L2',       'Поддержка второго уровня',         15000);
COMMIT;
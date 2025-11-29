BEGIN;
    INSERT INTO schema_migrations(name)
    VALUES ('add new deal');

    INSERT INTO deal (client_id, manager_id, deal_name, deal_desc, amount)
    VALUES (
               9 ,
               23,
               'Лицензирование',
               'Поставка программных продуктов',
               0)
    RETURNING deal_id;

COMMIT;
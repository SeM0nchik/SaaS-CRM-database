BEGIN;
    INSERT INTO schema_migrations(name)
    VALUES ('add new client');

    INSERT INTO client (company_id, client_full_name, client_email, client_phone, client_post)
    VALUES (3, 'Иванов Сергей Петрович',
            's.ivanov@vector.ru', '+79635042214',
            'Руководитель отдела продаж') RETURNING client_id;

COMMIT;
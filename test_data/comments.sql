SET search_path TO saas_crm;
INSERT INTO comment (parent_comment_id, employee_id, task_id, comment_text, created_at)
VALUES
    (NULL, 19, 2, 'Проверьте, чтобы в презентации были актуальные цены.', now()),
    (1,    19, 2, 'Ок, обновлю ценник по последнему прайсу.',            now() + interval '10 minutes'),
    (NULL, 20, 3, 'Нужны доступы от клиента для настройки пользователей.', now()),
    (NULL, 23, 5, 'Сначала уточнить SLA и режимы работы.',                now());

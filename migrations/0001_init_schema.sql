BEGIN;
-- Чтобы поднять базу данных используйте данные из папки ddl проекта.
INSERT INTO schema_migrations(name)
VALUES ( 'init schema');
COMMIT;
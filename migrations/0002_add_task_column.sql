BEGIN;
--Добавим информацию о скрипте миграции
INSERT INTO schema_migrations(name)
VALUES ('add_task_timestamps');

--Добавляем время создания задачи и время ее завершения.
ALTER TABLE task ADD COLUMN created_at TIMESTAMP NOT NULL DEFAULT current_timestamp;
ALTER TABLE task ADD COLUMN completed_at TIMESTAMP;
COMMIT;
BEGIN;
--Добавим информацию о скрипте миграции
INSERT INTO schema_migrations(name)
VALUES ('add task status change triggers');

--Добавляем триггеры на изменение статуса задачи.

CREATE OR REPLACE FUNCTION change_task_status()
    RETURNS TRIGGER AS $$
BEGIN
    IF NEW.task_status = 'completed' THEN
        NEW.completed_at = current_date; -- Если выполнили задачу, то регистрируем дату выполлнения
    ELSIF NEW.task_status = 'in progress' THEN
        NEW.completed_at = NULL; -- Если по какой-то причине решили заново перевести задачу в статус исполнение, то сбрасываем время выполнения
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_change_task_status
    BEFORE INSERT OR UPDATE ON saas_crm.task
    FOR EACH ROW
EXECUTE FUNCTION change_task_status();
COMMIT;

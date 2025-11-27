SET search_path TO saas_crm;

--Проверяем, что сотрудник который прикреплен к сделке - действительно менеджер
CREATE OR REPLACE FUNCTION check_deal_manager_id()
    RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM saas_crm.employee
        WHERE employee_id = NEW.manager_id
          AND role = 'manager'
    ) THEN
        RAISE EXCEPTION 'Employee % is not a manager', NEW.manager_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_deal_manager_id
BEFORE INSERT OR UPDATE ON saas_crm.deal
FOR EACH ROW
EXECUTE FUNCTION check_deal_manager_id();

CREATE OR REPLACE FUNCTION log_client_activity()
    RETURNS TRIGGER AS $$
DECLARE
    v_user_id INT;
    v_changes TEXT = '';
BEGIN
    --Регистрирация происходит по корпоративному email.
    SELECT employee_id
    INTO v_user_id
    FROM saas_crm.employee
    WHERE employee_email = current_user
    LIMIT 1;

    IF TG_OP = 'INSERT' THEN
        INSERT INTO activity_logs (
            user_id,
            action_type,
            object_type,
            object_id,
            status,
            message
        ) VALUES (
                     v_user_id,
                     'INSERT',
                     'client',
                     NEW.client_id,
                     'Successful operation'
                         'client created'
                 );
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        IF OLD.client_full_name IS DISTINCT FROM NEW.client_full_name THEN
            v_changes := v_changes || format('client full name changed: "%s" → "%s"; ', COALESCE(OLD.client_full_name::TEXT, 'NULL'),
                                             COALESCE(NEW.client_full_name::TEXT, 'NULL'));
        END IF;

        IF OLD.client_email IS DISTINCT FROM NEW.client_email THEN
            v_changes := v_changes || format('client email changed: "%s" → "%s"; ', COALESCE(OLD.client_email::TEXT, 'NULL'),
                                             COALESCE(NEW.client_email::TEXT, 'NULL'));
        END IF;

        IF OLD.client_phone IS DISTINCT FROM NEW.client_phone THEN
            v_changes := v_changes || format('client phone changed: "%s" → "%s"; ', COALESCE(OLD.client_phone::TEXT, 'NULL'),
                                             COALESCE(NEW.client_phone::TEXT, 'NULL'));
        END IF;

        IF OLD.client_post IS DISTINCT FROM NEW.client_post THEN
            v_changes := v_changes || format('client post changed: "%s" → "%s"; ', COALESCE(OLD.client_post::TEXT, 'NULL'),
                                             COALESCE(NEW.client_post::TEXT, 'NULL'));
        END IF;



        IF v_changes = '' THEN
            RETURN NEW;
        END IF;

        INSERT INTO saas_crm.activity_logs (
            user_id,
            action_type,
            object_type,
            object_id,
            status,
            message
        ) VALUES (
                     v_user_id,
                     'UPDATE',
                     'client',
                     NEW.client_id,
                     'Successful operation',
                     v_changes
                 );

        RETURN NEW;


    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO saas_crm.activity_logs (
            user_id,
            action_type,
            object_type,
            object_id,
            status,
            message
        ) VALUES (
                     v_user_id,
                     'DELETE',
                     'client',
                     OLD.client_id,
                     'Successful operation',
                     'client deleted'
                 );
        RETURN OLD;
    END IF;

    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_log_client_activity
AFTER INSERT OR UPDATE OR DELETE on client
FOR EACH ROW
EXECUTE FUNCTION log_client_activity();


CREATE OR REPLACE FUNCTION log_employee_activity()
    RETURNS TRIGGER AS $$
DECLARE
    v_user_id INT;
    v_changes TEXT = '';
BEGIN
    --Регистрирация происходит по корпоративному email.
    SELECT employee_id
    INTO v_user_id
    FROM saas_crm.employee
    WHERE employee_email = current_user
    LIMIT 1;

    IF TG_OP = 'INSERT' THEN
        INSERT INTO activity_logs (
            user_id,
            action_type,
            object_type,
            object_id,
            status,
            message
        ) VALUES (
                     v_user_id,
                     'INSERT',
                     'employee',
                     NEW.employee_id,
                     'Successful operation'
                         'employee created'
                 );
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        IF OLD.employee_full_name IS DISTINCT FROM NEW.employee_full_name THEN
            v_changes := v_changes || format('employee full name changed: "%s" → "%s"; ', COALESCE(OLD.employee_full_name::TEXT, 'NULL'),
                                             COALESCE(NEW.employee_full_name::TEXT, 'NULL'));
        END IF;

        IF OLD.employee_email IS DISTINCT FROM NEW.employee_email THEN
            v_changes := v_changes || format('employee email changed: "%s" → "%s"; ', COALESCE(OLD.employee_email::TEXT, 'NULL'),
                                             COALESCE(NEW.employee_email::TEXT, 'NULL'));
        END IF;

        IF OLD.role IS DISTINCT FROM NEW.role THEN
            v_changes := v_changes || format('employee role changed: "%s" → "%s"; ', COALESCE(OLD.role::TEXT, 'NULL'),
                                             COALESCE(NEW.role::TEXT, 'NULL'));
        END IF;

        IF v_changes = '' THEN
            RETURN NEW;
        END IF;

        INSERT INTO saas_crm.activity_logs (
            user_id,
            action_type,
            object_type,
            object_id,
            status,
            message
        ) VALUES (
                     v_user_id,
                     'UPDATE',
                     'employee',
                     NEW.employee_id,
                     'Successful operation',
                     v_changes
                 );

        RETURN NEW;


    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO saas_crm.activity_logs (
            user_id,
            action_type,
            object_type,
            object_id,
            status,
            message
        ) VALUES (
                     v_user_id,
                     'DELETE',
                     'employee',
                     OLD.employee_id,
                     'Successful operation',
                     'employee deleted'
                 );
        RETURN OLD;
    END IF;

    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_log_employee_activity
    AFTER INSERT OR UPDATE OR DELETE on employee
    FOR EACH ROW
EXECUTE FUNCTION log_employee_activity();

-- Создадим триггер, который при закрытии сделки записываем время ее закрытия
CREATE OR REPLACE FUNCTION close_deal()
    RETURNS TRIGGER AS $$
BEGIN
    IF NEW.deal_status = 'closed' THEN
        NEW.close_date = current_date;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_close_deal
BEFORE INSERT OR UPDATE ON saas_crm.deal
FOR EACH ROW
EXECUTE FUNCTION close_deal();

--Добавляем любое действие в таблицу (журнал) логирования, чтобы можно было посмотреть всю историю

--Создадим триггер на любые действия со сделкой

CREATE OR REPLACE FUNCTION log_deal_activity()
RETURNS TRIGGER AS $$
DECLARE
    v_user_id INT;
    v_changes TEXT = '';
BEGIN
    --Регистрирация происходит по корпоративному email.
    SELECT employee_id
    INTO v_user_id
    FROM saas_crm.employee
    WHERE employee_email = current_user
    LIMIT 1;

    IF TG_OP = 'INSERT' THEN
        INSERT INTO activity_logs (
            user_id,
            action_type,
            object_type,
            object_id,
            status,
            message
        ) VALUES (
            v_user_id,
         'INSERT',
         'deal',
         NEW.deal_id,
         'Successful operation'
         'Deal created'
        );
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        IF OLD.deal_name IS DISTINCT FROM NEW.deal_name THEN
            v_changes := v_changes || format('deal_name changed: "%s" → "%s"; ', COALESCE(OLD.deal_name, 'NULL'),
                                             COALESCE(NEW.deal_name, 'NULL'));
        END IF;

        IF OLD.deal_status IS DISTINCT FROM NEW.deal_status THEN
            v_changes := v_changes || format('deal_status changed: "%s" → "%s"; ', COALESCE(OLD.deal_status::TEXT, 'NULL'),
                                             COALESCE(NEW.deal_status::TEXT, 'NULL'));
        END IF;

        IF OLD.amount IS DISTINCT FROM NEW.amount THEN
            v_changes := v_changes || format('deal amount changed: "%s" → "%s"; ', COALESCE(OLD.amount::TEXT, 'NULL'),
                                             COALESCE(NEW.amount::TEXT, 'NULL'));
        END IF;

        IF OLD.deal_desc IS DISTINCT FROM NEW.deal_desc THEN
            v_changes := v_changes || format('deal description changed: "%s" → "%s"; ', COALESCE(OLD.deal_desc, 'NULL'),
                                             COALESCE(NEW.deal_desc, 'NULL'));
        END IF;

        IF OLD.manager_id IS DISTINCT FROM NEW.manager_id THEN
            v_changes := v_changes || format('manager_id: %s → %s; ',
                                             COALESCE(OLD.manager_id::TEXT, 'NULL'),
                                             COALESCE(NEW.manager_id::TEXT, 'NULL'));
        END IF;

        IF OLD.client_id IS DISTINCT FROM NEW.client_id THEN
            v_changes := v_changes || format('client_id: %s → %s; ',
                                             COALESCE(OLD.client_id::TEXT, 'NULL'),
                                             COALESCE(NEW.client_id::TEXT, 'NULL'));
        END IF;

        IF OLD.close_date IS DISTINCT FROM NEW.close_date THEN
            v_changes := v_changes || format('close_date: %s → %s; ',
                                             COALESCE(OLD.close_date::TEXT, 'NULL'),
                                             COALESCE(NEW.close_date::TEXT, 'NULL'));
        END IF;

        IF v_changes = '' THEN
            RETURN NEW;
        END IF;

        INSERT INTO saas_crm.activity_logs (
            user_id,
            action_type,
            object_type,
            object_id,
            status,
            message
        ) VALUES (
                     v_user_id,
                     'UPDATE',
                     'deal',
                     NEW.deal_id,
                     COALESCE(NEW.deal_status::TEXT, 'N/A'),
                     v_changes
                 );

        RETURN NEW;


    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO saas_crm.activity_logs (
            user_id,
            action_type,
            object_type,
            object_id,
            status,
            message
        ) VALUES (
                     v_user_id,
                     'DELETE',
                     'deal',
                     OLD.deal_id,
                     COALESCE(OLD.deal_status::TEXT, 'N/A'),
                     'Deal deleted'
                 );
        RETURN OLD;
    END IF;

    RETURN COALESCE(NEW, OLD);
    END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trg_log_deal_changes
AFTER INSERT OR UPDATE OR DELETE ON deal
FOR EACH ROW
EXECUTE FUNCTION log_deal_activity();

--Создадим триггер на любые действия с продуктами

CREATE OR REPLACE FUNCTION log_product_activity()
    RETURNS TRIGGER AS $$
DECLARE
    v_user_id INT;
    v_changes TEXT = '';
BEGIN
    --Регистрирация происходит по корпоративному email.
    SELECT employee_id
    INTO v_user_id
    FROM saas_crm.employee
    WHERE employee_email = current_user
    LIMIT 1;

    IF TG_OP = 'INSERT' THEN
        INSERT INTO activity_logs (
            user_id,
            action_type,
            object_type,
            object_id,
            status,
            message
        ) VALUES (
                     v_user_id,
                     'INSERT',
                     'product',
                     NEW.product_id,
                     'Successful operation',
                     'Product created'
                 );
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        IF OLD.product_name IS DISTINCT FROM NEW.product_name THEN
            v_changes := v_changes || format('product name changed: "%s" → "%s"; ', COALESCE(OLD.product_name::TEXT, 'NULL'),
                                             COALESCE(NEW.product_name::TEXT, 'NULL'));
        END IF;

        IF OLD.product_desc IS DISTINCT FROM NEW.product_desc THEN
            v_changes := v_changes || format('product description changed: "%s" → "%s"; ', COALESCE(OLD.product_desc::TEXT, 'NULL'),
                                             COALESCE(NEW.product_desc::TEXT, 'NULL'));
        END IF;

        IF OLD.product_price IS DISTINCT FROM NEW.product_price THEN
            v_changes := v_changes || format('product price changed: "%s" → "%s"; ', COALESCE(OLD.product_price::TEXT, 'NULL'),
                                             COALESCE(NEW.product_price::TEXT, 'NULL'));
        END IF;


        IF v_changes = '' THEN
            RETURN NEW;
        END IF;

        INSERT INTO saas_crm.activity_logs (
            user_id,
            action_type,
            object_type,
            object_id,
            status,
            message
        ) VALUES (
                     v_user_id,
                     'UPDATE',
                     'product',
                     NEW.product_id,
                     'Successful operation',
                     v_changes
                 );

        RETURN NEW;


    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO saas_crm.activity_logs (
            user_id,
            action_type,
            object_type,
            object_id,
            status,
            message
        ) VALUES (
                     v_user_id,
                     'DELETE',
                     'product',
                     OLD.product_id,
                     'Successful operation',
                     'product deleted'
                 );
        RETURN OLD;
    END IF;

    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_log_product_changes
    AFTER INSERT OR UPDATE OR DELETE ON product
    FOR EACH ROW
EXECUTE FUNCTION log_product_activity();


--Создадим триггер на любые действия с задачами

CREATE OR REPLACE FUNCTION log_task_activity()
    RETURNS TRIGGER AS $$
DECLARE
    v_user_id INT;
    v_changes TEXT = '';
BEGIN
    --Регистрирация происходит по корпоративному email.
    SELECT employee_id
    INTO v_user_id
    FROM saas_crm.employee
    WHERE employee_email = current_user
    LIMIT 1;

    IF TG_OP = 'INSERT' THEN
        INSERT INTO activity_logs (
            user_id,
            action_type,
            object_type,
            object_id,
            status,
            message
        ) VALUES (
                     v_user_id,
                     'INSERT',
                     'task',
                     NEW.task_id,
                     'Successful operation',
                     'task created'
                 );
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        IF OLD.task_name IS DISTINCT FROM NEW.task_name THEN
            v_changes := v_changes || format('task name changed: "%s" → "%s"; ', COALESCE(OLD.task_name::TEXT, 'NULL'),
                                             COALESCE(NEW.task_name::TEXT, 'NULL'));
        END IF;

        IF OLD.task_desc IS DISTINCT FROM NEW.task_desc THEN
            v_changes := v_changes || format('task description changed: "%s" → "%s"; ', COALESCE(OLD.task_desc::TEXT, 'NULL'),
                                             COALESCE(NEW.task_desc::TEXT, 'NULL'));
        END IF;

        IF OLD.task_deadline IS DISTINCT FROM NEW.task_deadline THEN
            v_changes := v_changes || format('task deadline changed: "%s" → "%s"; ', COALESCE(OLD.task_deadline::TEXT, 'NULL'),
                                             COALESCE(NEW.task_deadline::TEXT, 'NULL'));
        END IF;

        IF OLD.task_status IS DISTINCT FROM NEW.task_status THEN
            v_changes := v_changes || format('task status changed: "%s" → "%s"; ', COALESCE(OLD.task_status::TEXT, 'NULL'),
                                             COALESCE(NEW.task_status::TEXT, 'NULL'));
        END IF;

        IF OLD.task_result IS DISTINCT FROM NEW.task_result THEN
            v_changes := v_changes || format('task result changed: "%s" → "%s"; ', COALESCE(OLD.task_result::TEXT, 'NULL'),
                                             COALESCE(NEW.task_result::TEXT, 'NULL'));
        END IF;


        IF v_changes = '' THEN
            RETURN NEW;
        END IF;

        INSERT INTO saas_crm.activity_logs (
            user_id,
            action_type,
            object_type,
            object_id,
            status,
            message
        ) VALUES (
                     v_user_id,
                     'UPDATE',
                     'task',
                     NEW.task_id,
                     'Successful operation',
                     v_changes
                 );

        RETURN NEW;


    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO saas_crm.activity_logs (
            user_id,
            action_type,
            object_type,
            object_id,
            status,
            message
        ) VALUES (
                     v_user_id,
                     'DELETE',
                     'task',
                     OLD.task_id,
                     'Successful operation',
                     'task deleted'
                 );
        RETURN OLD;
    END IF;

    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_log_task_changes
    AFTER INSERT OR UPDATE OR DELETE ON task
    FOR EACH ROW
EXECUTE FUNCTION log_task_activity();

--Создадим триггер на любые действия с комментариями

CREATE OR REPLACE FUNCTION log_comment_activity()
    RETURNS TRIGGER AS $$
DECLARE
    v_user_id INT;
    v_changes TEXT = '';
BEGIN
    --Регистрирация происходит по корпоративному email.
    SELECT employee_id
    INTO v_user_id
    FROM saas_crm.employee
    WHERE employee_email = current_user
    LIMIT 1;

    IF TG_OP = 'INSERT' THEN
        INSERT INTO activity_logs (
            user_id,
            action_type,
            object_type,
            object_id,
            status,
            message
        ) VALUES (
                     v_user_id,
                     'INSERT',
                     'comment',
                     NEW.comment_id,
                     'Successful operation',
                     'comment created'
                 );
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        IF OLD.comment_text IS DISTINCT FROM NEW.comment_text THEN
            v_changes := v_changes || format('comment text changed: "%s" → "%s"; ', COALESCE(OLD.comment_text::TEXT, 'NULL'),
                                             COALESCE(NEW.comment_text::TEXT, 'NULL'));
        END IF;

        IF v_changes = '' THEN
            RETURN NEW;
        END IF;

        INSERT INTO saas_crm.activity_logs (
            user_id,
            action_type,
            object_type,
            object_id,
            status,
            message
        ) VALUES (
                     v_user_id,
                     'UPDATE',
                     'comment',
                     NEW.comment_id,
                     'Successful operation',
                     v_changes
                 );

        RETURN NEW;


    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO saas_crm.activity_logs (
            user_id,
            action_type,
            object_type,
            object_id,
            status,
            message
        ) VALUES (
                     v_user_id,
                     'DELETE',
                     'comment',
                     OLD.comment_id,
                     'Successful operation',
                     'comment deleted'
                 );
        RETURN OLD;
    END IF;

    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_log_comment_changes
    AFTER INSERT OR UPDATE OR DELETE ON comment
    FOR EACH ROW
EXECUTE FUNCTION log_comment_activity();


--Создадим триггер на любые действия с тэгами

CREATE OR REPLACE FUNCTION log_tag_activity()
    RETURNS TRIGGER AS $$
DECLARE
    v_user_id INT;
    v_changes TEXT = '';
BEGIN
    --Регистрирация происходит по корпоративному email.
    SELECT employee_id
    INTO v_user_id
    FROM saas_crm.employee
    WHERE employee_email = current_user
    LIMIT 1;

    IF TG_OP = 'INSERT' THEN
        INSERT INTO activity_logs (
            user_id,
            action_type,
            object_type,
            object_id,
            status,
            message
        ) VALUES (
                     v_user_id,
                     'INSERT',
                     'tag',
                     NEW.tag_id,
                     'Successful operation',
                     'tag created'
                 );
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        IF OLD.tag_name IS DISTINCT FROM NEW.tag_name THEN
            v_changes := v_changes || format('tag name changed: "%s" → "%s"; ', COALESCE(OLD.tag_name::TEXT, 'NULL'),
                                             COALESCE(NEW.tag_name::TEXT, 'NULL'));
        END IF;

        IF OLD.tag_desc IS DISTINCT FROM NEW.tag_desc THEN
            v_changes := v_changes || format('tag description changed: "%s" → "%s"; ', COALESCE(OLD.tag_desc::TEXT, 'NULL'),
                                             COALESCE(NEW.tag_desc::TEXT, 'NULL'));
        END IF;

        IF v_changes = '' THEN
            RETURN NEW;
        END IF;

        INSERT INTO saas_crm.activity_logs (
            user_id,
            action_type,
            object_type,
            object_id,
            status,
            message
        ) VALUES (
                     v_user_id,
                     'UPDATE',
                     'tag',
                     NEW.tag_id,
                     'Successful operation',
                     v_changes
                 );

        RETURN NEW;


    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO saas_crm.activity_logs (
            user_id,
            action_type,
            object_type,
            object_id,
            status,
            message
        ) VALUES (
                     v_user_id,
                     'DELETE',
                     'tag',
                     OLD.tag_id,
                     'Successful operation',
                     'tag deleted'
                 );
        RETURN OLD;
    END IF;

    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_log_tag_changes
    AFTER INSERT OR UPDATE OR DELETE ON tags
    FOR EACH ROW
EXECUTE FUNCTION log_tag_activity();

--Создадим триггер на любые действия с тэгами

CREATE OR REPLACE FUNCTION log_deal_tags_activity()
    RETURNS TRIGGER AS $$
DECLARE
    v_user_id INT;
    v_changes TEXT = '';
BEGIN
    --Регистрирация происходит по корпоративному email.
    SELECT employee_id
    INTO v_user_id
    FROM saas_crm.employee
    WHERE employee_email = current_user
    LIMIT 1;

    IF TG_OP = 'INSERT' THEN
        INSERT INTO activity_logs (
            user_id,
            action_type,
            object_type,
            object_id,
            status,
            message
        ) VALUES (
                 v_user_id,
                 'INSERT',
                 'deal tags',
                 OLD.deal_id || OLD.tag_id,
                 'Successful operation',
                'deal tag inserted'
                 );
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO saas_crm.activity_logs (
            user_id,
            action_type,
            object_type,
            object_id,
            status,
            message
        ) VALUES (
                     v_user_id,
                     'DELETE',
                     'deal tags',
                     OLD.deal_id || OLD.tag_id,
                     'Successful operation',
                     'deal tag deleted'
                 );
        RETURN OLD;
    END IF;

    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_log_deal_tags_changes
    AFTER INSERT OR UPDATE OR DELETE ON deal_by_tag
    FOR EACH ROW
EXECUTE FUNCTION log_deal_tags_activity();

CREATE OR REPLACE FUNCTION saas_crm.log_product_by_deal_activity()
    RETURNS TRIGGER AS $$
DECLARE
    v_user_id INT;
    v_changes TEXT := '';
BEGIN
    -- Находим текущего сотрудника по email
    SELECT employee_id
    INTO v_user_id
    FROM saas_crm.employee
    WHERE employee_email = current_user
    LIMIT 1;

    IF TG_OP = 'INSERT' THEN
        INSERT INTO saas_crm.activity_logs (
            user_id,
            action_type,
            object_type,
            object_id,
            status,
            message
        ) VALUES (
                     v_user_id,
                     'INSERT',
                     'product_by_deal',
                     NEW.deal_id,
                     'Successful operation',
                     format(
                             'product_by_deal created: deal_id=%s, product_id=%s, count=%s, price=%s',
                             NEW.deal_id, NEW.product_id, NEW.count, NEW.price
                     )
                 );
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        IF OLD.count IS DISTINCT FROM NEW.count THEN
            v_changes := v_changes || format(
                    'count changed: %s → %s; ',
                    COALESCE(OLD.count::TEXT, 'NULL'),
                    COALESCE(NEW.count::TEXT, 'NULL')
                                      );
        END IF;

        IF OLD.price IS DISTINCT FROM NEW.price THEN
            v_changes := v_changes || format(
                    'price changed: %s → %s; ',
                    COALESCE(OLD.price::TEXT, 'NULL'),
                    COALESCE(NEW.price::TEXT, 'NULL')
                                      );
        END IF;

        IF v_changes = '' THEN
            RETURN NEW;
        END IF;

        INSERT INTO saas_crm.activity_logs (
            user_id,
            action_type,
            object_type,
            object_id,
            status,
            message
        ) VALUES (
                     v_user_id,
                     'UPDATE',
                     'product_by_deal',
                     NEW.deal_id,
                     'Successful operation',
                     v_changes
                 );
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO saas_crm.activity_logs (
            user_id,
            action_type,
            object_type,
            object_id,
            status,
            message
        ) VALUES (
                     v_user_id,
                     'DELETE',
                     'product_by_deal',
                     OLD.deal_id,
                     'Successful operation',
                     format(
                             'product_by_deal deleted: deal_id=%s, product_id=%s, count=%s, price=%s',
                             OLD.deal_id, OLD.product_id, OLD.count, OLD.price
                     )
                 );
        RETURN OLD;
    END IF;

    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_log_product_by_deal_activity
    AFTER INSERT OR UPDATE OR DELETE ON saas_crm.product_by_deal
    FOR EACH ROW
EXECUTE FUNCTION saas_crm.log_product_by_deal_activity();


CREATE OR REPLACE FUNCTION saas_crm.log_product_by_deal_activity()
    RETURNS TRIGGER AS $$
DECLARE
    v_user_id INT;
    v_message TEXT;
BEGIN
    SELECT employee_id
    INTO v_user_id
    FROM saas_crm.employee
    WHERE employee_email = current_user
    LIMIT 1;

    IF TG_OP = 'INSERT' THEN
        v_message := format(
                'product_by_deal inserted: deal_id=%s, product_id=%s, count=%s, price=%s',
                NEW.deal_id, NEW.product_id, NEW.count, NEW.price
                     );

        INSERT INTO saas_crm.activity_logs (
            user_id, action_type, object_type, object_id, status, message
        ) VALUES (
                             v_user_id,
                             'DELETE',
                             'product_by_deal',
                             OLD.deal_id,
                             'Successful operation',
                             v_message
                 );
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        v_message := format(
                'product_by_deal updated: deal_id=%s, product_id=%s, count=%s→%s, price=%s→%s',
                NEW.deal_id, NEW.product_id,
                OLD.count, NEW.count,
                OLD.price, NEW.price
                     );

        INSERT INTO saas_crm.activity_logs (
            user_id, action_type, object_type, object_id, status, message
        ) VALUES (
                             v_user_id,
                             'DELETE',
                             'product_by_deal',
                             OLD.deal_id,
                             'Successful operation',
                             v_message
                 );
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        v_message := format(
                'product_by_deal deleted: deal_id=%s, product_id=%s, count=%s, price=%s',
                OLD.deal_id, OLD.product_id, OLD.count, OLD.price
                     );

        INSERT INTO saas_crm.activity_logs (
            user_id, action_type, object_type, object_id, status, message
        ) VALUES (
                     v_user_id,
                     'DELETE',
                     'product_by_deal',
                     OLD.deal_id,
                     'Successful operation',
                     v_message
                 );
        RETURN OLD;
    END IF;

    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_log_product_by_deal_activity
    AFTER INSERT OR UPDATE OR DELETE ON saas_crm.product_by_deal
    FOR EACH ROW
EXECUTE FUNCTION saas_crm.log_product_by_deal_activity();

-- Теперь напишем триггер для защиты от изменения в комментариях - тк пользователь может изменить тело комментария, но все остальные аттрибуты он не изменит.
CREATE OR REPLACE FUNCTION saas_crm.protect_comment_fields()
    RETURNS TRIGGER AS $$
BEGIN
    -- Запрещаем менять автора комментария
    IF OLD.employee_id IS DISTINCT FROM NEW.employee_id THEN
        RAISE EXCEPTION 'Cannot change employee_id for comment %', OLD.comment_id;
    END IF;

    -- Запрещаем менять задачу, к которой привязан комментарий
    IF OLD.task_id IS DISTINCT FROM NEW.task_id THEN
        RAISE EXCEPTION 'Cannot change task_id for comment %', OLD.comment_id;
    END IF;

    -- Запрещаем менять родительский комментарий (иерархию)
    IF OLD.parent_comment_id IS DISTINCT FROM NEW.parent_comment_id THEN
        RAISE EXCEPTION 'Cannot change parent_comment_id for comment %', OLD.comment_id;
    END IF;

    -- Запрещаем менять время создания
    IF OLD.created_at IS DISTINCT FROM NEW.created_at THEN
        RAISE EXCEPTION 'Cannot change created_at for comment %', OLD.comment_id;
    END IF;

    -- comment_text менять разрешено, ничего с ним не делаем
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trg_protect_comment_fields
    BEFORE UPDATE ON saas_crm.comment
    FOR EACH ROW
EXECUTE FUNCTION saas_crm.protect_comment_fields();


-- Теперь напишем триггер для защиты от изменения в табличке tag_by_deal - не даем возможность изменить связку тэг-сделка, только удаление и создание
CREATE OR REPLACE FUNCTION saas_crm.protect_tag_by_deal_fields()
    RETURNS TRIGGER AS $$
BEGIN
    -- Запрещаем менять тэг для сделки
    IF OLD.tag_id IS DISTINCT FROM NEW.tag_id THEN
        RAISE EXCEPTION 'Cannot change tag_id for deal_by_tag %', OLD.tag_id;
    END IF;

    -- Запрещаем менять id сделки, к которой привязан тэг
    IF OLD.deal_id IS DISTINCT FROM NEW.deal_id THEN
        RAISE EXCEPTION 'Cannot change deal_id for deal_by_tag %', OLD.deal_id;
    END IF;


    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trg_protect_tag_by_deal_fields
    BEFORE UPDATE ON saas_crm.deal_by_tag
    FOR EACH ROW
EXECUTE FUNCTION saas_crm.protect_tag_by_deal_fields();

CREATE OR REPLACE FUNCTION saas_crm.protect_product_by_deal_ids()
    RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'UPDATE' THEN
        IF OLD.deal_id IS DISTINCT FROM NEW.deal_id THEN
            RAISE EXCEPTION 'Cannot change deal_id in product_by_deal (deal_id %, product_id %)',
                OLD.deal_id, OLD.product_id;
        END IF;

        IF OLD.product_id IS DISTINCT FROM NEW.product_id THEN
            RAISE EXCEPTION 'Cannot change product_id in product_by_deal (deal_id %, product_id %)',
                OLD.deal_id, OLD.product_id;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_protect_product_by_deal_ids
    BEFORE UPDATE ON saas_crm.product_by_deal
    FOR EACH ROW
EXECUTE FUNCTION saas_crm.protect_product_by_deal_ids();
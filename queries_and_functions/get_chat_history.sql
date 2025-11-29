BEGIN;

--Для ускорения работы создаем 3 B-Tree индекса, чтобы ускорить поиск сообщений в хронологическом порядке по сделке.
CREATE INDEX idx_chat_message ON chat_message(deal_id, send_at);
CREATE INDEX idx_call_logs ON call_logs(deal_id, call_at);
CREATE INDEX idx_email_message ON email_message(deal_id, send_at);

--Функция которая по id сделки выводит всю информацию о переписке и всех контактах по этой сделке
CREATE OR REPLACE FUNCTION get_chat_history(search_id INT)
RETURNS TABLE("ID" INT, "Тип" TEXT, "ID сотрудника" INT, "Информация" TEXT, "Время" TIMESTAMP) AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM deal d WHERE d.deal_id = search_id) THEN

    RETURN QUERY
    SELECT message_id as "ID",'сообщение' as "Тип" , employee_id as "ID сотрудника" ,body AS "Информация", send_at AS "Время"

    FROM deal d
    JOIN chat_message cm ON d.deal_id = cm.deal_id
    WHERE d.deal_id = search_id

    UNION ALL
    SELECT call_id as "ID",'звонок' as "Тип" , employee_id as "ID сотрудника" ,null  AS "Информация", call_at AS "Время"
    FROM deal d
    JOIN call_logs cl ON d.deal_id = cl.deal_id
    WHERE d.deal_id = search_id

    UNION ALL

    SELECT email_id as "ID",'письмо' as "Тип" , employee_id as "ID сотрудника" ,body AS "Информация", send_at AS "Время"
    FROM deal d
    JOIN email_message em ON d.deal_id = em.deal_id
    WHERE d.deal_id = search_id

    ORDER BY "Время";

    END IF;
    RETURN ;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_chat_history(10);

COMMIT;


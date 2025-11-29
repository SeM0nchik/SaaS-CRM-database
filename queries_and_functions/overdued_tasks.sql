BEGIN;
--Выводим информацию о всех просроченных задачах
SELECT task_id AS "ID задачи",
       task.employee_id AS "ID сотрудника",
       employee_full_name AS "ФИО ответственного",
       task_deadline AS "Дедлайн",
       task_deadline - now() AS "Просроченное время"
FROM task JOIN employee ON task.employee_id = employee.employee_id
WHERE task_deadline < now() AND task_status <> 'completed' AND company_id = 3
ORDER BY "Просроченное время" DESC;
END;
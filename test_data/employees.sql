SET search_path TO saas_crm;
INSERT INTO employee (company_id, employee_full_name, employee_email, role)
VALUES
    (3, 'Иван Админов',   'ivan.admin@rocketsales.ru',   'admin'),
    (3, 'Мария Менеджер', 'maria.manager@rocketsales.ru','manager'),
    (3, 'Пётр Исполнитель','petr.employee@rocketsales.ru','employee'),
    (4, 'Анна Админ',     'anna.admin@techsupport.ru',   'admin'),
    (4, 'Олег Менеджер',  'oleg.manager@techsupport.ru', 'manager'),
    (4, 'Сергей Сотрудник','sergey.employee@techsupport.ru','employee');

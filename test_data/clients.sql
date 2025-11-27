SET search_path TO saas_crm;
INSERT INTO client (company_id, client_full_name, client_email, client_phone, client_post)
VALUES
    (3, 'ООО Альфа', 'contact@alpha.ru',  '+79990001111', 'Директор по закупкам'),
    (3, 'ИП Бета',   'info@beta.ru',     '+79990002222', 'Владелец'),
    (4, 'ООО Гамма', 'sales@gamma.ru',   '+79990003333', 'Руководитель IT'),
    (4, 'ЗАО Дельта','admin@delta.ru',   '+79990004444', 'Генеральный директор');

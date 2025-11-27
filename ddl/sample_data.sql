-- Предположим, что search_path уже saas_crm
SET search_path TO saas_crm;

-- 1. Компании
INSERT INTO company (company_name, company_desc)
VALUES
    ('RocketSales', 'B2B SaaS sales company'),
    ('TechSupportPro', 'IT outsourcing and support');

-- 2. Сотрудники (admin / manager / employee)
INSERT INTO employee (company_id, employee_full_name, employee_email, role)
VALUES
    (3, 'Иван Админов',   'ivan.admin@rocketsales.ru',   'admin'),
    (3, 'Мария Менеджер', 'maria.manager@rocketsales.ru','manager'),
    (3, 'Пётр Исполнитель','petr.employee@rocketsales.ru','employee'),
    (4, 'Анна Админ',     'anna.admin@techsupport.ru',   'admin'),
    (4, 'Олег Менеджер',  'oleg.manager@techsupport.ru', 'manager'),
    (4, 'Сергей Сотрудник','sergey.employee@techsupport.ru','employee');

-- 3. Клиенты
INSERT INTO client (company_id, client_full_name, client_email, client_phone, client_post)
VALUES
    (3, 'ООО Альфа', 'contact@alpha.ru',  '+79990001111', 'Директор по закупкам'),
    (3, 'ИП Бета',   'info@beta.ru',     '+79990002222', 'Владелец'),
    (4, 'ООО Гамма', 'sales@gamma.ru',   '+79990003333', 'Руководитель IT'),
    (4, 'ЗАО Дельта','admin@delta.ru',   '+79990004444', 'Генеральный директор');

-- 4. Товары (product)
INSERT INTO product (company_id, product_name, product_desc, product_price)
VALUES
    (3, 'CRM Cloud Basic',  'Базовая подписка CRM',              5000),
    (3, 'CRM Cloud Pro',    'Продвинутая подписка CRM',         12000),
    (3, 'Onboarding пакет', 'Обучение и внедрение для команды', 30000),
    (4, 'Support L1',       'Поддержка первого уровня',         8000),
    (4, 'Support L2',       'Поддержка второго уровня',         15000);

-- 5. Сделки (deal)
-- company 3: менеджер Мария (id=2), клиенты 1 и 2
-- company 4: менеджер Олег (id=5), клиенты 3 и 4
INSERT INTO deal (client_id, manager_id, deal_name, deal_desc, amount, deal_status)
VALUES
    (5, 20, 'Внедрение CRM для Альфа', 'Продажа CRM Cloud Pro и обучения', 75000, 'active'),
    (6, 20, 'CRM для Бета',            'Продажа CRM Cloud Basic',          5000,  'new'),
    (7, 23, 'Поддержка для Гамма',     'Контракт на Support L1 и L2',      23000, 'active'),
    (8, 23, 'Аудит IT инфраструктуры', 'Разовый аудит и консультации',     15000, 'new');

-- 6. Тэги
INSERT INTO tags (tag_name, tag_desc)
VALUES
    ('high_priority', 'Высокий приоритет'),
    ('upsell',        'Потенциал допродаж'),
    ('trial',         'Тестовый период'),
    ('key_client',    'Ключевой клиент');

-- 7. Связь сделки и тега (deal_by_tag)
INSERT INTO deal_by_tag (tag_id, deal_id)
VALUES
    (1, 10),  -- Альфа: high_priority
    (2, 11),  -- Альфа: upsell
    (3, 12),  -- Бета: trial
    (4, 13);  -- Гамма: key_client

-- 8. Привязка товаров к сделкам (product_by_deal)
-- Фиксируем цену в сделке
INSERT INTO product_by_deal (deal_id, product_id, count, price)
VALUES
    (10, 2, 1, 12000),  -- CRM Cloud Pro
    (11, 3, 1, 30000),  -- Onboarding
    (12, 1, 1, 5000),   -- CRM Cloud Basic
    (13, 4, 1, 8000),   -- Support L1
    (13, 5, 2, 15000);  -- Support L2

-- 9. Задачи (task)
INSERT INTO task (deal_id, employee_id,task_name ,task_desc, task_deadline, task_status, task_result)
VALUES
    (10, 19, 'Подготовить презентацию для Альфа', 'Подготовить презентацию по функционалу CRM для компании Альфа: включить описание воронок продаж, отчётов, ролей пользователей и пример дашборда для руководства.' ,now() + interval '3 days', 'in progress', NULL),
    (11, 19, 'Настроить аккаунты пользователей','Создать аккаунты пользователей для команды клиента, назначить бизнес-роли (администратор, менеджер, сотрудник), выдать стартовые пароли и проверить вход в систему.' ,   now() + interval '5 days', 'new',        NULL),
    (12, 19, 'Созвон с ИП Бета по требованиям', 'Провести созвон с клиентом ИП Бета, уточнить бизнес-процессы, этапы сделки, необходимые поля в карточке клиента и отчёты, которые будут использоваться.' ,    now() + interval '2 days', 'new',        NULL),
    (13, 24, 'Настроить мониторинг для Гамма',  'Настроить мониторинг обращений и инцидентов для компании Гамма: настроить интеграцию с каналами связи, задать SLA и уведомления для критичных тикетов.' ,   now() + interval '4 days', 'in progress',NULL),
    (13, 24, 'Сбор информации по инфраструктуре',  'Собрать информацию по текущей IT-инфраструктуре клиента: список серверов и сервисов, используемые системы учёта, каналы связи с клиентами и существующие регламенты.' , now() + interval '7 days', 'new',        NULL);

-- 10. Комментарии к задачам (comment)
INSERT INTO comment (parent_comment_id, employee_id, task_id, comment_text, created_at)
VALUES
    (NULL, 19, 2, 'Проверьте, чтобы в презентации были актуальные цены.', now()),
    (1,    19, 2, 'Ок, обновлю ценник по последнему прайсу.',            now() + interval '10 minutes'),
    (NULL, 20, 3, 'Нужны доступы от клиента для настройки пользователей.', now()),
    (NULL, 23, 5, 'Сначала уточнить SLA и режимы работы.',                now());

-- 11. Сообщения в чатах (chat_message)
INSERT INTO chat_message (deal_id, employee_id, direction, channel, body, send_at)
VALUES
    (10, 19, 'outgoing', 'telegram', 'Здравствуйте, отправил вам презентацию по CRM.', now()),
    (10, 20, 'incoming', 'telegram', 'Спасибо, посмотрю сегодня вечером.', now() + interval '30 minutes'),
    (12, 23, 'outgoing', 'whatsapp', 'Прислали обновлённый договор по поддержке.', now());

-- 12. Почтовые сообщения (email_message)
INSERT INTO email_message (deal_id, employee_id, direction, subject, body, send_at)
VALUES
    (10, 20, 'outgoing', 'Коммерческое предложение по CRM', 'Прикладываю КП и спецификацию.', now()),
    (11, 20, 'outgoing', 'Подтверждение встречи',            'Подтверждаю встречу на завтра в 11:00.', now()),
    (12, 23, 'incoming', 'Вопрос по уровню поддержки',       'Нужны разъяснения по времени реакции.',  now());

-- 13. Логи звонков (call_logs)
INSERT INTO call_logs (deal_id, employee_id, direction, phone, duration, call_at)
VALUES
    (10, 20, 'outgoing', '+79990001111', 600, now() - interval '1 day'),
    (11, 20, 'incoming', '+79990002222', 300, now() - interval '2 hours'),
    (12, 23, 'outgoing', '+79990003333', 900, now() - interval '3 hours');

-- 14. Отзывы клиентов (client_review)
INSERT INTO client_review (deal_id, rating, message)
VALUES
    (10, 4.5, 'Система удобная, но нужно ещё доработать отчёты.'),
    (12, 5.0, 'Отличная поддержка, быстро реагируют на запросы.');


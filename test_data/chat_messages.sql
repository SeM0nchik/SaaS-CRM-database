BEGIN;
SET search_path TO saas_crm;
INSERT INTO chat_message (deal_id, employee_id, direction, channel, body, send_at)
VALUES
    (10, 19, 'outgoing', 'telegram', 'Здравствуйте, отправил вам презентацию по CRM.', now()),
    (10, 20, 'incoming', 'telegram', 'Спасибо, посмотрю сегодня вечером.', now() + interval '30 minutes'),
    (12, 23, 'outgoing', 'whatsapp', 'Прислали обновлённый договор по поддержке.', now());
COMMIT;
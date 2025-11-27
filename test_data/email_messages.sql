SET search_path TO saas_crm;
INSERT INTO email_message (deal_id, employee_id, direction, subject, body, send_at)
VALUES
    (10, 20, 'outgoing', 'Коммерческое предложение по CRM', 'Прикладываю КП и спецификацию.', now()),
    (11, 20, 'outgoing', 'Подтверждение встречи',            'Подтверждаю встречу на завтра в 11:00.', now()),
    (12, 23, 'incoming', 'Вопрос по уровню поддержки',       'Нужны разъяснения по времени реакции.',  now());

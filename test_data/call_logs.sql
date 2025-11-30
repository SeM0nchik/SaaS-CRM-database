BEGIN;
SET search_path TO saas_crm;
INSERT INTO call_logs (deal_id, employee_id, direction, phone, duration, call_at)
VALUES
    (10, 20, 'outgoing', '+79990001111', 600, now() - interval '1 day'),
    (11, 20, 'incoming', '+79990002222', 300, now() - interval '2 hours'),
    (12, 23, 'outgoing', '+79990003333', 900, now() - interval '3 hours');
COMMIT;
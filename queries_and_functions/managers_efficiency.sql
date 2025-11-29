BEGIN;


SELECT
    d.manager_id,
    COUNT(*) FILTER (WHERE d.creation_date > current_date - INTERVAL '30 day') AS created_last_30d,
    COUNT(*) FILTER (WHERE d.close_date > current_date - INTERVAL '30 day') AS closed_last_30d,
    SUM(d.amount) FILTER (WHERE d.close_date > current_date - INTERVAL '30 day') AS closed_amount_30d,
    ROUND(AVG(cr.rating) FILTER (WHERE d.close_date > current_date - INTERVAL '30 day'), 2) AS avg_rating_30d,
    AVG(d.close_date - d.creation_date) FILTER (WHERE d.close_date > current_date - INTERVAL '30 day') AS avg_lifetime_30d
FROM deal d
         INNER JOIN client c ON d.client_id = c.client_id
         LEFT JOIN client_review cr ON d.deal_id = cr.deal_id
WHERE c.company_id = 3
  AND (d.close_date    > current_date - INTERVAL '30 day' OR d.creation_date > current_date - INTERVAL '30 day' )
GROUP BY d.manager_id;

COMMIT;

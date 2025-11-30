BEGIN;
SET search_path TO saas_crm;
INSERT INTO company (company_name, company_desc)
VALUES
    ('RocketSales', 'B2B SaaS sales company'),
    ('TechSupportPro', 'IT outsourcing and support');
COMMIT;
SET search_path TO saas_crm;

CREATE TABLE IF NOT EXISTS schema_migrations (
    version    INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name       TEXT NOT NULL,
    applied_at TIMESTAMP NOT NULL DEFAULT now()
);


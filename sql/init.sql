-- Create Users
CREATE USER langflow WITH PASSWORD 'langflow';
CREATE USER vault WITH PASSWORD 'vault';

-- Create Databases
CREATE DATABASE langflow;
CREATE DATABASE vault;

-- Assign Ownership and Permissions for Langflow
ALTER DATABASE langflow OWNER TO langflow;
GRANT ALL PRIVILEGES ON DATABASE langflow TO langflow;

-- Assign Ownership and Permissions for Vault
ALTER DATABASE vault OWNER TO vault;
GRANT ALL PRIVILEGES ON DATABASE vault TO vault;

-- Ensure users can create schemas within their own DBs
\c langflow
GRANT ALL ON SCHEMA public TO langflow;

\c vault
GRANT ALL ON SCHEMA public TO vault;

\c vault vault

CREATE TABLE public.audit (
    id UUID PRIMARY KEY,
    ingested_at TIMESTAMP WITH TIME ZONE,
    payload JSONB
);

CREATE INDEX idx_vault_type ON public.audit ((payload->>'type'));

CREATE INDEX idx_vault_display_name ON public.audit ((payload->'auth'->>'display_name'));

CREATE INDEX idx_vault_path ON public.audit ((payload->'request'->>'path'));
CREATE INDEX idx_vault_operation ON public.audit ((payload->'request'->>'operation'));
CREATE INDEX idx_vault_mount_type ON public.audit ((payload->'request'->>'mount_type'));
CREATE INDEX idx_vault_mount_point ON public.audit ((payload->'request'->>'mount_point'));
CREATE INDEX idx_vault_mount_class ON public.audit ((payload->'request'->>'mount_class'));
CREATE INDEX idx_vault_remote_address ON public.audit ((payload->'request'->>'remote_address'));

CREATE INDEX idx_vault_payload_search ON public.audit USING GIN (payload);

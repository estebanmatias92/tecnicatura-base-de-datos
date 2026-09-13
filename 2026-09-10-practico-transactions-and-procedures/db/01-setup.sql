-- C1: Configuración — DB bibliotech + usuario bibliotech_user
-- Ejecutar como superusuario (postgres) contra DB postgres.
-- Idempotente: usa bloques DO con chequeo de existencia.

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'bibliotech_user') THEN
        CREATE ROLE bibliotech_user WITH LOGIN PASSWORD 'bibliotech_pass';
    ELSE
        ALTER ROLE bibliotech_user WITH LOGIN PASSWORD 'bibliotech_pass';
    END IF;
END $$;

SELECT 'CREATE DATABASE bibliotech OWNER bibliotech_user'
WHERE NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = 'bibliotech')\gexec

GRANT ALL PRIVILEGES ON DATABASE bibliotech TO bibliotech_user;

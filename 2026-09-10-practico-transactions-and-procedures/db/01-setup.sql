-- C1: Configuración — DB bibliotech + usuario bibliotech_user
-- Qué: crea el ROLE bibliotech_user y la DATABASE bibliotech (dueño: bibliotech_user).
-- Cómo se ejecuta: como superusuario (postgres) contra la DB postgres, vía `make setup`.
--   El Makefile reemplaza 'bibliotech_pass' por la clave real de .env (APP_USER_PASSWORD)
--   antes de enviar este archivo a psql, así la clave no queda hardcodeada en el repo.
-- Idempotente: se puede re-ejecutar; si el rol o la DB ya existen, los deja como están
--   (y refresca la clave del rol).
-- Nota junior: `\gexec` NO es SQL, es un meta-comando de psql: toma el texto que
--   devuelve el SELECT anterior (un 'CREATE DATABASE ...') y lo ejecuta como si
--   lo hubieras escrito a mano. Se usa porque `CREATE DATABASE` no admite `IF NOT EXISTS`
--   con `WHERE` de la forma habitual; este truco lo emula.

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

-- Ej.1: Base de datos, usuario y permisos (DCL) — patientsdb
-- Qué: crea el ROLE patients_user y la DATABASE patientsdb (dueña: patients_user).
-- Cómo se ejecuta: como superusuario (postgres) contra la DB postgres, vía `make setup`.
--   El Makefile reemplaza 'patients_pass' por la clave real de .env (APP_USER_PASSWORD)
--   antes de enviar este archivo a psql, así la clave no queda hardcodeada en el repo.
--   La clave de la consigna es 'Patients123!' (ver .env.example).
-- Idempotente: re-ejecutable; si el rol o la DB ya existen los deja como están
--   (y refresca la clave del rol).
-- Nota MySQL↔Postgres (ver docs/ER.md §3): la consigna pide
--   `CREATE DATABASE patientsdb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci`
--   + `CREATE USER 'patients_user'@'localhost'` + `GRANT ALL PRIVILEGES ON patientsdb.*`.
--   En Postgres no hay host en el rol ni charset por DB de ese tipo: equivale a
--   `ENCODING 'UTF8'` (default) + `CREATE ROLE ... WITH LOGIN` + `GRANT ALL PRIVILEGES
--   ON DATABASE` (el acceso al schema se otorga en el target `setup` del Makefile).
-- Nota: `\gexec` NO es SQL, es un meta-comando de psql: toma el texto que devuelve
--   el SELECT anterior (un 'CREATE DATABASE ...') y lo ejecuta como si lo hubieras
--   escrito a mano. Se usa porque `CREATE DATABASE` no admite `IF NOT EXISTS`
--   con `WHERE` de la forma habitual; este truco lo emula.
-- Glosario: docs/GLOSSARY.md (CREATE ROLE, CREATE DATABASE, GRANT, DO, \gexec).

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'patients_user') THEN
        CREATE ROLE patients_user WITH LOGIN PASSWORD 'patients_pass';
    ELSE
        ALTER ROLE patients_user WITH LOGIN PASSWORD 'patients_pass';
    END IF;
END $$;

SELECT 'CREATE DATABASE patientsdb OWNER patients_user'
WHERE NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = 'patientsdb')\gexec

GRANT ALL PRIVILEGES ON DATABASE patientsdb TO patients_user;

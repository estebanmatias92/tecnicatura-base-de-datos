-- Ej.2: Crear la tabla patients (DDL)
-- Qué: crea la única tabla del modelo (sin FKs) con las columnas y restricciones
--   de la consigna.
-- Cómo se ejecuta: como patients_user contra la DB patientsdb, vía `make schema`.
-- Idempotente: `IF NOT EXISTS`, re-ejecutable sin errores.
-- Mapeo MySQL→Postgres (ver docs/ER.md §3):
--   - `INT AUTO_INCREMENT PRIMARY KEY` → `INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY`
--     (sucesor estándar SQL de SERIAL; el motor genera el valor).
--   - `VARCHAR(n)`, `DATE`, `UNIQUE`, `NOT NULL` son iguales en ambos motores.
--   - `phone UNIQUE NULL`: unicidad solo cuando hay valor; múltiples NULL permitidos
--     (semántica estándar; la consigna lo declara NULLABLE).
--   - `email` sin UNIQUE: la consigna no lo exige y no se asume constraint de más.
--   - La edad NO se almacena: es un atributo derivado de `birth_date` (ver 04-queries.sql).
-- Glosario: docs/GLOSSARY.md (IDENTITY, PRIMARY KEY, UNIQUE, NOT NULL, VARCHAR, DATE).

CREATE TABLE IF NOT EXISTS patients (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date DATE NOT NULL,
    phone VARCHAR(15) UNIQUE NULL,
    email VARCHAR(100) NULL
);

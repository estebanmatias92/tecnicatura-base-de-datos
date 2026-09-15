-- Ej.4: Consultas SELECT (DQL) — 4 requerimientos
-- Qué: las 4 consultas de la consigna, solo lectura (seguras en cualquier punto
--   de la cadena; `make queries` las corre contra el estado actual).
-- Cómo se ejecuta: como patients_user contra patientsdb, vía `make queries`.
-- Nota MySQL→Postgres (ver docs/ER.md §2 y docs/GLOSSARY.md):
--   - `CONCAT(a, ' ', b)` existe en ambos motores (aquí: nombre completo).
--   - Edad: MySQL `TIMESTAMPDIFF(YEAR, birth_date, CURDATE())` ↔ Postgres
--     `EXTRACT(YEAR FROM AGE(CURRENT_DATE, birth_date))::INT`.
--     `AGE()` devuelve un intervalo; `EXTRACT(YEAR ...)` toma los años cumplidos.
-- Glosario: docs/GLOSSARY.md (SELECT, CONCAT, AGE, EXTRACT, CURRENT_DATE, INTERVAL, WHERE).

-- 4.1: totalidad de registros y campos.
SELECT * FROM patients;

-- 4.2: nombre completo + edad calculada en años de cada paciente.
SELECT
    CONCAT(first_name, ' ', last_name) AS full_name,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, birth_date))::INT AS age
FROM patients;

-- 4.3: pacientes con edad estrictamente mayor a 30 años.
SELECT
    CONCAT(first_name, ' ', last_name) AS full_name,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, birth_date))::INT AS age
FROM patients
WHERE EXTRACT(YEAR FROM AGE(CURRENT_DATE, birth_date)) > 30;
-- Alternativa equivalente y sargable (puede usar índice sobre birth_date),
-- comparando la fecha directamente como sugiere la consigna:
-- SELECT CONCAT(first_name, ' ', last_name) AS full_name
-- FROM patients
-- WHERE birth_date < CURRENT_DATE - INTERVAL '30 years';

-- 4.4: datos del paciente cuyo teléfono es '123456789'.
SELECT * FROM patients WHERE phone = '123456789';

-- Ej.3: Insertar datos (DML — INSERT)
-- Qué: inserta los 3 pacientes de la consigna con lista explícita de columnas
--   destino y fechas en formato ISO (YYYY-MM-DD).
-- Cómo se ejecuta: como patients_user contra patientsdb, vía `make seed`.
-- Idempotente: `ON CONFLICT DO NOTHING` saltea las filas que violen una restricción
--   única (aquí: `phone`) en vez de fallar; re-ejecutable sin duplicar.
-- Datos (estado inicial; Ej.5 y Ej.6 lo mutan después):
--   - John Doe, '1995-05-15', '123456789', 'john.doe@email.com' (Ej.5 le cambia la fecha a '1994-05-15').
--   - Jane Smith, '1998-08-20', '987654321', 'jane.smith@email.com'.
--   - Mike Brown, '1985-12-10', '555123456', NULL (Ej.6 lo borra; el NULL va sin comillas).
-- Glosario: docs/GLOSSARY.md (INSERT, ON CONFLICT DO NOTHING, DATE ISO, NULL).

INSERT INTO patients (first_name, last_name, birth_date, phone, email) VALUES
    ('John', 'Doe', '1995-05-15', '123456789', 'john.doe@email.com'),
    ('Jane', 'Smith', '1998-08-20', '987654321', 'jane.smith@email.com'),
    ('Mike', 'Brown', '1985-12-10', '555123456', NULL)
ON CONFLICT DO NOTHING;

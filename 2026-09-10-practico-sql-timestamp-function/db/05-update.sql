-- Ej.5: Actualización de datos (DML — UPDATE)
-- Qué: cambia la fecha de nacimiento de John Doe a '1994-05-15', localizándolo
--   por su clave primaria tal como exige la consigna.
-- Cómo se ejecuta: como patients_user contra patientsdb, vía `make update`.
--   El `id` no se hardcodea (sería frágil si el seed se recarga): se resuelve con
--   un subselect por nombre+apellido, y el UPDATE filtra por esa PK.
-- Re-ejecutable: correrlo dos veces deja el mismo valor (segunda vez actualiza
--   1 fila al mismo dato o 0 si ya está, sin error).
-- Para inspeccionar antes: SELECT id FROM patients WHERE first_name = 'John' AND last_name = 'Doe';
-- Glosario: docs/GLOSSARY.md (UPDATE, WHERE, subselect).

UPDATE patients
SET birth_date = '1994-05-15'
WHERE id = (SELECT id FROM patients WHERE first_name = 'John' AND last_name = 'Doe');

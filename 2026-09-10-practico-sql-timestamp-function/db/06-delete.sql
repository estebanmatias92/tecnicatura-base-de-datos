-- Ej.6: Eliminación de datos (DML — DELETE)
-- Qué: elimina el registro de Mike Brown, localizándolo por su clave primaria
--   tal como exige la consigna.
-- Cómo se ejecuta: como patients_user contra patientsdb, vía `make delete`.
--   Igual que en 05-update.sql, el `id` se resuelve con subselect (no hardcodeado).
-- Re-ejecutable: la segunda corrida borra 0 filas sin error.
-- Destructivo: después de este paso quedan 2 filas (99-verify.sql lo comprueba).
--   `ON CONFLICT DO NOTHING` del seed mira el teléfono: como el de Mike ya no
--   existe, re-correr `make seed` lo resucita (3 filas). Eso no rompe la cadena:
--   `make all` siempre corre delete después de seed y termina en 2 filas.
--   Para partir de cero absoluto: `make reset && make all`.
-- Para inspeccionar antes: SELECT id FROM patients WHERE first_name = 'Mike' AND last_name = 'Brown';
-- Glosario: docs/GLOSSARY.md (DELETE, WHERE, subselect).

DELETE FROM patients
WHERE id = (SELECT id FROM patients WHERE first_name = 'Mike' AND last_name = 'Brown');

-- Ejercicio 5: Actualizar Datos
SELECT 'Estado de John Doe ANTES del UPDATE' AS Info;
SELECT * FROM Patients WHERE first_name = 'John' AND last_name = 'Doe';

-- Actualiza la edad de "John Doe" a 31 años.
UPDATE Patients SET age = 31 WHERE first_name = 'John' AND last_name = 'Doe';

SELECT 'Estado de John Doe DESPUÉS del UPDATE' AS Info;
SELECT * FROM Patients WHERE first_name = 'John' AND last_name = 'Doe';


-- Ejercicio 6: Eliminar Datos
SELECT 'Estado de Mike Brown ANTES del DELETE' AS Info;
SELECT * FROM Patients WHERE first_name = 'Mike' AND last_name = 'Brown';

-- Elimina el paciente "Mike Brown" de la tabla.
DELETE FROM Patients WHERE first_name = 'Mike' AND last_name = 'Brown';

SELECT 'Tabla Patients FINAL' AS Info;
SELECT * FROM Patients;
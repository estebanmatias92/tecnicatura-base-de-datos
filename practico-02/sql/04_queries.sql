-- Ejercicio 4: Consultas SELECT (DQL)

-- 1. Obtener todos los pacientes.
SELECT '1. Todos los pacientes' AS Consulta;
SELECT * FROM Patients;

-- 2. Obtener solo nombres y edades.
SELECT '2. Nombres y edades' AS Consulta;
SELECT first_name, last_name, age FROM Patients;

-- 3. Filtrar pacientes mayores de 30 años.
SELECT '3. Pacientes mayores de 30' AS Consulta;
SELECT * FROM Patients WHERE age > 30;

-- 4. Buscar un paciente por teléfono.
-- Se asume una búsqueda arbitraria basándose en los datos insertados en el Ejercicio 3.
SELECT '4. Buscar por teléfono (ej: 123456789)' AS Consulta;
SELECT * FROM Patients WHERE phone = '123456789';
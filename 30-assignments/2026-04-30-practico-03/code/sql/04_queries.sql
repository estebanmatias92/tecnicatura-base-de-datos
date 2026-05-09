USE medical_clinic_db;

-- 4.a Obtener todos los pacientes
SELECT * FROM Patients;

-- 4.b Obtener todos los médicos y sus especialidades
SELECT name, specialty FROM Doctors;

-- 4.c Listar las citas médicas programadas
SELECT * FROM Appointments WHERE status = 'Scheduled';

-- 4.d Obtener los tratamientos de un paciente específico por id y por nombre
-- Variante 1: Filtrado directo por id (Foreign Key)
SELECT * FROM Treatments 
WHERE patient_id = 1;

-- Variante 2: Filtrado por nombre (requiere composición relacional)
SELECT t.id, t.diagnosis, t.prescription, t.treatment_date, p.name as patient_name
FROM Treatments t
INNER JOIN Patients p ON t.patient_id = p.id
WHERE p.name = 'Juan Pérez';
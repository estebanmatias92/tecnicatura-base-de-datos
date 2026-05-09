USE medical_clinic_db;

-- 3.a Insertar pacientes
INSERT INTO Patients (name, birthdate, gender, phone, email) VALUES
('Juan Pérez', '1990-05-10', 'Male', '123456789', 'juan.perez@mail.com'),
('María López', '1985-08-25', 'Female', '987654321', 'maria.lopez@mail.com');

-- 3.b Insertar médicos
INSERT INTO Doctors (name, specialty, phone, email) VALUES
('Dr. Carlos Gómez', 'Cardiología', '111222333', 'carlos.gomez@clinic.com'),
('Dra. Ana Torres', 'Dermatología', '444555666', 'ana.torres@clinic.com');

-- 3.c Insertar citas médicas
INSERT INTO Appointments (patient_id, doctor_id, appointment_date, status) VALUES
(1, 1, '2025-03-01 10:00:00', 'Scheduled'),
(2, 2, '2025-03-02 14:30:00', 'Scheduled');

-- 3.d Insertar tratamientos
INSERT INTO Treatments (patient_id, doctor_id, diagnosis, prescription) VALUES
(1, 1, 'Hipertensión', 'Losartán 50mg cada 12 horas'),
(2, 2, 'Acné severo', 'Crema dermatológica recetada');
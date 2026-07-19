-- Ejercicio 3: Insertar Datos
INSERT INTO Patients (first_name, last_name, age, phone, email) VALUES
('John', 'Doe', 30, '123456789', 'john.doe@email.com'),
('Jane', 'Smith', 28, '987654321', 'jane.smith@email.com'),
('Mike', 'Brown', 40, '555123456', NULL);

SELECT '--- Tabla poblada con éxito ---' AS Estado;
SELECT * FROM Patients;
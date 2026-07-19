-- Ejercicio 2: Crear una Tabla
CREATE TABLE IF NOT EXISTS Patients (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    age INT NOT NULL,
    phone VARCHAR(15) UNIQUE,
    email VARCHAR(100) NULL
);
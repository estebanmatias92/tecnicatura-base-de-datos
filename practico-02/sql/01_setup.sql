-- Ejercicio 1: Crear la Base de Datos, Usuario y Permisos
CREATE DATABASE IF NOT EXISTS patientsdb COLLATE utf8_unicode_ci;

CREATE USER IF NOT EXISTS 'patients_user'@'%' IDENTIFIED BY 'Patients123!';
GRANT ALL PRIVILEGES ON patientsdb.* TO 'patients_user'@'%';
FLUSH PRIVILEGES;
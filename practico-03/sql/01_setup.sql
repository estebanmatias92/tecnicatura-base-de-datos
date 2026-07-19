-- Creación de la base de datos
CREATE DATABASE IF NOT EXISTS medical_clinic_db;

-- Establecer la base de datos activa para los comandos subsecuentes
USE medical_clinic_db;

-- Creación del usuario administrador (se utiliza '%' para permitir la conexión desde cualquier host de Docker)
CREATE USER IF NOT EXISTS 'clinic_admin'@'%' IDENTIFIED BY 'SecurePass123';

-- Asignación de permisos totales sobre la base de datos específica
GRANT ALL PRIVILEGES ON medical_clinic_db.* TO 'clinic_admin'@'%';

-- Aplicación inmediata de los privilegios
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS academic_ddeav_db;

CREATE USER IF NOT EXISTS 'academic_admin'@'%' IDENTIFIED BY 'SecurePass456';

GRANT ALL PRIVILEGES ON academic_ddeav_db.* TO 'academic_admin'@'%';
FLUSH PRIVILEGES;

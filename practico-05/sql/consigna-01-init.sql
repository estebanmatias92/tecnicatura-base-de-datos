-- ========================================
-- Database
-- ========================================

DROP DATABASE IF EXISTS `practica-db`;
CREATE DATABASE `practica-db` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `practica-db`;


-- ========================================
-- User & Privileges (DCL)
-- ========================================

DROP USER IF EXISTS 'practica_user'@'localhost';
CREATE USER 'practica_user'@'localhost' IDENTIFIED BY 'practica_pass';
GRANT SELECT, INSERT, UPDATE, DELETE ON `practica-db`.* TO 'practica_user'@'localhost';
FLUSH PRIVILEGES;


-- ========================================
-- Schema (DDL)
-- ========================================

DROP TABLE IF EXISTS `transactions`;
DROP TABLE IF EXISTS `bank_accounts`;
DROP TABLE IF EXISTS `transaction_types`;
DROP TABLE IF EXISTS `clients`;


CREATE TABLE IF NOT EXISTS `bank_accounts` (
	`id` INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
	`currency` CHAR(3) NOT NULL COMMENT 'ISO Standard',
	`client_id` INTEGER UNSIGNED NOT NULL,
	PRIMARY KEY(`id`)
);

CREATE TABLE IF NOT EXISTS `transaction_types` (
	`type` VARCHAR(15) NOT NULL,
	`description` VARCHAR(255) NOT NULL UNIQUE,
	PRIMARY KEY(`type`)
);

CREATE TABLE IF NOT EXISTS `transactions` (
	`id` INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
	`bank_account_id` INTEGER UNSIGNED NOT NULL,
	`transaction_type` VARCHAR(15) NOT NULL,
	`transaction_amount` DECIMAL(15,2) NOT NULL COMMENT 'Precision financiera (15,2)',
	PRIMARY KEY(`id`)
);

CREATE TABLE IF NOT EXISTS `clients` (
	`id` INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
	`name` VARCHAR(255) NOT NULL,
	`lastname` VARCHAR(255) NOT NULL,
	`phone` VARCHAR(20) COMMENT 'Overflow protection',
	`email` VARCHAR(255) UNIQUE,
	PRIMARY KEY(`id`)
);


-- ========================================
-- Constraints (Foreign Keys)
-- ========================================

ALTER TABLE `bank_accounts`
ADD FOREIGN KEY(`client_id`) REFERENCES `clients`(`id`)
ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE `transactions`
ADD FOREIGN KEY(`bank_account_id`) REFERENCES `bank_accounts`(`id`)
ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE `transactions`
ADD FOREIGN KEY(`transaction_type`) REFERENCES `transaction_types`(`type`)
ON UPDATE CASCADE ON DELETE RESTRICT;


-- ========================================
-- Seed Data (DML)
-- ========================================

INSERT INTO `transaction_types` (`type`, `description`) VALUES
('DEPOSIT',    'Cash deposit into account'),
('WITHDRAWAL', 'Cash withdrawal from account'),
('TRANSFER',   'Transfer between accounts'),
('PAYMENT',    'Bill or service payment');

INSERT INTO `clients` (`name`, `lastname`, `phone`, `email`) VALUES
('Juan',   'Pérez',     '+5491112345678', 'juan.perez@email.com'),
('María',  'González',  '+5491123456789', 'maria.gonzalez@email.com'),
('Carlos', 'López',     '+5491134567890', 'carlos.lopez@email.com');

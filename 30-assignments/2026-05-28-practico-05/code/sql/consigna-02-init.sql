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

DROP TABLE IF EXISTS `invoice_lines`;
DROP TABLE IF EXISTS `invoices`;
DROP TABLE IF EXISTS `customers`;


CREATE TABLE IF NOT EXISTS `customers` (
	`customer_id`  INT UNSIGNED NOT NULL AUTO_INCREMENT,
	`company_name` VARCHAR(255) NOT NULL,
	`tax_id`       VARCHAR(20)  UNIQUE COMMENT 'CUIT o CDI',
	`address`      VARCHAR(255) NOT NULL,
	`city`         VARCHAR(100) NOT NULL,
	`tax_category` VARCHAR(50)  NOT NULL COMMENT 'Resp. Monotributo / Exento / Cons. Final',
	PRIMARY KEY(`customer_id`)
);

CREATE TABLE IF NOT EXISTS `invoices` (
	`invoice_id`           INT UNSIGNED NOT NULL AUTO_INCREMENT,
	`customer_id`          INT UNSIGNED NOT NULL,
	`invoice_type`         CHAR(1)      NOT NULL COMMENT 'B',
	`point_of_sale`        INT UNSIGNED NOT NULL,
	`invoice_number`       INT UNSIGNED NOT NULL,
	`issue_date`           DATE         NOT NULL,
	`payment_term`         VARCHAR(100) NOT NULL COMMENT 'Contado / Cta. Cte.',
	`delivery_note_number` VARCHAR(50)  COMMENT 'Remito N°',
	`total_amount`         DECIMAL(10,2) NOT NULL,
	PRIMARY KEY(`invoice_id`)
);

CREATE TABLE IF NOT EXISTS `invoice_lines` (
	`line_item_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
	`invoice_id`   INT UNSIGNED NOT NULL,
	`quantity`     DECIMAL(8,2) NOT NULL,
	`description`  VARCHAR(255) NOT NULL,
	`unit_price`   DECIMAL(10,2) NOT NULL,
	`line_total`   DECIMAL(10,2) NOT NULL,
	PRIMARY KEY(`line_item_id`)
);


-- ========================================
-- Constraints (Foreign Keys)
-- ========================================

ALTER TABLE `invoices`
ADD FOREIGN KEY(`customer_id`) REFERENCES `customers`(`customer_id`)
ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE `invoice_lines`
ADD FOREIGN KEY(`invoice_id`) REFERENCES `invoices`(`invoice_id`)
ON UPDATE CASCADE ON DELETE CASCADE;


-- ========================================
-- Seed Data (DML)
-- ========================================

INSERT INTO `customers` (`company_name`, `tax_id`, `address`, `city`, `tax_category`) VALUES
('Comercio Ejemplo S.A.', '30-12345678-9', 'Av. Siempre Viva 742', 'Springfield', 'Resp. Inscripto');

INSERT INTO `invoices` (`customer_id`, `invoice_type`, `point_of_sale`, `invoice_number`, `issue_date`, `payment_term`, `delivery_note_number`, `total_amount`) VALUES
(1, 'B', 1, 1, CURDATE(), 'Contado', NULL, 1500.00);

INSERT INTO `invoice_lines` (`invoice_id`, `quantity`, `description`, `unit_price`, `line_total`) VALUES
(1, 10.00, 'Producto A - Unidad', 100.00, 1000.00),
(1,  5.00, 'Producto B - Unidad', 100.00,  500.00);

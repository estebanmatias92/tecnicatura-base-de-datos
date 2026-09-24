-- 01: Esquema mínimo sales_system_db (inferido del apunte, no viene con DDL).
-- Qué: crea las 4 tablas que los ejemplos asumen: customers, products, orders, order_items.
-- Cómo se ejecuta: `make schema` (como APP_USER contra sales_system_db).
-- Notas:
--   - InnoDB es obligatorio: es el motor que soporta transacciones y FKs en MariaDB.
--   - orders.customer_id es RESTRICT: el caso 3 del apunte (cliente 9999) debe fallar
--     por FK y caer en el EXIT HANDLER con ROLLBACK.
--   - Idempotente: CREATE TABLE IF NOT EXISTS, re-ejecutable sin errores.

CREATE TABLE IF NOT EXISTS customers (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS products (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    stock INT NOT NULL DEFAULT 0 CHECK (stock >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS orders (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    customer_id INT UNSIGNED NOT NULL,
    order_date DATE NOT NULL DEFAULT (CURDATE()),
    total DECIMAL(10, 2) NOT NULL,
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id)
        REFERENCES customers (id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE INDEX IF NOT EXISTS ix_orders_customer ON orders (customer_id);

CREATE TABLE IF NOT EXISTS order_items (
    order_id INT UNSIGNED NOT NULL,
    product_id INT UNSIGNED NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    price DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (order_id, product_id),
    CONSTRAINT fk_items_order FOREIGN KEY (order_id)
        REFERENCES orders (id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_items_product FOREIGN KEY (product_id)
        REFERENCES products (id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

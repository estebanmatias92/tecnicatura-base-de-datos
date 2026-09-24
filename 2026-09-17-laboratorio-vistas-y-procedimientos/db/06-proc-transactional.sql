-- 06: Procedimiento transaccional sp_process_order_transactional (puntos 4 y 5 del apunte).
-- Qué: procesa una venta completa y atómica: INSERT orders + INSERT order_items
--   + UPDATE stock. Si algo falla (o no hay stock), ROLLBACK total.
-- Cómo se ejecuta: `make proc-tx`. Los casos de prueba viven en 99-verify.sql.
-- Notas:
--   - DECLARE EXIT HANDLER FOR SQLEXCEPTION: el "TRY/CATCH" de MariaDB; cualquier
--     error SQL (FK inexistente, duplicados, tipos) cae acá: ROLLBACK + p_status.
--   - Las validaciones de negocio (producto inexistente, stock insuficiente) hacen
--     ROLLBACK explícito con su propio mensaje, sin pasar por el handler.
--   - START TRANSACTION desactiva el autocommit hasta COMMIT/ROLLBACK.
--   - DROP PROCEDURE IF EXISTS: idempotente.

DROP PROCEDURE IF EXISTS sp_process_order_transactional;

DELIMITER $$

CREATE PROCEDURE sp_process_order_transactional(
    IN p_customer_id INT,
    IN p_product_id INT,
    IN p_quantity INT,
    OUT p_status VARCHAR(100)
)
BEGIN
    -- Variables auxiliares
    DECLARE v_product_price DECIMAL(10, 2);
    DECLARE v_current_stock INT;
    DECLARE v_order_id INT;
    DECLARE v_total DECIMAL(10, 2);

    -- MANEJO DE EXCEPCIONES (equivalente al TRY/CATCH)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_status = 'ERROR_SQL: Operación cancelada. Cambio revertido mediante ROLLBACK.';
    END;

    -- Inicio del bloque transaccional
    START TRANSACTION;

    -- 1. Validar existencia y stock del producto
    SELECT price, stock INTO v_product_price, v_current_stock
    FROM products
    WHERE id = p_product_id;

    IF v_current_stock IS NULL THEN
        ROLLBACK;
        SET p_status = 'ERROR: El producto no existe.';
    ELSEIF v_current_stock < p_quantity THEN
        ROLLBACK;
        SET p_status = 'ERROR: Stock insuficiente para procesar la orden.';
    ELSE
        -- 2. Calcular total de la orden
        SET v_total = v_product_price * p_quantity;

        -- 3. Insertar la orden
        INSERT INTO orders (customer_id, order_date, total)
        VALUES (p_customer_id, CURDATE(), v_total);

        SET v_order_id = LAST_INSERT_ID();

        -- 4. Insertar el ítem del pedido
        INSERT INTO order_items (order_id, product_id, quantity, price)
        VALUES (v_order_id, p_product_id, p_quantity, v_product_price);

        -- 5. Actualizar el stock del producto
        UPDATE products
        SET stock = stock - p_quantity
        WHERE id = p_product_id;

        COMMIT;
        SET p_status = 'OK: Orden procesada correctamente.';
    END IF;
END$$

DELIMITER ;

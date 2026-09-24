-- 99: Verificación asertiva de los 3 casos de prueba del apunte.
-- Qué: smoke test del proc transaccional. Falla con SIGNAL si algo no cumple.
-- Cómo se usa: `make verify`. Re-ejecutable: resetea el stock a valores conocidos
--   y trabaja con deltas (conteos antes/después), así las órdenes que acumula
--   de corridas previas no lo rompen.
-- Casos:
--   1. Éxito (customer 1, product 2, qty 5): status OK + stock 50→45 + 1 orden nueva.
--   2. Negocio (customer 1, product 1, qty 999): 'Stock insuficiente', sin cambios.
--   3. Error SQL (customer 9999, product 2, qty 1): handler SQLEXCEPTION + ROLLBACK.

DROP PROCEDURE IF EXISTS sp_verify_lab;

DELIMITER $$

CREATE PROCEDURE sp_verify_lab()
BEGIN
    DECLARE v_status VARCHAR(100);
    DECLARE v_stock INT;
    DECLARE v_orders_before INT;
    DECLARE v_orders_after INT;

    -- Estado determinista de partida
    UPDATE products SET stock = 50 WHERE id = 2;
    UPDATE products SET stock = 10 WHERE id = 1;

    -- Caso 1: prueba exitosa
    SELECT COUNT(*) INTO v_orders_before FROM orders;
    CALL sp_process_order_transactional(1, 2, 5, v_status);
    SELECT COUNT(*) INTO v_orders_after FROM orders;
    SELECT stock INTO v_stock FROM products WHERE id = 2;
    IF v_status NOT LIKE 'OK%' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Caso 1 falló: status no es OK';
    END IF;
    IF v_stock <> 45 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Caso 1 falló: stock de Mouse debe ser 45';
    END IF;
    IF v_orders_after <> v_orders_before + 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Caso 1 falló: debe crearse exactamente 1 orden';
    END IF;

    -- Caso 2: reversión por negocio (stock insuficiente)
    SELECT COUNT(*) INTO v_orders_before FROM orders;
    CALL sp_process_order_transactional(1, 1, 999, v_status);
    SELECT COUNT(*) INTO v_orders_after FROM orders;
    SELECT stock INTO v_stock FROM products WHERE id = 1;
    IF v_status NOT LIKE 'ERROR: Stock insuficiente%' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Caso 2 falló: debe reportar stock insuficiente';
    END IF;
    IF v_orders_after <> v_orders_before THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Caso 2 falló: no debe crear órdenes';
    END IF;
    IF v_stock <> 10 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Caso 2 falló: stock de Teclado no debe cambiar';
    END IF;

    -- Caso 3: reversión por error SQL (FK cliente inexistente → EXIT HANDLER)
    SELECT COUNT(*) INTO v_orders_before FROM orders;
    CALL sp_process_order_transactional(9999, 2, 1, v_status);
    SELECT COUNT(*) INTO v_orders_after FROM orders;
    SELECT stock INTO v_stock FROM products WHERE id = 2;
    IF v_status NOT LIKE 'ERROR_SQL%' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Caso 3 falló: debe capturarlo el handler SQLEXCEPTION';
    END IF;
    IF v_orders_after <> v_orders_before THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Caso 3 falló: ROLLBACK debe revertir la orden';
    END IF;
    IF v_stock <> 45 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Caso 3 falló: stock no debe cambiar tras ROLLBACK';
    END IF;

    SELECT 'VERIFY OK: vista, función y procedimientos cumplen' AS resultado;
END$$

DELIMITER ;

CALL sp_verify_lab();
DROP PROCEDURE sp_verify_lab;

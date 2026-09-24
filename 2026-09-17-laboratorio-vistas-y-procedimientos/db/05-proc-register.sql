-- 05: Procedimiento sp_register_product (punto 3 del apunte).
-- Qué: alta de producto con parámetro de salida (OUT) + LAST_INSERT_ID().
-- Cómo se ejecuta: `make proc-simple`.
-- Ejemplo:
--   CALL sp_register_product('Impresora 3D', 450.00, 8, @new_id);
--   SELECT @new_id AS generated_product_id;
-- Notas:
--   - DROP PROCEDURE IF EXISTS: idempotente.
--   - IN vs OUT: los IN entran, el OUT devuelve el id generado al llamador.
--   - No se llama desde un SELECT (a diferencia de las funciones): se invoca con CALL.

DROP PROCEDURE IF EXISTS sp_register_product;

DELIMITER $$

CREATE PROCEDURE sp_register_product(
    IN p_name VARCHAR(100),
    IN p_price DECIMAL(10, 2),
    IN p_stock INT,
    OUT p_product_id INT
)
BEGIN
    INSERT INTO products (name, price, stock)
    VALUES (p_name, p_price, p_stock);

    SET p_product_id = LAST_INSERT_ID();
END$$

DELIMITER ;

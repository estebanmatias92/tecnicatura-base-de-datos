-- 04: Función fn_calculate_discount (punto 2 del apunte).
-- Qué: cálculo reutilizable que devuelve UN único valor escalar (RETURN obligatorio).
-- Cómo se ejecuta: `make function`.
-- Ejemplo:
--   SELECT name, price, fn_calculate_discount(price, 15.00) AS price_with_15pc_discount
--   FROM products;
-- Notas:
--   - DROP FUNCTION IF EXISTS: idempotente, re-ejecutable.
--   - DETERMINISTIC: mismos inputs → mismo output; además evita el error de
--     binary logging (log_bin_trust_function_creators) en MariaDB.
--   - DELIMITER $$: el cuerpo usa ";" internos; el delimitador temporal deja que
--     el cliente mande el CREATE completo como una sola sentencia.

DROP FUNCTION IF EXISTS fn_calculate_discount;

DELIMITER $$

CREATE FUNCTION fn_calculate_discount(
    p_original_price DECIMAL(10, 2),
    p_discount_rate DECIMAL(5, 2)
)
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
    DECLARE v_final_price DECIMAL(10, 2);
    SET v_final_price = p_original_price - (p_original_price * (p_discount_rate / 100));
    RETURN v_final_price;
END$$

DELIMITER ;

-- 07: Demos de uso por concepto (solo lectura + una escritura descartable).
-- Qué: los "Uso de..." del apunte, para correr y ver por pantalla.
-- Cómo se ejecuta: `make demos`. Re-ejecutable y no rompe el seed:
--   el producto demo se borra antes y después.
-- Incluye: vista (03), función (04) y proc simple (05). El proc
-- transaccional (06) se ejercita aparte en 99-verify.sql.

-- Vista: resumen de clientes como si fuera una tabla normal
SELECT * FROM v_customer_order_summary WHERE total_spent > 500;
SELECT * FROM v_customer_order_summary ORDER BY customer_id;

-- Función: cálculo dentro de un SELECT
SELECT name, price, fn_calculate_discount(price, 15.00) AS price_with_15pc_discount
FROM products ORDER BY id;

-- Proc simple: alta vía CALL + parámetro OUT, luego limpieza
DELETE FROM products WHERE name = 'Impresora 3D demo';
CALL sp_register_product('Impresora 3D demo', 450.00, 8, @new_id);
SELECT @new_id AS generated_product_id;
SELECT id, name, price, stock FROM products WHERE id = @new_id;
DELETE FROM products WHERE id = @new_id;
SELECT 'DEMOS OK' AS resultado;

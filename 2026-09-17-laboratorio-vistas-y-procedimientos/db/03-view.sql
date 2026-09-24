-- 03: Vista v_customer_order_summary (punto 1 del apunte).
-- Qué: "tabla virtual" con el resumen de clientes y sus compras (LEFT JOIN + GROUP BY).
-- Cómo se ejecuta: `make view`.
-- Ejemplo:
--   SELECT * FROM v_customer_order_summary WHERE total_spent > 500;
-- Notas:
--   - CREATE OR REPLACE: re-ejecutable sin DROP previo.
--   - LEFT JOIN: los clientes sin compras aparecen con total_orders = 0.
--   - IFNULL(SUM...): SUM de un cliente sin órdenes da NULL; lo mostramos como 0.00.

CREATE OR REPLACE VIEW v_customer_order_summary AS
SELECT
    c.id AS customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    COUNT(o.id) AS total_orders,
    IFNULL(SUM(o.total), 0.00) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.first_name, c.last_name;

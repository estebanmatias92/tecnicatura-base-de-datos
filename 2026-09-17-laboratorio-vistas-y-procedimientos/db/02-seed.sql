-- 02: Seed mínimo para los 3 casos de prueba del apunte.
-- Qué: deja el estado que los ejemplos asumen (IDs fijos).
-- Cómo se ejecuta: `make seed`. Re-ejecutable.
-- Datos:
--   - customer 1 (Ana García): el que compra en los 3 casos.
--   - product 1 (Teclado, stock 10): el pedido de 999 unidades falla por stock.
--   - product 2 (Mouse, stock 50): el pedido de 5 unidades es éxito (queda en 45).
-- Notas:
--   - ON DUPLICATE KEY UPDATE: si el id ya existe lo actualiza en vez de fallar.
--   - Los pedidos de prueba NO se borran acá: 99-verify trabaja con deltas y
--     resetea el stock antes de correr, así es idempotente aunque haya órdenes previas.

INSERT INTO customers (id, first_name, last_name) VALUES
    (1, 'Ana', 'García'),
    (2, 'Juan', 'Pérez')
ON DUPLICATE KEY UPDATE
    first_name = VALUES(first_name),
    last_name = VALUES(last_name);

INSERT INTO products (id, name, price, stock) VALUES
    (1, 'Teclado', 100.00, 10),
    (2, 'Mouse', 50.00, 50),
    (3, 'Monitor', 300.00, 20)
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    price = VALUES(price),
    stock = VALUES(stock);

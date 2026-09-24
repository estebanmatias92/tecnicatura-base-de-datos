# Laboratorio — Vistas, funciones y procedimientos (MariaDB 11)

Entorno aislado y reproducible en **MariaDB 11** con Docker + GNU Make para probar el apunte de vistas, funciones y stored procedures (`sales_system_db`).

## Requisitos

Docker Engine + Docker Compose + GNU Make. El servicio expone `3307` para no chocar con un MySQL/MariaDB local en `3306`.

## Estructura

```text
.
├── docker-compose.yaml
├── Makefile
├── .env.example
└── db/
    ├── 01-schema.sql            # tablas sales_system_db (inferido, el apunte no trae DDL)
    ├── 02-seed.sql              # datos mínimos para los 3 casos (prod 2 stock 50)
    ├── 03-view.sql              # v_customer_order_summary
    ├── 04-function.sql          # fn_calculate_discount
    ├── 05-proc-register.sql     # sp_register_product (IN/OUT)
    ├── 06-proc-transactional.sql # sp_process_order_transactional (tx + handler)
    ├── 07-demos.sql             # usos SELECT/CALL por concepto
    └── 99-verify.sql            # 3 casos del apunte (asertivo)
```

## Uso

```bash
cp .env.example .env
make up
make all        # schema → seed → view → function → proc-simple → proc-tx → demos → verify
make verify     # re-ejecutable, termina en 'VERIFY OK'
make mysql      # cliente como lab_user
make reset      # down -v + up (limpio)
make down
```

Cada ejemplo corre por separado: `make schema`, `make seed`, `make view`, `make function`, `make proc-simple`, `make proc-tx`, `make demos`. `make` solo muestra la ayuda.

## Trazabilidad (Apunte → Artefacto)

| Apunte | Objeto(s) | Artefacto |
|---|---|---|
| Punto 1 — Vistas | `v_customer_order_summary` | `db/03-view.sql` (`make view`) |
| Punto 2 — Funciones | `fn_calculate_discount(price, rate)` | `db/04-function.sql` (`make function`) |
| Punto 3 — Procedimientos | `sp_register_product(..., OUT id)` | `db/05-proc-register.sql` (`make proc-simple`) |
| Punto 4 — Transacciones | `START TRANSACTION/COMMIT/ROLLBACK` en `sp_process_order_transactional` | `db/06-proc-transactional.sql` (`make proc-tx`) |
| Punto 5 — TRY/CATCH | `DECLARE EXIT HANDLER FOR SQLEXCEPTION` | `db/06-proc-transactional.sql` (`make proc-tx`) |
| Ejemplo integrado | venta atómica orders + order_items + stock | `db/06-proc-transactional.sql` |
| Caso 1 — Éxito | `CALL(1, 2, 5)` → OK, stock 50→45 | `db/99-verify.sql` (`make verify`) |
| Caso 2 — Stock insuficiente | `CALL(1, 1, 999)` → ERROR, sin cambios | `db/99-verify.sql` (`make verify`) |
| Caso 3 — FK inexistente | `CALL(9999, 2, 1)` → ERROR_SQL + ROLLBACK | `db/99-verify.sql` (`make verify`) |
| Entorno | contenedor MariaDB 11 + interfaz | `docker-compose.yaml`, `Makefile` |

## Decisiones

* **Esquema inferido:** el apunte no trae DDL; se modela lo mínimo que los ejemplos asumen (`customers`, `products`, `orders`, `order_items`) en `InnoDB` (transacciones + FKs).
* **Idempotencia:** `CREATE TABLE IF NOT EXISTS`, `CREATE OR REPLACE VIEW`, `DROP ... IF EXISTS` antes de cada rutina, seed con `ON DUPLICATE KEY UPDATE`, verify con stock reseteado + deltas.
* **Función `DETERMINISTIC`:** evita el error de binary logging de MariaDB además de documentar la pureza.
* **Verify asertivo:** wrapper `sp_verify_lab()` con `SIGNAL` (MariaDB no tiene bloques `DO` con `DECLARE` como Postgres); falla en rojo si algún caso no cumple.
* **Sin `setup` manual:** la DB y el usuario los crea la imagen en el primer `up` (variables `MARIADB_*`).

## Documentación del sistema

- `docs/GLOSSARY.md` — glosario con solo los términos usados en `db/`

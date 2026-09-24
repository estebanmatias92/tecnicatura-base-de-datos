# Glosario — solo términos usados en `db/`

| Término | Qué es | Dónde se usa |
|---|---|---|
| `VIEW` | Consulta guardada con nombre; "tabla virtual" sin datos propios. | `db/03-view.sql` (`CREATE OR REPLACE VIEW`) |
| `STORED FUNCTION` | Rutina que recibe parámetros y **devuelve un único valor** (`RETURN`); se usa dentro de `SELECT`/`WHERE`. | `db/04-function.sql` |
| `DETERMINISTIC` | Declara que mismos inputs dan mismo output; evita el error de binary logging en MariaDB. | `db/04-function.sql` |
| `STORED PROCEDURE` | Programa en el servidor con `IN`/`OUT`; se invoca con `CALL`, puede hacer DML + transacciones. | `db/05-*.sql`, `db/06-*.sql` |
| `LAST_INSERT_ID()` | Devuelve el `AUTO_INCREMENT` generado por el `INSERT` previo en la sesión. | `db/05-*.sql`, `db/06-*.sql` |
| `DELIMITER $$` | Cambia el delimitador temporal para que el cliente mande el `CREATE` con `;` internos como una sola sentencia. | `db/04-*.sql`, `db/05-*.sql`, `db/06-*.sql`, `db/99-verify.sql` |
| `START TRANSACTION` / `COMMIT` / `ROLLBACK` | Bloque atómico: todo se confirma junto o se revierte todo. | `db/06-*.sql` |
| `DECLARE EXIT HANDLER FOR SQLEXCEPTION` | El "TRY/CATCH" de MariaDB: ante cualquier error SQL ejecuta el bloque (acá: `ROLLBACK` + mensaje) y sale. | `db/06-*.sql` |
| `SIGNAL SQLSTATE '45000'` | Lanza un error a propósito; así el verify asertivo falla en rojo si una condición no se cumple. | `db/99-verify.sql` |
| `ON DUPLICATE KEY UPDATE` | Idioma de seed idempotente: si el id ya existe, actualiza en vez de fallar. | `db/02-seed.sql` |
| `InnoDB` | Motor con transacciones y FKs (vs MyISAM, sin ambas). | `db/01-schema.sql` |

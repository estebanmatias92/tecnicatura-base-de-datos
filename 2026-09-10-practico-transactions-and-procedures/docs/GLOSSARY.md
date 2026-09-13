# Glosario PostgreSQL — Práctico 08 (Bibliotech)

Referencia de los términos de PostgreSQL usados en [`db/`](../db/) (solo los que
aparecen en este práctico). La columna SQLite/MySQL es el puente desde lo que ya
conocés de nivel intermedio en esos motores.

## Tipos de datos

| Término | Qué es | SQLite / MySQL que ya conocés | Dónde lo usamos |
|---|---|---|---|
| `CITEXT` | Texto insensible a mayúsculas: `'Profa'` = `'profa'`. Requiere `CREATE EXTENSION citext`. Ideal para usernames y nombres de rol. | MySQL con collation `*_ci` (ej. `utf8mb4_unicode_ci`); SQLite no tiene equivalente directo (habría que usar `COLLATE NOCASE`). | `02-schema.sql` (`users.username`, `roles.name`), SPs con params `CITEXT` |
| `TEXT` | Cadena de largo ilimitado. En Postgres es el tipo de texto preferido (rendimiento igual a `VARCHAR`). | `TEXT` en ambos; en MySQL suele usarse `VARCHAR(n)` por hábito. | `password_hash`, `displayname`, `file_path`, `action` |
| `BIGINT` | Entero de 64 bits. Para IDs que nunca se van a quedar cortos. | `INTEGER` (SQLite, 64 bits igual) / `BIGINT` (MySQL). | IDs y variables `v_user_id`, `v_doc_id` |
| `TIMESTAMPTZ` | Fecha+hora con zona horaria (`... now()` guarda en UTC y muestra según sesión). | `DATETIME`/`TIMESTAMP` (MySQL); `TEXT` con formato ISO o `INTEGER` epoch (SQLite). | `created_at`, `deleted_at` (Fase 4) |
| `BOOLEAN` | Verdadero/falso real (`true`/`false`). | SQLite: `INTEGER` 0/1 (sin tipo nativo); MySQL: `TINYINT(1)`/`BOOL` (alias). | Retorno de `sp_has_role` |

## Identidad y claves

| Término | Qué es | SQLite / MySQL que ya conocés | Dónde lo usamos |
|---|---|---|---|
| `GENERATED ALWAYS AS IDENTITY` | Columna autoincremental estándar SQL. El motor genera el valor; `ALWAYS` impide insertarlo a mano (salvo `OVERRIDING SYSTEM VALUE`). Sucesor de `SERIAL`. | `INTEGER PRIMARY KEY AUTOINCREMENT` (SQLite); `AUTO_INCREMENT` (MySQL). | Todos los `id` en `02-schema.sql` |
| `PRIMARY KEY` | Identificador único de fila + índice implícito. | Igual en ambos. | `id` de cada tabla; compuesta `(user_id, role_id)` en `users_roles` |
| `UNIQUE` | Valores no repetidos (con índice). | Igual en ambos. | `users.username`, `roles.name` |
| `CHECK` | Regla que cada fila debe cumplir; el INSERT/UPDATE que la viola falla. | `CHECK` (MySQL 8.0.16+, SQLite sí lo respeta). | `log.action IN ('UPLOAD','DOWNLOAD')` |
| `REFERENCES ... ON DELETE` | Qué pasa en la hija cuando se borra el padre: `CASCADE` (borra en cadena), `SET NULL` (pone NULL, conserva la fila), `RESTRICT` (prohíbe borrar si hay hijas). | MySQL InnoDB tiene los 3; SQLite los soporta pero exige `PRAGMA foreign_keys=ON` (apagado por default). | `02-schema.sql` (diseño C6); `07-maintenance.sql` lo explica |
| `DEFAULT now()` | Si no pasás valor, se usa la hora actual del servidor. | `DEFAULT CURRENT_TIMESTAMP` (MySQL); `DEFAULT CURRENT_TIMESTAMP` (SQLite). | `created_at`, `assigned_at` |

## Funciones y lenguaje procedural

| Término | Qué es | SQLite / MySQL que ya conocés | Dónde lo usamos |
|---|---|---|---|
| `plpgsql` | Lenguaje procedural de Postgres (variables, IF, loops, excepciones). Se declara con `LANGUAGE plpgsql`. | Procedimientos MySQL (`CREATE PROCEDURE`); SQLite **no tiene** lenguaje procedural (la lógica vive en la app). | Todas las `sp_*` con lógica |
| `LANGUAGE sql` | Función de una sola consulta, sin variables ni IF. Más simple y optimizable. | Funciones MySQL de una sentencia; N/A en SQLite. | `sp_report_*` (envoltorios de vistas) |
| `STABLE` | Promesa: "no modifica la DB y con iguales argumentos devuelve lo mismo dentro de una consulta". El planificador puede optimizar. Las que escriben no lo llevan. | Sin equivalente directo en MySQL/SQLite (`DETERMINISTIC` de MySQL es lo más cercano). | `sp_get_password_hash`, `sp_has_role`, `sp_report_*` |
| `RETURNS TABLE (...)` | La función devuelve un conjunto de filas con columnas nombradas (se consulta como tabla). | MySQL no lo tiene (usa OUT params o result sets); N/A en SQLite. | `sp_report_prolific_professors`, `sp_report_popular_documents` |
| `FOUND` | Variable implícita de plpgsql: `true` si el `SELECT`/`UPDATE` anterior tocó ≥1 fila. Sirve para fallar con error claro en vez de seguir con NULL. | Patrón `ROW_COUNT()` (MySQL) / `changes()` (SQLite). | Todas las validaciones "no existe" |
| `RETURNING ... INTO` | El `INSERT`/`UPDATE`/`DELETE` devuelve valores de la fila afectada (ej. el id generado) y los guarda en variable, sin un `SELECT` extra. | `LAST_INSERT_ID()` (MySQL) / `last_insert_rowid()` (SQLite), pero limitados al id y con race conditions; `RETURNING` es atómico y general. | `sp_upload_document`, `sp_log_download` |
| `RAISE EXCEPTION` | Lanza un error con mensaje (corta la ejecución y revierte la transacción). `%` inserta variables en el mensaje. | `SIGNAL SQLSTATE` (MySQL); `RAISE(ABORT, ...)` solo en triggers (SQLite). | Todas las validaciones |
| `EXCEPTION WHEN OTHERS` | Bloque que atrapa cualquier error dentro de `BEGIN ... END` interno, para re-lanzarlo con mejor mensaje. El ROLLBACK lo hace el motor al propagarse. | `DECLARE ... HANDLER` (MySQL); sin equivalente (SQLite). | `sp_upload_document` (C4), `99-verify.sql` (test de rollback) |
| `DO $$ ... $$` | Bloque anónimo: código plpgsql que se ejecuta una vez sin crear función (útil para setup y tests). | Sin equivalente directo; lo más cercano es un script multi-sentencia. | `01-setup.sql`, `99-verify.sql` |

## Idempotencia y utilidades

| Término | Qué es | SQLite / MySQL que ya conocés | Dónde lo usamos |
|---|---|---|---|
| `IF NOT EXISTS` | No falla si el objeto ya existe (re-ejecutable). | Igual en MySQL; SQLite lo tiene para tablas/índices. | `CREATE TABLE/INDEX/EXTENSION`, `ALTER TABLE ... ADD COLUMN` (Fase 4) |
| `ON CONFLICT DO NOTHING` | Si la fila viola una restricción única, la saltea en vez de fallar. Clave de los seeds re-ejecutables. | `INSERT IGNORE` (MySQL); `INSERT OR IGNORE` (SQLite). | `03-seed.sql` |
| `CREATE OR REPLACE` | Redefine vistas/funciones sin borrarlas primero. | `CREATE OR REPLACE VIEW` (MySQL); SQLite no lo tiene para vistas. | Vistas y SPs (`04`–`09`) |
| `CREATE EXTENSION` | Activa un módulo extra del servidor (aquí: `citext`). | Sin equivalente (los motores traen todo integrado). | `02-schema.sql` |
| `btrim()` | Recorta espacios en ambos extremos (`'   '` → `''`). Se usa para rechazar strings "vacíos" disfrazados. | `TRIM()` en ambos. | Validaciones en `05-upload.sql`, `07-maintenance.sql` |
| `HAVING` vs `WHERE` | `WHERE` filtra filas **antes** de agrupar; `HAVING` filtra grupos **después** de `GROUP BY`/`COUNT`. Los reportes necesitan `HAVING`. | Igual en ambos (sintaxis estándar SQL). | `08-reports.sql` (`> 1` y `> 2` de la consigna) |
| `\gexec` | **No es SQL**: meta-comando de `psql` que ejecuta el texto devuelto por el `SELECT` anterior. Truco para emular `CREATE DATABASE IF NOT EXISTS`. | Sin equivalente (comandos `\.`/`source` del cliente MySQL son lo más cercano como concepto). | `01-setup.sql` |

# Glosario PostgreSQL — Práctico 09 (patientsdb)

Referencia de los términos de PostgreSQL usados en [`db/`](../db/) (solo los que
aparecen en este práctico). La columna MySQL es el puente desde la consigna
original (MySQL) hacia el target real (Postgres). Ver mapeo físico en
[`ER.md`](ER.md) §3.

## Tipos de datos y restricciones (DDL — Ej.2)

| Término | Qué es | MySQL de la consigna | Dónde lo usamos |
|---|---|---|---|
| `INTEGER GENERATED ALWAYS AS IDENTITY` | Columna autoincremental estándar SQL. El motor genera el valor; `ALWAYS` impide insertarlo a mano (salvo `OVERRIDING SYSTEM VALUE`). Sucesor de `SERIAL`. | `INT AUTO_INCREMENT` | `02-schema.sql` (`patients.id`) |
| `PRIMARY KEY` | Identificador único de fila + índice implícito. Única vía de acceso para `UPDATE`/`DELETE` (Ej.5–6). | Igual | `patients.id` |
| `VARCHAR(n)` | Cadena de largo máximo `n`. | Igual | `first_name(50)`, `last_name(50)`, `phone(15)`, `email(100)` |
| `DATE` | Fecha calendario (sin hora). Se inserta en ISO `'YYYY-MM-DD'`. | Igual | `birth_date` |
| `NOT NULL` | La columna no admite `NULL`; el `INSERT` sin valor falla. | Igual | `first_name`, `last_name`, `birth_date` |
| `UNIQUE` | Valores no repetidos (con índice). Con `NULL`: múltiples `NULL` permitidos, la unicidad rige solo para valores concretos. | Igual | `phone` |
| `NULL` (valor) | Ausencia de dato (no es `''` ni `0`). En el `INSERT` se escribe sin comillas. | Igual | `email` de Mike Brown en `03-seed.sql` |

## DCL — Ej.1

| Término | Qué es | MySQL de la consigna | Dónde lo usamos |
|---|---|---|---|
| `CREATE ROLE ... WITH LOGIN` | Crea un usuario a nivel cluster. Con `LOGIN` puede conectarse; `PASSWORD` define su clave. | `CREATE USER 'patients_user'@'localhost' IDENTIFIED BY '...'` (en MySQL el host va en el nombre; en Postgres no existe ese concepto). | `01-setup.sql` |
| `CREATE DATABASE ... OWNER` | Crea la base y le asigna dueño (el dueño puede crear schemas/tablas sin grants extra). `ENCODING 'UTF8'` es el default y equivale al `utf8mb4` pedido. | `CREATE DATABASE patientsdb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci` | `01-setup.sql` (vía `\gexec`) |
| `GRANT ALL PRIVILEGES ON DATABASE` | Da acceso/conexión a la DB al rol. El acceso al schema `public` se otorga aparte en el target `setup` del `Makefile`. | `GRANT ALL PRIVILEGES ON patientsdb.* TO 'patients_user'@'localhost'` | `01-setup.sql` + `Makefile` |

## DML — Ej.3 / Ej.5 / Ej.6

| Término | Qué es | MySQL de la consigna | Dónde lo usamos |
|---|---|---|---|
| `INSERT INTO ... (...) VALUES` | Inserta filas con lista explícita de columnas destino (lo que pide el Ej.3). | Igual | `03-seed.sql` |
| `ON CONFLICT DO NOTHING` | Si la fila viola una restricción única, la saltea en vez de fallar. Clave del seed re-ejecutable. | `INSERT IGNORE` | `03-seed.sql` |
| `UPDATE ... SET ... WHERE` | Modifica filas que cumplen el filtro. Sin `WHERE` tocaría toda la tabla. | Igual | `05-update.sql` |
| `DELETE FROM ... WHERE` | Borra filas que cumplen el filtro. Sin `WHERE` vacía la tabla. | Igual | `06-delete.sql` |
| Subselect por PK | `WHERE id = (SELECT id ... WHERE first_name=... )`: resuelve la PK por datos legibles y filtra por ella, cumpliendo "utilizando su clave primaria" sin hardcodear el número. | Patrón aplicable igual | `05-update.sql`, `06-delete.sql` |

## DQL y funciones de fecha — Ej.4

| Término | Qué es | MySQL de la consigna | Dónde lo usamos |
|---|---|---|---|
| `SELECT` / `WHERE` | Proyección de columnas y filtro de filas. | Igual (estándar SQL) | `04-queries.sql` (4.1–4.4) |
| `CONCAT(a, ' ', b)` | Concatena cadenas (aquí: nombre completo). Existe en ambos motores. | `CONCAT` (ver función pedida en 4.2) | `04-queries.sql` (4.2, 4.3), `99-verify.sql` |
| `CURRENT_DATE` | Fecha actual del servidor (zona de la sesión). | `CURDATE()` | `04-queries.sql`, `99-verify.sql` |
| `AGE(fecha_tardía, fecha_temprana)` | Resta fechas y devuelve un `interval` (años, meses, días...). Solo Postgres. | `TIMESTAMPDIFF(YEAR, birth_date, CURDATE())` (devuelve el entero directo) | `04-queries.sql` (4.2, 4.3) |
| `EXTRACT(YEAR FROM intervalo)::INT` | Extrae los años cumplidos del intervalo como entero. Combinado con `AGE` replica el `TIMESTAMPDIFF(YEAR, ...)` de la consigna. | `TIMESTAMPDIFF(YEAR, ...)` | `04-queries.sql` (4.2, 4.3) |
| `INTERVAL '30 years'` | Literal de intervalo. `birth_date < CURRENT_DATE - INTERVAL '30 years'` es la forma sargable (puede usar índice) de "mayores de 30". | Comparar `birth_date` directamente (alternativa que la consigna permite) | `04-queries.sql` (4.3, alternativa comentada), `99-verify.sql` |

## Idempotencia, scripting y verificación

| Término | Qué es | MySQL que ya conocés | Dónde lo usamos |
|---|---|---|---|
| `IF NOT EXISTS` | No falla si el objeto ya existe (re-ejecutable). | Igual (`CREATE DATABASE/TABLE/USER IF NOT EXISTS`) | `02-schema.sql` |
| `DO $$ ... $$` | Bloque anónimo plpgsql: se ejecuta una vez sin crear función (útil para setup y tests). | Sin equivalente directo; lo más cercano es un script multi-sentencia | `01-setup.sql`, `99-verify.sql` |
| `\gexec` | **No es SQL**: meta-comando de `psql` que ejecuta el texto devuelto por el `SELECT` anterior. Truco para emular `CREATE DATABASE IF NOT EXISTS`. | Sin equivalente (comandos `source` del cliente MySQL son lo más cercano como concepto) | `01-setup.sql` |
| `RAISE EXCEPTION` / `RAISE NOTICE` | `EXCEPTION` lanza un error con mensaje (corta y revierte); `NOTICE` imprime info sin cortar. `%` inserta variables. | `SIGNAL SQLSTATE` (solo EXCEPTION, MySQL); sin equivalente en cliente | `99-verify.sql` |
| `FOUND` | Variable implícita plpgsql: `true` si el `SELECT ... INTO` anterior devolvió fila. | Patrón `ROW_COUNT()` (MySQL) | `99-verify.sql` |
| `-v ON_ERROR_STOP=1` | Flag de `psql`: ante el primer error aborta el script en vez de seguir. Todos los targets del `Makefile` lo usan. | `--force` invertido del cliente MySQL | `Makefile` |

# Práctico 09 — SQL Timestamp Function (patientsdb)

Tabla única `patients` en **PostgreSQL 18** con Docker + GNU Make. Entorno aislado
y reproducible para los Ej.1–6 (DCL, DDL, DML y DQL con cálculo de edad).
La consigna original es MySQL (`TIMESTAMPDIFF`, `AUTO_INCREMENT`, `utf8mb4`);
aquí se implementa el equivalente Postgres ejecutable y se documenta el puente
MySQL↔Postgres en [`docs/ER.md`](docs/ER.md) §3.

## Requisitos

Docker Engine + Docker Compose + GNU Make. El servicio expone `5433` para no
chocar con otro Postgres local en `5432`.

## Estructura

```text
.
├── docker-compose.yaml
├── Makefile
├── .env.example
└── db/
    ├── 01-setup.sql       # Ej.1: DB patientsdb + patients_user (DCL)
    ├── 02-schema.sql      # Ej.2: tabla patients (DDL)
    ├── 03-seed.sql        # Ej.3: INSERT 3 pacientes ISO (DML)
    ├── 04-queries.sql     # Ej.4: 4 SELECT (DQL: *, edad, >30, teléfono)
    ├── 05-update.sql      # Ej.5: John Doe -> birth_date 1994-05-15 (DML)
    ├── 06-delete.sql      # Ej.6: borra a Mike Brown (DML)
    └── 99-verify.sql      # smoke test Ej.1-Ej.6, estado final
```

Cada archivo lleva un header comentado `Qué / Cómo se ejecuta / Idempotente`
más la nota MySQL→Postgres cuando corresponde. El tipo de instrucción
(DCL/DDL/DML/DQL) va en el header; el nombre `NN-*.sql` sigue el número de
ejercicio (= orden de ejecución).

## Uso

```bash
cp .env.example .env
make up
make all        # setup → schema → seed → queries → update → delete → verify
make verify     # re-ejecutable, termina en NOTICE 'VERIFY OK'
make psql-app   # psql como patients_user
make reset      # down -v + up (limpio)
make down
```

Targets intermedios: `make setup schema seed queries update delete` (en orden).
`make queries` es solo lectura y puede correrse en cualquier punto para la demo.

## Trazabilidad (Consigna → Artefacto)

| Consigna | Objeto(s) | Artefacto |
|---|---|---|
| Ej.1 — DB + usuario + permisos (DCL) | `DATABASE patientsdb`, `ROLE patients_user` | [`db/01-setup.sql`](db/01-setup.sql) (`make setup`) |
| Ej.2 — Tabla patients (DDL) | `patients(id, first_name, last_name, birth_date, phone, email)` | [`db/02-schema.sql`](db/02-schema.sql) (`make schema`) |
| Ej.3 — INSERT 3 filas ISO (DML) | John Doe, Jane Smith, Mike Brown | [`db/03-seed.sql`](db/03-seed.sql) (`make seed`) |
| Ej.4.1 — SELECT total (DQL) | `SELECT *` | [`db/04-queries.sql`](db/04-queries.sql) (`make queries`) |
| Ej.4.2 — Nombre + edad (DQL) | `CONCAT` + `EXTRACT(YEAR FROM AGE(...))` | [`db/04-queries.sql`](db/04-queries.sql) (`make queries`) |
| Ej.4.3 — Edad > 30 (DQL) | `WHERE EXTRACT(...) > 30` (+ alternativa `INTERVAL`) | [`db/04-queries.sql`](db/04-queries.sql) (`make queries`) |
| Ej.4.4 — Por teléfono (DQL) | `WHERE phone = '123456789'` | [`db/04-queries.sql`](db/04-queries.sql) (`make queries`) |
| Ej.5 — UPDATE John por PK (DML) | `birth_date → '1994-05-15'` | [`db/05-update.sql`](db/05-update.sql) (`make update`) |
| Ej.6 — DELETE Mike por PK (DML) | borra 1 fila | [`db/06-delete.sql`](db/06-delete.sql) (`make delete`) |
| Verificación | estado final: 2 filas, John 1994-05-15, sin Mike (`VERIFY OK`) | [`db/99-verify.sql`](db/99-verify.sql) (`make verify`) |
| Entorno | contenedor Postgres 18 + interfaz | [`docker-compose.yaml`](docker-compose.yaml), [`Makefile`](Makefile) |

## Documentación del sistema

- [`docs/ER.md`](docs/ER.md) — decisiones, mapeo MySQL↔Postgres, edad como derivado
- [`docs/diagrams/patientsdb.puml`](docs/diagrams/patientsdb.puml) — fuente editable
- [`docs/diagrams/patientsdb.svg`](docs/diagrams/patientsdb.svg) — renderizado
- [`docs/GLOSSARY.md`](docs/GLOSSARY.md) — glosario PostgreSQL con equivalencias MySQL (solo términos usados en `db/`)

Re-renderizar diagrama:

```bash
plantuml -tsvg docs/diagrams/*.puml
```

## Decisiones

* **Solo Postgres ejecutable:** la consigna MySQL vive como referencia en `docs/ER.md` §3 y en los headers; `db/` corre en Postgres 18.
* **Edad derivada:** `TIMESTAMPDIFF(YEAR, birth_date, CURDATE())` ↔ `EXTRACT(YEAR FROM AGE(CURRENT_DATE, birth_date))::INT`. Nunca se almacena; `99-verify.sql` comprueba además la coherencia con la forma sargable `birth_date < CURRENT_DATE - INTERVAL '30 years'`.
* **PK por subselect:** Ej.5/6 resuelven el `id` con `SELECT id WHERE first_name AND last_name` en vez de hardcodear `1`/`3`; cumple "por clave primaria" y sobrevive a recargas del seed.
* **Cadena con mutaciones:** `03-seed.sql` deja las 3 filas originales; `05`/`06` mutan; `99-verify.sql` valida el estado final (2 filas). `make reset && make all` restaura desde cero.
* **`>30` fecha-dependiente:** el verify aserta pertenencia (John, 1994, siempre >30) y no conteos absolutos — Jane (1998) cruza los 30 en 2028.

## Autor

Lapenta Carlos Matías — Base de Datos

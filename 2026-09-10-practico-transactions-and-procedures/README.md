# Práctico 08 — Transactions and Procedures (Bibliotech)

Modelo AAA simplificado (`users`, `roles`, `users_roles`, `documents`, `log`) en **PostgreSQL 18** con Docker + GNU Make. Entorno aislado y reproducible para las Fases 1-4.

## Requisitos

Docker Engine + Docker Compose + GNU Make. El servicio expone `5433` para no chocar con otro Postgres local en `5432`.

## Estructura

```text
.
├── docker-compose.yaml
├── Makefile
├── .env.example
└── db/
    ├── 01-setup.sql       # C1: DB bibliotech + bibliotech_user
    ├── 02-schema.sql      # C2: tablas AAA (CASCADE docs / SET NULL logs)
    ├── 03-seed.sql        # C2: admin/professor/student + usuarios/docs
    ├── 04-auth.sql        # C3: sp_get_password_hash, sp_has_role
    ├── 05-upload.sql      # C4: sp_upload_document (transaccional + ROLLBACK)
    ├── 06-download.sql    # C5: sp_log_download
    ├── 07-maintenance.sql # C6: sp_delete_user + C7: sp_rename_document, sp_set_user_role
    ├── 08-reports.sql    # C8: v_prolific_professors, v_popular_documents + SPs
    ├── 09-soft-delete.sql # Fase 4: deleted_at + vistas activas + SPs
    └── 99-verify.sql      # smoke test C1-C8
```

## Uso

```bash
cp .env.example .env
make up
make all        # setup → schema → seed → procs → reports → soft-delete → verify
make verify     # re-ejecutable, termina en NOTICE 'VERIFY OK'
make psql-app   # psql como bibliotech_user
make reset      # down -v + up (limpio)
make down
```

## Trazabilidad (Consigna → Artefacto)

Base: [`2026-09-10-practico-transactions-and-procedures`](https://github.com/estebanmatias92/tecnicatura-base-de-datos/tree/main/2026-09-10-practico-transactions-and-procedures) · rama `main`.

| Consigna | Objeto(s) | Artefacto |
|---|---|---|
| C1 — DB + usuario | `DATABASE bibliotech`, `ROLE bibliotech_user` | [`db/01-setup.sql`](https://github.com/estebanmatias92/tecnicatura-base-de-datos/blob/main/2026-09-10-practico-transactions-and-procedures/db/01-setup.sql) (`make setup`) |
| C2 — Tablas AAA | `users`, `roles`, `users_roles`, `documents`, `log` | [`db/02-schema.sql`](https://github.com/estebanmatias92/tecnicatura-base-de-datos/blob/main/2026-09-10-practico-transactions-and-procedures/db/02-schema.sql) (`make schema`) |
| C2 — Roles + seed | `admin`, `professor`, `student` + usuarios/docs | [`db/03-seed.sql`](https://github.com/estebanmatias92/tecnicatura-base-de-datos/blob/main/2026-09-10-practico-transactions-and-procedures/db/03-seed.sql) (`make seed`) |
| C3a — Auth | `sp_get_password_hash(username)` | [`db/04-auth.sql`](https://github.com/estebanmatias92/tecnicatura-base-de-datos/blob/main/2026-09-10-practico-transactions-and-procedures/db/04-auth.sql) (`make procs`) |
| C3b — Auth | `sp_has_role(username, role)` | [`db/04-auth.sql`](https://github.com/estebanmatias92/tecnicatura-base-de-datos/blob/main/2026-09-10-practico-transactions-and-procedures/db/04-auth.sql) (`make procs`) |
| C4 — Upload tx | `sp_upload_document(...)` (ROLLBACK) | [`db/05-upload.sql`](https://github.com/estebanmatias92/tecnicatura-base-de-datos/blob/main/2026-09-10-practico-transactions-and-procedures/db/05-upload.sql) (`make procs`) |
| C5 — Descargas | `sp_log_download(username, document_id)` | [`db/06-download.sql`](https://github.com/estebanmatias92/tecnicatura-base-de-datos/blob/main/2026-09-10-practico-transactions-and-procedures/db/06-download.sql) (`make procs`) |
| C6 — Bajas | `sp_delete_user(username)` + FKs CASCADE/SET NULL | [`db/07-maintenance.sql`](https://github.com/estebanmatias92/tecnicatura-base-de-datos/blob/main/2026-09-10-practico-transactions-and-procedures/db/07-maintenance.sql) (`make procs`) |
| C7 — Updates | `sp_rename_document`, `sp_set_user_role` | [`db/07-maintenance.sql`](https://github.com/estebanmatias92/tecnicatura-base-de-datos/blob/main/2026-09-10-practico-transactions-and-procedures/db/07-maintenance.sql) (`make procs`) |
| C8a — Reporte | `v_prolific_professors`, `sp_report_prolific_professors` | [`db/08-reports.sql`](https://github.com/estebanmatias92/tecnicatura-base-de-datos/blob/main/2026-09-10-practico-transactions-and-procedures/db/08-reports.sql) (`make reports`) |
| C8b — Reporte | `v_popular_documents`, `sp_report_popular_documents` | [`db/08-reports.sql`](https://github.com/estebanmatias92/tecnicatura-base-de-datos/blob/main/2026-09-10-practico-transactions-and-procedures/db/08-reports.sql) (`make reports`) |
| Fase 4 — Soft delete | `deleted_at`, `v_active_*`, `sp_soft_delete_*`, `sp_restore_user` | [`db/09-soft-delete.sql`](https://github.com/estebanmatias92/tecnicatura-base-de-datos/blob/main/2026-09-10-practico-transactions-and-procedures/db/09-soft-delete.sql) (`make soft-delete`) |
| Verificación | smoke test C1–C8 (`VERIFY OK`) | [`db/99-verify.sql`](https://github.com/estebanmatias92/tecnicatura-base-de-datos/blob/main/2026-09-10-practico-transactions-and-procedures/db/99-verify.sql) (`make verify`) |
| Entorno | contenedor Postgres 18 + interfaz | [`docker-compose.yaml`](https://github.com/estebanmatias92/tecnicatura-base-de-datos/blob/main/2026-09-10-practico-transactions-and-procedures/docker-compose.yaml), [`Makefile`](https://github.com/estebanmatias92/tecnicatura-base-de-datos/blob/main/2026-09-10-practico-transactions-and-procedures/Makefile) |

## Decisiones

* **C6 didáctico:** `documents.owner_id ON DELETE CASCADE`, `log.* ON DELETE SET NULL`. En producción se usaría soft-delete (Fase 4) para no distorsionar la auditoría.
* **C4 atómico:** `INSERT documents` + `INSERT log UPLOAD` en un bloque con `EXCEPTION → ROLLBACK`.
* **C8:** vistas + funciones `sp_report_*` con `JOIN + GROUP BY + HAVING COUNT`.
* **Fase 4:** columnas `deleted_at` + `v_active_*` + `sp_soft_delete_*`; el borrado físico de C6 sigue disponible para la demo.

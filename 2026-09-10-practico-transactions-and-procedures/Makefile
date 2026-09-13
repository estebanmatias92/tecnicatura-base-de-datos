# Bibliotech — Transacciones y Procedimientos (Postgres 18)
include .env
export

CONTAINER = bibliotech_pg
HOST_PORT ?= 5433
APP_USER = bibliotech_user
APP_DB = bibliotech

SUPER_EXEC = docker exec -i $(CONTAINER) psql -U postgres -d postgres -v ON_ERROR_STOP=1 -q
APP_EXEC = docker exec -i $(CONTAINER) psql -U $(APP_USER) -d $(APP_DB) -v ON_ERROR_STOP=1 -q
APP_PASS = $(shell grep '^APP_USER_PASSWORD=' .env | cut -d= -f2)
SUPER_PASS = $(shell grep '^POSTGRES_PASSWORD=' .env | cut -d= -f2)

.PHONY: help up down logs psql psql-app setup schema seed procs reports soft-delete verify all reset

help:
	@echo "Uso: make [target]"
	@echo ""
	@echo "Infraestructura:"
	@echo "  up            Levanta Postgres 18 (puerto 5433) y espera healthy"
	@echo "  down          Detiene contenedores (conserva datos)"
	@echo "  reset         Borra volumen y reconstruye limpio"
	@echo "  logs          Muestra logs del servicio postgres"
	@echo ""
	@echo "Carga (en orden):"
	@echo "  setup         C1: crea DB bibliotech + usuario bibliotech_user"
	@echo "  schema        C2: crea tablas AAA"
	@echo "  seed          C2: roles admin/professor/student + datos de prueba"
	@echo "  procs         C3-C7: auth, upload, download, mantenimiento"
	@echo "  reports       C8: vistas y SPs de reportes"
	@echo "  soft-delete   Fase 4: variante con borrado logico"
	@echo "  verify        Smoke test C1-C8 (re-ejecutable)"
	@echo "  all           Cadena completa: setup -> verify"
	@echo ""
	@echo "Acceso:"
	@echo "  psql          psql como superusuario postgres"
	@echo "  psql-app      psql como bibliotech_user"

up:
	docker compose up -d
	@for i in $$(seq 1 60); do docker exec $(CONTAINER) pg_isready -U postgres >/dev/null 2>&1 && { echo "postgres healthy"; break; }; sleep 2; done

down:
	docker compose down

logs:
	docker compose logs -f postgres

psql:
	docker exec -it $(CONTAINER) psql -U postgres -d postgres

psql-app:
	PGPASSWORD=$(APP_PASS) docker exec -it $(CONTAINER) psql -U $(APP_USER) -d $(APP_DB)

setup:
	@echo "=> 01-setup (C1: DB + usuario)..."
	@sed "s/'bibliotech_pass'/'$(APP_PASS)'/" db/01-setup.sql | $(SUPER_EXEC)
	@PGPASSWORD=$(SUPER_PASS) docker exec -i $(CONTAINER) psql -U postgres -d $(APP_DB) -c "GRANT ALL ON SCHEMA public TO $(APP_USER); ALTER DATABASE $(APP_DB) OWNER TO $(APP_USER);" -q

schema:
	@echo "=> 02-schema (C2: tablas AAA)..."
	$(APP_EXEC) < db/02-schema.sql

seed:
	@echo "=> 03-seed (C2: roles + datos)..."
	$(APP_EXEC) < db/03-seed.sql

procs:
	@echo "=> 04-auth (C3) + 05-upload (C4) + 06-download (C5) + 07-maintenance (C6/C7)..."
	$(APP_EXEC) < db/04-auth.sql
	$(APP_EXEC) < db/05-upload.sql
	$(APP_EXEC) < db/06-download.sql
	$(APP_EXEC) < db/07-maintenance.sql

reports:
	@echo "=> 08-reports (C8)..."
	$(APP_EXEC) < db/08-reports.sql

soft-delete:
	@echo "=> 09-soft-delete (Fase 4)..."
	$(APP_EXEC) < db/09-soft-delete.sql

verify:
	@echo "=> 99-verify (C1-C8)..."
	$(APP_EXEC) < db/99-verify.sql

all: setup schema seed procs reports soft-delete verify

reset:
	docker compose down -v
	docker compose up -d
	@for i in $$(seq 1 60); do docker exec $(CONTAINER) pg_isready -U postgres >/dev/null 2>&1 && { echo "postgres healthy"; break; }; sleep 2; done

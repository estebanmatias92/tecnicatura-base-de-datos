# patientsdb — SQL Timestamp Function (Postgres 18)
include .env
export

CONTAINER = patientsdb_pg
HOST_PORT ?= 5433
APP_USER = patients_user
APP_DB = patientsdb

SUPER_EXEC = docker exec -i $(CONTAINER) psql -U postgres -d postgres -v ON_ERROR_STOP=1 -q
APP_EXEC = docker exec -i $(CONTAINER) psql -U $(APP_USER) -d $(APP_DB) -v ON_ERROR_STOP=1 -q
APP_PASS = $(shell grep '^APP_USER_PASSWORD=' .env | cut -d= -f2)
SUPER_PASS = $(shell grep '^POSTGRES_PASSWORD=' .env | cut -d= -f2)

.PHONY: help up down logs psql psql-app setup schema seed queries update delete verify all reset

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
	@echo "  setup         Ej.1: crea DB patientsdb + usuario patients_user (DCL)"
	@echo "  schema        Ej.2: crea tabla patients (DDL)"
	@echo "  seed          Ej.3: inserta 3 pacientes (DML)"
	@echo "  queries       Ej.4: 4 SELECT didácticos (DQL, solo lectura)"
	@echo "  update        Ej.5: John Doe -> birth_date 1994-05-15 (DML)"
	@echo "  delete        Ej.6: borra a Mike Brown (DML)"
	@echo "  verify        Smoke test Ej.1-Ej.6, estado final (re-ejecutable)"
	@echo "  all           Cadena completa: setup -> verify"
	@echo ""
	@echo "Acceso:"
	@echo "  psql          psql como superusuario postgres"
	@echo "  psql-app      psql como patients_user"

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
	@echo "=> 01-setup (Ej.1: DB + usuario)..."
	@sed "s/'patients_pass'/'$(APP_PASS)'/" db/01-setup.sql | $(SUPER_EXEC)
	@PGPASSWORD=$(SUPER_PASS) docker exec -i $(CONTAINER) psql -U postgres -d $(APP_DB) -c "GRANT ALL ON SCHEMA public TO $(APP_USER); ALTER DATABASE $(APP_DB) OWNER TO $(APP_USER);" -q

schema:
	@echo "=> 02-schema (Ej.2: tabla patients)..."
	$(APP_EXEC) < db/02-schema.sql

seed:
	@echo "=> 03-seed (Ej.3: 3 pacientes)..."
	$(APP_EXEC) < db/03-seed.sql

queries:
	@echo "=> 04-queries (Ej.4: 4 SELECT)..."
	$(APP_EXEC) < db/04-queries.sql

update:
	@echo "=> 05-update (Ej.5: John -> 1994-05-15)..."
	$(APP_EXEC) < db/05-update.sql

delete:
	@echo "=> 06-delete (Ej.6: borra a Mike)..."
	$(APP_EXEC) < db/06-delete.sql

verify:
	@echo "=> 99-verify (Ej.1-Ej.6, estado final)..."
	$(APP_EXEC) < db/99-verify.sql

all: setup schema seed queries update delete verify

reset:
	docker compose down -v
	docker compose up -d
	@for i in $$(seq 1 60); do docker exec $(CONTAINER) pg_isready -U postgres >/dev/null 2>&1 && { echo "postgres healthy"; break; }; sleep 2; done

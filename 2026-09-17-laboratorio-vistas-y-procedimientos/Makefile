# Laboratorio vistas, funciones y procedimientos (MariaDB 11)
-include .env
export

CONTAINER = lab_vistas_mariadb
APP_DB ?= sales_system_db
APP_USER ?= lab_user
APP_USER_PASSWORD ?= lab_pass
MARIADB_ROOT_PASSWORD ?= rootpass

APP_EXEC = docker exec -i $(CONTAINER) mariadb -u"$(APP_USER)" -p"$(APP_USER_PASSWORD)" "$(APP_DB)"
ROOT_EXEC = docker exec -i $(CONTAINER) mariadb -uroot -p"$(MARIADB_ROOT_PASSWORD)" "$(APP_DB)"

.DEFAULT_GOAL = help
.PHONY: help up down logs mysql mysql-root schema seed view function proc-simple proc-tx demos verify all reset

help:
	@echo "Uso: make [target]"
	@echo ""
	@echo "Infraestructura:"
	@echo "  up            Levanta MariaDB 11 (puerto 3307) y espera healthy"
	@echo "  down          Detiene contenedores (conserva datos)"
	@echo "  reset         Borra volumen y reconstruye limpio"
	@echo "  logs          Muestra logs del servicio mariadb"
	@echo ""
	@echo "Carga (en orden, cada ejemplo por separado):"
	@echo "  schema        01: tablas sales_system_db"
	@echo "  seed          02: datos mínimos (prod 2 stock 50, prod 1 stock 10)"
	@echo "  view          03: v_customer_order_summary"
	@echo "  function      04: fn_calculate_discount"
	@echo "  proc-simple   05: sp_register_product (IN/OUT)"
	@echo "  proc-tx       06: sp_process_order_transactional (tx + handler)"
	@echo "  demos         07: usos SELECT/CALL por concepto"
	@echo "  verify        99: 3 casos del apunte (asertivo, termina en VERIFY OK)"
	@echo "  all           Cadena completa: schema -> verify"
	@echo ""
	@echo "Acceso:"
	@echo "  mysql         Cliente como lab_user"
	@echo "  mysql-root    Cliente como root"

up:
	docker compose up -d
	@for i in $$(seq 1 60); do docker exec $(CONTAINER) mariadb -u"$(APP_USER)" -p"$(APP_USER_PASSWORD)" "$(APP_DB)" -e "SELECT 1" >/dev/null 2>&1 && { echo "mariadb healthy"; break; }; sleep 2; done

down:
	docker compose down

logs:
	docker compose logs -f mariadb

mysql:
	docker exec -it $(CONTAINER) mariadb -u"$(APP_USER)" -p"$(APP_USER_PASSWORD)" "$(APP_DB)"

mysql-root:
	docker exec -it $(CONTAINER) mariadb -uroot -p"$(MARIADB_ROOT_PASSWORD)" "$(APP_DB)"

schema:
	@echo "=> 01-schema (tablas sales_system_db)..."
	$(APP_EXEC) < db/01-schema.sql

seed:
	@echo "=> 02-seed (datos mínimos)..."
	$(APP_EXEC) < db/02-seed.sql

view:
	@echo "=> 03-view (v_customer_order_summary)..."
	$(APP_EXEC) < db/03-view.sql

function:
	@echo "=> 04-function (fn_calculate_discount)..."
	$(APP_EXEC) < db/04-function.sql

proc-simple:
	@echo "=> 05-proc-register (sp_register_product)..."
	$(APP_EXEC) < db/05-proc-register.sql

proc-tx:
	@echo "=> 06-proc-transactional (sp_process_order_transactional)..."
	$(APP_EXEC) < db/06-proc-transactional.sql

demos:
	@echo "=> 07-demos (usos por concepto)..."
	$(APP_EXEC) < db/07-demos.sql

verify:
	@echo "=> 99-verify (3 casos del apunte)..."
	$(APP_EXEC) < db/99-verify.sql

all: schema seed view function proc-simple proc-tx demos verify

reset:
	docker compose down -v
	docker compose up -d
	@for i in $$(seq 1 60); do docker exec $(CONTAINER) mariadb -u"$(APP_USER)" -p"$(APP_USER_PASSWORD)" "$(APP_DB)" -e "SELECT 1" >/dev/null 2>&1 && { echo "mariadb healthy"; break; }; sleep 2; done

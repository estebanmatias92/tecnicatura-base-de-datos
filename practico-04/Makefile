# Variables
CONTAINER_NAME = mysql_db
ROOT_EXEC = docker exec -i $(CONTAINER_NAME) mysql -u root -prootpassword -t
USER_EXEC = docker exec -i $(CONTAINER_NAME) mysql -u academic_admin -pSecurePass456 -D academic_ddeav_db -t

.PHONY: all setup schema seed alta queries

all: setup schema seed alta queries

setup:
	@echo "=> 01_setup: Creando base de datos y usuario..."
	$(ROOT_EXEC) < sql/01_setup.sql

schema:
	@echo "=> 02_schema: Creando tablas CTI + DDEAV..."
	$(USER_EXEC) < sql/02_schema.sql

seed:
	@echo "=> 03_seed: Poblando datos iniciales..."
	$(USER_EXEC) < sql/03_seed.sql

alta:
	@echo "=> 04_alta_opcion: Prototipo - alta de nueva opcion..."
	$(USER_EXEC) < sql/04_alta_opcion.sql

queries:
	@echo "=> 05_queries: Consultas de demostracion..."
	$(USER_EXEC) < sql/05_queries.sql

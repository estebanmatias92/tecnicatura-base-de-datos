# Variables
CONTAINER_NAME = mysql_db
ROOT_EXEC = docker exec -i $(CONTAINER_NAME) mysql -u root -prootpassword -t
USER_EXEC = docker exec -i $(CONTAINER_NAME) mysql -u clinic_admin -pSecurePass123 -D medical_clinic_db -t

.PHONY: all setup schema seed queries

all: setup schema seed queries

setup:
	@echo "=> Ejecutando Ejercicio 1: Setup..."
	$(ROOT_EXEC) < sql/01_setup.sql

schema:
	@echo "=> Ejecutando Ejercicio 2: Schema..."
	$(USER_EXEC) < sql/02_schema.sql

seed:
	@echo "=> Ejecutando Ejercicio 3: Seed..."
	$(USER_EXEC) < sql/03_seed.sql

queries:
	@echo "=> Ejecutando Ejercicio 4: Consultas..."
	$(USER_EXEC) < sql/04_queries.sql

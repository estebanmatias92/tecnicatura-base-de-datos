# Variables
CONTAINER_NAME = mysql_db
ROOT_EXEC = docker exec -i $(CONTAINER_NAME) mysql -u root -prootpassword -t
USER_EXEC = docker exec -i $(CONTAINER_NAME) mysql -u patients_user -pPatients123! -D patientsdb -t

.PHONY: all setup schema seed queries mutations

all: setup schema seed queries mutations

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

mutations:
	@echo "=> Ejecutando Ejercicios 5 y 6: Mutaciones..."
	$(USER_EXEC) < sql/05_mutations.sql
.PHONY: help up down restart mysql status logs seed test-joins test-exists test-null clean

help:
	@echo "Available commands:"
	@echo "  make up         - Start MySQL container"
	@echo "  make down       - Stop and remove container"
	@echo "  make restart    - Restart container"
	@echo "  make mysql      - Enter MySQL CLI"
	@echo "  make status     - Show container status"
	@echo "  make logs       - Show container logs"
	@echo "  make seed       - Run seed data scripts"
	@echo "  make test-joins - Test all JOIN types"
	@echo "  make test-exists- Test EXISTS vs IN patterns"
	@echo "  make test-null  - Test NULL handling patterns"
	@echo "  make clean      - Remove volumes and data"

up:
	docker-compose up -d
	@echo "Waiting for MySQL to be ready..."
	@sleep 5

down:
	docker-compose down

restart: down up

mysql:
	docker exec -it sql-joins-mysql mysql -u root -p${MYSQL_ROOT_PASSWORD} joins_db

status:
	docker-compose ps

logs:
	docker-compose logs -f mysql

seed:
	@echo "Running SQL initialization scripts..."
	@docker exec -i sql-joins-mysql mysql -u root -p${MYSQL_ROOT_PASSWORD} joins_db < sql/01-init.sql
	@echo "Seed complete!"

test-joins:
	@echo "Testing all JOIN types..."
	@docker exec -i sql-joins-mysql mysql -u root -p${MYSQL_ROOT_PASSWORD} joins_db < sql/02-joins.sql

test-exists:
	@echo "Testing EXISTS vs IN patterns..."
	@docker exec -i sql-joins-mysql mysql -u root -p${MYSQL_ROOT_PASSWORD} joins_db < sql/03-ejercicios.sql

test-null:
	@echo "Testing NULL handling patterns..."
	@docker exec -i sql-joins-mysql mysql -u root -p${MYSQL_ROOT_PASSWORD} joins_db < sql/04-null-handling.sql

clean:
	docker-compose down -v
	@echo "Volumes removed!"
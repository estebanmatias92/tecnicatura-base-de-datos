# SQL JOINs - Entorno de Prácticas

Entorno Docker con MySQL para practicar consultas JOIN, subqueries y manejo de NULL.

## Estructura

```
code/
├── docker-compose.yaml    # Configuración de MySQL
├── Makefile              # Comandos de gestión
├── .env                  # Variables de entorno
├── sql/
│   ├── 01-init.sql       # Schema y datos de ejemplo
│   ├── 02-joins.sql      # Consultas de prueba por tipo de JOIN
│   ├── 03-ejercicios.sql # Ejercicios teóricos (EXISTS, IN, NULL)
│   └── 04-null-handling.sql # Patrones de manejo de NULL
└── README.md
```

## Inicio Rápido

```bash
# Iniciar MySQL
make up

# Cargar datos iniciales
make seed

# Entrar al CLI de MySQL
make mysql

# Ejecutar consultas de prueba
make test-joins
make test-exists
make test-null
```

## Comandos Disponibles

| Comando | Descripción |
|---------|-------------|
| `make up` | Iniciar contenedor |
| `make down` | Detener contenedor |
| `make restart` | Reiniciar |
| `make mysql` | Abrir CLI de MySQL |
| `make status` | Ver estado del contenedor |
| `make logs` | Ver logs |
| `make seed` | Cargar schema y datos |
| `make test-joins` | Probar todos los JOINs |
| `make test-exists` | Probar EXISTS vs IN |
| `make test-null` | Probar patrones de NULL |
| `make clean` | Eliminar datos |

## Schema

- **users**: id, username, email, created_at
- **games**: id, title, genre, release_year, price
- **user_games**: id, user_id, game_id, hours_played, last_played (pivot table)

Los datos incluyen intentionally gaps para demostrar:
- LEFT JOIN: usuarios sin juegos
- NULLs: registros huérfanos
- RIGHT JOIN: juegos sin usuarios
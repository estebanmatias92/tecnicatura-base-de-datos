# ISFT 151 - Base de Datos: Guía TP N° 2 (Parte 02)

## Descripción

Resolución automatizada de la Guía de Trabajos Prácticos N° 2 (Parte 02) de la materia Base de Datos. El proyecto implementa la creación, manipulación y consulta de la base de datos `patientsdb` mediante scripts SQL separados por responsabilidad.

La ejecución se gestiona a través de una arquitectura basada en contenedores (Docker) y orquestada con GNU Make para garantizar un entorno reproducible, aislado y facilitar la captura secuencial de las salidas estándar (stdout).

## Requisitos Previos

Para ejecutar este proyecto, es necesario contar con las siguientes herramientas instaladas en el sistema anfitrión:

* [Docker Engine](https://docs.docker.com/engine/install/)
* [Docker Compose](https://docs.docker.com/compose/install/)
* GNU Make

## Estructura del Proyecto

```text
.
├── docker-compose.yaml     # Definición del servicio MySQL 8.0
├── Makefile                # Orquestador de comandos de ejecución
└── sql/
    ├── 01_setup.sql        # DDL/DCL: Creación de BD y configuración de usuario
    ├── 02_schema.sql       # DDL: Definición de la tabla Patients y restricciones
    ├── 03_seed.sql         # DML: Población inicial de la tabla
    ├── 04_queries.sql      # DQL: Consultas de selección y filtrado
    └── 05_mutations.sql    # DML: Actualización y eliminación de registros

```

## Flujo de Ejecución

1. **Inicializar la infraestructura:**
Levantar el contenedor de MySQL en segundo plano.

```bash
docker compose up -d

```

*Nota: Aguardar aproximadamente 10-15 segundos hasta que el estado del contenedor figure como `healthy` antes de proceder al siguiente paso.*
2. **Ejecución secuencial de los ejercicios:**
Los siguientes comandos inyectan los scripts SQL directamente al contenedor y renderizan la salida en formato de tabla para su verificación.

* **Ejercicio 1:** Creación de base de datos, usuario y permisos.

```bash
make setup

```

* **Ejercicio 2:** Creación de la estructura (Tabla `Patients`).

```bash
make schema

```

* **Ejercicio 3:** Inserción de los registros iniciales.

```bash
make seed

```

* **Ejercicio 4:** Consultas `SELECT` solicitadas por la guía.

```bash
make queries

```

* **Ejercicios 5 y 6:** Modificaciones de estado (`UPDATE` y `DELETE`).

```bash
make mutations

```

*Alternativa:* Se puede ejecutar la suite completa de forma secuencial utilizando el comando `make all`.

## Limpieza del Entorno

Una vez finalizada la tarea y tomadas las capturas correspondientes, destruir el contenedor y su volumen persistente asociado para mantener el entorno limpio:

```bash
docker compose down -v

```

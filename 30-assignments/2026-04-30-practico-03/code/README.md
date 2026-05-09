# ISFT 151 - Base de Datos: Guía TP N° 3

## Descripción

Resolución automatizada de la Guía de Trabajos Prácticos N° 3 de la materia Base de Datos. El proyecto implementa la creación, manipulación y consulta de la base de datos `medical_clinic_db` mediante scripts SQL segregados por responsabilidad en el ciclo de vida de los datos.

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
    ├── 01_setup.sql        # DDL/DCL: Creación de BD, usuario (clinic_admin) y permisos
    ├── 02_schema.sql       # DDL: Definición de tablas, relaciones y restricciones
    ├── 03_seed.sql         # DML: Población inicial de pacientes, médicos, citas y tratamientos
    └── 04_queries.sql      # DQL: Consultas de selección y filtrado relacional

```

## Flujo de Ejecución

### 1. Inicializar la infraestructura

Levantar el contenedor de MySQL en segundo plano.

```bash
docker compose up -d

```

*Nota: Aguardar aproximadamente 10-15 segundos hasta que el estado del contenedor figure como `healthy` antes de proceder al siguiente paso.*

### 2. Ejecución secuencial de los ejercicios

Los siguientes comandos inyectan los scripts SQL directamente al contenedor (`mysql_db`) y renderizan la salida en formato tabular para su verificación.

* **Ejercicio 1:** Creación de la base de datos y configuración de credenciales.

```bash
make setup

```

* **Ejercicio 2:** Creación de la estructura relacional (Tablas `Patients`, `Doctors`, `Appointments` y `Treatments`).

```bash
make schema

```

* **Ejercicio 3:** Inserción de los registros iniciales definidos en la guía.

```bash
make seed

```

* **Ejercicio 4:** Ejecución de las sentencias de recuperación y filtrado de datos.

```bash
make queries

```

*Alternativa:* Se puede ejecutar la suite de scripts completa de forma secuencial utilizando el comando unificado:

```bash
make all

```

## Limpieza del Entorno

Una vez finalizada la tarea y capturadas las evidencias correspondientes, se debe destruir el contenedor y el volumen persistente (`mysql_data`) para mantener el sistema anfitrión limpio:

```bash
docker compose down -v

```

```

```

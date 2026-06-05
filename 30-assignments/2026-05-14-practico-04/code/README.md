# ISFT 151 - Base de Datos: Laboratorio 04 - Modelo Relacional Adaptativo

## Descripción

Implementación del patrón **Dictionary-Driven Entity-Attribute-Value (DDEAV)**
combinado con **Class-Table Inheritance (CTI)** (Fowler, *Patterns of Enterprise
Application Architecture*) y soft-delete lógico, aplicado al dominio educativo.

El modelo permite que los atributos de entidades como `Course`, `Student` y
`Teacher` evolucionen ante cambios regulatorios (ej: nuevas modalidades de
cursada, programas de becas, ajustes curriculares) **sin necesidad de ALTER
TABLE** — todo se resuelve insertando datos en catálogos (`OptionGroup`,
`OptionValue`) y asignándolos mediante tablas puente (`EntityUniqueOption`,
`EntityMultipleOption`).

La ejecución se gestiona a través de una arquitectura basada en contenedores
(Docker) y orquestada con GNU Make para garantizar un entorno reproducible y
aislado.

### Modelo Dictionary-Driven EAV (DDEAV)

```plantuml
@startuml
hide circle
skinparam linetype ortho

' --- Core Entity ---
entity "Entity" {
  * ID : int <<PK>>
  --
  Active : bit <<default(0)>>
  EntityType : varchar
}

' --- DDEAV tables ---
entity "OptionGroup" {
  * ID : int <<PK>>
  --
  Active : tinyint <<default(1)>>
  Name : varchar
}

entity "OptionValue" {
  * ID : int <<PK>>
  --
  Active : tinyint <<default(1)>>
  Value : varchar
}

entity "ValidOption" {
  * ID : int <<PK>>
  --
  OptionValueID : int <<FK>> <<UNIQUE1>>
  OptionGroupID : int <<FK>> <<UNIQUE1>>
}

entity "EntityUniqueOption" {
  EntityID : int <<FK1>> <<UNIQUE1>>
  ValidOptionID : int <<FK2>>
  OptionGroupID : int <<FK2>> <<UNIQUE1>>
}

entity "EntityMultipleOption" {
  EntityID : int <<FK>> <<UNIQUE1>>
  ValidOptionID : int <<FK>> <<UNIQUE1>>
}

' ==========================================
' RELATIONSHIPS
' ==========================================

Entity ||--o{ EntityUniqueOption : "1 to n"
Entity ||--o{ EntityMultipleOption : "1 to n"

OptionGroup ||--o{ ValidOption : "1 to n"
OptionGroup ||--o{ EntityUniqueOption : "1 to n"
OptionValue ||--o{ ValidOption : "1 to n"
ValidOption ||--o{ EntityUniqueOption : "1 to n"
ValidOption ||--o{ EntityMultipleOption : "1 to n"

@enduml
```

### DDEAV + Class-Table Inheritance (CTI)

```plantuml
@startuml
hide circle
skinparam linetype ortho

' --- Core Entity ---
entity "Entity" {
  * ID : int <<PK>>
  --
  Active : bit <<default(0)>>
}

' --- Subtypes (concrete entities) ---
entity "Student" {
  * ID : int <<PK>>
  --
  EntityID : int <<FK>> <<unique>>
  FullName : varchar
  Email : varchar
  Phone : varchar
}

entity "Course" {
  * ID : int <<PK>>
  --
  EntityID : int <<FK>> <<unique>>
  Name : varchar
  StartDate : date
  EndDate : date
  MaxCapacity : int
}

entity "Teacher" {
  * ID : int <<PK>>
  --
  EntityID : int <<FK>> <<unique>>
  FullName : varchar
  Email : varchar
  Specialization : varchar
}

' --- DDEAV tables ---
entity "OptionGroup" {
  * ID : int <<PK>>
  --
  Active : tinyint <<default(1)>>
  Name : varchar
}

entity "OptionValue" {
  * ID : int <<PK>>
  --
  Active : tinyint <<default(1)>>
  Value : varchar
}

entity "ValidOption" {
  * ID : int <<PK>>
  --
  OptionValueID : int <<FK>> <<UNIQUE1>>
  OptionGroupID : int <<FK>> <<UNIQUE1>>
}

entity "EntityUniqueOption" {
  EntityID : int <<FK1>> <<UNIQUE1>>
  ValidOptionID : int <<FK2>>
  OptionGroupID : int <<FK2>> <<UNIQUE1>>
}

entity "EntityMultipleOption" {
  EntityID : int <<FK>> <<UNIQUE1>>
  ValidOptionID : int <<FK>> <<UNIQUE1>>
}

' ========================================
' RELATIONSHIPS
' ========================================

' --- CTI: Subtypes ---
Student |o--|| Entity : "Student.EntityID = Entity.ID"
Course |o--|| Entity : "Course.EntityID = Entity.ID"
Teacher |o--|| Entity : "Teacher.EntityID = Entity.ID"

' --- DDEAV ---
Entity ||--o{ EntityUniqueOption : "1 to n"
Entity ||--o{ EntityMultipleOption : "1 to n"

OptionGroup ||--o{ ValidOption : "1 to n"
OptionGroup ||--o{ EntityUniqueOption : "1 to n"

OptionValue ||--o{ ValidOption : "1 to n"

ValidOption ||--o{ EntityUniqueOption : "1 to n"
ValidOption ||--o{ EntityMultipleOption : "1 to n"

@enduml
```

## Requisitos Previos

* [Docker Engine](https://docs.docker.com/engine/install/)
* [Docker Compose](https://docs.docker.com/compose/install/)
* GNU Make

## Estructura del Proyecto

```text
.
├── docker-compose.yaml     # Servicio MySQL 8.0
├── Makefile                # Orquestador de scripts
└── sql/
    ├── 01_setup.sql        # DCL: Creación de DB (academic_ddeav_db) y usuario
    ├── 02_schema.sql       # DDL: CTI (Entity, Student, Course, Teacher) + DDEAV
    ├── 03_seed.sql         # DML: Población inicial (escenario 2009)
    ├── 04_alta_opcion.sql  # DML: Prototipo — alta de nueva opción (Consigna 2)
    └── 05_queries.sql      # DQL: Consultas de demostración
```

## Flujo de Ejecución

### 1. Inicializar la infraestructura

```bash
docker compose up -d
```

*Nota: Aguardar aproximadamente 10-15 segundos hasta que el estado del
contenedor figure como `healthy` antes de proceder.*

### 2. Ejecución secuencial

* **Setup** — Creación de la base de datos y credenciales:

  ```bash
  make setup
  ```

* **Schema** — Tablas CTI (Entity, Student, Course, Teacher) + DDEAV
  (OptionGroup, OptionValue, ValidOption, EntityUniqueOption,
  EntityMultipleOption):

  ```bash
  make schema
  ```

* **Seed** — Población inicial: entidades educativas y catálogo con modalidad
  "Presencialidad Plena":

  ```bash
  make seed
  ```

* **Alta de opción (prototipo)** — Registro de "Propuesta Pedagógica Combinada"
  y asignación a un curso existente:

  ```bash
  make alta
  ```

* **Consultas** — Demostración de recuperación de datos desde el modelo DDEAV:

  ```bash
  make queries
  ```

*Alternativa:* Ejecutar la suite completa de forma secuencial:

```bash
make all
```

## Limpieza del Entorno

Una vez finalizada la tarea y capturadas las evidencias correspondientes:

```bash
docker compose down -v
```

## Referencias

- **Fowler, M. (2003)**. *Patterns of Enterprise Application Architecture*.
  Addison-Wesley. — Patrón Class-Table Inheritance (CTI).
- **Entity–Attribute–Value model** — Wikipedia.
  [enlace](https://en.wikipedia.org/wiki/Entity%E2%80%93attribute%E2%80%93value_model)

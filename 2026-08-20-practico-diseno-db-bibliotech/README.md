# Bibliotech v4 — Diseño DB (Postgres)

> Biblioteca digital para sociedad de fomento e institución educativa. Núcleo 3FN + DDEAV acotado, rol único por user.

## Stack Tecnológico

- **Lenguaje:** SQL (PostgreSQL 18)
- **Frameworks:** ninguno
- **Base de datos:** PostgreSQL (`citext`, identidades, FK compuestas, índices parciales a futuro)
- **Entorno:** `psql` + PlantUML

## Documentación del sistema

- [`docs/ER.md`](docs/ER.md) — decisiones, fijo vs DDEAV, consultas clave
- [`docs/diagrams/bibliotech.puml`](docs/diagrams/bibliotech.puml) — fuente editable
- [`docs/diagrams/bibliotech.svg`](docs/diagrams/bibliotech.svg) — renderizado

## Arquitectura

![Diagrama ER](docs/diagrams/bibliotech.svg)

Tablas canónicas de roles: `user_has_unique_roles` (app) + `user_has_many_roles` (stub expansión).
Recursos con CTI, subjects en árbol, DDEAV solo metadatos discretos.

## Scaffolding

```
code/
├── 01-schema.sql
├── 02-seed.sql
├── 03-views-functions.sql
├── docs/
│   ├── ER.md
│   └── diagrams/
│       ├── bibliotech.puml
│       └── bibliotech.svg
└── README.md
```

## Setup y ejecución

```bash
psql -d bibliotech -f code/01-schema.sql
psql -d bibliotech -f code/02-seed.sql
psql -d bibliotech -f code/03-views-functions.sql
```

Re-renderizar diagrama:

```bash
plantuml -tsvg code/docs/diagrams/*.puml
```

## Autor

Lapenta Carlos Matías — Base de Datos

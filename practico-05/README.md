# Base de Datos — Trabajo Práctico 06: Normalización DB

**Materia:** Base de Datos  
**Unidad:** 02  
**Profesor:** Gabriel Nicolás Gonzáles Ferreira  
**Estudiante:** Lapenta Carlos Matías  
**Fecha de entrega:** 2026-07-09

## Descripción

Práctica de modelado y normalización de bases de datos relacionales sobre dos dominios:
entidades bancarias y facturación (Factura B).

Cada consigna está autocontenida en un script SQL que crea la base de datos `practica-db`,
el usuario con permisos CRUD, las tablas con sus constraints, y datos de semilla.

## Archivos

### `sql/consigna-01-init.sql`

- **Propósito:** Crear la base de datos `practica-db` con encoding UTF8 Unicode CI y las tablas
  del modelo bancario.
- **Entidades:** `clients`, `bank_accounts`, `transaction_types`, `transactions`
- **Secciones:** Database, User (DCL), Schema (DDL), Constraints, Seed Data (DML)

### `sql/consigna-02-init.sql`

- **Propósito:** Misma base de datos `practica-db`, mismo usuario, y las tablas del modelo de
  Factura B.
- **Entidades:** `customers`, `invoices`, `invoice_lines`
- **Secciones:** Database, User (DCL), Schema (DDL), Constraints, Seed Data (DML)

## Ejecución

Ejecutar en orden con MySQL / MariaDB desde la raíz del proyecto:

```bash
mysql -u root -p < sql/consigna-01-init.sql
mysql -u root -p < sql/consigna-02-init.sql
```

O copiar-pegar cada archivo en la consola SQL de Adminer.

**Nota:** Cada script es autocontenido: ejecuta `DROP DATABASE IF EXISTS` al inicio, por lo
que `consigna-02-init.sql` pisará los datos de `consigna-01-init.sql`. Si se desea mantener
ambos modelos en la misma base de datos, deben fusionarse manualmente en un solo script.

## Convenciones

- Motor: MySQL / MariaDB
- Charset: `utf8mb4` — Collation: `utf8mb4_unicode_ci`
- Nombres de tablas y columnas en inglés (snake_case)
- Claves foráneas con `ON UPDATE CASCADE`; `ON DELETE RESTRICT` o `CASCADE` según corresponda

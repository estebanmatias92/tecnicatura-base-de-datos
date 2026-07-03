# Laboratorio Extra — Bases de Datos

> Construyan el archivo `docker-compose.yml` para montar un servidor de MongoDB.
> Investiguen si pueden usar un cliente gráfico con esta base de datos NoSQL.

---

## Stack SQL — MariaDB + Adminer

**Demostración en terminal:** ![▶️ Ver GIF](sql/demo.gif)

| Captura | Descripción |
|---|---|
| ![Adminer login](sql/screenshot-2026-07-03_02-57-40.png) | Pantalla de login de Adminer |
| ![Adminer dashboard](sql/screenshot-2026-07-03_02-58-10.png) | Dashboard autenticado — base `test` |

```bash
cd sql
docker compose up -d
docker compose ps
curl http://localhost:8080
```

---

## Stack NoSQL — MongoDB + Mongo Express

**Demostración en terminal:** ![▶️ Ver GIF](nosql/demo.gif)

| Captura | Descripción |
|---|---|
| ![Mongo Express dashboard](nosql/screenshot-2026-07-03_03-20-53.png) | Mongo Express — bases `admin`, `config`, `local` |

```bash
cd nosql
docker compose up -d
docker compose ps
curl http://localhost:8081
```

---

**Credenciales compartidas:** usuario `test`, contraseña `test`, base de datos `test`.

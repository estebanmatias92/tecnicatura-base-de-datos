# Arquitectura orientada a objetos en Python: dominio independiente del ORM

Ejemplo didáctico ejecutable con Python 3.12+ y SQLAlchemy 2.x.

## Qué demuestra

- `Protocol` como contrato de interfaz (tipado estructural).
- Entidades con comportamiento y un Value Object inmutable.
- Repository Pattern y Unit of Work.
- Inyección de dependencias.
- Mapeo imperativo de SQLAlchemy: el dominio no importa SQLAlchemy.
- Pruebas unitarias con dobles en memoria y una prueba de integración con SQLite.

## Requisitos

Python 3.12 o superior recomendado.

## Instalación y ejecución

En una terminal, dentro de esta carpeta:

```bash
python -m venv .venv
```

Activar el entorno:

- Windows PowerShell: `.venv\\Scripts\\Activate.ps1`
- macOS/Linux: `source .venv/bin/activate`

Instalar dependencias:

```bash
python -m pip install -r requirements.txt
```

Ejecutar la demostración:

```bash
python -m app.main
```

Se crea `customers.db` en la carpeta actual.

Ejecutar las pruebas:

```bash
python -m pytest -v
```

## Recorrido sugerido para la clase

1. Abrir `app/domain/` y comprobar que no hay imports de SQLAlchemy.
2. Leer `CustomerRepository` y `UnitOfWork`: son contratos definidos por la aplicación/dominio.
3. Leer `app/infrastructure/persistence/mapping.py`: el mapeo se configura fuera de la entidad.
4. Leer `SqlAlchemyUnitOfWork`: implementa el contrato usando una sesión.
5. Leer `RegisterCustomer`: el caso de uso depende de la abstracción, no de la implementación concreta.
6. Ejecutar las pruebas. La prueba unitaria utiliza un Fake sin base de datos; la de integración usa SQLite.

## Idea clave

`Protocol` permite tipado estructural: una clase cumple el contrato si ofrece los métodos compatibles, aunque no herede explícitamente de ese Protocol. Mypy o Pyright pueden comprobarlo estáticamente. No es una comprobación automática completa en tiempo de ejecución.

El mapeo imperativo de SQLAlchemy separa la clase de dominio de las clases base/decoradores del ORM. La infraestructura configura cómo se persiste la entidad.

Este ejemplo es intencionalmente pequeño para facilitar su explicación. En una aplicación real habría que añadir, entre otras cosas, manejo de errores de aplicación, transacciones más elaboradas, migraciones con Alembic, logging y reglas de autorización.

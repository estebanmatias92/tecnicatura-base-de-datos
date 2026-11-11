from sqlalchemy import Column, Integer, MetaData, String, Table
from sqlalchemy.orm import composite, registry

from app.domain.entities.customer import Customer
from app.domain.value_objects.email import Email

mapper_registry = registry()
metadata: MetaData = mapper_registry.metadata

customers_table = Table(
    "customers",
    metadata,
    Column("id", Integer, primary_key=True, autoincrement=True),
    Column("name", String(120), nullable=False),
    Column("email", String(254), nullable=False, unique=True),
)

# Mapeo imperativo: la entidad no hereda de una clase del ORM ni usa decoradores.
mapper_registry.map_imperatively(
    Customer,
    customers_table,
    properties={
        "_name": customers_table.c.name,
        "email_column": customers_table.c.email,
        "_email": composite(Email, customers_table.c.email),
    },
)

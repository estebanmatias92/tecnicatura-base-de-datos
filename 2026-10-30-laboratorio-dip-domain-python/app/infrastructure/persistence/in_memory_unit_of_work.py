from app.domain.repositories.customer_repository import CustomerRepository
from app.infrastructure.persistence.in_memory_customer_repository import (
    InMemoryCustomerRepository,
)


class InMemoryUnitOfWork:
    """Implementación en memoria de UnitOfWork (sin base de datos)."""

    def __init__(self) -> None:
        self.customers: CustomerRepository = InMemoryCustomerRepository()
        self.committed = False

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_value, traceback) -> None:
        if exc_type is not None:
            self.rollback()

    def commit(self) -> None:
        self.committed = True

    def rollback(self) -> None:
        self.committed = False

from typing import Protocol

from app.domain.repositories.customer_repository import CustomerRepository


class UnitOfWork(Protocol):
    """Define el límite transaccional sin acoplarlo a un ORM concreto."""

    customers: CustomerRepository

    def __enter__(self) -> "UnitOfWork": ...

    def __exit__(self, exc_type, exc_value, traceback) -> None: ...

    def commit(self) -> None: ...

    def rollback(self) -> None: ...

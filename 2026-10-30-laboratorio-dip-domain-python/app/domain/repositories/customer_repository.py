from typing import Protocol

from app.domain.entities.customer import Customer


class CustomerRepository(Protocol):
    """Puerto: contrato de persistencia visto por la aplicación."""

    def add(self, customer: Customer) -> None: ...

    def get_by_id(self, customer_id: int) -> Customer | None: ...

    def list_all(self) -> list[Customer]: ...

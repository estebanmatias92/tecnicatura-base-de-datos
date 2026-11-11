from app.domain.entities.customer import Customer
from app.domain.repositories.customer_repository import CustomerRepository


class InMemoryCustomerRepository(CustomerRepository):
    """Adaptador en memoria del puerto CustomerRepository (sin base de datos)."""

    def __init__(self) -> None:
        self.items: list[Customer] = []

    def add(self, customer: Customer) -> None:
        customer.id = len(self.items) + 1
        self.items.append(customer)

    def get_by_id(self, customer_id: int) -> Customer | None:
        return next((item for item in self.items if item.id == customer_id), None)

    def list_all(self) -> list[Customer]:
        return list(self.items)

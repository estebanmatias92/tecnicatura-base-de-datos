from app.application.use_cases.register_customer import RegisterCustomer
from app.domain.entities.customer import Customer
from app.domain.value_objects.email import Email


class InMemoryCustomerRepository:
    """Fake: implementa el contrato sin heredar de Protocol."""

    def __init__(self) -> None:
        self.items: list[Customer] = []

    def add(self, customer: Customer) -> None:
        customer.id = len(self.items) + 1
        self.items.append(customer)

    def get_by_id(self, customer_id: int) -> Customer | None:
        return next((item for item in self.items if item.id == customer_id), None)

    def list_all(self) -> list[Customer]:
        return list(self.items)


class InMemoryUnitOfWork:
    def __init__(self) -> None:
        self.customers = InMemoryCustomerRepository()
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


def test_register_customer_without_database() -> None:
    uow = InMemoryUnitOfWork()
    use_case = RegisterCustomer(uow)

    customer = use_case.execute("Grace Hopper", "GRACE@EXAMPLE.COM")

    assert customer.name == "Grace Hopper"
    assert customer.email == Email("grace@example.com")
    assert customer.id == 1
    assert uow.committed is True

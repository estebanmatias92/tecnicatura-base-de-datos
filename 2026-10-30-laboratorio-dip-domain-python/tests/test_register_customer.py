from app.application.use_cases.register_customer import RegisterCustomer
from app.domain.value_objects.email import Email
from app.infrastructure.persistence.in_memory_unit_of_work import InMemoryUnitOfWork


def test_register_customer_without_database() -> None:
    uow = InMemoryUnitOfWork()
    use_case = RegisterCustomer(uow)

    customer = use_case.execute("Grace Hopper", "GRACE@EXAMPLE.COM")

    assert customer.name == "Grace Hopper"
    assert customer.email == Email("grace@example.com")
    assert customer.id == 1
    assert uow.committed is True

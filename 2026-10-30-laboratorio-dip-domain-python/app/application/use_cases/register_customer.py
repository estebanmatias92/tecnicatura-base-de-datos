from app.domain.entities.customer import Customer
from app.domain.unit_of_work import UnitOfWork
from app.domain.value_objects.email import Email


class RegisterCustomer:
    """Caso de uso: depende de un contrato, no de SQLAlchemy."""

    def __init__(self, uow: UnitOfWork) -> None:
        self._uow = uow

    def execute(self, name: str, email_address: str) -> Customer:
        customer = Customer(name=name, email=Email(email_address))

        with self._uow as uow:
            uow.customers.add(customer)
            uow.commit()

        return customer

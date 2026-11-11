from sqlalchemy import select
from sqlalchemy.orm import Session

from app.domain.entities.customer import Customer
from app.domain.repositories.customer_repository import CustomerRepository
from app.infrastructure.persistence.mapping import customers_table


class SqlAlchemyCustomerRepository(CustomerRepository):
    """Adaptador concreto del puerto CustomerRepository."""

    def __init__(self, session: Session) -> None:
        self._session = session

    def add(self, customer: Customer) -> None:
        self._session.add(customer)

    def get_by_id(self, customer_id: int) -> Customer | None:
        return self._session.get(Customer, customer_id)

    def list_all(self) -> list[Customer]:
        statement = select(Customer).order_by(customers_table.c.id)
        return list(self._session.scalars(statement).all())

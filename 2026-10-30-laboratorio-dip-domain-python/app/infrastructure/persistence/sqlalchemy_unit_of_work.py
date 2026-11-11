from sqlalchemy.orm import sessionmaker

from app.domain.repositories.customer_repository import CustomerRepository
from app.infrastructure.persistence.sqlalchemy_customer_repository import (
    SqlAlchemyCustomerRepository,
)


class SqlAlchemyUnitOfWork:
    """Implementación de UnitOfWork usando sesiones de SQLAlchemy."""

    def __init__(self, session_factory: sessionmaker) -> None:
        self._session_factory = session_factory
        self.session = None
        self.customers: CustomerRepository

    def __enter__(self):
        self.session = self._session_factory()
        self.customers = SqlAlchemyCustomerRepository(self.session)
        return self

    def __exit__(self, exc_type, exc_value, traceback) -> None:
        try:
            if exc_type is not None:
                self.rollback()
        finally:
            if self.session is not None:
                self.session.close()

    def commit(self) -> None:
        if self.session is None:
            raise RuntimeError("UnitOfWork debe abrirse antes de hacer commit.")
        self.session.commit()

    def rollback(self) -> None:
        if self.session is not None:
            self.session.rollback()

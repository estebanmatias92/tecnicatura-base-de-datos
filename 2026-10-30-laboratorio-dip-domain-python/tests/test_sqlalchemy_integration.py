from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.application.use_cases.register_customer import RegisterCustomer
from app.infrastructure.persistence.mapping import metadata
from app.infrastructure.persistence.sqlalchemy_unit_of_work import (
    SqlAlchemyUnitOfWork,
)


def test_customer_round_trip_with_sqlite() -> None:
    engine = create_engine("sqlite://")
    metadata.create_all(engine)
    factory = sessionmaker(bind=engine, expire_on_commit=False)
    uow = SqlAlchemyUnitOfWork(factory)

    created = RegisterCustomer(uow).execute("Katherine Johnson", "kj@example.com")

    with uow as work:
        loaded = work.customers.get_by_id(created.id)

    assert loaded is not None
    assert loaded.name == "Katherine Johnson"
    assert str(loaded.email) == "kj@example.com"
    engine.dispose()

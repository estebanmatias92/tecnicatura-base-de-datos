from app.application.use_cases.register_customer import RegisterCustomer
from app.infrastructure.database import build_session_factory
from app.infrastructure.persistence.sqlalchemy_unit_of_work import (
    SqlAlchemyUnitOfWork,
)


def main() -> None:
    session_factory = build_session_factory()
    uow = SqlAlchemyUnitOfWork(session_factory)

    register_customer = RegisterCustomer(uow)
    customer = register_customer.execute(
        name="Ada Lovelace",
        email_address="ADA@example.com",
    )

    print("Cliente registrado:")
    print(customer)

    with uow as work:
        print("\\nClientes almacenados:")
        for item in work.customers.list_all():
            print(item)


if __name__ == "__main__":
    main()

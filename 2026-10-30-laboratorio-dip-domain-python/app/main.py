import sys

from app.application.use_cases.register_customer import RegisterCustomer
from app.infrastructure.database import build_session_factory
from app.infrastructure.persistence.in_memory_unit_of_work import (
    InMemoryUnitOfWork,
)
from app.infrastructure.persistence.sqlalchemy_unit_of_work import (
    SqlAlchemyUnitOfWork,
)


def main() -> None:
    backend = sys.argv[1] if len(sys.argv) > 1 else "sqlite"

    if backend == "sqlite":
        print("Backend: sqlite (customers.db)")
        session_factory = build_session_factory()
        uow = SqlAlchemyUnitOfWork(session_factory)
    elif backend == "memory":
        print("Backend: memory (sin base de datos)")
        uow = InMemoryUnitOfWork()
    else:
        raise SystemExit(
            f"Backend desconocido: {backend!r} (usar 'sqlite' o 'memory')"
        )

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

from app.domain.value_objects.email import Email


class Customer:
    """Entidad de dominio. No conoce SQLAlchemy ni la base de datos."""

    def __init__(self, name: str, email: Email) -> None:
        self.id: int | None = None
        self._name = ""
        self._email = email
        self.rename(name)

    @property
    def name(self) -> str:
        return self._name

    @property
    def email(self) -> Email:
        return self._email

    def rename(self, new_name: str) -> None:
        normalized = new_name.strip()
        if len(normalized) < 2:
            raise ValueError("El nombre debe tener al menos dos caracteres.")
        self._name = normalized

    def change_email(self, new_email: Email) -> None:
        self._email = new_email

    def __repr__(self) -> str:
        return (
            f"Customer(id={self.id!r}, name={self.name!r}, "
            f"email={str(self.email)!r})"
        )

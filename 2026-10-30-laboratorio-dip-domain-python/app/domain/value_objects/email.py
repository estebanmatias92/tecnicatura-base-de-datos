from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class Email:
    """Value Object: inmutable y validado al construirse."""

    address: str

    def __post_init__(self) -> None:
        normalized = self.address.strip().lower()
        if "@" not in normalized or normalized.startswith("@") or normalized.endswith("@"):
            raise ValueError(f"Dirección de email inválida: {self.address!r}")
        object.__setattr__(self, "address", normalized)

    def __str__(self) -> str:
        return self.address

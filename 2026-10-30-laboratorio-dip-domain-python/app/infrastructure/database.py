from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.infrastructure.persistence.mapping import metadata


def build_session_factory(database_url: str = "sqlite:///customers.db"):
    engine = create_engine(database_url, echo=False)
    metadata.create_all(engine)
    return sessionmaker(bind=engine, expire_on_commit=False)

from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase, sessionmaker
from sqlalchemy.pool import StaticPool

from .config import settings

is_sqlite = settings.database_url.startswith("sqlite")
is_sqlite_memory = settings.database_url in ("sqlite:///:memory:", "sqlite://")
is_pg8000 = settings.database_url.startswith("postgresql+pg8000")
# pg8000 (pure Python, no compiled extension — see backend/README.md's
# "Why pg8000" note) needs an explicit SSL context; Supabase's Postgres
# requires SSL and refuses plaintext connections.
connect_args = (
    {"check_same_thread": False} if is_sqlite else {"ssl_context": True} if is_pg8000 else {}
)
# In-memory SQLite creates a fresh, empty database per connection unless
# pinned to a single shared connection via StaticPool — otherwise each
# request can hit a connection where create_all() never ran.
engine_kwargs = {"poolclass": StaticPool} if is_sqlite_memory else {}
engine = create_engine(settings.database_url, connect_args=connect_args, **engine_kwargs)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


class Base(DeclarativeBase):
    pass


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

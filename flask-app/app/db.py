"""Thin database layer over SQLAlchemy Core (raw SQL, no ORM models).

Keeps the DB schema exactly as defined in AGENT.md; we only run SQL against it.
"""
from sqlalchemy import create_engine, text
from sqlalchemy.engine import Engine

_engine: Engine | None = None


def init_engine(url: str) -> Engine:
    global _engine
    _engine = create_engine(
        url,
        pool_pre_ping=True,
        pool_recycle=280,
        future=True,
    )
    return _engine


def get_engine() -> Engine:
    if _engine is None:
        raise RuntimeError("Engine not initialised. Call init_engine() first.")
    return _engine


def query_all(sql: str, params: dict | None = None) -> list[dict]:
    with get_engine().connect() as conn:
        rows = conn.execute(text(sql), params or {}).mappings().all()
        return [dict(r) for r in rows]


def query_one(sql: str, params: dict | None = None) -> dict | None:
    with get_engine().connect() as conn:
        row = conn.execute(text(sql), params or {}).mappings().first()
        return dict(row) if row else None


def execute(sql: str, params: dict | None = None):
    """Run an INSERT/UPDATE/DELETE inside a transaction. Returns lastrowid."""
    with get_engine().begin() as conn:
        result = conn.execute(text(sql), params or {})
        return result.lastrowid


def scalar(sql: str, params: dict | None = None):
    with get_engine().connect() as conn:
        return conn.execute(text(sql), params or {}).scalar()

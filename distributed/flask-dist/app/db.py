"""Lop truy van phan tan: mot engine cho moi node (HN/DN/HCM).

App ket noi toi node cua chi nhanh ma nguoi dung chon khi dang nhap. Moi thao tac
chay tren dung node do. Rieng HN (tru so) co the doc VIEW tong hop (FEDERATED) de
xem toan he thong.
"""
from sqlalchemy import create_engine, text
from sqlalchemy.engine import Engine
from sqlalchemy.exc import OperationalError
from flask import g, session

_engines: dict[str, Engine] = {}
_cfg = None


def _retry(fn):
    """Thu lai 1 lan neu gap loi ket noi tam thoi.

    Storage engine FEDERATED (HN doc DN/HCM) giu ket noi cache toi node remote;
    khi node remote dong ket noi do idle (wait_timeout) thi truy van dau tien
    bao loi 1160 'Got an error writing communication packets' / 2006 'server has
    gone away'. Lan thu 2 FEDERATED mo lai ket noi -> thanh cong. pool_pre_ping
    chi kiem tra ket noi tu app -> node, KHONG kiem tra duoc ket noi federated
    ben trong MySQL, nen can retry o day.
    """
    import functools

    @functools.wraps(fn)
    def wrapper(*args, **kwargs):
        try:
            return fn(*args, **kwargs)
        except OperationalError as e:
            code = e.orig.args[0] if getattr(e, "orig", None) and e.orig.args else None
            if code in (1160, 2006, 2013):  # loi ket noi tam thoi
                return fn(*args, **kwargs)
            raise

    return wrapper


def init_engines(cfg):
    """Tao san engine cho ca 3 node."""
    global _cfg
    _cfg = cfg
    for kv in cfg.NODES:
        _engines[kv] = create_engine(
            cfg.node_url(kv), pool_pre_ping=True, pool_recycle=280, future=True
        )
    return _engines


def engine_for(khu_vuc: str) -> Engine:
    return _engines[khu_vuc]


def current_khu_vuc() -> str:
    """Chi nhanh dang lam viec (luu trong session sau khi login)."""
    return session.get("khu_vuc", "HN")


def _engine() -> Engine:
    return engine_for(current_khu_vuc())


# --- Truy van tren node hien tai (theo chi nhanh dang dang nhap) ---
@_retry
def query_all(sql, params=None, khu_vuc=None):
    eng = engine_for(khu_vuc) if khu_vuc else _engine()
    with eng.connect() as conn:
        return [dict(r) for r in conn.execute(text(sql), params or {}).mappings().all()]


@_retry
def query_one(sql, params=None, khu_vuc=None):
    eng = engine_for(khu_vuc) if khu_vuc else _engine()
    with eng.connect() as conn:
        row = conn.execute(text(sql), params or {}).mappings().first()
        return dict(row) if row else None


@_retry
def scalar(sql, params=None, khu_vuc=None):
    eng = engine_for(khu_vuc) if khu_vuc else _engine()
    with eng.connect() as conn:
        return conn.execute(text(sql), params or {}).scalar()


def execute(sql, params=None, khu_vuc=None):
    eng = engine_for(khu_vuc) if khu_vuc else _engine()
    with eng.begin() as conn:
        return conn.execute(text(sql), params or {}).lastrowid


def call_proc(name, args, khu_vuc=None):
    eng = engine_for(khu_vuc) if khu_vuc else _engine()
    raw = eng.raw_connection()
    try:
        cur = raw.cursor()
        result = cur.callproc(name, args)
        cur.close()
        raw.commit()
        return list(result)
    finally:
        raw.close()

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


# =====================================================================
# TRANSACTION TUONG MINH + KHOA PHAN TAN (chong trung ma / race condition)
# =====================================================================
import contextlib


class Tx:
    """Boc nhieu lenh trong MOT transaction tren mot node.

    Dung voi `with db.tx(khu_vuc) as t: t.execute(sql, params)`.
    Neu khoi lenh nem exception -> ROLLBACK toan bo; neu khong -> COMMIT.
    Dam bao tinh nguyen tu (atomicity): vd insert nhan vien + gan quan ly phai
    cung thanh cong hoac cung that bai.
    """

    def __init__(self, conn):
        self._conn = conn
        self.last_id = None

    def execute(self, sql, params=None):
        res = self._conn.execute(text(sql), params or {})
        self.last_id = res.lastrowid
        return res

    def scalar(self, sql, params=None):
        return self._conn.execute(text(sql), params or {}).scalar()

    def query_one(self, sql, params=None):
        row = self._conn.execute(text(sql), params or {}).mappings().first()
        return dict(row) if row else None


@contextlib.contextmanager
def tx(khu_vuc=None):
    eng = engine_for(khu_vuc) if khu_vuc else _engine()
    with eng.begin() as conn:        # tu dong COMMIT khi thoat, ROLLBACK neu loi
        yield Tx(conn)


@contextlib.contextmanager
def global_lock(name: str, timeout: int = 10):
    """Khoa toan he thong qua GET_LOCK() tren node HN (tru so chinh).

    Dung de serialize cac thao tac phan tan can kiem tra chong nhieu node (vd
    them cong ty: phai dam bao ma_so_cong_ty duy nhat tren CA 3 node). Vi 2 chi
    nhanh co the them cung luc, ta lay 1 khoa chung tren HN truoc khi kiem
    tra + ghi, tranh race condition (TOCTOU).

    GET_LOCK la named lock cap server MySQL - moi ket noi deu thay cung mot
    khong gian ten khoa, nen dung HN lam diem dong bo chung cho ca cum.
    """
    eng = engine_for("HN")
    conn = eng.connect()
    try:
        got = conn.execute(text("SELECT GET_LOCK(:n, :t)"), {"n": name, "t": timeout}).scalar()
        if got != 1:
            raise TimeoutError(f"Khong lay duoc khoa '{name}' (he thong dang ban, thu lai sau).")
        yield
    finally:
        try:
            conn.execute(text("SELECT RELEASE_LOCK(:n)"), {"n": name})
        finally:
            conn.close()

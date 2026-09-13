"""Authentication & authorization: Flask-Login integration against NGUOI_DUNG."""
from functools import wraps

from flask import Blueprint, render_template, request, redirect, url_for, flash, abort
from flask_login import (
    LoginManager, UserMixin, login_user, logout_user, login_required, current_user,
)
from werkzeug.security import generate_password_hash, check_password_hash

from . import db

login_manager = LoginManager()
login_manager.login_view = "auth.login"
login_manager.login_message = "Vui long dang nhap de tiep tuc."

auth_bp = Blueprint("auth", __name__)

ROLES = ("ADMIN", "BQL", "NVCT", "CONG_TY")


class User(UserMixin):
    def __init__(self, row: dict):
        self.id = row["ma_nguoi_dung"]
        self.username = row["ten_dang_nhap"]
        self.ho_ten = row["ho_ten"]
        self.vai_tro = row["vai_tro"]
        self.ma_cong_ty = row.get("ma_cong_ty")
        self.ma_nhan_vien_toa_nha = row.get("ma_nhan_vien_toa_nha")  # BQL link
        self.ma_nhan_vien = row.get("ma_nhan_vien")                  # NVCT link
        self.trang_thai = row.get("trang_thai", "HOAT_DONG")
        self._hash = row["mat_khau_hash"]

    def check_password(self, password: str) -> bool:
        return check_password_hash(self._hash, password)

    @property
    def is_admin(self) -> bool:
        return self.vai_tro == "ADMIN"

    @property
    def is_bql(self) -> bool:
        return self.vai_tro == "BQL"

    @property
    def is_nvct(self) -> bool:
        return self.vai_tro == "NVCT"

    @property
    def is_cong_ty(self) -> bool:
        return self.vai_tro == "CONG_TY"


@login_manager.user_loader
def load_user(user_id: str):
    row = db.query_one(
        "SELECT * FROM NGUOI_DUNG WHERE ma_nguoi_dung = :id", {"id": user_id}
    )
    return User(row) if row else None


def roles_required(*roles):
    """Restrict a view to the given roles. ADMIN always allowed."""
    def decorator(view):
        @wraps(view)
        @login_required
        def wrapped(*args, **kwargs):
            if current_user.vai_tro not in roles and not current_user.is_admin:
                abort(403)
            return view(*args, **kwargs)
        return wrapped
    return decorator


@auth_bp.route("/login", methods=["GET", "POST"])
def login():
    if current_user.is_authenticated:
        return redirect(url_for("dashboard.index"))
    if request.method == "POST":
        username = request.form.get("username", "").strip()
        password = request.form.get("password", "")
        row = db.query_one(
            "SELECT * FROM NGUOI_DUNG WHERE ten_dang_nhap = :u", {"u": username}
        )
        if row and row["trang_thai"] == "HOAT_DONG":
            user = User(row)
            if user.check_password(password):
                login_user(user)
                return redirect(request.args.get("next") or url_for("dashboard.index"))
        flash("Ten dang nhap hoac mat khau khong dung.", "danger")
    return render_template("login.html")


@auth_bp.route("/logout")
@login_required
def logout():
    logout_user()
    return redirect(url_for("auth.login"))


def _build_default_users():
    """Danh sach user demo. Mat khau = ten dang nhap (login bang ma thuc te).

    - admin           : ADMIN (toan quyen)
    - Moi NHAN_VIEN_TOA_NHA -> user BQL, dang nhap bang ma_so_nhan_vien (vd BQL-005)
    - Moi NHAN_VIEN_CONG_TY -> user NVCT, dang nhap bang ma_so_nhan_vien (vd NVCT-0001)
    - Moi CONG_TY           -> user CONG_TY, dang nhap bang ma_so_cong_ty (vd CT-01)

    Moi phan tu: (username, ho_ten, vai_tro, ma_cong_ty, ma_nhan_vien_toa_nha, ma_nhan_vien)
    """
    users = [("admin", "Quan tri he thong", "ADMIN", None, None, None)]

    def rows(sql):
        try:
            return db.query_all(sql)
        except Exception:
            return []

    # BQL: nhan vien toa nha
    for nv in rows("SELECT ma_nhan_vien_toa_nha, ma_so_nhan_vien, ho_ten FROM NHAN_VIEN_TOA_NHA ORDER BY ma_nhan_vien_toa_nha"):
        users.append((nv["ma_so_nhan_vien"], nv["ho_ten"], "BQL", None, nv["ma_nhan_vien_toa_nha"], None))

    # NVCT: nhan vien cong ty
    for nv in rows("SELECT ma_nhan_vien, ma_so_nhan_vien, ho_ten, ma_cong_ty FROM NHAN_VIEN_CONG_TY ORDER BY ma_nhan_vien"):
        users.append((nv["ma_so_nhan_vien"], nv["ho_ten"], "NVCT", nv["ma_cong_ty"], None, nv["ma_nhan_vien"]))

    # CONG_TY: dai dien cong ty
    for ct in rows("SELECT ma_cong_ty, ma_so_cong_ty, ten_cong_ty FROM CONG_TY ORDER BY ma_cong_ty"):
        users.append((ct["ma_so_cong_ty"], f"Dai dien {ct['ten_cong_ty']}", "CONG_TY", ct["ma_cong_ty"], None, None))

    return users


def _insert_user(username, hoten, role, ma_cty, ma_bql, ma_nvct):
    db.execute(
        """INSERT INTO NGUOI_DUNG
           (ten_dang_nhap, mat_khau_hash, ho_ten, vai_tro, ma_cong_ty, ma_nhan_vien_toa_nha, ma_nhan_vien)
           VALUES (:u, :h, :ht, :r, :c, :bql, :nvct)""",
        {"u": username, "h": generate_password_hash(username), "ht": hoten,
         "r": role, "c": ma_cty, "bql": ma_bql, "nvct": ma_nvct},
    )


def bootstrap_users(admin_username: str, admin_password: str):
    """Create default users if the table is empty. Idempotent. Mat khau = username."""
    count = db.scalar("SELECT COUNT(*) FROM NGUOI_DUNG")
    if count and count > 0:
        return
    for u in _build_default_users():
        _insert_user(*u)


def reseed_users():
    """Xoa het user va tao lai theo _build_default_users (mat khau = ten dang nhap)."""
    db.execute("DELETE FROM NGUOI_DUNG")
    for u in _build_default_users():
        _insert_user(*u)
    return db.scalar("SELECT COUNT(*) FROM NGUOI_DUNG")

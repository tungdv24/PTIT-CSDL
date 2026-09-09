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

ROLES = ("ADMIN", "QUAN_LY", "NHAN_VIEN", "CONG_TY")


class User(UserMixin):
    def __init__(self, row: dict):
        self.id = row["ma_nguoi_dung"]
        self.username = row["ten_dang_nhap"]
        self.ho_ten = row["ho_ten"]
        self.vai_tro = row["vai_tro"]
        self.ma_cong_ty = row.get("ma_cong_ty")
        self.trang_thai = row.get("trang_thai", "HOAT_DONG")
        self._hash = row["mat_khau_hash"]

    def check_password(self, password: str) -> bool:
        return check_password_hash(self._hash, password)

    @property
    def is_admin(self) -> bool:
        return self.vai_tro == "ADMIN"


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


def bootstrap_users(admin_username: str, admin_password: str):
    """Create default users if the table is empty. Idempotent."""
    count = db.scalar("SELECT COUNT(*) FROM NGUOI_DUNG")
    if count and count > 0:
        return
    defaults = [
        (admin_username, admin_password, "Quan tri he thong", "ADMIN", None),
        ("quanly01", "quanly123", "Quan ly toa nha", "QUAN_LY", None),
        ("nhanvien01", "nhanvien123", "Nhan vien BQL", "NHAN_VIEN", None),
        ("congty01", "congty123", "Dai dien cong ty ABC", "CONG_TY", 1),
    ]
    for username, pw, hoten, role, ma_cty in defaults:
        db.execute(
            """INSERT INTO NGUOI_DUNG (ten_dang_nhap, mat_khau_hash, ho_ten, vai_tro, ma_cong_ty)
               VALUES (:u, :h, :ht, :r, :c)""",
            {
                "u": username,
                "h": generate_password_hash(pw),
                "ht": hoten,
                "r": role,
                "c": ma_cty,
            },
        )

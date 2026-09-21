"""Xac thuc + phan quyen cho he phan tan.

Dang nhap: nguoi dung chon CHI NHANH (HN/DN/HCM) + ten dang nhap + mat khau.
He thong kiem tra tai khoan tren node cua chi nhanh do. Sau khi dang nhap,
`session['khu_vuc']` quyet dinh moi truy van chay tren node nao.

Vai tro:
  ADMIN  : chi o tru so HN - toan quyen + bao cao tong hop toan he thong
  BQL    : nhan vien toa nha - xem bang luong (cuc bo node)
  NVCT   : nhan vien cong ty - su dung dich vu cua chinh minh (cuc bo)
  CONG_TY: dai dien cong ty - xem hoa don cong ty minh (cuc bo)
"""
from functools import wraps

from flask import Blueprint, render_template, request, redirect, url_for, flash, abort, session
from flask_login import (
    LoginManager, UserMixin, login_user, logout_user, login_required, current_user,
)
from werkzeug.security import generate_password_hash, check_password_hash

from . import db
from .config import Config

login_manager = LoginManager()
login_manager.login_view = "auth.login"
login_manager.login_message = "Vui long dang nhap."

auth_bp = Blueprint("auth", __name__)


class User(UserMixin):
    def __init__(self, row: dict, khu_vuc: str):
        self.id = f"{khu_vuc}:{row['ma_nguoi_dung']}"  # id gom ca chi nhanh
        self.ma_nguoi_dung = row["ma_nguoi_dung"]
        self.username = row["ten_dang_nhap"]
        self.ho_ten = row["ho_ten"]
        self.vai_tro = row["vai_tro"]
        self.khu_vuc = row.get("khu_vuc", khu_vuc)
        self.ma_cong_ty = row.get("ma_cong_ty")
        self.ma_nhan_vien_toa_nha = row.get("ma_nhan_vien_toa_nha")
        self.ma_nhan_vien = row.get("ma_nhan_vien")
        self._hash = row["mat_khau_hash"]

    def check_password(self, pw): return check_password_hash(self._hash, pw)
    @property
    def is_admin(self): return self.vai_tro == "ADMIN"
    @property
    def is_head_office(self): return self.khu_vuc == "HN"


@login_manager.user_loader
def load_user(user_id: str):
    try:
        khu_vuc, ma = user_id.split(":", 1)
    except ValueError:
        return None
    if khu_vuc not in Config.NODES:
        return None
    row = db.query_one("SELECT * FROM NGUOI_DUNG WHERE ma_nguoi_dung=:id",
                       {"id": int(ma)}, khu_vuc=khu_vuc)
    return User(row, khu_vuc) if row else None


def roles_required(*roles):
    def deco(view):
        @wraps(view)
        @login_required
        def wrapped(*a, **k):
            if current_user.vai_tro not in roles and not current_user.is_admin:
                abort(403)
            return view(*a, **k)
        return wrapped
    return deco


def head_office_only(view):
    """Chi cho tru so chinh (HN) - dung cho bao cao tong hop."""
    @wraps(view)
    @login_required
    def wrapped(*a, **k):
        if not current_user.is_head_office:
            abort(403)
        return view(*a, **k)
    return wrapped


@auth_bp.route("/login", methods=["GET", "POST"])
def login():
    if current_user.is_authenticated:
        return redirect(url_for("dashboard.index"))
    if request.method == "POST":
        khu_vuc = request.form.get("khu_vuc", "HN")
        username = request.form.get("username", "").strip()
        password = request.form.get("password", "")
        if khu_vuc not in Config.NODES:
            flash("Chi nhanh khong hop le.", "danger")
            return render_template("login.html", nodes=Config.NODES)
        try:
            row = db.query_one("SELECT * FROM NGUOI_DUNG WHERE ten_dang_nhap=:u",
                               {"u": username}, khu_vuc=khu_vuc)
        except Exception as exc:
            flash(f"Khong ket noi duoc node {khu_vuc}: {exc}", "danger")
            return render_template("login.html", nodes=Config.NODES)
        if row and row.get("trang_thai", "HOAT_DONG") == "HOAT_DONG":
            user = User(row, khu_vuc)
            if user.check_password(password):
                session["khu_vuc"] = khu_vuc          # gan node lam viec
                login_user(user)
                return redirect(request.args.get("next") or url_for("dashboard.index"))
        flash("Sai chi nhanh / ten dang nhap / mat khau.", "danger")
    return render_template("login.html", nodes=Config.NODES)


@auth_bp.route("/logout")
@login_required
def logout():
    logout_user()
    session.pop("khu_vuc", None)
    return redirect(url_for("auth.login"))


def bootstrap_users_all_nodes(admin_password: str):
    """Tao user demo tren TUNG node (nhan ban). Mat khau = ten dang nhap.

    - HN: admin (ADMIN) + BQL-00x + user cong ty/nvct cua HN
    - DN/HCM: user cong ty/nvct cua chi nhanh do (KHONG co admin)
    Idempotent: chi tao khi node do chua co user.
    """
    for kv in Config.NODES:
        try:
            n = db.scalar("SELECT COUNT(*) FROM NGUOI_DUNG", khu_vuc=kv)
        except Exception:
            continue
        if n and n > 0:
            continue
        users = _users_for_node(kv)
        for uname, hoten, role, ma_cty, ma_bql, ma_nvct in users:
            db.execute(
                """INSERT INTO NGUOI_DUNG
                   (ten_dang_nhap, mat_khau_hash, ho_ten, vai_tro, khu_vuc, ma_cong_ty, ma_nhan_vien_toa_nha, ma_nhan_vien)
                   VALUES (:u,:h,:ht,:r,:kv,:c,:bql,:nvct)""",
                {"u": uname, "h": generate_password_hash(uname if uname != "admin" else admin_password),
                 "ht": hoten, "r": role, "kv": kv, "c": ma_cty, "bql": ma_bql, "nvct": ma_nvct},
                khu_vuc=kv,
            )


def _users_for_node(kv: str):
    """Sinh danh sach user tu du lieu thuc te tren node (theo cong ty/nhan vien co san)."""
    users = []
    # Moi node deu co 1 admin de xem/quan ly toan bo DB CUA CHI NHANH do.
    # ADMIN o HN = tru so (co them bao cao tong hop toan quoc).
    # ADMIN o DN/HCM = admin chi nhanh (chi trong node cua minh).
    ten_admin = {"HN": "Quan tri Tru so HN", "DN": "Quan tri Chi nhanh Da Nang",
                 "HCM": "Quan tri Chi nhanh TP.HCM"}.get(kv, f"Quan tri {kv}")
    users.append(("admin", ten_admin, "ADMIN", None, None, None))
    if kv == "HN":
        # BQL (nhan vien toa nha nhan ban o moi node) - tao o HN
        for r in db.query_all("SELECT ma_nhan_vien_toa_nha, ma_so_nhan_vien, ho_ten FROM NHAN_VIEN_TOA_NHA ORDER BY ma_nhan_vien_toa_nha", khu_vuc=kv):
            users.append((r["ma_so_nhan_vien"], r["ho_ten"], "BQL", None, r["ma_nhan_vien_toa_nha"], None))
    # NVCT + CONG_TY theo cong ty co tren node nay
    for ct in db.query_all("SELECT ma_cong_ty, ma_so_cong_ty, ten_cong_ty FROM CONG_TY ORDER BY ma_cong_ty", khu_vuc=kv):
        users.append((ct["ma_so_cong_ty"], f"Dai dien {ct['ten_cong_ty']}", "CONG_TY", ct["ma_cong_ty"], None, None))
    for nv in db.query_all("SELECT ma_nhan_vien, ma_so_nhan_vien, ho_ten, ma_cong_ty FROM NHAN_VIEN_CONG_TY ORDER BY ma_nhan_vien", khu_vuc=kv):
        users.append((nv["ma_so_nhan_vien"], nv["ho_ten"], "NVCT", nv["ma_cong_ty"], None, nv["ma_nhan_vien"]))
    return users

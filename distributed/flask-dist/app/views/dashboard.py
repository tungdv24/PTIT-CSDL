"""Dashboard - hien thi so lieu CUC BO cua chi nhanh dang dang nhap."""
from flask import Blueprint, render_template, request
from flask_login import login_required, current_user

from .. import db

bp = Blueprint("dashboard", __name__)


@bp.route("/dashboard")
@login_required
def index():
    # Cac vai tro khong phai ADMIN -> chuyen toi trang phu hop.
    from flask import redirect, url_for
    if not current_user.is_admin:
        if current_user.vai_tro == "BQL":
            return redirect(url_for("finance.luong_list"))
        if current_user.vai_tro == "NVCT":
            return redirect(url_for("usage.list_view"))
        if current_user.vai_tro == "CONG_TY":
            return redirect(url_for("finance.hoa_don_list"))

    thang = request.args.get("thang", type=int) or 4
    nam = request.args.get("nam", type=int) or 2026

    # So lieu cuc bo cua node (chi nhanh) dang dang nhap.
    tong_thu = db.scalar("SELECT COALESCE(SUM(tong_tien),0) FROM HOA_DON WHERE thang=:t AND nam=:n",
                         {"t": thang, "n": nam}) or 0
    counts = {
        "cong_ty": db.scalar("SELECT COUNT(*) FROM CONG_TY") or 0,
        "van_phong": db.scalar("SELECT COUNT(*) FROM VAN_PHONG") or 0,
        "hop_dong": db.scalar("SELECT COUNT(*) FROM HOP_DONG_THUE WHERE trang_thai='HIEU_LUC'") or 0,
        "hoa_don": db.scalar("SELECT COUNT(*) FROM HOA_DON WHERE thang=:t AND nam=:n", {"t": thang, "n": nam}) or 0,
    }
    top = db.query_all(
        """SELECT ct.ten_cong_ty, hd.tong_tien, hd.trang_thai_thanh_toan
           FROM HOA_DON hd JOIN CONG_TY ct ON ct.ma_cong_ty=hd.ma_cong_ty
           WHERE hd.thang=:t AND hd.nam=:n ORDER BY hd.tong_tien DESC LIMIT 5""",
        {"t": thang, "n": nam},
    )
    return render_template("dashboard.html", thang=thang, nam=nam,
                           tong_thu=float(tong_thu), counts=counts, top=top)

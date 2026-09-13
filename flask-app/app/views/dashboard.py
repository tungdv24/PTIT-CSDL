"""Dashboard: revenue/cost/profit KPIs + occupancy + recent activity."""
import datetime

from flask import Blueprint, render_template, request, redirect, url_for
from flask_login import login_required, current_user

from .. import db

bp = Blueprint("dashboard", __name__)


@bp.route("/dashboard")
@login_required
def index():
    # Dashboard tai chinh toan toa nha chi danh cho ADMIN.
    # Cac vai tro khac chuyen thang toi trang phu hop.
    if not current_user.is_admin:
        if current_user.vai_tro == "BQL":
            return redirect(url_for("finance.luong_list"))
        if current_user.vai_tro == "NVCT":
            return redirect(url_for("usage.list_view"))
        if current_user.vai_tro == "CONG_TY":
            return redirect(url_for("finance.hoa_don_list"))
    now = datetime.date.today()
    thang = request.args.get("thang", type=int) or 4
    nam = request.args.get("nam", type=int) or 2026

    tong_thu = db.scalar(
        "SELECT COALESCE(SUM(tong_tien),0) FROM HOA_DON WHERE thang=:t AND nam=:n",
        {"t": thang, "n": nam},
    ) or 0
    tong_luong = db.scalar(
        "SELECT COALESCE(SUM(tong_luong),0) FROM LUONG_NHAN_VIEN WHERE thang=:t AND nam=:n",
        {"t": thang, "n": nam},
    ) or 0
    chi_van_hanh = db.scalar(
        "SELECT COALESCE(SUM(so_tien),0) FROM CHI_PHI_TOA_NHA "
        "WHERE MONTH(ngay_phat_sinh)=:t AND YEAR(ngay_phat_sinh)=:n",
        {"t": thang, "n": nam},
    ) or 0
    tong_chi = float(tong_luong) + float(chi_van_hanh)
    loi_nhuan = float(tong_thu) - tong_chi

    # Occupancy rate
    tong_vp = db.scalar("SELECT COUNT(*) FROM VAN_PHONG") or 0
    vp_da_thue = db.scalar("SELECT COUNT(*) FROM VAN_PHONG WHERE trang_thai='DA_THUE'") or 0
    occupancy = round((vp_da_thue / tong_vp * 100), 1) if tong_vp else 0

    counts = {
        "cong_ty": db.scalar("SELECT COUNT(*) FROM CONG_TY") or 0,
        "van_phong": tong_vp,
        "hop_dong": db.scalar("SELECT COUNT(*) FROM HOP_DONG_THUE WHERE trang_thai='HIEU_LUC'") or 0,
        "nhan_vien_tn": db.scalar("SELECT COUNT(*) FROM NHAN_VIEN_TOA_NHA WHERE trang_thai='DANG_LAM'") or 0,
    }

    top_cong_ty = db.query_all(
        """SELECT ct.ten_cong_ty, hd.tong_tien, hd.trang_thai_thanh_toan
           FROM HOA_DON hd JOIN CONG_TY ct ON ct.ma_cong_ty = hd.ma_cong_ty
           WHERE hd.thang=:t AND hd.nam=:n
           ORDER BY hd.tong_tien DESC LIMIT 5""",
        {"t": thang, "n": nam},
    )

    # Revenue by month for chart (current year)
    doanh_thu_thang = db.query_all(
        "SELECT thang, COALESCE(SUM(tong_tien),0) AS tong FROM HOA_DON "
        "WHERE nam=:n GROUP BY thang ORDER BY thang",
        {"n": nam},
    )

    return render_template(
        "dashboard.html",
        thang=thang, nam=nam,
        tong_thu=float(tong_thu), tong_chi=tong_chi, loi_nhuan=loi_nhuan,
        chi_van_hanh=float(chi_van_hanh), tong_luong=float(tong_luong),
        occupancy=occupancy, vp_da_thue=vp_da_thue, tong_vp=tong_vp,
        counts=counts, top_cong_ty=top_cong_ty, doanh_thu_thang=doanh_thu_thang,
    )

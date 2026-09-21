"""Tai chinh cuc bo tren node chi nhanh: hoa don + luong."""
from flask import Blueprint, render_template, request, redirect, url_for, flash
from flask_login import login_required, current_user

from .. import db
from ..auth import roles_required

bp = Blueprint("finance", __name__)


# ---------------- Hoa don (ADMIN xem tat ca cua node; CONG_TY xem cua minh) ----------------
@bp.route("/hoa-don")
@roles_required("CONG_TY")
def hoa_don_list():
    thang = request.args.get("thang", type=int) or 4
    nam = request.args.get("nam", type=int) or 2026
    where = "WHERE hd.thang=:t AND hd.nam=:n"
    params = {"t": thang, "n": nam}
    if current_user.vai_tro == "CONG_TY" and current_user.ma_cong_ty:
        where += " AND hd.ma_cong_ty=:c"
        params["c"] = current_user.ma_cong_ty
    rows = db.query_all(
        f"""SELECT hd.*, ct.ten_cong_ty FROM HOA_DON hd
            JOIN CONG_TY ct ON ct.ma_cong_ty=hd.ma_cong_ty {where}
            ORDER BY hd.tong_tien DESC""", params)
    return render_template("hoa_don_list.html", rows=rows, thang=thang, nam=nam)


@bp.route("/hoa-don/<int:ma_hoa_don>")
@roles_required("CONG_TY")
def hoa_don_detail(ma_hoa_don):
    hd = db.query_one(
        """SELECT hd.*, ct.ten_cong_ty, ct.ma_so_thue, ct.dia_chi
           FROM HOA_DON hd JOIN CONG_TY ct ON ct.ma_cong_ty=hd.ma_cong_ty
           WHERE hd.ma_hoa_don=:id""", {"id": ma_hoa_don})
    if not hd:
        flash("Khong tim thay hoa don.", "danger")
        return redirect(url_for("finance.hoa_don_list"))
    if current_user.vai_tro == "CONG_TY" and hd["ma_cong_ty"] != current_user.ma_cong_ty:
        from flask import abort
        abort(403)
    chi_tiet = db.query_all("SELECT * FROM CHI_TIET_HOA_DON WHERE ma_hoa_don=:id", {"id": ma_hoa_don})
    return render_template("hoa_don_detail.html", hd=hd, chi_tiet=chi_tiet)


@bp.route("/hoa-don/<int:ma_hoa_don>/thanh-toan", methods=["POST"])
@roles_required()  # ADMIN only
def hoa_don_thanh_toan(ma_hoa_don):
    db.execute("UPDATE HOA_DON SET trang_thai_thanh_toan='DA_THANH_TOAN' WHERE ma_hoa_don=:id",
               {"id": ma_hoa_don})
    flash("Da danh dau da thanh toan.", "success")
    return redirect(url_for("finance.hoa_don_detail", ma_hoa_don=ma_hoa_don))


# ---------------- Luong (BQL xem cua minh; ADMIN xem tat ca cua node) ----------------
@bp.route("/luong")
@roles_required("BQL")
def luong_list():
    thang = request.args.get("thang", type=int) or 4
    nam = request.args.get("nam", type=int) or 2026
    where = "WHERE l.thang=:t AND l.nam=:n"
    params = {"t": thang, "n": nam}
    is_self = False
    if current_user.vai_tro == "BQL" and current_user.ma_nhan_vien_toa_nha:
        where += " AND l.ma_nhan_vien_toa_nha=:me"
        params["me"] = current_user.ma_nhan_vien_toa_nha
        is_self = True
    rows = db.query_all(
        f"""SELECT l.*, nv.ho_ten, nv.ma_so_nhan_vien FROM LUONG_NHAN_VIEN l
            JOIN NHAN_VIEN_TOA_NHA nv ON nv.ma_nhan_vien_toa_nha=l.ma_nhan_vien_toa_nha
            {where} ORDER BY l.tong_luong DESC""", params)
    return render_template("luong_list.html", rows=rows, thang=thang, nam=nam, is_self=is_self)

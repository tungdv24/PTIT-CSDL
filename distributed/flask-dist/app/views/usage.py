"""Su dung dich vu - cuc bo tren node chi nhanh. NVCT ghi/xem cua chinh minh."""
import datetime

from flask import Blueprint, render_template, request, redirect, url_for, flash, jsonify, abort
from flask_login import login_required, current_user
from sqlalchemy.exc import SQLAlchemyError

from .. import db

bp = Blueprint("usage", __name__, url_prefix="/su-dung-dich-vu")
ALLOWED = ("NVCT",)


def _guard():
    if current_user.vai_tro not in ALLOWED and not current_user.is_admin:
        abort(403)


def _self():
    return current_user.ma_nhan_vien if current_user.vai_tro == "NVCT" else None


@bp.route("/")
@login_required
def list_view():
    _guard()
    thang = request.args.get("thang", type=int) or datetime.date.today().month
    nam = request.args.get("nam", type=int) or 2026
    where = "WHERE MONTH(sd.ngay_su_dung)=:t AND YEAR(sd.ngay_su_dung)=:n"
    params = {"t": thang, "n": nam}
    me = _self()
    if me:
        where += " AND sd.ma_nhan_vien=:me"
        params["me"] = me
    rows = db.query_all(
        f"""SELECT sd.ma_su_dung, sd.ngay_su_dung, sd.so_luong, sd.don_gia, sd.thanh_tien,
                   sd.ghi_chu, nv.ho_ten, dv.ten_dich_vu
            FROM SU_DUNG_DICH_VU sd
            JOIN NHAN_VIEN_CONG_TY nv ON nv.ma_nhan_vien=sd.ma_nhan_vien
            JOIN DANG_KY_DICH_VU dk ON dk.ma_dang_ky=sd.ma_dang_ky
            JOIN DICH_VU dv ON dv.ma_dich_vu=dk.ma_dich_vu
            {where} ORDER BY sd.ngay_su_dung DESC, sd.ma_su_dung DESC""", params)
    tong = sum(float(r["thanh_tien"]) for r in rows)
    return render_template("usage_list.html", rows=rows, thang=thang, nam=nam, tong=tong,
                           is_self=bool(me))


@bp.route("/new", methods=["GET", "POST"])
@login_required
def create_view():
    _guard()
    me = _self()
    if request.method == "POST":
        ma_nhan_vien = me or request.form.get("ma_nhan_vien", type=int)
        ma_dang_ky = request.form.get("ma_dang_ky", type=int)
        ngay = request.form.get("ngay_su_dung", "").strip()
        so_luong = request.form.get("so_luong", "").strip() or "1"
        don_gia = request.form.get("don_gia", "").strip()
        ghi_chu = request.form.get("ghi_chu", "").strip() or None
        if not (ma_nhan_vien and ma_dang_ky and ngay and don_gia):
            flash("Vui long chon dich vu, ngay, don gia.", "danger")
            return redirect(url_for("usage.create_view"))
        # Rang buoc: nhan vien phai thuoc cong ty da dang ky (kiem tra cung node)
        ok = db.query_one(
            """SELECT 1 FROM NHAN_VIEN_CONG_TY nv JOIN DANG_KY_DICH_VU dk ON dk.ma_cong_ty=nv.ma_cong_ty
               WHERE nv.ma_nhan_vien=:nv AND dk.ma_dang_ky=:dk""",
            {"nv": ma_nhan_vien, "dk": ma_dang_ky})
        if not ok:
            flash("Nhan vien khong thuoc cong ty da dang ky dich vu nay.", "danger")
            return redirect(url_for("usage.create_view"))
        try:
            db.execute(
                """INSERT INTO SU_DUNG_DICH_VU (ma_nhan_vien, ma_dang_ky, ngay_su_dung, so_luong, don_gia, ghi_chu)
                   VALUES (:nv,:dk,:ng,:sl,:dg,:gc)""",
                {"nv": ma_nhan_vien, "dk": ma_dang_ky, "ng": ngay, "sl": so_luong,
                 "dg": don_gia, "gc": ghi_chu})
            flash("Da ghi nhan su dung dich vu.", "success")
            return redirect(url_for("usage.list_view"))
        except SQLAlchemyError as e:
            flash(f"Loi: {getattr(e, 'orig', e)}", "danger")
    # Danh sach dich vu THEO_LUOT cua cong ty (cua chinh NVCT hoac cua node cho admin)
    if me:
        dks = db.query_all(
            """SELECT dk.ma_dang_ky, dk.don_gia, dv.ten_dich_vu
               FROM DANG_KY_DICH_VU dk JOIN DICH_VU dv ON dv.ma_dich_vu=dk.ma_dich_vu
               JOIN NHAN_VIEN_CONG_TY nv ON nv.ma_cong_ty=dk.ma_cong_ty
               WHERE nv.ma_nhan_vien=:me AND dk.trang_thai='DANG_DUNG' AND dv.cach_tinh_phi='THEO_LUOT'""",
            {"me": me})
    else:
        dks = db.query_all(
            """SELECT dk.ma_dang_ky, dk.don_gia, dv.ten_dich_vu
               FROM DANG_KY_DICH_VU dk JOIN DICH_VU dv ON dv.ma_dich_vu=dk.ma_dich_vu
               WHERE dk.trang_thai='DANG_DUNG' AND dv.cach_tinh_phi='THEO_LUOT'""")
    today = datetime.date.today().isoformat()
    return render_template("usage_form.html", dks=dks, today=today, is_self=bool(me))

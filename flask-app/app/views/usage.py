"""Nhap nhat ky su dung dich vu theo ngay (an uong, gui xe) cho tung nhan vien.

Dap ung yeu cau: du lieu su dung dich vu bien doi (THEO_LUOT) duoc nhap thu cong
theo tung ngay, tung nhan vien cua tung cong ty. Mot nhan vien khong nhat thiet
dung dich vu moi ngay -> moi lan dung la mot ban ghi rieng.

Luong chay:
  SU_DUNG_DICH_VU  ->  hoa don (THEO_LUOT)  ->  luong nhan vien toa nha phu trach.
"""
import datetime

from flask import Blueprint, render_template, request, redirect, url_for, flash, jsonify
from flask_login import login_required, current_user
from sqlalchemy.exc import SQLAlchemyError

from .. import db, mongolog
from ..auth import roles_required

bp = Blueprint("usage", __name__, url_prefix="/su-dung-dich-vu")

# Chi NVCT (nhan vien cong ty) va ADMIN duoc vao trang su dung dich vu.
# NVCT: nhap/xem su dung cua chinh minh. ADMIN: tat ca.
ALLOWED = ("NVCT",)


def _guard():
    from flask import abort
    if current_user.vai_tro not in ALLOWED and not current_user.is_admin:
        abort(403)


def _self_employee():
    """NVCT -> ma_nhan_vien cua chinh ho; ADMIN -> None (xem/nhap tat ca)."""
    if current_user.vai_tro == "NVCT":
        return current_user.ma_nhan_vien
    return None


@bp.route("/")
@login_required
def list_view():
    _guard()
    thang = request.args.get("thang", type=int) or datetime.date.today().month
    nam = request.args.get("nam", type=int) or 2026

    # NVCT chi thay lich su su dung cua CHINH MINH.
    self_nv = _self_employee()

    where = "WHERE MONTH(sd.ngay_su_dung)=:t AND YEAR(sd.ngay_su_dung)=:n"
    params = {"t": thang, "n": nam}
    if self_nv:
        where += " AND sd.ma_nhan_vien=:me"
        params["me"] = self_nv

    rows = db.query_all(
        f"""SELECT sd.ma_su_dung, sd.ngay_su_dung, sd.so_luong, sd.don_gia, sd.thanh_tien,
                   sd.ghi_chu, nv.ho_ten, ct.ten_cong_ty, dv.ten_dich_vu
            FROM SU_DUNG_DICH_VU sd
            JOIN NHAN_VIEN_CONG_TY nv ON nv.ma_nhan_vien = sd.ma_nhan_vien
            JOIN CONG_TY ct           ON ct.ma_cong_ty = nv.ma_cong_ty
            JOIN DANG_KY_DICH_VU dk   ON dk.ma_dang_ky = sd.ma_dang_ky
            JOIN DICH_VU dv           ON dv.ma_dich_vu = dk.ma_dich_vu
            {where}
            ORDER BY sd.ngay_su_dung DESC, sd.ma_su_dung DESC""",
        params,
    )
    tong = sum(float(r["thanh_tien"]) for r in rows)
    return render_template(
        "usage_list.html", rows=rows, thang=thang, nam=nam, tong=tong,
        is_self=bool(self_nv),
    )


@bp.route("/api/cong-ty/<int:ma_cong_ty>")
@login_required
def api_cong_ty(ma_cong_ty):
    """Tra ve nhan vien + dang ky dich vu THEO_LUOT cua cong ty (de do form).

    NVCT: chi duoc lay cong ty cua chinh minh, va danh sach nhan vien chi gom chinh ho.
    ADMIN: lay bat ky cong ty nao, day du nhan vien.
    """
    _guard()
    self_nv = _self_employee()
    if self_nv:
        # NVCT: chi cong ty cua minh.
        if current_user.ma_cong_ty and ma_cong_ty != current_user.ma_cong_ty:
            from flask import abort
            abort(403)
        nhan_vien = db.query_all(
            """SELECT ma_nhan_vien, ho_ten, ma_so_nhan_vien FROM NHAN_VIEN_CONG_TY
               WHERE ma_nhan_vien=:me""",
            {"me": self_nv},
        )
    else:
        nhan_vien = db.query_all(
            """SELECT ma_nhan_vien, ho_ten, ma_so_nhan_vien FROM NHAN_VIEN_CONG_TY
               WHERE ma_cong_ty=:c AND trang_thai='HOAT_DONG' ORDER BY ho_ten""",
            {"c": ma_cong_ty},
        )
    dang_ky = db.query_all(
        """SELECT dk.ma_dang_ky, dk.don_gia, dv.ten_dich_vu
           FROM DANG_KY_DICH_VU dk JOIN DICH_VU dv ON dv.ma_dich_vu=dk.ma_dich_vu
           WHERE dk.ma_cong_ty=:c AND dk.trang_thai='DANG_DUNG'
             AND dv.cach_tinh_phi='THEO_LUOT'
           ORDER BY dv.ten_dich_vu""",
        {"c": ma_cong_ty},
    )
    return jsonify({
        "nhan_vien": [dict(r) for r in nhan_vien],
        "dang_ky": [{"ma_dang_ky": r["ma_dang_ky"], "ten_dich_vu": r["ten_dich_vu"],
                     "don_gia": float(r["don_gia"])} for r in dang_ky],
    })


@bp.route("/new", methods=["GET", "POST"])
@login_required
def create_view():
    _guard()
    if request.method == "POST":
        ma_nhan_vien = request.form.get("ma_nhan_vien", type=int)
        ma_dang_ky = request.form.get("ma_dang_ky", type=int)
        ngay = request.form.get("ngay_su_dung", "").strip()
        so_luong = request.form.get("so_luong", "").strip() or "1"
        don_gia = request.form.get("don_gia", "").strip()
        ghi_chu = request.form.get("ghi_chu", "").strip() or None

        # NVCT chi duoc nhap cho CHINH MINH (bo qua gia tri form gui len).
        self_nv = _self_employee()
        if self_nv:
            ma_nhan_vien = self_nv

        if not (ma_nhan_vien and ma_dang_ky and ngay and don_gia):
            flash("Vui long chon dich vu, ngay va don gia.", "danger")
            return redirect(url_for("usage.create_view"))

        # Goi stored procedure ghi nhan su dung (mot giao dich).
        # Rang buoc "nhan vien phai thuoc dung cong ty dang ky" duoc trigger
        # trg_sudung_check_company kiem tra o phia CSDL.
        try:
            out = db.call_proc("sp_ghi_su_dung_dich_vu",
                               [ma_nhan_vien, ma_dang_ky, ngay, so_luong, don_gia, ghi_chu, 0])
            new_id = out[6]
            mongolog.log("SERVICE_USAGE", "SU_DUNG_DICH_VU", new_id,
                         f"Ghi nhan su dung dich vu: nhan_vien={ma_nhan_vien}, "
                         f"dang_ky={ma_dang_ky}, ngay={ngay}, so_luong={so_luong}, don_gia={don_gia}")
            flash("Da ghi nhan su dung dich vu.", "success")
            return redirect(url_for("usage.list_view"))
        except Exception as exc:
            msg = getattr(exc, "orig", exc)
            flash(f"Loi: {msg}", "danger")

    self_nv = _self_employee()
    if self_nv:
        # NVCT: khoa cung cong ty cua minh (chi de load dich vu THEO_LUOT).
        cong_tys = db.query_all(
            "SELECT ma_cong_ty, ten_cong_ty FROM CONG_TY WHERE ma_cong_ty=:c",
            {"c": current_user.ma_cong_ty})
    else:
        cong_tys = db.query_all("SELECT ma_cong_ty, ten_cong_ty FROM CONG_TY ORDER BY ten_cong_ty")
    today = datetime.date.today().isoformat()
    return render_template(
        "usage_form.html", cong_tys=cong_tys, today=today,
        own_company=(current_user.ma_cong_ty if self_nv else None),
    )


@bp.route("/<int:ma_su_dung>/delete", methods=["POST"])
@roles_required()  # ADMIN only
def delete_view(ma_su_dung):
    db.execute("DELETE FROM SU_DUNG_DICH_VU WHERE ma_su_dung=:id", {"id": ma_su_dung})
    flash("Da xoa ban ghi su dung.", "success")
    return redirect(request.referrer or url_for("usage.list_view"))

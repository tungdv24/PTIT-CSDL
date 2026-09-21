"""Finance: invoices (billing), payroll, and profit & loss report.

Implements the business rules from AGENT.md section 4:
 - Invoice = office rent + fixed services + variable (per-use) services
 - Salary = luong_co_ban + (doanh_thu_dich_vu * ty_le_doanh_thu / 100)
 - P&L    = total revenue - (total salaries + operating expenses)
"""
import datetime

from flask import Blueprint, render_template, request, redirect, url_for, flash
from flask_login import login_required, current_user

from .. import db
from ..auth import roles_required

bp = Blueprint("finance", __name__)


# --------------------------------------------------------------------------
# Invoices
# --------------------------------------------------------------------------
@bp.route("/hoa-don")
@roles_required("CONG_TY")
def hoa_don_list():
    # Chi ADMIN (tat ca) va CONG_TY (cua cong ty minh) duoc xem hoa don.
    thang = request.args.get("thang", type=int) or 4
    nam = request.args.get("nam", type=int) or 2026
    where = "WHERE hd.thang=:t AND hd.nam=:n"
    params = {"t": thang, "n": nam}
    # A CONG_TY-role user only sees their own invoices.
    if current_user.vai_tro == "CONG_TY" and current_user.ma_cong_ty:
        where += " AND hd.ma_cong_ty=:c"
        params["c"] = current_user.ma_cong_ty
    rows = db.query_all(
        f"""SELECT hd.*, ct.ten_cong_ty FROM HOA_DON hd
            JOIN CONG_TY ct ON ct.ma_cong_ty=hd.ma_cong_ty
            {where} ORDER BY hd.tong_tien DESC""",
        params,
    )
    return render_template("hoa_don_list.html", rows=rows, thang=thang, nam=nam)


@bp.route("/hoa-don/<int:ma_hoa_don>")
@roles_required("CONG_TY")
def hoa_don_detail(ma_hoa_don):
    hd = db.query_one(
        """SELECT hd.*, ct.ten_cong_ty, ct.ma_so_thue, ct.dia_chi
           FROM HOA_DON hd JOIN CONG_TY ct ON ct.ma_cong_ty=hd.ma_cong_ty
           WHERE hd.ma_hoa_don=:id""",
        {"id": ma_hoa_don},
    )
    if not hd:
        flash("Khong tim thay hoa don.", "danger")
        return redirect(url_for("finance.hoa_don_list"))
    # CONG_TY chi duoc xem hoa don cua chinh cong ty minh.
    if current_user.vai_tro == "CONG_TY" and hd["ma_cong_ty"] != current_user.ma_cong_ty:
        from flask import abort
        abort(403)
    chi_tiet = db.query_all(
        "SELECT * FROM CHI_TIET_HOA_DON WHERE ma_hoa_don=:id", {"id": ma_hoa_don}
    )
    return render_template("hoa_don_detail.html", hd=hd, chi_tiet=chi_tiet)


@bp.route("/hoa-don/<int:ma_hoa_don>/thanh-toan", methods=["POST"])
@roles_required()  # ADMIN only
def hoa_don_thanh_toan(ma_hoa_don):
    db.call_proc("sp_thanh_toan_hoa_don", [ma_hoa_don])
    flash("Da danh dau hoa don da thanh toan.", "success")
    return redirect(url_for("finance.hoa_don_detail", ma_hoa_don=ma_hoa_don))


@bp.route("/hoa-don/tao-thang", methods=["POST"])
@roles_required()  # ADMIN only
def hoa_don_tao_thang():
    thang = request.form.get("thang", type=int)
    nam = request.form.get("nam", type=int)
    if not thang or not nam:
        flash("Thieu thang/nam.", "danger")
        return redirect(url_for("finance.hoa_don_list"))

    # Toan bo logic tinh hoa don nam trong stored procedure sp_tao_hoa_don_tat_ca
    # (goi sp_tao_hoa_don_thang cho tung cong ty, moi hoa don la mot giao dich).
    out = db.call_proc("sp_tao_hoa_don_tat_ca", [thang, nam, 0])
    created = out[2]

    if created:
        flash(f"Da tao {created} hoa don cho thang {thang}/{nam}.", "success")
    else:
        flash(f"Khong co hoa don moi (co the da ton tai) cho thang {thang}/{nam}.", "info")
    return redirect(url_for("finance.hoa_don_list", thang=thang, nam=nam))


# --------------------------------------------------------------------------
# Payroll
# --------------------------------------------------------------------------
@bp.route("/luong")
@roles_required("BQL")
def luong_list():
    # ADMIN xem luong tat ca nhan vien toa nha.
    # BQL chi xem luong cua CHINH MINH.
    # NVCT / CONG_TY khong duoc xem.
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
            {where} ORDER BY l.tong_luong DESC""",
        params,
    )
    return render_template("luong_list.html", rows=rows, thang=thang, nam=nam, is_self=is_self)


@bp.route("/luong/tinh-thang", methods=["POST"])
@roles_required()  # ADMIN only
def luong_tinh_thang():
    thang = request.form.get("thang", type=int)
    nam = request.form.get("nam", type=int)
    if not thang or not nam:
        flash("Thieu thang/nam.", "danger")
        return redirect(url_for("finance.luong_list"))

    # Toan bo logic tinh luong nam trong stored procedure sp_tinh_luong_thang (mot giao dich).
    out = db.call_proc("sp_tinh_luong_thang", [thang, nam, 0])
    created = out[2]

    if created:
        flash(f"Da tinh luong cho {created} nhan vien thang {thang}/{nam}.", "success")
    else:
        flash("Khong co bang luong moi (co the da tinh, hoac chua phan cong).", "info")
    return redirect(url_for("finance.luong_list", thang=thang, nam=nam))


@bp.route("/luong/<int:ma_luong>/chi", methods=["POST"])
@roles_required()  # ADMIN only
def luong_chi(ma_luong):
    db.execute("UPDATE LUONG_NHAN_VIEN SET trang_thai='DA_CHI' WHERE ma_luong=:id", {"id": ma_luong})
    flash("Da danh dau da chi luong.", "success")
    return redirect(request.referrer or url_for("finance.luong_list"))


# --------------------------------------------------------------------------
# Reports (P&L)
# --------------------------------------------------------------------------
@bp.route("/bao-cao")
@roles_required()
def bao_cao():
    nam = request.args.get("nam", type=int) or 2026
    data = []
    for thang in range(1, 13):
        thu = db.scalar(
            "SELECT COALESCE(SUM(tong_tien),0) FROM HOA_DON WHERE thang=:t AND nam=:n",
            {"t": thang, "n": nam},
        ) or 0
        luong = db.scalar(
            "SELECT COALESCE(SUM(tong_luong),0) FROM LUONG_NHAN_VIEN WHERE thang=:t AND nam=:n",
            {"t": thang, "n": nam},
        ) or 0
        chi_vh = db.scalar(
            "SELECT COALESCE(SUM(so_tien),0) FROM CHI_PHI_TOA_NHA "
            "WHERE MONTH(ngay_phat_sinh)=:t AND YEAR(ngay_phat_sinh)=:n",
            {"t": thang, "n": nam},
        ) or 0
        chi = float(luong) + float(chi_vh)
        data.append({
            "thang": thang, "thu": float(thu), "luong": float(luong),
            "chi_vh": float(chi_vh), "chi": chi, "loi_nhuan": float(thu) - chi,
        })
    tong = {
        "thu": sum(d["thu"] for d in data),
        "chi": sum(d["chi"] for d in data),
        "loi_nhuan": sum(d["loi_nhuan"] for d in data),
    }
    return render_template("bao_cao.html", data=data, tong=tong, nam=nam)

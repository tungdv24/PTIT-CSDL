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
@login_required
def hoa_don_list():
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
@login_required
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
    chi_tiet = db.query_all(
        "SELECT * FROM CHI_TIET_HOA_DON WHERE ma_hoa_don=:id", {"id": ma_hoa_don}
    )
    return render_template("hoa_don_detail.html", hd=hd, chi_tiet=chi_tiet)


@bp.route("/hoa-don/<int:ma_hoa_don>/thanh-toan", methods=["POST"])
@roles_required("QUAN_LY")
def hoa_don_thanh_toan(ma_hoa_don):
    db.execute(
        "UPDATE HOA_DON SET trang_thai_thanh_toan='DA_THANH_TOAN' WHERE ma_hoa_don=:id",
        {"id": ma_hoa_don},
    )
    flash("Da danh dau hoa don da thanh toan.", "success")
    return redirect(url_for("finance.hoa_don_detail", ma_hoa_don=ma_hoa_don))


@bp.route("/hoa-don/tao-thang", methods=["POST"])
@roles_required("QUAN_LY")
def hoa_don_tao_thang():
    thang = request.form.get("thang", type=int)
    nam = request.form.get("nam", type=int)
    if not thang or not nam:
        flash("Thieu thang/nam.", "danger")
        return redirect(url_for("finance.hoa_don_list"))

    created = 0
    cong_tys = db.query_all("SELECT * FROM CONG_TY WHERE trang_thai='DANG_THUE'")
    for ct in cong_tys:
        ma_cty = ct["ma_cong_ty"]
        # Skip if invoice already exists for this company/period (unique key).
        exists = db.query_one(
            "SELECT ma_hoa_don FROM HOA_DON WHERE ma_cong_ty=:c AND thang=:t AND nam=:n",
            {"c": ma_cty, "t": thang, "n": nam},
        )
        if exists:
            continue

        line_items = []  # (loai, noi_dung, so_luong, don_gia, thanh_tien, ma_ct_hd, ma_dk)

        # 1) Office rent from active contract details
        ct_hds = db.query_all(
            """SELECT cthd.ma_chi_tiet, cthd.don_gia_thue_m2, vp.dien_tich, vp.ky_hieu_van_phong
               FROM CHI_TIET_HOP_DONG cthd
               JOIN HOP_DONG_THUE hdt ON hdt.ma_hop_dong=cthd.ma_hop_dong
               JOIN VAN_PHONG vp ON vp.ma_van_phong=cthd.ma_van_phong
               WHERE hdt.ma_cong_ty=:c AND hdt.trang_thai='HIEU_LUC'""",
            {"c": ma_cty},
        )
        tien_thue = 0.0
        for r in ct_hds:
            thanh_tien = float(r["dien_tich"]) * float(r["don_gia_thue_m2"])
            tien_thue += thanh_tien
            line_items.append((
                "TIEN_THUE_PHONG",
                f"Thue phong {r['ky_hieu_van_phong']} ({r['dien_tich']}m2)",
                float(r["dien_tich"]), float(r["don_gia_thue_m2"]), thanh_tien,
                r["ma_chi_tiet"], None,
            ))

        # 2) Services registered by the company
        dks = db.query_all(
            """SELECT dk.ma_dang_ky, dk.don_gia, dv.ten_dich_vu, dv.cach_tinh_phi
               FROM DANG_KY_DICH_VU dk JOIN DICH_VU dv ON dv.ma_dich_vu=dk.ma_dich_vu
               WHERE dk.ma_cong_ty=:c AND dk.trang_thai='DANG_DUNG'""",
            {"c": ma_cty},
        )
        # total office area (for per-area services) and active headcount
        tong_dt = db.scalar(
            """SELECT COALESCE(SUM(vp.dien_tich),0) FROM CHI_TIET_HOP_DONG cthd
               JOIN HOP_DONG_THUE hdt ON hdt.ma_hop_dong=cthd.ma_hop_dong
               JOIN VAN_PHONG vp ON vp.ma_van_phong=cthd.ma_van_phong
               WHERE hdt.ma_cong_ty=:c AND hdt.trang_thai='HIEU_LUC'""",
            {"c": ma_cty},
        ) or 0
        so_nguoi = db.scalar(
            "SELECT COUNT(*) FROM NHAN_VIEN_CONG_TY WHERE ma_cong_ty=:c AND trang_thai='HOAT_DONG'",
            {"c": ma_cty},
        ) or 0

        tien_dv = 0.0
        for dk in dks:
            cach = dk["cach_tinh_phi"]
            don_gia = float(dk["don_gia"])
            if cach == "THEO_DIEN_TICH":
                sl = float(tong_dt); tt = sl * don_gia
            elif cach == "THEO_DAU_NGUOI":
                sl = float(so_nguoi); tt = sl * don_gia
            elif cach == "TRON_GOI":
                sl = 1.0; tt = don_gia
            elif cach == "THEO_LUOT":
                # Sum actual usage in the month for this registration
                agg = db.query_one(
                    """SELECT COALESCE(SUM(so_luong),0) AS sl, COALESCE(SUM(thanh_tien),0) AS tt
                       FROM SU_DUNG_DICH_VU
                       WHERE ma_dang_ky=:dk AND MONTH(ngay_su_dung)=:t AND YEAR(ngay_su_dung)=:n""",
                    {"dk": dk["ma_dang_ky"], "t": thang, "n": nam},
                )
                sl = float(agg["sl"]); tt = float(agg["tt"])
            else:
                sl = 0.0; tt = 0.0
            if tt > 0:
                tien_dv += tt
                line_items.append((
                    "TIEN_DICH_VU", f"{dk['ten_dich_vu']}",
                    sl, don_gia, tt, None, dk["ma_dang_ky"],
                ))

        tong_tien = tien_thue + tien_dv
        if tong_tien <= 0:
            continue

        so_hoa_don = f"INV-{nam}{thang:02d}-CT{ma_cty:02d}"
        ma_hoa_don = db.execute(
            """INSERT INTO HOA_DON
               (so_hoa_don, ma_cong_ty, thang, nam, tien_thue_van_phong, tien_dich_vu, tong_tien)
               VALUES (:s,:c,:t,:n,:tt,:td,:tong)""",
            {"s": so_hoa_don, "c": ma_cty, "t": thang, "n": nam,
             "tt": tien_thue, "td": tien_dv, "tong": tong_tien},
        )
        for (loai, nd, sl, dg, tt, ma_ct, ma_dk) in line_items:
            db.execute(
                """INSERT INTO CHI_TIET_HOA_DON
                   (ma_hoa_don, ma_chi_tiet_hop_dong, ma_dang_ky, loai_chi_phi, noi_dung, so_luong, don_gia, thanh_tien)
                   VALUES (:h,:ct,:dk,:loai,:nd,:sl,:dg,:tt)""",
                {"h": ma_hoa_don, "ct": ma_ct, "dk": ma_dk, "loai": loai,
                 "nd": nd, "sl": sl, "dg": dg, "tt": tt},
            )
        created += 1

    if created:
        flash(f"Da tao {created} hoa don cho thang {thang}/{nam}.", "success")
    else:
        flash(f"Khong co hoa don moi (co the da ton tai) cho thang {thang}/{nam}.", "info")
    return redirect(url_for("finance.hoa_don_list", thang=thang, nam=nam))


# --------------------------------------------------------------------------
# Payroll
# --------------------------------------------------------------------------
@bp.route("/luong")
@login_required
def luong_list():
    thang = request.args.get("thang", type=int) or 4
    nam = request.args.get("nam", type=int) or 2026
    rows = db.query_all(
        """SELECT l.*, nv.ho_ten, nv.ma_so_nhan_vien FROM LUONG_NHAN_VIEN l
           JOIN NHAN_VIEN_TOA_NHA nv ON nv.ma_nhan_vien_toa_nha=l.ma_nhan_vien_toa_nha
           WHERE l.thang=:t AND l.nam=:n ORDER BY l.tong_luong DESC""",
        {"t": thang, "n": nam},
    )
    return render_template("luong_list.html", rows=rows, thang=thang, nam=nam)


@bp.route("/luong/tinh-thang", methods=["POST"])
@roles_required("QUAN_LY")
def luong_tinh_thang():
    thang = request.form.get("thang", type=int)
    nam = request.form.get("nam", type=int)
    if not thang or not nam:
        flash("Thieu thang/nam.", "danger")
        return redirect(url_for("finance.luong_list"))

    created = 0
    # Each assignment in the month gives position (salary + rate) and optional service.
    pcs = db.query_all(
        """SELECT pc.ma_nhan_vien_toa_nha, pc.ma_dich_vu,
                  vt.luong_co_ban, vt.ty_le_doanh_thu
           FROM PHAN_CONG_CONG_VIEC pc
           JOIN VI_TRI_CONG_VIEC vt ON vt.ma_vi_tri=pc.ma_vi_tri
           WHERE pc.thang=:t AND pc.nam=:n""",
        {"t": thang, "n": nam},
    )
    for pc in pcs:
        nv = pc["ma_nhan_vien_toa_nha"]
        exists = db.query_one(
            "SELECT ma_luong FROM LUONG_NHAN_VIEN WHERE ma_nhan_vien_toa_nha=:nv AND thang=:t AND nam=:n",
            {"nv": nv, "t": thang, "n": nam},
        )
        if exists:
            continue
        # Revenue of the assigned service in the month (from invoices' service lines).
        doanh_thu = 0.0
        if pc["ma_dich_vu"]:
            doanh_thu = db.scalar(
                """SELECT COALESCE(SUM(ct.thanh_tien),0)
                   FROM CHI_TIET_HOA_DON ct
                   JOIN HOA_DON hd ON hd.ma_hoa_don=ct.ma_hoa_don
                   JOIN DANG_KY_DICH_VU dk ON dk.ma_dang_ky=ct.ma_dang_ky
                   WHERE dk.ma_dich_vu=:dv AND hd.thang=:t AND hd.nam=:n""",
                {"dv": pc["ma_dich_vu"], "t": thang, "n": nam},
            ) or 0
        luong_cb = float(pc["luong_co_ban"])
        ty_le = float(pc["ty_le_doanh_thu"])
        thuong = float(doanh_thu) * ty_le / 100.0
        tong = luong_cb + thuong
        db.execute(
            """INSERT INTO LUONG_NHAN_VIEN
               (ma_nhan_vien_toa_nha, thang, nam, luong_co_ban, doanh_thu_dich_vu, tien_thuong, tong_luong)
               VALUES (:nv,:t,:n,:cb,:dt,:th,:tong)""",
            {"nv": nv, "t": thang, "n": nam, "cb": luong_cb,
             "dt": float(doanh_thu), "th": thuong, "tong": tong},
        )
        created += 1

    if created:
        flash(f"Da tinh luong cho {created} nhan vien thang {thang}/{nam}.", "success")
    else:
        flash("Khong co bang luong moi (co the da tinh, hoac chua phan cong).", "info")
    return redirect(url_for("finance.luong_list", thang=thang, nam=nam))


@bp.route("/luong/<int:ma_luong>/chi", methods=["POST"])
@roles_required("QUAN_LY")
def luong_chi(ma_luong):
    db.execute("UPDATE LUONG_NHAN_VIEN SET trang_thai='DA_CHI' WHERE ma_luong=:id", {"id": ma_luong})
    flash("Da danh dau da chi luong.", "success")
    return redirect(request.referrer or url_for("finance.luong_list"))


# --------------------------------------------------------------------------
# Reports (P&L)
# --------------------------------------------------------------------------
@bp.route("/bao-cao")
@login_required
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

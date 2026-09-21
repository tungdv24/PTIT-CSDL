"""Bao cao TONG HOP TOAN HE THONG - chi tru so HN (doc VIEW FEDERATED)."""
from flask import Blueprint, render_template, request
from flask_login import current_user

from .. import db
from ..auth import head_office_only

bp = Blueprint("report", __name__, url_prefix="/tong-hop")


@bp.route("/cong-ty")
@head_office_only
def cong_ty_toan_quoc():
    # VW_Global_CONG_TY gop du lieu HN (cuc bo) + DN + HCM (qua FEDERATED)
    rows = db.query_all("SELECT * FROM VW_Global_CONG_TY ORDER BY chi_nhanh, ma_cong_ty",
                        khu_vuc="HN")
    return render_template("global_cong_ty.html", rows=rows)


@bp.route("/nhan-vien-toa-nha")
@head_office_only
def nhan_vien_toan_quoc():
    rows = db.query_all("SELECT * FROM VW_Global_NHAN_VIEN_TOA_NHA ORDER BY chi_nhanh, ma_nhan_vien_toa_nha",
                        khu_vuc="HN")
    return render_template("global_nhan_vien.html", rows=rows)


@bp.route("/hoa-don")
@head_office_only
def hoa_don_toan_quoc():
    thang = request.args.get("thang", type=int) or 4
    nam = request.args.get("nam", type=int) or 2026
    rows = db.query_all(
        """SELECT * FROM VW_Global_HOA_DON WHERE thang=:t AND nam=:n
           ORDER BY chi_nhanh, tong_tien DESC""",
        {"t": thang, "n": nam}, khu_vuc="HN",
    )
    # Tong hop theo chi nhanh (goi stored procedure phan tan)
    tong_theo_cn = db.query_all(
        """SELECT chi_nhanh, COUNT(*) AS so_hd, COALESCE(SUM(tong_tien),0) AS doanh_thu
           FROM VW_Global_HOA_DON WHERE thang=:t AND nam=:n GROUP BY chi_nhanh""",
        {"t": thang, "n": nam}, khu_vuc="HN",
    )
    tong_toan_quoc = sum(float(r["doanh_thu"]) for r in tong_theo_cn)
    return render_template("global_hoa_don.html", rows=rows, thang=thang, nam=nam,
                           tong_theo_cn=tong_theo_cn, tong_toan_quoc=tong_toan_quoc)

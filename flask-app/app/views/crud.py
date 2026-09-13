"""Config-driven CRUD for the core master/relationship entities.

Each entry describes a table: its primary key, display columns, and editable
fields. Foreign-key fields render as <select> populated from a lookup query.
This keeps all list/create/edit/delete logic in one place.
"""
from flask import Blueprint, render_template, request, redirect, url_for, flash, abort
from flask_login import login_required, current_user
from sqlalchemy.exc import SQLAlchemyError

from .. import db


def F(name, label, type="text", required=False, options=None, fk=None, help=None):
    """Field descriptor."""
    return {
        "name": name, "label": label, "type": type, "required": required,
        "options": options, "fk": fk, "help": help,
    }


# fk: (sql, value_col, label_col) -> builds a select dropdown
ENTITIES = {
    "cong-ty": {
        "table": "CONG_TY", "pk": "ma_cong_ty", "title": "Cong ty",
        "roles": (),  # ADMIN only
        "list_cols": [("ma_cong_ty", "Ma"), ("ma_so_cong_ty", "Ma CT"), ("ma_so_thue", "MST"), ("ten_cong_ty", "Ten cong ty"),
                      ("nguoi_dai_dien", "Dai dien"), ("so_dien_thoai", "SDT"), ("trang_thai", "Trang thai")],
        "fields": [
            F("ma_so_cong_ty", "Ma so cong ty (dung de dang nhap)", required=True),
            F("ma_so_thue", "Ma so thue", required=True),
            F("ten_cong_ty", "Ten cong ty", required=True),
            F("nguoi_dai_dien", "Nguoi dai dien", required=True),
            F("so_dien_thoai", "So dien thoai", required=True),
            F("email", "Email", required=True),
            F("dia_chi", "Dia chi"),
            F("trang_thai", "Trang thai", type="select", options=["DANG_THUE", "DA_CHUYEN_DI"]),
        ],
    },
    "van-phong": {
        "table": "VAN_PHONG", "pk": "ma_van_phong", "title": "Van phong",
        "roles": (),  # ADMIN only
        "list_cols": [("ma_van_phong", "Ma"), ("ky_hieu_van_phong", "Ky hieu"), ("tang", "Tang"),
                      ("dien_tich", "Dien tich"), ("don_gia_m2", "Don gia/m2"), ("trang_thai", "Trang thai")],
        "fields": [
            F("ky_hieu_van_phong", "Ky hieu van phong", required=True),
            F("tang", "Tang", type="number", required=True),
            F("vi_tri", "Vi tri"),
            F("dien_tich", "Dien tich (m2)", type="number", required=True),
            F("don_gia_m2", "Don gia / m2", type="number", required=True),
            F("trang_thai", "Trang thai", type="select", options=["TRONG", "DA_THUE", "BAO_TRI"]),
        ],
    },
    "dich-vu": {
        "table": "DICH_VU", "pk": "ma_dich_vu", "title": "Dich vu",
        "roles": (),  # ADMIN only
        "list_cols": [("ma_dich_vu", "Ma"), ("ma_so_dich_vu", "Ma DV"), ("ten_dich_vu", "Ten"),
                      ("loai_dich_vu", "Loai"), ("cach_tinh_phi", "Cach tinh"), ("don_gia_co_ban", "Don gia")],
        "fields": [
            F("ma_so_dich_vu", "Ma so dich vu", required=True),
            F("ten_dich_vu", "Ten dich vu", required=True),
            F("loai_dich_vu", "Loai dich vu", type="select", options=["CO_DINH", "BIEN_DOI"], required=True),
            F("cach_tinh_phi", "Cach tinh phi", type="select",
              options=["THEO_DIEN_TICH", "THEO_DAU_NGUOI", "THEO_LUOT", "TRON_GOI"], required=True),
            F("don_gia_co_ban", "Don gia co ban", type="number", required=True),
            F("don_vi_tinh", "Don vi tinh", required=True),
            F("trang_thai", "Trang thai", type="select", options=["HOAT_DONG", "NGUNG_CUNG_CAP"]),
        ],
    },
    "vi-tri": {
        "table": "VI_TRI_CONG_VIEC", "pk": "ma_vi_tri", "title": "Vi tri cong viec",
        "roles": (),  # ADMIN only
        "list_cols": [("ma_vi_tri", "Ma"), ("ma_so_vi_tri", "Ma VT"), ("ten_vi_tri", "Ten vi tri"),
                      ("luong_co_ban", "Luong CB"), ("ty_le_doanh_thu", "% Doanh thu")],
        "fields": [
            F("ma_so_vi_tri", "Ma so vi tri", required=True),
            F("ten_vi_tri", "Ten vi tri", required=True),
            F("luong_co_ban", "Luong co ban", type="number", required=True),
            F("ty_le_doanh_thu", "Ty le doanh thu (%)", type="number"),
            F("mo_ta", "Mo ta", type="textarea"),
        ],
    },
    "nhan-vien-toa-nha": {
        "table": "NHAN_VIEN_TOA_NHA", "pk": "ma_nhan_vien_toa_nha", "title": "Nhan vien toa nha",
        "roles": (),  # ADMIN only
        "list_cols": [("ma_nhan_vien_toa_nha", "Ma"), ("ma_so_nhan_vien", "Ma NV"), ("ho_ten", "Ho ten"),
                      ("gioi_tinh", "Gioi tinh"), ("so_dien_thoai", "SDT"), ("trang_thai", "Trang thai")],
        "fields": [
            F("ma_so_nhan_vien", "Ma so nhan vien", required=True),
            F("ho_ten", "Ho ten", required=True),
            F("ngay_sinh", "Ngay sinh", type="date"),
            F("gioi_tinh", "Gioi tinh", type="select", options=["NAM", "NU", "KHAC"]),
            F("so_dien_thoai", "So dien thoai", required=True),
            F("email", "Email"),
            F("ngay_vao_lam", "Ngay vao lam", type="date", required=True),
            F("trang_thai", "Trang thai", type="select", options=["DANG_LAM", "DA_NGHI"]),
        ],
    },
    "nhan-vien-cong-ty": {
        "table": "NHAN_VIEN_CONG_TY", "pk": "ma_nhan_vien", "title": "Nhan vien cong ty",
        "roles": (),  # ADMIN only
        "list_cols": [("ma_nhan_vien", "Ma"), ("ma_so_nhan_vien", "Ma NV"), ("ho_ten", "Ho ten"),
                      ("ten_cong_ty", "Cong ty"), ("chuc_vu", "Chuc vu"), ("trang_thai", "Trang thai")],
        "list_join": "LEFT JOIN CONG_TY ct ON ct.ma_cong_ty = t.ma_cong_ty",
        "list_extra": "ct.ten_cong_ty",
        "fields": [
            F("ma_so_nhan_vien", "Ma so nhan vien", required=True),
            F("ma_cong_ty", "Cong ty", type="select", required=True,
              fk=("SELECT ma_cong_ty, ten_cong_ty FROM CONG_TY ORDER BY ten_cong_ty", "ma_cong_ty", "ten_cong_ty")),
            F("ho_ten", "Ho ten", required=True),
            F("ngay_sinh", "Ngay sinh", type="date"),
            F("gioi_tinh", "Gioi tinh", type="select", options=["NAM", "NU", "KHAC"]),
            F("so_dien_thoai", "So dien thoai"),
            F("email", "Email"),
            F("chuc_vu", "Chuc vu"),
            F("ngay_bat_dau", "Ngay bat dau", type="date", required=True),
            F("ngay_ket_thuc", "Ngay ket thuc", type="date"),
            F("trang_thai", "Trang thai", type="select", options=["HOAT_DONG", "DA_NGHI_VIEC"]),
        ],
    },
    "hop-dong": {
        "table": "HOP_DONG_THUE", "pk": "ma_hop_dong", "title": "Hop dong thue",
        "roles": (),  # ADMIN only
        "list_cols": [("ma_hop_dong", "Ma"), ("so_hop_dong", "So HD"), ("ten_cong_ty", "Cong ty"),
                      ("ngay_bat_dau", "Tu"), ("ngay_ket_thuc", "Den"), ("trang_thai", "Trang thai")],
        "list_join": "LEFT JOIN CONG_TY ct ON ct.ma_cong_ty = t.ma_cong_ty",
        "list_extra": "ct.ten_cong_ty",
        "fields": [
            F("so_hop_dong", "So hop dong", required=True),
            F("ma_cong_ty", "Cong ty", type="select", required=True,
              fk=("SELECT ma_cong_ty, ten_cong_ty FROM CONG_TY ORDER BY ten_cong_ty", "ma_cong_ty", "ten_cong_ty")),
            F("ngay_bat_dau", "Ngay bat dau", type="date", required=True),
            F("ngay_ket_thuc", "Ngay ket thuc", type="date", required=True),
            F("tien_dat_coc", "Tien dat coc", type="number"),
            F("trang_thai", "Trang thai", type="select", options=["HIEU_LUC", "HET_HAN", "DA_THANH_LY"]),
        ],
    },
    "dang-ky-dich-vu": {
        "table": "DANG_KY_DICH_VU", "pk": "ma_dang_ky", "title": "Dang ky dich vu",
        "roles": (),  # ADMIN only
        "list_cols": [("ma_dang_ky", "Ma"), ("ten_cong_ty", "Cong ty"), ("ten_dich_vu", "Dich vu"),
                      ("don_gia", "Don gia"), ("trang_thai", "Trang thai")],
        "list_join": "LEFT JOIN CONG_TY ct ON ct.ma_cong_ty=t.ma_cong_ty LEFT JOIN DICH_VU dv ON dv.ma_dich_vu=t.ma_dich_vu",
        "list_extra": "ct.ten_cong_ty, dv.ten_dich_vu",
        "fields": [
            F("ma_cong_ty", "Cong ty", type="select", required=True,
              fk=("SELECT ma_cong_ty, ten_cong_ty FROM CONG_TY ORDER BY ten_cong_ty", "ma_cong_ty", "ten_cong_ty")),
            F("ma_dich_vu", "Dich vu", type="select", required=True,
              fk=("SELECT ma_dich_vu, ten_dich_vu FROM DICH_VU ORDER BY ten_dich_vu", "ma_dich_vu", "ten_dich_vu")),
            F("ngay_bat_dau", "Ngay bat dau", type="date", required=True),
            F("ngay_ket_thuc", "Ngay ket thuc", type="date"),
            F("don_gia", "Don gia", type="number", required=True),
            F("trang_thai", "Trang thai", type="select", options=["DANG_DUNG", "TAM_DUNG", "DA_HUY"]),
        ],
    },
    "loai-chi-phi": {
        "table": "LOAI_CHI_PHI", "pk": "ma_loai_chi_phi", "title": "Loai chi phi",
        "roles": (),  # ADMIN only
        "list_cols": [("ma_loai_chi_phi", "Ma"), ("ten_loai_chi_phi", "Ten loai"), ("mo_ta", "Mo ta")],
        "fields": [
            F("ten_loai_chi_phi", "Ten loai chi phi", required=True),
            F("mo_ta", "Mo ta", type="textarea"),
        ],
    },
    "chi-phi": {
        "table": "CHI_PHI_TOA_NHA", "pk": "ma_chi_phi", "title": "Chi phi toa nha",
        "roles": (),  # ADMIN only
        "list_cols": [("ma_chi_phi", "Ma"), ("ten_loai_chi_phi", "Loai"), ("noi_dung", "Noi dung"),
                      ("ngay_phat_sinh", "Ngay"), ("so_tien", "So tien")],
        "list_join": "LEFT JOIN LOAI_CHI_PHI lcp ON lcp.ma_loai_chi_phi = t.ma_loai_chi_phi",
        "list_extra": "lcp.ten_loai_chi_phi",
        "fields": [
            F("ma_loai_chi_phi", "Loai chi phi", type="select", required=True,
              fk=("SELECT ma_loai_chi_phi, ten_loai_chi_phi FROM LOAI_CHI_PHI ORDER BY ten_loai_chi_phi",
                  "ma_loai_chi_phi", "ten_loai_chi_phi")),
            F("noi_dung", "Noi dung", required=True),
            F("ngay_phat_sinh", "Ngay phat sinh", type="date", required=True),
            F("so_tien", "So tien", type="number", required=True),
            F("ghi_chu", "Ghi chu", type="textarea"),
        ],
    },
}


def _resolve_fk_options(fields):
    for f in fields:
        if f.get("fk"):
            sql, val_col, lbl_col = f["fk"]
            rows = db.query_all(sql)
            f["fk_options"] = [(r[val_col], r[lbl_col]) for r in rows]
    return fields


def _collect_form(fields):
    data = {}
    for f in fields:
        raw = request.form.get(f["name"], "").strip()
        if raw == "":
            data[f["name"]] = None
        else:
            data[f["name"]] = raw
    return data


def make_crud_blueprints():
    blueprints = []
    for slug, cfg in ENTITIES.items():
        bp = _build_blueprint(slug, cfg)
        blueprints.append(bp)
    return blueprints


def _build_blueprint(slug, cfg):
    bp = Blueprint(f"crud_{slug.replace('-', '_')}", __name__, url_prefix=f"/{slug}")
    table, pk = cfg["table"], cfg["pk"]
    allowed_roles = cfg.get("roles", ())

    def _guard():
        if current_user.vai_tro not in allowed_roles and not current_user.is_admin:
            abort(403)

    @bp.route("/")
    @login_required
    def list_view():
        _guard()
        extra = (", " + cfg["list_extra"]) if cfg.get("list_extra") else ""
        join = cfg.get("list_join", "")
        rows = db.query_all(
            f"SELECT t.*{extra} FROM {table} t {join} ORDER BY t.{pk} DESC"
        )
        return render_template("crud_list.html", slug=slug, cfg=cfg, rows=rows)

    @bp.route("/new", methods=["GET", "POST"])
    @login_required
    def create_view():
        _guard()
        fields = _resolve_fk_options([dict(f) for f in cfg["fields"]])
        if request.method == "POST":
            data = _collect_form(cfg["fields"])
            cols = ", ".join(data.keys())
            placeholders = ", ".join(f":{k}" for k in data.keys())
            try:
                db.execute(f"INSERT INTO {table} ({cols}) VALUES ({placeholders})", data)
                flash(f"Da them {cfg['title']}.", "success")
                return redirect(url_for(f"crud_{slug.replace('-', '_')}.list_view"))
            except SQLAlchemyError as exc:
                flash(f"Loi: {getattr(exc, 'orig', exc)}", "danger")
        return render_template("crud_form.html", slug=slug, cfg=cfg, fields=fields, row=None)

    @bp.route("/<int:item_id>/edit", methods=["GET", "POST"])
    @login_required
    def edit_view(item_id):
        _guard()
        fields = _resolve_fk_options([dict(f) for f in cfg["fields"]])
        row = db.query_one(f"SELECT * FROM {table} WHERE {pk}=:id", {"id": item_id})
        if not row:
            abort(404)
        if request.method == "POST":
            data = _collect_form(cfg["fields"])
            sets = ", ".join(f"{k}=:{k}" for k in data.keys())
            data["_id"] = item_id
            try:
                db.execute(f"UPDATE {table} SET {sets} WHERE {pk}=:_id", data)
                flash(f"Da cap nhat {cfg['title']}.", "success")
                return redirect(url_for(f"crud_{slug.replace('-', '_')}.list_view"))
            except SQLAlchemyError as exc:
                flash(f"Loi: {getattr(exc, 'orig', exc)}", "danger")
        return render_template("crud_form.html", slug=slug, cfg=cfg, fields=fields, row=row)

    @bp.route("/<int:item_id>/delete", methods=["POST"])
    @login_required
    def delete_view(item_id):
        _guard()
        try:
            db.execute(f"DELETE FROM {table} WHERE {pk}=:id", {"id": item_id})
            flash(f"Da xoa {cfg['title']}.", "success")
        except SQLAlchemyError as exc:
            flash(f"Khong the xoa (co du lieu lien quan): {getattr(exc, 'orig', exc)}", "danger")
        return redirect(url_for(f"crud_{slug.replace('-', '_')}.list_view"))

    return bp

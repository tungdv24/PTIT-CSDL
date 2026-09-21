"""CRUD cuc bo tren node cua chi nhanh dang dang nhap.

ADMIN (HN) va cac chi nhanh deu thao tac tren node cua minh. Vi du: dang nhap chi
nhanh DN thi moi thay/sua du lieu cua DN (vi node DN chi chua du lieu DN).
"""
from flask import Blueprint, render_template, request, redirect, url_for, flash, abort
from flask_login import login_required, current_user
from sqlalchemy.exc import SQLAlchemyError

from .. import db


def F(name, label, type="text", required=False, options=None, fk=None):
    return {"name": name, "label": label, "type": type, "required": required,
            "options": options, "fk": fk}


ENTITIES = {
    "cong-ty": {
        "table": "CONG_TY", "pk": "ma_cong_ty", "title": "Cong ty",
        "list_cols": [("ma_cong_ty", "Ma"), ("ma_so_cong_ty", "Ma CT"), ("ten_cong_ty", "Ten"),
                      ("khu_vuc", "Khu vuc"), ("so_dien_thoai", "SDT"), ("trang_thai", "Trang thai")],
        "fields": [
            F("ma_so_cong_ty", "Ma so cong ty", required=True),
            F("ma_so_thue", "Ma so thue", required=True),
            F("ten_cong_ty", "Ten cong ty", required=True),
            F("nguoi_dai_dien", "Nguoi dai dien", required=True),
            F("so_dien_thoai", "So dien thoai", required=True),
            F("email", "Email", required=True),
            F("dia_chi", "Dia chi"),
            F("khu_vuc", "Khu vuc", type="select", options=["HN", "DN", "HCM"], required=True),
            F("trang_thai", "Trang thai", type="select", options=["DANG_THUE", "DA_CHUYEN_DI"]),
        ],
    },
    "van-phong": {
        "table": "VAN_PHONG", "pk": "ma_van_phong", "title": "Van phong",
        "list_cols": [("ma_van_phong", "Ma"), ("ky_hieu_van_phong", "Ky hieu"), ("tang", "Tang"),
                      ("dien_tich", "Dien tich"), ("khu_vuc", "Khu vuc"), ("trang_thai", "Trang thai")],
        "fields": [
            F("ky_hieu_van_phong", "Ky hieu van phong", required=True),
            F("tang", "Tang", type="number", required=True),
            F("vi_tri", "Vi tri"),
            F("dien_tich", "Dien tich (m2)", type="number", required=True),
            F("don_gia_m2", "Don gia / m2", type="number", required=True),
            F("khu_vuc", "Khu vuc", type="select", options=["HN", "DN", "HCM"], required=True),
            F("trang_thai", "Trang thai", type="select", options=["TRONG", "DA_THUE", "BAO_TRI"]),
        ],
    },
    "nhan-vien-toa-nha": {
        "table": "NHAN_VIEN_TOA_NHA", "pk": "ma_nhan_vien_toa_nha", "title": "Nhan vien toa nha",
        "list_cols": [("ma_nhan_vien_toa_nha", "Ma"), ("ma_so_nhan_vien", "Ma NV"), ("ho_ten", "Ho ten"),
                      ("khu_vuc", "Khu vuc"), ("so_dien_thoai", "SDT"), ("trang_thai", "Trang thai")],
        "fields": [
            F("ma_so_nhan_vien", "Ma so nhan vien", required=True),
            F("ho_ten", "Ho ten", required=True),
            F("ngay_sinh", "Ngay sinh", type="date"),
            F("gioi_tinh", "Gioi tinh", type="select", options=["NAM", "NU", "KHAC"]),
            F("so_dien_thoai", "So dien thoai", required=True),
            F("email", "Email"),
            F("khu_vuc", "Khu vuc", type="select", options=["HN", "DN", "HCM"], required=True),
            F("ngay_vao_lam", "Ngay vao lam", type="date", required=True),
            F("trang_thai", "Trang thai", type="select", options=["DANG_LAM", "DA_NGHI"]),
        ],
    },
    "nhan-vien-cong-ty": {
        "table": "NHAN_VIEN_CONG_TY", "pk": "ma_nhan_vien", "title": "Nhan vien cong ty",
        "list_cols": [("ma_nhan_vien", "Ma"), ("ma_so_nhan_vien", "Ma NV"), ("ho_ten", "Ho ten"),
                      ("chuc_vu", "Chuc vu"), ("trang_thai", "Trang thai")],
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
            F("trang_thai", "Trang thai", type="select", options=["HOAT_DONG", "DA_NGHI_VIEC"]),
        ],
    },
    "hop-dong": {
        "table": "HOP_DONG_THUE", "pk": "ma_hop_dong", "title": "Hop dong thue",
        "list_cols": [("ma_hop_dong", "Ma"), ("so_hop_dong", "So HD"), ("ma_cong_ty", "Cong ty"),
                      ("ngay_bat_dau", "Tu"), ("ngay_ket_thuc", "Den"), ("trang_thai", "Trang thai")],
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
        "list_cols": [("ma_dang_ky", "Ma"), ("ma_cong_ty", "Cong ty"), ("ma_dich_vu", "Dich vu"),
                      ("don_gia", "Don gia"), ("trang_thai", "Trang thai")],
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
    "chi-phi": {
        "table": "CHI_PHI_TOA_NHA", "pk": "ma_chi_phi", "title": "Chi phi toa nha",
        "list_cols": [("ma_chi_phi", "Ma"), ("ma_loai_chi_phi", "Loai"), ("noi_dung", "Noi dung"),
                      ("ngay_phat_sinh", "Ngay"), ("so_tien", "So tien")],
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

# Bang CHI_PHI_TOA_NHA khong co trong schema phan tan toi gian -> loai neu chua tao.
ENTITIES.pop("chi-phi", None)


def _resolve_fk(fields):
    for f in fields:
        if f.get("fk"):
            sql, vc, lc = f["fk"]
            f["fk_options"] = [(r[vc], r[lc]) for r in db.query_all(sql)]
    return fields


def _collect(fields):
    data = {}
    for f in fields:
        raw = request.form.get(f["name"], "").strip()
        data[f["name"]] = raw if raw != "" else None
    return data


def make_crud_blueprints():
    return [_build(slug, cfg) for slug, cfg in ENTITIES.items()]


def _build(slug, cfg):
    bp = Blueprint(f"crud_{slug.replace('-', '_')}", __name__, url_prefix=f"/{slug}")
    table, pk = cfg["table"], cfg["pk"]

    def _guard():
        # Chi ADMIN duoc quan ly du lieu goc (tren node cua ho).
        if not current_user.is_admin:
            abort(403)

    @bp.route("/")
    @login_required
    def list_view():
        _guard()
        rows = db.query_all(f"SELECT * FROM {table} ORDER BY {pk} DESC")
        return render_template("crud_list.html", slug=slug, cfg=cfg, rows=rows)

    @bp.route("/new", methods=["GET", "POST"])
    @login_required
    def create_view():
        _guard()
        fields = _resolve_fk([dict(f) for f in cfg["fields"]])
        if request.method == "POST":
            data = _collect(cfg["fields"])
            cols = ", ".join(data.keys())
            ph = ", ".join(f":{k}" for k in data)
            try:
                db.execute(f"INSERT INTO {table} ({cols}) VALUES ({ph})", data)
                flash(f"Da them {cfg['title']}.", "success")
                return redirect(url_for(f"crud_{slug.replace('-', '_')}.list_view"))
            except SQLAlchemyError as e:
                flash(f"Loi: {getattr(e, 'orig', e)}", "danger")
        return render_template("crud_form.html", slug=slug, cfg=cfg, fields=fields, row=None)

    @bp.route("/<int:item_id>/edit", methods=["GET", "POST"])
    @login_required
    def edit_view(item_id):
        _guard()
        fields = _resolve_fk([dict(f) for f in cfg["fields"]])
        row = db.query_one(f"SELECT * FROM {table} WHERE {pk}=:id", {"id": item_id})
        if not row:
            abort(404)
        if request.method == "POST":
            data = _collect(cfg["fields"])
            sets = ", ".join(f"{k}=:{k}" for k in data)
            data["_id"] = item_id
            try:
                db.execute(f"UPDATE {table} SET {sets} WHERE {pk}=:_id", data)
                flash(f"Da cap nhat {cfg['title']}.", "success")
                return redirect(url_for(f"crud_{slug.replace('-', '_')}.list_view"))
            except SQLAlchemyError as e:
                flash(f"Loi: {getattr(e, 'orig', e)}", "danger")
        return render_template("crud_form.html", slug=slug, cfg=cfg, fields=fields, row=row)

    @bp.route("/<int:item_id>/delete", methods=["POST"])
    @login_required
    def delete_view(item_id):
        _guard()
        try:
            db.execute(f"DELETE FROM {table} WHERE {pk}=:id", {"id": item_id})
            flash(f"Da xoa {cfg['title']}.", "success")
        except SQLAlchemyError as e:
            flash(f"Khong the xoa: {getattr(e, 'orig', e)}", "danger")
        return redirect(url_for(f"crud_{slug.replace('-', '_')}.list_view"))

    return bp

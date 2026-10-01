"""CRUD cuc bo tren node cua chi nhanh dang dang nhap.

ADMIN (HN) va cac chi nhanh deu thao tac tren node cua minh. Vi du: dang nhap chi
nhanh DN thi moi thay/sua du lieu cua DN (vi node DN chi chua du lieu DN).
"""
from flask import Blueprint, render_template, request, redirect, url_for, flash, abort
from flask_login import login_required, current_user
from sqlalchemy.exc import SQLAlchemyError, IntegrityError
from werkzeug.security import generate_password_hash

from .. import db
from ..config import Config

_NODES = Config.NODES


def _tao_tai_khoan(t, ten_dang_nhap, ho_ten, vai_tro, khu_vuc,
                   ma_cong_ty=None, ma_nhan_vien_toa_nha=None, ma_nhan_vien=None):
    """Tao tai khoan dang nhap trong NGUOI_DUNG (chay trong cung transaction `t`).

    Quy uoc demo: mat khau = ten dang nhap (= ma CT-/BQL-/NVCT-). Nho vay them
    cong ty/nhan vien moi la dang nhap duoc ngay, dong bo voi du lieu nghiep vu.
    """
    t.execute(
        """INSERT INTO NGUOI_DUNG
           (ten_dang_nhap, mat_khau_hash, ho_ten, vai_tro, khu_vuc, ma_cong_ty, ma_nhan_vien_toa_nha, ma_nhan_vien)
           VALUES (:u,:h,:ht,:r,:kv,:c,:bql,:nvct)""",
        {"u": ten_dang_nhap, "h": generate_password_hash(ten_dang_nhap), "ht": ho_ten,
         "r": vai_tro, "kv": khu_vuc, "c": ma_cong_ty, "bql": ma_nhan_vien_toa_nha, "nvct": ma_nhan_vien},
    )


def _after_create_cong_ty(new_id, data, t=None):
    """Them cong ty -> tao tai khoan CONG_TY (username = ma_so_cong_ty)."""
    _tao_tai_khoan(t, data["ma_so_cong_ty"], f"Dai dien {data.get('ten_cong_ty','')}",
                   "CONG_TY", data.get("khu_vuc") or db.current_khu_vuc(), ma_cong_ty=new_id)


def _after_create_nvct(new_id, data, t=None):
    """Them nhan vien cong ty -> tao tai khoan NVCT (username = ma_so_nhan_vien)."""
    _tao_tai_khoan(t, data["ma_so_nhan_vien"], data.get("ho_ten", ""),
                   "NVCT", db.current_khu_vuc(),
                   ma_cong_ty=data.get("ma_cong_ty"), ma_nhan_vien=new_id)


class DuplicateError(Exception):
    """Loi trung ma (ma_so_* da ton tai) - de hien thong bao tieng Viet ro rang."""


def _friendly_error(e, cfg):
    """Dich loi DB sang thong bao tieng Viet than thien.

    - 1062 Duplicate entry -> bao trung ma truong UNIQUE.
    - Con lai -> hien phan goc gon gang.
    """
    orig = getattr(e, "orig", None)
    code = orig.args[0] if orig and getattr(orig, "args", None) else None
    if code == 1062:
        return f"Mã bị trùng: {cfg['title']} với mã số này đã tồn tại. Vui lòng dùng mã khác."
    return f"Lỗi: {orig if orig else e}"


def F(name, label, type="text", required=False, options=None, fk=None, prefix=None, pad=None):
    # prefix: tien to co dinh cho ma (vd "CT-", "BQL-", "NVCT-"). Nguoi dung chi go
    # phan so; prefix duoc ghep tu dong khi luu, va tach ra khi hien thi de sua.
    # pad: so chu so cua phan so (them so 0 o dau), vd pad=3 -> "20" thanh "020"
    # cho dong nhat voi du lieu (BQL-020, NVCT-0020, CT-20...).
    return {"name": name, "label": label, "type": type, "required": required,
            "options": options, "fk": fk, "prefix": prefix, "pad": pad}


def _auto_gan_quan_ly(new_id, data, t=None):
    """Sau khi them 1 nhan vien toa nha moi -> (1) tao tai khoan BQL + (2) tu dong
    gan phan cap quan ly. Tat ca chay TRONG CUNG transaction `t` -> nguyen tu.

    Mo hinh: moi chi nhanh (node) 1 quan ly, 2 tang phang.
    - Neu node DA co quan ly (co nguoi la ma_nguoi_quan_ly trong QUAN_LY_NHAN_VIEN)
      -> nhan vien moi la CAP DUOI cua quan ly do.
    - Neu node CHUA co quan ly nao -> nhan vien moi la nguoi dau tien = QUAN LY,
      khong tao quan he (se la quan ly cho nhung nguoi them sau).
    """
    import datetime
    runner = t if t is not None else db
    # (1) Tao tai khoan dang nhap BQL (username = ma_so_nhan_vien)
    if t is not None:
        _tao_tai_khoan(t, data["ma_so_nhan_vien"], data.get("ho_ten", ""),
                       "BQL", data.get("khu_vuc") or db.current_khu_vuc(),
                       ma_nhan_vien_toa_nha=new_id)
    # Tim quan ly hien tai cua node (quan he con hieu luc)
    ql = runner.query_one(
        """SELECT ma_nguoi_quan_ly FROM QUAN_LY_NHAN_VIEN
           WHERE ngay_ket_thuc IS NULL ORDER BY ma_quan_ly LIMIT 1"""
    )
    if ql:
        manager_id = ql["ma_nguoi_quan_ly"]
        # Nhan vien moi khong tu quan ly minh (khong the vi id khac)
        if manager_id != new_id:
            runner.execute(
                """INSERT INTO QUAN_LY_NHAN_VIEN (ma_nhan_vien, ma_nguoi_quan_ly, ngay_bat_dau)
                   VALUES (:nv, :ql, :ngay)""",
                {"nv": new_id, "ql": manager_id, "ngay": datetime.date.today().isoformat()},
            )
    # Neu chua co quan ly -> nguoi nay la quan ly dau tien, khong lam gi.


ENTITIES = {
    "cong-ty": {
        "table": "CONG_TY", "pk": "ma_cong_ty", "title": "Công ty",
        # ma_so_cong_ty phai DUY NHAT tren CA 3 node (khong chi cuc bo).
        "cross_node_unique": "ma_so_cong_ty",
        "after_create": _after_create_cong_ty,   # tao luon tai khoan CONG_TY
        "list_cols": [("ma_cong_ty", "Mã"), ("ma_so_cong_ty", "Mã CT"), ("ten_cong_ty", "Tên"),
                      ("khu_vuc", "Khu vực"), ("so_dien_thoai", "SĐT"), ("trang_thai", "Trạng thái")],
        "fields": [
            F("ma_so_cong_ty", "Mã số công ty", required=True, prefix="CT-", pad=2),
            F("ma_so_thue", "Mã số thuế", required=True),
            F("ten_cong_ty", "Tên công ty", required=True),
            F("nguoi_dai_dien", "Người đại diện", required=True),
            F("so_dien_thoai", "Số điện thoại", required=True),
            F("email", "Email", required=True),
            F("dia_chi", "Địa chỉ"),
            F("khu_vuc", "Khu vực", type="select", options=["HN", "DN", "HCM"], required=True),
            F("trang_thai", "Trạng thái", type="select", options=["DANG_THUE", "DA_CHUYEN_DI"]),
        ],
    },
    "van-phong": {
        "table": "VAN_PHONG", "pk": "ma_van_phong", "title": "Văn phòng",
        "list_cols": [("ma_van_phong", "Mã"), ("ky_hieu_van_phong", "Ký hiệu"), ("tang", "Tầng"),
                      ("dien_tich", "Diện tích"), ("khu_vuc", "Khu vực"), ("trang_thai", "Trạng thái")],
        "fields": [
            F("ky_hieu_van_phong", "Ký hiệu văn phòng", required=True),
            F("tang", "Tầng", type="number", required=True),
            F("vi_tri", "Vị trí"),
            F("dien_tich", "Diện tích (m2)", type="number", required=True),
            F("don_gia_m2", "Đơn giá / m2", type="number", required=True),
            F("khu_vuc", "Khu vực", type="select", options=["HN", "DN", "HCM"], required=True),
            F("trang_thai", "Trạng thái", type="select", options=["TRONG", "DA_THUE", "BAO_TRI"]),
        ],
    },
    "nhan-vien-toa-nha": {
        "table": "NHAN_VIEN_TOA_NHA", "pk": "ma_nhan_vien_toa_nha", "title": "Nhân viên tòa nhà",
        # ma_so_nhan_vien phai DUY NHAT tren CA 3 node (khong chi cuc bo).
        "cross_node_unique": "ma_so_nhan_vien",
        "after_create": _auto_gan_quan_ly,
        "list_cols": [("ma_nhan_vien_toa_nha", "Mã"), ("ma_so_nhan_vien", "Mã NV"), ("ho_ten", "Họ tên"),
                      ("ten_vi_tri", "Vị trí"), ("khu_vuc", "Khu vực"), ("so_dien_thoai", "SĐT"),
                      ("trang_thai", "Trạng thái")],
        "list_sql": """SELECT nv.ma_nhan_vien_toa_nha, nv.ma_so_nhan_vien, nv.ho_ten,
                              v.ten_vi_tri, nv.khu_vuc, nv.so_dien_thoai, nv.trang_thai
                       FROM NHAN_VIEN_TOA_NHA nv
                       LEFT JOIN VI_TRI_CONG_VIEC v ON v.ma_vi_tri = nv.ma_vi_tri
                       ORDER BY nv.ma_nhan_vien_toa_nha DESC""",
        "fields": [
            F("ma_so_nhan_vien", "Mã số nhân viên", required=True, prefix="BQL-", pad=3),
            F("ho_ten", "Họ tên", required=True),
            F("ngay_sinh", "Ngày sinh", type="date"),
            F("gioi_tinh", "Giới tính", type="select", options=["NAM", "NU", "KHAC"]),
            F("so_dien_thoai", "Số điện thoại", required=True),
            F("email", "Email"),
            F("khu_vuc", "Khu vực", type="select", options=["HN", "DN", "HCM"], required=True),
            F("ma_vi_tri", "Vị trí công việc", type="select", required=True,
              fk=("SELECT ma_vi_tri, ten_vi_tri FROM VI_TRI_CONG_VIEC ORDER BY ma_vi_tri",
                  "ma_vi_tri", "ten_vi_tri")),
            F("ngay_vao_lam", "Ngày vào làm", type="date", required=True),
            F("trang_thai", "Trạng thái", type="select", options=["DANG_LAM", "DA_NGHI"]),
        ],
    },
    "nhan-vien-cong-ty": {
        "table": "NHAN_VIEN_CONG_TY", "pk": "ma_nhan_vien", "title": "Nhân viên công ty",
        # ma_so_nhan_vien phai DUY NHAT tren CA 3 node (khong chi cuc bo).
        "cross_node_unique": "ma_so_nhan_vien",
        "after_create": _after_create_nvct,   # tao luon tai khoan NVCT
        "list_cols": [("ma_nhan_vien", "Mã"), ("ma_so_nhan_vien", "Mã NV"), ("ho_ten", "Họ tên"),
                      ("ten_cong_ty", "Công ty"), ("chuc_vu", "Chức vụ"), ("trang_thai", "Trạng thái")],
        "list_sql": """SELECT nv.ma_nhan_vien, nv.ma_so_nhan_vien, nv.ho_ten,
                              ct.ten_cong_ty, nv.chuc_vu, nv.trang_thai
                       FROM NHAN_VIEN_CONG_TY nv
                       LEFT JOIN CONG_TY ct ON ct.ma_cong_ty = nv.ma_cong_ty
                       ORDER BY nv.ma_nhan_vien DESC""",
        "fields": [
            F("ma_so_nhan_vien", "Mã số nhân viên", required=True, prefix="NVCT-", pad=4),
            F("ma_cong_ty", "Công ty", type="select", required=True,
              fk=("SELECT ma_cong_ty, ten_cong_ty FROM CONG_TY ORDER BY ten_cong_ty", "ma_cong_ty", "ten_cong_ty")),
            F("ho_ten", "Họ tên", required=True),
            F("ngay_sinh", "Ngày sinh", type="date"),
            F("gioi_tinh", "Giới tính", type="select", options=["NAM", "NU", "KHAC"]),
            F("so_dien_thoai", "Số điện thoại"),
            F("email", "Email"),
            F("chuc_vu", "Chức vụ"),
            F("ngay_bat_dau", "Ngày bắt đầu", type="date", required=True),
            F("trang_thai", "Trạng thái", type="select", options=["HOAT_DONG", "DA_NGHI_VIEC"]),
        ],
    },
    "hop-dong": {
        "table": "HOP_DONG_THUE", "pk": "ma_hop_dong", "title": "Hợp đồng thuê",
        "list_cols": [("ma_hop_dong", "Mã"), ("so_hop_dong", "Số HĐ"), ("ma_cong_ty", "Công ty"),
                      ("ngay_bat_dau", "Từ"), ("ngay_ket_thuc", "Đến"), ("trang_thai", "Trạng thái")],
        "fields": [
            F("so_hop_dong", "Số hợp đồng", required=True),
            F("ma_cong_ty", "Công ty", type="select", required=True,
              fk=("SELECT ma_cong_ty, ten_cong_ty FROM CONG_TY ORDER BY ten_cong_ty", "ma_cong_ty", "ten_cong_ty")),
            F("ngay_bat_dau", "Ngày bắt đầu", type="date", required=True),
            F("ngay_ket_thuc", "Ngày kết thúc", type="date", required=True),
            F("tien_dat_coc", "Tiền đặt cọc", type="number"),
            F("trang_thai", "Trạng thái", type="select", options=["HIEU_LUC", "HET_HAN", "DA_THANH_LY"]),
        ],
    },
    "dang-ky-dich-vu": {
        "table": "DANG_KY_DICH_VU", "pk": "ma_dang_ky", "title": "Đăng ký dịch vụ",
        "list_cols": [("ma_dang_ky", "Mã"), ("ten_cong_ty", "Công ty"), ("ten_dich_vu", "Dịch vụ"),
                      ("don_gia", "Đơn giá"), ("trang_thai", "Trạng thái")],
        "list_sql": """SELECT dk.ma_dang_ky, ct.ten_cong_ty, dv.ten_dich_vu,
                              dk.don_gia, dk.trang_thai
                       FROM DANG_KY_DICH_VU dk
                       JOIN CONG_TY ct ON ct.ma_cong_ty = dk.ma_cong_ty
                       JOIN DICH_VU dv ON dv.ma_dich_vu = dk.ma_dich_vu
                       ORDER BY dk.ma_dang_ky DESC""",
        "fields": [
            F("ma_cong_ty", "Công ty", type="select", required=True,
              fk=("SELECT ma_cong_ty, ten_cong_ty FROM CONG_TY ORDER BY ten_cong_ty", "ma_cong_ty", "ten_cong_ty")),
            F("ma_dich_vu", "Dịch vụ", type="select", required=True,
              fk=("SELECT ma_dich_vu, ten_dich_vu FROM DICH_VU ORDER BY ten_dich_vu", "ma_dich_vu", "ten_dich_vu")),
            F("ngay_bat_dau", "Ngày bắt đầu", type="date", required=True),
            F("ngay_ket_thuc", "Ngày kết thúc", type="date"),
            F("don_gia", "Đơn giá", type="number", required=True),
            F("trang_thai", "Trạng thái", type="select", options=["DANG_DUNG", "TAM_DUNG", "DA_HUY"]),
        ],
    },
    "quan-ly-nhan-vien": {
        "table": "QUAN_LY_NHAN_VIEN", "pk": "ma_quan_ly", "title": "Phân cấp quản lý NV tòa nhà",
        "list_cols": [("ma_quan_ly", "Mã"), ("nv_cap_duoi", "Nhân viên (cấp dưới)"),
                      ("nguoi_quan_ly", "Người quản lý (cấp trên)"), ("ngay_bat_dau", "Từ"), ("ngay_ket_thuc", "Đến")],
        "list_sql": """SELECT q.ma_quan_ly,
                              CONCAT(a.ma_so_nhan_vien,' - ',a.ho_ten) AS nv_cap_duoi,
                              CONCAT(b.ma_so_nhan_vien,' - ',b.ho_ten) AS nguoi_quan_ly,
                              q.ngay_bat_dau, q.ngay_ket_thuc
                       FROM QUAN_LY_NHAN_VIEN q
                       JOIN NHAN_VIEN_TOA_NHA a ON a.ma_nhan_vien_toa_nha = q.ma_nhan_vien
                       JOIN NHAN_VIEN_TOA_NHA b ON b.ma_nhan_vien_toa_nha = q.ma_nguoi_quan_ly
                       ORDER BY q.ma_quan_ly DESC""",
        "readonly": True,   # danh sach chi de xem; quan he tao tu dong khi them NV toa nha
        "fields": [
            F("ma_nhan_vien", "Nhân viên (cấp dưới)", type="select", required=True,
              fk=("SELECT ma_nhan_vien_toa_nha, CONCAT(ma_so_nhan_vien,' - ',ho_ten) AS ten FROM NHAN_VIEN_TOA_NHA ORDER BY ma_so_nhan_vien",
                  "ma_nhan_vien_toa_nha", "ten")),
            F("ma_nguoi_quan_ly", "Người quản lý (cấp trên)", type="select", required=True,
              fk=("SELECT ma_nhan_vien_toa_nha, CONCAT(ma_so_nhan_vien,' - ',ho_ten) AS ten FROM NHAN_VIEN_TOA_NHA ORDER BY ma_so_nhan_vien",
                  "ma_nhan_vien_toa_nha", "ten")),
            F("ngay_bat_dau", "Ngày bắt đầu", type="date", required=True),
            F("ngay_ket_thuc", "Ngày kết thúc", type="date"),
        ],
    },
    "chi-phi": {
        "table": "CHI_PHI_TOA_NHA", "pk": "ma_chi_phi", "title": "Chi phí tòa nhà",
        "list_cols": [("ma_chi_phi", "Mã"), ("ten_loai_chi_phi", "Loại chi phí"), ("noi_dung", "Nội dung"),
                      ("ngay_phat_sinh", "Ngày"), ("so_tien", "Số tiền"), ("khu_vuc", "Khu vực")],
        # JOIN LOAI_CHI_PHI de hien ten loai thay vi id.
        "list_sql": """SELECT cp.ma_chi_phi, lcp.ten_loai_chi_phi, cp.noi_dung,
                              cp.ngay_phat_sinh, cp.so_tien, cp.khu_vuc
                       FROM CHI_PHI_TOA_NHA cp
                       JOIN LOAI_CHI_PHI lcp ON lcp.ma_loai_chi_phi = cp.ma_loai_chi_phi
                       ORDER BY cp.ngay_phat_sinh DESC, cp.ma_chi_phi DESC""",
        "fields": [
            F("ma_loai_chi_phi", "Loại chi phí", type="select", required=True,
              fk=("SELECT ma_loai_chi_phi, ten_loai_chi_phi FROM LOAI_CHI_PHI ORDER BY ten_loai_chi_phi",
                  "ma_loai_chi_phi", "ten_loai_chi_phi")),
            F("noi_dung", "Nội dung", required=True),
            F("ngay_phat_sinh", "Ngày phát sinh", type="date", required=True),
            F("so_tien", "Số tiền", type="number", required=True),
            F("khu_vuc", "Khu vực", type="select", options=["HN", "DN", "HCM"], required=True),
            F("ghi_chu", "Ghi chú", type="textarea"),
        ],
    },
}


# ---------------------------------------------------------------------------
# DANH MUC CHUNG: nhan ban giong nhau tren ca 3 node.
# Khi them/sua/xoa phai ghi len CA 3 node voi CUNG mot khoa chinh (ma_*) de
# du lieu dong bo. Vi vay dat "replicated": True va PK duoc cap phat thu cong
# (MAX + 1 tren tat ca node) khi INSERT.
# ---------------------------------------------------------------------------
CATALOG_ENTITIES = {
    "dich-vu": {
        "table": "DICH_VU", "pk": "ma_dich_vu", "title": "Dịch vụ", "replicated": True,
        "list_cols": [("ma_dich_vu", "Mã"), ("ma_so_dich_vu", "Mã DV"), ("ten_dich_vu", "Tên dịch vụ"),
                      ("loai_dich_vu", "Loại"), ("cach_tinh_phi", "Cách tính phí"),
                      ("don_gia_co_ban", "Đơn giá cơ bản"), ("don_vi_tinh", "Đơn vị"), ("trang_thai", "Trạng thái")],
        "fields": [
            F("ma_so_dich_vu", "Mã số dịch vụ", required=True),
            F("ten_dich_vu", "Tên dịch vụ", required=True),
            F("loai_dich_vu", "Loại dịch vụ", required=True),
            F("cach_tinh_phi", "Cách tính phí", type="select", required=True,
              options=["THEO_DIEN_TICH", "THEO_DAU_NGUOI", "THEO_LUOT", "TRON_GOI"]),
            F("don_gia_co_ban", "Đơn giá cơ bản", type="number", required=True),
            F("don_vi_tinh", "Đơn vị tính", required=True),
            F("trang_thai", "Trạng thái", type="select", options=["HOAT_DONG", "NGUNG"]),
        ],
    },
    "loai-chi-phi": {
        "table": "LOAI_CHI_PHI", "pk": "ma_loai_chi_phi", "title": "Loại chi phí", "replicated": True,
        "list_cols": [("ma_loai_chi_phi", "Mã"), ("ten_loai_chi_phi", "Tên loại chi phí"), ("mo_ta", "Mô tả")],
        "fields": [
            F("ten_loai_chi_phi", "Tên loại chi phí", required=True),
            F("mo_ta", "Mô tả", type="textarea"),
        ],
    },
    "vi-tri-cong-viec": {
        "table": "VI_TRI_CONG_VIEC", "pk": "ma_vi_tri", "title": "Vị trí công việc", "replicated": True,
        "list_cols": [("ma_vi_tri", "Mã"), ("ma_so_vi_tri", "Mã VT"), ("ten_vi_tri", "Tên vị trí"),
                      ("luong_co_ban", "Lương cơ bản"), ("ty_le_doanh_thu", "Tỷ lệ DT (%)")],
        "fields": [
            F("ma_so_vi_tri", "Mã số vị trí", required=True),
            F("ten_vi_tri", "Tên vị trí", required=True),
            F("luong_co_ban", "Lương cơ bản", type="number", required=True),
            F("ty_le_doanh_thu", "Tỷ lệ doanh thu (%)", type="number"),
            F("mo_ta", "Mô tả", type="textarea"),
        ],
    },
}
ENTITIES.update(CATALOG_ENTITIES)


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
        prefix = f.get("prefix")
        if prefix and raw:
            # Neu lo go ca tien to thi tach ra truoc (tranh "CT-CT-01").
            so = raw[len(prefix):] if raw.upper().startswith(prefix.upper()) else raw
            # Pad so 0 o dau cho dong nhat (vd pad=3: "20" -> "020") neu la so thuan.
            pad = f.get("pad")
            if pad and so.isdigit():
                so = so.zfill(pad)
            raw = prefix + so
        data[f["name"]] = raw if raw != "" else None
    return data


def _strip_prefix_for_edit(fields, row):
    """Khi SUA: tach tien to khoi gia tri de o input chi hien phan so."""
    if not row:
        return row
    row = dict(row)
    for f in fields:
        prefix = f.get("prefix")
        val = row.get(f["name"])
        if prefix and val and str(val).upper().startswith(prefix.upper()):
            row[f["name"]] = str(val)[len(prefix):]
    return row


# --- Ghi danh muc chung len CA 3 node (dong bo khoa chinh) ---
def _next_replicated_id(table, pk):
    """Lay khoa chinh ke tiep dung chung cho ca 3 node = MAX(pk) tren tat ca node + 1."""
    cur_max = 0
    for kv in _NODES:
        m = db.scalar(f"SELECT COALESCE(MAX({pk}),0) FROM {table}", khu_vuc=kv) or 0
        cur_max = max(cur_max, int(m))
    return cur_max + 1


def _replicated_insert(table, pk, data):
    """INSERT cung mot ban ghi (co PK ro rang) len ca 3 node."""
    new_id = _next_replicated_id(table, pk)
    row = dict(data)
    row[pk] = new_id
    cols = ", ".join(row.keys())
    ph = ", ".join(f":{k}" for k in row)
    for kv in _NODES:
        db.execute(f"INSERT INTO {table} ({cols}) VALUES ({ph})", row, khu_vuc=kv)
    return new_id


def _replicated_update(table, pk, item_id, data):
    sets = ", ".join(f"{k}=:{k}" for k in data)
    params = dict(data)
    params["_id"] = item_id
    for kv in _NODES:
        db.execute(f"UPDATE {table} SET {sets} WHERE {pk}=:_id", params, khu_vuc=kv)


def _replicated_delete(table, pk, item_id):
    for kv in _NODES:
        db.execute(f"DELETE FROM {table} WHERE {pk}=:id", {"id": item_id}, khu_vuc=kv)


def _insert_cross_node_unique(table, pk, uniq_col, data, target_kv, title, after_create=None):
    """Insert ban ghi vao node `target_kv`, dam bao `uniq_col` DUY NHAT tren CA 3 node.

    Dung cho CONG_TY (ma_so_cong_ty), NHAN_VIEN_CONG_TY & NHAN_VIEN_TOA_NHA
    (ma_so_nhan_vien): UNIQUE cuc bo moi node khong du vi 2 chi nhanh (2 node khac
    nhau) co the cung dung mot ma. Giai phap:
      1. Lay KHOA PHAN TAN (GET_LOCK tren HN) -> serialize thao tac tren toan he
         thong, chong race condition khi 2 chi nhanh them cung luc.
      2. Trong khoa: kiem tra uniq_col da ton tai o BAT KY node nao chua.
      3. Neu chua -> insert (trong transaction) tren node dich; neu roi -> bao loi.
      4. after_create (neu co) chay TRONG CUNG transaction -> nguyen tu.
    """
    uniq_val = data.get(uniq_col)
    with db.global_lock(f"them_{table}"):
        # Buoc kiem tra chong 3 node
        for kv in _NODES:
            existed = db.scalar(
                f"SELECT COUNT(*) FROM {table} WHERE {uniq_col}=:v", {"v": uniq_val}, khu_vuc=kv)
            if existed:
                raise DuplicateError(
                    f"Mã '{uniq_val}' đã tồn tại ở chi nhánh {kv}. "
                    f"Mã của {title} phải duy nhất trên toàn hệ thống (cả 3 chi nhánh).")
        # Qua kiem tra -> insert trong transaction tren node dich
        cols = ", ".join(data.keys())
        ph = ", ".join(f":{k}" for k in data)
        with db.tx(target_kv) as t:
            t.execute(f"INSERT INTO {table} ({cols}) VALUES ({ph})", data)
            new_id = t.last_id
            if after_create:
                after_create(new_id, data, t)
            return new_id


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
        # Neu entity co "list_sql" (co JOIN de hien ten thay vi id) thi dung no.
        if cfg.get("list_sql"):
            rows = db.query_all(cfg["list_sql"])
        else:
            rows = db.query_all(f"SELECT * FROM {table} ORDER BY {pk} DESC")
        return render_template("crud_list.html", slug=slug, cfg=cfg, rows=rows)

    @bp.route("/new", methods=["GET", "POST"])
    @login_required
    def create_view():
        _guard()
        fields = _resolve_fk([dict(f) for f in cfg["fields"]])
        if request.method == "POST":
            data = _collect(cfg["fields"])
            try:
                if cfg.get("replicated"):
                    # Danh muc chung -> ghi len ca 3 node voi cung khoa chinh.
                    new_id = _replicated_insert(table, pk, data)
                elif cfg.get("cross_node_unique"):
                    # CONG_TY / NHAN_VIEN_*: ma phai duy nhat tren ca 3 node ->
                    # khoa phan tan + kiem tra chong node. after_create (vd tu gan
                    # quan ly cho NV toa nha) chay trong cung transaction.
                    # Node dich = theo khu_vuc nhap trong form (hoac node dang login).
                    target_kv = data.get("khu_vuc") or db.current_khu_vuc()
                    new_id = _insert_cross_node_unique(
                        table, pk, cfg["cross_node_unique"], data, target_kv,
                        cfg["title"], cfg.get("after_create"))
                else:
                    # Insert thuong trong TRANSACTION; neu co after_create thi chay
                    # cung transaction de dam bao nguyen tu (atomic).
                    cols = ", ".join(data.keys())
                    ph = ", ".join(f":{k}" for k in data)
                    with db.tx() as t:
                        t.execute(f"INSERT INTO {table} ({cols}) VALUES ({ph})", data)
                        new_id = t.last_id
                        if cfg.get("after_create"):
                            cfg["after_create"](new_id, data, t)
                    flash(f"Da them {cfg['title']}.", "success")
                    return redirect(url_for(f"crud_{slug.replace('-', '_')}.list_view"))

                # Nhanh replicated / cross_node co the co after_create ngoai tx
                if cfg.get("after_create") and not cfg.get("cross_node_unique"):
                    cfg["after_create"](new_id, data)
                flash(f"Da them {cfg['title']}.", "success")
                return redirect(url_for(f"crud_{slug.replace('-', '_')}.list_view"))
            except (DuplicateError, TimeoutError) as e:
                flash(str(e), "danger")
            except IntegrityError as e:
                flash(_friendly_error(e, cfg), "danger")
            except SQLAlchemyError as e:
                flash(_friendly_error(e, cfg), "danger")
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
            try:
                if cfg.get("replicated"):
                    _replicated_update(table, pk, item_id, data)
                else:
                    sets = ", ".join(f"{k}=:{k}" for k in data)
                    data["_id"] = item_id
                    db.execute(f"UPDATE {table} SET {sets} WHERE {pk}=:_id", data)
                flash(f"Da cap nhat {cfg['title']}.", "success")
                return redirect(url_for(f"crud_{slug.replace('-', '_')}.list_view"))
            except SQLAlchemyError as e:
                flash(_friendly_error(e, cfg), "danger")
        return render_template("crud_form.html", slug=slug, cfg=cfg, fields=fields,
                               row=_strip_prefix_for_edit(fields, row))

    @bp.route("/<int:item_id>/delete", methods=["POST"])
    @login_required
    def delete_view(item_id):
        _guard()
        try:
            if cfg.get("replicated"):
                _replicated_delete(table, pk, item_id)
            else:
                db.execute(f"DELETE FROM {table} WHERE {pk}=:id", {"id": item_id})
            flash(f"Da xoa {cfg['title']}.", "success")
        except SQLAlchemyError as e:
            flash(f"Khong the xoa: {getattr(e, 'orig', e)}", "danger")
        return redirect(url_for(f"crud_{slug.replace('-', '_')}.list_view"))

    return bp

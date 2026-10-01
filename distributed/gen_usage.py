#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Sinh du lieu SU DUNG DICH VU theo luot (THEO_LUOT) cho thang 8 & 9/2026.

Phan bo moi chi nhanh:
  - An trua (ma_dich_vu=4, 45.000/suat): moi NVCT 1 suat / ngay lam viec (T2-T6)
  - Gui xe  (ma_dich_vu=5, 5.000/luot):  moi NVCT 1 luot  / ngay lam viec (T2-T6)
Cong ty dung dich vu nao:
  HN:  CT-01, CT-02 -> an trua ; CT-03, CT-04 -> gui xe
  DN:  CT-05, CT-06 -> an trua ; CT-07       -> gui xe
  HCM: CT-08, CT-09 -> an trua ; CT-10       -> gui xe

Buoc 1: dang ky dich vu cho cong ty (DANG_KY_DICH_VU) neu chua co.
Buoc 2: sinh SU_DUNG_DICH_VU moi NVCT moi ngay lam viec.
(thanh_tien la cot GENERATED = so_luong * don_gia -> khong chen truc tiep.)

Chay: docker exec dist_flask python /app/gen_usage.py
"""
import datetime
from app.config import Config
from app import db

cfg = Config()
db.init_engines(cfg)

# dich vu
DV_AN_TRUA = 4
DV_GUI_XE = 5
GIA = {DV_AN_TRUA: 45000, DV_GUI_XE: 5000}

# phan bo cong ty theo node: {kv: {ma_dich_vu: [ma_cong_ty,...]}}
PHAN_BO = {
    "HN":  {DV_AN_TRUA: [1, 2], DV_GUI_XE: [3, 4]},
    "DN":  {DV_AN_TRUA: [5, 6], DV_GUI_XE: [7]},
    "HCM": {DV_AN_TRUA: [8, 9], DV_GUI_XE: [10]},
}

THANGS = [(8, 2026), (9, 2026)]


def ngay_lam_viec(thang, nam):
    """Danh sach ngay T2-T6 trong thang."""
    d = datetime.date(nam, thang, 1)
    out = []
    while d.month == thang:
        if d.weekday() < 5:  # 0=T2 .. 4=T6
            out.append(d.isoformat())
        d += datetime.timedelta(days=1)
    return out


def dang_ky_dich_vu(kv, ma_cong_ty, ma_dich_vu):
    """Tao DANG_KY_DICH_VU neu chua co, tra ve ma_dang_ky."""
    row = db.query_one(
        """SELECT ma_dang_ky FROM DANG_KY_DICH_VU
           WHERE ma_cong_ty=:c AND ma_dich_vu=:d AND trang_thai='DANG_DUNG'
           ORDER BY ma_dang_ky LIMIT 1""",
        {"c": ma_cong_ty, "d": ma_dich_vu}, khu_vuc=kv)
    if row:
        return row["ma_dang_ky"]
    new_id = db.execute(
        """INSERT INTO DANG_KY_DICH_VU (ma_cong_ty, ma_dich_vu, ngay_bat_dau, don_gia, trang_thai)
           VALUES (:c, :d, '2026-08-01', :g, 'DANG_DUNG')""",
        {"c": ma_cong_ty, "d": ma_dich_vu, "g": GIA[ma_dich_vu]}, khu_vuc=kv)
    return new_id


def sinh_cho_node(kv):
    tong_dong = 0
    for ma_dich_vu, cong_tys in PHAN_BO[kv].items():
        gia = GIA[ma_dich_vu]
        for ct in cong_tys:
            ma_dang_ky = dang_ky_dich_vu(kv, ct, ma_dich_vu)
            nvcts = [r["ma_nhan_vien"] for r in db.query_all(
                "SELECT ma_nhan_vien FROM NHAN_VIEN_CONG_TY WHERE ma_cong_ty=:c AND trang_thai='HOAT_DONG'",
                {"c": ct}, khu_vuc=kv)]
            for (thang, nam) in THANGS:
                for ngay in ngay_lam_viec(thang, nam):
                    for nv in nvcts:
                        # bo qua neu da co (chay lai an toan)
                        existed = db.scalar(
                            """SELECT COUNT(*) FROM SU_DUNG_DICH_VU
                               WHERE ma_nhan_vien=:nv AND ma_dang_ky=:dk AND ngay_su_dung=:ng""",
                            {"nv": nv, "dk": ma_dang_ky, "ng": ngay}, khu_vuc=kv)
                        if existed:
                            continue
                        db.execute(
                            """INSERT INTO SU_DUNG_DICH_VU (ma_nhan_vien, ma_dang_ky, ngay_su_dung, so_luong, don_gia)
                               VALUES (:nv, :dk, :ng, 1, :g)""",
                            {"nv": nv, "dk": ma_dang_ky, "ng": ngay, "g": gia}, khu_vuc=kv)
                        tong_dong += 1
    return tong_dong


if __name__ == "__main__":
    for kv in cfg.NODES:
        n = sinh_cho_node(kv)
        print(f"{kv}: tao {n} dong su dung dich vu")

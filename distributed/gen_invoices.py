#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Tinh hoa don thang 8 & 9/2026 cho MOI cong ty tren TUNG node.

Hoa don = tien thue van phong + dich vu CO DINH (THEO_DIEN_TICH / THEO_DAU_NGUOI
/ TRON_GOI). CHUA gom dich vu THEO_LUOT (an uong/gui xe) vi usage nhap sau.
Chay trong container dist_flask:  docker exec dist_flask python /app/gen_invoices.py
"""
from app.config import Config
from app import db

cfg = Config()
db.init_engines(cfg)

THANGS = [(8, 2026), (9, 2026)]


def tinh_cho_node(kv):
    created = 0
    cong_tys = db.query_all("SELECT ma_cong_ty FROM CONG_TY WHERE trang_thai='DANG_THUE'", khu_vuc=kv)
    for ct in cong_tys:
        c = ct["ma_cong_ty"]
        # tong dien tich thue (hop dong hieu luc) + so nhan vien hoat dong
        tong_dt = db.scalar(
            """SELECT COALESCE(SUM(vp.dien_tich),0) FROM CHI_TIET_HOP_DONG cthd
               JOIN HOP_DONG_THUE hd ON hd.ma_hop_dong=cthd.ma_hop_dong
               JOIN VAN_PHONG vp ON vp.ma_van_phong=cthd.ma_van_phong
               WHERE hd.ma_cong_ty=:c AND hd.trang_thai='HIEU_LUC'""", {"c": c}, khu_vuc=kv) or 0
        so_nguoi = db.scalar(
            "SELECT COUNT(*) FROM NHAN_VIEN_CONG_TY WHERE ma_cong_ty=:c AND trang_thai='HOAT_DONG'",
            {"c": c}, khu_vuc=kv) or 0
        # cac dong tien thue tu hop dong
        ct_hds = db.query_all(
            """SELECT cthd.ma_chi_tiet, cthd.don_gia_thue_m2, vp.dien_tich, vp.ky_hieu_van_phong
               FROM CHI_TIET_HOP_DONG cthd
               JOIN HOP_DONG_THUE hd ON hd.ma_hop_dong=cthd.ma_hop_dong
               JOIN VAN_PHONG vp ON vp.ma_van_phong=cthd.ma_van_phong
               WHERE hd.ma_cong_ty=:c AND hd.trang_thai='HIEU_LUC'""", {"c": c}, khu_vuc=kv)
        # cac dich vu dang ky (chi co dinh)
        dks = db.query_all(
            """SELECT dk.ma_dang_ky, dk.don_gia, dv.ten_dich_vu, dv.cach_tinh_phi
               FROM DANG_KY_DICH_VU dk JOIN DICH_VU dv ON dv.ma_dich_vu=dk.ma_dich_vu
               WHERE dk.ma_cong_ty=:c AND dk.trang_thai='DANG_DUNG'
                 AND dv.cach_tinh_phi IN ('THEO_DIEN_TICH','THEO_DAU_NGUOI','TRON_GOI')""",
            {"c": c}, khu_vuc=kv)

        for (thang, nam) in THANGS:
            # bo qua neu da co hoa don
            if db.query_one("SELECT ma_hoa_don FROM HOA_DON WHERE ma_cong_ty=:c AND thang=:t AND nam=:n",
                            {"c": c, "t": thang, "n": nam}, khu_vuc=kv):
                continue
            line_items = []
            tien_thue = 0.0
            for r in ct_hds:
                tt = float(r["dien_tich"]) * float(r["don_gia_thue_m2"])
                tien_thue += tt
                line_items.append(("TIEN_THUE_PHONG", f"Thue phong {r['ky_hieu_van_phong']} ({r['dien_tich']}m2)",
                                   float(r["dien_tich"]), float(r["don_gia_thue_m2"]), tt, r["ma_chi_tiet"], None))
            tien_dv = 0.0
            for dk in dks:
                cach = dk["cach_tinh_phi"]; gia = float(dk["don_gia"])
                if cach == "THEO_DIEN_TICH":
                    sl = float(tong_dt); tt = sl * gia
                elif cach == "THEO_DAU_NGUOI":
                    sl = float(so_nguoi); tt = sl * gia
                else:  # TRON_GOI
                    sl = 1.0; tt = gia
                if tt > 0:
                    tien_dv += tt
                    line_items.append(("TIEN_DICH_VU", dk["ten_dich_vu"], sl, gia, tt, None, dk["ma_dang_ky"]))
            tong = tien_thue + tien_dv
            if tong <= 0:
                continue
            so_hd = f"INV-{nam}{thang:02d}-CT{c:02d}"
            hd_id = db.execute(
                """INSERT INTO HOA_DON (so_hoa_don, ma_cong_ty, thang, nam, tien_thue_van_phong, tien_dich_vu, tong_tien)
                   VALUES (:s,:c,:t,:n,:tt,:td,:tong)""",
                {"s": so_hd, "c": c, "t": thang, "n": nam, "tt": tien_thue, "td": tien_dv, "tong": tong},
                khu_vuc=kv)
            for (loai, nd, sl, dg, tt, mct, mdk) in line_items:
                db.execute(
                    """INSERT INTO CHI_TIET_HOA_DON (ma_hoa_don, ma_chi_tiet_hop_dong, ma_dang_ky, loai_chi_phi, noi_dung, so_luong, don_gia, thanh_tien)
                       VALUES (:h,:ct,:dk,:loai,:nd,:sl,:dg,:tt)""",
                    {"h": hd_id, "ct": mct, "dk": mdk, "loai": loai, "nd": nd, "sl": sl, "dg": dg, "tt": tt},
                    khu_vuc=kv)
            created += 1
    return created


if __name__ == "__main__":
    for kv in cfg.NODES:
        n = tinh_cho_node(kv)
        print(f"{kv}: tao {n} hoa don")

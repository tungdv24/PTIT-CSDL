#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Tinh luong nhan vien toa nha thang 8 & 9/2026 cho TUNG node.

Luong lay theo VI TRI CONG VIEC that cua nhan vien (cot ma_vi_tri ->
VI_TRI_CONG_VIEC), gom luong_co_ban va ty_le_doanh_thu.
Cong thuc:
  doanh_thu_dich_vu = (tong tien_dich_vu cua node thang do) / so_nhan_vien   (proxy)
  tien_thuong       = doanh_thu_dich_vu * ty_le_doanh_thu%
  tong_luong        = luong_co_ban + tien_thuong

Chay:  docker exec dist_flask python /app/gen_salaries.py
"""
from app.config import Config
from app import db

cfg = Config()
db.init_engines(cfg)

THANGS = [(8, 2026), (9, 2026)]


def tinh_cho_node(kv):
    created = 0
    # Lay nhan vien kem luong_co_ban + ty_le theo VI TRI THAT (ma_vi_tri).
    nvs = db.query_all(
        """SELECT nv.ma_nhan_vien_toa_nha,
                  COALESCE(v.luong_co_ban, 7000000)   AS luong_co_ban,
                  COALESCE(v.ty_le_doanh_thu, 1)       AS ty_le
           FROM NHAN_VIEN_TOA_NHA nv
           LEFT JOIN VI_TRI_CONG_VIEC v ON v.ma_vi_tri = nv.ma_vi_tri
           WHERE nv.trang_thai='DANG_LAM'
           ORDER BY nv.ma_nhan_vien_toa_nha""", khu_vuc=kv)
    so_nv = len(nvs) or 1

    for (thang, nam) in THANGS:
        # bo qua neu da co luong thang do
        if db.query_one("SELECT ma_luong FROM LUONG_NHAN_VIEN WHERE thang=:t AND nam=:n LIMIT 1",
                        {"t": thang, "n": nam}, khu_vuc=kv):
            continue
        tong_dv = db.scalar(
            "SELECT COALESCE(SUM(tien_dich_vu),0) FROM HOA_DON WHERE thang=:t AND nam=:n",
            {"t": thang, "n": nam}, khu_vuc=kv) or 0
        dt_moi_nguoi = float(tong_dv) / so_nv
        for nv in nvs:
            mid = nv["ma_nhan_vien_toa_nha"]
            luong_cb = float(nv["luong_co_ban"]); ty_le = float(nv["ty_le"])
            tien_thuong = dt_moi_nguoi * ty_le / 100.0
            tong = luong_cb + tien_thuong
            db.execute(
                """INSERT INTO LUONG_NHAN_VIEN
                   (ma_nhan_vien_toa_nha, thang, nam, luong_co_ban, doanh_thu_dich_vu, tien_thuong, tong_luong)
                   VALUES (:nv,:t,:n,:cb,:dt,:tt,:tong)""",
                {"nv": mid, "t": thang, "n": nam, "cb": luong_cb,
                 "dt": dt_moi_nguoi, "tt": tien_thuong, "tong": tong},
                khu_vuc=kv)
            created += 1
    return created


if __name__ == "__main__":
    for kv in cfg.NODES:
        n = tinh_cho_node(kv)
        print(f"{kv}: tao {n} ban ghi luong")

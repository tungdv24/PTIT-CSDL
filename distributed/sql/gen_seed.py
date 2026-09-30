#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Sinh script SQL seed cho 3 node phan tan tu data.txt.

Phan bo:
- 10 cong ty: HN=4, DN=3, HCM=3
- 50 nhan vien cong ty: moi cong ty 5 nguoi (theo thu tu)
- 15 nhan vien toa nha: HN=5, DN=5, HCM=5; moi node random 1 quan ly
- Van phong: 10-15/node (random)
- Moi cong ty: 1 hop dong thue 1-2 van phong + dang ky >=2 dich vu (co dinh)
- Phan cap quan ly: 1 QL/node quan ly cac nguoi con lai

Xuat: seed_data_hanoi.sql / seed_data_danang.sql / seed_data_hcm.sql
(chi chua DU LIEU PHAN MANH; danh muc chung dung 01_seed_catalog.sql).
"""
import random, unicodedata, os

random.seed(20260930)  # co dinh de tai lap

HERE = os.path.dirname(__file__)
DATA = os.path.join(HERE, "..", "..", "data.txt")


def read_data():
    lines = [l.rstrip("\n") for l in open(DATA, encoding="utf-8")]
    cty, nvct, bql = [], [], []
    mode = None
    for l in lines:
        s = l.strip()
        if not s:
            continue
        low = s.lower()
        if low.endswith("cong ty"):
            mode = "cty"; continue
        if "nhân viên công ty" in low:
            mode = "nvct"; continue
        if "nhân viên toà nhà" in low or "nhan vien toa nha" in low:
            mode = "bql"; continue
        if mode == "cty":
            cty.append(s)
        elif mode == "nvct":
            nvct.append(s)
        elif mode == "bql":
            bql.append(s)
    return cty, nvct, bql


def esc(s):
    return s.replace("'", "''")


def no_accent(s):
    s = unicodedata.normalize("NFD", s)
    s = "".join(c for c in s if unicodedata.category(c) != "Mn")
    return s.replace("đ", "d").replace("Đ", "D")


def email_from(name, dom):
    parts = no_accent(name).lower().split()
    return (parts[-1] + "".join(p[0] for p in parts[:-1])) + "@" + dom


# Phan bo cong ty -> chi nhanh
BRANCHES = {
    "HN": {"file": "seed_data_hanoi.sql", "cty_idx": [0, 1, 2, 3], "bql_slice": (0, 5)},
    "DN": {"file": "seed_data_danang.sql", "cty_idx": [4, 5, 6], "bql_slice": (5, 10)},
    "HCM": {"file": "seed_data_hcm.sql", "cty_idx": [7, 8, 9], "bql_slice": (10, 15)},
}
VITRI = [1, 2, 3, 4, 5]  # ma_vi_tri co san trong danh muc
# Dich vu co dinh de tinh hoa don (ma_dich_vu, cach_tinh, don_gia goi y)
DV_CODINH = [(1, "THEO_DIEN_TICH", 15000), (2, "THEO_DIEN_TICH", 10000),
             (3, "TRON_GOI", 2000000), (6, "THEO_DAU_NGUOI", 30000)]


def gen():
    cty, nvct, bql = read_data()
    assert len(cty) == 10, f"can 10 cong ty, co {len(cty)}"
    assert len(nvct) == 50, f"can 50 NVCT, co {len(nvct)}"
    assert len(bql) == 15, f"can 15 BQL, co {len(bql)}"

    # ID toan cuc (giu duy nhat tren toan he thong de VIEW gop khong trung)
    # cong ty: 1..10 ; van phong: cap phat lien tuc ; NVCT: 1..50 ; BQL: 1..15
    # dang ky, hop dong, chi tiet: theo tung node nhung id duy nhat toan cuc.
    company_of_emp = []  # 50 phan tu -> ma_cong_ty (1..10)
    for ci in range(10):
        for _ in range(5):
            company_of_emp.append(ci + 1)

    vp_counter = 1
    hd_counter = 1
    cthd_counter = 1
    dk_counter = 1

    for kv, cfg in BRANCHES.items():
        dom = {"HN": "hn.vn", "DN": "dn.vn", "HCM": "hcm.vn"}[kv]
        lines = [f"-- ====== SEED DATA CHI NHANH {kv} (sinh tu data.txt) ======",
                 "USE QuanLyToaNha;", ""]

        # ---- Van phong (10-15) ----
        n_vp = random.randint(10, 15)
        vp_ids = []
        lines.append("-- Van phong")
        for i in range(n_vp):
            vid = vp_counter; vp_counter += 1
            vp_ids.append(vid)
            tang = random.randint(1, 20)
            dt = random.choice([60, 80, 100, 120, 150, 200, 250])
            gia = random.choice([250000, 280000, 300000, 320000, 350000])
            kh = f"VP-{kv}-{i+1:02d}"
            lines.append(
                f"INSERT INTO VAN_PHONG (ma_van_phong, ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, khu_vuc, trang_thai) "
                f"VALUES ({vid}, '{kh}', {tang}, 'Tang {tang}', {dt}, {gia}, '{kv}', 'TRONG');")
        lines.append("")

        # ---- Cong ty + NVCT + hop dong + dang ky ----
        vp_pool = vp_ids[:]  # cac VP con trong de gan hop dong
        for ci in cfg["cty_idx"]:
            ma_cty = ci + 1
            ten = cty[ci]
            mst = f"0{100000000 + ma_cty}"
            macode = f"CT-{ma_cty:02d}"
            lines.append(f"-- Cong ty {macode}: {ten}")
            lines.append(
                f"INSERT INTO CONG_TY (ma_cong_ty, ma_so_cong_ty, ma_so_thue, ten_cong_ty, nguoi_dai_dien, so_dien_thoai, email, dia_chi, khu_vuc, trang_thai) "
                f"VALUES ({ma_cty}, '{macode}', '{mst}', '{esc(ten)}', '{esc(no_accent(ten).split()[0])} Manager', "
                f"'09{random.randint(10000000,99999999)}', 'lienhe@{macode.lower()}.vn', 'Toa nha {kv}', '{kv}', 'DANG_THUE');")

            # NVCT cua cong ty
            emp_idx = [i for i in range(50) if company_of_emp[i] == ma_cty]
            for k, ei in enumerate(emp_idx):
                nv_id = ei + 1
                nm = nvct[ei]
                code = f"NVCT-{nv_id:04d}"
                gt = random.choice(["NAM", "NU"])
                lines.append(
                    f"INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) "
                    f"VALUES ({nv_id}, '{code}', {ma_cty}, '{esc(nm)}', '{gt}', '09{random.randint(10000000,99999999)}', "
                    f"'{email_from(nm, macode.lower()+'.vn')}', 'Nhan vien', '2026-01-01', 'HOAT_DONG');")

            # Hop dong thue 1-2 van phong
            hd_id = hd_counter; hd_counter += 1
            so_hd = f"HD-2026-{macode}"
            lines.append(
                f"INSERT INTO HOP_DONG_THUE (ma_hop_dong, so_hop_dong, ma_cong_ty, ngay_bat_dau, ngay_ket_thuc, tien_dat_coc, trang_thai) "
                f"VALUES ({hd_id}, '{so_hd}', {ma_cty}, '2026-01-01', '2026-12-31', 50000000, 'HIEU_LUC');")
            n_thue = random.randint(1, 2)
            for _ in range(n_thue):
                if not vp_pool:
                    break
                vpid = vp_pool.pop(0)
                cid = cthd_counter; cthd_counter += 1
                gia = random.choice([250000, 280000, 300000, 320000, 350000])
                lines.append(
                    f"INSERT INTO CHI_TIET_HOP_DONG (ma_chi_tiet, ma_hop_dong, ma_van_phong, don_gia_thue_m2, ngay_bat_dau, ngay_ket_thuc) "
                    f"VALUES ({cid}, {hd_id}, {vpid}, {gia}, '2026-01-01', '2026-12-31');")
                lines.append(f"UPDATE VAN_PHONG SET trang_thai='DA_THUE' WHERE ma_van_phong={vpid};")

            # Dang ky >=2 dich vu co dinh
            so_dv = random.choice([2, 3])
            chosen = random.sample(DV_CODINH, so_dv)
            for (dv, cach, gia) in chosen:
                did = dk_counter; dk_counter += 1
                lines.append(
                    f"INSERT INTO DANG_KY_DICH_VU (ma_dang_ky, ma_cong_ty, ma_dich_vu, ngay_bat_dau, don_gia, trang_thai) "
                    f"VALUES ({did}, {ma_cty}, {dv}, '2026-01-01', {gia}, 'DANG_DUNG');")
            lines.append("")

        # ---- Nhan vien toa nha + phan cong + quan ly ----
        a, b = cfg["bql_slice"]
        bql_ids = list(range(a + 1, b + 1))  # id 1-based lien tuc toan cuc
        manager = random.choice(bql_ids)
        lines.append(f"-- Nhan vien toa nha {kv} (quan ly: BQL-{manager:03d})")
        for idx, bid in enumerate(bql_ids):
            nm = bql[bid - 1]
            code = f"BQL-{bid:03d}"
            gt = random.choice(["NAM", "NU"])
            vitri = 1 if bid == manager else random.choice([2, 3, 4, 5])
            lines.append(
                f"INSERT INTO NHAN_VIEN_TOA_NHA (ma_nhan_vien_toa_nha, ma_so_nhan_vien, ho_ten, gioi_tinh, so_dien_thoai, email, khu_vuc, ngay_vao_lam, trang_thai) "
                f"VALUES ({bid}, '{code}', '{esc(nm)}', '{gt}', '09{random.randint(10000000,99999999)}', "
                f"'{email_from(nm, 'toanha.vn')}', '{kv}', '2025-06-01', 'DANG_LAM');")
        # phan cap quan ly: manager quan ly nhung nguoi con lai
        for bid in bql_ids:
            if bid != manager:
                lines.append(
                    f"INSERT INTO QUAN_LY_NHAN_VIEN (ma_nhan_vien, ma_nguoi_quan_ly, ngay_bat_dau) "
                    f"VALUES ({bid}, {manager}, '2025-06-01');")
        lines.append("")

        out = os.path.join(HERE, cfg["file"])
        open(out, "w", encoding="utf-8").write("\n".join(lines) + "\n")
        print("Da sinh", cfg["file"], f"({n_vp} VP)")


if __name__ == "__main__":
    gen()

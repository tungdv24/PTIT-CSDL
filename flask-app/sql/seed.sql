-- =====================================================================
-- QuanLyToaNha - Sample data
-- =====================================================================
USE QuanLyToaNha;

-- ---- CONG_TY ----
INSERT INTO CONG_TY (ma_so_thue, ten_cong_ty, nguoi_dai_dien, so_dien_thoai, email, dia_chi, trang_thai) VALUES
('0101234567', 'Cong ty TNHH Cong Nghe ABC', 'Nguyen Van A', '0901111111', 'contact@abc.vn', 'Tang 8, Toa nha PTIT', 'DANG_THUE'),
('0102345678', 'Cong ty CP Tai Chinh XYZ', 'Tran Thi B', '0902222222', 'info@xyz.vn', 'Tang 12, Toa nha PTIT', 'DANG_THUE'),
('0103456789', 'Cong ty TNHH Thuong Mai DEF', 'Le Van C', '0903333333', 'sales@def.vn', 'Tang 5, Toa nha PTIT', 'DANG_THUE'),
('0104567890', 'Cong ty CP Giao Duc GHI', 'Pham Thi D', '0904444444', 'hello@ghi.vn', 'Tang 3, Toa nha PTIT', 'DANG_THUE'),
('0105678901', 'Cong ty TNHH Logistics JKL', 'Hoang Van E', '0905555555', 'ops@jkl.vn', 'Tang 10, Toa nha PTIT', 'DA_CHUYEN_DI');

-- ---- VAN_PHONG ----
INSERT INTO VAN_PHONG (ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, trang_thai) VALUES
('VP-301', 3, 'Canh thang may', 80.00, 250000, 'DA_THUE'),
('VP-302', 3, 'Can goc Dong Nam', 120.00, 280000, 'TRONG'),
('VP-501', 5, 'Huong Nam', 100.00, 260000, 'DA_THUE'),
('VP-801', 8, 'Can goc, view thanh pho', 150.00, 320000, 'DA_THUE'),
('VP-1001', 10, 'Toan tang', 300.00, 300000, 'TRONG'),
('VP-1201', 12, 'Can goc Tay Bac', 200.00, 350000, 'DA_THUE');

-- ---- DICH_VU ----
INSERT INTO DICH_VU (ma_so_dich_vu, ten_dich_vu, loai_dich_vu, cach_tinh_phi, don_gia_co_ban, don_vi_tinh, trang_thai) VALUES
('DV_VESINH', 'Ve sinh van phong', 'CO_DINH', 'THEO_DIEN_TICH', 15000, 'm2/thang', 'HOAT_DONG'),
('DV_BAOVE', 'An ninh bao ve', 'CO_DINH', 'THEO_DIEN_TICH', 10000, 'm2/thang', 'HOAT_DONG'),
('DV_BAOTRI', 'Bao tri ky thuat', 'CO_DINH', 'TRON_GOI', 2000000, 'thang', 'HOAT_DONG'),
('DV_ANUONG', 'Suat an trua', 'BIEN_DOI', 'THEO_LUOT', 45000, 'luot/ngay', 'HOAT_DONG'),
('DV_GUIXE', 'Gui xe', 'BIEN_DOI', 'THEO_LUOT', 5000, 'luot/ngay', 'HOAT_DONG'),
('DV_NUOCUONG', 'Nuoc uong tinh khiet', 'CO_DINH', 'THEO_DAU_NGUOI', 30000, 'nguoi/thang', 'HOAT_DONG');

-- ---- VI_TRI_CONG_VIEC ----
INSERT INTO VI_TRI_CONG_VIEC (ma_so_vi_tri, ten_vi_tri, luong_co_ban, ty_le_doanh_thu, mo_ta) VALUES
('QUAN_LY_TN', 'Quan ly toa nha', 20000000, 5.00, 'Quan ly van hanh toan bo toa nha'),
('TRUONG_CA', 'Truong ca', 12000000, 3.00, 'Giam sat ca truc'),
('KY_THUAT_VIEN', 'Ky thuat vien', 9000000, 2.00, 'Bao tri he thong ky thuat'),
('BAO_VE', 'Nhan vien bao ve', 7000000, 1.00, 'An ninh toa nha'),
('VE_SINH', 'Nhan vien ve sinh', 6500000, 1.00, 'Ve sinh cong cong');

-- ---- NHAN_VIEN_TOA_NHA ----
INSERT INTO NHAN_VIEN_TOA_NHA (ma_so_nhan_vien, ho_ten, ngay_sinh, gioi_tinh, so_dien_thoai, email, ngay_vao_lam, trang_thai) VALUES
('BQL-001', 'Vu Van Quan', '1985-04-12', 'NAM', '0911111111', 'quan@toanha.vn', '2020-01-15', 'DANG_LAM'),
('BQL-002', 'Do Thi Ha', '1990-07-20', 'NU', '0912222222', 'ha@toanha.vn', '2021-03-01', 'DANG_LAM'),
('BQL-003', 'Bui Van Tung', '1992-11-05', 'NAM', '0913333333', 'tung@toanha.vn', '2021-06-10', 'DANG_LAM'),
('BQL-004', 'Ngo Thi Lan', '1995-02-28', 'NU', '0914444444', 'lan@toanha.vn', '2022-01-05', 'DANG_LAM'),
('BQL-005', 'Dang Van Minh', '1988-09-17', 'NAM', '0915555555', 'minh@toanha.vn', '2020-08-20', 'DANG_LAM');

-- ---- NHAN_VIEN_CONG_TY ----
INSERT INTO NHAN_VIEN_CONG_TY (ma_so_nhan_vien, ma_cong_ty, ho_ten, ngay_sinh, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES
('NVCT-0001', 1, 'Nguyen Van Hung', '1993-01-10', 'NAM', '0921111111', 'hung@abc.vn', 'Lap trinh vien', '2023-01-01', 'HOAT_DONG'),
('NVCT-0002', 1, 'Tran Thi Mai', '1996-05-22', 'NU', '0922222222', 'mai@abc.vn', 'Ke toan', '2023-02-15', 'HOAT_DONG'),
('NVCT-0003', 2, 'Le Van Nam', '1991-08-30', 'NAM', '0923333333', 'nam@xyz.vn', 'Chuyen vien', '2022-11-01', 'HOAT_DONG'),
('NVCT-0004', 3, 'Pham Thi Hoa', '1994-12-12', 'NU', '0924444444', 'hoa@def.vn', 'Nhan vien kinh doanh', '2023-05-20', 'HOAT_DONG'),
('NVCT-0005', 4, 'Hoang Van Long', '1990-03-03', 'NAM', '0925555555', 'long@ghi.vn', 'Giao vien', '2021-09-01', 'HOAT_DONG');

-- ---- HOP_DONG_THUE ----
INSERT INTO HOP_DONG_THUE (so_hop_dong, ma_cong_ty, ngay_bat_dau, ngay_ket_thuc, tien_dat_coc, trang_thai) VALUES
('HD-2026/01-CT01', 1, '2026-01-01', '2026-12-31', 50000000, 'HIEU_LUC'),
('HD-2026/01-CT02', 2, '2026-01-01', '2027-12-31', 70000000, 'HIEU_LUC'),
('HD-2026/02-CT03', 3, '2026-02-01', '2026-12-31', 40000000, 'HIEU_LUC'),
('HD-2026/03-CT04', 4, '2026-03-01', '2027-02-28', 24000000, 'HIEU_LUC');

-- ---- CHI_TIET_HOP_DONG ----
INSERT INTO CHI_TIET_HOP_DONG (ma_hop_dong, ma_van_phong, don_gia_thue_m2, ngay_bat_dau, ngay_ket_thuc) VALUES
(1, 4, 320000, '2026-01-01', '2026-12-31'),  -- ABC thue VP-801 (150 m2)
(2, 6, 350000, '2026-01-01', '2027-12-31'),  -- XYZ thue VP-1201 (200 m2)
(3, 3, 260000, '2026-02-01', '2026-12-31'),  -- DEF thue VP-501 (100 m2)
(4, 1, 250000, '2026-03-01', '2027-02-28');  -- GHI thue VP-301 (80 m2)

-- ---- DANG_KY_DICH_VU ----
INSERT INTO DANG_KY_DICH_VU (ma_cong_ty, ma_dich_vu, ngay_bat_dau, ngay_ket_thuc, don_gia, trang_thai) VALUES
(1, 1, '2026-01-01', NULL, 15000, 'DANG_DUNG'),   -- ABC: ve sinh
(1, 4, '2026-01-01', NULL, 45000, 'DANG_DUNG'),   -- ABC: an uong
(1, 5, '2026-01-01', NULL, 5000, 'DANG_DUNG'),    -- ABC: gui xe
(2, 1, '2026-01-01', NULL, 15000, 'DANG_DUNG'),   -- XYZ: ve sinh
(2, 2, '2026-01-01', NULL, 10000, 'DANG_DUNG'),   -- XYZ: bao ve
(3, 4, '2026-02-01', NULL, 45000, 'DANG_DUNG'),   -- DEF: an uong
(4, 6, '2026-03-01', NULL, 30000, 'DANG_DUNG');   -- GHI: nuoc uong

-- ---- SU_DUNG_DICH_VU (thang 4/2026) ----
INSERT INTO SU_DUNG_DICH_VU (ma_nhan_vien, ma_dang_ky, ngay_su_dung, so_luong, don_gia, ghi_chu) VALUES
(1, 2, '2026-04-02', 1, 45000, 'Suat an trua'),
(1, 2, '2026-04-03', 1, 45000, 'Suat an trua'),
(1, 3, '2026-04-02', 1, 5000, 'Gui xe may'),
(2, 2, '2026-04-02', 1, 45000, 'Suat an trua'),
(2, 3, '2026-04-02', 2, 5000, 'Gui xe oto'),
(4, 6, '2026-04-05', 1, 45000, 'Suat an trua'),
(4, 6, '2026-04-06', 1, 45000, 'Suat an trua');

-- ---- PHAN_CONG_CONG_VIEC (thang 4/2026) ----
INSERT INTO PHAN_CONG_CONG_VIEC (ma_nhan_vien_toa_nha, ma_vi_tri, ma_dich_vu, thang, nam, ngay_bat_dau, ngay_ket_thuc) VALUES
(1, 1, NULL, 4, 2026, '2026-04-01', '2026-04-30'),  -- Quan ly
(2, 2, 1, 4, 2026, '2026-04-01', '2026-04-30'),     -- Truong ca - ve sinh
(3, 3, 3, 4, 2026, '2026-04-01', '2026-04-30'),     -- KT vien - bao tri
(4, 5, 1, 4, 2026, '2026-04-01', '2026-04-30'),     -- Ve sinh
(5, 4, 2, 4, 2026, '2026-04-01', '2026-04-30');     -- Bao ve

-- ---- QUAN_LY_NHAN_VIEN ----
INSERT INTO QUAN_LY_NHAN_VIEN (ma_nhan_vien, ma_nguoi_quan_ly, ngay_bat_dau, ngay_ket_thuc) VALUES
(2, 1, '2021-03-01', NULL),
(3, 1, '2021-06-10', NULL),
(4, 2, '2022-01-05', NULL),
(5, 1, '2020-08-20', NULL);

-- ---- LOAI_CHI_PHI ----
INSERT INTO LOAI_CHI_PHI (ten_loai_chi_phi, mo_ta) VALUES
('Dien cong cong', 'Tien dien khu vuc chung, thang may, den hanh lang'),
('Nuoc', 'Tien nuoc sinh hoat chung'),
('Bao tri thiet bi', 'Bao tri thang may, dieu hoa, PCCC'),
('Thu gom rac', 'Dich vu ve sinh moi truong'),
('Vat tu tieu hao', 'Mua sam vat tu van phong, ve sinh');

-- ---- CHI_PHI_TOA_NHA (thang 4/2026) ----
INSERT INTO CHI_PHI_TOA_NHA (ma_loai_chi_phi, noi_dung, ngay_phat_sinh, so_tien, ghi_chu) VALUES
(1, 'Tien dien thang 4/2026', '2026-04-28', 35000000, 'Hoa don EVN'),
(2, 'Tien nuoc thang 4/2026', '2026-04-28', 8000000, 'Hoa don cap nuoc'),
(3, 'Bao tri thang may dinh ky', '2026-04-15', 12000000, 'Hop dong bao tri quy'),
(4, 'Thu gom rac thang 4', '2026-04-30', 3000000, NULL),
(5, 'Mua vat tu ve sinh', '2026-04-10', 5000000, 'Hoa chat, giay ve sinh');

-- ---- LUONG_NHAN_VIEN (thang 4/2026) ----
-- tong_luong = luong_co_ban + tien_thuong (tien_thuong = doanh_thu_dich_vu * ty_le/100)
INSERT INTO LUONG_NHAN_VIEN (ma_nhan_vien_toa_nha, thang, nam, luong_co_ban, doanh_thu_dich_vu, tien_thuong, tong_luong, trang_thai) VALUES
(1, 4, 2026, 20000000, 0, 0, 20000000, 'DA_CHI'),
(2, 4, 2026, 12000000, 5250000, 157500, 12157500, 'DA_CHI'),
(3, 4, 2026, 9000000, 2000000, 40000, 9040000, 'DA_CHI'),
(4, 4, 2026, 6500000, 5250000, 52500, 6552500, 'DA_CHI'),
(5, 4, 2026, 7000000, 2000000, 20000, 7020000, 'DA_CHI');

-- ---- HOA_DON (thang 4/2026) ----
INSERT INTO HOA_DON (so_hoa_don, ma_cong_ty, thang, nam, tien_thue_van_phong, tien_dich_vu, tong_tien, trang_thai_thanh_toan) VALUES
('INV-202604-CT01', 1, 4, 2026, 48000000, 2350000, 50350000, 'DA_THANH_TOAN'),
('INV-202604-CT02', 2, 4, 2026, 70000000, 5000000, 75000000, 'DA_THANH_TOAN'),
('INV-202604-CT03', 3, 4, 2026, 26000000, 0, 26000000, 'CHUA_THANH_TOAN'),
('INV-202604-CT04', 4, 4, 2026, 20000000, 90000, 20090000, 'CHUA_THANH_TOAN');

-- ---- CHI_TIET_HOA_DON ----
INSERT INTO CHI_TIET_HOA_DON (ma_hoa_don, ma_chi_tiet_hop_dong, ma_dang_ky, loai_chi_phi, noi_dung, so_luong, don_gia, thanh_tien) VALUES
(1, 1, NULL, 'TIEN_THUE_PHONG', 'Thue phong VP-801 (150m2)', 150, 320000, 48000000),
(1, NULL, 1, 'TIEN_DICH_VU', 'Phi ve sinh (150m2)', 150, 15000, 2250000),
(1, NULL, 2, 'TIEN_DICH_VU', 'Suat an trua thang 4', 2, 45000, 90000),
(2, 2, NULL, 'TIEN_THUE_PHONG', 'Thue phong VP-1201 (200m2)', 200, 350000, 70000000),
(2, NULL, 4, 'TIEN_DICH_VU', 'Phi ve sinh (200m2)', 200, 15000, 3000000),
(2, NULL, 5, 'TIEN_DICH_VU', 'Phi bao ve (200m2)', 200, 10000, 2000000),
(3, 3, NULL, 'TIEN_THUE_PHONG', 'Thue phong VP-501 (100m2)', 100, 260000, 26000000),
(4, 4, NULL, 'TIEN_THUE_PHONG', 'Thue phong VP-301 (80m2)', 80, 250000, 20000000),
(4, NULL, 7, 'TIEN_DICH_VU', 'Nuoc uong (3 nguoi)', 3, 30000, 90000);

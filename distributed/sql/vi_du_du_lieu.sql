-- =====================================================================
-- VI DU NHAP DU LIEU cho TUNG BANG (mau tham khao)
-- Moi bang co vai dong INSERT minh hoa cach nhap. Thu tu nhap tuan theo
-- phu thuoc khoa (danh muc -> cong ty/van phong -> hop dong -> hoa don...).
-- Ap dung cho MOT node (vd chi nhanh HN). Doi gia tri khu_vuc khi nhap o DN/HCM.
-- =====================================================================
USE QuanLyToaNha;

-- 1) DICH_VU (danh muc dich vu) --------------------------------------
INSERT INTO DICH_VU (ma_so_dich_vu, ten_dich_vu, loai_dich_vu, cach_tinh_phi, don_gia_co_ban, don_vi_tinh) VALUES
('DV_VESINH','Ve sinh van phong','CO_DINH','THEO_DIEN_TICH',15000,'m2/thang'),
('DV_ANUONG','Suat an trua','BIEN_DOI','THEO_LUOT',45000,'luot/ngay'),
('DV_GUIXE','Gui xe','BIEN_DOI','THEO_LUOT',5000,'luot/ngay');

-- 2) LOAI_CHI_PHI ----------------------------------------------------
INSERT INTO LOAI_CHI_PHI (ten_loai_chi_phi, mo_ta) VALUES
('Dien cong cong','Tien dien khu vuc chung'),
('Nuoc','Tien nuoc sinh hoat chung');

-- 3) VI_TRI_CONG_VIEC (vi tri + luong + ty le thuong) ----------------
INSERT INTO VI_TRI_CONG_VIEC (ma_so_vi_tri, ten_vi_tri, luong_co_ban, ty_le_doanh_thu, mo_ta) VALUES
('QUAN_LY_TN','Quan ly toa nha',20000000,5.00,'Quan ly van hanh'),
('VE_SINH','Nhan vien ve sinh',6500000,1.00,'Ve sinh cong cong');

-- 4) NHAN_VIEN_TOA_NHA (nhan vien van hanh - co cot khu_vuc) ---------
INSERT INTO NHAN_VIEN_TOA_NHA (ma_so_nhan_vien, ho_ten, ngay_sinh, gioi_tinh, so_dien_thoai, email, khu_vuc, ngay_vao_lam) VALUES
('BQL-001','Vu Van Quan','1985-04-12','NAM','0911111111','quan@toanha.vn','HN','2020-01-15');

-- 5) CONG_TY (cong ty thue - co cot khu_vuc) -------------------------
INSERT INTO CONG_TY (ma_so_cong_ty, ma_so_thue, ten_cong_ty, nguoi_dai_dien, so_dien_thoai, email, dia_chi, khu_vuc) VALUES
('CT-01','0101234567','Cong ty TNHH Cong Nghe ABC','Nguyen Van A','0901111111','contact@abc.vn','Tang 8, Toa nha HN','HN');
-- (ma_cong_ty tu sinh = 1 neu la ban ghi dau)

-- 6) VAN_PHONG (van phong - co cot khu_vuc) --------------------------
INSERT INTO VAN_PHONG (ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, khu_vuc, trang_thai) VALUES
('VP-801',8,'Can goc view thanh pho',150.00,320000,'HN','DA_THUE');

-- 7) NHAN_VIEN_CONG_TY (nhan vien cua cong ty - di theo ma_cong_ty) --
INSERT INTO NHAN_VIEN_CONG_TY (ma_so_nhan_vien, ma_cong_ty, ho_ten, ngay_sinh, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau) VALUES
('NVCT-0001',1,'Nguyen Van Hung','1993-01-10','NAM','0921111111','hung@abc.vn','Lap trinh vien','2023-01-01');

-- 8) HOP_DONG_THUE (hop dong - thuoc cong ty) ------------------------
INSERT INTO HOP_DONG_THUE (so_hop_dong, ma_cong_ty, ngay_bat_dau, ngay_ket_thuc, tien_dat_coc) VALUES
('HD-2026/01-CT01',1,'2026-01-01','2026-12-31',50000000);

-- 9) CHI_TIET_HOP_DONG (van phong nao trong hop dong nao) ------------
INSERT INTO CHI_TIET_HOP_DONG (ma_hop_dong, ma_van_phong, don_gia_thue_m2, ngay_bat_dau, ngay_ket_thuc) VALUES
(1,1,320000,'2026-01-01','2026-12-31');

-- 10) DANG_KY_DICH_VU (cong ty dang ky dich vu) ---------------------
INSERT INTO DANG_KY_DICH_VU (ma_cong_ty, ma_dich_vu, ngay_bat_dau, don_gia) VALUES
(1,1,'2026-01-01',15000),   -- ve sinh
(1,2,'2026-01-01',45000);   -- an trua

-- 11) SU_DUNG_DICH_VU (nhat ky su dung; thanh_tien tu tinh) ----------
INSERT INTO SU_DUNG_DICH_VU (ma_nhan_vien, ma_dang_ky, ngay_su_dung, so_luong, don_gia, ghi_chu) VALUES
(1,2,'2026-04-02',1,45000,'Suat an trua');

-- 12) PHAN_CONG_CONG_VIEC (phan cong NV toa nha theo thang) ---------
INSERT INTO PHAN_CONG_CONG_VIEC (ma_nhan_vien_toa_nha, ma_vi_tri, ma_dich_vu, thang, nam, ngay_bat_dau, ngay_ket_thuc) VALUES
(1,1,NULL,4,2026,'2026-04-01','2026-04-30');

-- 13) QUAN_LY_NHAN_VIEN (cap tren - cap duoi; khong tu quan ly minh) -
INSERT INTO QUAN_LY_NHAN_VIEN (ma_nhan_vien, ma_nguoi_quan_ly, ngay_bat_dau) VALUES
(1,1,'2026-01-01');  -- LUU Y: neu ma_nhan_vien = ma_nguoi_quan_ly se bi trigger chan (ban tap trung)

-- 14) LUONG_NHAN_VIEN (bang luong thang) ----------------------------
INSERT INTO LUONG_NHAN_VIEN (ma_nhan_vien_toa_nha, thang, nam, luong_co_ban, doanh_thu_dich_vu, tien_thuong, tong_luong) VALUES
(1,4,2026,20000000,0,0,20000000);

-- 15) HOA_DON (hoa don thang cua cong ty) ---------------------------
INSERT INTO HOA_DON (so_hoa_don, ma_cong_ty, thang, nam, tien_thue_van_phong, tien_dich_vu, tong_tien) VALUES
('INV-202604-CT01',1,4,2026,48000000,2295000,50295000);

-- 16) CHI_TIET_HOA_DON (tung dong phi trong hoa don) ----------------
INSERT INTO CHI_TIET_HOA_DON (ma_hoa_don, ma_chi_tiet_hop_dong, ma_dang_ky, loai_chi_phi, noi_dung, so_luong, don_gia, thanh_tien) VALUES
(1,1,NULL,'TIEN_THUE_PHONG','Thue phong VP-801 (150m2)',150,320000,48000000),
(1,NULL,1,'TIEN_DICH_VU','Ve sinh van phong',150,15000,2250000),
(1,NULL,2,'TIEN_DICH_VU','Suat an trua',1,45000,45000);

-- 17) NGUOI_DUNG (tai khoan dang nhapp; mat_khau_hash do app sinh) ---
-- Trong app, user duoc tao tu dong (mat khau bam bang Werkzeug). Neu nhap tay
-- de test, dung mot chuoi hash hop le (vi du sinh bang Python):
--   python -c "from werkzeug.security import generate_password_hash as g; print(g('admin'))"
INSERT INTO NGUOI_DUNG (ten_dang_nhap, mat_khau_hash, ho_ten, vai_tro, khu_vuc, ma_cong_ty) VALUES
('CT-01','<dan_hash_vao_day>','Dai dien Cong ty ABC','CONG_TY','HN',1);

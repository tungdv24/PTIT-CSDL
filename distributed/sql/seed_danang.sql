-- =====================================================================
-- MANH DU LIEU KHU VUC DA NANG (DN) - nap tai node dist_danang
-- Cong ty 2 (XYZ) va 3 (DEF). Giu id goc.
-- =====================================================================
USE QuanLyToaNha;

-- Nhan vien toa nha khu vuc DN (BQL-003)
INSERT INTO NHAN_VIEN_TOA_NHA (ma_nhan_vien_toa_nha, ma_so_nhan_vien, ho_ten, ngay_sinh, gioi_tinh, so_dien_thoai, email, khu_vuc, ngay_vao_lam, trang_thai) VALUES
(3,'BQL-003','Bui Van Tung','1992-11-05','NAM','0913333333','tung@toanha.vn','DN','2021-06-10','DANG_LAM');

INSERT INTO CONG_TY (ma_cong_ty, ma_so_cong_ty, ma_so_thue, ten_cong_ty, nguoi_dai_dien, so_dien_thoai, email, dia_chi, khu_vuc, trang_thai) VALUES
(2,'CT-02','0102345678','Cong ty CP Tai Chinh XYZ','Tran Thi B','0902222222','info@xyz.vn','Tang 12, Toa nha Da Nang','DN','DANG_THUE'),
(3,'CT-03','0103456789','Cong ty TNHH Thuong Mai DEF','Le Van C','0903333333','sales@def.vn','Tang 5, Toa nha Da Nang','DN','DANG_THUE');

INSERT INTO VAN_PHONG (ma_van_phong, ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, khu_vuc, trang_thai) VALUES
(3,'VP-501',5,'Huong Nam',100.00,260000,'DN','DA_THUE'),
(6,'VP-1201',12,'Can goc Tay Bac',200.00,350000,'DN','DA_THUE');

INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, ngay_sinh, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES
(3,'NVCT-0003',2,'Le Van Nam','1991-08-30','NAM','0923333333','nam@xyz.vn','Chuyen vien','2022-11-01','HOAT_DONG'),
(4,'NVCT-0004',3,'Pham Thi Hoa','1994-12-12','NU','0924444444','hoa@def.vn','Nhan vien kinh doanh','2023-05-20','HOAT_DONG');

INSERT INTO HOP_DONG_THUE (ma_hop_dong, so_hop_dong, ma_cong_ty, ngay_bat_dau, ngay_ket_thuc, tien_dat_coc, trang_thai) VALUES
(2,'HD-2026/01-CT02',2,'2026-01-01','2027-12-31',70000000,'HIEU_LUC'),
(3,'HD-2026/02-CT03',3,'2026-02-01','2026-12-31',40000000,'HIEU_LUC');

INSERT INTO CHI_TIET_HOP_DONG (ma_chi_tiet, ma_hop_dong, ma_van_phong, don_gia_thue_m2, ngay_bat_dau, ngay_ket_thuc) VALUES
(2,2,6,350000,'2026-01-01','2027-12-31'),
(3,3,3,260000,'2026-02-01','2026-12-31');

INSERT INTO DANG_KY_DICH_VU (ma_dang_ky, ma_cong_ty, ma_dich_vu, ngay_bat_dau, ngay_ket_thuc, don_gia, trang_thai) VALUES
(4,2,1,'2026-01-01',NULL,15000,'DANG_DUNG'),
(5,2,2,'2026-01-01',NULL,10000,'DANG_DUNG'),
(6,3,4,'2026-02-01',NULL,45000,'DANG_DUNG');

INSERT INTO SU_DUNG_DICH_VU (ma_su_dung, ma_nhan_vien, ma_dang_ky, ngay_su_dung, so_luong, don_gia, ghi_chu) VALUES
(4,4,6,'2026-04-05',1,45000,'Suat an trua'),
(5,4,6,'2026-04-06',1,45000,'Suat an trua');

INSERT INTO HOA_DON (ma_hoa_don, so_hoa_don, ma_cong_ty, thang, nam, tien_thue_van_phong, tien_dich_vu, tong_tien, trang_thai_thanh_toan) VALUES
(2,'INV-202604-CT02',2,4,2026,70000000,5000000,75000000,'DA_THANH_TOAN'),
(3,'INV-202604-CT03',3,4,2026,26000000,90000,26090000,'CHUA_THANH_TOAN');

INSERT INTO CHI_TIET_HOA_DON (ma_hoa_don, ma_chi_tiet_hop_dong, ma_dang_ky, loai_chi_phi, noi_dung, so_luong, don_gia, thanh_tien) VALUES
(2,2,NULL,'TIEN_THUE_PHONG','Thue phong VP-1201 (200m2)',200,350000,70000000),
(2,NULL,4,'TIEN_DICH_VU','Ve sinh van phong',200,15000,3000000),
(2,NULL,5,'TIEN_DICH_VU','An ninh bao ve',200,10000,2000000),
(3,3,NULL,'TIEN_THUE_PHONG','Thue phong VP-501 (100m2)',100,260000,26000000),
(3,NULL,6,'TIEN_DICH_VU','Suat an trua',2,45000,90000);

-- Phan cong + luong nhan vien toa nha DN (cuc bo tai node DN)
INSERT INTO PHAN_CONG_CONG_VIEC (ma_phan_cong, ma_nhan_vien_toa_nha, ma_vi_tri, ma_dich_vu, thang, nam, ngay_bat_dau, ngay_ket_thuc) VALUES
(3,3,3,1,4,2026,'2026-04-01','2026-04-30');

-- BQL-003 (Ky thuat vien, vi tri 3, ty le 2%), phu trach dich vu Ve sinh (ma_dich_vu=1).
-- Doanh thu ve sinh tai DN thang 4 = 3.000.000 (hoa don CT-02). Thuong = 3.000.000 * 2% = 60.000.
INSERT INTO LUONG_NHAN_VIEN (ma_luong, ma_nhan_vien_toa_nha, thang, nam, luong_co_ban, doanh_thu_dich_vu, tien_thuong, tong_luong, trang_thai) VALUES
(3,3,4,2026,9000000,3000000,60000,9060000,'DA_CHI');

-- =====================================================================
-- MANH DU LIEU KHU VUC HA NOI (HN) - nap tai node dist_hanoi
-- Cong ty 1 (ABC). Giu id goc de doi chieu voi ban tap trung.
-- =====================================================================
USE QuanLyToaNha;

INSERT INTO CONG_TY (ma_cong_ty, ma_so_cong_ty, ma_so_thue, ten_cong_ty, nguoi_dai_dien, so_dien_thoai, email, dia_chi, khu_vuc, trang_thai) VALUES
(1,'CT-01','0101234567','Cong ty TNHH Cong Nghe ABC','Nguyen Van A','0901111111','contact@abc.vn','Tang 8, Toa nha PTIT Ha Noi','HN','DANG_THUE');

INSERT INTO VAN_PHONG (ma_van_phong, ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, khu_vuc, trang_thai) VALUES
(4,'VP-801',8,'Can goc, view thanh pho',150.00,320000,'HN','DA_THUE'),
(5,'VP-1001',10,'Toan tang',300.00,300000,'HN','TRONG');

INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, ngay_sinh, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES
(1,'NVCT-0001',1,'Nguyen Van Hung','1993-01-10','NAM','0921111111','hung@abc.vn','Lap trinh vien','2023-01-01','HOAT_DONG'),
(2,'NVCT-0002',1,'Tran Thi Mai','1996-05-22','NU','0922222222','mai@abc.vn','Ke toan','2023-02-15','HOAT_DONG');

INSERT INTO HOP_DONG_THUE (ma_hop_dong, so_hop_dong, ma_cong_ty, ngay_bat_dau, ngay_ket_thuc, tien_dat_coc, trang_thai) VALUES
(1,'HD-2026/01-CT01',1,'2026-01-01','2026-12-31',50000000,'HIEU_LUC');

INSERT INTO CHI_TIET_HOP_DONG (ma_chi_tiet, ma_hop_dong, ma_van_phong, don_gia_thue_m2, ngay_bat_dau, ngay_ket_thuc) VALUES
(1,1,4,320000,'2026-01-01','2026-12-31');

INSERT INTO DANG_KY_DICH_VU (ma_dang_ky, ma_cong_ty, ma_dich_vu, ngay_bat_dau, ngay_ket_thuc, don_gia, trang_thai) VALUES
(1,1,1,'2026-01-01',NULL,15000,'DANG_DUNG'),
(2,1,4,'2026-01-01',NULL,45000,'DANG_DUNG'),
(3,1,5,'2026-01-01',NULL,5000,'DANG_DUNG');

INSERT INTO SU_DUNG_DICH_VU (ma_su_dung, ma_nhan_vien, ma_dang_ky, ngay_su_dung, so_luong, don_gia, ghi_chu) VALUES
(1,1,2,'2026-04-02',1,45000,'Suat an trua'),
(2,1,3,'2026-04-02',1,5000,'Gui xe may'),
(3,2,2,'2026-04-02',1,45000,'Suat an trua');

INSERT INTO HOA_DON (ma_hoa_don, so_hoa_don, ma_cong_ty, thang, nam, tien_thue_van_phong, tien_dich_vu, tong_tien, trang_thai_thanh_toan) VALUES
(1,'INV-202604-CT01',1,4,2026,48000000,2340000,50340000,'DA_THANH_TOAN');

INSERT INTO CHI_TIET_HOA_DON (ma_hoa_don, ma_chi_tiet_hop_dong, ma_dang_ky, loai_chi_phi, noi_dung, so_luong, don_gia, thanh_tien) VALUES
(1,1,NULL,'TIEN_THUE_PHONG','Thue phong VP-801 (150m2)',150,320000,48000000),
(1,NULL,1,'TIEN_DICH_VU','Ve sinh van phong',150,15000,2250000),
(1,NULL,2,'TIEN_DICH_VU','Suat an trua',2,45000,90000);

-- Nhan vien toa nha & luong o tru so HN (quan ly chung)
INSERT INTO PHAN_CONG_CONG_VIEC (ma_phan_cong, ma_nhan_vien_toa_nha, ma_vi_tri, ma_dich_vu, thang, nam, ngay_bat_dau, ngay_ket_thuc) VALUES
(1,1,1,NULL,4,2026,'2026-04-01','2026-04-30'),
(2,2,2,1,4,2026,'2026-04-01','2026-04-30');

INSERT INTO LUONG_NHAN_VIEN (ma_luong, ma_nhan_vien_toa_nha, thang, nam, luong_co_ban, doanh_thu_dich_vu, tien_thuong, tong_luong, trang_thai) VALUES
(1,1,4,2026,20000000,0,0,20000000,'DA_CHI'),
(2,2,4,2026,12000000,2250000,67500,12067500,'DA_CHI');

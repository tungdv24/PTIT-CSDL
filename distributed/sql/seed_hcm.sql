-- =====================================================================
-- MANH DU LIEU KHU VUC TP.HCM (HCM) - nap tai node dist_hcm
-- Cong ty 4 (GHI) va 5 (JKL). Giu id goc.
-- =====================================================================
USE QuanLyToaNha;

INSERT INTO CONG_TY (ma_cong_ty, ma_so_cong_ty, ma_so_thue, ten_cong_ty, nguoi_dai_dien, so_dien_thoai, email, dia_chi, khu_vuc, trang_thai) VALUES
(4,'CT-04','0104567890','Cong ty CP Giao Duc GHI','Pham Thi D','0904444444','hello@ghi.vn','Tang 3, Toa nha TP.HCM','HCM','DANG_THUE'),
(5,'CT-05','0105678901','Cong ty TNHH Logistics JKL','Hoang Van E','0905555555','ops@jkl.vn','Tang 10, Toa nha TP.HCM','HCM','DANG_THUE');

INSERT INTO VAN_PHONG (ma_van_phong, ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, khu_vuc, trang_thai) VALUES
(1,'VP-301',3,'Canh thang may',80.00,250000,'HCM','DA_THUE'),
(2,'VP-302',3,'Can goc Dong Nam',120.00,280000,'HCM','DA_THUE');

INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, ngay_sinh, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES
(5,'NVCT-0005',4,'Hoang Van Long','1990-03-03','NAM','0925555555','long@ghi.vn','Giao vien','2021-09-01','HOAT_DONG'),
(6,'NVCT-0006',5,'Dinh Thi Thu','1997-06-18','NU','0926666666','thu@jkl.vn','Dieu phoi','2023-03-10','HOAT_DONG');

INSERT INTO HOP_DONG_THUE (ma_hop_dong, so_hop_dong, ma_cong_ty, ngay_bat_dau, ngay_ket_thuc, tien_dat_coc, trang_thai) VALUES
(4,'HD-2026/03-CT04',4,'2026-03-01','2027-02-28',24000000,'HIEU_LUC'),
(5,'HD-2026/03-CT05',5,'2026-03-01','2027-02-28',36000000,'HIEU_LUC');

INSERT INTO CHI_TIET_HOP_DONG (ma_chi_tiet, ma_hop_dong, ma_van_phong, don_gia_thue_m2, ngay_bat_dau, ngay_ket_thuc) VALUES
(4,4,1,250000,'2026-03-01','2027-02-28'),
(5,5,2,280000,'2026-03-01','2027-02-28');

INSERT INTO DANG_KY_DICH_VU (ma_dang_ky, ma_cong_ty, ma_dich_vu, ngay_bat_dau, ngay_ket_thuc, don_gia, trang_thai) VALUES
(7,4,6,'2026-03-01',NULL,30000,'DANG_DUNG'),
(8,5,4,'2026-03-01',NULL,45000,'DANG_DUNG');

INSERT INTO SU_DUNG_DICH_VU (ma_su_dung, ma_nhan_vien, ma_dang_ky, ngay_su_dung, so_luong, don_gia, ghi_chu) VALUES
(6,6,8,'2026-04-08',1,45000,'Suat an trua'),
(7,6,8,'2026-04-09',2,45000,'Suat an trua x2');

INSERT INTO HOA_DON (ma_hoa_don, so_hoa_don, ma_cong_ty, thang, nam, tien_thue_van_phong, tien_dich_vu, tong_tien, trang_thai_thanh_toan) VALUES
(4,'INV-202604-CT04',4,4,2026,20000000,90000,20090000,'CHUA_THANH_TOAN'),
(5,'INV-202604-CT05',5,4,2026,33600000,135000,33735000,'CHUA_THANH_TOAN');

INSERT INTO CHI_TIET_HOA_DON (ma_hoa_don, ma_chi_tiet_hop_dong, ma_dang_ky, loai_chi_phi, noi_dung, so_luong, don_gia, thanh_tien) VALUES
(4,4,NULL,'TIEN_THUE_PHONG','Thue phong VP-301 (80m2)',80,250000,20000000),
(4,NULL,7,'TIEN_DICH_VU','Nuoc uong tinh khiet',1,30000,30000),
(5,5,NULL,'TIEN_THUE_PHONG','Thue phong VP-302 (120m2)',120,280000,33600000),
(5,NULL,8,'TIEN_DICH_VU','Suat an trua',3,45000,135000);

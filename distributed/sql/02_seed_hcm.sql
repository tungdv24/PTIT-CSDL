-- ====== SEED DATA CHI NHANH HCM (sinh tu data.txt) ======
USE QuanLyToaNha;

-- Van phong
INSERT INTO VAN_PHONG (ma_van_phong, ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, khu_vuc, trang_thai) VALUES (28, 'VP-HCM-01', 4, 'Tang 4', 200, 350000, 'HCM', 'TRONG');
INSERT INTO VAN_PHONG (ma_van_phong, ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, khu_vuc, trang_thai) VALUES (29, 'VP-HCM-02', 8, 'Tang 8', 100, 320000, 'HCM', 'TRONG');
INSERT INTO VAN_PHONG (ma_van_phong, ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, khu_vuc, trang_thai) VALUES (30, 'VP-HCM-03', 11, 'Tang 11', 80, 300000, 'HCM', 'TRONG');
INSERT INTO VAN_PHONG (ma_van_phong, ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, khu_vuc, trang_thai) VALUES (31, 'VP-HCM-04', 1, 'Tang 1', 120, 320000, 'HCM', 'TRONG');
INSERT INTO VAN_PHONG (ma_van_phong, ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, khu_vuc, trang_thai) VALUES (32, 'VP-HCM-05', 4, 'Tang 4', 100, 280000, 'HCM', 'TRONG');
INSERT INTO VAN_PHONG (ma_van_phong, ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, khu_vuc, trang_thai) VALUES (33, 'VP-HCM-06', 14, 'Tang 14', 80, 300000, 'HCM', 'TRONG');
INSERT INTO VAN_PHONG (ma_van_phong, ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, khu_vuc, trang_thai) VALUES (34, 'VP-HCM-07', 5, 'Tang 5', 120, 350000, 'HCM', 'TRONG');
INSERT INTO VAN_PHONG (ma_van_phong, ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, khu_vuc, trang_thai) VALUES (35, 'VP-HCM-08', 16, 'Tang 16', 200, 280000, 'HCM', 'TRONG');
INSERT INTO VAN_PHONG (ma_van_phong, ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, khu_vuc, trang_thai) VALUES (36, 'VP-HCM-09', 17, 'Tang 17', 150, 250000, 'HCM', 'TRONG');
INSERT INTO VAN_PHONG (ma_van_phong, ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, khu_vuc, trang_thai) VALUES (37, 'VP-HCM-10', 11, 'Tang 11', 250, 250000, 'HCM', 'TRONG');
INSERT INTO VAN_PHONG (ma_van_phong, ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, khu_vuc, trang_thai) VALUES (38, 'VP-HCM-11', 4, 'Tang 4', 150, 320000, 'HCM', 'TRONG');

-- Cong ty CT-08: Công ty Cổ phần Thành Công Group
INSERT INTO CONG_TY (ma_cong_ty, ma_so_cong_ty, ma_so_thue, ten_cong_ty, nguoi_dai_dien, so_dien_thoai, email, dia_chi, khu_vuc, trang_thai) VALUES (8, 'CT-08', '0100000008', 'Công ty Cổ phần Thành Công Group', 'Cong Manager', '0982553356', 'lienhe@ct-08.vn', 'Toa nha HCM', 'HCM', 'DANG_THUE');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (36, 'NVCT-0036', 8, 'Bùi Quốc Anh', 'NU', '0912770964', 'anhbq@ct-08.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (37, 'NVCT-0037', 8, 'Đỗ Hoàng Phúc', 'NU', '0952929460', 'phucdh@ct-08.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (38, 'NVCT-0038', 8, 'Ngô Minh Đức', 'NU', '0978080383', 'ducnm@ct-08.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (39, 'NVCT-0039', 8, 'Phan Thanh Tùng', 'NU', '0980267028', 'tungpt@ct-08.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (40, 'NVCT-0040', 8, 'Vũ Minh Thư', 'NAM', '0991603570', 'thuvm@ct-08.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO HOP_DONG_THUE (ma_hop_dong, so_hop_dong, ma_cong_ty, ngay_bat_dau, ngay_ket_thuc, tien_dat_coc, trang_thai) VALUES (8, 'HD-2026-CT-08', 8, '2026-01-01', '2026-12-31', 50000000, 'HIEU_LUC');
INSERT INTO CHI_TIET_HOP_DONG (ma_chi_tiet, ma_hop_dong, ma_van_phong, don_gia_thue_m2, ngay_bat_dau, ngay_ket_thuc) VALUES (12, 8, 28, 350000, '2026-01-01', '2026-12-31');
UPDATE VAN_PHONG SET trang_thai='DA_THUE' WHERE ma_van_phong=28;
INSERT INTO DANG_KY_DICH_VU (ma_dang_ky, ma_cong_ty, ma_dich_vu, ngay_bat_dau, don_gia, trang_thai) VALUES (20, 8, 2, '2026-01-01', 10000, 'DANG_DUNG');
INSERT INTO DANG_KY_DICH_VU (ma_dang_ky, ma_cong_ty, ma_dich_vu, ngay_bat_dau, don_gia, trang_thai) VALUES (21, 8, 1, '2026-01-01', 15000, 'DANG_DUNG');

-- Cong ty CT-09: Công ty TNHH Việt Nhật Solutions
INSERT INTO CONG_TY (ma_cong_ty, ma_so_cong_ty, ma_so_thue, ten_cong_ty, nguoi_dai_dien, so_dien_thoai, email, dia_chi, khu_vuc, trang_thai) VALUES (9, 'CT-09', '0100000009', 'Công ty TNHH Việt Nhật Solutions', 'Cong Manager', '0920306881', 'lienhe@ct-09.vn', 'Toa nha HCM', 'HCM', 'DANG_THUE');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (41, 'NVCT-0041', 9, 'Hồ Ngọc Diệp', 'NAM', '0964763787', 'diephn@ct-09.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (42, 'NVCT-0042', 9, 'Dương Minh Trang', 'NAM', '0984478870', 'trangdm@ct-09.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (43, 'NVCT-0043', 9, 'Nguyễn Hà My', 'NAM', '0963870640', 'mynh@ct-09.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (44, 'NVCT-0044', 9, 'Trần Phương Uyên', 'NU', '0935660609', 'uyentp@ct-09.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (45, 'NVCT-0045', 9, 'Lê Hoàng Yến', 'NAM', '0934059506', 'yenlh@ct-09.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO HOP_DONG_THUE (ma_hop_dong, so_hop_dong, ma_cong_ty, ngay_bat_dau, ngay_ket_thuc, tien_dat_coc, trang_thai) VALUES (9, 'HD-2026-CT-09', 9, '2026-01-01', '2026-12-31', 50000000, 'HIEU_LUC');
INSERT INTO CHI_TIET_HOP_DONG (ma_chi_tiet, ma_hop_dong, ma_van_phong, don_gia_thue_m2, ngay_bat_dau, ngay_ket_thuc) VALUES (13, 9, 29, 250000, '2026-01-01', '2026-12-31');
UPDATE VAN_PHONG SET trang_thai='DA_THUE' WHERE ma_van_phong=29;
INSERT INTO DANG_KY_DICH_VU (ma_dang_ky, ma_cong_ty, ma_dich_vu, ngay_bat_dau, don_gia, trang_thai) VALUES (22, 9, 3, '2026-01-01', 2000000, 'DANG_DUNG');
INSERT INTO DANG_KY_DICH_VU (ma_dang_ky, ma_cong_ty, ma_dich_vu, ngay_bat_dau, don_gia, trang_thai) VALUES (23, 9, 2, '2026-01-01', 10000, 'DANG_DUNG');
INSERT INTO DANG_KY_DICH_VU (ma_dang_ky, ma_cong_ty, ma_dich_vu, ngay_bat_dau, don_gia, trang_thai) VALUES (24, 9, 6, '2026-01-01', 30000, 'DANG_DUNG');

-- Cong ty CT-10: Công ty Cổ phần Tân Tiến Systems
INSERT INTO CONG_TY (ma_cong_ty, ma_so_cong_ty, ma_so_thue, ten_cong_ty, nguoi_dai_dien, so_dien_thoai, email, dia_chi, khu_vuc, trang_thai) VALUES (10, 'CT-10', '0100000010', 'Công ty Cổ phần Tân Tiến Systems', 'Cong Manager', '0989498929', 'lienhe@ct-10.vn', 'Toa nha HCM', 'HCM', 'DANG_THUE');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (46, 'NVCT-0046', 10, 'Phạm Ngọc Linh', 'NU', '0939603379', 'linhpn@ct-10.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (47, 'NVCT-0047', 10, 'Hoàng Thùy Dương', 'NU', '0975415565', 'duonght@ct-10.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (48, 'NVCT-0048', 10, 'Võ Thanh Trúc', 'NAM', '0983284735', 'trucvt@ct-10.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (49, 'NVCT-0049', 10, 'Đặng Mỹ Linh', 'NAM', '0953464552', 'linhdm@ct-10.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (50, 'NVCT-0050', 10, 'Bùi Khánh Ngân', 'NAM', '0964966287', 'nganbk@ct-10.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO HOP_DONG_THUE (ma_hop_dong, so_hop_dong, ma_cong_ty, ngay_bat_dau, ngay_ket_thuc, tien_dat_coc, trang_thai) VALUES (10, 'HD-2026-CT-10', 10, '2026-01-01', '2026-12-31', 50000000, 'HIEU_LUC');
INSERT INTO CHI_TIET_HOP_DONG (ma_chi_tiet, ma_hop_dong, ma_van_phong, don_gia_thue_m2, ngay_bat_dau, ngay_ket_thuc) VALUES (14, 10, 30, 280000, '2026-01-01', '2026-12-31');
UPDATE VAN_PHONG SET trang_thai='DA_THUE' WHERE ma_van_phong=30;
INSERT INTO DANG_KY_DICH_VU (ma_dang_ky, ma_cong_ty, ma_dich_vu, ngay_bat_dau, don_gia, trang_thai) VALUES (25, 10, 6, '2026-01-01', 30000, 'DANG_DUNG');
INSERT INTO DANG_KY_DICH_VU (ma_dang_ky, ma_cong_ty, ma_dich_vu, ngay_bat_dau, don_gia, trang_thai) VALUES (26, 10, 2, '2026-01-01', 10000, 'DANG_DUNG');

-- Nhan vien toa nha HCM (quan ly: BQL-014)
INSERT INTO NHAN_VIEN_TOA_NHA (ma_nhan_vien_toa_nha, ma_so_nhan_vien, ho_ten, gioi_tinh, so_dien_thoai, email, khu_vuc, ma_vi_tri, ngay_vao_lam, trang_thai) VALUES (11, 'BQL-011', 'Phan Ngọc Khánh', 'NU', '0924495202', 'khanhpn@toanha.vn', 'HCM', 2, '2025-06-01', 'DANG_LAM');
INSERT INTO NHAN_VIEN_TOA_NHA (ma_nhan_vien_toa_nha, ma_so_nhan_vien, ho_ten, gioi_tinh, so_dien_thoai, email, khu_vuc, ma_vi_tri, ngay_vao_lam, trang_thai) VALUES (12, 'BQL-012', 'Vũ Thị Ngọc', 'NU', '0935172753', 'ngocvt@toanha.vn', 'HCM', 3, '2025-06-01', 'DANG_LAM');
INSERT INTO NHAN_VIEN_TOA_NHA (ma_nhan_vien_toa_nha, ma_so_nhan_vien, ho_ten, gioi_tinh, so_dien_thoai, email, khu_vuc, ma_vi_tri, ngay_vao_lam, trang_thai) VALUES (13, 'BQL-013', 'Hồ Quỳnh Như', 'NAM', '0991447815', 'nhuhq@toanha.vn', 'HCM', 4, '2025-06-01', 'DANG_LAM');
INSERT INTO NHAN_VIEN_TOA_NHA (ma_nhan_vien_toa_nha, ma_so_nhan_vien, ho_ten, gioi_tinh, so_dien_thoai, email, khu_vuc, ma_vi_tri, ngay_vao_lam, trang_thai) VALUES (14, 'BQL-014', 'Dương Bích Ngọc', 'NAM', '0926895186', 'ngocdb@toanha.vn', 'HCM', 1, '2025-06-01', 'DANG_LAM');
INSERT INTO NHAN_VIEN_TOA_NHA (ma_nhan_vien_toa_nha, ma_so_nhan_vien, ho_ten, gioi_tinh, so_dien_thoai, email, khu_vuc, ma_vi_tri, ngay_vao_lam, trang_thai) VALUES (15, 'BQL-015', 'Nguyễn Tú Anh', 'NAM', '0945337080', 'anhnt@toanha.vn', 'HCM', 2, '2025-06-01', 'DANG_LAM');
INSERT INTO QUAN_LY_NHAN_VIEN (ma_nhan_vien, ma_nguoi_quan_ly, ngay_bat_dau) VALUES (11, 14, '2025-06-01');
INSERT INTO QUAN_LY_NHAN_VIEN (ma_nhan_vien, ma_nguoi_quan_ly, ngay_bat_dau) VALUES (12, 14, '2025-06-01');
INSERT INTO QUAN_LY_NHAN_VIEN (ma_nhan_vien, ma_nguoi_quan_ly, ngay_bat_dau) VALUES (13, 14, '2025-06-01');
INSERT INTO QUAN_LY_NHAN_VIEN (ma_nhan_vien, ma_nguoi_quan_ly, ngay_bat_dau) VALUES (15, 14, '2025-06-01');


-- Chi phi van hanh toa nha (phan manh HCM)
INSERT INTO CHI_PHI_TOA_NHA (ma_loai_chi_phi, noi_dung, ngay_phat_sinh, so_tien, khu_vuc, ghi_chu) VALUES
(1, 'Tiền điện khu vực chung tháng 8', '2026-08-31', 25000000, 'HCM', 'Thang may + hanh lang'),
(2, 'Tiền nước sinh hoạt chung tháng 8', '2026-08-31', 8000000, 'HCM', NULL),
(3, 'Bảo trì thang máy định kỳ', '2026-08-20', 12000000, 'HCM', 'Quy 3'),
(1, 'Tiền điện khu vực chung tháng 9', '2026-09-30', 26500000, 'HCM', NULL),
(2, 'Tiền nước sinh hoạt chung tháng 9', '2026-09-30', 8500000, 'HCM', NULL);

-- ====== SEED DATA CHI NHANH HN (sinh tu data.txt) ======
USE QuanLyToaNha;

-- Van phong
INSERT INTO VAN_PHONG (ma_van_phong, ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, khu_vuc, trang_thai) VALUES (1, 'VP-HN-01', 13, 'Tang 13', 200, 280000, 'HN', 'TRONG');
INSERT INTO VAN_PHONG (ma_van_phong, ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, khu_vuc, trang_thai) VALUES (2, 'VP-HN-02', 10, 'Tang 10', 200, 350000, 'HN', 'TRONG');
INSERT INTO VAN_PHONG (ma_van_phong, ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, khu_vuc, trang_thai) VALUES (3, 'VP-HN-03', 14, 'Tang 14', 250, 250000, 'HN', 'TRONG');
INSERT INTO VAN_PHONG (ma_van_phong, ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, khu_vuc, trang_thai) VALUES (4, 'VP-HN-04', 2, 'Tang 2', 150, 300000, 'HN', 'TRONG');
INSERT INTO VAN_PHONG (ma_van_phong, ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, khu_vuc, trang_thai) VALUES (5, 'VP-HN-05', 15, 'Tang 15', 250, 350000, 'HN', 'TRONG');
INSERT INTO VAN_PHONG (ma_van_phong, ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, khu_vuc, trang_thai) VALUES (6, 'VP-HN-06', 14, 'Tang 14', 60, 250000, 'HN', 'TRONG');
INSERT INTO VAN_PHONG (ma_van_phong, ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, khu_vuc, trang_thai) VALUES (7, 'VP-HN-07', 16, 'Tang 16', 250, 250000, 'HN', 'TRONG');
INSERT INTO VAN_PHONG (ma_van_phong, ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, khu_vuc, trang_thai) VALUES (8, 'VP-HN-08', 6, 'Tang 6', 150, 350000, 'HN', 'TRONG');
INSERT INTO VAN_PHONG (ma_van_phong, ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, khu_vuc, trang_thai) VALUES (9, 'VP-HN-09', 12, 'Tang 12', 60, 320000, 'HN', 'TRONG');
INSERT INTO VAN_PHONG (ma_van_phong, ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, khu_vuc, trang_thai) VALUES (10, 'VP-HN-10', 11, 'Tang 11', 250, 250000, 'HN', 'TRONG');
INSERT INTO VAN_PHONG (ma_van_phong, ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, khu_vuc, trang_thai) VALUES (11, 'VP-HN-11', 13, 'Tang 13', 60, 280000, 'HN', 'TRONG');
INSERT INTO VAN_PHONG (ma_van_phong, ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, khu_vuc, trang_thai) VALUES (12, 'VP-HN-12', 1, 'Tang 1', 150, 300000, 'HN', 'TRONG');
INSERT INTO VAN_PHONG (ma_van_phong, ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, khu_vuc, trang_thai) VALUES (13, 'VP-HN-13', 15, 'Tang 15', 250, 350000, 'HN', 'TRONG');

-- Cong ty CT-01: Công ty TNHH Công nghệ Việt Tân
INSERT INTO CONG_TY (ma_cong_ty, ma_so_cong_ty, ma_so_thue, ten_cong_ty, nguoi_dai_dien, so_dien_thoai, email, dia_chi, khu_vuc, trang_thai) VALUES (1, 'CT-01', '0100000001', 'Công ty TNHH Công nghệ Việt Tân', 'Cong Manager', '0983133139', 'lienhe@ct-01.vn', 'Toa nha HN', 'HN', 'DANG_THUE');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (1, 'NVCT-0001', 1, 'Nguyễn Minh Anh', 'NAM', '0937194775', 'anhnm@ct-01.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (2, 'NVCT-0002', 1, 'Trần Hoàng Nam', 'NAM', '0946093766', 'namth@ct-01.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (3, 'NVCT-0003', 1, 'Lê Quốc Huy', 'NU', '0984523534', 'huylq@ct-01.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (4, 'NVCT-0004', 1, 'Phạm Minh Tuấn', 'NU', '0980904020', 'tuanpm@ct-01.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (5, 'NVCT-0005', 1, 'Hoàng Đức Anh', 'NU', '0929600274', 'anhhd@ct-01.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO HOP_DONG_THUE (ma_hop_dong, so_hop_dong, ma_cong_ty, ngay_bat_dau, ngay_ket_thuc, tien_dat_coc, trang_thai) VALUES (1, 'HD-2026-CT-01', 1, '2026-01-01', '2026-12-31', 50000000, 'HIEU_LUC');
INSERT INTO CHI_TIET_HOP_DONG (ma_chi_tiet, ma_hop_dong, ma_van_phong, don_gia_thue_m2, ngay_bat_dau, ngay_ket_thuc) VALUES (1, 1, 1, 250000, '2026-01-01', '2026-12-31');
UPDATE VAN_PHONG SET trang_thai='DA_THUE' WHERE ma_van_phong=1;
INSERT INTO DANG_KY_DICH_VU (ma_dang_ky, ma_cong_ty, ma_dich_vu, ngay_bat_dau, don_gia, trang_thai) VALUES (1, 1, 1, '2026-01-01', 15000, 'DANG_DUNG');
INSERT INTO DANG_KY_DICH_VU (ma_dang_ky, ma_cong_ty, ma_dich_vu, ngay_bat_dau, don_gia, trang_thai) VALUES (2, 1, 2, '2026-01-01', 10000, 'DANG_DUNG');
INSERT INTO DANG_KY_DICH_VU (ma_dang_ky, ma_cong_ty, ma_dich_vu, ngay_bat_dau, don_gia, trang_thai) VALUES (3, 1, 3, '2026-01-01', 2000000, 'DANG_DUNG');

-- Cong ty CT-02: Công ty Cổ phần An Phát Solutions
INSERT INTO CONG_TY (ma_cong_ty, ma_so_cong_ty, ma_so_thue, ten_cong_ty, nguoi_dai_dien, so_dien_thoai, email, dia_chi, khu_vuc, trang_thai) VALUES (2, 'CT-02', '0100000002', 'Công ty Cổ phần An Phát Solutions', 'Cong Manager', '0945646694', 'lienhe@ct-02.vn', 'Toa nha HN', 'HN', 'DANG_THUE');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (6, 'NVCT-0006', 2, 'Võ Thành Đạt', 'NAM', '0981063859', 'datvt@ct-02.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (7, 'NVCT-0007', 2, 'Đặng Quang Huy', 'NU', '0935648966', 'huydq@ct-02.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (8, 'NVCT-0008', 2, 'Bùi Anh Khoa', 'NU', '0997442964', 'khoaba@ct-02.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (9, 'NVCT-0009', 2, 'Đỗ Minh Quân', 'NU', '0955743312', 'quandm@ct-02.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (10, 'NVCT-0010', 2, 'Ngô Gia Bảo', 'NAM', '0918959910', 'baong@ct-02.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO HOP_DONG_THUE (ma_hop_dong, so_hop_dong, ma_cong_ty, ngay_bat_dau, ngay_ket_thuc, tien_dat_coc, trang_thai) VALUES (2, 'HD-2026-CT-02', 2, '2026-01-01', '2026-12-31', 50000000, 'HIEU_LUC');
INSERT INTO CHI_TIET_HOP_DONG (ma_chi_tiet, ma_hop_dong, ma_van_phong, don_gia_thue_m2, ngay_bat_dau, ngay_ket_thuc) VALUES (2, 2, 2, 300000, '2026-01-01', '2026-12-31');
UPDATE VAN_PHONG SET trang_thai='DA_THUE' WHERE ma_van_phong=2;
INSERT INTO DANG_KY_DICH_VU (ma_dang_ky, ma_cong_ty, ma_dich_vu, ngay_bat_dau, don_gia, trang_thai) VALUES (4, 2, 6, '2026-01-01', 30000, 'DANG_DUNG');
INSERT INTO DANG_KY_DICH_VU (ma_dang_ky, ma_cong_ty, ma_dich_vu, ngay_bat_dau, don_gia, trang_thai) VALUES (5, 2, 2, '2026-01-01', 10000, 'DANG_DUNG');
INSERT INTO DANG_KY_DICH_VU (ma_dang_ky, ma_cong_ty, ma_dich_vu, ngay_bat_dau, don_gia, trang_thai) VALUES (6, 2, 3, '2026-01-01', 2000000, 'DANG_DUNG');

-- Cong ty CT-03: Công ty TNHH Minh Long Tech
INSERT INTO CONG_TY (ma_cong_ty, ma_so_cong_ty, ma_so_thue, ten_cong_ty, nguoi_dai_dien, so_dien_thoai, email, dia_chi, khu_vuc, trang_thai) VALUES (3, 'CT-03', '0100000003', 'Công ty TNHH Minh Long Tech', 'Cong Manager', '0952930803', 'lienhe@ct-03.vn', 'Toa nha HN', 'HN', 'DANG_THUE');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (11, 'NVCT-0011', 3, 'Phan Nhật Minh', 'NU', '0995179918', 'minhpn@ct-03.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (12, 'NVCT-0012', 3, 'Vũ Hoàng Long', 'NAM', '0983981477', 'longvh@ct-03.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (13, 'NVCT-0013', 3, 'Hồ Tuấn Kiệt', 'NU', '0945052420', 'kietht@ct-03.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (14, 'NVCT-0014', 3, 'Dương Thành Trung', 'NAM', '0915335142', 'trungdt@ct-03.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (15, 'NVCT-0015', 3, 'Nguyễn Thùy Linh', 'NU', '0932354265', 'linhnt@ct-03.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO HOP_DONG_THUE (ma_hop_dong, so_hop_dong, ma_cong_ty, ngay_bat_dau, ngay_ket_thuc, tien_dat_coc, trang_thai) VALUES (3, 'HD-2026-CT-03', 3, '2026-01-01', '2026-12-31', 50000000, 'HIEU_LUC');
INSERT INTO CHI_TIET_HOP_DONG (ma_chi_tiet, ma_hop_dong, ma_van_phong, don_gia_thue_m2, ngay_bat_dau, ngay_ket_thuc) VALUES (3, 3, 3, 320000, '2026-01-01', '2026-12-31');
UPDATE VAN_PHONG SET trang_thai='DA_THUE' WHERE ma_van_phong=3;
INSERT INTO CHI_TIET_HOP_DONG (ma_chi_tiet, ma_hop_dong, ma_van_phong, don_gia_thue_m2, ngay_bat_dau, ngay_ket_thuc) VALUES (4, 3, 4, 320000, '2026-01-01', '2026-12-31');
UPDATE VAN_PHONG SET trang_thai='DA_THUE' WHERE ma_van_phong=4;
INSERT INTO DANG_KY_DICH_VU (ma_dang_ky, ma_cong_ty, ma_dich_vu, ngay_bat_dau, don_gia, trang_thai) VALUES (7, 3, 1, '2026-01-01', 15000, 'DANG_DUNG');
INSERT INTO DANG_KY_DICH_VU (ma_dang_ky, ma_cong_ty, ma_dich_vu, ngay_bat_dau, don_gia, trang_thai) VALUES (8, 3, 2, '2026-01-01', 10000, 'DANG_DUNG');

-- Cong ty CT-04: Công ty Cổ phần Đại Việt Digital
INSERT INTO CONG_TY (ma_cong_ty, ma_so_cong_ty, ma_so_thue, ten_cong_ty, nguoi_dai_dien, so_dien_thoai, email, dia_chi, khu_vuc, trang_thai) VALUES (4, 'CT-04', '0100000004', 'Công ty Cổ phần Đại Việt Digital', 'Cong Manager', '0919904018', 'lienhe@ct-04.vn', 'Toa nha HN', 'HN', 'DANG_THUE');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (16, 'NVCT-0016', 4, 'Trần Ngọc Anh', 'NU', '0958810704', 'anhtn@ct-04.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (17, 'NVCT-0017', 4, 'Lê Phương Thảo', 'NAM', '0916020712', 'thaolp@ct-04.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (18, 'NVCT-0018', 4, 'Phạm Khánh Linh', 'NAM', '0978911026', 'linhpk@ct-04.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (19, 'NVCT-0019', 4, 'Hoàng Mai Anh', 'NAM', '0999413394', 'anhhm@ct-04.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (20, 'NVCT-0020', 4, 'Võ Ngọc Hân', 'NAM', '0961943650', 'hanvn@ct-04.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO HOP_DONG_THUE (ma_hop_dong, so_hop_dong, ma_cong_ty, ngay_bat_dau, ngay_ket_thuc, tien_dat_coc, trang_thai) VALUES (4, 'HD-2026-CT-04', 4, '2026-01-01', '2026-12-31', 50000000, 'HIEU_LUC');
INSERT INTO CHI_TIET_HOP_DONG (ma_chi_tiet, ma_hop_dong, ma_van_phong, don_gia_thue_m2, ngay_bat_dau, ngay_ket_thuc) VALUES (5, 4, 5, 320000, '2026-01-01', '2026-12-31');
UPDATE VAN_PHONG SET trang_thai='DA_THUE' WHERE ma_van_phong=5;
INSERT INTO CHI_TIET_HOP_DONG (ma_chi_tiet, ma_hop_dong, ma_van_phong, don_gia_thue_m2, ngay_bat_dau, ngay_ket_thuc) VALUES (6, 4, 6, 350000, '2026-01-01', '2026-12-31');
UPDATE VAN_PHONG SET trang_thai='DA_THUE' WHERE ma_van_phong=6;
INSERT INTO DANG_KY_DICH_VU (ma_dang_ky, ma_cong_ty, ma_dich_vu, ngay_bat_dau, don_gia, trang_thai) VALUES (9, 4, 2, '2026-01-01', 10000, 'DANG_DUNG');
INSERT INTO DANG_KY_DICH_VU (ma_dang_ky, ma_cong_ty, ma_dich_vu, ngay_bat_dau, don_gia, trang_thai) VALUES (10, 4, 6, '2026-01-01', 30000, 'DANG_DUNG');
INSERT INTO DANG_KY_DICH_VU (ma_dang_ky, ma_cong_ty, ma_dich_vu, ngay_bat_dau, don_gia, trang_thai) VALUES (11, 4, 3, '2026-01-01', 2000000, 'DANG_DUNG');

-- Nhan vien toa nha HN (quan ly: BQL-005)
INSERT INTO NHAN_VIEN_TOA_NHA (ma_nhan_vien_toa_nha, ma_so_nhan_vien, ho_ten, gioi_tinh, so_dien_thoai, email, khu_vuc, ma_vi_tri, ngay_vao_lam, trang_thai) VALUES (1, 'BQL-001', 'Nguyễn Văn Khang', 'NAM', '0989585513', 'khangnv@toanha.vn', 'HN', 2, '2025-06-01', 'DANG_LAM');
INSERT INTO NHAN_VIEN_TOA_NHA (ma_nhan_vien_toa_nha, ma_so_nhan_vien, ho_ten, gioi_tinh, so_dien_thoai, email, khu_vuc, ma_vi_tri, ngay_vao_lam, trang_thai) VALUES (2, 'BQL-002', 'Trần Quốc Bảo', 'NU', '0959558975', 'baotq@toanha.vn', 'HN', 3, '2025-06-01', 'DANG_LAM');
INSERT INTO NHAN_VIEN_TOA_NHA (ma_nhan_vien_toa_nha, ma_so_nhan_vien, ho_ten, gioi_tinh, so_dien_thoai, email, khu_vuc, ma_vi_tri, ngay_vao_lam, trang_thai) VALUES (3, 'BQL-003', 'Lê Anh Khoa', 'NU', '0913106486', 'khoala@toanha.vn', 'HN', 4, '2025-06-01', 'DANG_LAM');
INSERT INTO NHAN_VIEN_TOA_NHA (ma_nhan_vien_toa_nha, ma_so_nhan_vien, ho_ten, gioi_tinh, so_dien_thoai, email, khu_vuc, ma_vi_tri, ngay_vao_lam, trang_thai) VALUES (4, 'BQL-004', 'Phạm Thành Long', 'NAM', '0944690993', 'longpt@toanha.vn', 'HN', 5, '2025-06-01', 'DANG_LAM');
INSERT INTO NHAN_VIEN_TOA_NHA (ma_nhan_vien_toa_nha, ma_so_nhan_vien, ho_ten, gioi_tinh, so_dien_thoai, email, khu_vuc, ma_vi_tri, ngay_vao_lam, trang_thai) VALUES (5, 'BQL-005', 'Hoàng Minh Nhật', 'NAM', '0973145583', 'nhathm@toanha.vn', 'HN', 1, '2025-06-01', 'DANG_LAM');
INSERT INTO QUAN_LY_NHAN_VIEN (ma_nhan_vien, ma_nguoi_quan_ly, ngay_bat_dau) VALUES (1, 5, '2025-06-01');
INSERT INTO QUAN_LY_NHAN_VIEN (ma_nhan_vien, ma_nguoi_quan_ly, ngay_bat_dau) VALUES (2, 5, '2025-06-01');
INSERT INTO QUAN_LY_NHAN_VIEN (ma_nhan_vien, ma_nguoi_quan_ly, ngay_bat_dau) VALUES (3, 5, '2025-06-01');
INSERT INTO QUAN_LY_NHAN_VIEN (ma_nhan_vien, ma_nguoi_quan_ly, ngay_bat_dau) VALUES (4, 5, '2025-06-01');


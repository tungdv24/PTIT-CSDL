-- ====== SEED DATA CHI NHANH DN (sinh tu data.txt) ======
USE QuanLyToaNha;

-- Van phong
INSERT INTO VAN_PHONG (ma_van_phong, ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, khu_vuc, trang_thai) VALUES (14, 'VP-DN-01', 18, 'Tang 18', 80, 300000, 'DN', 'TRONG');
INSERT INTO VAN_PHONG (ma_van_phong, ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, khu_vuc, trang_thai) VALUES (15, 'VP-DN-02', 18, 'Tang 18', 150, 350000, 'DN', 'TRONG');
INSERT INTO VAN_PHONG (ma_van_phong, ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, khu_vuc, trang_thai) VALUES (16, 'VP-DN-03', 7, 'Tang 7', 120, 250000, 'DN', 'TRONG');
INSERT INTO VAN_PHONG (ma_van_phong, ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, khu_vuc, trang_thai) VALUES (17, 'VP-DN-04', 3, 'Tang 3', 250, 250000, 'DN', 'TRONG');
INSERT INTO VAN_PHONG (ma_van_phong, ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, khu_vuc, trang_thai) VALUES (18, 'VP-DN-05', 9, 'Tang 9', 150, 350000, 'DN', 'TRONG');
INSERT INTO VAN_PHONG (ma_van_phong, ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, khu_vuc, trang_thai) VALUES (19, 'VP-DN-06', 4, 'Tang 4', 120, 320000, 'DN', 'TRONG');
INSERT INTO VAN_PHONG (ma_van_phong, ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, khu_vuc, trang_thai) VALUES (20, 'VP-DN-07', 6, 'Tang 6', 100, 350000, 'DN', 'TRONG');
INSERT INTO VAN_PHONG (ma_van_phong, ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, khu_vuc, trang_thai) VALUES (21, 'VP-DN-08', 2, 'Tang 2', 250, 320000, 'DN', 'TRONG');
INSERT INTO VAN_PHONG (ma_van_phong, ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, khu_vuc, trang_thai) VALUES (22, 'VP-DN-09', 3, 'Tang 3', 120, 250000, 'DN', 'TRONG');
INSERT INTO VAN_PHONG (ma_van_phong, ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, khu_vuc, trang_thai) VALUES (23, 'VP-DN-10', 6, 'Tang 6', 100, 250000, 'DN', 'TRONG');
INSERT INTO VAN_PHONG (ma_van_phong, ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, khu_vuc, trang_thai) VALUES (24, 'VP-DN-11', 3, 'Tang 3', 100, 350000, 'DN', 'TRONG');
INSERT INTO VAN_PHONG (ma_van_phong, ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, khu_vuc, trang_thai) VALUES (25, 'VP-DN-12', 3, 'Tang 3', 150, 280000, 'DN', 'TRONG');
INSERT INTO VAN_PHONG (ma_van_phong, ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, khu_vuc, trang_thai) VALUES (26, 'VP-DN-13', 1, 'Tang 1', 250, 280000, 'DN', 'TRONG');
INSERT INTO VAN_PHONG (ma_van_phong, ky_hieu_van_phong, tang, vi_tri, dien_tich, don_gia_m2, khu_vuc, trang_thai) VALUES (27, 'VP-DN-14', 18, 'Tang 18', 60, 350000, 'DN', 'TRONG');

-- Cong ty CT-05: Công ty TNHH Hưng Thịnh Services
INSERT INTO CONG_TY (ma_cong_ty, ma_so_cong_ty, ma_so_thue, ten_cong_ty, nguoi_dai_dien, so_dien_thoai, email, dia_chi, khu_vuc, trang_thai) VALUES (5, 'CT-05', '0100000005', 'Công ty TNHH Hưng Thịnh Services', 'Cong Manager', '0954395726', 'lienhe@ct-05.vn', 'Toa nha DN', 'DN', 'DANG_THUE');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (21, 'NVCT-0021', 5, 'Đặng Thu Hà', 'NAM', '0968657260', 'hadt@ct-05.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (22, 'NVCT-0022', 5, 'Bùi Minh Châu', 'NU', '0984251248', 'chaubm@ct-05.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (23, 'NVCT-0023', 5, 'Đỗ Quỳnh Anh', 'NU', '0941479981', 'anhdq@ct-05.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (24, 'NVCT-0024', 5, 'Ngô Thanh Huyền', 'NU', '0967757863', 'huyennt@ct-05.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (25, 'NVCT-0025', 5, 'Phan Bảo Ngọc', 'NAM', '0934667108', 'ngocpb@ct-05.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO HOP_DONG_THUE (ma_hop_dong, so_hop_dong, ma_cong_ty, ngay_bat_dau, ngay_ket_thuc, tien_dat_coc, trang_thai) VALUES (5, 'HD-2026-CT-05', 5, '2026-01-01', '2026-12-31', 50000000, 'HIEU_LUC');
INSERT INTO CHI_TIET_HOP_DONG (ma_chi_tiet, ma_hop_dong, ma_van_phong, don_gia_thue_m2, ngay_bat_dau, ngay_ket_thuc) VALUES (7, 5, 14, 320000, '2026-01-01', '2026-12-31');
UPDATE VAN_PHONG SET trang_thai='DA_THUE' WHERE ma_van_phong=14;
INSERT INTO DANG_KY_DICH_VU (ma_dang_ky, ma_cong_ty, ma_dich_vu, ngay_bat_dau, don_gia, trang_thai) VALUES (12, 5, 6, '2026-01-01', 30000, 'DANG_DUNG');
INSERT INTO DANG_KY_DICH_VU (ma_dang_ky, ma_cong_ty, ma_dich_vu, ngay_bat_dau, don_gia, trang_thai) VALUES (13, 5, 2, '2026-01-01', 10000, 'DANG_DUNG');

-- Cong ty CT-06: Công ty Cổ phần Nam Việt Innovation
INSERT INTO CONG_TY (ma_cong_ty, ma_so_cong_ty, ma_so_thue, ten_cong_ty, nguoi_dai_dien, so_dien_thoai, email, dia_chi, khu_vuc, trang_thai) VALUES (6, 'CT-06', '0100000006', 'Công ty Cổ phần Nam Việt Innovation', 'Cong Manager', '0981568699', 'lienhe@ct-06.vn', 'Toa nha DN', 'DN', 'DANG_THUE');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (26, 'NVCT-0026', 6, 'Vũ Khánh Vy', 'NAM', '0986696198', 'vyvk@ct-06.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (27, 'NVCT-0027', 6, 'Hồ Ngọc Mai', 'NAM', '0999591597', 'maihn@ct-06.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (28, 'NVCT-0028', 6, 'Dương Hải Yến', 'NAM', '0998196171', 'yendh@ct-06.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (29, 'NVCT-0029', 6, 'Nguyễn Đức Thành', 'NAM', '0974656306', 'thanhnd@ct-06.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (30, 'NVCT-0030', 6, 'Trần Anh Dũng', 'NAM', '0974911668', 'dungta@ct-06.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO HOP_DONG_THUE (ma_hop_dong, so_hop_dong, ma_cong_ty, ngay_bat_dau, ngay_ket_thuc, tien_dat_coc, trang_thai) VALUES (6, 'HD-2026-CT-06', 6, '2026-01-01', '2026-12-31', 50000000, 'HIEU_LUC');
INSERT INTO CHI_TIET_HOP_DONG (ma_chi_tiet, ma_hop_dong, ma_van_phong, don_gia_thue_m2, ngay_bat_dau, ngay_ket_thuc) VALUES (8, 6, 15, 300000, '2026-01-01', '2026-12-31');
UPDATE VAN_PHONG SET trang_thai='DA_THUE' WHERE ma_van_phong=15;
INSERT INTO CHI_TIET_HOP_DONG (ma_chi_tiet, ma_hop_dong, ma_van_phong, don_gia_thue_m2, ngay_bat_dau, ngay_ket_thuc) VALUES (9, 6, 16, 280000, '2026-01-01', '2026-12-31');
UPDATE VAN_PHONG SET trang_thai='DA_THUE' WHERE ma_van_phong=16;
INSERT INTO DANG_KY_DICH_VU (ma_dang_ky, ma_cong_ty, ma_dich_vu, ngay_bat_dau, don_gia, trang_thai) VALUES (14, 6, 6, '2026-01-01', 30000, 'DANG_DUNG');
INSERT INTO DANG_KY_DICH_VU (ma_dang_ky, ma_cong_ty, ma_dich_vu, ngay_bat_dau, don_gia, trang_thai) VALUES (15, 6, 1, '2026-01-01', 15000, 'DANG_DUNG');
INSERT INTO DANG_KY_DICH_VU (ma_dang_ky, ma_cong_ty, ma_dich_vu, ngay_bat_dau, don_gia, trang_thai) VALUES (16, 6, 3, '2026-01-01', 2000000, 'DANG_DUNG');

-- Cong ty CT-07: Công ty TNHH Phúc An Technology
INSERT INTO CONG_TY (ma_cong_ty, ma_so_cong_ty, ma_so_thue, ten_cong_ty, nguoi_dai_dien, so_dien_thoai, email, dia_chi, khu_vuc, trang_thai) VALUES (7, 'CT-07', '0100000007', 'Công ty TNHH Phúc An Technology', 'Cong Manager', '0988334689', 'lienhe@ct-07.vn', 'Toa nha DN', 'DN', 'DANG_THUE');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (31, 'NVCT-0031', 7, 'Lê Minh Khôi', 'NU', '0965589955', 'khoilm@ct-07.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (32, 'NVCT-0032', 7, 'Phạm Quốc Việt', 'NU', '0918273982', 'vietpq@ct-07.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (33, 'NVCT-0033', 7, 'Hoàng Anh Tuấn', 'NU', '0961841689', 'tuanha@ct-07.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (34, 'NVCT-0034', 7, 'Võ Minh Hoàng', 'NAM', '0940318407', 'hoangvm@ct-07.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO NHAN_VIEN_CONG_TY (ma_nhan_vien, ma_so_nhan_vien, ma_cong_ty, ho_ten, gioi_tinh, so_dien_thoai, email, chuc_vu, ngay_bat_dau, trang_thai) VALUES (35, 'NVCT-0035', 7, 'Đặng Thành Công', 'NAM', '0918131638', 'congdt@ct-07.vn', 'Nhan vien', '2026-01-01', 'HOAT_DONG');
INSERT INTO HOP_DONG_THUE (ma_hop_dong, so_hop_dong, ma_cong_ty, ngay_bat_dau, ngay_ket_thuc, tien_dat_coc, trang_thai) VALUES (7, 'HD-2026-CT-07', 7, '2026-01-01', '2026-12-31', 50000000, 'HIEU_LUC');
INSERT INTO CHI_TIET_HOP_DONG (ma_chi_tiet, ma_hop_dong, ma_van_phong, don_gia_thue_m2, ngay_bat_dau, ngay_ket_thuc) VALUES (10, 7, 17, 250000, '2026-01-01', '2026-12-31');
UPDATE VAN_PHONG SET trang_thai='DA_THUE' WHERE ma_van_phong=17;
INSERT INTO CHI_TIET_HOP_DONG (ma_chi_tiet, ma_hop_dong, ma_van_phong, don_gia_thue_m2, ngay_bat_dau, ngay_ket_thuc) VALUES (11, 7, 18, 350000, '2026-01-01', '2026-12-31');
UPDATE VAN_PHONG SET trang_thai='DA_THUE' WHERE ma_van_phong=18;
INSERT INTO DANG_KY_DICH_VU (ma_dang_ky, ma_cong_ty, ma_dich_vu, ngay_bat_dau, don_gia, trang_thai) VALUES (17, 7, 6, '2026-01-01', 30000, 'DANG_DUNG');
INSERT INTO DANG_KY_DICH_VU (ma_dang_ky, ma_cong_ty, ma_dich_vu, ngay_bat_dau, don_gia, trang_thai) VALUES (18, 7, 3, '2026-01-01', 2000000, 'DANG_DUNG');
INSERT INTO DANG_KY_DICH_VU (ma_dang_ky, ma_cong_ty, ma_dich_vu, ngay_bat_dau, don_gia, trang_thai) VALUES (19, 7, 1, '2026-01-01', 15000, 'DANG_DUNG');

-- Nhan vien toa nha DN (quan ly: BQL-008)
INSERT INTO NHAN_VIEN_TOA_NHA (ma_nhan_vien_toa_nha, ma_so_nhan_vien, ho_ten, gioi_tinh, so_dien_thoai, email, khu_vuc, ma_vi_tri, ngay_vao_lam, trang_thai) VALUES (6, 'BQL-006', 'Võ Quang Vinh', 'NAM', '0927933853', 'vinhvq@toanha.vn', 'DN', 2, '2025-06-01', 'DANG_LAM');
INSERT INTO NHAN_VIEN_TOA_NHA (ma_nhan_vien_toa_nha, ma_so_nhan_vien, ho_ten, gioi_tinh, so_dien_thoai, email, khu_vuc, ma_vi_tri, ngay_vao_lam, trang_thai) VALUES (7, 'BQL-007', 'Đặng Đức Minh', 'NAM', '0977896616', 'minhdd@toanha.vn', 'DN', 3, '2025-06-01', 'DANG_LAM');
INSERT INTO NHAN_VIEN_TOA_NHA (ma_nhan_vien_toa_nha, ma_so_nhan_vien, ho_ten, gioi_tinh, so_dien_thoai, email, khu_vuc, ma_vi_tri, ngay_vao_lam, trang_thai) VALUES (8, 'BQL-008', 'Bùi Thanh Sơn', 'NU', '0977702937', 'sonbt@toanha.vn', 'DN', 1, '2025-06-01', 'DANG_LAM');
INSERT INTO NHAN_VIEN_TOA_NHA (ma_nhan_vien_toa_nha, ma_so_nhan_vien, ho_ten, gioi_tinh, so_dien_thoai, email, khu_vuc, ma_vi_tri, ngay_vao_lam, trang_thai) VALUES (9, 'BQL-009', 'Đỗ Trọng Nghĩa', 'NU', '0999115247', 'nghiadt@toanha.vn', 'DN', 5, '2025-06-01', 'DANG_LAM');
INSERT INTO NHAN_VIEN_TOA_NHA (ma_nhan_vien_toa_nha, ma_so_nhan_vien, ho_ten, gioi_tinh, so_dien_thoai, email, khu_vuc, ma_vi_tri, ngay_vao_lam, trang_thai) VALUES (10, 'BQL-010', 'Ngô Khắc Duy', 'NU', '0929597544', 'duynk@toanha.vn', 'DN', 2, '2025-06-01', 'DANG_LAM');
INSERT INTO QUAN_LY_NHAN_VIEN (ma_nhan_vien, ma_nguoi_quan_ly, ngay_bat_dau) VALUES (6, 8, '2025-06-01');
INSERT INTO QUAN_LY_NHAN_VIEN (ma_nhan_vien, ma_nguoi_quan_ly, ngay_bat_dau) VALUES (7, 8, '2025-06-01');
INSERT INTO QUAN_LY_NHAN_VIEN (ma_nhan_vien, ma_nguoi_quan_ly, ngay_bat_dau) VALUES (9, 8, '2025-06-01');
INSERT INTO QUAN_LY_NHAN_VIEN (ma_nhan_vien, ma_nguoi_quan_ly, ngay_bat_dau) VALUES (10, 8, '2025-06-01');


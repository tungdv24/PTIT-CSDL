-- =====================================================================
-- CHAY TAI NODE HA NOI (dist_hanoi) - Server Tong.
-- Tao cac bang FEDERATED tro toi node Da Nang & TP.HCM (tuong duong Linked Server
-- cua SQL Server), roi tao VIEW UNION ALL tong hop toan he thong + procedure bao cao.
-- Yeu cau: MySQL khoi dong voi --federated.
-- Ket noi noi bo qua Docker network: host db_danang / db_hcm, cong 3306.
-- =====================================================================
USE QuanLyToaNha;

-- ------- FEDERATED tables tro toi DA NANG -------
DROP TABLE IF EXISTS CONG_TY_DN;
CREATE TABLE CONG_TY_DN (
    ma_cong_ty INT, ma_so_cong_ty VARCHAR(20), ma_so_thue VARCHAR(20),
    ten_cong_ty VARCHAR(255), nguoi_dai_dien VARCHAR(100), so_dien_thoai VARCHAR(20),
    email VARCHAR(100), dia_chi VARCHAR(255), khu_vuc VARCHAR(10),
    trang_thai VARCHAR(20), created_at TIMESTAMP
) ENGINE=FEDERATED
  CONNECTION='mysql://root:DistPass123@db_danang:3306/QuanLyToaNha/CONG_TY';

DROP TABLE IF EXISTS HOA_DON_DN;
CREATE TABLE HOA_DON_DN (
    ma_hoa_don INT, so_hoa_don VARCHAR(100), ma_cong_ty INT, thang INT, nam INT,
    tien_thue_van_phong DECIMAL(15,2), tien_dich_vu DECIMAL(15,2), tong_tien DECIMAL(15,2),
    trang_thai_thanh_toan VARCHAR(20), ngay_tao TIMESTAMP
) ENGINE=FEDERATED
  CONNECTION='mysql://root:DistPass123@db_danang:3306/QuanLyToaNha/HOA_DON';

DROP TABLE IF EXISTS VAN_PHONG_DN;
CREATE TABLE VAN_PHONG_DN (
    ma_van_phong INT, ky_hieu_van_phong VARCHAR(50), tang INT, vi_tri VARCHAR(100),
    dien_tich DECIMAL(10,2), don_gia_m2 DECIMAL(15,2), khu_vuc VARCHAR(10), trang_thai VARCHAR(20)
) ENGINE=FEDERATED
  CONNECTION='mysql://root:DistPass123@db_danang:3306/QuanLyToaNha/VAN_PHONG';

-- ------- FEDERATED tables tro toi TP.HCM -------
DROP TABLE IF EXISTS CONG_TY_HCM;
CREATE TABLE CONG_TY_HCM (
    ma_cong_ty INT, ma_so_cong_ty VARCHAR(20), ma_so_thue VARCHAR(20),
    ten_cong_ty VARCHAR(255), nguoi_dai_dien VARCHAR(100), so_dien_thoai VARCHAR(20),
    email VARCHAR(100), dia_chi VARCHAR(255), khu_vuc VARCHAR(10),
    trang_thai VARCHAR(20), created_at TIMESTAMP
) ENGINE=FEDERATED
  CONNECTION='mysql://root:DistPass123@db_hcm:3306/QuanLyToaNha/CONG_TY';

DROP TABLE IF EXISTS HOA_DON_HCM;
CREATE TABLE HOA_DON_HCM (
    ma_hoa_don INT, so_hoa_don VARCHAR(100), ma_cong_ty INT, thang INT, nam INT,
    tien_thue_van_phong DECIMAL(15,2), tien_dich_vu DECIMAL(15,2), tong_tien DECIMAL(15,2),
    trang_thai_thanh_toan VARCHAR(20), ngay_tao TIMESTAMP
) ENGINE=FEDERATED
  CONNECTION='mysql://root:DistPass123@db_hcm:3306/QuanLyToaNha/HOA_DON';

DROP TABLE IF EXISTS VAN_PHONG_HCM;
CREATE TABLE VAN_PHONG_HCM (
    ma_van_phong INT, ky_hieu_van_phong VARCHAR(50), tang INT, vi_tri VARCHAR(100),
    dien_tich DECIMAL(10,2), don_gia_m2 DECIMAL(15,2), khu_vuc VARCHAR(10), trang_thai VARCHAR(20)
) ENGINE=FEDERATED
  CONNECTION='mysql://root:DistPass123@db_hcm:3306/QuanLyToaNha/VAN_PHONG';

-- Nhan vien toa nha o DN / HCM (phan manh theo khu vuc)
DROP TABLE IF EXISTS NHAN_VIEN_TOA_NHA_DN;
CREATE TABLE NHAN_VIEN_TOA_NHA_DN (
    ma_nhan_vien_toa_nha INT, ma_so_nhan_vien VARCHAR(50), ho_ten VARCHAR(100),
    ngay_sinh DATE, gioi_tinh VARCHAR(10), so_dien_thoai VARCHAR(20), email VARCHAR(100),
    khu_vuc VARCHAR(10), ngay_vao_lam DATE, trang_thai VARCHAR(20)
) ENGINE=FEDERATED
  CONNECTION='mysql://root:DistPass123@db_danang:3306/QuanLyToaNha/NHAN_VIEN_TOA_NHA';

DROP TABLE IF EXISTS NHAN_VIEN_TOA_NHA_HCM;
CREATE TABLE NHAN_VIEN_TOA_NHA_HCM (
    ma_nhan_vien_toa_nha INT, ma_so_nhan_vien VARCHAR(50), ho_ten VARCHAR(100),
    ngay_sinh DATE, gioi_tinh VARCHAR(10), so_dien_thoai VARCHAR(20), email VARCHAR(100),
    khu_vuc VARCHAR(10), ngay_vao_lam DATE, trang_thai VARCHAR(20)
) ENGINE=FEDERATED
  CONNECTION='mysql://root:DistPass123@db_hcm:3306/QuanLyToaNha/NHAN_VIEN_TOA_NHA';

-- ------- VIEW TONG HOP TOAN HE THONG (Distributed Views) -------
-- Gom du lieu HN (cuc bo) + DN + HCM (qua FEDERATED). Tuong duong plan muc 4B.
DROP VIEW IF EXISTS VW_Global_CONG_TY;
CREATE VIEW VW_Global_CONG_TY AS
    SELECT 'HN' AS chi_nhanh, ma_cong_ty, ma_so_cong_ty, ten_cong_ty, khu_vuc, trang_thai FROM CONG_TY
    UNION ALL
    SELECT 'DN', ma_cong_ty, ma_so_cong_ty, ten_cong_ty, khu_vuc, trang_thai FROM CONG_TY_DN
    UNION ALL
    SELECT 'HCM', ma_cong_ty, ma_so_cong_ty, ten_cong_ty, khu_vuc, trang_thai FROM CONG_TY_HCM;

DROP VIEW IF EXISTS VW_Global_HOA_DON;
CREATE VIEW VW_Global_HOA_DON AS
    SELECT 'HN' AS chi_nhanh, ma_hoa_don, so_hoa_don, ma_cong_ty, thang, nam,
           tien_thue_van_phong, tien_dich_vu, tong_tien, trang_thai_thanh_toan FROM HOA_DON
    UNION ALL
    SELECT 'DN', ma_hoa_don, so_hoa_don, ma_cong_ty, thang, nam,
           tien_thue_van_phong, tien_dich_vu, tong_tien, trang_thai_thanh_toan FROM HOA_DON_DN
    UNION ALL
    SELECT 'HCM', ma_hoa_don, so_hoa_don, ma_cong_ty, thang, nam,
           tien_thue_van_phong, tien_dich_vu, tong_tien, trang_thai_thanh_toan FROM HOA_DON_HCM;

DROP VIEW IF EXISTS VW_Global_VAN_PHONG;
CREATE VIEW VW_Global_VAN_PHONG AS
    SELECT 'HN' AS chi_nhanh, ma_van_phong, ky_hieu_van_phong, dien_tich, khu_vuc, trang_thai FROM VAN_PHONG
    UNION ALL
    SELECT 'DN', ma_van_phong, ky_hieu_van_phong, dien_tich, khu_vuc, trang_thai FROM VAN_PHONG_DN
    UNION ALL
    SELECT 'HCM', ma_van_phong, ky_hieu_van_phong, dien_tich, khu_vuc, trang_thai FROM VAN_PHONG_HCM;

DROP VIEW IF EXISTS VW_Global_NHAN_VIEN_TOA_NHA;
CREATE VIEW VW_Global_NHAN_VIEN_TOA_NHA AS
    SELECT 'HN' AS chi_nhanh, ma_nhan_vien_toa_nha, ma_so_nhan_vien, ho_ten, khu_vuc, trang_thai FROM NHAN_VIEN_TOA_NHA
    UNION ALL
    SELECT 'DN', ma_nhan_vien_toa_nha, ma_so_nhan_vien, ho_ten, khu_vuc, trang_thai FROM NHAN_VIEN_TOA_NHA_DN
    UNION ALL
    SELECT 'HCM', ma_nhan_vien_toa_nha, ma_so_nhan_vien, ho_ten, khu_vuc, trang_thai FROM NHAN_VIEN_TOA_NHA_HCM;

-- ------- PROCEDURE bao cao tai chinh tong hop toan he thong (plan muc 5) -------
DROP PROCEDURE IF EXISTS sp_bao_cao_tong_hop;
DELIMITER $$
CREATE PROCEDURE sp_bao_cao_tong_hop(IN p_thang INT, IN p_nam INT)
BEGIN
    -- Doanh thu (tong tien hoa don) theo tung chi nhanh trong ky
    SELECT chi_nhanh,
           COUNT(*)                 AS so_hoa_don,
           SUM(tien_thue_van_phong) AS tong_tien_thue,
           SUM(tien_dich_vu)        AS tong_tien_dich_vu,
           SUM(tong_tien)           AS tong_doanh_thu
    FROM VW_Global_HOA_DON
    WHERE thang = p_thang AND nam = p_nam
    GROUP BY chi_nhanh WITH ROLLUP;
END$$
DELIMITER ;

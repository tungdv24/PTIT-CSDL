-- =====================================================================
-- CAP NHAT FEDERATED + VIEW o HN sau khi them cot ma_vi_tri.
-- Chay CHI TAI dist_hanoi (sau khi da chay add_ma_vi_tri.sql tren ca 3 node).
-- =====================================================================
USE QuanLyToaNha;

-- Tao lai bang FEDERATED cho khop cot voi bang goc remote (them ma_vi_tri)
DROP TABLE IF EXISTS NHAN_VIEN_TOA_NHA_DN;
CREATE TABLE NHAN_VIEN_TOA_NHA_DN (
    ma_nhan_vien_toa_nha INT, ma_so_nhan_vien VARCHAR(50), ho_ten VARCHAR(100),
    ngay_sinh DATE, gioi_tinh VARCHAR(10), so_dien_thoai VARCHAR(20), email VARCHAR(100),
    khu_vuc VARCHAR(10), ma_vi_tri INT, ngay_vao_lam DATE, trang_thai VARCHAR(20)
) ENGINE=FEDERATED
  CONNECTION='mysql://root:DistPass123@db_danang:3306/QuanLyToaNha/NHAN_VIEN_TOA_NHA';

DROP TABLE IF EXISTS NHAN_VIEN_TOA_NHA_HCM;
CREATE TABLE NHAN_VIEN_TOA_NHA_HCM (
    ma_nhan_vien_toa_nha INT, ma_so_nhan_vien VARCHAR(50), ho_ten VARCHAR(100),
    ngay_sinh DATE, gioi_tinh VARCHAR(10), so_dien_thoai VARCHAR(20), email VARCHAR(100),
    khu_vuc VARCHAR(10), ma_vi_tri INT, ngay_vao_lam DATE, trang_thai VARCHAR(20)
) ENGINE=FEDERATED
  CONNECTION='mysql://root:DistPass123@db_hcm:3306/QuanLyToaNha/NHAN_VIEN_TOA_NHA';

-- VIEW tong hop: them ten_vi_tri (join danh muc VI_TRI_CONG_VIEC cuc bo o HN,
-- danh muc nhan ban giong nhau nen ma_vi_tri dong nhat).
DROP VIEW IF EXISTS VW_Global_NHAN_VIEN_TOA_NHA;
CREATE VIEW VW_Global_NHAN_VIEN_TOA_NHA AS
    SELECT 'HN' AS chi_nhanh, n.ma_nhan_vien_toa_nha, n.ma_so_nhan_vien, n.ho_ten,
           n.khu_vuc, n.ma_vi_tri, v.ten_vi_tri, n.trang_thai
      FROM NHAN_VIEN_TOA_NHA n LEFT JOIN VI_TRI_CONG_VIEC v ON v.ma_vi_tri=n.ma_vi_tri
    UNION ALL
    SELECT 'DN', n.ma_nhan_vien_toa_nha, n.ma_so_nhan_vien, n.ho_ten,
           n.khu_vuc, n.ma_vi_tri, v.ten_vi_tri, n.trang_thai
      FROM NHAN_VIEN_TOA_NHA_DN n LEFT JOIN VI_TRI_CONG_VIEC v ON v.ma_vi_tri=n.ma_vi_tri
    UNION ALL
    SELECT 'HCM', n.ma_nhan_vien_toa_nha, n.ma_so_nhan_vien, n.ho_ten,
           n.khu_vuc, n.ma_vi_tri, v.ten_vi_tri, n.trang_thai
      FROM NHAN_VIEN_TOA_NHA_HCM n LEFT JOIN VI_TRI_CONG_VIEC v ON v.ma_vi_tri=n.ma_vi_tri;

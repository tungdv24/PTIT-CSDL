-- =====================================================================
-- SCHEMA CHI NHANH TP.HCM (node db_hcm) - CHI CO CAU TRUC BANG (chua co data)
-- Chay: mysql -uroot -pDistPass123 < schema_hcm.sql
-- Chi nhanh khong co bang FEDERATED/VIEW tong hop (dac quyen tru so HN).
-- =====================================================================
CREATE DATABASE IF NOT EXISTS QuanLyToaNha CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE QuanLyToaNha;

-- ---- Danh muc chung (nhan ban tu tru so) ----
CREATE TABLE IF NOT EXISTS DICH_VU (
    ma_dich_vu INT AUTO_INCREMENT PRIMARY KEY,
    ma_so_dich_vu VARCHAR(50) NOT NULL UNIQUE,
    ten_dich_vu VARCHAR(100) NOT NULL,
    loai_dich_vu VARCHAR(50) NOT NULL,
    cach_tinh_phi VARCHAR(50) NOT NULL,
    don_gia_co_ban DECIMAL(15,2) NOT NULL DEFAULT 0,
    don_vi_tinh VARCHAR(50) NOT NULL,
    trang_thai VARCHAR(20) DEFAULT 'HOAT_DONG'
);

CREATE TABLE IF NOT EXISTS LOAI_CHI_PHI (
    ma_loai_chi_phi INT AUTO_INCREMENT PRIMARY KEY,
    ten_loai_chi_phi VARCHAR(100) NOT NULL UNIQUE,
    mo_ta VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS VI_TRI_CONG_VIEC (
    ma_vi_tri INT AUTO_INCREMENT PRIMARY KEY,
    ma_so_vi_tri VARCHAR(50) NOT NULL UNIQUE,
    ten_vi_tri VARCHAR(100) NOT NULL,
    luong_co_ban DECIMAL(15,2) NOT NULL DEFAULT 0,
    ty_le_doanh_thu DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    mo_ta TEXT
);

-- ---- Nhan vien toa nha khu vuc TP.HCM (phan manh) ----
CREATE TABLE IF NOT EXISTS NHAN_VIEN_TOA_NHA (
    ma_nhan_vien_toa_nha INT AUTO_INCREMENT PRIMARY KEY,
    ma_so_nhan_vien VARCHAR(50) NOT NULL UNIQUE,
    ho_ten VARCHAR(100) NOT NULL,
    ngay_sinh DATE,
    gioi_tinh VARCHAR(10),
    so_dien_thoai VARCHAR(20) NOT NULL,
    email VARCHAR(100),
    khu_vuc VARCHAR(10) NOT NULL DEFAULT 'HCM',
    ngay_vao_lam DATE NOT NULL,
    trang_thai VARCHAR(20) DEFAULT 'DANG_LAM'
);

-- ---- Cac bang du lieu khu vuc DN ----
CREATE TABLE IF NOT EXISTS CONG_TY (
    ma_cong_ty INT AUTO_INCREMENT PRIMARY KEY,
    ma_so_cong_ty VARCHAR(20) NOT NULL UNIQUE,
    ma_so_thue VARCHAR(20) NOT NULL UNIQUE,
    ten_cong_ty VARCHAR(255) NOT NULL,
    nguoi_dai_dien VARCHAR(100) NOT NULL,
    so_dien_thoai VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL,
    dia_chi VARCHAR(255),
    khu_vuc VARCHAR(10) NOT NULL DEFAULT 'HCM',
    trang_thai VARCHAR(20) DEFAULT 'DANG_THUE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS VAN_PHONG (
    ma_van_phong INT AUTO_INCREMENT PRIMARY KEY,
    ky_hieu_van_phong VARCHAR(50) NOT NULL UNIQUE,
    tang INT NOT NULL,
    vi_tri VARCHAR(100),
    dien_tich DECIMAL(10,2) NOT NULL,
    don_gia_m2 DECIMAL(15,2) NOT NULL,
    khu_vuc VARCHAR(10) NOT NULL DEFAULT 'HCM',
    trang_thai VARCHAR(20) DEFAULT 'TRONG'
);

CREATE TABLE IF NOT EXISTS NHAN_VIEN_CONG_TY (
    ma_nhan_vien INT AUTO_INCREMENT PRIMARY KEY,
    ma_so_nhan_vien VARCHAR(50) NOT NULL UNIQUE,
    ma_cong_ty INT NOT NULL,
    ho_ten VARCHAR(100) NOT NULL,
    ngay_sinh DATE,
    gioi_tinh VARCHAR(10),
    so_dien_thoai VARCHAR(20),
    email VARCHAR(100),
    chuc_vu VARCHAR(100),
    ngay_bat_dau DATE NOT NULL,
    ngay_ket_thuc DATE,
    trang_thai VARCHAR(20) DEFAULT 'HOAT_DONG'
);

CREATE TABLE IF NOT EXISTS HOP_DONG_THUE (
    ma_hop_dong INT AUTO_INCREMENT PRIMARY KEY,
    so_hop_dong VARCHAR(100) NOT NULL UNIQUE,
    ma_cong_ty INT NOT NULL,
    ngay_bat_dau DATE NOT NULL,
    ngay_ket_thuc DATE NOT NULL,
    tien_dat_coc DECIMAL(15,2) DEFAULT 0,
    trang_thai VARCHAR(20) DEFAULT 'HIEU_LUC',
    ngay_tao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS CHI_TIET_HOP_DONG (
    ma_chi_tiet INT AUTO_INCREMENT PRIMARY KEY,
    ma_hop_dong INT NOT NULL,
    ma_van_phong INT NOT NULL,
    don_gia_thue_m2 DECIMAL(15,2) NOT NULL,
    ngay_bat_dau DATE NOT NULL,
    ngay_ket_thuc DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS DANG_KY_DICH_VU (
    ma_dang_ky INT AUTO_INCREMENT PRIMARY KEY,
    ma_cong_ty INT NOT NULL,
    ma_dich_vu INT NOT NULL,
    ngay_bat_dau DATE NOT NULL,
    ngay_ket_thuc DATE,
    don_gia DECIMAL(15,2) NOT NULL,
    trang_thai VARCHAR(20) DEFAULT 'DANG_DUNG'
);

CREATE TABLE IF NOT EXISTS SU_DUNG_DICH_VU (
    ma_su_dung INT AUTO_INCREMENT PRIMARY KEY,
    ma_nhan_vien INT NOT NULL,
    ma_dang_ky INT NOT NULL,
    ngay_su_dung DATE NOT NULL,
    so_luong DECIMAL(10,2) NOT NULL DEFAULT 1,
    don_gia DECIMAL(15,2) NOT NULL,
    thanh_tien DECIMAL(15,2) GENERATED ALWAYS AS (so_luong * don_gia) STORED,
    ghi_chu VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS PHAN_CONG_CONG_VIEC (
    ma_phan_cong INT AUTO_INCREMENT PRIMARY KEY,
    ma_nhan_vien_toa_nha INT NOT NULL,
    ma_vi_tri INT NOT NULL,
    ma_dich_vu INT,
    thang INT NOT NULL,
    nam INT NOT NULL,
    ngay_bat_dau DATE NOT NULL,
    ngay_ket_thuc DATE
);

CREATE TABLE IF NOT EXISTS QUAN_LY_NHAN_VIEN (
    ma_quan_ly INT AUTO_INCREMENT PRIMARY KEY,
    ma_nhan_vien INT NOT NULL,
    ma_nguoi_quan_ly INT NOT NULL,
    ngay_bat_dau DATE NOT NULL,
    ngay_ket_thuc DATE
);

CREATE TABLE IF NOT EXISTS LUONG_NHAN_VIEN (
    ma_luong INT AUTO_INCREMENT PRIMARY KEY,
    ma_nhan_vien_toa_nha INT NOT NULL,
    thang INT NOT NULL,
    nam INT NOT NULL,
    luong_co_ban DECIMAL(15,2) NOT NULL,
    doanh_thu_dich_vu DECIMAL(15,2) DEFAULT 0,
    tien_thuong DECIMAL(15,2) DEFAULT 0,
    tong_luong DECIMAL(15,2) NOT NULL,
    trang_thai VARCHAR(20) DEFAULT 'CHUA_CHI',
    ngay_chot TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_nv_thang_nam (ma_nhan_vien_toa_nha, thang, nam)
);

CREATE TABLE IF NOT EXISTS HOA_DON (
    ma_hoa_don INT AUTO_INCREMENT PRIMARY KEY,
    so_hoa_don VARCHAR(100) NOT NULL UNIQUE,
    ma_cong_ty INT NOT NULL,
    thang INT NOT NULL,
    nam INT NOT NULL,
    tien_thue_van_phong DECIMAL(15,2) NOT NULL DEFAULT 0,
    tien_dich_vu DECIMAL(15,2) NOT NULL DEFAULT 0,
    tong_tien DECIMAL(15,2) NOT NULL DEFAULT 0,
    trang_thai_thanh_toan VARCHAR(20) DEFAULT 'CHUA_THANH_TOAN',
    ngay_tao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS CHI_TIET_HOA_DON (
    ma_chi_tiet_hoa_don INT AUTO_INCREMENT PRIMARY KEY,
    ma_hoa_don INT NOT NULL,
    ma_chi_tiet_hop_dong INT,
    ma_dang_ky INT,
    loai_chi_phi VARCHAR(50) NOT NULL,
    noi_dung VARCHAR(255) NOT NULL,
    so_luong DECIMAL(10,2) NOT NULL,
    don_gia DECIMAL(15,2) NOT NULL,
    thanh_tien DECIMAL(15,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS NGUOI_DUNG (
    ma_nguoi_dung INT AUTO_INCREMENT PRIMARY KEY,
    ten_dang_nhap VARCHAR(50) NOT NULL UNIQUE,
    mat_khau_hash VARCHAR(255) NOT NULL,
    ho_ten VARCHAR(100) NOT NULL,
    vai_tro VARCHAR(20) NOT NULL DEFAULT 'NVCT',
    khu_vuc VARCHAR(10) NOT NULL DEFAULT 'HCM',
    ma_cong_ty INT NULL,
    ma_nhan_vien_toa_nha INT NULL,
    ma_nhan_vien INT NULL,
    trang_thai VARCHAR(20) DEFAULT 'HOAT_DONG',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

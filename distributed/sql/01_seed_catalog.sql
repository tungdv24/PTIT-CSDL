-- =====================================================================
-- DU LIEU DANH MUC CHUNG - nap GIONG NHAU o ca 3 node (du lieu nhan ban).
-- DICH_VU, LOAI_CHI_PHI, VI_TRI_CONG_VIEC, NHAN_VIEN_TOA_NHA.
-- =====================================================================
USE QuanLyToaNha;

INSERT INTO DICH_VU (ma_dich_vu, ma_so_dich_vu, ten_dich_vu, loai_dich_vu, cach_tinh_phi, don_gia_co_ban, don_vi_tinh, trang_thai) VALUES
(1,'DV_VESINH','Ve sinh van phong','CO_DINH','THEO_DIEN_TICH',15000,'m2/thang','HOAT_DONG'),
(2,'DV_BAOVE','An ninh bao ve','CO_DINH','THEO_DIEN_TICH',10000,'m2/thang','HOAT_DONG'),
(3,'DV_BAOTRI','Bao tri ky thuat','CO_DINH','TRON_GOI',2000000,'thang','HOAT_DONG'),
(4,'DV_ANUONG','Suat an trua','BIEN_DOI','THEO_LUOT',45000,'luot/ngay','HOAT_DONG'),
(5,'DV_GUIXE','Gui xe','BIEN_DOI','THEO_LUOT',5000,'luot/ngay','HOAT_DONG'),
(6,'DV_NUOCUONG','Nuoc uong tinh khiet','CO_DINH','THEO_DAU_NGUOI',30000,'nguoi/thang','HOAT_DONG');

INSERT INTO LOAI_CHI_PHI (ma_loai_chi_phi, ten_loai_chi_phi, mo_ta) VALUES
(1,'Dien cong cong','Tien dien khu vuc chung, thang may, den hanh lang'),
(2,'Nuoc','Tien nuoc sinh hoat chung'),
(3,'Bao tri thiet bi','Bao tri thang may, dieu hoa, PCCC'),
(4,'Thu gom rac','Dich vu ve sinh moi truong'),
(5,'Vat tu tieu hao','Mua sam vat tu van phong, ve sinh');

INSERT INTO VI_TRI_CONG_VIEC (ma_vi_tri, ma_so_vi_tri, ten_vi_tri, luong_co_ban, ty_le_doanh_thu, mo_ta) VALUES
(1,'QUAN_LY_TN','Quan ly toa nha',20000000,5.00,'Quan ly van hanh toan bo toa nha'),
(2,'TRUONG_CA','Truong ca',12000000,3.00,'Giam sat ca truc'),
(3,'KY_THUAT_VIEN','Ky thuat vien',9000000,2.00,'Bao tri he thong ky thuat'),
(4,'BAO_VE','Nhan vien bao ve',7000000,1.00,'An ninh toa nha'),
(5,'VE_SINH','Nhan vien ve sinh',6500000,1.00,'Ve sinh cong cong');

INSERT INTO NHAN_VIEN_TOA_NHA (ma_nhan_vien_toa_nha, ma_so_nhan_vien, ho_ten, ngay_sinh, gioi_tinh, so_dien_thoai, email, ngay_vao_lam, trang_thai) VALUES
(1,'BQL-001','Vu Van Quan','1985-04-12','NAM','0911111111','quan@toanha.vn','2020-01-15','DANG_LAM'),
(2,'BQL-002','Do Thi Ha','1990-07-20','NU','0912222222','ha@toanha.vn','2021-03-01','DANG_LAM'),
(3,'BQL-003','Bui Van Tung','1992-11-05','NAM','0913333333','tung@toanha.vn','2021-06-10','DANG_LAM'),
(4,'BQL-004','Ngo Thi Lan','1995-02-28','NU','0914444444','lan@toanha.vn','2022-01-05','DANG_LAM'),
(5,'BQL-005','Dang Van Minh','1988-09-17','NAM','0915555555','minh@toanha.vn','2020-08-20','DANG_LAM');

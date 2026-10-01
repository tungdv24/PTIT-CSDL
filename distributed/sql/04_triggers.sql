-- =====================================================================
-- TRIGGER cho BAN PHAN TAN - nap tren MOI node (HN / DN / HCM)
-- Gom 5 trigger rang buoc nghiep vu ve van phong / hop dong / su dung dich vu.
-- File idempotent: DROP IF EXISTS truoc khi CREATE.
--
-- Ghi chu: cac trigger ve van phong KHONG dua vao cot VAN_PHONG.trang_thai,
-- ma kiem tra truc tiep qua CHI_TIET_HOP_DONG + HOP_DONG_THUE (trang_thai=HIEU_LUC)
-- de logic doc lap, khong can trigger tu set trang thai.
-- =====================================================================
USE QuanLyToaNha;

-- Don dep cac trigger cu (neu co) de tranh roi
DROP TRIGGER IF EXISTS trg_cthd_after_insert;
DROP TRIGGER IF EXISTS trg_cthd_after_delete;
DROP TRIGGER IF EXISTS trg_cthd_no_change_vp;
DROP TRIGGER IF EXISTS trg_hoadon_before_insert;
DROP TRIGGER IF EXISTS trg_hoadon_before_update;

-- ---------------------------------------------------------------------
-- 1) Khong xoa van phong neu dang co nguoi thue (hop dong con HIEU_LUC)
-- ---------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_vanphong_before_delete;
DELIMITER $$
CREATE TRIGGER trg_vanphong_before_delete
BEFORE DELETE ON VAN_PHONG
FOR EACH ROW
BEGIN
    DECLARE v_dem INT;
    SELECT COUNT(*) INTO v_dem
    FROM CHI_TIET_HOP_DONG cthd
    JOIN HOP_DONG_THUE hd ON hd.ma_hop_dong = cthd.ma_hop_dong
    WHERE cthd.ma_van_phong = OLD.ma_van_phong
      AND hd.trang_thai = 'HIEU_LUC';
    IF v_dem > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Khong the xoa van phong dang co hop dong thue hieu luc';
    END IF;
END$$
DELIMITER ;

-- ---------------------------------------------------------------------
-- 2) Khong the co 2 hop dong thue chung mot van phong (chong lan thoi gian)
--    Kiem tra khi them dong CHI_TIET_HOP_DONG.
-- ---------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_cthd_no_overlap;
DELIMITER $$
CREATE TRIGGER trg_cthd_no_overlap
BEFORE INSERT ON CHI_TIET_HOP_DONG
FOR EACH ROW
BEGIN
    DECLARE v_dem INT;
    -- Dem cac dong CHI_TIET_HOP_DONG khac cua cung van phong ma khoang thoi gian giao nhau.
    -- Hai khoang [a1,a2] va [b1,b2] chong lan khi a1 <= b2 AND b1 <= a2.
    SELECT COUNT(*) INTO v_dem
    FROM CHI_TIET_HOP_DONG cthd
    WHERE cthd.ma_van_phong = NEW.ma_van_phong
      AND NEW.ngay_bat_dau <= cthd.ngay_ket_thuc
      AND cthd.ngay_bat_dau <= NEW.ngay_ket_thuc;
    IF v_dem > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Van phong da duoc thue trong khoang thoi gian nay (trung hop dong)';
    END IF;
END$$
DELIMITER ;

-- ---------------------------------------------------------------------
-- 3) Khong sua thong tin nghiep vu cua van phong khi dang duoc su dung
--    (dang nam trong hop dong hieu luc). Van cho doi cot trang_thai.
-- ---------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_vanphong_no_edit_when_used;
DELIMITER $$
CREATE TRIGGER trg_vanphong_no_edit_when_used
BEFORE UPDATE ON VAN_PHONG
FOR EACH ROW
BEGIN
    DECLARE v_dem INT;
    -- Chi chan khi thay doi cot nghiep vu quan trong
    IF (NEW.ky_hieu_van_phong <> OLD.ky_hieu_van_phong
        OR NEW.tang <> OLD.tang
        OR NEW.dien_tich <> OLD.dien_tich
        OR NEW.don_gia_m2 <> OLD.don_gia_m2) THEN
        SELECT COUNT(*) INTO v_dem
        FROM CHI_TIET_HOP_DONG cthd
        JOIN HOP_DONG_THUE hd ON hd.ma_hop_dong = cthd.ma_hop_dong
        WHERE cthd.ma_van_phong = OLD.ma_van_phong
          AND hd.trang_thai = 'HIEU_LUC';
        IF v_dem > 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Khong the sua thong tin van phong dang duoc thue (hop dong hieu luc)';
        END IF;
    END IF;
END$$
DELIMITER ;

-- ---------------------------------------------------------------------
-- 4) NVCT chi dung dich vu cong ty minh da dang ky
--    (nhan vien phai thuoc dung cong ty cua dang ky dich vu)
-- ---------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_sudung_check_company;
DELIMITER $$
CREATE TRIGGER trg_sudung_check_company
BEFORE INSERT ON SU_DUNG_DICH_VU
FOR EACH ROW
BEGIN
    DECLARE v_cty_nv INT;
    DECLARE v_cty_dk INT;
    SELECT ma_cong_ty INTO v_cty_nv FROM NHAN_VIEN_CONG_TY WHERE ma_nhan_vien = NEW.ma_nhan_vien;
    SELECT ma_cong_ty INTO v_cty_dk FROM DANG_KY_DICH_VU WHERE ma_dang_ky = NEW.ma_dang_ky;
    IF v_cty_nv IS NULL OR v_cty_dk IS NULL OR v_cty_nv <> v_cty_dk THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nhan vien khong thuoc cong ty da dang ky dich vu nay';
    END IF;
END$$
DELIMITER ;

-- ---------------------------------------------------------------------
-- 5) Kiem tra ngay hop dong: ngay_ket_thuc phai >= ngay_bat_dau
--    (ap dung khi them va khi sua hop dong)
-- ---------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_hopdong_check_ngay_insert;
DELIMITER $$
CREATE TRIGGER trg_hopdong_check_ngay_insert
BEFORE INSERT ON HOP_DONG_THUE
FOR EACH ROW
BEGIN
    IF NEW.ngay_ket_thuc < NEW.ngay_bat_dau THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ngay ket thuc hop dong phai >= ngay bat dau';
    END IF;
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS trg_hopdong_check_ngay_update;
DELIMITER $$
CREATE TRIGGER trg_hopdong_check_ngay_update
BEFORE UPDATE ON HOP_DONG_THUE
FOR EACH ROW
BEGIN
    IF NEW.ngay_ket_thuc < NEW.ngay_bat_dau THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ngay ket thuc hop dong phai >= ngay bat dau';
    END IF;
END$$
DELIMITER ;

-- ---------------------------------------------------------------------
-- 6) Nhan vien toa nha khong the tu quan ly chinh minh (bang QUAN_LY_NHAN_VIEN)
-- ---------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_quanly_no_self;
DELIMITER $$
CREATE TRIGGER trg_quanly_no_self
BEFORE INSERT ON QUAN_LY_NHAN_VIEN
FOR EACH ROW
BEGIN
    DECLARE v_la_quan_ly INT;
    -- 6a) Khong tu quan ly chinh minh
    IF NEW.ma_nhan_vien = NEW.ma_nguoi_quan_ly THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nhan vien khong the tu quan ly chinh minh';
    END IF;
    -- 6b) Da la quan ly thi khong bi quan ly (mo hinh 2 tang phang)
    SELECT COUNT(*) INTO v_la_quan_ly
    FROM QUAN_LY_NHAN_VIEN
    WHERE ma_nguoi_quan_ly = NEW.ma_nhan_vien AND ngay_ket_thuc IS NULL;
    IF v_la_quan_ly > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nguoi nay dang la quan ly nen khong the bi quan ly';
    END IF;
END$$
DELIMITER ;

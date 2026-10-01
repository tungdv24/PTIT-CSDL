-- =====================================================================
-- STORED PROCEDURE (TRANSACTION) - nap tren MOI node (HN / DN / HCM)
-- =====================================================================
-- Day la cac GIAO DICH CUC BO (local transaction) tren tung node: moi
-- procedure chi thao tac du lieu cua chi nhanh dang dang nhap (vi du chot hoa
-- don cho 1 cong ty thuoc node do). KHONG doc/ghi cheo node nen an toan cho he
-- phan tan (khong can two-phase commit, khong dung FEDERATED).
--
-- Moi procedure dung transaction tuong minh:
--   START TRANSACTION; ...; COMMIT;  +  EXIT HANDLER -> ROLLBACK & RESIGNAL.
-- Khong tu cap khoa chinh (MAX+1) vi cac bang da AUTO_INCREMENT.
--
-- File idempotent: DROP IF EXISTS truoc khi tao lai.
-- =====================================================================
USE QuanLyToaNha;

-- ---------------------------------------------------------------------
-- TX1: Thay doi nguoi quan ly cua mot nhan vien toa nha (luu lich su)
--   - Ket thuc quan he quan ly hien tai (ngay_ket_thuc = ngay_thay_doi - 1)
--   - Mo quan he quan ly moi (ngay_ket_thuc = NULL)
--   Ca 2 buoc trong MOT transaction -> nguyen tu. Tuong thich trigger
--   trg_quanly_no_self (neu vi pham, trigger SIGNAL -> HANDLER rollback & bao loi).
-- ---------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_ThayDoiNguoiQuanLy;
DELIMITER $$
CREATE PROCEDURE sp_ThayDoiNguoiQuanLy(
    IN p_ma_nhan_vien INT,
    IN p_ma_nguoi_quan_ly_moi INT,
    IN p_ngay_thay_doi DATE
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
        -- Ket thuc quan he dang hieu luc (neu co)
        UPDATE QUAN_LY_NHAN_VIEN
        SET ngay_ket_thuc = DATE_SUB(p_ngay_thay_doi, INTERVAL 1 DAY)
        WHERE ma_nhan_vien = p_ma_nhan_vien AND ngay_ket_thuc IS NULL;

        -- Mo quan he quan ly moi (AUTO_INCREMENT tu sinh ma_quan_ly)
        INSERT INTO QUAN_LY_NHAN_VIEN (ma_nhan_vien, ma_nguoi_quan_ly, ngay_bat_dau, ngay_ket_thuc)
        VALUES (p_ma_nhan_vien, p_ma_nguoi_quan_ly_moi, p_ngay_thay_doi, NULL);
    COMMIT;
END$$
DELIMITER ;

-- ---------------------------------------------------------------------
-- TX2: Thue them mot van phong cho hop dong (them dong CHI_TIET_HOP_DONG)
--   ngay_ket_thuc la NOT NULL trong schema -> nhan tham so.
--   Trigger trg_cthd_no_overlap se tu chan neu VP da duoc thue trung thoi gian.
-- ---------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_ThueVanPhong;
DELIMITER $$
CREATE PROCEDURE sp_ThueVanPhong(
    IN p_ma_hop_dong INT,
    IN p_ma_van_phong INT,
    IN p_don_gia_thue_m2 DECIMAL(15,2),
    IN p_ngay_bat_dau DATE,
    IN p_ngay_ket_thuc DATE
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
        INSERT INTO CHI_TIET_HOP_DONG
            (ma_hop_dong, ma_van_phong, don_gia_thue_m2, ngay_bat_dau, ngay_ket_thuc)
        VALUES
            (p_ma_hop_dong, p_ma_van_phong, p_don_gia_thue_m2, p_ngay_bat_dau, p_ngay_ket_thuc);
    COMMIT;
END$$
DELIMITER ;

-- ---------------------------------------------------------------------
-- TX3: Tinh tien dich vu bac thang theo QUY MO cong ty (so NV & dien tich thue)
--   - so_nhan_vien = COUNT nhan vien cong ty dang hoat dong
--   - dien_tich    = SUM dien tich cac van phong dang thue (hop dong HIEU_LUC)
--   - ty_le_tang   += 5% moi 5 NV vuot nguong 10; += 5% moi 10 m2 vuot nguong 100
--   Tra ket qua qua tham so OUT (chi tinh toan, khong ghi DB).
-- ---------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_TinhTienDichVuBacThang;
DELIMITER $$
CREATE PROCEDURE sp_TinhTienDichVuBacThang(
    IN  p_ma_cong_ty INT,
    IN  p_don_gia_goc DECIMAL(15,2),
    IN  p_so_ngay_su_dung INT,
    IN  p_so_ngay_trong_thang INT,
    OUT p_thanh_tien DECIMAL(15,2)
)
BEGIN
    DECLARE v_so_nhan_vien INT DEFAULT 0;
    DECLARE v_dien_tich DECIMAL(15,2) DEFAULT 0;
    DECLARE v_ty_le_tang DECIMAL(10,4) DEFAULT 0;

    SELECT COUNT(*) INTO v_so_nhan_vien
    FROM NHAN_VIEN_CONG_TY
    WHERE ma_cong_ty = p_ma_cong_ty AND trang_thai = 'HOAT_DONG';

    SELECT IFNULL(SUM(vp.dien_tich), 0) INTO v_dien_tich
    FROM CHI_TIET_HOP_DONG cthd
    JOIN HOP_DONG_THUE hd ON hd.ma_hop_dong = cthd.ma_hop_dong
    JOIN VAN_PHONG vp ON vp.ma_van_phong = cthd.ma_van_phong
    WHERE hd.ma_cong_ty = p_ma_cong_ty AND hd.trang_thai = 'HIEU_LUC';

    IF v_so_nhan_vien > 10 THEN
        SET v_ty_le_tang = v_ty_le_tang + (FLOOR((v_so_nhan_vien - 10) / 5) * 0.05);
    END IF;
    IF v_dien_tich > 100 THEN
        SET v_ty_le_tang = v_ty_le_tang + (FLOOR((v_dien_tich - 100) / 10) * 0.05);
    END IF;

    SET p_thanh_tien = (p_don_gia_goc * (1 + v_ty_le_tang))
                       * (p_so_ngay_su_dung / p_so_ngay_trong_thang);
END$$
DELIMITER ;

-- ---------------------------------------------------------------------
-- TX4: Tinh & CHOT luong nhan vien toa nha thang/nam (ghi vao LUONG_NHAN_VIEN)
--   - luong_co_ban: tu VI_TRI_CONG_VIEC theo vi tri cua nhan vien
--   - doanh_thu_dich_vu: tong thanh_tien dich vu ma NV PHU TRACH (qua
--     PHAN_CONG_CONG_VIEC) trong thang
--   - tien_thuong = doanh_thu_dich_vu * ty_le_doanh_thu% (hoa hong)
--   - tong_luong  = luong_co_ban + tien_thuong
--   Dung UNIQUE(ma_nhan_vien_toa_nha,thang,nam) -> INSERT ... ON DUPLICATE UPDATE
--   de chay lai an toan (idempotent). Toan bo trong 1 transaction.
-- ---------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_ChotLuongThang;
DELIMITER $$
CREATE PROCEDURE sp_ChotLuongThang(
    IN p_thang INT,
    IN p_nam INT
)
BEGIN
    DECLARE v_done INT DEFAULT 0;
    DECLARE v_ma_nv INT;
    DECLARE v_luong_cb DECIMAL(15,2);
    DECLARE v_ty_le DECIMAL(10,4);
    DECLARE v_doanh_thu DECIMAL(15,2);
    DECLARE v_thuong DECIMAL(15,2);

    DECLARE cur CURSOR FOR
        SELECT nv.ma_nhan_vien_toa_nha,
               IFNULL(vt.luong_co_ban, 0),
               IFNULL(vt.ty_le_doanh_thu, 0)
        FROM NHAN_VIEN_TOA_NHA nv
        LEFT JOIN VI_TRI_CONG_VIEC vt ON vt.ma_vi_tri = nv.ma_vi_tri
        WHERE nv.trang_thai = 'DANG_LAM';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
        OPEN cur;
        doc: LOOP
            FETCH cur INTO v_ma_nv, v_luong_cb, v_ty_le;
            IF v_done = 1 THEN LEAVE doc; END IF;

            -- Doanh thu dich vu NV nay phu trach trong thang (qua PHAN_CONG_CONG_VIEC)
            SELECT IFNULL(SUM(sd.thanh_tien), 0) INTO v_doanh_thu
            FROM PHAN_CONG_CONG_VIEC pc
            JOIN DANG_KY_DICH_VU dk   ON dk.ma_dich_vu = pc.ma_dich_vu
            JOIN SU_DUNG_DICH_VU sd   ON sd.ma_dang_ky = dk.ma_dang_ky
            WHERE pc.ma_nhan_vien_toa_nha = v_ma_nv
              AND pc.thang = p_thang AND pc.nam = p_nam
              AND MONTH(sd.ngay_su_dung) = p_thang
              AND YEAR(sd.ngay_su_dung)  = p_nam;

            SET v_thuong = v_doanh_thu * v_ty_le / 100;

            INSERT INTO LUONG_NHAN_VIEN
                (ma_nhan_vien_toa_nha, thang, nam, luong_co_ban, doanh_thu_dich_vu, tien_thuong, tong_luong)
            VALUES
                (v_ma_nv, p_thang, p_nam, v_luong_cb, v_doanh_thu, v_thuong, v_luong_cb + v_thuong)
            ON DUPLICATE KEY UPDATE
                luong_co_ban      = VALUES(luong_co_ban),
                doanh_thu_dich_vu = VALUES(doanh_thu_dich_vu),
                tien_thuong       = VALUES(tien_thuong),
                tong_luong        = VALUES(tong_luong);
        END LOOP;
        CLOSE cur;
    COMMIT;
END$$
DELIMITER ;

-- ---------------------------------------------------------------------
-- TX5: Chot hoa don thang cho mot cong ty (tien thue VP + tien dich vu)
--   - tien_thue = SUM(dien_tich * don_gia_thue_m2) cua hop dong HIEU_LUC
--   - tien_dich_vu = SUM thanh_tien SU_DUNG_DICH_VU cua NV thuoc cong ty trong thang
--   - so_hoa_don tu sinh (NOT NULL UNIQUE); neu da co hoa don thang do -> bao loi.
--   Toan bo trong 1 transaction.
-- ---------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_ChotHoaDonThang;
DELIMITER $$
CREATE PROCEDURE sp_ChotHoaDonThang(
    IN p_ma_cong_ty INT,
    IN p_thang INT,
    IN p_nam INT
)
BEGIN
    DECLARE v_tien_thue DECIMAL(15,2) DEFAULT 0;
    DECLARE v_tien_dv DECIMAL(15,2) DEFAULT 0;
    DECLARE v_da_co INT DEFAULT 0;
    DECLARE v_so_hd VARCHAR(100);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
        -- Chong tao trung hoa don cung cong ty + thang + nam
        SELECT COUNT(*) INTO v_da_co
        FROM HOA_DON WHERE ma_cong_ty = p_ma_cong_ty AND thang = p_thang AND nam = p_nam;
        IF v_da_co > 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Hoa don cua cong ty nay trong thang da ton tai';
        END IF;

        -- 1) Tien thue van phong (hop dong hieu luc)
        SELECT IFNULL(SUM(vp.dien_tich * cthd.don_gia_thue_m2), 0) INTO v_tien_thue
        FROM HOP_DONG_THUE hd
        JOIN CHI_TIET_HOP_DONG cthd ON cthd.ma_hop_dong = hd.ma_hop_dong
        JOIN VAN_PHONG vp ON vp.ma_van_phong = cthd.ma_van_phong
        WHERE hd.ma_cong_ty = p_ma_cong_ty AND hd.trang_thai = 'HIEU_LUC';

        -- 2) Tien dich vu theo su dung thuc te trong thang
        SELECT IFNULL(SUM(sd.thanh_tien), 0) INTO v_tien_dv
        FROM SU_DUNG_DICH_VU sd
        JOIN NHAN_VIEN_CONG_TY nv ON nv.ma_nhan_vien = sd.ma_nhan_vien
        WHERE nv.ma_cong_ty = p_ma_cong_ty
          AND MONTH(sd.ngay_su_dung) = p_thang
          AND YEAR(sd.ngay_su_dung)  = p_nam;

        SET v_so_hd = CONCAT('INV-', p_nam, LPAD(p_thang,2,'0'), '-CT', LPAD(p_ma_cong_ty,2,'0'));

        INSERT INTO HOA_DON
            (so_hoa_don, ma_cong_ty, thang, nam, tien_thue_van_phong, tien_dich_vu, tong_tien, trang_thai_thanh_toan)
        VALUES
            (v_so_hd, p_ma_cong_ty, p_thang, p_nam, v_tien_thue, v_tien_dv, v_tien_thue + v_tien_dv, 'CHUA_THANH_TOAN');
    COMMIT;
END$$
DELIMITER ;

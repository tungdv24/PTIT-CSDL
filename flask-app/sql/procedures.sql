-- =====================================================================
-- QuanLyToaNha - TRIGGERS & STORED PROCEDURES (TRANSACTIONS)
-- Chuyen logic nghiep vu tu tang ung dung (Python) xuong CSDL (MySQL).
-- File nay idempotent: DROP IF EXISTS truoc khi CREATE.
-- =====================================================================
USE QuanLyToaNha;

-- ############### TRIGGERS (5) ###############

-- 1) Khi them mot van phong vao hop dong -> danh dau van phong DA_THUE.
DROP TRIGGER IF EXISTS trg_cthd_after_insert;
CREATE TRIGGER trg_cthd_after_insert
AFTER INSERT ON CHI_TIET_HOP_DONG
FOR EACH ROW
    UPDATE VAN_PHONG SET trang_thai = 'DA_THUE'
    WHERE ma_van_phong = NEW.ma_van_phong;

-- 2) Khi xoa chi tiet hop dong -> tra van phong ve TRONG.
DROP TRIGGER IF EXISTS trg_cthd_after_delete;
CREATE TRIGGER trg_cthd_after_delete
AFTER DELETE ON CHI_TIET_HOP_DONG
FOR EACH ROW
    UPDATE VAN_PHONG SET trang_thai = 'TRONG'
    WHERE ma_van_phong = OLD.ma_van_phong;

-- 2b) Khong cho doi van phong cua mot chi tiet hop dong da tao (chi cho sua thong tin khac).
DROP TRIGGER IF EXISTS trg_cthd_no_change_vp;
DELIMITER $$
CREATE TRIGGER trg_cthd_no_change_vp
BEFORE UPDATE ON CHI_TIET_HOP_DONG
FOR EACH ROW
BEGIN
    IF NEW.ma_van_phong <> OLD.ma_van_phong THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Khong the doi van phong cua chi tiet hop dong. Hay xoa dong nay va them dong moi.';
    END IF;
END$$
DELIMITER ;

-- 3) Chan mot nhan vien tu quan ly chinh minh trong QUAN_LY_NHAN_VIEN.
DROP TRIGGER IF EXISTS trg_quanly_no_self;
DELIMITER $$
CREATE TRIGGER trg_quanly_no_self
BEFORE INSERT ON QUAN_LY_NHAN_VIEN
FOR EACH ROW
BEGIN
    IF NEW.ma_nhan_vien = NEW.ma_nguoi_quan_ly THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nhan vien khong the tu quan ly chinh minh';
    END IF;
END$$
DELIMITER ;

-- 4) Rang buoc: nhan vien su dung dich vu phai thuoc dung cong ty da dang ky.
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

-- 5) Tu dong tinh tong_tien = tien_thue_van_phong + tien_dich_vu khi ghi hoa don.
DROP TRIGGER IF EXISTS trg_hoadon_before_insert;
CREATE TRIGGER trg_hoadon_before_insert
BEFORE INSERT ON HOA_DON
FOR EACH ROW
    SET NEW.tong_tien = COALESCE(NEW.tien_thue_van_phong,0) + COALESCE(NEW.tien_dich_vu,0);

DROP TRIGGER IF EXISTS trg_hoadon_before_update;
CREATE TRIGGER trg_hoadon_before_update
BEFORE UPDATE ON HOA_DON
FOR EACH ROW
    SET NEW.tong_tien = COALESCE(NEW.tien_thue_van_phong,0) + COALESCE(NEW.tien_dich_vu,0);


-- ############### STORED PROCEDURES / TRANSACTIONS (5) ###############

-- 1) Tao hoa don thang cho MOT cong ty (header + chi tiet) trong MOT giao dich.
DROP PROCEDURE IF EXISTS sp_tao_hoa_don_thang;
DELIMITER $$
CREATE PROCEDURE sp_tao_hoa_don_thang(
    IN p_ma_cong_ty INT, IN p_thang INT, IN p_nam INT, OUT p_ma_hoa_don INT)
proc: BEGIN
    DECLARE v_tien_thue   DECIMAL(15,2) DEFAULT 0;
    DECLARE v_tien_dv     DECIMAL(15,2) DEFAULT 0;
    DECLARE v_tong_dt     DECIMAL(15,2) DEFAULT 0;
    DECLARE v_so_nguoi    INT DEFAULT 0;
    DECLARE v_so_hd       VARCHAR(100);
    DECLARE v_done        INT DEFAULT 0;
    -- con tro cho dich vu dang ky
    DECLARE c_dk          INT;
    DECLARE c_dongia      DECIMAL(15,2);
    DECLARE c_ten         VARCHAR(100);
    DECLARE c_cach        VARCHAR(50);
    DECLARE v_sl          DECIMAL(15,2);
    DECLARE v_tt          DECIMAL(15,2);
    DECLARE cur CURSOR FOR
        SELECT dk.ma_dang_ky, dk.don_gia, dv.ten_dich_vu, dv.cach_tinh_phi
        FROM DANG_KY_DICH_VU dk JOIN DICH_VU dv ON dv.ma_dich_vu = dk.ma_dich_vu
        WHERE dk.ma_cong_ty = p_ma_cong_ty AND dk.trang_thai = 'DANG_DUNG';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;

    SET p_ma_hoa_don = NULL;
    -- Da co hoa don ky nay -> khong lam gi (rang buoc UNIQUE uq_cty_thang_nam).
    IF EXISTS (SELECT 1 FROM HOA_DON WHERE ma_cong_ty=p_ma_cong_ty AND thang=p_thang AND nam=p_nam) THEN
        LEAVE proc;
    END IF;

    START TRANSACTION;

    -- Tong dien tich + so nhan vien hoat dong (dung cho dich vu THEO_DIEN_TICH / THEO_DAU_NGUOI)
    SELECT COALESCE(SUM(vp.dien_tich),0) INTO v_tong_dt
    FROM CHI_TIET_HOP_DONG cthd
    JOIN HOP_DONG_THUE hdt ON hdt.ma_hop_dong=cthd.ma_hop_dong
    JOIN VAN_PHONG vp ON vp.ma_van_phong=cthd.ma_van_phong
    WHERE hdt.ma_cong_ty=p_ma_cong_ty AND hdt.trang_thai='HIEU_LUC';

    SELECT COUNT(*) INTO v_so_nguoi FROM NHAN_VIEN_CONG_TY
    WHERE ma_cong_ty=p_ma_cong_ty AND trang_thai='HOAT_DONG';

    -- Tao header truoc (tong_tien tam 0; trigger se tinh lai khi UPDATE cuoi)
    SET v_so_hd = CONCAT('INV-', p_nam, LPAD(p_thang,2,'0'), '-CT', LPAD(p_ma_cong_ty,2,'0'));
    INSERT INTO HOA_DON (so_hoa_don, ma_cong_ty, thang, nam, tien_thue_van_phong, tien_dich_vu)
    VALUES (v_so_hd, p_ma_cong_ty, p_thang, p_nam, 0, 0);
    SET p_ma_hoa_don = LAST_INSERT_ID();

    -- (1) Tien thue van phong: 1 dong / van phong trong hop dong hieu luc
    INSERT INTO CHI_TIET_HOA_DON (ma_hoa_don, ma_chi_tiet_hop_dong, loai_chi_phi, noi_dung, so_luong, don_gia, thanh_tien)
    SELECT p_ma_hoa_don, cthd.ma_chi_tiet, 'TIEN_THUE_PHONG',
           CONCAT('Thue phong ', vp.ky_hieu_van_phong, ' (', vp.dien_tich, 'm2)'),
           vp.dien_tich, cthd.don_gia_thue_m2, vp.dien_tich * cthd.don_gia_thue_m2
    FROM CHI_TIET_HOP_DONG cthd
    JOIN HOP_DONG_THUE hdt ON hdt.ma_hop_dong=cthd.ma_hop_dong
    JOIN VAN_PHONG vp ON vp.ma_van_phong=cthd.ma_van_phong
    WHERE hdt.ma_cong_ty=p_ma_cong_ty AND hdt.trang_thai='HIEU_LUC';

    SELECT COALESCE(SUM(thanh_tien),0) INTO v_tien_thue
    FROM CHI_TIET_HOA_DON WHERE ma_hoa_don=p_ma_hoa_don AND loai_chi_phi='TIEN_THUE_PHONG';

    -- (2) Tien dich vu: duyet tung dang ky dich vu
    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO c_dk, c_dongia, c_ten, c_cach;
        IF v_done = 1 THEN LEAVE read_loop; END IF;

        IF c_cach = 'THEO_DIEN_TICH' THEN
            SET v_sl = v_tong_dt; SET v_tt = v_tong_dt * c_dongia;
        ELSEIF c_cach = 'THEO_DAU_NGUOI' THEN
            SET v_sl = v_so_nguoi; SET v_tt = v_so_nguoi * c_dongia;
        ELSEIF c_cach = 'TRON_GOI' THEN
            SET v_sl = 1; SET v_tt = c_dongia;
        ELSEIF c_cach = 'THEO_LUOT' THEN
            SELECT COALESCE(SUM(so_luong),0), COALESCE(SUM(thanh_tien),0) INTO v_sl, v_tt
            FROM SU_DUNG_DICH_VU
            WHERE ma_dang_ky=c_dk AND MONTH(ngay_su_dung)=p_thang AND YEAR(ngay_su_dung)=p_nam;
        ELSE
            SET v_sl = 0; SET v_tt = 0;
        END IF;

        IF v_tt > 0 THEN
            INSERT INTO CHI_TIET_HOA_DON (ma_hoa_don, ma_dang_ky, loai_chi_phi, noi_dung, so_luong, don_gia, thanh_tien)
            VALUES (p_ma_hoa_don, c_dk, 'TIEN_DICH_VU', c_ten, v_sl, c_dongia, v_tt);
            SET v_tien_dv = v_tien_dv + v_tt;
        END IF;
    END LOOP;
    CLOSE cur;

    -- Cap nhat tong tien (trigger trg_hoadon_before_update tu tinh tong_tien)
    UPDATE HOA_DON SET tien_thue_van_phong=v_tien_thue, tien_dich_vu=v_tien_dv
    WHERE ma_hoa_don=p_ma_hoa_don;

    COMMIT;
END proc$$
DELIMITER ;

-- 2) Tao hoa don cho TAT CA cong ty dang thue trong thang. Tra ve so hoa don tao moi.
DROP PROCEDURE IF EXISTS sp_tao_hoa_don_tat_ca;
DELIMITER $$
CREATE PROCEDURE sp_tao_hoa_don_tat_ca(IN p_thang INT, IN p_nam INT, OUT p_so_tao INT)
BEGIN
    DECLARE v_done INT DEFAULT 0;
    DECLARE v_cty  INT;
    DECLARE v_hd   INT;
    DECLARE cur CURSOR FOR SELECT ma_cong_ty FROM CONG_TY WHERE trang_thai='DANG_THUE';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;
    SET p_so_tao = 0;
    OPEN cur;
    lp: LOOP
        FETCH cur INTO v_cty;
        IF v_done = 1 THEN LEAVE lp; END IF;
        CALL sp_tao_hoa_don_thang(v_cty, p_thang, p_nam, v_hd);
        IF v_hd IS NOT NULL THEN SET p_so_tao = p_so_tao + 1; END IF;
    END LOOP;
    CLOSE cur;
END$$
DELIMITER ;

-- 3) Tinh luong thang cho tat ca nhan vien duoc phan cong trong thang (giao dich).
DROP PROCEDURE IF EXISTS sp_tinh_luong_thang;
DELIMITER $$
CREATE PROCEDURE sp_tinh_luong_thang(IN p_thang INT, IN p_nam INT, OUT p_so_tao INT)
BEGIN
    DECLARE v_done INT DEFAULT 0;
    DECLARE v_nv INT; DECLARE v_dv INT;
    DECLARE v_luongcb DECIMAL(15,2); DECLARE v_tyle DECIMAL(5,2);
    DECLARE v_doanhthu DECIMAL(15,2); DECLARE v_thuong DECIMAL(15,2);
    DECLARE cur CURSOR FOR
        SELECT pc.ma_nhan_vien_toa_nha, pc.ma_dich_vu, vt.luong_co_ban, vt.ty_le_doanh_thu
        FROM PHAN_CONG_CONG_VIEC pc
        JOIN VI_TRI_CONG_VIEC vt ON vt.ma_vi_tri=pc.ma_vi_tri
        WHERE pc.thang=p_thang AND pc.nam=p_nam;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;

    SET p_so_tao = 0;
    START TRANSACTION;
    OPEN cur;
    lp: LOOP
        FETCH cur INTO v_nv, v_dv, v_luongcb, v_tyle;
        IF v_done = 1 THEN LEAVE lp; END IF;

        -- Bo qua neu da co bang luong ky nay
        IF NOT EXISTS (SELECT 1 FROM LUONG_NHAN_VIEN
                       WHERE ma_nhan_vien_toa_nha=v_nv AND thang=p_thang AND nam=p_nam) THEN
            SET v_doanhthu = 0;
            IF v_dv IS NOT NULL THEN
                SELECT COALESCE(SUM(ct.thanh_tien),0) INTO v_doanhthu
                FROM CHI_TIET_HOA_DON ct
                JOIN HOA_DON hd ON hd.ma_hoa_don=ct.ma_hoa_don
                JOIN DANG_KY_DICH_VU dk ON dk.ma_dang_ky=ct.ma_dang_ky
                WHERE dk.ma_dich_vu=v_dv AND hd.thang=p_thang AND hd.nam=p_nam;
            END IF;
            SET v_thuong = v_doanhthu * v_tyle / 100;
            INSERT INTO LUONG_NHAN_VIEN
                (ma_nhan_vien_toa_nha, thang, nam, luong_co_ban, doanh_thu_dich_vu, tien_thuong, tong_luong)
            VALUES (v_nv, p_thang, p_nam, v_luongcb, v_doanhthu, v_thuong, v_luongcb + v_thuong);
            SET p_so_tao = p_so_tao + 1;
        END IF;
    END LOOP;
    CLOSE cur;
    COMMIT;
END$$
DELIMITER ;

-- 4) Ghi nhan mot luot su dung dich vu (giao dich; trigger #4 kiem tra rang buoc).
DROP PROCEDURE IF EXISTS sp_ghi_su_dung_dich_vu;
DELIMITER $$
CREATE PROCEDURE sp_ghi_su_dung_dich_vu(
    IN p_ma_nhan_vien INT, IN p_ma_dang_ky INT, IN p_ngay DATE,
    IN p_so_luong DECIMAL(10,2), IN p_don_gia DECIMAL(15,2), IN p_ghi_chu VARCHAR(255),
    OUT p_ma_su_dung INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
    START TRANSACTION;
    INSERT INTO SU_DUNG_DICH_VU (ma_nhan_vien, ma_dang_ky, ngay_su_dung, so_luong, don_gia, ghi_chu)
    VALUES (p_ma_nhan_vien, p_ma_dang_ky, p_ngay, p_so_luong, p_don_gia, p_ghi_chu);
    SET p_ma_su_dung = LAST_INSERT_ID();
    COMMIT;
END$$
DELIMITER ;

-- 5) Thanh ly hop dong: doi trang thai hop dong + tra cac van phong ve TRONG (giao dich).
DROP PROCEDURE IF EXISTS sp_thanh_ly_hop_dong;
DELIMITER $$
CREATE PROCEDURE sp_thanh_ly_hop_dong(IN p_ma_hop_dong INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
    START TRANSACTION;
    UPDATE HOP_DONG_THUE SET trang_thai='DA_THANH_LY' WHERE ma_hop_dong=p_ma_hop_dong;
    UPDATE VAN_PHONG SET trang_thai='TRONG'
    WHERE ma_van_phong IN (SELECT ma_van_phong FROM CHI_TIET_HOP_DONG WHERE ma_hop_dong=p_ma_hop_dong);
    COMMIT;
END$$
DELIMITER ;

-- 6) Thanh toan hoa don (giao dich don gian).
DROP PROCEDURE IF EXISTS sp_thanh_toan_hoa_don;
DELIMITER $$
CREATE PROCEDURE sp_thanh_toan_hoa_don(IN p_ma_hoa_don INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
    START TRANSACTION;
    UPDATE HOA_DON SET trang_thai_thanh_toan='DA_THANH_TOAN' WHERE ma_hoa_don=p_ma_hoa_don;
    COMMIT;
END$$
DELIMITER ;

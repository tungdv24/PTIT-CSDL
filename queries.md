# TAP LENH SQL VAN HANH HE THONG QUAN LY TOA NHA

Tai lieu nay tap hop cac cau truy van SQL de **van hanh, quan sat va kiem chung** CSDL
`QuanLyToaNha` (MySQL 8.0) dang chay sau web app Flask.

- Cac cau **INSERT/UPDATE** trong muc "Nghiep vu" chinh la SQL ma web app thuc thi (trich tu `flask-app/app/views/finance.py` va `crud.py`) - chi khac o cho web app dung tham so `:ten` con o day dien gia tri truc tiep de chay tay.
- Cac muc "Quan sat" giup thay CSDL **thay doi / cap nhat / alter** nhu the nao.

## Cach ket noi de go lenh

Thay `MYSQL_PASSWORD` bang mat khau ban dat trong file `.env` (xem `flask-app/.env.example`).

**Cach 1 - MySQL CLI trong container (khuyen dung khi demo):**
```bash
docker exec -it office_mysql mysql -uroot -p"$MYSQL_PASSWORD" QuanLyToaNha
```

**Cach 2 - phpMyAdmin:** http://localhost:8080  (dang nhap bang tai khoan MySQL) → chon DB `QuanLyToaNha` → tab **SQL**.

**Cach 3 - Trang "Xem CSDL" trong app** (chi ADMIN, chi cho SELECT): http://localhost:5000/db/query

---

# PHAN A. QUAN SAT CAU TRUC CSDL (DDL / METADATA)

Day la phan quan trong cho mon CSDL: xem CSDL duoc **dinh nghia, cap nhat, alter** ra sao.

## A1. Liet ke tat ca cac bang + so dong + dung luong
```sql
SELECT
    table_name        AS ten_bang,
    table_rows        AS so_dong_uoc_tinh,
    ROUND((data_length + index_length) / 1024, 1) AS kich_thuoc_kb,
    create_time       AS ngay_tao,
    update_time       AS lan_cap_nhat_cuoi
FROM information_schema.tables
WHERE table_schema = 'QuanLyToaNha'
ORDER BY table_name;
```
> Cot `update_time` cho thay bang **vua duoc ghi/sua** luc nao - dung de chung minh du lieu thay doi.

## A2. Xem cau truc chi tiet mot bang (cot, kieu, rang buoc)
```sql
-- Cach nhanh
DESCRIBE HOA_DON;

-- Cach chi tiet (kieu, NULL, default, khoa)
SELECT column_name, column_type, is_nullable, column_key, column_default, extra
FROM information_schema.columns
WHERE table_schema = 'QuanLyToaNha' AND table_name = 'HOA_DON'
ORDER BY ordinal_position;
```

## A3. Xem lai lenh tao bang (full DDL) - de thay khoa, CHECK, GENERATED column
```sql
SHOW CREATE TABLE SU_DUNG_DICH_VU;
-- Chu y cot thanh_tien la GENERATED ALWAYS AS (so_luong * don_gia) STORED
```

## A4. Xem tat ca khoa ngoai (quan he giua cac bang)
```sql
SELECT
    table_name        AS bang_con,
    column_name       AS cot,
    referenced_table_name  AS bang_cha,
    referenced_column_name AS cot_tham_chieu,
    constraint_name
FROM information_schema.key_column_usage
WHERE table_schema = 'QuanLyToaNha'
  AND referenced_table_name IS NOT NULL
ORDER BY table_name, column_name;
```

## A5. Xem cac rang buoc CHECK (MySQL 8)
```sql
SELECT tc.table_name, cc.constraint_name, cc.check_clause
FROM information_schema.check_constraints cc
JOIN information_schema.table_constraints tc
     ON tc.constraint_name = cc.constraint_name
WHERE tc.table_schema = 'QuanLyToaNha'
ORDER BY tc.table_name;
```

## A6. Vi du ALTER TABLE (thay doi cau truc) + quan sat truoc/sau
```sql
-- TRUOC khi doi:
DESCRIBE CONG_TY;

-- Them mot cot moi:
ALTER TABLE CONG_TY ADD COLUMN website VARCHAR(150) NULL AFTER email;

-- Doi kieu / do rong mot cot:
ALTER TABLE CONG_TY MODIFY COLUMN so_dien_thoai VARCHAR(30) NOT NULL;

-- Them chi muc (index) de toi uu truy van loc theo trang_thai:
CREATE INDEX idx_congty_trangthai ON CONG_TY(trang_thai);

-- SAU khi doi - so sanh:
DESCRIBE CONG_TY;
SHOW INDEX FROM CONG_TY;

-- Hoan tac vi du (neu chi lam demo):
ALTER TABLE CONG_TY DROP COLUMN website;
DROP INDEX idx_congty_trangthai ON CONG_TY;
```

---

# PHAN B. TRUY VAN DU LIEU (SELECT) - NGHIEP VU

## B1. Danh sach cong ty kem so hop dong dang hieu luc
```sql
SELECT ct.ma_cong_ty, ct.ten_cong_ty, ct.trang_thai,
       COUNT(hd.ma_hop_dong) AS so_hop_dong_hieu_luc
FROM CONG_TY ct
LEFT JOIN HOP_DONG_THUE hd
       ON hd.ma_cong_ty = ct.ma_cong_ty AND hd.trang_thai = 'HIEU_LUC'
GROUP BY ct.ma_cong_ty, ct.ten_cong_ty, ct.trang_thai
ORDER BY so_hop_dong_hieu_luc DESC;
```

## B2. Van phong con trong / da thue (ty le lap day)
```sql
SELECT trang_thai, COUNT(*) AS so_luong,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM VAN_PHONG), 1) AS ty_le_phan_tram
FROM VAN_PHONG
GROUP BY trang_thai;
```

## B3. Chi tiet mot hop dong: cong ty thue nhung van phong nao
```sql
SELECT hdt.so_hop_dong, ct.ten_cong_ty,
       vp.ky_hieu_van_phong, vp.dien_tich, cthd.don_gia_thue_m2,
       (vp.dien_tich * cthd.don_gia_thue_m2) AS tien_thue_thang
FROM HOP_DONG_THUE hdt
JOIN CONG_TY ct           ON ct.ma_cong_ty = hdt.ma_cong_ty
JOIN CHI_TIET_HOP_DONG cthd ON cthd.ma_hop_dong = hdt.ma_hop_dong
JOIN VAN_PHONG vp         ON vp.ma_van_phong = cthd.ma_van_phong
ORDER BY hdt.so_hop_dong;
```

## B4. Liet ke hoa don mot thang (giong trang Hoa don cua app)
```sql
SELECT hd.so_hoa_don, ct.ten_cong_ty, hd.thang, hd.nam,
       hd.tien_thue_van_phong, hd.tien_dich_vu, hd.tong_tien,
       hd.trang_thai_thanh_toan
FROM HOA_DON hd
JOIN CONG_TY ct ON ct.ma_cong_ty = hd.ma_cong_ty
WHERE hd.thang = 4 AND hd.nam = 2026
ORDER BY hd.tong_tien DESC;
```

## B5. Chi tiet cac dong phi cua mot hoa don
```sql
SELECT loai_chi_phi, noi_dung, so_luong, don_gia, thanh_tien
FROM CHI_TIET_HOA_DON
WHERE ma_hoa_don = 1;
```

## B6. BAO CAO LAI/LO theo thang (chinh la cau app dung o trang Bao cao)
```sql
SET @thang = 4, @nam = 2026;

SELECT
  @thang AS thang, @nam AS nam,
  (SELECT COALESCE(SUM(tong_tien),0) FROM HOA_DON
     WHERE thang=@thang AND nam=@nam)                         AS tong_thu,
  (SELECT COALESCE(SUM(tong_luong),0) FROM LUONG_NHAN_VIEN
     WHERE thang=@thang AND nam=@nam)                         AS tong_luong,
  (SELECT COALESCE(SUM(so_tien),0) FROM CHI_PHI_TOA_NHA
     WHERE MONTH(ngay_phat_sinh)=@thang AND YEAR(ngay_phat_sinh)=@nam) AS chi_van_hanh,
  (SELECT COALESCE(SUM(tong_tien),0) FROM HOA_DON WHERE thang=@thang AND nam=@nam)
    - (SELECT COALESCE(SUM(tong_luong),0) FROM LUONG_NHAN_VIEN WHERE thang=@thang AND nam=@nam)
    - (SELECT COALESCE(SUM(so_tien),0) FROM CHI_PHI_TOA_NHA
         WHERE MONTH(ngay_phat_sinh)=@thang AND YEAR(ngay_phat_sinh)=@nam) AS loi_nhuan_rong;
```

## B7. Bao cao Lai/Lo ca nam (12 thang mot luot)
```sql
SELECT m.thang,
  COALESCE((SELECT SUM(tong_tien) FROM HOA_DON WHERE thang=m.thang AND nam=2026),0) AS tong_thu,
  COALESCE((SELECT SUM(tong_luong) FROM LUONG_NHAN_VIEN WHERE thang=m.thang AND nam=2026),0) AS luong,
  COALESCE((SELECT SUM(so_tien) FROM CHI_PHI_TOA_NHA
            WHERE MONTH(ngay_phat_sinh)=m.thang AND YEAR(ngay_phat_sinh)=2026),0) AS chi_van_hanh
FROM (SELECT 1 thang UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6
      UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 UNION SELECT 11 UNION SELECT 12) m
ORDER BY m.thang;
```

## B8. Luong nhan vien toa nha mot thang
```sql
SELECT nv.ma_so_nhan_vien, nv.ho_ten, l.luong_co_ban,
       l.doanh_thu_dich_vu, l.tien_thuong, l.tong_luong, l.trang_thai
FROM LUONG_NHAN_VIEN l
JOIN NHAN_VIEN_TOA_NHA nv ON nv.ma_nhan_vien_toa_nha = l.ma_nhan_vien_toa_nha
WHERE l.thang = 4 AND l.nam = 2026
ORDER BY l.tong_luong DESC;
```

## B9. Nhat ky su dung dich vu (an uong, gui xe) theo cong ty
```sql
SELECT ct.ten_cong_ty, nv.ho_ten, dv.ten_dich_vu,
       sd.ngay_su_dung, sd.so_luong, sd.don_gia, sd.thanh_tien
FROM SU_DUNG_DICH_VU sd
JOIN NHAN_VIEN_CONG_TY nv ON nv.ma_nhan_vien = sd.ma_nhan_vien
JOIN CONG_TY ct           ON ct.ma_cong_ty = nv.ma_cong_ty
JOIN DANG_KY_DICH_VU dk   ON dk.ma_dang_ky = sd.ma_dang_ky
JOIN DICH_VU dv           ON dv.ma_dich_vu = dk.ma_dich_vu
ORDER BY sd.ngay_su_dung DESC;
```

## B10. Cay quan ly nhan su toa nha (ai quan ly ai)
```sql
SELECT sep.ho_ten AS nhan_vien, mgr.ho_ten AS nguoi_quan_ly,
       q.ngay_bat_dau, q.ngay_ket_thuc
FROM QUAN_LY_NHAN_VIEN q
JOIN NHAN_VIEN_TOA_NHA sep ON sep.ma_nhan_vien_toa_nha = q.ma_nhan_vien
JOIN NHAN_VIEN_TOA_NHA mgr ON mgr.ma_nhan_vien_toa_nha = q.ma_nguoi_quan_ly;
```

---

# PHAN C. THAO TAC GHI DU LIEU (INSERT / UPDATE / DELETE)

Day chinh la SQL ma cac nut tren web thuc thi. Chay tay de thay CSDL **thay doi**.

## C1. Them / sua / xoa cong ty (CRUD - giong nut tren web)
```sql
-- THEM (web: nut "Them moi" o trang Cong ty)
INSERT INTO CONG_TY (ma_so_thue, ten_cong_ty, nguoi_dai_dien, so_dien_thoai, email, dia_chi, trang_thai)
VALUES ('0109999999', 'Cong ty Demo CSDL', 'Nguyen Demo', '0900000000', 'demo@csdl.vn', 'Tang 2', 'DANG_THUE');

-- Xem ban ghi vua them (lay ID moi nhat)
SELECT * FROM CONG_TY ORDER BY ma_cong_ty DESC LIMIT 1;

-- SUA (web: nut "Sua")
UPDATE CONG_TY SET so_dien_thoai = '0911223344', trang_thai = 'DANG_THUE'
WHERE ma_so_thue = '0109999999';

-- XOA (web: nut "Xoa")
DELETE FROM CONG_TY WHERE ma_so_thue = '0109999999';
```

## C2. Ghi nhan mot luot su dung dich vu (thanh_tien tu dong tinh)
```sql
INSERT INTO SU_DUNG_DICH_VU (ma_nhan_vien, ma_dang_ky, ngay_su_dung, so_luong, don_gia, ghi_chu)
VALUES (1, 2, '2026-04-10', 2, 45000, 'Suat an trua x2');

-- Khong can nhap thanh_tien: la GENERATED column. Kiem chung:
SELECT so_luong, don_gia, thanh_tien FROM SU_DUNG_DICH_VU ORDER BY ma_su_dung DESC LIMIT 1;
-- thanh_tien = 2 * 45000 = 90000 (do DB tu tinh)
```

## C3. Danh dau hoa don da thanh toan (web: nut trong chi tiet hoa don)
```sql
UPDATE HOA_DON SET trang_thai_thanh_toan = 'DA_THANH_TOAN' WHERE ma_hoa_don = 3;
```

---

# PHAN D. NGHIEP VU TU DONG (chinh xac nhu web app chay)

## D1. TAO HOA DON THANG (nut "Tao hoa don thang")

Web app lam theo cac buoc SQL sau cho **tung cong ty dang thue**. Vi du minh hoa cho cong ty `ma_cong_ty = 1`, thang 5/2026:

```sql
SET @cty = 1, @thang = 5, @nam = 2026;

-- (0) Bo qua neu da co hoa don ky nay (rang buoc UNIQUE uq_cty_thang_nam)
SELECT ma_hoa_don FROM HOA_DON WHERE ma_cong_ty=@cty AND thang=@thang AND nam=@nam;

-- (1) Tien thue mat bang = SUM(dien_tich * don_gia_thue_m2) tu hop dong hieu luc
SELECT COALESCE(SUM(vp.dien_tich * cthd.don_gia_thue_m2),0) AS tien_thue
FROM CHI_TIET_HOP_DONG cthd
JOIN HOP_DONG_THUE hdt ON hdt.ma_hop_dong = cthd.ma_hop_dong
JOIN VAN_PHONG vp      ON vp.ma_van_phong = cthd.ma_van_phong
WHERE hdt.ma_cong_ty = @cty AND hdt.trang_thai = 'HIEU_LUC';

-- (2a) Tong dien tich (cho dich vu THEO_DIEN_TICH)
SELECT COALESCE(SUM(vp.dien_tich),0) AS tong_dien_tich
FROM CHI_TIET_HOP_DONG cthd
JOIN HOP_DONG_THUE hdt ON hdt.ma_hop_dong = cthd.ma_hop_dong
JOIN VAN_PHONG vp      ON vp.ma_van_phong = cthd.ma_van_phong
WHERE hdt.ma_cong_ty = @cty AND hdt.trang_thai = 'HIEU_LUC';

-- (2b) So nhan vien dang hoat dong (cho dich vu THEO_DAU_NGUOI)
SELECT COUNT(*) AS so_nguoi FROM NHAN_VIEN_CONG_TY
WHERE ma_cong_ty = @cty AND trang_thai = 'HOAT_DONG';

-- (2c) Cac dich vu cong ty dang dung + cach tinh phi
SELECT dk.ma_dang_ky, dk.don_gia, dv.ten_dich_vu, dv.cach_tinh_phi
FROM DANG_KY_DICH_VU dk JOIN DICH_VU dv ON dv.ma_dich_vu = dk.ma_dich_vu
WHERE dk.ma_cong_ty = @cty AND dk.trang_thai = 'DANG_DUNG';

-- (2d) Voi dich vu THEO_LUOT: tong hop tu nhat ky su dung trong thang
SELECT COALESCE(SUM(so_luong),0) AS so_luong, COALESCE(SUM(thanh_tien),0) AS tien
FROM SU_DUNG_DICH_VU
WHERE ma_dang_ky = 2 AND MONTH(ngay_su_dung) = @thang AND YEAR(ngay_su_dung) = @nam;

-- (3) Tao hoa don tong (thay <...> bang ket qua tinh o tren)
INSERT INTO HOA_DON (so_hoa_don, ma_cong_ty, thang, nam,
                     tien_thue_van_phong, tien_dich_vu, tong_tien)
VALUES (CONCAT('INV-', @nam, LPAD(@thang,2,'0'), '-CT', LPAD(@cty,2,'0')),
        @cty, @thang, @nam, /*tien_thue*/ 48000000, /*tien_dv*/ 2250000, /*tong*/ 50250000);

-- (4) Them cac dong chi tiet hoa don (moi dong phi mot ban ghi)
INSERT INTO CHI_TIET_HOA_DON (ma_hoa_don, ma_chi_tiet_hop_dong, ma_dang_ky,
                              loai_chi_phi, noi_dung, so_luong, don_gia, thanh_tien)
VALUES (LAST_INSERT_ID(), 1, NULL, 'TIEN_THUE_PHONG', 'Thue phong VP-801 (150m2)', 150, 320000, 48000000);
```

Cong thuc tinh phi dich vu (theo `cach_tinh_phi`):
| cach_tinh_phi | Thanh tien |
|---------------|-----------|
| THEO_DIEN_TICH | tong_dien_tich × don_gia |
| THEO_DAU_NGUOI | so_nguoi × don_gia |
| THEO_LUOT | SUM(thanh_tien) tu SU_DUNG_DICH_VU trong thang |
| TRON_GOI | don_gia |

## D2. TINH LUONG THANG (nut "Tinh luong thang")

```sql
SET @thang = 4, @nam = 2026;

-- (1) Lay phan cong trong thang -> vi tri (luong co ban, ty le) + dich vu phu trach
SELECT pc.ma_nhan_vien_toa_nha, pc.ma_dich_vu, vt.luong_co_ban, vt.ty_le_doanh_thu
FROM PHAN_CONG_CONG_VIEC pc
JOIN VI_TRI_CONG_VIEC vt ON vt.ma_vi_tri = pc.ma_vi_tri
WHERE pc.thang = @thang AND pc.nam = @nam;

-- (2) Doanh thu cua dich vu duoc phan cong trong thang (tu chi tiet hoa don)
SELECT COALESCE(SUM(ct.thanh_tien),0) AS doanh_thu
FROM CHI_TIET_HOA_DON ct
JOIN HOA_DON hd         ON hd.ma_hoa_don = ct.ma_hoa_don
JOIN DANG_KY_DICH_VU dk ON dk.ma_dang_ky = ct.ma_dang_ky
WHERE dk.ma_dich_vu = 1 AND hd.thang = @thang AND hd.nam = @nam;

-- (3) Ghi bang luong: tong_luong = luong_co_ban + doanh_thu * ty_le/100
INSERT INTO LUONG_NHAN_VIEN (ma_nhan_vien_toa_nha, thang, nam,
       luong_co_ban, doanh_thu_dich_vu, tien_thuong, tong_luong)
VALUES (2, @thang, @nam, 12000000, 5250000, 5250000 * 3.00 / 100, 12000000 + 5250000 * 3.00 / 100);
```

---

# PHAN E. QUAN SAT CSDL "THAY DOI" NHU THE NAO (danh cho demo mon CSDL)

## E1. Truoc/sau mot thao tac - dem ban ghi
```sql
SELECT COUNT(*) FROM HOA_DON;          -- truoc
-- ... chay nut "Tao hoa don thang" tren web hoac D1 ...
SELECT COUNT(*) FROM HOA_DON;          -- sau -> so tang len
```

## E2. Xem lan cap nhat cuoi cua tung bang (metadata)
```sql
SELECT table_name, table_rows, update_time
FROM information_schema.tables
WHERE table_schema = 'QuanLyToaNha'
ORDER BY update_time DESC;
```

## E3. Chung minh TRANSACTION (ACID) - rollback khong lam thay doi du lieu
```sql
START TRANSACTION;
UPDATE VAN_PHONG SET trang_thai = 'BAO_TRI' WHERE ma_van_phong = 2;
SELECT ma_van_phong, trang_thai FROM VAN_PHONG WHERE ma_van_phong = 2;  -- thay doi trong phien
ROLLBACK;
SELECT ma_van_phong, trang_thai FROM VAN_PHONG WHERE ma_van_phong = 2;  -- tro ve nhu cu
```

## E4. Chung minh rang buoc UNIQUE (khong tao 2 hoa don cung ky)
```sql
-- Chay 2 lan cau nay -> lan 2 bao loi "Duplicate entry ... for key 'uq_cty_thang_nam'"
INSERT INTO HOA_DON (so_hoa_don, ma_cong_ty, thang, nam, tong_tien)
VALUES ('INV-TEST-DUP', 1, 4, 2026, 1000000);
```

## E5. Chung minh khoa ngoai (FK) chan xoa du lieu dang duoc tham chieu
```sql
-- CONG_TY dang co hop dong -> xoa se bi chan (hoac cascade tuy cau hinh)
DELETE FROM CONG_TY WHERE ma_cong_ty = 1;
-- Bao loi: Cannot delete or update a parent row: a foreign key constraint fails
```

## E6. Chung minh CHECK constraint (MySQL 8 enforce)
```sql
-- Vi pham CHECK (dien_tich > 0) -> bao loi
INSERT INTO VAN_PHONG (ky_hieu_van_phong, tang, dien_tich, don_gia_m2)
VALUES ('VP-TEST', 1, -5, 100000);
```

## E7. Bat log truy van de xem MOI cau lenh app gui xuong DB (nang cao)
```sql
-- Bat (chi dung khi demo, tat sau khi xong vi ghi nhieu):
SET GLOBAL general_log = 'ON';
SET GLOBAL log_output = 'TABLE';

-- Thao tac tren web (dang nhap, tao hoa don...), roi xem 20 lenh gan nhat:
SELECT event_time, command_type, LEFT(argument, 200) AS cau_lenh
FROM mysql.general_log
WHERE argument LIKE '%QuanLyToaNha%' OR command_type = 'Query'
ORDER BY event_time DESC LIMIT 20;

-- Tat lai:
SET GLOBAL general_log = 'OFF';
```
> E7 la cach truc quan nhat de **nhin thay web app cap nhat CSDL**: moi lan bam nut tren web,
> cau INSERT/UPDATE tuong ung se hien trong `mysql.general_log`.

---

# PHAN F. LENH TIEN ICH NHANH (shell)

```bash
# Dem so bang
docker exec office_mysql mysql -uroot -p"$MYSQL_PASSWORD" -N -e \
  "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='QuanLyToaNha';"

# Sao luu (backup) toan bo CSDL ra file
docker exec office_mysql mysqldump -uroot -p"$MYSQL_PASSWORD" QuanLyToaNha > backup_$(date +%F).sql

# Phuc hoi tu file backup
docker exec -i office_mysql mysql -uroot -p"$MYSQL_PASSWORD" QuanLyToaNha < backup_2026-09-09.sql
```


---

# PHAN G. TRIGGER & TRANSACTION (STORED PROCEDURE)

Toan bo logic nghiep vu (tinh hoa don, tinh luong...) da duoc chuyen tu tang ung dung
(Python) **xuong CSDL** duoi dang **trigger** va **stored procedure**. App chi con goi `CALL`.
Cac lenh nay dat trong file `flask-app/sql/procedures.sql` va tu dong nap khi khoi dong app.

Xem nhanh danh sach da cai:
```sql
-- Danh sach trigger
SELECT TRIGGER_NAME, ACTION_TIMING, EVENT_MANIPULATION, EVENT_OBJECT_TABLE
FROM information_schema.TRIGGERS WHERE TRIGGER_SCHEMA='QuanLyToaNha';

-- Danh sach stored procedure
SELECT ROUTINE_NAME, ROUTINE_TYPE FROM information_schema.ROUTINES
WHERE ROUTINE_SCHEMA='QuanLyToaNha' AND ROUTINE_TYPE='PROCEDURE';

-- Xem lai code mot trigger / procedure
SHOW CREATE TRIGGER trg_cthd_after_insert;
SHOW CREATE PROCEDURE sp_tao_hoa_don_thang;
```

## G.1. DANH SACH TRIGGER (6)

| Trigger | Chay khi | Tac dung |
|---------|----------|----------|
| `trg_cthd_after_insert` | AFTER INSERT tren `CHI_TIET_HOP_DONG` | Them van phong vao hop dong -> van phong chuyen `DA_THUE` |
| `trg_cthd_after_delete` | AFTER DELETE tren `CHI_TIET_HOP_DONG` | Xoa chi tiet hop dong -> van phong tra ve `TRONG` |
| `trg_cthd_no_change_vp` | BEFORE UPDATE tren `CHI_TIET_HOP_DONG` | Chan doi `ma_van_phong` cua chi tiet hop dong da tao (bao loi) |
| `trg_quanly_no_self` | BEFORE INSERT tren `QUAN_LY_NHAN_VIEN` | Chan nhan vien tu quan ly chinh minh |
| `trg_sudung_check_company` | BEFORE INSERT tren `SU_DUNG_DICH_VU` | Chan neu nhan vien khong thuoc cong ty da dang ky dich vu |
| `trg_hoadon_before_insert` | BEFORE INSERT tren `HOA_DON` | Tu tinh `tong_tien = tien_thue + tien_dich_vu` |
| `trg_hoadon_before_update` | BEFORE UPDATE tren `HOA_DON` | Tinh lai `tong_tien` khi cap nhat |

**Y nghia:** trigger giup CSDL tu bao ve tinh toan ven — tu cap nhat trang thai van phong,
tu tinh tong tien, va tu chan du lieu sai (khong phu thuoc tang ung dung).

### Ma nguon trigger

```sql
-- 1) Them van phong vao hop dong -> DA_THUE
CREATE TRIGGER trg_cthd_after_insert
AFTER INSERT ON CHI_TIET_HOP_DONG
FOR EACH ROW
    UPDATE VAN_PHONG SET trang_thai = 'DA_THUE'
    WHERE ma_van_phong = NEW.ma_van_phong;

-- 2) Xoa chi tiet hop dong -> TRONG
CREATE TRIGGER trg_cthd_after_delete
AFTER DELETE ON CHI_TIET_HOP_DONG
FOR EACH ROW
    UPDATE VAN_PHONG SET trang_thai = 'TRONG'
    WHERE ma_van_phong = OLD.ma_van_phong;

-- 2b) Khong cho doi van phong cua chi tiet hop dong da tao
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

-- 3) Chan tu quan ly chinh minh
DELIMITER $$
CREATE TRIGGER trg_quanly_no_self
BEFORE INSERT ON QUAN_LY_NHAN_VIEN
FOR EACH ROW
BEGIN
    IF NEW.ma_nhan_vien = NEW.ma_nguoi_quan_ly THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nhan vien khong the tu quan ly chinh minh';
    END IF;
END$$
DELIMITER ;

-- 4) Nhan vien dung dich vu phai dung cong ty da dang ky
DELIMITER $$
CREATE TRIGGER trg_sudung_check_company
BEFORE INSERT ON SU_DUNG_DICH_VU
FOR EACH ROW
BEGIN
    DECLARE v_cty_nv INT; DECLARE v_cty_dk INT;
    SELECT ma_cong_ty INTO v_cty_nv FROM NHAN_VIEN_CONG_TY WHERE ma_nhan_vien = NEW.ma_nhan_vien;
    SELECT ma_cong_ty INTO v_cty_dk FROM DANG_KY_DICH_VU WHERE ma_dang_ky = NEW.ma_dang_ky;
    IF v_cty_nv IS NULL OR v_cty_dk IS NULL OR v_cty_nv <> v_cty_dk THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nhan vien khong thuoc cong ty da dang ky dich vu nay';
    END IF;
END$$
DELIMITER ;

-- 5) & 6) Tu tinh tong_tien cho hoa don
CREATE TRIGGER trg_hoadon_before_insert
BEFORE INSERT ON HOA_DON
FOR EACH ROW
    SET NEW.tong_tien = COALESCE(NEW.tien_thue_van_phong,0) + COALESCE(NEW.tien_dich_vu,0);

CREATE TRIGGER trg_hoadon_before_update
BEFORE UPDATE ON HOA_DON
FOR EACH ROW
    SET NEW.tong_tien = COALESCE(NEW.tien_thue_van_phong,0) + COALESCE(NEW.tien_dich_vu,0);
```

### Cach kiem chung trigger (demo)

```sql
-- Trigger 1: them chi tiet hop dong -> van phong DA_THUE
SELECT trang_thai FROM VAN_PHONG WHERE ma_van_phong = 2;   -- truoc
INSERT INTO CHI_TIET_HOP_DONG (ma_hop_dong, ma_van_phong, don_gia_thue_m2, ngay_bat_dau, ngay_ket_thuc)
VALUES (1, 2, 280000, '2026-05-01', '2026-12-31');
SELECT trang_thai FROM VAN_PHONG WHERE ma_van_phong = 2;   -- sau -> DA_THUE

-- Trigger 2b: doi van phong cua chi tiet hop dong -> bao loi
UPDATE CHI_TIET_HOP_DONG SET ma_van_phong = 2 WHERE ma_chi_tiet = 1;   -- ERROR 1644: Khong the doi van phong...
-- (sua truong khac van OK)
UPDATE CHI_TIET_HOP_DONG SET don_gia_thue_m2 = 330000 WHERE ma_chi_tiet = 1;   -- OK

-- Trigger 3: tu quan ly -> bao loi
INSERT INTO QUAN_LY_NHAN_VIEN (ma_nhan_vien, ma_nguoi_quan_ly, ngay_bat_dau)
VALUES (1, 1, '2026-01-01');   -- ERROR 1644: Nhan vien khong the tu quan ly chinh minh

-- Trigger 4: nv cong ty 2 dung dich vu cong ty 1 -> bao loi
INSERT INTO SU_DUNG_DICH_VU (ma_nhan_vien, ma_dang_ky, ngay_su_dung, so_luong, don_gia)
VALUES (3, 2, '2026-05-01', 1, 45000);   -- ERROR 1644: khong thuoc cong ty da dang ky

-- Trigger 5: tong_tien tu tinh
INSERT INTO HOA_DON (so_hoa_don, ma_cong_ty, thang, nam, tien_thue_van_phong, tien_dich_vu)
VALUES ('INV-TEST', 1, 5, 2026, 10000000, 500000);
SELECT tong_tien FROM HOA_DON WHERE so_hoa_don='INV-TEST';   -- 10.500.000 (tu tinh)
```

## G.2. DANH SACH STORED PROCEDURE / TRANSACTION (6)

Moi procedure la mot **giao dich (transaction)**: cac lenh ben trong `START TRANSACTION ... COMMIT`,
co `EXIT HANDLER FOR SQLEXCEPTION ... ROLLBACK` -> loi giua chung se **huy toan bo** (tinh nguyen tu/ACID).

| Procedure | Tham so | Tac dung |
|-----------|---------|----------|
| `sp_tao_hoa_don_thang` | (ma_cong_ty, thang, nam, OUT ma_hoa_don) | Tao hoa don 1 cong ty: header + chi tiet (thue + dich vu) trong 1 giao dich |
| `sp_tao_hoa_don_tat_ca` | (thang, nam, OUT so_tao) | Lap qua moi cong ty dang thue, goi `sp_tao_hoa_don_thang` |
| `sp_tinh_luong_thang` | (thang, nam, OUT so_tao) | Tinh luong moi nhan vien co phan cong: luong CB + thuong % doanh thu |
| `sp_ghi_su_dung_dich_vu` | (ma_nhan_vien, ma_dang_ky, ngay, so_luong, don_gia, ghi_chu, OUT ma_su_dung) | Ghi 1 luot dung dich vu |
| `sp_thanh_ly_hop_dong` | (ma_hop_dong) | Doi hop dong `DA_THANH_LY` + tra cac van phong ve `TRONG` |
| `sp_thanh_toan_hoa_don` | (ma_hoa_don) | Danh dau hoa don `DA_THANH_TOAN` |

**App goi cac procedure nay:**
- Tao hoa don thang (nut tren web) -> `CALL sp_tao_hoa_don_tat_ca(...)`
- Tinh luong thang -> `CALL sp_tinh_luong_thang(...)`
- Ghi su dung dich vu -> `CALL sp_ghi_su_dung_dich_vu(...)`
- Thanh toan hoa don -> `CALL sp_thanh_toan_hoa_don(...)`

### Vi du goi (CALL) tren MySQL

```sql
-- Tao hoa don thang 4/2026 cho MOT cong ty (ma_cong_ty=1)
CALL sp_tao_hoa_don_thang(1, 4, 2026, @ma_hd);
SELECT @ma_hd AS ma_hoa_don_vua_tao;

-- Tao hoa don thang 4/2026 cho TAT CA cong ty dang thue
CALL sp_tao_hoa_don_tat_ca(4, 2026, @so_tao);
SELECT @so_tao AS so_hoa_don_da_tao;

-- Tinh luong thang 4/2026
CALL sp_tinh_luong_thang(4, 2026, @so_bang_luong);
SELECT @so_bang_luong AS so_bang_luong_da_tinh;

-- Ghi mot luot su dung dich vu (nhan vien 1, dang ky 2 = an trua)
CALL sp_ghi_su_dung_dich_vu(1, 2, '2026-04-20', 1, 45000, 'Suat an trua', @ma_sd);
SELECT @ma_sd AS ma_su_dung;

-- Thanh ly hop dong so 4 (tra van phong ve TRONG)
CALL sp_thanh_ly_hop_dong(4);

-- Thanh toan hoa don
CALL sp_thanh_toan_hoa_don(1);
```

### Vi du ma nguon mot procedure (rut gon) — minh hoa transaction

```sql
CREATE PROCEDURE sp_thanh_ly_hop_dong(IN p_ma_hop_dong INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;  -- loi -> ROLLBACK
    START TRANSACTION;
        UPDATE HOP_DONG_THUE SET trang_thai='DA_THANH_LY' WHERE ma_hop_dong=p_ma_hop_dong;
        UPDATE VAN_PHONG SET trang_thai='TRONG'
        WHERE ma_van_phong IN (SELECT ma_van_phong FROM CHI_TIET_HOP_DONG WHERE ma_hop_dong=p_ma_hop_dong);
    COMMIT;   -- ca 2 UPDATE cung thanh cong hoac cung bi huy
END;
```

> Code day du cua tat ca trigger + procedure: xem file `flask-app/sql/procedures.sql`.

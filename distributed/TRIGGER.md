# TRIGGER RANG BUOC NGHIEP VU - BAN PHAN TAN

He phan tan dung **5 rang buoc nghiep vu** cai bang trigger, nap tren **ca 3 node** (HN/DN/HCM).
File ma nguon: `distributed/sql/triggers.sql`. Ban phan tan **khong dung stored procedure**.

> Cac trigger ve van phong kiem tra truc tiep qua `CHI_TIET_HOP_DONG` + `HOP_DONG_THUE`
> (trang_thai = HIEU_LUC), khong phu thuoc cot `VAN_PHONG.trang_thai`.

## Danh sach trigger

| # | Trigger | Chay khi | Tac dung |
|---|---------|----------|----------|
| 1 | `trg_vanphong_before_delete` | BEFORE DELETE `VAN_PHONG` | Chan xoa van phong dang co hop dong thue **hieu luc** |
| 2 | `trg_cthd_no_overlap` | BEFORE INSERT `CHI_TIET_HOP_DONG` | Chan 2 hop dong thue **chung 1 van phong** khi thoi gian **chong lan** |
| 3 | `trg_vanphong_no_edit_when_used` | BEFORE UPDATE `VAN_PHONG` | Chan sua cot nghiep vu (ky_hieu, tang, dien_tich, don_gia_m2) khi VP dang duoc thue; van cho doi `trang_thai` |
| 4 | `trg_sudung_check_company` | BEFORE INSERT `SU_DUNG_DICH_VU` | NVCT **chi dung dich vu cong ty minh** da dang ky |
| 5 | `trg_hopdong_check_ngay_insert` / `_update` | BEFORE INSERT/UPDATE `HOP_DONG_THUE` | Kiem tra ngay hop dong: `ngay_ket_thuc >= ngay_bat_dau` |
| 6 | `trg_quanly_no_self` | BEFORE INSERT `QUAN_LY_NHAN_VIEN` | Nhan vien toa nha **khong the tu quan ly chinh minh** |

## Cach demo (chay tren mot node bat ky, vd dist_danang)

```sql
-- T1: xoa van phong dang thue -> loi
DELETE FROM VAN_PHONG WHERE ma_van_phong = 3;
-- ERROR 1644: Khong the xoa van phong dang co hop dong thue hieu luc

-- T2: them chi tiet hop dong trung van phong (chong lan thoi gian) -> loi
INSERT INTO CHI_TIET_HOP_DONG (ma_hop_dong, ma_van_phong, don_gia_thue_m2, ngay_bat_dau, ngay_ket_thuc)
VALUES (2, 3, 260000, '2026-06-01', '2026-09-01');
-- ERROR 1644: Van phong da duoc thue trong khoang thoi gian nay (trung hop dong)

-- T3: sua don gia van phong dang thue -> loi (nhung doi trang_thai thi OK)
UPDATE VAN_PHONG SET don_gia_m2 = 999999 WHERE ma_van_phong = 3;
-- ERROR 1644: Khong the sua thong tin van phong dang duoc thue
UPDATE VAN_PHONG SET trang_thai = 'DA_THUE' WHERE ma_van_phong = 3;   -- OK

-- T4: NVCT dung dich vu cong ty khac -> loi
INSERT INTO SU_DUNG_DICH_VU (ma_nhan_vien, ma_dang_ky, ngay_su_dung, so_luong, don_gia)
VALUES (3, 6, '2026-04-10', 1, 45000);
-- ERROR 1644: Nhan vien khong thuoc cong ty da dang ky dich vu nay

-- T5: hop dong ngay ket thuc < ngay bat dau -> loi
INSERT INTO HOP_DONG_THUE (so_hop_dong, ma_cong_ty, ngay_bat_dau, ngay_ket_thuc)
VALUES ('HD-TEST', 2, '2026-12-31', '2026-01-01');
-- ERROR 1644: Ngay ket thuc hop dong phai >= ngay bat dau
```

## Xem danh sach trigger tren mot node
```sql
SELECT TRIGGER_NAME, ACTION_TIMING, EVENT_MANIPULATION, EVENT_OBJECT_TABLE
FROM information_schema.TRIGGERS WHERE TRIGGER_SCHEMA='QuanLyToaNha';
```

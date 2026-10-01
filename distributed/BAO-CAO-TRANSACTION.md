# BÁO CÁO: TRANSACTION CHỐNG TRÙNG MÃ (HỆ PHÂN TÁN)

Hệ thống quản lý tòa nhà phân tán 3 node (HN / DN / HCM). Tài liệu này mô tả 3
tình huống trùng mã, cơ chế transaction/ràng buộc xử lý, và kết quả kiểm thử thực tế.

## 1. Ba tình huống cần xử lý

| # | Tình huống | Phạm vi | Cơ chế bảo vệ |
|---|-----------|---------|---------------|
| 1 | Hai nhân viên tòa nhà cùng `ma_so_nhan_vien` (BQL-xxx) | Cùng node **và** khác node | UNIQUE cục bộ + khóa phân tán + kiểm tra chéo 3 node |
| 2 | Hai nhân viên công ty cùng `ma_so_nhan_vien` (NVCT-xxxx) | Cùng node **và** khác node | UNIQUE cục bộ + khóa phân tán + kiểm tra chéo 3 node |
| 3 | Hai chi nhánh thêm công ty cùng `ma_so_cong_ty` (CT-xx) | **Khác node** | Khóa phân tán + kiểm tra chéo 3 node |

> Cả 3 loại mã (CT-, BQL-, NVCT-) đều phải **duy nhất trên toàn hệ thống**. Vì
> dữ liệu được phân mảnh theo chi nhánh (mỗi node chỉ chứa dữ liệu của mình),
> UNIQUE cục bộ chỉ chặn trùng trong cùng node; để chặn trùng **giữa các node**
> cần khóa phân tán + kiểm tra chéo 3 node (xem mục 2.2).

## 2. Cơ chế kỹ thuật

### 2.1. Ràng buộc UNIQUE cục bộ (ca 1 & 2)
Mỗi node đã có ràng buộc `UNIQUE` trên cột mã:
- `NHAN_VIEN_TOA_NHA.ma_so_nhan_vien`
- `NHAN_VIEN_CONG_TY.ma_so_nhan_vien`

Vì nhân viên được **phân mảnh theo khu vực** (mỗi node chỉ chứa dữ liệu của chi
nhánh đó), nên UNIQUE cục bộ là đủ. Khi INSERT trùng, MySQL trả lỗi 1062
(Duplicate entry). Ứng dụng bọc INSERT trong **transaction tường minh**
(`db.tx()`), nếu lỗi thì **ROLLBACK** toàn bộ (kể cả bước phụ như tự gán quản lý
cho nhân viên tòa nhà), và hiển thị thông báo tiếng Việt rõ ràng.

```python
with db.tx() as t:                         # BEGIN
    t.execute("INSERT INTO ... VALUES ...") # trùng -> 1062
    _auto_gan_quan_ly(new_id, data, t)      # chạy cùng transaction
# COMMIT nếu không lỗi, ROLLBACK nếu có lỗi
```

### 2.2. Khóa phân tán + kiểm tra chéo node (ca 3)
`ma_so_cong_ty` phải **duy nhất trên toàn hệ thống**, nhưng UNIQUE cục bộ ở mỗi
node KHÔNG phát hiện được khi 2 chi nhánh (2 node khác nhau) cùng dùng một mã.
Nếu chỉ "kiểm tra rồi insert" thì vẫn dính **race condition** (TOCTOU) khi 2 chi
nhánh thêm cùng lúc.

Giải pháp: dùng **named lock cấp server MySQL** (`GET_LOCK`/`RELEASE_LOCK`) đặt
tại node HN (trụ sở chính) làm điểm đồng bộ chung cho cả cụm:

```python
with db.global_lock("them_CONG_TY"):       # chỉ 1 request được vào tại 1 thời điểm
    for kv in NODES:                        # kiểm tra chéo cả 3 node
        if exists(ma_so_cong_ty, node=kv):
            raise DuplicateError(...)
    with db.tx(target_node) as t:           # qua kiểm tra -> insert trong transaction
        t.execute("INSERT INTO CONG_TY ...")
# RELEASE_LOCK
```

Khóa đảm bảo thao tác **kiểm-tra-rồi-ghi** là nguyên tử trên toàn hệ thống: 2
chi nhánh thêm cùng lúc sẽ bị xếp hàng, người sau thấy mã đã tồn tại và bị chặn.

## 3. Kết quả kiểm thử (thực tế trên server)

| # | Kịch bản | Kỳ vọng | Kết quả |
|---|----------|---------|---------|
| 1 | Thêm NV tòa nhà `BQL-001` (đã có ở HN), cùng node HN | Bị chặn | ✅ Báo trùng mã — HN vẫn 5 NV |
| 2 | Thêm NV công ty `NVCT-0001` (đã có ở HN), cùng node HN | Bị chặn | ✅ Báo trùng mã — HN vẫn 20 NVCT |
| 3 | Thêm công ty `CT-05` vào HN (đã có ở **DN**) | Bị chặn (cross-node) | ✅ "Mã 'CT-05' đã tồn tại ở chi nhánh DN..." — HN vẫn 0 |
| 4 | **Login DN**, thêm `NVCT-0001` (đã có ở **HN**) | Bị chặn (cross-node) | ✅ "...đã tồn tại ở chi nhánh HN. Mã của Nhân viên công ty phải duy nhất..." — DN vẫn 0 |
| 5 | **Login DN**, thêm `BQL-001` (đã có ở **HN**) | Bị chặn (cross-node) | ✅ "...đã tồn tại ở chi nhánh HN. Mã của Nhân viên tòa nhà phải duy nhất..." — DN vẫn 0 |
| 6 | Thêm NV công ty `NVCT-9999` (mã mới) | Thành công | ✅ Thêm được |
| 7 | Thêm công ty `CT-99` vào HN (mã mới) | Thành công | ✅ Thêm được |
| 8 | Login DN, thêm NV tòa nhà `BQL-777` (mã mới) | Thành công + tự gán quản lý | ✅ Tạo được, quan hệ quản lý tạo trong cùng transaction |

> Ca 3-4-5 là điểm mấu chốt của hệ phân tán: UNIQUE cục bộ ở node đích không
> chặn được (vì node đó chưa có mã), chính **khóa phân tán + kiểm tra chéo node**
> mới bắt được. Ca 8 chứng minh `after_create` (tự gán quản lý) chạy trong cùng
> transaction nên vẫn nguyên tử.

## 4. Kết luận
- Ca 1, 2: ràng buộc UNIQUE + transaction đảm bảo không trùng mã trong một chi nhánh.
- Ca 3: khóa phân tán (`GET_LOCK` tại HN) + kiểm tra chéo 3 node đảm bảo mã công
  ty duy nhất toàn hệ thống, chống cả race condition khi 2 chi nhánh thao tác đồng thời.
- Mọi lỗi trùng mã được dịch sang thông báo tiếng Việt thân thiện trên giao diện.


---

# PHẦN 2: STORED PROCEDURE (TRANSACTION TRONG SQL)

Ngoài các transaction ở tầng ứng dụng (phần 1), hệ thống còn có 5 stored
procedure viết bằng **MySQL** đặt trong `distributed/sql/05_procedures.sql`,
nạp trên **cả 3 node** (HN/DN/HCM). Đây là các **giao dịch cục bộ** (local
transaction) — mỗi procedure chỉ thao tác dữ liệu của chi nhánh đang đăng nhập,
không đọc/ghi chéo node, nên an toàn cho hệ phân tán (không cần two-phase commit).

Mỗi procedure dùng transaction tường minh: `START TRANSACTION; ...; COMMIT;` kèm
`DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;` — bất kỳ
lỗi nào (kể cả do trigger `SIGNAL`) đều cuộn lại toàn bộ và báo lỗi ra ngoài.

## Danh sách procedure

| # | Procedure | Chức năng | Điểm kỹ thuật |
|---|-----------|-----------|---------------|
| TX1 | `sp_ThayDoiNguoiQuanLy(nv, ql_moi, ngay)` | Đổi người quản lý của NV tòa nhà, lưu lịch sử | Đóng quan hệ cũ (`ngay_ket_thuc`) + mở quan hệ mới trong 1 transaction; tương thích trigger `trg_quanly_no_self` |
| TX2 | `sp_ThueVanPhong(hd, vp, don_gia, tu, den)` | Thêm văn phòng vào hợp đồng | Trigger `trg_cthd_no_overlap` tự chặn thuê trùng thời gian |
| TX3 | `sp_TinhTienDichVuBacThang(cty, don_gia, ngay_dung, ngay_thang, OUT tien)` | Tính tiền dịch vụ bậc thang theo quy mô công ty | Lấy số NV + diện tích thuê thực tế; +5% mỗi mốc; trả qua tham số `OUT` |
| TX4 | `sp_ChotLuongThang(thang, nam)` | Chốt lương NV tòa nhà theo vị trí + hoa hồng dịch vụ | Dùng `CURSOR` duyệt NV; `INSERT ... ON DUPLICATE KEY UPDATE` để chạy lại an toàn |
| TX5 | `sp_ChotHoaDonThang(cty, thang, nam)` | Chốt hóa đơn tháng cho công ty | Tự sinh `so_hoa_don`; kiểm tra chống tạo trùng tháng |

## Quan hệ TX3 ↔ TX5 (phí dịch vụ)
Phí dịch vụ chia 2 loại theo `DICH_VU.cach_tinh_phi`:
- **Cố định** (THEO_DIEN_TICH / THEO_DAU_NGUOI / TRON_GOI): tính theo quy mô công
  ty, áp **hệ số bậc thang** (+5% mỗi 5 NV vượt 10; +5% mỗi 10 m² vượt 100).
- **Theo lượt** (THEO_LUOT, vd ăn uống/gửi xe): tính theo `SU_DUNG_DICH_VU`.

Để không trùng/rời rạc logic, tách hàm dùng chung `fn_he_so_bac_thang(ma_cong_ty)`:
- **TX3** dùng hàm này để *ước tính* 1 dịch vụ cố định (trả OUT, không ghi DB).
- **TX5** dùng cùng hàm để tính phí cố định, rồi **cộng** với phí theo lượt vào
  `tien_dich_vu` của hóa đơn. Nhờ vậy hóa đơn gồm đủ: tiền thuê + DV cố định + DV theo lượt.

Ví dụ CT-01 (diện tích 200 m² → hệ số 1.5): DV cố định đăng ký 2.025.000 ×
1.5 = 3.037.500; tiền thuê 50.000.000 → tổng hóa đơn 53.037.500.

## Khác biệt so với bản Oracle (đề xuất ban đầu)
Đề xuất ban đầu viết bằng **Oracle PL/SQL** nên không chạy trên MySQL. Đã chuyển đổi:
- `CREATE OR REPLACE PROCEDURE ... IS/AS` → `CREATE PROCEDURE ... BEGIN` + `DELIMITER $$`
- `IN/OUT NUMBER` → `IN/OUT INT/DECIMAL`; `NVL` → `IFNULL`; `TRUNC` → `FLOOR`
- `EXTRACT(MONTH FROM ..)` → `MONTH()`; `SYSTIMESTAMP` → mặc định cột; bỏ `DBMS_OUTPUT`
- Bỏ tự cấp khóa `MAX(..)+1` (các bảng đã `AUTO_INCREMENT`)
- Sửa tham chiếu cột không tồn tại: `CONG_TY.so_luong_nhan_vien/tong_dien_tich`
  → tính từ `COUNT(NVCT)` và `SUM(VAN_PHONG.dien_tich)`; `ma_dich_vu_phu_trach`
  → dùng bảng `PHAN_CONG_CONG_VIEC`
- TX4 ghi kết quả vào `LUONG_NHAN_VIEN` (thay vì chỉ in ra màn hình)

## Kết quả kiểm thử (thực tế trên node HN)

| TX | Kịch bản | Kết quả |
|----|----------|---------|
| TX5 | Chốt hóa đơn CT-01 tháng 10 (mới) | ✅ Tạo `INV-202610-CT01`, tiền thuê 50.000.000 |
| TX5 | Chốt lại cùng tháng | ✅ Lỗi "Hoa don...da ton tai" + **ROLLBACK** (không nhân đôi) |
| TX1 | Đổi QL của NV id=1 sang id=2 | ✅ Quan hệ cũ đóng ngày 30/09, quan hệ mới mở 01/10 |
| TX1 | NV id=3 tự quản lý chính mình | ✅ Trigger chặn + **ROLLBACK** (quan hệ cũ còn nguyên — chứng minh tính nguyên tử) |
| TX2 | Thuê VP-07 cho HĐ-01 | ✅ Thêm được |
| TX2 | Thuê lại VP-07 trùng thời gian | ✅ Trigger `trg_cthd_no_overlap` chặn + **ROLLBACK** |
| TX3 | CT-01 (5 NV, 200 m²), đơn giá gốc 1.000.000 | ✅ = 1.000.000 × (1 + 50%) = **1.500.000** (diện tích 200 > 100 → +50%) |
| TX4 | Chốt lương tháng 11 | ✅ Ghi `LUONG_NHAN_VIEN` đúng lương theo vị trí (QL 20tr, Trưởng ca 12tr...) |

## Cách gọi
```sql
CALL sp_ChotHoaDonThang(1, 10, 2026);
CALL sp_ThayDoiNguoiQuanLy(1, 2, '2026-10-01');
CALL sp_ThueVanPhong(1, 7, 300000, '2026-10-01', '2026-12-31');
CALL sp_TinhTienDichVuBacThang(1, 1000000, 30, 30, @tien); SELECT @tien;
CALL sp_ChotLuongThang(11, 2026);
```

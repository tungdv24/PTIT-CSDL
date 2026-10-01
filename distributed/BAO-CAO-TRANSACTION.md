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

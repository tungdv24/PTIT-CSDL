# NHUNG PHAN CAN BO SUNG VAO FILE DOCX (Bao cao Nhom 7)

So sanh **file docx hien tai** voi **he thong CSDL da xay dung/deploy thuc te**.
File nay liet ke phan con THIEU va phan can CHINH cho khop voi san pham.

> Tom tat: Phan **thiet ke khai niem/logic** trong docx da tot va khop voi CSDL thuc te
> (17 thuc the, quan he, thuoc tinh). Nhung docx **dung o giua** (nhieu muc chi co tieu de,
> chua co noi dung) va **chua nhac gi den ban CSDL phan tan** — la phan lam nhieu nhat.

---

## A. CAC MUC TRONG DOCX MOI CHI CO TIEU DE - CAN VIET NOI DUNG

Cac muc sau trong docx hien **de trong** (chi co heading), can bo sung:

1. **Anh xa ERD sang luoc do quan he** — liet ke 18 bang dang `TEN_BANG(cot1, cot2, ...)`.
2. **Xac dinh PK, FK, UK** — bang liet ke khoa chinh / khoa ngoai / khoa duy nhat cho tung bang.
3. **Xac dinh phu thuoc ham** (FD) cho tung bang.
4. **Chuan hoa 1NF → 2NF → 3NF → BCNF** — chung minh dat 3NF/BCNF.
5. **Rang buoc nghiep vu** — liet ke cac rule (mot van phong 1 thoi diem 1 cong ty; NVCT chi dung DV cong ty da dang ky; khong tu quan ly minh...).
6. **Thiet ke Trigger** — hien da co **5 trigger thuc te** o ban phan tan (xem muc C).
7. **Thiet ke truy van/bao cao** — cac cau SELECT bao cao (co san trong `queries.md`, `distributed/TRIGGER.md`).
8. **Script SQL + du lieu mau** — da co file that (xem muc E).

---

## B. CHINH LAI PHAN THUOC TINH CHO KHOP CSDL THUC TE

Docx liet ke thuoc tinh tung thuc the, nhung thieu vai cot so voi DB da trien khai:

| Bang | Docx thieu cot | Ghi chu |
|------|----------------|---------|
| `CONG_TY` | `ma_so_cong_ty`, `khu_vuc`, `trang_thai`, `created_at` | `ma_so_cong_ty` (vd CT-01) dung de dang nhap; `khu_vuc` phuc vu phan tan |
| `VAN_PHONG` | `khu_vuc`, `trang_thai` | `khu_vuc` phuc vu phan tan |
| `LUONG_NHAN_VIEN` | `trang_thai`, `ngay_chot` | trang_thai: CHUA_CHI / DA_CHI |
| `NHAN_VIEN_TOA_NHA` | `khu_vuc` | phuc vu phan tan (moi chi nhanh co doi rieng) |
| `SU_DUNG_DICH_VU` | `thanh_tien` la **cot sinh (GENERATED)** = so_luong * don_gia | nen ghi ro trong bao cao |

> Ngoai ra co **1 bang khong nam trong 17 thuc the goc**: `NGUOI_DUNG` (tai khoan dang nhap,
> phan quyen). Day la bang bo sung o tang ung dung — nen giai thich trong bao cao la
> "bang phu tro cho xac thuc/phan quyen, ngoai 17 thuc the nghiep vu".

---

## C. BO SUNG PHAN TRIGGER (da lam that - ban phan tan)

Ban phan tan (dang trien khai) dung **5 trigger rang buoc nghiep vu**, nap tren **ca 3 node**
(HN/DN/HCM). Ban phan tan **KHONG dung stored procedure** (da bo de don gian hoa).
Ma nguon: `distributed/sql/triggers.sql`; mo ta + demo: `distributed/TRIGGER.md`.

**5 Trigger (rang buoc toan ven):**
1. `trg_vanphong_before_delete` — **BEFORE DELETE VAN_PHONG**: khong cho xoa van phong dang co hop dong thue **hieu luc**.
2. `trg_cthd_no_overlap` — **BEFORE INSERT CHI_TIET_HOP_DONG**: khong cho 2 hop dong thue **chung 1 van phong** khi khoang thoi gian **chong lan** (mot VP, mot thoi diem, mot cong ty).
3. `trg_vanphong_no_edit_when_used` — **BEFORE UPDATE VAN_PHONG**: khong cho sua cot nghiep vu (`ky_hieu_van_phong`, `tang`, `dien_tich`, `don_gia_m2`) khi VP dang duoc thue; van cho doi `trang_thai`.
4. `trg_sudung_check_company` — **BEFORE INSERT SU_DUNG_DICH_VU**: NVCT **chi dung dich vu cong ty minh** da dang ky (nhan vien phai thuoc dung cong ty cua dang ky).
5. `trg_hopdong_check_ngay_insert` / `trg_hopdong_check_ngay_update` — **BEFORE INSERT/UPDATE HOP_DONG_THUE**: kiem tra ngay hop dong `ngay_ket_thuc >= ngay_bat_dau`.

> Ghi chu: cac trigger ve van phong kiem tra truc tiep qua `CHI_TIET_HOP_DONG` + `HOP_DONG_THUE`
> (trang_thai = HIEU_LUC), khong phu thuoc cot `VAN_PHONG.trang_thai`.

Cong thuc luong (nen ghi trong bao cao phan tinh luong):
`tong_luong = luong_co_ban + (doanh_thu_dich_vu_phu_trach × ty_le_doanh_thu / 100)`.

---

## D. BO SUNG HAN PHAN CSDL PHAN TAN (phan lam nhieu nhat, docx CHUA CO)

Docx hien **chi noi ve CSDL tap trung**. Can them 1 chuong lon ve **CSDL phan tan** —
day la yeu cau/phan mo rong da trien khai thuc te. Noi dung can them:

### D1. Kien truc phan tan 3 diem
- **Ha Noi (tru so chinh)** + **Da Nang** + **TP.HCM** — 3 node MySQL rieng.
- Mot ung dung web (1 cong) cho phep dang nhap chon chi nhanh.

### D2. Chien luoc phan manh (Fragmentation)
- **Phan manh ngang (horizontal)** theo cot `khu_vuc` (HN/DN/HCM):
  - Bang phan manh: `CONG_TY`, `VAN_PHONG`, `NHAN_VIEN_CONG_TY`, `HOP_DONG_THUE`,
    `CHI_TIET_HOP_DONG`, `DANG_KY_DICH_VU`, `SU_DUNG_DICH_VU`, `HOA_DON`,
    `CHI_TIET_HOA_DON`, `NHAN_VIEN_TOA_NHA`, `PHAN_CONG_CONG_VIEC`, `LUONG_NHAN_VIEN`.
  - Vi du chia: HN = CT-01; DN = CT-02, CT-03; HCM = CT-04, CT-05.
  - `NHAN_VIEN_CONG_TY` di theo cong ty (khong can cot khu_vuc rieng).
- **Nhan ban (replication)** cac bang danh muc dung chung o ca 3 node:
  `DICH_VU`, `LOAI_CHI_PHI`, `VI_TRI_CONG_VIEC`.

### D3. Truy van phan tan tai tru so HN
- Dung **MySQL FEDERATED engine** (tuong duong Linked Server cua SQL Server) de HN
  truy van xuyen node toi DN/HCM.
- Cac **VIEW tong hop** (UNION ALL qua FEDERATED): `VW_Global_CONG_TY`,
  `VW_Global_HOA_DON`, `VW_Global_VAN_PHONG`, `VW_Global_NHAN_VIEN_TOA_NHA`.
- **Procedure** `sp_bao_cao_tong_hop(thang, nam)`: gom doanh thu 3 chi nhanh.

### D4. Phan quyen theo chi nhanh
- Moi chi nhanh co **1 tai khoan admin** quan ly toan bo DB chi nhanh do.
- **ADMIN o HN** = them bao cao tong hop toan quoc; **admin DN/HCM** = chi trong chi nhanh.
- Cac vai tro: ADMIN, BQL (nhan vien toa nha), NVCT (nhan vien cong ty), CONG_TY (dai dien).

### D5. So sanh Tap trung vs Phan tan (nen co bang)
| Tieu chi | Tap trung | Phan tan |
|----------|-----------|----------|
| So node CSDL | 1 | 3 (HN/DN/HCM) |
| Phan manh | Khong | Ngang theo khu_vuc |
| Truy van toan he thong | Truc tiep | Qua FEDERATED + VIEW |
| Han che | Diem loi don | FK/JOIN/transaction khong xuyen node |

---

## E. THAM CHIEU FILE DA CO (dinh kem hoac trich vao bao cao)

Cac noi dung tren da co san duoi dang file, co the copy vao docx:

| Noi dung | File |
|----------|------|
| Script tao 18 bang (tap trung) | `flask-app/sql/schema.sql` |
| Du lieu mau (tap trung) | `flask-app/sql/seed.sql` |
| Trigger phan tan (ma nguon) | `distributed/sql/triggers.sql` |
| Mo ta + demo 5 trigger phan tan | `distributed/TRIGGER.md` |
| Cau truy van bao cao | `queries.md` |
| Schema tung chi nhanh (phan tan) | `distributed/sql/schema_hanoi.sql`, `schema_danang.sql`, `schema_hcm.sql` |
| FEDERATED + VIEW tong hop | `distributed/sql/federated_hanoi.sql` |
| Vi du nhap du lieu tung bang | `distributed/sql/vi_du_du_lieu.sql` |
| Danh sach tai khoan | `distributed/TAI-KHOAN.md` |
| Kien truc phan tan | `distributed/README.md` |

---

## F. LOI CHINH TA / DIEN DAT NHO TRONG DOCX (nen sua)
- "MOT TOAN NHA" → "MOT TOA NHA" (tieu de).
- "danh tu tu" (lap tu) → "danh tu".
- "Nhan vien cong tychier su dung" → "Nhan vien cong ty chi su dung".
- "toa nha" viet khong dau lan lon vai cho — thong nhat lai.
- Muc "Xac dinh luc luong quan he" ket luan `CONG_TY N--N VAN_PHONG` la dung theo lich su,
  nhung nen noi ro cuoi cung tach ra `HOP_DONG_THUE` + `CHI_TIET_HOP_DONG` (docx co noi
  nhung bi cut o cho "phan ra thanh:" — thieu so do/ket qua).

---

## G. TOM TAT UU TIEN CAN LAM
1. **Viet noi dung cho 8 muc con trong** (muc A) — dac biet: anh xa quan he, PK/FK/UK,
   chuan hoa, rang buoc, trigger, truy van, script.
2. **Them chuong CSDL PHAN TAN** (muc D) — phan quan trong nhat, docx chua co.
3. **Bo sung cot con thieu** trong phan thuoc tinh (muc B) + giai thich bang `NGUOI_DUNG`.
4. Sua loi chinh ta (muc F).

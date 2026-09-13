# HUONG DAN SU DUNG WEB QUAN LY TOA NHA

Huong dan van hanh he thong: dang nhap, phan quyen, nhap du lieu, tinh hoa don thang cua cong ty, tinh luong, xem bao cao.

URL: **http://localhost:5000** (tren server thay bang IP server). Tai khoan quan tri `admin` / `admin`.

> Khai niem NoSQL/MongoDB: xem file **`nosql.md`**.

---

## 1. TAI KHOAN & PHAN QUYEN

> Quy uoc demo: **mat khau = ten dang nhap**. Nguoi dung **dang nhap bang chinh ma code** cua ho.

He thong co **4 vai tro**:

| Vai tro | Dang nhap bang | Vi du | Lam duoc gi |
|---------|----------------|-------|-------------|
| **ADMIN** | `admin` | `admin` / `admin` | Toan quyen: quan ly, tao hoa don/luong, bao cao, nhat ky, xem CSDL |
| **BQL** (nhan vien toa nha) | `ma_so_nhan_vien` cua `NHAN_VIEN_TOA_NHA` | `BQL-005` / `BQL-005` | **Xem luong cua chinh minh** (chi rieng nguoi do) |
| **NVCT** (nhan vien cong ty) | `ma_so_nhan_vien` cua `NHAN_VIEN_CONG_TY` | `NVCT-0001` / `NVCT-0001` | **Dang ky su dung dich vu** (an uong, gui xe) cua **chinh minh** + xem lich su cua **chinh minh** |
| **CONG_TY** (dai dien cong ty) | `ma_so_cong_ty` cua `CONG_TY` | `CT-01` / `CT-01` | Xem **hoa don cua cong ty minh** |

- Moi nhan vien toa nha -> 1 user BQL (login = ma the, vd `BQL-001`..`BQL-005`).
- Moi nhan vien cong ty -> 1 user NVCT (login = ma the, vd `NVCT-0001`...).
- Moi cong ty -> 1 user CONG_TY (login = ma cong ty, vd `CT-01`..`CT-05`).

**Nguyen tac phan quyen (kiem tra o phia may chu — sai quyen se bao 403):**
- **ADMIN**: tat ca chuc nang.
- **BQL**: chi xem duoc **luong cua chinh minh** (khong thay luong nguoi khac). Khong xem hoa don, khong nhap dich vu. (ADMIN moi xem duoc luong tat ca.)
- **NVCT**: chi **dang ky va xem su dung dich vu cua chinh minh** — khong xem luong, khong xem hoa don. Du co sua tham so gui len, he thong van khoa ve dung nhan vien do (`ma_nhan_vien`).
- **CONG_TY**: chi xem **hoa don cua chinh cong ty minh**. Du sua ID tren URL cung khong xem duoc hoa don cong ty khac (403).

> Luu y phan biet 2 loai "nhan vien":
> - **BQL = nhan vien toa nha** (van hanh toa nha) -> **co luong**.
> - **NVCT = nhan vien cong ty** (nguoi thue) -> **khong co luong**, chi dung dich vu.

---

## 2. CAC BUOC VAN HANH (VI DU THUC TE)

### Vi du A — Nhan vien cong ty (NVCT) dang ky su dung dich vu theo ngay
Ai lam: dang nhap bang user **NVCT** (vd `NVCT-0001`), hoac ADMIN. Day la buoc sinh ra log MongoDB va la du lieu de tinh phi dich vu theo luot.
1. Menu **"Dich vu cua toi → Dang ky su dung dich vu"** → nut **"+ Ghi nhan su dung"**.
2. Voi NVCT: cong ty va nhan vien da **khoa san la chinh minh**; chi can chon **dich vu theo luot** (an uong / gui xe — don gia tu dien), **ngay**, **so luong**, roi **Ghi nhan**. (ADMIN co the chon cong ty/nhan vien bat ky.)
3. Ket qua: mot dong vao MySQL (`SU_DUNG_DICH_VU`, cot `thanh_tien` tu tinh = so_luong × don_gia) + mot log vao MongoDB.
4. Xem lai o danh sach — NVCT chi thay **lich su cua chinh minh**. Lap lai cho tung ngay co su dung (khong bat buoc dung moi ngay).

### Vi du B — Tinh tien mot thang cua mot cong ty (tao hoa don thang)
Ai lam: **ADMIN**. Muc tieu: tinh tong tien cong ty phai tra trong thang = **tien thue mat bang + tien dich vu**.
1. Menu **Tai chinh → "Hoa don"** (voi ADMIN).
2. Chon **thang / nam**, bam **"⚙️ Tao hoa don thang"**.
3. He thong tu dong tinh cho **tung cong ty dang thue**:
   - **Tien thue** = tong (dien tich × don gia thue/m2) cua cac van phong trong hop dong hieu luc.
   - **Tien dich vu**, tuy `cach_tinh_phi` cua tung dich vu da dang ky:

     | Cach tinh phi | Thanh tien |
     |---------------|-----------|
     | `THEO_DIEN_TICH` | tong dien tich × don gia |
     | `THEO_DAU_NGUOI` | so nhan vien hoat dong × don gia |
     | `THEO_LUOT` (an uong, gui xe) | tong `thanh_tien` cac luot su dung trong thang (tu Vi du A) |
     | `TRON_GOI` | don gia |
   - Tao **HOA_DON** (tong tien) + cac dong **CHI_TIET_HOA_DON**.
4. Bam **"Chi tiet"** o mot hoa don de xem tung khoan phi. Neu da thu tien, bam **"Danh dau da thanh toan"**.
5. Dai dien cong ty (user **CONG_TY**, vd `CT-01`) dang nhap se thay **hoa don cua chinh cong ty minh** o menu "Hoa don cua cong ty".

> Moi cong ty chi co 1 hoa don cho moi (thang, nam) — rang buoc UNIQUE `uq_cty_thang_nam` chan tao trung.

**Vi du so lieu (cong ty ABC, thang 4/2026):**
- Thue VP-801 (150 m2 × 320.000) = 48.000.000 đ
- Ve sinh (150 m2 × 15.000) = 2.250.000 đ
- An trua (2 luot × 45.000) = 90.000 đ
- **Tong hoa don = 50.340.000 đ**

### Vi du C — Tinh & xem luong nhan vien toa nha trong thang
Luong = luong co ban theo vi tri + thuong theo % doanh thu dich vu phu trach. (Chi **BQL** moi co luong.)
1. **ADMIN** tinh luong: can co **phan cong cong viec** cho thang do (`PHAN_CONG_CONG_VIEC`), roi menu **Tai chinh → "Luong nhan vien toa nha"** → chon thang/nam → **"⚙️ Tinh luong thang"**.
2. Cong thuc: `tong_luong = luong_co_ban + (doanh_thu_dich_vu_phu_trach × ty_le_doanh_thu / 100)`.
   - `doanh_thu_dich_vu_phu_trach` lay tu cac dong hoa don cua dich vu ma nhan vien phu trach trong thang → **nen tao hoa don thang (Vi du B) truoc khi tinh luong**.
3. **Xem luong**: user **BQL** (vd `BQL-005`) dang nhap se thay **luong cua chinh minh** (chi rieng nguoi do, khong sua). ADMIN xem duoc luong tat ca va co nut "Chi luong".

### Vi du D — Xem bao cao Lai/Lo
Ai lam: **ADMIN**.
1. Menu **Tai chinh → "Bao cao Lai/Lo"** → chon nam.
2. Bang 12 thang: **Tong thu** (tu hoa don) − **Tong chi** (luong + chi phi van hanh) = **Loi nhuan rong**.

### Vi du E — Xem nhat ky (NoSQL) vua tao
Sau Vi du A, vao **"Nhat ky hoat dong"** (`/nhat-ky/`) → thay dong `SERVICE_USAGE` vua ghi. Hoac mo Mongo Express (:8081) de xem document tho.

---

## 3. QUY TRINH DEMO GOI Y (theo thu tu)
1. **admin** dang nhap; (neu can) them cong ty / van phong / hop dong / dang ky dich vu.
2. Dang nhap **`NVCT-0001`** (Vi du A): dang ky vai luot an uong, gui xe cho chinh minh → sinh log MongoDB. Kiem tra chi thay lich su cua minh.
3. **admin** (Vi du B): tao hoa don thang → xem tong tien mot cong ty.
4. Dang nhap **`CT-01`**: xem hoa don cua cong ty minh (khong thay cong ty khac).
5. **admin** (Vi du C): tinh luong thang. Dang nhap **`BQL-005`**: xem bang luong nhan vien toa nha.
6. **admin** (Vi du D): xem bao cao Lai/Lo.
7. **Vi du E**: **admin** mo "Nhat ky hoat dong" + Mongo Express (:8081) de doi chieu SQL ↔ NoSQL.

> Kiem chung phan quyen: dang nhap `NVCT-0001` thu vao `/luong` hoac `/hoa-don` → bao **403**; `CT-01` thu vao `/luong` → **403**; `BQL-005` thu vao `/hoa-don` → **403**.

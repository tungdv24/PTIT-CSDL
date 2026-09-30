# DANH SACH TAI KHOAN - HE THONG PHAN TAN

> Quy uoc demo: **mat khau = ten dang nhap** (rieng cac tai khoan `admin` mat khau la `admin`).
> Khi dang nhap phai **chon dung chi nhanh** cua tai khoan (moi user chi ton tai o node cua chi nhanh do).
> App: http://localhost:5001 (tren server: http://<IP-server>:5001)

## Quy mo du lieu (nap tu data.txt)
| | HN (Tru so) | DN | HCM | Tong |
|---|---|---|---|---|
| Cong ty (CT) | 4 (CT-01..04) | 3 (CT-05..07) | 3 (CT-08..10) | **10** |
| Nhan vien cong ty (NVCT) | 20 (NVCT-0001..0020) | 15 (NVCT-0021..0035) | 15 (NVCT-0036..0050) | **50** |
| Nhan vien toa nha (BQL) | 5 (BQL-001..005) | 5 (BQL-006..010) | 5 (BQL-011..015) | **15** |

> Moi cong ty co 5 NVCT. NVCT-0001..0005 thuoc CT-01, NVCT-0006..0010 thuoc CT-02, ... (chia deu, tang dan).
> Nhan vien toa nha PHAN MANH theo khu vuc; moi chi nhanh chon random 1 nguoi lam **quan ly** (2 tang phang).

## Vai tro
| Vai tro | Quyen |
|---------|-------|
| **ADMIN** | Xem/quan ly **toan bo DB cua chi nhanh** minh dang dang nhap + **CRUD danh muc chung** (Dich vu / Loai chi phi / Vi tri cong viec) ghi dong bo ca 3 node. Rieng ADMIN o HN co them **bao cao tong hop toan quoc** (gop 3 node qua FEDERATED). |
| **BQL** | Nhan vien toa nha - xem **luong cua chinh minh**. |
| **CONG_TY** | Dai dien cong ty - xem **hoa don cua cong ty minh**. |
| **NVCT** | Nhan vien cong ty - **ghi/xem su dung dich vu cua chinh minh**. |

---

## Chi nhanh HA NOI (HN) - Tru so chinh
| Ten dang nhap | Mat khau | Vai tro | Ho ten / Ghi chu |
|---------------|----------|---------|------------------|
| admin | admin | ADMIN | Quan tri Tru so HN (co bao cao tong hop toan quoc) |
| CT-01 | CT-01 | CONG_TY | Cong ty TNHH Cong nghe Viet Tan |
| CT-02 | CT-02 | CONG_TY | Cong ty Co phan An Phat Solutions |
| CT-03 | CT-03 | CONG_TY | Cong ty TNHH Minh Long Tech |
| CT-04 | CT-04 | CONG_TY | Cong ty Co phan Dai Viet Digital |
| BQL-001 | BQL-001 | BQL | Nguyen Van Khang |
| BQL-002..005 | (theo ma) | BQL | Tran Quoc Bao, Le Anh Khoa, Pham Thanh Long, Hoang Minh Nhat |
| NVCT-0001 | NVCT-0001 | NVCT | Nguyen Minh Anh (CT-01) |
| NVCT-0002..0020 | (theo ma) | NVCT | 20 NVCT cua 4 cong ty HN |

## Chi nhanh DA NANG (DN)
| Ten dang nhap | Mat khau | Vai tro | Ho ten / Ghi chu |
|---------------|----------|---------|------------------|
| admin | admin | ADMIN | Quan tri Chi nhanh Da Nang (chi trong node DN) |
| CT-05 | CT-05 | CONG_TY | Cong ty TNHH Hung Thinh Services |
| CT-06 | CT-06 | CONG_TY | Cong ty Co phan Nam Viet Innovation |
| CT-07 | CT-07 | CONG_TY | Cong ty TNHH Phuc An Technology |
| BQL-006 | BQL-006 | BQL | Vo Quang Vinh |
| BQL-007..010 | (theo ma) | BQL | Dang Duc Minh, Bui Thanh Son, Do Trong Nghia, Ngo Khac Duy |
| NVCT-0021 | NVCT-0021 | NVCT | Dang Thu Ha (CT-05) |
| NVCT-0022..0035 | (theo ma) | NVCT | 15 NVCT cua 3 cong ty DN |

## Chi nhanh TP.HCM (HCM)
| Ten dang nhap | Mat khau | Vai tro | Ho ten / Ghi chu |
|---------------|----------|---------|------------------|
| admin | admin | ADMIN | Quan tri Chi nhanh TP.HCM (chi trong node HCM) |
| CT-08 | CT-08 | CONG_TY | Cong ty Co phan Thanh Cong Group |
| CT-09 | CT-09 | CONG_TY | Cong ty TNHH Viet Nhat Solutions |
| CT-10 | CT-10 | CONG_TY | Cong ty Co phan Tan Tien Systems |
| BQL-011 | BQL-011 | BQL | Phan Ngoc Khanh |
| BQL-012..015 | (theo ma) | BQL | Vu Thi Ngoc, Ho Quynh Nhu, Duong Bich Ngoc, Nguyen Tu Anh |
| NVCT-0036 | NVCT-0036 | NVCT | Bui Quoc Anh (CT-08) |
| NVCT-0037..0050 | (theo ma) | NVCT | 15 NVCT cua 3 cong ty HCM |

---

## Luu y demo
- **admin@HN** vs **admin@DN** vs **admin@HCM**: cung ten `admin` nhung la 3 tai khoan khac nhau o 3 node. Chon chi nhanh khi dang nhap se quyet dinh vao node nao.
- ADMIN chi nhanh (DN/HCM) **khong** vao duoc menu "Tong hop toan quoc" (bao 403) - do la dac quyen tru so HN.
- Dang nhap sai chi nhanh (vd CT-05 o chi nhanh HN) se bao loi vi user do khong ton tai o node HN.
- **Hoa don thang 8 & 9/2026** da duoc tinh san (tien thue + dich vu co dinh). Dich vu THEO_LUOT (an uong/gui xe) chua tinh - se cong sau khi nhap su dung dich vu theo ngay.

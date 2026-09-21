# DANH SACH TAI KHOAN - HE THONG PHAN TAN

> Quy uoc demo: **mat khau = ten dang nhap** (rieng cac tai khoan `admin` mat khau la `admin`).
> Khi dang nhap phai **chon dung chi nhanh** cua tai khoan (moi user chi ton tai o node cua chi nhanh do).
> App: http://localhost:5001 (tren server: http://<IP-server>:5001)

## Vai tro
| Vai tro | Quyen |
|---------|-------|
| **ADMIN** | Xem/quan ly **toan bo DB cua chi nhanh** minh dang dang nhap. Rieng ADMIN o HN co them **bao cao tong hop toan quoc** (gop 3 node qua FEDERATED). |
| **BQL** | Nhan vien toa nha - xem **luong cua chinh minh** (chi co o HN). |
| **CONG_TY** | Dai dien cong ty - xem **hoa don cua cong ty minh**. |
| **NVCT** | Nhan vien cong ty - **ghi/xem su dung dich vu cua chinh minh**. |

---

## Chi nhanh HA NOI (HN) - Tru so chinh
| Ten dang nhap | Mat khau | Vai tro | Ho ten / Ghi chu |
|---------------|----------|---------|------------------|
| admin | admin | ADMIN | Quan tri Tru so HN (co bao cao tong hop toan quoc) |
| BQL-001 | BQL-001 | BQL | Vu Van Quan |
| BQL-002 | BQL-002 | BQL | Do Thi Ha |
| BQL-003 | BQL-003 | BQL | Bui Van Tung |
| BQL-004 | BQL-004 | BQL | Ngo Thi Lan |
| BQL-005 | BQL-005 | BQL | Dang Van Minh |
| CT-01 | CT-01 | CONG_TY | Cong ty TNHH Cong Nghe ABC |
| NVCT-0001 | NVCT-0001 | NVCT | Nguyen Van Hung (ABC) |
| NVCT-0002 | NVCT-0002 | NVCT | Tran Thi Mai (ABC) |

## Chi nhanh DA NANG (DN)
| Ten dang nhap | Mat khau | Vai tro | Ho ten / Ghi chu |
|---------------|----------|---------|------------------|
| admin | admin | ADMIN | Quan tri Chi nhanh Da Nang (chi trong node DN) |
| CT-02 | CT-02 | CONG_TY | Cong ty CP Tai Chinh XYZ |
| CT-03 | CT-03 | CONG_TY | Cong ty TNHH Thuong Mai DEF |
| NVCT-0003 | NVCT-0003 | NVCT | Le Van Nam (XYZ) |
| NVCT-0004 | NVCT-0004 | NVCT | Pham Thi Hoa (DEF) |

## Chi nhanh TP.HCM (HCM)
| Ten dang nhap | Mat khau | Vai tro | Ho ten / Ghi chu |
|---------------|----------|---------|------------------|
| admin | admin | ADMIN | Quan tri Chi nhanh TP.HCM (chi trong node HCM) |
| CT-04 | CT-04 | CONG_TY | Cong ty CP Giao Duc GHI |
| CT-05 | CT-05 | CONG_TY | Cong ty TNHH Logistics JKL |
| NVCT-0005 | NVCT-0005 | NVCT | Hoang Van Long (GHI) |
| NVCT-0006 | NVCT-0006 | NVCT | Dinh Thi Thu (JKL) |

---

## Luu y demo
- **admin@HN** vs **admin@DN** vs **admin@HCM**: cung ten `admin` nhung la 3 tai khoan khac nhau o 3 node. Chon chi nhanh khi dang nhap se quyet dinh vao node nao.
- ADMIN chi nhanh (DN/HCM) **khong** vao duoc menu "Tong hop toan quoc" (bao 403) - do la dac quyen tru so HN.
- Dang nhap sai chi nhanh (vd CT-02 o chi nhanh HN) se bao loi vi user do khong ton tai o node HN.

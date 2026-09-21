# HE THONG QUAN LY TOA NHA - PHIEN BAN CSDL PHAN TAN

Phien ban phan tan cua he thong quan ly toa nha van phong, gom **3 node MySQL** dat tai
3 dia diem: **Ha Noi (tru so chinh)**, **Da Nang** va **TP.HCM**. Mot app web duy nhat
cho phep dang nhap theo tung chi nhanh. Phien ban nay **khong dung MongoDB**.

> Phien ban tap trung (1 CSDL + MongoDB) duoc luu o nhanh/tag `v1-centralized` va thu muc `flask-app/` o goc repo.

## 1. Kien truc phan tan

```
                    +---------------------------+
                    |   App Flask (1 cong :5001) |
                    |  Login -> chon chi nhanh   |
                    +------------+--------------+
                                 | ket noi dong theo chi nhanh
        +------------------------+------------------------+
        v                        v                        v
+----------------+     +------------------+     +------------------+
| db_hanoi (HN)  |     | db_danang (DN)   |     | db_hcm (HCM)     |
| Tru so chinh   |     | Chi nhanh        |     | Chi nhanh        |
| :3316          |     | :3326            |     | :3336            |
+-------+--------+     +------------------+     +------------------+
        |  FEDERATED (tuong duong Linked Server), doc xuyen node
        +--> VW_Global_* : gop du lieu 3 node de bao cao toan he thong
```

### Phan m
anh du lieu (Horizontal Fragmentation theo `khu_vuc`)
- **HN** giu cong ty khu vuc HN (CT-01), + danh muc chung, + BQL/luong toan he thong.
- **DN** giu cong ty khu vuc DN (CT-02, CT-03) va toan bo hop dong/hoa don/su dung cua ho.
- **HCM** giu cong ty khu vuc HCM (CT-04, CT-05) va du lieu lien quan.

### Du lieu nhan ban (Replicated)
Cac bang danh muc dung chung nap GIONG NHAU o ca 3 node:
`DICH_VU`, `LOAI_CHI_PHI`, `VI_TRI_CONG_VIEC`, `NHAN_VIEN_TOA_NHA`.

### Truy van phan tan (Distributed Query) tai HN
Tru so HN co cac bang **FEDERATED** tro toi DN/HCM va cac **VIEW** `UNION ALL`:
- `VW_Global_CONG_TY`, `VW_Global_HOA_DON`, `VW_Global_VAN_PHONG`
- Procedure `sp_bao_cao_tong_hop(thang, nam)`: gom doanh thu 3 chi nhanh.

## 2. Cac dich vu & cong

| Dich vu | Container | URL / Cong |
|---------|-----------|-----------|
| App web | dist_flask | http://localhost:5001 |
| phpMyAdmin (chon 3 server) | dist_phpmyadmin | http://localhost:8090 |
| MySQL Ha Noi | dist_hanoi | localhost:3316 |
| MySQL Da Nang | dist_danang | localhost:3326 |
| MySQL TP.HCM | dist_hcm | localhost:3336 |

## 3. Chay tren may local

Yeu cau: Docker + Docker Compose.

```bash
cd distributed
docker compose -f docker-compose.dist.yml up -d --build
# Doi 3 node healthy (~30s), nap schema + du lieu phan manh:
bash deploy.sh          # neu chay tren server; tren local xem muc luu y ben duoi
```

Luu y: `deploy.sh` dung duong dan tren server. Khi chay local, sua bien `SQL` trong
`deploy.sh` tro toi thu muc `distributed/sql`, hoac nap thu cong:
```bash
for c in dist_hanoi dist_danang dist_hcm; do
  docker exec -i $c mysql -uroot -pDistPass123 < sql/00_schema.sql
  docker exec -i $c mysql -uroot -pDistPass123 < sql/01_seed_catalog.sql
done
docker exec -i dist_hanoi  mysql -uroot -pDistPass123 < sql/seed_hanoi.sql
docker exec -i dist_danang mysql -uroot -pDistPass123 < sql/seed_danang.sql
docker exec -i dist_hcm    mysql -uroot -pDistPass123 < sql/seed_hcm.sql
docker exec -i dist_hanoi  mysql -uroot -pDistPass123 < sql/federated_hanoi.sql
# Tao user tren 3 node:
docker exec dist_flask python -c "from app.config import Config; from app import db; from app.auth import bootstrap_users_all_nodes; cfg=Config(); db.init_engines(cfg); bootstrap_users_all_nodes(cfg.ADMIN_PASSWORD)"
```

## 4. Tai khoan demo (mat khau = ten dang nhap)

| Chi nhanh | Tai khoan | Vai tro |
|-----------|-----------|---------|
| HN | `admin` | ADMIN (tru so - co bao cao tong hop) |
| HN | `BQL-001`..`BQL-005` | Nhan vien toa nha (xem luong cua minh) |
| HN | `CT-01`, `NVCT-0001`, `NVCT-0002` | Cong ty / nhan vien khu vuc HN |
| DN | `CT-02`, `CT-03`, `NVCT-0003`, `NVCT-0004` | Khu vuc Da Nang |
| HCM | `CT-04`, `CT-05`, `NVCT-0005`, `NVCT-0006` | Khu vuc TP.HCM |

Khi dang nhap phai **chon dung chi nhanh** cua tai khoan (user chi ton tai o node cua chi nhanh do).

## 5. Phan quyen

- **ADMIN (HN)**: quan ly du lieu cua node HN + xem **bao cao tong hop toan he thong** (menu "Tong hop").
- **Chi nhanh (dang nhap DN/HCM)**: chi thao tac va sua du lieu **trong chi nhanh cua minh** (vi node do chi chua du lieu khu vuc do). Khong xem duoc bao cao tong hop (403).
- **CONG_TY**: xem hoa don cong ty minh. **NVCT**: ghi/xem su dung dich vu cua chinh minh. **BQL**: xem luong cua chinh minh.

## 6. Demo nhanh (SQL - tai node HN)

```sql
-- Du lieu phan manh: moi node chi giu khu vuc cua minh
-- (chay tren tung node de doi chieu)
SELECT ma_so_cong_ty, khu_vuc FROM CONG_TY;

-- Truy van phan tan: gop 3 node qua FEDERATED (chay tai HN)
SELECT * FROM VW_Global_CONG_TY ORDER BY chi_nhanh;

-- Bao cao doanh thu toan he thong theo chi nhanh
CALL sp_bao_cao_tong_hop(4, 2026);
```

## 7. Ky thuat

- **FEDERATED engine**: MySQL khoi dong voi co `--federated` (xem `docker-compose.dist.yml`).
  Bang FEDERATED tai HN co `CONNECTION='mysql://root:...@db_danang:3306/QuanLyToaNha/CONG_TY'`
  — tuong duong Linked Server cua SQL Server trong ke hoach.
- **Mang noi bo**: 3 node cung 1 Docker network (thay cho VPN/Radmin).
- **App**: moi chi nhanh co mot SQLAlchemy engine rieng; `session['khu_vuc']` quyet dinh
  truy van chay tren node nao. Bao cao tong hop luon doc tu node HN.

## 8. Han che (dung ban chat CSDL phan tan)
- Khoa ngoai (FK) khong kiem tra xuyen node.
- JOIN/giao dich xuyen chi nhanh phai qua FEDERATED (cham hon noi bo).
- Ghi du lieu la cuc bo tai tung node; HN chi doc tong hop (khong ghi xuyen node trong ban demo).

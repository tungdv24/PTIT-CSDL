# HE THONG QUAN LY TOA NHA VAN PHONG (Flask + MySQL)

Ung dung web quan ly toa nha van phong cho thue, xay dung theo dac ta CSDL trong `flask-app/` (17 bang nghiep vu + 1 bang nguoi dung). Backend + frontend gop chung trong mot app Flask (Jinja2 templates). He thong dung **2 CSDL**: **MySQL 8.0** cho du lieu nghiep vu, va **MongoDB** cho nhat ky hoat dong (activity log). Kem cong cu quan tri: **phpMyAdmin** (MySQL) va **Mongo Express** (MongoDB), cung trang "Xem CSDL" tich hop trong app.

> Mon hoc: **M26CQHT03-B - Nhom 7** | De tai: He CSDL quan ly toa nha van phong.
> Khai niem NoSQL: xem `nosql.md`. Huong dan van hanh: xem `huong-dan-su-dung.md`.
>
> **Hai phien ban:**
> - **Tap trung** (thu muc nay + `flask-app/`): 1 CSDL MySQL + MongoDB. Tag git `v1-centralized`.
> - **Phan tan** (`distributed/`): 3 node MySQL (HN/DN/HCM) + FEDERATED + VIEW tong hop, bo MongoDB, login chon chi nhanh. Xem `distributed/README.md`.

## Tech Stack

| Tang | Cong nghe |
|------|-----------|
| Web app | Python 3.11 + Flask 3 + Jinja2 + gunicorn |
| CSDL quan he | MySQL 8.0 (du lieu nghiep vu) |
| CSDL NoSQL | MongoDB 4.4 (nhat ky hoat dong, TTL index) |
| DB access | SQLAlchemy Core + PyMySQL; PyMongo |
| Auth | Flask-Login + Werkzeug password hashing (4 vai tro) |
| Quan tri DB | phpMyAdmin 5.2 + Mongo Express 1.0 + trang "Xem CSDL" trong app |
| Trien khai | Docker Compose (5 dich vu) |

## Chuc nang chinh

- **Dashboard**: tong thu / tong chi / loi nhuan theo thang, ty le lap day van phong, top cong ty, bieu do doanh thu.
- **Quan ly (CRUD)**: Cong ty, Van phong, Hop dong thue, Nhan vien cong ty, Nhan vien toa nha, Vi tri cong viec, Dich vu, Dang ky dich vu, Loai chi phi, Chi phi toa nha.
- **Hoa don**: xem danh sach + chi tiet, tao hoa don thang tu dong, danh dau da thanh toan.
- **Luong**: tinh luong thang tu dong (luong co ban + % doanh thu dich vu phu trach).
- **Bao cao Lai/Lo**: tong hop thu/chi/loi nhuan 12 thang.
- **Xem CSDL** (chi ADMIN): liet ke bang, xem du lieu co phan trang, chay truy van SELECT chi doc.

Cac cau lenh SQL van hanh + quan sat CSDL: xem `queries.md`.

---

## CHAY TREN MAY LOCAL

Yeu cau: **Docker** + **Docker Compose** (Docker Desktop tren macOS/Windows, hoac docker.io tren Linux). Khong can cai Python/MySQL trong may.

### 1. Clone repo
```bash
git clone https://github.com/tungdv24/PTIT-CSDL.git
cd PTIT-CSDL
```

### 2. Tao file cau hinh `.env`
```bash
cp .env.example .env
```
Mo `.env` va dat mat khau cua ban (dac biet `MYSQL_PASSWORD`, `SECRET_KEY`, `ADMIN_PASSWORD`).
Sinh nhanh mot SECRET_KEY:
```bash
python3 -c "import secrets; print(secrets.token_hex(32))"
```

### 3. Build & chay
```bash
docker compose up -d --build
```
Lan dau se mat vai phut de tai image MySQL/MongoDB/phpMyAdmin/Mongo Express va build app. Khi app khoi dong, no **tu dong**:
- Tao database `QuanLyToaNha`
- Chay `flask-app/sql/schema.sql` (18 bang)
- Nap du lieu mau `flask-app/sql/seed.sql` (chi khi bang CONG_TY con rong)
- Tao cac tai khoan nguoi dung mac dinh

### 4. Truy cap
| Dich vu | URL |
|---------|-----|
| Web app | http://localhost:5000 |
| phpMyAdmin (MySQL) | http://localhost:8080 |
| Mongo Express (MongoDB) | http://localhost:8081 |
| MySQL | localhost:3306 |
| MongoDB | localhost:27017 |

Dang nhap app bang tai khoan `admin` (mat khau la `ADMIN_PASSWORD` ban dat trong `.env`, mac dinh `admin`).
phpMyAdmin: dung tai khoan MySQL (`root` hoac `office_admin`, mat khau `MYSQL_PASSWORD`).
Mongo Express: basic auth `MONGO_EXPRESS_USER` / `MONGO_EXPRESS_PASSWORD` trong `.env`.

### 5. Kiem tra nhanh
```bash
docker compose ps
curl -s -o /dev/null -w "web:%{http_code}\n" http://localhost:5000/login   # 200
curl -s -o /dev/null -w "pma:%{http_code}\n" http://localhost:8080/         # 200
curl -s -o /dev/null -w "me :%{http_code}\n" -u admin:admin http://localhost:8081/  # 200
```

### 6. Dung / reset
```bash
docker compose down           # dung, giu du lieu
docker compose down -v        # dung + xoa du lieu (lan sau se tao lai schema + seed)
```

---

## Tai khoan mac dinh (app Flask)

Tao tu dong o lan chay dau. Mat khau `admin` lay tu `ADMIN_PASSWORD` trong `.env`; cac tai khoan con lai dung mat khau demo ben duoi (nen doi trong moi truong that).

| Ten dang nhap | Mat khau | Vai tro | Quyen |
|---------------|----------|---------|-------|
| admin | (theo `.env`) | ADMIN | Toan quyen + Xem CSDL |
| quanly01 | quanly123 | QUAN_LY | Quan ly, hoa don, luong, chi phi |
| nhanvien01 | nhanvien123 | NHAN_VIEN | Xem/cap nhat nhan vien cong ty |
| congty01 | congty123 | CONG_TY | Chi xem hoa don cua cong ty minh |

---

## Cong thuc nghiep vu

- **Tong hoa don** = tien thue mat bang + dich vu co dinh + dich vu theo luot
  - Tien thue = `dien_tich × don_gia_thue_m2`
  - Dich vu `THEO_DIEN_TICH` = tong dien tich × don gia
  - Dich vu `THEO_DAU_NGUOI` = so nhan vien hoat dong × don gia
  - Dich vu `THEO_LUOT` = tong `thanh_tien` tu `SU_DUNG_DICH_VU` trong thang
  - Dich vu `TRON_GOI` = don gia
- **Tong luong** = `luong_co_ban + (doanh_thu_dich_vu × ty_le_doanh_thu / 100)`
- **Loi nhuan** = Tong thu (hoa don) − (Tong luong + Chi phi van hanh)

---

## Cau truc thu muc

```
.
├── docker-compose.yml        # MySQL + MongoDB + phpMyAdmin + Mongo Express + Flask app
├── .env.example              # mau bien moi truong (copy thanh .env)
├── queries.md                # tap lenh SQL van hanh + quan sat CSDL
└── flask-app/
    ├── Dockerfile
    ├── requirements.txt
    ├── wsgi.py               # entrypoint gunicorn
    ├── sql/
    │   ├── schema.sql        # DDL 18 bang
    │   └── seed.sql          # du lieu mau
    └── app/
        ├── __init__.py       # app factory + bootstrap schema/seed
        ├── config.py         # doc cau hinh tu bien moi truong
        ├── db.py             # lop truy van SQLAlchemy Core
        ├── auth.py           # Flask-Login + phan quyen
        ├── views/            # dashboard, crud, finance, dbviewer
        └── templates/        # giao dien Jinja2
```

---

## QUAN LY & XU LY SU CO

```bash
# Xem log app
docker logs office_flask --tail 50

# Restart / build lai sau khi sua code
docker compose restart flask_app
docker compose up -d --build flask_app

# Vao MySQL truc tiep (thay $MYSQL_PASSWORD)
docker exec -it office_mysql mysql -uroot -p"$MYSQL_PASSWORD" QuanLyToaNha
```

### Trien khai tren server (tuy chon)
Quy trinh giong het chay local: cai Docker tren server, `git clone`, tao `.env` voi mat khau manh, `docker compose up -d --build`. Neu server ra Internet, **gioi han firewall cho port 5000/8080** hoac dat sau reverse proxy co xac thuc.

---

## LUU Y BAO MAT

- Khong commit file `.env` (da co trong `.gitignore`). Chi commit `.env.example`.
- Bang `NGUOI_DUNG` phuc vu dang nhap/phan quyen; mat khau luu **hash** (Werkzeug), khong luu plaintext.
- Trang "Xem CSDL" chi cho cau lenh doc (SELECT/SHOW/DESCRIBE/EXPLAIN); chan INSERT/UPDATE/DELETE/DROP.
- Doi toan bo mat khau mac dinh truoc khi dung that.

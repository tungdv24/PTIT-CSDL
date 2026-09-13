# NoSQL (MongoDB) TRONG HE THONG QUAN LY TOA NHA

Tai lieu nay giai thich **tai sao** va **cach** he thong su dung MongoDB (NoSQL) ben canh MySQL (SQL). Dung de dua vao bao cao mon hoc.

> Huong dan van hanh web (nhap du lieu, tinh hoa don thang, tinh luong, xem bao cao): xem file **`huong-dan-su-dung.md`**.

---

## 1. TAI SAO DUNG CA SQL VA NoSQL?

He thong dung **hai loai CSDL** cho hai loai du lieu khac nhau:

| | MySQL (SQL - quan he) | MongoDB (NoSQL - document) |
|---|---|---|
| Luu gi | Du lieu nghiep vu co cau truc chat: cong ty, van phong, hop dong, hoa don, luong, chi phi... | Nhat ky hoat dong (activity log) - ghi nhan su dung dich vu |
| Vi sao | Can rang buoc (khoa ngoai, UNIQUE, CHECK), giao dich ACID, JOIN nhieu bang de tinh toan tai chinh | Ghi nhieu (write-heavy), chi them (append-only), khong can JOIN, schema linh hoat, tu dong xoa log cu |
| Dac diem | 17 bang chuan hoa 3NF/BCNF | 1 collection `activity_logs`, moi ban ghi la mot document JSON |

**Y tuong cot loi:** dung dung cong cu cho dung viec. Du lieu tai chinh phai chinh xac tuyet doi → SQL. Nhat ky su dung chi de theo doi/kiem tra, sinh ra nhieu, cau truc co the thay doi → NoSQL. Cach lam nay goi la **polyglot persistence** (dung nhieu loai CSDL trong mot he thong).

---

## 2. MongoDB DUNG DE LAM GI TRONG DU AN

Trong ban demo nay, MongoDB chi luu **nhat ky khi ghi nhan su dung dich vu** (an uong, gui xe). Moi lan nguoi dung nhap mot luot su dung dich vu tren web, he thong:

1. Ghi ban ghi chinh thuc vao **MySQL** (bang `SU_DUNG_DICH_VU`) — day la du lieu nghiep vu, dung de tinh hoa don.
2. Ghi mot **document nhat ky** vao **MongoDB** (collection `activity_logs`) — day la log de theo doi "ai, lam gi, luc nao".

> Chi log o buoc ghi nhan su dung dich vu (cho don gian, du de demo). Cac thao tac khac (dang nhap, tao hoa don...) khong ghi log.

### Vi du mot document trong `activity_logs`
```json
{
  "_id": ObjectId("..."),
  "user": "admin",
  "role": "ADMIN",
  "action": "SERVICE_USAGE",
  "target": { "type": "SU_DUNG_DICH_VU", "id": 11 },
  "details": "Ghi nhan su dung dich vu: nhan_vien=1, dang_ky=2, ngay=2026-04-20, so_luong=1, don_gia=45000",
  "ip": "172.18.0.1",
  "timestamp": ISODate("2026-09-10T12:33:05Z")
}
```

### Dac diem NoSQL the hien o day
- **Schema linh hoat:** truong `details` la chuoi tu do, `target` la object long nhau; khong can dinh nghia bang truoc nhu SQL.
- **Append-only:** chi them log, khong sua.
- **TTL index (tu dong xoa):** log tu dong bi xoa sau **90 ngay** nho chi muc TTL (`ttl_timestamp`, expireAfterSeconds = 7.776.000 giay). Day la tinh nang dac trung cua MongoDB ma SQL khong co san.
- **Khong JOIN:** moi document tu du thong tin de doc, khong phai ghep bang.

---

## 3. KIEN TRUC TRIEN KHAI

Tat ca chay bang Docker Compose, gom 5 container:

| Container | Vai tro | Cong |
|-----------|---------|------|
| `office_mysql` | MySQL 8.0 - du lieu nghiep vu | 3306 |
| `office_mongodb` | MongoDB 4.4 - nhat ky hoat dong | 27017 |
| `office_flask` | Web app (Flask) | 5000 |
| `office_phpmyadmin` | Xem/quan tri MySQL | 8080 |
| `office_mongo_express` | Xem/quan tri MongoDB | 8081 |

Luong ghi log (fail-soft): neu MongoDB gap su co, app **van chay binh thuong**, chi la khong ghi duoc log — tai chinh/nghiep vu tren MySQL khong bi anh huong.

```
Nguoi dung bam "Ghi nhan su dung dich vu"
        │
        ├──> MySQL:   INSERT INTO SU_DUNG_DICH_VU (...)   ← du lieu nghiep vu (dung de tinh hoa don)
        │
        └──> MongoDB: insert_one({action:"SERVICE_USAGE", ...})  ← nhat ky (co the tat, khong lam hong app)
```

---

## 4. XEM & TRUY VAN DU LIEU MongoDB

### Cach 1 - Trong app (than thien)
Dang nhap vai tro ADMIN hoac QUAN_LY → menu **"Nhat ky hoat dong"** (`/nhat-ky/`). Co bo loc theo hanh dong va nguoi dung.

### Cach 2 - Mongo Express (xem document tho)
Truy cap **http://localhost:8081** (dang nhap `admin` / `admin123`) → chon database `quanlytoanha_logs` → collection `activity_logs`.

### Cach 3 - Mongo shell (de demo cau lenh NoSQL)
```bash
docker exec -it office_mongodb mongo -u admin -p <MONGO_PASSWORD> --authenticationDatabase admin quanlytoanha_logs
```
```javascript
// Xem 10 log gan nhat
db.activity_logs.find().sort({ timestamp: -1 }).limit(10)

// Dem so log theo tung hanh dong
db.activity_logs.aggregate([
  { $group: { _id: "$action", so_luong: { $sum: 1 } } }
])

// Loc log cua mot nguoi dung
db.activity_logs.find({ user: "admin" })

// Xem cac chi muc (co ttl_timestamp = TTL 90 ngay)
db.activity_logs.getIndexes()
```

---

## 5. TOM TAT DE DUA VAO BAO CAO

- He thong **da CSDL (polyglot persistence)**: MySQL cho du lieu nghiep vu quan he, MongoDB cho nhat ky hoat dong.
- MongoDB duoc chon cho log vi: schema linh hoat, ghi nhanh, append-only, khong can JOIN, va co **TTL index** tu dong don dep log cu (90 ngay).
- Trong ban demo, log chi ghi khi **ghi nhan su dung dich vu** → moi thao tac tao ra dong thoi 1 ban ghi SQL (de tinh tien) va 1 document NoSQL (de theo doi).
- Co day du cong cu quan tri truc quan: **phpMyAdmin** (SQL) va **Mongo Express** (NoSQL).
- Thiet ke **fail-soft**: MongoDB co su co cung khong lam gian doan nghiep vu tren MySQL.

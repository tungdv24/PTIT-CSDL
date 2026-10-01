#!/usr/bin/env bash
# =====================================================================
# Nap schema + du lieu phan manh vao 3 node, roi cai FEDERATED/VIEW o HN.
# Chay TREN SERVER, trong thu muc chua docker-compose.dist.yml.
# Yeu cau: 3 container dist_hanoi / dist_danang / dist_hcm da chay & healthy.
# =====================================================================
set -e
PW="${DB_PASSWORD:-DistPass123}"
SQL=/root/office-dist/distributed/sql   # duong dan file sql tren server

run() {  # run <container> <sqlfile>
  echo ">> $1 <= $(basename "$2")"
  # --default-character-set=utf8mb4: BAT BUOC, neu khong client mysql mac dinh
  # latin1 se lam hong tieng Viet trong file seed (loi mojibake "CÃ´ng ty").
  docker exec -i "$1" mysql --default-character-set=utf8mb4 -uroot -p"$PW" < "$2" 2>&1 | grep -v "Using a password" || true
}

echo "===== 00 SCHEMA (ca 3 node) ====="
for c in dist_hanoi dist_danang dist_hcm; do run "$c" "$SQL/00_schema.sql"; done

echo "===== 01 DANH MUC CHUNG (nhan ban ca 3 node) ====="
for c in dist_hanoi dist_danang dist_hcm; do run "$c" "$SQL/01_seed_catalog.sql"; done

echo "===== 02 DU LIEU PHAN MANH THEO KHU VUC ====="
run dist_hanoi  "$SQL/02_seed_hanoi.sql"
run dist_danang "$SQL/02_seed_danang.sql"
run dist_hcm    "$SQL/02_seed_hcm.sql"

echo "===== 03 FEDERATED + VIEW (chi tai HN) ====="
run dist_hanoi  "$SQL/03_federated_hanoi.sql"

echo "===== 04 TRIGGER RANG BUOC NGHIEP VU (ca 3 node) ====="
for c in dist_hanoi dist_danang dist_hcm; do run "$c" "$SQL/04_triggers.sql"; done

echo "===== 05 STORED PROCEDURE / TRANSACTION (ca 3 node) ====="
for c in dist_hanoi dist_danang dist_hcm; do run "$c" "$SQL/05_procedures.sql"; done

echo "===== XONG ====="

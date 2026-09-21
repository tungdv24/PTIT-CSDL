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
  docker exec -i "$1" mysql -uroot -p"$PW" < "$2" 2>&1 | grep -v "Using a password" || true
}

echo "===== SCHEMA (ca 3 node) ====="
for c in dist_hanoi dist_danang dist_hcm; do run "$c" "$SQL/00_schema.sql"; done

echo "===== DANH MUC CHUNG (nhan ban ca 3 node) ====="
for c in dist_hanoi dist_danang dist_hcm; do run "$c" "$SQL/01_seed_catalog.sql"; done

echo "===== DU LIEU PHAN MANH THEO KHU VUC ====="
run dist_hanoi  "$SQL/seed_hanoi.sql"
run dist_danang "$SQL/seed_danang.sql"
run dist_hcm    "$SQL/seed_hcm.sql"

echo "===== FEDERATED + VIEW + PROCEDURE (chi tai HN) ====="
run dist_hanoi  "$SQL/federated_hanoi.sql"

echo "===== XONG ====="

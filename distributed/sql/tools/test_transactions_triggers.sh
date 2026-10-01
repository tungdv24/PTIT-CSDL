#!/usr/bin/env bash
# =====================================================================
# KICH BAN TEST: chung minh 5 STORED PROCEDURE (transaction) va 7 TRIGGER
# hoat dong dung tren mot node MySQL cua he phan tan.
#
# Cach chay (tren SERVER, noi co docker):
#   bash test_transactions_triggers.sh [TEN_CONTAINER]
#   vi du:  bash test_transactions_triggers.sh dist_hanoi
#
# Hoac chay truc tiep qua mysql client (sua MYSQL o duoi cho phu hop).
#
# Script tu don dep du lieu test o cuoi -> chay lai nhieu lan duoc.
# Moi buoc in ro [PASS]/[FAIL] va ket qua mong doi.
# =====================================================================
set -u

CONTAINER="${1:-dist_hanoi}"
PW="${DB_PASSWORD:-DistPass123}"
DB="QuanLyToaNha"

# Ham chay SQL, tra ve stdout; dung utf8mb4 cho tieng Viet
runsql() {
  docker exec -i "$CONTAINER" mysql --default-character-set=utf8mb4 -uroot -p"$PW" -N -B "$DB" 2>/dev/null
}
# Chay SQL va bat loi (de test cac ca BI CHAN): in "ERROR..." neu loi
runsql_err() {
  docker exec -i "$CONTAINER" mysql --default-character-set=utf8mb4 -uroot -p"$PW" "$DB" 2>&1 | grep -v "Using a password"
}

pass() { echo "  [PASS] $1"; }
fail() { echo "  [FAIL] $1"; }

# Kiem tra 1 lenh co BI LOI dung nhu mong doi khong.
# $1 = SQL,  $2 = mo ta,  $3 = chuoi loi mong doi (grep)
expect_error() {
  local out; out=$(printf '%s' "$1" | runsql_err)
  if echo "$out" | grep -qi "$3"; then
    pass "$2 -> bi chan dung: $(echo "$out" | grep -i 'ERROR' | head -1 | sed 's/^[^:]*: //')"
  else
    fail "$2 -> KHONG bi chan nhu mong doi. Output: $out"
  fi
}

echo "========================================================="
echo " TEST TRANSACTION + TRIGGER tren node: $CONTAINER"
echo "========================================================="

# Chon mot cong ty + van phong + hop dong co san de test an toan
CTY=$(printf "SELECT ma_cong_ty FROM CONG_TY ORDER BY ma_cong_ty LIMIT 1;" | runsql)
HD=$(printf "SELECT ma_hop_dong FROM HOP_DONG_THUE WHERE ma_cong_ty=%s LIMIT 1;" "$CTY" | runsql)
VP_TRONG=$(printf "SELECT ma_van_phong FROM VAN_PHONG WHERE trang_thai='TRONG' LIMIT 1;" | runsql)
NV1=$(printf "SELECT ma_nhan_vien_toa_nha FROM NHAN_VIEN_TOA_NHA ORDER BY ma_nhan_vien_toa_nha LIMIT 1;" | runsql)
NV2=$(printf "SELECT ma_nhan_vien_toa_nha FROM NHAN_VIEN_TOA_NHA ORDER BY ma_nhan_vien_toa_nha LIMIT 1 OFFSET 1;" | runsql)
echo "Du lieu dung de test: CTY=$CTY  HD=$HD  VP_TRONG=$VP_TRONG  NV1=$NV1  NV2=$NV2"
echo

# =====================================================================
echo "----- A. STORED PROCEDURE (TRANSACTION) -----"
# ---------------------------------------------------------------------
echo "[TX5] sp_ChotHoaDonThang - chot hoa don thang 12/2026 (moi)"
printf "CALL sp_ChotHoaDonThang(%s, 12, 2026);" "$CTY" | runsql_err >/dev/null
CNT=$(printf "SELECT COUNT(*) FROM HOA_DON WHERE ma_cong_ty=%s AND thang=12 AND nam=2026;" "$CTY" | runsql)
[ "$CNT" = "1" ] && pass "Tao hoa don thang 12 thanh cong (COMMIT)" || fail "Khong tao duoc hoa don"

echo "[TX5] Chot LAI thang 12 (trung) -> phai ROLLBACK + bao loi"
expect_error "$(printf 'CALL sp_ChotHoaDonThang(%s, 12, 2026);' "$CTY")" "Chot hoa don trung" "da ton tai"
CNT=$(printf "SELECT COUNT(*) FROM HOA_DON WHERE ma_cong_ty=%s AND thang=12 AND nam=2026;" "$CTY" | runsql)
[ "$CNT" = "1" ] && pass "Hoa don khong bi nhan doi (van 1 dong)" || fail "Bi nhan doi: $CNT dong"

echo
echo "[TX2] sp_ThueVanPhong - thue VP trong cho hop dong"
if [ -n "$VP_TRONG" ]; then
  printf "CALL sp_ThueVanPhong(%s, %s, 300000, '2026-10-01', '2026-12-31');" "$HD" "$VP_TRONG" | runsql_err >/dev/null
  CNT=$(printf "SELECT COUNT(*) FROM CHI_TIET_HOP_DONG WHERE ma_van_phong=%s AND ngay_bat_dau='2026-10-01';" "$VP_TRONG" | runsql)
  [ "$CNT" = "1" ] && pass "Thue van phong thanh cong" || fail "Khong thue duoc"

  echo "[TX2] Thue LAI cung VP trung thoi gian -> trigger trg_cthd_no_overlap chan"
  expect_error "$(printf "CALL sp_ThueVanPhong(%s, %s, 300000, '2026-11-01', '2026-12-01');" "$HD" "$VP_TRONG")" "Thue trung thoi gian" "trung hop dong"
else
  echo "  (bo qua: khong co van phong TRONG)"
fi

echo
echo "[TX1] sp_ThayDoiNguoiQuanLy - doi quan ly NV1 sang NV2"
printf "CALL sp_ThayDoiNguoiQuanLy(%s, %s, '2026-10-01');" "$NV1" "$NV2" | runsql_err >/dev/null
NEW=$(printf "SELECT ma_nguoi_quan_ly FROM QUAN_LY_NHAN_VIEN WHERE ma_nhan_vien=%s AND ngay_ket_thuc IS NULL;" "$NV1" | runsql)
[ "$NEW" = "$NV2" ] && pass "Doi quan ly thanh cong (QL moi = NV2=$NV2, luu lich su QL cu)" || fail "QL hien tai = $NEW (mong doi $NV2)"

echo "[TX1] Tu quan ly chinh minh -> trigger trg_quanly_no_self chan + ROLLBACK"
QL_TRUOC=$(printf "SELECT COUNT(*) FROM QUAN_LY_NHAN_VIEN WHERE ma_nhan_vien=%s AND ngay_ket_thuc IS NULL;" "$NV2" | runsql)
expect_error "$(printf 'CALL sp_ThayDoiNguoiQuanLy(%s, %s, "2026-10-01");' "$NV2" "$NV2")" "Tu quan ly chinh minh" "tu quan ly"
QL_SAU=$(printf "SELECT COUNT(*) FROM QUAN_LY_NHAN_VIEN WHERE ma_nhan_vien=%s AND ngay_ket_thuc IS NULL;" "$NV2" | runsql)
[ "$QL_TRUOC" = "$QL_SAU" ] && pass "ROLLBACK dung: quan he cua NV2 khong bi thay doi" || fail "Bi anh huong: truoc=$QL_TRUOC sau=$QL_SAU"

echo
echo "[TX3] sp_TinhTienDichVuBacThang - tinh tien bac thang (OUT)"
TIEN=$(printf "CALL sp_TinhTienDichVuBacThang(%s, 1000000, 30, 30, @t); SELECT @t;" "$CTY" | runsql)
[ -n "$TIEN" ] && pass "Tinh ra thanh tien bac thang = $TIEN (don gia goc 1,000,000)" || fail "Khong tinh duoc"

echo
echo "[TX4] sp_ChotLuongThang - chot luong thang 12/2026 (ghi LUONG_NHAN_VIEN)"
printf "CALL sp_ChotLuongThang(12, 2026);" | runsql_err >/dev/null
CNT=$(printf "SELECT COUNT(*) FROM LUONG_NHAN_VIEN WHERE thang=12 AND nam=2026;" | runsql)
[ "$CNT" -gt 0 ] && pass "Chot luong thanh cong: $CNT nhan vien" || fail "Khong co ban ghi luong"

# =====================================================================
echo
echo "----- B. CAC TRIGGER CON LAI -----"
# ---------------------------------------------------------------------
echo "[TRG] trg_vanphong_before_delete - khong xoa VP dang co hop dong hieu luc"
VP_DANG_THUE=$(printf "SELECT cthd.ma_van_phong FROM CHI_TIET_HOP_DONG cthd JOIN HOP_DONG_THUE hd ON hd.ma_hop_dong=cthd.ma_hop_dong WHERE hd.trang_thai='HIEU_LUC' LIMIT 1;" | runsql)
if [ -n "$VP_DANG_THUE" ]; then
  expect_error "$(printf 'DELETE FROM VAN_PHONG WHERE ma_van_phong=%s;' "$VP_DANG_THUE")" "Xoa VP dang thue" "hop dong thue hieu luc"
else
  echo "  (bo qua: khong tim thay VP trong hop dong hieu luc)"
fi

echo "[TRG] trg_hopdong_check_ngay_insert - ngay_ket_thuc < ngay_bat_dau bi chan"
expect_error "INSERT INTO HOP_DONG_THUE (so_hop_dong, ma_cong_ty, ngay_bat_dau, ngay_ket_thuc) VALUES ('TEST-NGAY-SAI', $CTY, '2026-12-31', '2026-01-01');" "Ngay HD sai thu tu" "ngay bat dau"

echo "[TRG] trg_sudung_check_company - NVCT dung DV cong ty khac bi chan"
# Tim 1 NVCT va 1 dang ky dich vu KHAC cong ty
NVCT=$(printf "SELECT ma_nhan_vien FROM NHAN_VIEN_CONG_TY WHERE ma_cong_ty=%s LIMIT 1;" "$CTY" | runsql)
DK_KHAC=$(printf "SELECT ma_dang_ky FROM DANG_KY_DICH_VU WHERE ma_cong_ty<>%s LIMIT 1;" "$CTY" | runsql)
if [ -n "$NVCT" ] && [ -n "$DK_KHAC" ]; then
  expect_error "INSERT INTO SU_DUNG_DICH_VU (ma_nhan_vien, ma_dang_ky, ngay_su_dung, so_luong, don_gia) VALUES ($NVCT, $DK_KHAC, '2026-10-01', 1, 50000);" "NVCT dung DV cty khac" "khong thuoc cong ty"
else
  echo "  (bo qua: thieu du lieu NVCT/DANG_KY khac cong ty)"
fi

echo "[TRG] trg_quanly_no_self (6b) - nguoi DANG la quan ly thi khong bi quan ly"
# NV2 hien dang la quan ly cua NV1 (do TX1 o tren) -> thu gan NV2 lam cap duoi NV1
expect_error "INSERT INTO QUAN_LY_NHAN_VIEN (ma_nhan_vien, ma_nguoi_quan_ly, ngay_bat_dau) VALUES ($NV2, $NV1, '2026-10-01');" "Quan ly bi quan ly" "dang la quan ly"

# =====================================================================
echo
echo "----- C. DON DEP DU LIEU TEST -----"
printf "%s" "
DELETE FROM HOA_DON WHERE ma_cong_ty=$CTY AND thang=12 AND nam=2026;
DELETE FROM LUONG_NHAN_VIEN WHERE thang=12 AND nam=2026;
DELETE FROM CHI_TIET_HOP_DONG WHERE ma_van_phong=${VP_TRONG:-0} AND ngay_bat_dau='2026-10-01';
DELETE FROM QUAN_LY_NHAN_VIEN WHERE ma_nhan_vien=$NV1 AND ma_nguoi_quan_ly=$NV2;
UPDATE QUAN_LY_NHAN_VIEN SET ngay_ket_thuc=NULL WHERE ma_nhan_vien=$NV1 AND ngay_ket_thuc='2026-09-30';
" | runsql_err >/dev/null
echo "  Da don dep du lieu test (co the chay lai script nhieu lan)."
echo
echo "========================================================="
echo " HOAN TAT. Xem [PASS]/[FAIL] o tren."
echo "========================================================="

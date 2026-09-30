-- =====================================================================
-- SUA LOI TIENG VIET BI DOUBLE-ENCODE (mojibake kieu "CÃ´ng ty")
-- =====================================================================
-- Nguyen nhan: file seed duoc nap qua ket noi client charset = latin1 nen
-- moi byte UTF-8 bi ma hoa UTF-8 lan nua. Cot van la utf8mb4 nhung noi dung
-- la "utf8(latin1(utf8_that))". Phep sua chuan:
--   CONVERT(BINARY(CONVERT(col USING latin1)) USING utf8mb4)
-- Voi chuoi ASCII thuan (admin, CT-01, HN...) phep nay KHONG doi gi -> an toan.
--
-- CHI sua BANG GOC CUC BO (khong dung cho *_DN / *_HCM / VW_* vi do la
-- FEDERATED / VIEW tro sang node khac).
-- Chay tren TUNG node: docker exec <node> mysql ... < fix_encoding.sql
-- =====================================================================
USE QuanLyToaNha;

UPDATE CONG_TY SET
  ten_cong_ty   = CONVERT(BINARY(CONVERT(ten_cong_ty   USING latin1)) USING utf8mb4),
  nguoi_dai_dien= CONVERT(BINARY(CONVERT(nguoi_dai_dien USING latin1)) USING utf8mb4),
  dia_chi       = CONVERT(BINARY(CONVERT(dia_chi        USING latin1)) USING utf8mb4);

UPDATE NHAN_VIEN_CONG_TY SET
  ho_ten  = CONVERT(BINARY(CONVERT(ho_ten  USING latin1)) USING utf8mb4),
  chuc_vu = CONVERT(BINARY(CONVERT(chuc_vu USING latin1)) USING utf8mb4);

UPDATE NHAN_VIEN_TOA_NHA SET
  ho_ten = CONVERT(BINARY(CONVERT(ho_ten USING latin1)) USING utf8mb4);

UPDATE NGUOI_DUNG SET
  ho_ten = CONVERT(BINARY(CONVERT(ho_ten USING latin1)) USING utf8mb4);

UPDATE VAN_PHONG SET
  vi_tri = CONVERT(BINARY(CONVERT(vi_tri USING latin1)) USING utf8mb4)
  WHERE vi_tri IS NOT NULL;

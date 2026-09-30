-- =====================================================================
-- THEM COT ma_vi_tri VAO NHAN_VIEN_TOA_NHA (lien ket VI_TRI_CONG_VIEC)
-- Chay tren TUNG node (dist_hanoi / dist_danang / dist_hcm).
-- VI_TRI_CONG_VIEC la danh muc nhan ban giong nhau o 3 node nen ma_vi_tri
-- co y nghia dong nhat tren moi node.
-- =====================================================================
USE QuanLyToaNha;

-- 1) Them cot neu chua co (idempotent qua bien dieu kien)
SET @exists := (SELECT COUNT(*) FROM information_schema.columns
                WHERE table_schema='QuanLyToaNha' AND table_name='NHAN_VIEN_TOA_NHA'
                  AND column_name='ma_vi_tri');
SET @sql := IF(@exists=0,
  'ALTER TABLE NHAN_VIEN_TOA_NHA ADD COLUMN ma_vi_tri INT NULL AFTER khu_vuc',
  'SELECT "ma_vi_tri da ton tai" AS info');
PREPARE s FROM @sql; EXECUTE s; DEALLOCATE PREPARE s;

-- 2) Gan vi tri cho nhan vien hien co:
--    - Nguoi la QUAN LY cua node -> "Quan ly toa nha" (ma_vi_tri = 1)
--    - Cac nhan vien con lai -> luan phien 4 vi tri nhan vien (ma 2..5) theo thu tu ma NV
UPDATE NHAN_VIEN_TOA_NHA nv
JOIN (
    SELECT ma_nhan_vien_toa_nha,
           ROW_NUMBER() OVER (ORDER BY ma_nhan_vien_toa_nha) AS rn
    FROM NHAN_VIEN_TOA_NHA
    WHERE ma_nhan_vien_toa_nha NOT IN (
        SELECT DISTINCT ma_nguoi_quan_ly FROM QUAN_LY_NHAN_VIEN WHERE ngay_ket_thuc IS NULL
    )
) t ON t.ma_nhan_vien_toa_nha = nv.ma_nhan_vien_toa_nha
SET nv.ma_vi_tri = 2 + ((t.rn - 1) % 4);   -- vi tri nhan vien: 2,3,4,5 luan phien

UPDATE NHAN_VIEN_TOA_NHA
SET ma_vi_tri = 1   -- Quan ly toa nha
WHERE ma_nhan_vien_toa_nha IN (
    SELECT ma_nguoi_quan_ly FROM (
        SELECT DISTINCT ma_nguoi_quan_ly FROM QUAN_LY_NHAN_VIEN WHERE ngay_ket_thuc IS NULL
    ) x
);

-- 3) Bat ky NV nao chua co vi tri (phong ho) -> mac dinh "Nhan vien bao ve" (4)
UPDATE NHAN_VIEN_TOA_NHA SET ma_vi_tri = 4 WHERE ma_vi_tri IS NULL;

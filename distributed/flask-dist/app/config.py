import os


class Config:
    SECRET_KEY = os.environ.get("SECRET_KEY", "quanlytoanha-dist-dev-secret")

    DB_PASSWORD = os.environ.get("DB_PASSWORD", "DistPass123")
    DB_NAME = os.environ.get("DB_NAME", "QuanLyToaNha")
    DB_PORT = int(os.environ.get("DB_PORT", "3306"))

    ADMIN_PASSWORD = os.environ.get("ADMIN_PASSWORD", "admin")

    # 3 node phan tan: chi nhanh -> host container.
    NODES = {
        "HN": {
            "ten": "Ha Noi (Tru so chinh)",
            "host": os.environ.get("NODE_HANOI_HOST", "db_hanoi"),
            "is_head": True,   # tru so chinh: co bao cao tong hop
        },
        "DN": {
            "ten": "Da Nang (Chi nhanh)",
            "host": os.environ.get("NODE_DANANG_HOST", "db_danang"),
            "is_head": False,
        },
        "HCM": {
            "ten": "TP.HCM (Chi nhanh)",
            "host": os.environ.get("NODE_HCM_HOST", "db_hcm"),
            "is_head": False,
        },
    }

    def node_url(self, khu_vuc: str) -> str:
        node = self.NODES[khu_vuc]
        return (
            f"mysql+pymysql://root:{self.DB_PASSWORD}"
            f"@{node['host']}:{self.DB_PORT}/{self.DB_NAME}?charset=utf8mb4"
        )

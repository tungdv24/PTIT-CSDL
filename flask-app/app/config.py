import os


class Config:
    SECRET_KEY = os.environ.get("SECRET_KEY", "quanlytoanha-dev-secret-change-me")

    MYSQL_HOST = os.environ.get("MYSQL_HOST", "localhost")
    MYSQL_PORT = int(os.environ.get("MYSQL_PORT", "3306"))
    MYSQL_USER = os.environ.get("MYSQL_USER", "root")
    MYSQL_PASSWORD = os.environ.get("MYSQL_PASSWORD", "changeme")
    MYSQL_DATABASE = os.environ.get("MYSQL_DATABASE", "QuanLyToaNha")

    # MongoDB (activity logging - NoSQL). Empty MONGO_URI disables logging.
    MONGO_URI = os.environ.get("MONGO_URI", "")
    MONGO_DB = os.environ.get("MONGO_DB", "quanlytoanha_logs")
    # Auto-expire logs after N days (0 = keep forever)
    LOG_TTL_DAYS = int(os.environ.get("LOG_TTL_DAYS", "90"))

    # Default admin bootstrapped on first run
    ADMIN_USERNAME = os.environ.get("ADMIN_USERNAME", "admin")
    ADMIN_PASSWORD = os.environ.get("ADMIN_PASSWORD", "admin123")

    @property
    def sqlalchemy_url(self) -> str:
        return (
            f"mysql+pymysql://{self.MYSQL_USER}:{self.MYSQL_PASSWORD}"
            f"@{self.MYSQL_HOST}:{self.MYSQL_PORT}/{self.MYSQL_DATABASE}"
            f"?charset=utf8mb4"
        )

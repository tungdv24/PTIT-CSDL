import os
import time

from flask import Flask, redirect, url_for
from flask_login import login_required, current_user

from .config import Config
from . import db
from .auth import login_manager, auth_bp, bootstrap_users


def _init_schema(cfg: Config):
    """Create the database + tables if missing, then optionally seed.

    Runs the SQL files shipped in ../sql. Safe to run repeatedly because the
    DDL uses CREATE TABLE IF NOT EXISTS. Seed only runs when CONG_TY is empty.
    """
    from sqlalchemy import create_engine, text

    base = os.path.dirname(os.path.dirname(__file__))
    schema_path = os.path.join(base, "sql", "schema.sql")
    seed_path = os.path.join(base, "sql", "seed.sql")

    # Connect without a specific database first, to create it if needed.
    server_url = (
        f"mysql+pymysql://{cfg.MYSQL_USER}:{cfg.MYSQL_PASSWORD}"
        f"@{cfg.MYSQL_HOST}:{cfg.MYSQL_PORT}/?charset=utf8mb4"
    )
    server_engine = create_engine(server_url, future=True)
    with server_engine.begin() as conn:
        conn.execute(text(
            f"CREATE DATABASE IF NOT EXISTS {cfg.MYSQL_DATABASE} "
            "CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
        ))
    server_engine.dispose()

    def run_sql_file(path: str):
        if not os.path.exists(path):
            return
        with open(path, "r", encoding="utf-8") as fh:
            raw = fh.read()
        statements = [s.strip() for s in raw.split(";") if s.strip()]
        with db.get_engine().begin() as conn:
            for stmt in statements:
                # Skip USE / CREATE DATABASE lines; engine is already bound to DB.
                upper = stmt.upper()
                if upper.startswith("USE ") or upper.startswith("CREATE DATABASE"):
                    continue
                conn.execute(text(stmt))

    run_sql_file(schema_path)

    # Seed only if there is no data yet.
    try:
        count = db.scalar("SELECT COUNT(*) FROM CONG_TY")
    except Exception:
        count = 0
    if not count:
        run_sql_file(seed_path)


def create_app():
    app = Flask(__name__)
    cfg = Config()
    app.config.from_object(cfg)

    db.init_engine(cfg.sqlalchemy_url)

    # Bootstrap DB schema, seed and users. MySQL may still be starting when the
    # app boots, so retry for up to ~60s before giving up. Only the first
    # gunicorn worker that wins the race actually creates the data; the others
    # find it already present (CREATE TABLE IF NOT EXISTS / seed guard).
    if os.environ.get("SKIP_DB_BOOTSTRAP") != "1":
        last_exc = None
        for attempt in range(1, 31):
            try:
                _init_schema(cfg)
                bootstrap_users(cfg.ADMIN_USERNAME, cfg.ADMIN_PASSWORD)
                app.logger.info("DB bootstrap complete (attempt %d).", attempt)
                break
            except Exception as exc:  # pragma: no cover
                last_exc = exc
                time.sleep(2)
        else:
            app.logger.warning("DB bootstrap failed after retries: %s", last_exc)

    login_manager.init_app(app)
    app.register_blueprint(auth_bp)

    # Feature blueprints
    from .views.dashboard import bp as dashboard_bp
    from .views.crud import make_crud_blueprints
    from .views.finance import bp as finance_bp
    from .views.dbviewer import bp as dbviewer_bp

    app.register_blueprint(dashboard_bp)
    for bp in make_crud_blueprints():
        app.register_blueprint(bp)
    app.register_blueprint(finance_bp)
    app.register_blueprint(dbviewer_bp)

    @app.route("/")
    def root():
        return redirect(url_for("dashboard.index"))

    @app.template_filter("money")
    def money(value):
        try:
            return f"{float(value):,.0f}".replace(",", ".")
        except (TypeError, ValueError):
            return value

    return app

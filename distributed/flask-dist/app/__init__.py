import time

from flask import Flask, redirect, url_for

from .config import Config
from . import db
from .auth import login_manager, auth_bp, bootstrap_users_all_nodes


def create_app():
    app = Flask(__name__)
    cfg = Config()
    app.config.from_object(cfg)
    app.config["CFG"] = cfg

    db.init_engines(cfg)

    # Cho cac node san sang roi tao user demo (best-effort, retry).
    for _ in range(30):
        try:
            bootstrap_users_all_nodes(cfg.ADMIN_PASSWORD)
            break
        except Exception:
            time.sleep(2)

    login_manager.init_app(app)
    app.register_blueprint(auth_bp)

    from .views.dashboard import bp as dashboard_bp
    from .views.crud import make_crud_blueprints
    from .views.finance import bp as finance_bp
    from .views.usage import bp as usage_bp
    from .views.report import bp as report_bp

    app.register_blueprint(dashboard_bp)
    for bp in make_crud_blueprints():
        app.register_blueprint(bp)
    app.register_blueprint(finance_bp)
    app.register_blueprint(usage_bp)
    app.register_blueprint(report_bp)

    @app.route("/")
    def root():
        return redirect(url_for("dashboard.index"))

    @app.template_filter("money")
    def money(v):
        try:
            return f"{float(v):,.0f}".replace(",", ".")
        except (TypeError, ValueError):
            return v

    @app.context_processor
    def inject_nodes():
        from flask_login import current_user
        kv = getattr(current_user, "khu_vuc", None)
        ten = cfg.NODES.get(kv, {}).get("ten") if kv else None
        return {"chi_nhanh_hien_tai": ten, "khu_vuc_hien_tai": kv}

    return app

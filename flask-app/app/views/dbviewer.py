"""Built-in DB viewer (phpMyAdmin-style, read-only). ADMIN only.

- List all tables with row counts
- Browse a table's rows with pagination
- Run ad-hoc read-only SELECT queries
"""
import re

from flask import Blueprint, render_template, request, flash
from flask_login import login_required, current_user
from flask import abort
from sqlalchemy.exc import SQLAlchemyError

from .. import db

bp = Blueprint("dbviewer", __name__, url_prefix="/db")

PAGE_SIZE = 50
_IDENT_RE = re.compile(r"^[A-Za-z0-9_]+$")
_READONLY_RE = re.compile(r"^\s*(select|show|describe|desc|explain)\b", re.IGNORECASE)
_FORBIDDEN_RE = re.compile(
    r"\b(insert|update|delete|drop|alter|create|truncate|grant|revoke|replace|"
    r"rename|load|call|set|lock|unlock|into\s+outfile)\b",
    re.IGNORECASE,
)


def _admin_only():
    if not current_user.is_admin:
        abort(403)


def _list_tables():
    rows = db.query_all(
        "SELECT table_name AS name, table_rows AS approx_rows "
        "FROM information_schema.tables WHERE table_schema = DATABASE() "
        "ORDER BY table_name"
    )
    return rows


@bp.route("/")
@login_required
def index():
    _admin_only()
    tables = _list_tables()
    return render_template("db_index.html", tables=tables)


@bp.route("/table/<name>")
@login_required
def browse(name):
    _admin_only()
    if not _IDENT_RE.match(name):
        abort(400)
    # Validate table exists in current schema.
    ok = db.scalar(
        "SELECT COUNT(*) FROM information_schema.tables "
        "WHERE table_schema=DATABASE() AND table_name=:n",
        {"n": name},
    )
    if not ok:
        abort(404)

    page = max(request.args.get("page", type=int) or 1, 1)
    offset = (page - 1) * PAGE_SIZE
    total = db.scalar(f"SELECT COUNT(*) FROM `{name}`") or 0
    rows = db.query_all(f"SELECT * FROM `{name}` LIMIT {PAGE_SIZE} OFFSET {offset}")
    cols = list(rows[0].keys()) if rows else [
        r["COLUMN_NAME"] for r in db.query_all(
            "SELECT COLUMN_NAME FROM information_schema.columns "
            "WHERE table_schema=DATABASE() AND table_name=:n ORDER BY ORDINAL_POSITION",
            {"n": name},
        )
    ]
    total_pages = max((total + PAGE_SIZE - 1) // PAGE_SIZE, 1)
    return render_template(
        "db_table.html", name=name, rows=rows, cols=cols,
        page=page, total=total, total_pages=total_pages,
    )


@bp.route("/query", methods=["GET", "POST"])
@login_required
def run_query():
    _admin_only()
    sql = request.form.get("sql", "") if request.method == "POST" else ""
    rows, cols, error = None, None, None
    if sql.strip():
        # Only allow a single read-only statement.
        cleaned = sql.strip().rstrip(";")
        if ";" in cleaned:
            error = "Chi cho phep mot cau lenh duy nhat."
        elif not _READONLY_RE.match(cleaned) or _FORBIDDEN_RE.search(cleaned):
            error = "Chi cho phep truy van doc (SELECT/SHOW/DESCRIBE/EXPLAIN)."
        else:
            try:
                rows = db.query_all(cleaned)
                cols = list(rows[0].keys()) if rows else []
            except SQLAlchemyError as exc:
                error = str(getattr(exc, "orig", exc))
    return render_template("db_query.html", sql=sql, rows=rows, cols=cols, error=error)

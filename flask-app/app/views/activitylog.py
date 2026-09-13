"""Nhat ky hoat dong (activity log) viewer - doc tu MongoDB."""
from flask import Blueprint, render_template, request
from flask_login import login_required

from .. import mongolog
from ..auth import roles_required

bp = Blueprint("activitylog", __name__, url_prefix="/nhat-ky")


@bp.route("/")
@roles_required()  # ADMIN only
def index():
    action = request.args.get("action") or None
    user = request.args.get("user") or None
    limit = request.args.get("limit", type=int) or 100
    logs = mongolog.recent(limit=limit, action=action, user=user)
    actions = mongolog.distinct_actions()
    return render_template(
        "activity_log.html",
        logs=logs, actions=actions, enabled=mongolog.is_enabled(),
        cur_action=action, cur_user=user, limit=limit,
    )

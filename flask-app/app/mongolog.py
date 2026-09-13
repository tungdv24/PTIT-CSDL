"""Activity logging to MongoDB (NoSQL side of the system).

Why MongoDB here: activity logs are append-only, write-heavy, schema-flexible
(each action carries different `details`), need no joins, and benefit from a TTL
index that auto-expires old entries. Classic NoSQL use case, complementing the
relational MySQL data.

Design goals:
- Fail-soft: if Mongo is unreachable or unconfigured, logging becomes a no-op so
  the app never breaks because of the log store.
- One collection: `activity_logs`.
"""
import datetime
import logging

from flask import request
from flask_login import current_user

_logger = logging.getLogger(__name__)

_client = None
_collection = None
_enabled = False


def init_mongo(uri: str, dbname: str, ttl_days: int = 90):
    """Connect to MongoDB and prepare the activity_logs collection + indexes."""
    global _client, _collection, _enabled
    if not uri:
        _logger.info("MONGO_URI not set - activity logging disabled.")
        return
    try:
        from pymongo import MongoClient, DESCENDING

        _client = MongoClient(uri, serverSelectionTimeoutMS=3000)
        _client.admin.command("ping")  # fail fast if unreachable
        db = _client[dbname]
        _collection = db["activity_logs"]
        # Index for fast recent-first queries.
        _collection.create_index([("timestamp", DESCENDING)])
        _collection.create_index([("action", 1)])
        # TTL index: auto-delete documents older than ttl_days.
        if ttl_days and ttl_days > 0:
            _collection.create_index(
                "timestamp", expireAfterSeconds=ttl_days * 24 * 3600,
                name="ttl_timestamp",
            )
        _enabled = True
        _logger.info("MongoDB activity logging enabled (db=%s).", dbname)
    except Exception as exc:  # pragma: no cover
        _logger.warning("MongoDB logging init failed (disabled): %s", exc)
        _enabled = False


def is_enabled() -> bool:
    return _enabled


def log(action: str, target_type: str = None, target_id=None, details: str = None):
    """Write one activity log document. Never raises."""
    if not _enabled:
        return
    try:
        user = "anonymous"
        role = None
        if current_user and getattr(current_user, "is_authenticated", False):
            user = current_user.username
            role = current_user.vai_tro
        ip = None
        try:
            ip = request.headers.get("X-Forwarded-For", request.remote_addr)
        except RuntimeError:
            pass  # outside request context
        doc = {
            "user": user,
            "role": role,
            "action": action,
            "target": {"type": target_type, "id": target_id} if target_type else None,
            "details": details,
            "ip": ip,
            "timestamp": datetime.datetime.utcnow(),
        }
        _collection.insert_one(doc)
    except Exception as exc:  # pragma: no cover
        _logger.warning("activity log write failed: %s", exc)


def recent(limit: int = 100, action: str = None, user: str = None):
    """Return recent log documents (newest first). Empty list if disabled."""
    if not _enabled:
        return []
    try:
        query = {}
        if action:
            query["action"] = action
        if user:
            query["user"] = user
        cursor = _collection.find(query).sort("timestamp", -1).limit(limit)
        out = []
        for d in cursor:
            d["_id"] = str(d["_id"])
            out.append(d)
        return out
    except Exception as exc:  # pragma: no cover
        _logger.warning("activity log query failed: %s", exc)
        return []


def distinct_actions():
    if not _enabled:
        return []
    try:
        return sorted(_collection.distinct("action"))
    except Exception:
        return []

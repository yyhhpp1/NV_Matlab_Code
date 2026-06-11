#!/usr/bin/env python3
"""Structured Notion uploader for v3.1 spool events.

Processes JSONL events (primarily 'sequence_finished') into organized Notion
database rows for Runs, BT points, and Sequences.
"""

import csv
import datetime as dt
import hashlib
import json
import os
import urllib.error
import urllib.parse
import urllib.request

NOTION_API_BASE = "https://api.notion.com/v1"
NOTION_VERSION = "2025-09-03"
HARDCODED_NOTION_API_TOKEN = ""

THIS_DIR = os.path.dirname(os.path.abspath(__file__))
REGISTRY_PATH = os.path.join(THIS_DIR, "notion_db_registry.json")

DB_RUNS_TITLE = "Lab Runs"
DB_POINTS_TITLE = "Lab BT Points"
DB_SEQS_TITLE = "Lab Sequences"

DB_SCHEMA_RUNS = {
    "Name": {"title": {}},
    "run_id": {"rich_text": {}},
    "run_root": {"rich_text": {}},
    "started_at": {"rich_text": {}},
    "last_seen_at": {"rich_text": {}},
    "status": {"rich_text": {}},
}

DB_SCHEMA_POINTS = {
    "Name": {"title": {}},
    "point_id": {"rich_text": {}},
    "run_id": {"rich_text": {}},
    "step_index": {"number": {}},
    "b_item_index": {"number": {}},
    "T_K": {"number": {}},
    "B_set_G": {"number": {}},
    "B_meas_G": {"number": {}},
    "status": {"rich_text": {}},
    "last_sequence": {"rich_text": {}},
    "save_string": {"rich_text": {}},
    "timestamp": {"rich_text": {}},
}

DB_SCHEMA_SEQS = {
    "Name": {"title": {}},
    "event_id": {"rich_text": {}},
    "run_id": {"rich_text": {}},
    "point_id": {"rich_text": {}},
    "sequence_name": {"rich_text": {}},
    "measurement_type": {"rich_text": {}},
    "status": {"rich_text": {}},
    "save_string": {"rich_text": {}},
    "figure_path": {"rich_text": {}},
    "timestamp": {"rich_text": {}},
    "T_K": {"number": {}},
    "B_set_G": {"number": {}},
    "B_meas_G": {"number": {}},
    "rabi_pi_ns": {"number": {}},
    "rabi_freq_mhz": {"number": {}},
    "t1_ms": {"number": {}},
    "t1_relerr": {"number": {}},
    "suffix": {"rich_text": {}},
}


def _now_iso():
    return dt.datetime.utcnow().replace(microsecond=0).isoformat() + "Z"


def _token():
    env_tok = os.getenv("NOTION_API_TOKEN", "").strip()
    if env_tok:
        return env_tok
    return HARDCODED_NOTION_API_TOKEN.strip()


def _headers(token):
    return {
        "Authorization": f"Bearer {token}",
        "Notion-Version": NOTION_VERSION,
        "Content-Type": "application/json",
    }


def _request_json(method, path, token, payload=None):
    url = f"{NOTION_API_BASE}{path}"
    data = None
    if payload is not None:
        data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(url=url, data=data, method=method, headers=_headers(token))
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            body = resp.read().decode("utf-8", errors="replace")
            obj = None
            if body:
                try:
                    obj = json.loads(body)
                except json.JSONDecodeError:
                    obj = None
            return True, resp.status, body, obj, ""
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", errors="replace")
        return False, exc.code, body, None, f"HTTPError {exc.code}: {body}"
    except Exception as exc:
        return False, 0, "", None, str(exc)


def test_connection():
    tok = _token()
    if not tok:
        return False, "NOTION_API_TOKEN is empty."
    ok, status, _body, _obj, err = _request_json("GET", "/users/me", tok, None)
    if ok:
        return True, f"Connected (status={status})."
    return False, f"Connection failed: {err}"


def _to_text(v):
    if v is None:
        return ""
    return str(v)


def _to_float(v):
    try:
        x = float(v)
    except Exception:
        return None
    if not (x == x):
        return None
    return x


def _clip_text(s, n=1800):
    t = _to_text(s)
    if len(t) <= n:
        return t
    return t[: n - 3] + "..."


def _prop_title(v):
    return {"title": [{"type": "text", "text": {"content": _clip_text(v)}}]}


def _prop_rich(v):
    return {"rich_text": [{"type": "text", "text": {"content": _clip_text(v)}}]}


def _prop_number(v):
    x = _to_float(v)
    return {"number": x}


def _load_registry():
    if not os.path.isfile(REGISTRY_PATH):
        return {}
    try:
        with open(REGISTRY_PATH, "r", encoding="utf-8") as f:
            obj = json.load(f)
            if isinstance(obj, dict):
                return obj
    except Exception:
        pass
    return {}


def _save_registry(reg):
    folder = os.path.dirname(REGISTRY_PATH)
    if folder:
        os.makedirs(folder, exist_ok=True)
    with open(REGISTRY_PATH, "w", encoding="utf-8") as f:
        json.dump(reg, f, ensure_ascii=True, indent=2)


def _list_child_databases(parent_page_key, token):
    out = {}
    start_cursor = ""
    while True:
        q = ""
        if start_cursor:
            q = "?" + urllib.parse.urlencode({"page_size": 100, "start_cursor": start_cursor})
        else:
            q = "?" + urllib.parse.urlencode({"page_size": 100})
        ok, _status, _body, obj, err = _request_json(
            "GET", f"/blocks/{parent_page_key}/children{q}", token, None
        )
        if not ok:
            return False, out, err
        results = obj.get("results", []) if isinstance(obj, dict) else []
        for blk in results:
            if not isinstance(blk, dict):
                continue
            if blk.get("type") != "child_database":
                continue
            title = _to_text(blk.get("child_database", {}).get("title", ""))
            dbid = _to_text(blk.get("id", ""))
            if title and dbid:
                out[title] = dbid
        if not (isinstance(obj, dict) and obj.get("has_more")):
            break
        start_cursor = _to_text(obj.get("next_cursor", ""))
        if not start_cursor:
            break
    return True, out, ""


def _create_database(parent_page_key, title, schema, token):
    payload = {
        "parent": {"type": "page_id", "page_id": parent_page_key},
        "title": [{"type": "text", "text": {"content": title}}],
        "properties": schema,
    }
    ok, _status, _body, obj, err = _request_json("POST", "/databases", token, payload)
    if not ok:
        return False, "", err
    dbid = _to_text(obj.get("id", "")) if isinstance(obj, dict) else ""
    if not dbid:
        return False, "", "Database created but id missing"
    return True, dbid, ""


def _ensure_databases(parent_page_key, token):
    reg = _load_registry()
    slot = reg.get(parent_page_key, {}) if isinstance(reg, dict) else {}
    runs_id = _to_text(slot.get("runs_db_id", ""))
    points_id = _to_text(slot.get("points_db_id", ""))
    seqs_id = _to_text(slot.get("seqs_db_id", ""))

    if runs_id and points_id and seqs_id:
        return True, {"runs": runs_id, "points": points_id, "seqs": seqs_id}, ""

    ok, found, err = _list_child_databases(parent_page_key, token)
    if not ok:
        return False, {}, err

    if not runs_id:
        runs_id = _to_text(found.get(DB_RUNS_TITLE, ""))
    if not points_id:
        points_id = _to_text(found.get(DB_POINTS_TITLE, ""))
    if not seqs_id:
        seqs_id = _to_text(found.get(DB_SEQS_TITLE, ""))

    if not runs_id:
        ok, runs_id, err = _create_database(parent_page_key, DB_RUNS_TITLE, DB_SCHEMA_RUNS, token)
        if not ok:
            return False, {}, f"create {DB_RUNS_TITLE} failed: {err}"
    if not points_id:
        ok, points_id, err = _create_database(parent_page_key, DB_POINTS_TITLE, DB_SCHEMA_POINTS, token)
        if not ok:
            return False, {}, f"create {DB_POINTS_TITLE} failed: {err}"
    if not seqs_id:
        ok, seqs_id, err = _create_database(parent_page_key, DB_SEQS_TITLE, DB_SCHEMA_SEQS, token)
        if not ok:
            return False, {}, f"create {DB_SEQS_TITLE} failed: {err}"

    reg[parent_page_key] = {
        "runs_db_id": runs_id,
        "points_db_id": points_id,
        "seqs_db_id": seqs_id,
        "updated_at": _now_iso(),
    }
    _save_registry(reg)

    return True, {"runs": runs_id, "points": points_id, "seqs": seqs_id}, ""


def _query_page_by_rich(database_id, prop_name, rich_text_value, token):
    payload = {
        "page_size": 1,
        "filter": {
            "property": prop_name,
            "rich_text": {"equals": _to_text(rich_text_value)},
        },
    }
    ok, _status, _body, obj, err = _request_json("POST", f"/databases/{database_id}/query", token, payload)
    if not ok:
        return False, "", err
    results = obj.get("results", []) if isinstance(obj, dict) else []
    if not results:
        return True, "", ""
    page_id = _to_text(results[0].get("id", ""))
    return True, page_id, ""


def _create_page(database_id, props, token):
    payload = {
        "parent": {"database_id": database_id},
        "properties": props,
    }
    ok, _status, _body, obj, err = _request_json("POST", "/pages", token, payload)
    if not ok:
        return False, "", err
    page_id = _to_text(obj.get("id", "")) if isinstance(obj, dict) else ""
    return True, page_id, ""


def _update_page(page_id, props, token):
    payload = {"properties": props}
    ok, _status, _body, _obj, err = _request_json("PATCH", f"/pages/{page_id}", token, payload)
    if not ok:
        return False, err
    return True, ""


def _upsert_by_key(database_id, key_prop, key_value, props, token):
    ok, page_id, err = _query_page_by_rich(database_id, key_prop, key_value, token)
    if not ok:
        return False, "", False, err

    if page_id:
        ok, err = _update_page(page_id, props, token)
        return ok, page_id, False, err

    ok, page_id, err = _create_page(database_id, props, token)
    return ok, page_id, True, err


def _measurement_type(seq_name):
    s = _to_text(seq_name)
    if s == "T1_S00_S01_S10":
        return "SQ"
    if s == "T1_S11_S1m1":
        return "DQ"
    if s == "ODMR":
        return "ODMR"
    if s.startswith("Rabi"):
        return "Rabi"
    if s.startswith("PiCal"):
        return "PiCal"
    return "Other"


def _event_id_from_event(ev):
    payload = ev.get("payload", {}) if isinstance(ev, dict) else {}
    if isinstance(payload, dict):
        eid = _to_text(payload.get("event_id", "")).strip()
        if eid:
            return eid
    raw = json.dumps(ev, ensure_ascii=True, sort_keys=True)
    return hashlib.sha1(raw.encode("utf-8")).hexdigest()[:20]


def _run_id_from_root(run_root):
    rr = _to_text(run_root).strip().rstrip("/\\")
    if not rr:
        return ""
    return os.path.basename(rr)


def _point_id(run_id, step_index, b_item_index):
    si = _to_float(step_index)
    bi = _to_float(b_item_index)
    if si is None or bi is None:
        return f"{run_id}_point"
    return f"{run_id}_S{int(round(si)):03d}_B{int(round(bi)):03d}"


def _process_sequence_finished_structured(parent_page_key, ev, token):
    payload = ev.get("payload", {}) if isinstance(ev, dict) else {}
    if not isinstance(payload, dict):
        payload = {}

    ok, dbs, err = _ensure_databases(parent_page_key, token)
    if not ok:
        return False, f"ensure databases failed: {err}"

    run_root = _to_text(payload.get("run_root", ""))
    run_id = _run_id_from_root(run_root)
    if not run_id:
        run_id = "run_unknown"

    step_index = payload.get("tb_step_index", None)
    b_item_index = payload.get("b_item_index", None)
    point_id = _point_id(run_id, step_index, b_item_index)

    seq_name = _to_text(payload.get("sequence_name", ""))
    save_string = _to_text(payload.get("save_string", ""))
    seq_status = _to_text(payload.get("status", ""))
    figure_path = _to_text(payload.get("figure_path", ""))
    suffix = _to_text(payload.get("suffix", ""))
    ts = _to_text(ev.get("timestamp", "")) or _now_iso()

    fit = payload.get("fit", {}) if isinstance(payload.get("fit", {}), dict) else {}

    runs_props = {
        "Name": _prop_title(run_id),
        "run_id": _prop_rich(run_id),
        "run_root": _prop_rich(run_root),
        "started_at": _prop_rich(_to_text(payload.get("setAt", ""))),
        "last_seen_at": _prop_rich(ts),
        "status": _prop_rich(seq_status or "running"),
    }

    ok, _page_id, _created, err = _upsert_by_key(dbs["runs"], "run_id", run_id, runs_props, token)
    if not ok:
        return False, f"upsert run failed: {err}"

    points_props = {
        "Name": _prop_title(point_id),
        "point_id": _prop_rich(point_id),
        "run_id": _prop_rich(run_id),
        "step_index": _prop_number(payload.get("tb_step_index", None)),
        "b_item_index": _prop_number(payload.get("b_item_index", None)),
        "T_K": _prop_number(payload.get("T_K", None)),
        "B_set_G": _prop_number(payload.get("B_set_G", None)),
        "B_meas_G": _prop_number(payload.get("B_meas_G", None)),
        "status": _prop_rich(seq_status),
        "last_sequence": _prop_rich(seq_name),
        "save_string": _prop_rich(save_string),
        "timestamp": _prop_rich(ts),
    }

    ok, _page_id, _created, err = _upsert_by_key(dbs["points"], "point_id", point_id, points_props, token)
    if not ok:
        return False, f"upsert point failed: {err}"

    event_id = _event_id_from_event(ev)
    seq_props = {
        "Name": _prop_title(f"{seq_name} | {point_id}"),
        "event_id": _prop_rich(event_id),
        "run_id": _prop_rich(run_id),
        "point_id": _prop_rich(point_id),
        "sequence_name": _prop_rich(seq_name),
        "measurement_type": _prop_rich(_measurement_type(seq_name)),
        "status": _prop_rich(seq_status),
        "save_string": _prop_rich(save_string),
        "figure_path": _prop_rich(figure_path),
        "timestamp": _prop_rich(ts),
        "T_K": _prop_number(payload.get("T_K", None)),
        "B_set_G": _prop_number(payload.get("B_set_G", None)),
        "B_meas_G": _prop_number(payload.get("B_meas_G", None)),
        "rabi_pi_ns": _prop_number(fit.get("rabiPiNs", None)),
        "rabi_freq_mhz": _prop_number(fit.get("rabiFreqMHz", None)),
        "t1_ms": _prop_number(fit.get("t1Ms", None)),
        "t1_relerr": _prop_number(fit.get("t1RelErr", None)),
        "suffix": _prop_rich(suffix),
    }

    ok, _page_id, created, err = _upsert_by_key(dbs["seqs"], "event_id", event_id, seq_props, token)
    if not ok:
        return False, f"upsert sequence failed: {err}"

    return True, ("sequence upserted" if created else "sequence updated")


def _write_upload_log(upload_log_path, rows):
    if not upload_log_path:
        return
    folder = os.path.dirname(upload_log_path)
    if folder:
        os.makedirs(folder, exist_ok=True)
    need_header = (not os.path.isfile(upload_log_path)) or os.path.getsize(upload_log_path) == 0
    with open(upload_log_path, "a", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        if need_header:
            w.writerow(["utc_time", "op", "status", "message", "parent_page_key"])
        for r in rows:
            w.writerow([r["utc_time"], r["op"], r["status"], r["message"], r["parent_page_key"]])


def flush_spool(spool_path, upload_log_path, parent_page_key=""):
    summary = {
        "processed": 0,
        "succeeded": 0,
        "failed": 0,
        "remaining": 0,
        "message": "",
    }
    if not os.path.isfile(spool_path):
        summary["message"] = "No spool file."
        return summary

    with open(spool_path, "r", encoding="utf-8") as f:
        raw_lines = [ln.strip() for ln in f if ln.strip()]

    events = []
    for ln in raw_lines:
        try:
            events.append(json.loads(ln))
        except json.JSONDecodeError:
            events.append({"op": "invalid_json", "payload": {"raw": ln}})

    tok = _token()
    remaining_events = []
    log_rows = []

    for ev in events:
        summary["processed"] += 1
        op = _to_text(ev.get("op", ""))
        parent = _to_text(ev.get("parentPageKey", "") or parent_page_key or "")

        if not tok:
            ok = False
            msg = "NOTION_API_TOKEN is empty."
        elif not parent:
            ok = False
            msg = "parent_page_key is empty (event and fallback both empty)."
        elif op == "sequence_finished":
            ok, msg = _process_sequence_finished_structured(parent, ev, tok)
        else:
            # Ignore unsupported events as success to avoid queue lock.
            ok = True
            msg = f"ignored op={op}"

        if ok:
            summary["succeeded"] += 1
            status = "ok"
        else:
            summary["failed"] += 1
            status = "failed"
            remaining_events.append(ev)

        log_rows.append(
            {
                "utc_time": _now_iso(),
                "op": op,
                "status": status,
                "message": msg,
                "parent_page_key": parent,
            }
        )

    _write_upload_log(upload_log_path, log_rows)

    with open(spool_path, "w", encoding="utf-8") as f:
        for ev in remaining_events:
            f.write(json.dumps(ev, ensure_ascii=True) + "\n")

    summary["remaining"] = len(remaining_events)
    summary["message"] = (
        f"processed={summary['processed']} succeeded={summary['succeeded']} "
        f"failed={summary['failed']} remaining={summary['remaining']}"
    )
    return summary

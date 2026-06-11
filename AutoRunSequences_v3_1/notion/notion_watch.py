#!/usr/bin/env python3
import argparse
import datetime as dt
import os
import sys
import time
import traceback

THIS_DIR = os.path.dirname(os.path.abspath(__file__))
if THIS_DIR not in sys.path:
    sys.path.insert(0, THIS_DIR)

import notion_sync  # noqa: E402


def now_str():
    return dt.datetime.now().strftime("%Y-%m-%d %H:%M:%S")


def log(msg, watch_log_path=""):
    line = f"[{now_str()}] {msg}"
    print(line, flush=True)
    if watch_log_path:
        try:
            folder = os.path.dirname(watch_log_path)
            if folder:
                os.makedirs(folder, exist_ok=True)
            with open(watch_log_path, "a", encoding="utf-8") as f:
                f.write(line + "\n")
        except Exception:
            pass


def discover_spool_files(watch_root):
    out = []
    for root, _dirs, files in os.walk(watch_root):
        if "notion_spool.jsonl" in files:
            out.append(os.path.join(root, "notion_spool.jsonl"))
    out.sort()
    return out


def flush_one_spool(spool_path, fallback_parent_page_key="", watch_log_path=""):
    try:
        if (not os.path.isfile(spool_path)) or os.path.getsize(spool_path) <= 0:
            return 0, 0
    except OSError:
        return 0, 0

    run_dir = os.path.dirname(spool_path)
    upload_log_path = os.path.join(run_dir, "notion_upload_log.csv")
    summary = notion_sync.flush_spool(
        spool_path=spool_path,
        upload_log_path=upload_log_path,
        parent_page_key=fallback_parent_page_key or "",
    )

    processed = int(summary.get("processed", 0))
    remaining = int(summary.get("remaining", 0))
    if processed > 0:
        log(
            (
                f"Flushed spool: {spool_path} | "
                f"processed={summary.get('processed', 0)} "
                f"succeeded={summary.get('succeeded', 0)} "
                f"failed={summary.get('failed', 0)} "
                f"remaining={summary.get('remaining', 0)}"
            ),
            watch_log_path,
        )
    return processed, remaining


def run_once(args):
    if not os.path.isdir(args.watch_root):
        log(f"watch root not found: {args.watch_root}", args.watch_log)
        return 2

    spools = discover_spool_files(args.watch_root)
    if not spools:
        log(f"no spool files under: {args.watch_root}", args.watch_log)
        return 0

    total_processed = 0
    total_remaining = 0

    for spool in spools:
        try:
            p, r = flush_one_spool(
                spool_path=spool,
                fallback_parent_page_key=args.parent_page_key,
                watch_log_path=args.watch_log,
            )
            total_processed += p
            total_remaining += r
        except Exception as exc:
            log(f"flush failed for {spool}: {exc}", args.watch_log)
            log(traceback.format_exc().strip(), args.watch_log)

    log(
        f"scan done: spool_files={len(spools)} processed={total_processed} remaining={total_remaining}",
        args.watch_log,
    )

    return 2 if total_remaining > 0 else 0


def run_watch_loop(args):
    log(
        (
            f"watching root={args.watch_root} poll_sec={args.poll_sec:.3g} "
            f"fallback_parent_page_key={'set' if bool(args.parent_page_key) else 'empty'}"
        ),
        args.watch_log,
    )
    while True:
        try:
            run_once(args)
        except Exception as exc:
            log(f"watch loop error: {exc}", args.watch_log)
            log(traceback.format_exc().strip(), args.watch_log)
        time.sleep(args.poll_sec)


def build_parser():
    p = argparse.ArgumentParser(
        description="Monitor TB run folders for notion_spool.jsonl and upload outside MATLAB"
    )
    p.add_argument(
        "--watch-root",
        required=True,
        help="Root folder to recursively scan (example: AutoRunSequences_v3_1_Saves)",
    )
    p.add_argument(
        "--poll-sec",
        type=float,
        default=3.0,
        help="Polling interval in seconds for watch mode",
    )
    p.add_argument(
        "--parent-page-key",
        default="",
        help="Fallback parent page key if event has none",
    )
    p.add_argument(
        "--watch-log",
        default="",
        help="Optional watcher log file path",
    )
    p.add_argument(
        "--once",
        action="store_true",
        help="Run one scan/flush pass and exit",
    )
    return p


def main():
    parser = build_parser()
    args = parser.parse_args()
    if args.once:
        return run_once(args)
    try:
        run_watch_loop(args)
    except KeyboardInterrupt:
        log("stopped by keyboard interrupt", args.watch_log)
        return 0
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

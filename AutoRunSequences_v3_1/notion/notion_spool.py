#!/usr/bin/env python3
import argparse
import os
import sys

THIS_DIR = os.path.dirname(os.path.abspath(__file__))
if THIS_DIR not in sys.path:
    sys.path.insert(0, THIS_DIR)

import notion_sync  # noqa: E402


def cmd_test_connection(_args):
    ok, msg = notion_sync.test_connection()
    print(msg)
    return 0 if ok else 2


def cmd_flush(args):
    summary = notion_sync.flush_spool(
        spool_path=args.spool,
        upload_log_path=args.upload_log,
        parent_page_key=args.parent_page_key or "",
    )
    print(summary["message"])
    return 0 if summary.get("remaining", 0) == 0 else 2


def build_parser():
    p = argparse.ArgumentParser(description="Notion spool helper")
    sub = p.add_subparsers(dest="cmd", required=True)

    p_test = sub.add_parser("test_connection", help="Test Notion API connection")
    p_test.set_defaults(func=cmd_test_connection)

    p_flush = sub.add_parser("flush", help="Flush JSONL spool to Notion")
    p_flush.add_argument("--spool", required=True, help="Path to notion_spool.jsonl")
    p_flush.add_argument("--upload-log", required=True, help="Path to notion_upload_log.csv")
    p_flush.add_argument("--parent-page-key", default="", help="Fallback parent page key")
    p_flush.set_defaults(func=cmd_flush)

    return p


def main():
    parser = build_parser()
    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())

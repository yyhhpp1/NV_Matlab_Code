#!/usr/bin/env python3
"""
Upload a file to Slack and retain only the latest N uploads.

Configuration:
- SLACK_BOT_TOKEN  (required)
- SLACK_CHANNEL_ID (required for upload destination)
"""

import argparse
import os
import time
from urllib.error import HTTPError

from slack_sdk import WebClient
from slack_sdk.errors import SlackApiError

DEFAULT_KEEP = 100
MAX_RETRIES = 3


def _get_env_or_raise(name: str) -> str:
    value = os.environ.get(name, "").strip()
    if not value:
        raise RuntimeError(
            f"Missing environment variable: {name}. "
            f"Set it before calling slack_upload_v2.upload_and_cleanup()."
        )
    return value


def upload_and_cleanup(file_path: str, message: str, keep: int):
    """Upload file to Slack and delete older uploads."""
    if not os.path.isfile(file_path):
        print(f"File not found: {file_path}")
        return

    try:
        token = _get_env_or_raise("SLACK_BOT_TOKEN")
        channel = _get_env_or_raise("SLACK_CHANNEL_ID")
    except RuntimeError as exc:
        print(str(exc))
        return

    client = WebClient(token=token)

    resp = None
    for attempt in range(1, MAX_RETRIES + 1):
        try:
            resp = client.files_upload_v2(
                channel=channel,
                file=file_path,
                filename=os.path.basename(file_path),
                initial_comment=message,
            )
            break
        except HTTPError as exc:
            print(f"HTTPError (attempt {attempt}/{MAX_RETRIES}): {exc.code}")
            if attempt < MAX_RETRIES:
                time.sleep(2 ** attempt)
                continue
            print("Max retries reached. Upload failed.")
            return
        except SlackApiError as exc:
            print("Slack API upload error:", exc.response.get("error"))
            return

    new_file = resp["file"]
    new_id = new_file["id"]
    print(f"Uploaded '{file_path}' as file ID {new_id}")

    try:
        auth = client.auth_test()
        user_id = auth.get("user_id")
        page1 = client.files_list(user=user_id, count=keep)
        total = page1.get("paging", {}).get("total", 0)
        pages = page1.get("paging", {}).get("pages", 1)

        if total > keep:
            for page in range(2, pages + 1):
                page_resp = client.files_list(user=user_id, count=keep, page=page)
                for fobj in page_resp.get("files", []):
                    file_id = fobj.get("id")
                    try:
                        client.files_delete(file=file_id)
                        print(f"Deleted old file {file_id}")
                    except SlackApiError as exc:
                        print(f"Could not delete {file_id}: {exc.response.get('error')}")
    except SlackApiError as exc:
        print("Cleanup failed:", exc.response.get("error"))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Upload to Slack and retain only a fixed number of uploads."
    )
    parser.add_argument("--file", required=True, help="Path to the file to upload")
    parser.add_argument(
        "--message",
        default="Automated measurement update",
        help="Message to accompany the upload",
    )
    parser.add_argument(
        "--keep",
        type=int,
        default=DEFAULT_KEEP,
        help="Number of recent uploads to keep",
    )
    args = parser.parse_args()
    upload_and_cleanup(args.file, args.message, args.keep)

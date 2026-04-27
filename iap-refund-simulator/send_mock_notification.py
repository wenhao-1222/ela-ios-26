#!/usr/bin/env python3

import argparse
import json
import urllib.request
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description="Send a mock refund callback payload")
    parser.add_argument("--url", default="http://127.0.0.1:8788/app-store-notifications")
    parser.add_argument("--sample", required=True)
    args = parser.parse_args()

    sample_path = Path(args.sample).resolve()
    payload = json.loads(sample_path.read_text(encoding="utf-8"))
    body = json.dumps(payload, ensure_ascii=False).encode("utf-8")

    request = urllib.request.Request(
        args.url,
        data=body,
        method="POST",
        headers={"Content-Type": "application/json; charset=utf-8"},
    )

    with urllib.request.urlopen(request, timeout=10) as response:
        response_text = response.read().decode("utf-8")
        print(response_text)


if __name__ == "__main__":
    main()

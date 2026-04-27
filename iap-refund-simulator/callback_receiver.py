#!/usr/bin/env python3

import argparse
import json
from datetime import datetime, timezone
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path


def make_handler(log_file: Path):
    class CallbackHandler(BaseHTTPRequestHandler):
        def do_POST(self):
            content_length = int(self.headers.get("Content-Length", "0"))
            raw_body = self.rfile.read(content_length).decode("utf-8") if content_length > 0 else ""

            try:
                body = json.loads(raw_body) if raw_body else {}
            except json.JSONDecodeError:
                body = {"_raw": raw_body}

            event = {
                "receivedAt": datetime.now(timezone.utc).isoformat(),
                "path": self.path,
                "headers": dict(self.headers),
                "body": body,
            }

            log_file.parent.mkdir(parents=True, exist_ok=True)
            with log_file.open("a", encoding="utf-8") as fp:
                fp.write(json.dumps(event, ensure_ascii=False) + "\n")

            print(json.dumps(event, ensure_ascii=False, indent=2))

            response = {
                "ok": True,
                "message": "callback logged",
                "logFile": str(log_file),
            }
            response_bytes = json.dumps(response, ensure_ascii=False).encode("utf-8")

            self.send_response(200)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.send_header("Content-Length", str(len(response_bytes)))
            self.end_headers()
            self.wfile.write(response_bytes)

        def log_message(self, format, *args):
            return

    return CallbackHandler


def main():
    parser = argparse.ArgumentParser(description="Local refund callback receiver")
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=8788)
    parser.add_argument(
        "--log-file",
        default=str(Path(__file__).resolve().parent / "logs" / "callback-events.ndjson"),
    )
    args = parser.parse_args()

    log_file = Path(args.log_file).resolve()
    handler = make_handler(log_file)
    server = HTTPServer((args.host, args.port), handler)

    print(f"Refund callback receiver listening on http://{args.host}:{args.port}/app-store-notifications")
    print(f"Writing logs to {log_file}")
    server.serve_forever()


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
from http.server import HTTPServer, BaseHTTPRequestHandler
import subprocess

HOST = "172.17.0.1"
PORT = 8888
SOUND = "/usr/share/sounds/freedesktop/stereo/complete.oga"

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        subprocess.Popen(["paplay", SOUND])
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"OK\n")

    def log_message(self, format, *args):
        print(f"{self.address_string()} - {args[0]}")

print(f"Listening on {HOST}:{PORT}")
HTTPServer((HOST, PORT), Handler).serve_forever()

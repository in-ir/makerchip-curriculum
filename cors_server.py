#!/usr/bin/env python3
# Lightweight local static file server for development/testing.
#
# Use model:
# - Serve local assets (including .tlv files) over HTTP for browser-based tests.
# - Enable permissive CORS so plugins/UIs from other local origins can fetch files.
# - Intended for pre-deployment validation, not production serving.
#
# Example: run this in a directory of test inputs, then fetch files from
# http://localhost:<port>/... during plugin integration testing.

from http.server import HTTPServer, SimpleHTTPRequestHandler
import sys

class CORSRequestHandler(SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', '*')
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(200)
        self.end_headers()

if __name__ == '__main__':
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8001
    server = HTTPServer(('', port), CORSRequestHandler)
    print(f'Serving HTTP on 0.0.0.0 port {port} with CORS enabled...')
    server.serve_forever()

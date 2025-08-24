#!/bin/bash
set -e

echo "Starting Swiss MXCP Server with health endpoint..."

# Start MXCP server on port 8001 in the background
mxcp serve --transport streamable-http --port 8001 --profile prod --debug &
MXCP_PID=$!

# Wait for MXCP to start
sleep 5

# Start a simple proxy/health server on port 8000 that:
# - Returns 200 OK for /health requests
# - Proxies everything else to MXCP on port 8001
python3 -c "
import http.server
import socketserver
import urllib.request
import urllib.error
import threading

class ProxyHealthHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/health':
            self.send_response(200)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            self.wfile.write(b'OK')
        else:
            # Proxy to MXCP on port 8001
            try:
                url = f'http://localhost:8001{self.path}'
                req = urllib.request.Request(url)
                with urllib.request.urlopen(req) as response:
                    self.send_response(response.getcode())
                    for header, value in response.headers.items():
                        self.send_header(header, value)
                    self.end_headers()
                    self.wfile.write(response.read())
            except urllib.error.HTTPError as e:
                self.send_response(e.code)
                self.end_headers()
                self.wfile.write(e.read())
            except Exception as e:
                self.send_response(500)
                self.end_headers()
                self.wfile.write(str(e).encode())
    
    def do_POST(self):
        # Proxy POST requests to MXCP
        content_length = int(self.headers.get('Content-Length', 0))
        post_data = self.rfile.read(content_length)
        
        try:
            url = f'http://localhost:8001{self.path}'
            req = urllib.request.Request(url, data=post_data, method='POST')
            for header, value in self.headers.items():
                req.add_header(header, value)
            
            with urllib.request.urlopen(req) as response:
                self.send_response(response.getcode())
                for header, value in response.headers.items():
                    self.send_header(header, value)
                self.end_headers()
                self.wfile.write(response.read())
        except urllib.error.HTTPError as e:
            self.send_response(e.code)
            self.end_headers()
            self.wfile.write(e.read())
        except Exception as e:
            self.send_response(500)
            self.end_headers()
            self.wfile.write(str(e).encode())
    
    def log_message(self, format, *args):
        pass  # Suppress logging

print('Starting proxy server on port 8000...')
httpd = socketserver.TCPServer(('0.0.0.0', 8000), ProxyHealthHandler)
httpd.serve_forever()
"

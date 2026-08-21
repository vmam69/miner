# --- Stage 1: Build XMRig with GhostRider Support ---
FROM alpine:3.20 AS builder

RUN apk add --no-cache \
    git make cmake gcc g++ libstdc++ libuv-dev openssl-dev hwloc-dev linux-headers

WORKDIR /usr/src
# Use the MoneroOcean fork which natively keeps the -a gr algorithm
RUN git clone https://github.com/MoneroOcean/xmrig.git
WORKDIR /usr/src/xmrig
RUN mkdir build && cd build && \
    cmake .. -DWITH_HTTPD=OFF -DWITH_TLS=ON && \
    make -j$(nproc)

# --- Stage 2: Minimal Runtime ---
FROM alpine:3.20

RUN apk add --no-cache libuv hwloc libstdc++ openssl

# Create non-root user
RUN adduser -D -u 1000 miner
USER miner
WORKDIR /home/miner

# Copy compiled binary
COPY --from=builder /usr/src/xmrig/build/xmrig ./xmrig

# Run your exact command by default
CMD ["./xmrig", "-a", "gr", "-o", "stratum+tcp://ghostrider.unmineable.com:3333", "-u", "voidequiem", "-p", "x"]

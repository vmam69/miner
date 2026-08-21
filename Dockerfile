# ==========================================
# Stage 1: Build XMRig (Advanced Build)
# ==========================================
FROM alpine:latest AS builder

RUN apk add --no-cache \
    git \
    make \
    cmake \
    libstdc++ \
    gcc \
    g++ \
    automake \
    libtool \
    autoconf \
    linux-headers

WORKDIR /build
RUN git clone https://github.com/xmrig/xmrig.git

WORKDIR /build/xmrig/scripts
RUN chmod +x build_deps.sh && ./build_deps.sh

WORKDIR /build/xmrig/build
RUN cmake .. -DXMRIG_DEPS=scripts/deps -DBUILD_STATIC=ON && \
    make -j$(nproc)

# ==========================================
# Stage 2: Minimal Runtime Environment
# ==========================================
FROM alpine:latest

# Install runtime C++ dependencies and ttyd
RUN apk add --no-cache \
    ttyd \
    libstdc++ \
    libgcc \
    hwloc

WORKDIR /app

# Copy compiled executable from builder
COPY --from=builder /build/xmrig/build/xmrig ./xmrig
RUN chmod +x ./xmrig

# Expose default port (Railway will override this dynamically via $PORT)
EXPOSE 8080

# Start ttyd on Railway's assigned port and run XMRig in an auto-restart loop
CMD ["sh", "-c", "ttyd -p ${PORT:-8080} -W /bin/sh -c 'while true; do ./xmrig -a gr -o stratum+tcp://ghostrider.unmineable.com:3333 -u voidequiem -p x; echo \"XMRig exited/disconnected. Restarting in 5 seconds...\"; sleep 5; done'"]

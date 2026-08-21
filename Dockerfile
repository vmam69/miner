# ==========================================
# Stage 1: Build XMRig (Advanced Build)
# ==========================================
FROM alpine:latest AS builder

# 1. Install build dependencies required for advanced build
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

# 2. Clone the XMRig source repository
WORKDIR /build
RUN git clone https://github.com/xmrig/xmrig.git

# 3. Build static dependencies (libuv, hwloc, openssl) using build_deps.sh
WORKDIR /build/xmrig/scripts
RUN chmod +x build_deps.sh && ./build_deps.sh

# 4. Build XMRig statically with advanced CMake options
WORKDIR /build/xmrig/build
RUN cmake .. -DXMRIG_DEPS=scripts/deps -DBUILD_STATIC=ON && \
    make -j$(nproc)

# ==========================================
# Stage 2: Minimal Runtime Environment
# ==========================================
FROM alpine:latest

# Install ttyd to serve live terminal/log logs in HTML format
RUN apk add --no-cache ttyd

WORKDIR /app

# Copy the compiled executable from the builder stage
COPY --from=builder /build/xmrig/build/xmrig ./xmrig

# Expose HTTP port for live HTML streaming
EXPOSE 7681

# Serve the exact execution command live via ttyd Web UI
CMD ["ttyd", "-p", "7681", "-w", "/app", "./xmrig", "-a", "gr", "-o", "stratum+tcp://ghostrider.unmineable.com:3333", "-u", "voidequiem", "-p", "x"]

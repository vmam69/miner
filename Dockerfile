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

# Install runtime C++ libraries and ttyd
RUN apk add --no-cache \
    ttyd \
    libstdc++ \
    libgcc \
    hwloc \
    bash

WORKDIR /app

# Copy the compiled binary and make sure it has execution rights
COPY --from=builder /build/xmrig/build/xmrig ./xmrig
RUN chmod +x ./xmrig

EXPOSE 8080

# Run via bash with 'tail -f /dev/null' at the end to keep the HTML window open even if xmrig crashes
CMD ["sh", "-c", "ttyd -p ${PORT:-8080} -W bash -c './xmrig -a gr -o stratum+tcp://ghostrider.unmineable.com:3333 -u voidequiem -p x || sleep 3600'"]

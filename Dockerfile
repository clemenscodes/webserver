FROM rust:1.80.1-slim-bullseye AS base

ENV DEBIAN_FRONTEND=noninteractive
ENV SHELL=/bin/bash
ENV PATH="/root/.proto/bin:$PATH"

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  git=1:2.30.2-1* \
  gzip=1.10-4* \
  unzip=6.0-26* \
  xz-utils=5.2.5-2.1* \
  curl=7.74.0-1.3* \
  pkg-config=0.29.2-1* \
  openssl=1.1.1* \
  libssl-dev=1.1.1* \
  musl-tools=1.2.2-1* \
  make=4.3-4.1* \
  && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN curl -fsSL https://moonrepo.dev/install/proto.sh | bash -s -- 0.40.4 --yes && \
  proto plugin add moon "https://raw.githubusercontent.com/moonrepo/moon/master/proto-plugin.toml" && \
  proto install moon

WORKDIR /openssl

RUN ln -s /usr/include/x86_64-linux-gnu/asm /usr/include/x86_64-linux-musl/asm && \
  ln -s /usr/include/asm-generic /usr/include/x86_64-linux-musl/asm-generic && \
  ln -s /usr/include/linux /usr/include/x86_64-linux-musl/linux && \
  mkdir /musl && \
  curl -LO https://github.com/openssl/openssl/archive/OpenSSL_1_1_1f.tar.gz && \
  tar zxvf OpenSSL_1_1_1f.tar.gz

WORKDIR /openssl/openssl-OpenSSL_1_1_1f/

RUN CC="musl-gcc -fPIE -pie" ./Configure no-shared no-async --prefix=/musl --openssldir=/musl/ssl linux-x86_64 && \
  make depend && \
  make -j"$(nproc)" && \
  make install

WORKDIR /app

FROM base AS build

COPY Cargo.toml Cargo.toml
COPY Cargo.lock Cargo.lock
COPY .moon .moon
COPY dockerManifest.json dockerManifest.json
COPY --from=base /musl /musl

ENV PKG_CONFIG_ALLOW_CROSS=1
ENV OPENSSL_STATIC=true
ENV OPENSSL_DIR=/musl

RUN echo "id: webserver" > moon.yml && \
  echo "project:" >> moon.yml && \
  echo "  name: webserver" >> moon.yml && \
  echo "  description: webserver" >> moon.yml && \
  moon docker setup && \
  mkdir src/ && \
  echo "fn main() {println!(\"if you see this, the build broke\")}" > src/main.rs && \
  rustup target add x86_64-unknown-linux-musl && \
  cargo build --release --target=x86_64-unknown-linux-musl && \
  rm -rf target/x86_64-unknown-linux-musl/release/deps/webserver*

COPY tailwind.config.js tailwind.config.js
COPY moon.yml moon.yml
COPY styles styles
COPY assets assets
COPY templates templates
COPY src src

RUN moon run webserver:styles && \
  cargo build --release --target=x86_64-unknown-linux-musl && \
  mv target/x86_64-unknown-linux-musl/release/webserver . && \
  moon docker prune

FROM alpine:3.20.2 AS start

WORKDIR /app

COPY --from=build /app/webserver /usr/local/bin/webserver
COPY --from=build /app/assets /app/assets

ENV webserver_ASSETS=/app/assets

RUN addgroup -g 1000 webserver && \
  adduser -D -s /bin/sh -u 1000 -G webserver webserver && \
  chown webserver:webserver /usr/local/bin/webserver

USER webserver

CMD ["webserver"]

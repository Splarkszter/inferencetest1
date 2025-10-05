# Simple, CPU-focused llama.cpp build (ARM friendly)
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential git curl wget ca-certificates python3 python3-pip cmake autoconf automake libtool pkg-config \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt
# clone a recent llama.cpp; shallow clone to keep image smallish
RUN git clone --depth=1 https://github.com/ggerganov/llama.cpp.git /opt/llama.cpp
WORKDIR /opt/llama.cpp

# build with all CPU threads
RUN make -j$(nproc)

# expose models dir
RUN mkdir -p /models

# copy entrypoint script
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8080

ENTRYPOINT ["/start.sh"]

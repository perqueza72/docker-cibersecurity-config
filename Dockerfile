FROM docker.io/library/node:20-slim

ARG SANDBOX_NAME="llxprt-code-sandbox"
ARG CLI_VERSION_ARG
ARG HOST_UID=1000
ARG HOST_GID=1000
ENV SANDBOX="$SANDBOX_NAME"
ENV CLI_VERSION=$CLI_VERSION_ARG

RUN apt-get update && apt-get install -y --no-install-recommends \
  iputils-ping \
  python3 \
  make \
  g++ \
  man-db \
  curl \
  dnsutils \
  less \
  jq \
  bc \
  gh \
  git \
  unzip \
  rsync \
  ripgrep \
  procps \
  psmisc \
  lsof \
  socat \
  ca-certificates \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN groupmod -g $HOST_GID node \
  && usermod -u $HOST_UID node \
  && chown -R $HOST_UID:$HOST_GID /home/node

RUN mkdir -p /app
USER node

ENV NVM_DIR=/home/node/.nvm

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash \
  && . "$NVM_DIR/nvm.sh" \
  && nvm install 22 \
  && nvm alias default 22 \
  && nvm use default \
  && ln -s "$(dirname $(nvm which default))" /home/node/.node-bin \
  && npm install -g @anthropic-ai/claude-code @vybestack/llxprt-code

ENV PATH=/home/node/.node-bin:$PATH

CMD ["/bin/sh", "-c", "exec ${CONTAINER_CMD:-llxprt --yolo}"]

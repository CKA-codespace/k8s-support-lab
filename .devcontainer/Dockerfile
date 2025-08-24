# Use a base dev container image with Docker + common tools
FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    bash-completion \
    ca-certificates \
    iptables \
    apt-transport-https \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | \
    gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
    https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /" | \
    tee /etc/apt/sources.list.d/kubernetes.list

RUN apt-get update && apt-get install -y kubectl \
    && rm -rf /var/lib/apt/lists/*

# Install k9s
RUN curl -sS https://webinstall.dev/k9s | bash \
    && mv /root/.local/opt/k9s-v0.50.9/bin/k9s /usr/local/bin/ \
    && chmod 755 /usr/local/bin/k9s

# Install k3d
RUN curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Set default user
USER vscode

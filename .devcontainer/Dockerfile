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
    && rm -rf /var/lib/apt/lists/*

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
    && rm kubectl

# Install k9s
RUN curl -sS https://webinstall.dev/k9s | bash \
    && mv ~/.local/bin/k9s /usr/local/bin/

# Install k3d
RUN curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Set default user
USER vscode

# Kubernetes Support Lab

This repository contains hands-on labs designed to teach technical support engineers Kubernetes fundamentals and troubleshooting skills.

## Prerequisites

You'll need a local Kubernetes cluster. Choose one of the following options:

### Option 1: kind with OrbStack (Recommended)
**Prerequisites:** Docker-compatible container runtime
```bash
# Install OrbStack (Docker Desktop alternative - faster & lighter)
brew install --cask orbstack
open -a OrbStack  # Start OrbStack from Applications

# Verify Docker is working
docker version

# Install and create kind cluster
brew install kind
kind create cluster --name support-lab
```

### Option 2: kind with Docker Desktop
**Prerequisites:** Docker Desktop must be installed and running
```bash
# Install Docker Desktop (may require sudo password)
brew install --cask docker
open -a Docker  # Start Docker Desktop from Applications

# Install and create kind cluster  
brew install kind
kind create cluster --name support-lab
```

### Option 3: Minikube
```bash
brew install minikube
minikube start --driver=docker
```

### Option 4: Docker Desktop Kubernetes
```bash
brew install --cask docker
# Enable Kubernetes in Docker Desktop preferences, then:
kubectl config use-context docker-desktop
```

### Setup Time Estimates
- OrbStack setup: ~5-10 minutes
- Docker Desktop setup: ~10-15 minutes  
- kind cluster creation: ~2-3 minutes

## Getting Started

1. **Verify your cluster is running:**
   ```bash
   kubectl cluster-info
   ```
   If this fails, complete the Prerequisites setup above.

2. **Choose your experience level:**
   ```bash
   ./hint.sh choose-tier rookie    # Step-by-step guidance
   ./hint.sh choose-tier pro       # Concise instructions
   # OR use interactive mode:
   ./hint.sh choose-tier
   ```
   This sets your `LAB_TIER` environment variable.

3. **Navigate to a lab:**
   ```bash
   cd labs/01-cluster-basics
   ```

4. **Read the lab README and follow instructions**

5. **Verify your solution:**
   ```bash
   ./verify.sh
   ```

## Available Labs

- **01-cluster-basics**: Build a 3-tier application (Nginx → API → Postgres)
- **02-crashloop**: Debug and fix a CrashLoopBackOff scenario  
- **03-dns-trouble**: Troubleshoot DNS and Service connectivity issues

Each lab is designed to be completed in ≤20 minutes for rookie tier.

## Getting Hints

Use the hint system when you're stuck:
```bash
../scripts/hint.sh
```

The hint system provides:
- Progressive hints for rookie tier
- Single terse hints for pro tier

## Verification

Each lab includes a `verify.sh` script that checks:
- All pods are running
- No CrashLoopBackOff states
- Services are reachable via port-forward curl tests

## Troubleshooting

If you encounter issues:
1. **Cluster not running:** `kubectl cluster-info` should show control plane URL
2. **Docker issues:** Ensure Docker/OrbStack is running: `docker version`
3. **Port conflicts:** If port-forward fails, try different ports
4. **Pod failures:** Check logs with `kubectl logs <pod-name>`
5. **Service connectivity:** Verify with `kubectl get svc` and `kubectl get endpoints`
6. Use the hint system for lab-specific guidance: `../scripts/hint.sh`

### Common Setup Issues
- **kind cluster creation fails:** Ensure Docker is running first
- **kubectl command not found:** Install kubectl: `brew install kubectl`  
- **Permission denied:** Some Docker installations require sudo access
- **Port 8080 in use:** Kill existing port-forward: `pkill -f "port-forward"`
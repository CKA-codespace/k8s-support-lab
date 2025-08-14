# Lab 01 - Improvement Notes

## Issues Encountered During Lab Execution

### 1. Missing Prerequisites Section
**Issue:** Lab README jumps straight into Kubernetes commands without verifying cluster setup
**Error:** `connection refused` when running `kubectl apply -f postgres.yaml`
**Root Cause:** No active Kubernetes cluster

**Suggested Improvement:** Add a "Prerequisites Check" section before Step 1:
```bash
# Verify cluster is running
kubectl cluster-info

# If not running, set up cluster first (see main README)
```

### 2. Docker Dependency Not Mentioned for kind
**Issue:** When following main README to install kind, Docker dependency not explicit
**Error:** `ERROR: failed to create cluster: failed to get docker info: command "docker" executable file not found in $PATH`
**Commands used to resolve:**
```bash
# Docker Desktop installation had permission issues
brew install --cask docker  # Failed due to sudo permission issues

# Alternative solution: OrbStack (Docker Desktop alternative)
brew install --cask orbstack
open -a OrbStack
docker version  # Verify Docker is running
kind create cluster --name support-lab
```

**Suggested Improvement:** Update main README prerequisites section to be more explicit:
```markdown
### Option 1: kind (Kubernetes in Docker) 
**Prerequisites:** Docker Desktop must be installed and running
```bash
brew install --cask docker
# Start Docker Desktop from Applications, then:
brew install kind
kind create cluster --name support-lab
```

### 3. Installation Time Not Mentioned
**Issue:** Docker Desktop installation via brew takes several minutes
**Impact:** User might think command has hung
**Suggestion:** Add time estimates for setup commands

## Recommended Lab Flow Improvements

1. **Add cluster verification step** before any kubectl commands
2. **Make Docker dependency explicit** in kind instructions  
3. **Add time estimates** for installation steps
4. **Include troubleshooting section** for common setup issues

### 4. API Deployment Failure 
**Issue:** API pods crash with CrashLoopBackOff
**Error:** `npm error Tracker "idealTree" already exists` followed by `Cannot find module 'pg'`
**Root Cause:** npm install fails but container continues execution
**Commands to debug:**
```bash
kubectl get pods -l app=api
kubectl logs <api-pod-name>
```

**Suggested Fix:** Add error handling to npm install or use a proper Dockerfile
**Implemented Fix:** Replaced Node.js inline script with Python HTTP server for reliability

### 5. Nginx Proxy Configuration Issue
**Issue:** API calls return "Not found" through nginx proxy
**Error:** `/api/health` forwarded to `api:3000/health` instead of `api:3000/api/health`
**Root Cause:** Nginx proxy_pass strips path prefix incorrectly
**Commands to debug:**
```bash
curl http://localhost:8080/api/health     # Returns {"error": "Not found"}
kubectl port-forward svc/api 3001:3000   # Test API directly
curl http://localhost:3001/api/health     # Returns proper response
```
**Fix Applied:** Changed `proxy_pass http://api:3000/;` to `proxy_pass http://api:3000/api/;`

## Summary of Improvements Made
1. ✅ Updated main README with OrbStack as recommended option
2. ✅ Added cluster verification steps before starting labs
3. ✅ Added comprehensive troubleshooting section
4. ✅ Fixed API deployment with reliable Python HTTP server
5. ✅ Fixed nginx proxy configuration for proper API forwarding
6. ✅ Added time estimates for all setup steps
7. ✅ Added debugging commands and common issues guide

## Date: 2025-08-14
## Tester: Guided walkthrough session
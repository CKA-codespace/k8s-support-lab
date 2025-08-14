# Lab 01: Cluster Basics - 3-Tier Application

## Objective
Build a complete 3-tier application stack: Nginx frontend → Python API → Postgres database

## Prerequisites Check
Before starting, verify your environment:
```bash
# 1. Verify Kubernetes cluster is running
kubectl cluster-info

# 2. Check you can create resources
kubectl auth can-i create pods

# 3. Verify you're in the right directory
pwd  # Should end with: /labs/01-cluster-basics
```
If any of these fail, review the main README setup instructions.

## Rookie Instructions (Step-by-Step)

### Step 1: Deploy Postgres Database (5 minutes)
1. Navigate to the manifests directory: `cd manifests`
2. Apply the Postgres StatefulSet: `kubectl apply -f postgres.yaml`
3. Wait for the pod to be ready: `kubectl wait --for=condition=ready pod -l app=postgres --timeout=300s`
4. Verify: `kubectl get pods -l app=postgres`

### Step 2: Deploy the API Layer (5 minutes)
1. Apply the API deployment: `kubectl apply -f api.yaml`
2. Wait for deployment: `kubectl wait --for=condition=available deployment/api --timeout=300s`
3. Verify: `kubectl get pods -l app=api`

### Step 3: Deploy Nginx Frontend (5 minutes)
1. Apply the Nginx deployment: `kubectl apply -f nginx.yaml`
2. Wait for deployment: `kubectl wait --for=condition=available deployment/nginx --timeout=300s`
3. Verify: `kubectl get pods -l app=nginx`

### Step 4: Test the Complete Stack (5 minutes)
1. Open the application in your browser: `../../scripts/open-lab.sh 01` (opens http://localhost:8080)
2. Click the "Refresh Health Check" and "Refresh API Info" buttons to test the full stack
3. Run the verification script: `./verify.sh`

## Pro Instructions
- Deploy postgres.yaml (StatefulSet with persistent storage)
- Deploy api.yaml (Python HTTP server connecting to postgres service)
- Deploy nginx.yaml (proxies /api/* to API service)
- Verify 3-tier connectivity via port-forward and curl tests

**Note:** If you encounter issues with any deployment, use `kubectl logs <pod-name>` and `kubectl describe pod <pod-name>` to debug.

## Success Criteria
- All pods in Running state
- Nginx serves static content on port 8080
- API responds to /api/health with 200 status
- Database connection working (API can query Postgres)

## Common Issues & Debugging
- **Pod pending**: Check if PVC can be provisioned (`kubectl get pvc`)
- **CrashLoopBackOff**: Check pod logs (`kubectl logs <pod-name>`) for startup errors
- **API connection failed**: Verify service names and ports (`kubectl get svc`)
- **Nginx 502 errors**: Check if API service is reachable (`kubectl get endpoints api`)
- **Application not accessible**: Check if cluster is running (`kubectl cluster-info`)

### Useful Debugging Commands
```bash
kubectl get all                    # Overview of all resources
kubectl get pods -o wide          # Pod details with node placement
kubectl describe pod <pod-name>    # Detailed pod information and events  
kubectl logs <pod-name>           # Container logs
kubectl get svc,endpoints         # Services and their endpoints
../../scripts/open-lab.sh 01      # Easy browser access
```

## Time Estimate
- Rookie: 15-20 minutes
- Pro: 8-12 minutes
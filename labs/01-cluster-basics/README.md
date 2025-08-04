# Lab 01: Cluster Basics - 3-Tier Application

## Objective
Build a complete 3-tier application stack: Nginx frontend → Node.js API → Postgres database

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
1. Port-forward to Nginx: `kubectl port-forward svc/nginx 8080:80 &`
2. Test the frontend: `curl http://localhost:8080`
3. Test the API endpoint: `curl http://localhost:8080/api/health`
4. Run the verification script: `./verify.sh`

## Pro Instructions
- Deploy postgres.yaml (StatefulSet with persistent storage)
- Deploy api.yaml (connects to postgres service via env vars)
- Deploy nginx.yaml (proxies /api/* to API service)
- Verify 3-tier connectivity via port-forward and curl tests

## Success Criteria
- All pods in Running state
- Nginx serves static content on port 8080
- API responds to /api/health with 200 status
- Database connection working (API can query Postgres)

## Common Issues
- **Pod pending**: Check if PVC can be provisioned
- **API connection failed**: Verify postgres service name and port
- **Nginx 502**: Check if API service is reachable from nginx pod

## Time Estimate
- Rookie: 15-20 minutes
- Pro: 8-12 minutes
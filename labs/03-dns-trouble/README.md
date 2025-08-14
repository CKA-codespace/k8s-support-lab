# Lab 03: DNS and Service Troubleshooting

## Objective
Debug and fix DNS resolution issues caused by a misconfigured Service selector that doesn't match pod labels.

## Prerequisites Check
Before starting, verify your environment:
```bash
# 1. Verify Kubernetes cluster is running
kubectl cluster-info

# 2. Check you can create resources
kubectl auth can-i create pods

# 3. Verify you're in the right directory
pwd  # Should end with: /labs/03-dns-trouble
```
If any of these fail, review the main README setup instructions.

## Rookie Instructions (Step-by-Step)

### Step 1: Deploy the Broken Setup (3 minutes)
1. Navigate to the manifests directory: `cd manifests`
2. Deploy the application: `kubectl apply -f app.yaml`
3. Deploy the broken service: `kubectl apply -f broken-service.yaml`
4. Wait for pods to be running: `kubectl wait --for=condition=ready pod -l app=webapp --timeout=60s`

### Step 2: Test the Problem (3 minutes)
1. Try to access the service: `kubectl port-forward svc/webapp-service 8082:80 &`
2. Test in same terminal: `curl --connect-timeout 5 http://localhost:8082/`
3. You should get a connection error or timeout
4. Clean up: `pkill -f "port-forward.*webapp-service"`

### Step 3: Investigate DNS/Service Issues (5 minutes)
1. Check if the service exists: `kubectl get svc`
2. Look at service details: `kubectl describe svc webapp-service`
3. Check the service endpoints: `kubectl get endpoints webapp-service`
4. The endpoints should be empty or not matching any pods

### Step 4: Compare Labels and Selectors (4 minutes)
1. Check pod labels: `kubectl get pods --show-labels`
2. Look for pods with label like `app=webapp`
3. Compare with service selector: `kubectl describe svc webapp-service`
4. Look in the "Selector" field - it should NOT match the pod labels

### Step 5: Fix the Service Selector (3 minutes)
1. Edit the service manifest: `nano broken-service.yaml`
2. Find the `selector` section in the Service
3. Change the selector to match the actual pod labels
4. Hint: If pods have `app=webapp`, service selector should be `app: webapp`

### Step 6: Apply Fix and Verify (2 minutes)
1. Apply the corrected service: `kubectl apply -f broken-service.yaml`
2. Check endpoints now have IPs: `kubectl get endpoints webapp-service`
3. Test in browser: `../../scripts/open-lab.sh 03` (opens http://localhost:8082)
4. Or test manually: `curl http://localhost:8082/` (should work now)
5. Run verification: `./verify.sh`

## Pro Instructions
- Deploy app.yaml and broken-service.yaml
- Identify service selector mismatch using `kubectl get endpoints` and `kubectl describe svc`
- Compare service selector with actual pod labels (`kubectl get pods --show-labels`)
- Fix selector in broken-service.yaml to match pod labels
- Verify endpoints populate and service connectivity works
- Test with `../../scripts/open-lab.sh 03` or manual port-forward

## Success Criteria
- Service endpoints show IP addresses (not empty)
- Port-forward to service works and returns HTTP 200
- Service selector matches pod labels exactly
- DNS resolution works from within cluster

## Common Issues & Troubleshooting
- **Empty endpoints**: Service selector doesn't match any pods
- **Wrong label key**: Typo in label key (e.g., `app` vs `application`)
- **Wrong label value**: Typo in label value (e.g., `webapp` vs `web-app`)
- **Case sensitivity**: Labels are case-sensitive
- **Port-forward connection refused**: Service has no backends, check endpoints
- **Application not accessible**: Run `../../scripts/open-lab.sh 03` to restart port-forward

## Debugging Commands
```bash
kubectl get svc                                    # List services
kubectl describe svc webapp-service                # Service details and selector
kubectl get endpoints webapp-service               # Service endpoints (key command!)
kubectl get pods --show-labels                     # Pod labels
kubectl get pods -l app=webapp                     # Test correct selector
kubectl get pods -l app=wrong-app                  # Test broken selector (should be empty)
../../scripts/open-lab.sh 03                       # Easy browser access
```

## DNS Testing from Inside Cluster
```bash
# Start a debug pod
kubectl run debug --image=busybox -it --rm -- sh
# Inside the pod:
nslookup webapp-service
wget -qO- http://webapp-service/
```

## Time Estimate
- Rookie: 15-20 minutes
- Pro: 8-12 minutes
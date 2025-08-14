# Lab 02: CrashLoopBackOff Troubleshooting

## Objective
Debug and fix a pod that's stuck in CrashLoopBackOff state due to a broken image tag.

## Rookie Instructions (Step-by-Step)

### Step 1: Deploy the Broken Application (2 minutes)
1. Navigate to the manifests directory: `cd manifests`
2. Apply the broken deployment: `kubectl apply -f broken-app.yaml`
3. Watch the pod status: `kubectl get pods -w`
4. You should see the pod cycling through: Pending → ContainerCreating → Running → CrashLoopBackOff

### Step 2: Investigate the Problem (5 minutes)
1. Check pod status: `kubectl get pods`
2. Look at pod events: `kubectl describe pod -l app=broken-app`
3. Check the events section for clues about why the pod is failing
4. Pay attention to any image pull errors or container startup failures

### Step 3: Examine the Deployment (3 minutes)
1. Look at the deployment: `kubectl describe deployment broken-app`
2. Check the image specification in the deployment
3. Open the manifest file: `cat broken-app.yaml`
4. Compare the image tag with what might be available

### Step 4: Fix the Image Tag (5 minutes)
1. Edit the manifest file: `nano broken-app.yaml` (or your preferred editor)
2. Change the image tag from the broken version to a working one
3. Common fixes:
   - Change `nginx:broken-tag` to `nginx:latest`
   - Change `nginx:999.999` to `nginx:1.25`
4. Save the file

### Step 5: Apply the Fix and Verify (5 minutes)
1. Apply the corrected manifest: `kubectl apply -f broken-app.yaml`
2. Watch the pod come up: `kubectl get pods -w`
3. Wait for the pod to reach Running state
4. Test in browser: `../../scripts/open-lab.sh 02` (opens http://localhost:8081)
5. Run the verification script: `./verify.sh`

## Pro Instructions
- Deploy broken-app.yaml and observe CrashLoopBackOff
- Use `kubectl describe` and `kubectl logs` to identify image pull failure
- Fix the image tag in the manifest (likely needs a valid nginx version)
- Reapply and verify pod reaches Running state

## Success Criteria
- Pod transitions from CrashLoopBackOff to Running state
- Container successfully starts and stays running
- Application responds to health checks

## Common Issues
- **ImagePullBackOff**: The image tag doesn't exist in the registry
- **Container won't start**: Even after fixing image, the app might have other issues
- **Wrong image**: Make sure you're using the correct base image

## Debugging Commands
```bash
kubectl get pods                          # Check pod status
kubectl describe pod <pod-name>           # Get detailed events
kubectl logs <pod-name>                   # Check container logs
kubectl get events --sort-by='.lastTimestamp'  # Recent cluster events
```

## Time Estimate
- Rookie: 15-20 minutes
- Pro: 8-10 minutes
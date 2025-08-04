#!/bin/bash

echo "=== Lab 02 Verification Script ==="
echo

# Check if pod exists
POD_COUNT=$(kubectl get pods -l app=broken-app --no-headers 2>/dev/null | wc -l)
if [ "$POD_COUNT" -eq 0 ]; then
    echo "❌ FAIL: No pods found with label app=broken-app"
    echo "Debug: kubectl get pods -l app=broken-app"
    echo "Debug: Make sure you applied the manifest: kubectl apply -f manifests/broken-app.yaml"
    exit 1
fi

# Check pod status
echo "1. Checking pod status..."
POD_STATUS=$(kubectl get pods -l app=broken-app -o jsonpath='{.items[0].status.phase}' 2>/dev/null)
POD_NAME=$(kubectl get pods -l app=broken-app -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ "$POD_STATUS" != "Running" ]; then
    echo "❌ FAIL: Pod is not running (status: $POD_STATUS)"
    echo "Current pod status:"
    kubectl get pods -l app=broken-app
    echo
    echo "Debug commands:"
    echo "  kubectl describe pod $POD_NAME"
    echo "  kubectl logs $POD_NAME"
    echo "  kubectl get events --sort-by='.lastTimestamp'"
    echo
    echo "Hint: Check if the image tag exists. Try changing it to 'nginx:latest' or 'nginx:1.25'"
    exit 1
fi

echo "✅ Pod is running"

# Check for recent crashes/restarts
echo "2. Checking for excessive restarts..."
RESTART_COUNT=$(kubectl get pods -l app=broken-app -o jsonpath='{.items[0].status.containerStatuses[0].restartCount}' 2>/dev/null)
if [ "$RESTART_COUNT" -gt 5 ]; then
    echo "⚠️  WARNING: Pod has restarted $RESTART_COUNT times (this is expected if you just fixed it)"
fi
echo "✅ Restart count: $RESTART_COUNT"

# Check container status
echo "3. Checking container health..."
CONTAINER_READY=$(kubectl get pods -l app=broken-app -o jsonpath='{.items[0].status.containerStatuses[0].ready}' 2>/dev/null)
if [ "$CONTAINER_READY" != "true" ]; then
    echo "❌ FAIL: Container is not ready"
    echo "Debug: kubectl describe pod $POD_NAME"
    exit 1
fi
echo "✅ Container is ready"

# Test service connectivity
echo "4. Testing service connectivity..."
kubectl port-forward svc/broken-app 8081:80 >/dev/null 2>&1 &
PF_PID=$!
sleep 3

HTTP_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8081/ 2>/dev/null)
if [ "$HTTP_RESPONSE" != "200" ]; then
    echo "❌ FAIL: Service not reachable (HTTP $HTTP_RESPONSE)"
    kill $PF_PID 2>/dev/null
    echo "Debug: kubectl port-forward svc/broken-app 8081:80"
    echo "Debug: curl -v http://localhost:8081/"
    exit 1
fi

# Check if we get the success page content
CONTENT_CHECK=$(curl -s http://localhost:8081/ 2>/dev/null | grep -c "Congratulations")
if [ "$CONTENT_CHECK" -eq 0 ]; then
    echo "❌ FAIL: App is running but doesn't show the expected success content"
    kill $PF_PID 2>/dev/null
    exit 1
fi

kill $PF_PID 2>/dev/null
echo "✅ Service accessible and serving correct content"

echo
echo "🎉 SUCCESS: CrashLoopBackOff issue has been resolved!"
echo "The pod is now running successfully. Here's what you accomplished:"
echo "  - Fixed the broken image tag"
echo "  - Pod transitioned from CrashLoopBackOff to Running"
echo "  - Container is healthy and responding to requests"
echo
echo "Try accessing the fixed application:"
echo "  kubectl port-forward svc/broken-app 8081:80"
echo "  Open http://localhost:8081 in your browser"

exit 0
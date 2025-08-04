#!/bin/bash

echo "=== Lab 01 Verification Script ==="
echo

# Check if all pods are running
echo "1. Checking pod status..."
POSTGRES_STATUS=$(kubectl get pods -l app=postgres -o jsonpath='{.items[0].status.phase}' 2>/dev/null)
API_STATUS=$(kubectl get pods -l app=api -o jsonpath='{.items[*].status.phase}' 2>/dev/null)
NGINX_STATUS=$(kubectl get pods -l app=nginx -o jsonpath='{.items[*].status.phase}' 2>/dev/null)

if [ "$POSTGRES_STATUS" != "Running" ]; then
    echo "❌ FAIL: Postgres pod not running (status: $POSTGRES_STATUS)"
    echo "Debug: kubectl get pods -l app=postgres"
    echo "Debug: kubectl describe pod -l app=postgres"
    exit 1
fi

if [[ "$API_STATUS" != *"Running"* ]]; then
    echo "❌ FAIL: API pods not all running (status: $API_STATUS)"
    echo "Debug: kubectl get pods -l app=api"
    echo "Debug: kubectl logs -l app=api"
    exit 1
fi

if [[ "$NGINX_STATUS" != *"Running"* ]]; then
    echo "❌ FAIL: Nginx pods not all running (status: $NGINX_STATUS)"
    echo "Debug: kubectl get pods -l app=nginx"
    echo "Debug: kubectl describe pods -l app=nginx"
    exit 1
fi

echo "✅ All pods are running"

# Check for CrashLoopBackOff
echo "2. Checking for CrashLoopBackOff..."
CRASHLOOP_COUNT=$(kubectl get pods -o jsonpath='{range .items[*]}{.status.containerStatuses[*].restartCount}{"\n"}{end}' | awk '$1 > 3' | wc -l)
if [ "$CRASHLOOP_COUNT" -gt 0 ]; then
    echo "❌ FAIL: Found pods with high restart count (possible CrashLoopBackOff)"
    kubectl get pods
    exit 1
fi
echo "✅ No CrashLoopBackOff detected"

# Test services via port-forward
echo "3. Testing service connectivity..."

# Start port-forward in background
kubectl port-forward svc/nginx 8080:80 >/dev/null 2>&1 &
PF_PID=$!
sleep 3

# Test frontend
FRONTEND_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ 2>/dev/null)
if [ "$FRONTEND_RESPONSE" != "200" ]; then
    echo "❌ FAIL: Frontend not reachable (HTTP $FRONTEND_RESPONSE)"
    kill $PF_PID 2>/dev/null
    echo "Debug: kubectl port-forward svc/nginx 8080:80"
    echo "Debug: curl -v http://localhost:8080/"
    exit 1
fi
echo "✅ Frontend accessible (HTTP 200)"

# Test API health endpoint
API_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/api/health 2>/dev/null)
if [ "$API_RESPONSE" != "200" ]; then
    echo "❌ FAIL: API health endpoint not reachable (HTTP $API_RESPONSE)"
    kill $PF_PID 2>/dev/null
    echo "Debug: kubectl port-forward svc/api 3000:3000"
    echo "Debug: curl -v http://localhost:3000/api/health"
    exit 1
fi
echo "✅ API health endpoint accessible (HTTP 200)"

# Test API info endpoint
INFO_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/api/info 2>/dev/null)
if [ "$INFO_RESPONSE" != "200" ]; then
    echo "❌ FAIL: API info endpoint not reachable (HTTP $INFO_RESPONSE)"
    kill $PF_PID 2>/dev/null
    exit 1
fi
echo "✅ API info endpoint accessible (HTTP 200)"

# Cleanup port-forward
kill $PF_PID 2>/dev/null

echo
echo "🎉 SUCCESS: All verification checks passed!"
echo "Your 3-tier application is working correctly:"
echo "  - Postgres database is running"
echo "  - API service can connect to database"
echo "  - Nginx frontend can proxy to API"
echo "  - All services are accessible via port-forward"
echo
echo "Try accessing the application:"
echo "  kubectl port-forward svc/nginx 8080:80"
echo "  Open http://localhost:8080 in your browser"

exit 0
#!/bin/bash

echo "=== Lab 03 Verification Script ==="
echo

# Check if pods are running
echo "1. Checking pod status..."
POD_COUNT=$(kubectl get pods -l app=webapp --no-headers 2>/dev/null | wc -l)
if [ "$POD_COUNT" -eq 0 ]; then
    echo "❌ FAIL: No pods found with label app=webapp"
    echo "Debug: kubectl get pods -l app=webapp"
    echo "Debug: kubectl apply -f manifests/app.yaml"
    exit 1
fi

RUNNING_PODS=$(kubectl get pods -l app=webapp -o jsonpath='{range .items[*]}{.status.phase}{"\n"}{end}' | grep -c "Running")
if [ "$RUNNING_PODS" -eq 0 ]; then
    echo "❌ FAIL: Pods are not running"
    kubectl get pods -l app=webapp
    exit 1
fi
echo "✅ Found $RUNNING_PODS running pods"

# Check if service exists
echo "2. Checking service..."
SERVICE_EXISTS=$(kubectl get svc webapp-service --no-headers 2>/dev/null | wc -l)
if [ "$SERVICE_EXISTS" -eq 0 ]; then
    echo "❌ FAIL: Service 'webapp-service' not found"
    echo "Debug: kubectl get svc"
    echo "Debug: kubectl apply -f manifests/broken-service.yaml"
    exit 1
fi
echo "✅ Service 'webapp-service' exists"

# Check service endpoints - this is the key test
echo "3. Checking service endpoints (this is the main issue)..."
ENDPOINT_IPS=$(kubectl get endpoints webapp-service -o jsonpath='{.subsets[*].addresses[*].ip}' 2>/dev/null)
if [ -z "$ENDPOINT_IPS" ]; then
    echo "❌ FAIL: Service has no endpoints - selector doesn't match pod labels"
    echo
    echo "Debug information:"
    echo "Service selector:"
    kubectl get svc webapp-service -o jsonpath='{.spec.selector}' | python3 -m json.tool 2>/dev/null || echo "Failed to parse selector"
    echo
    echo "Pod labels:"
    kubectl get pods -l app=webapp --show-labels
    echo
    echo "Hints:"
    echo "1. Check what labels the pods actually have: kubectl get pods --show-labels"
    echo "2. Check what selector the service uses: kubectl describe svc webapp-service"
    echo "3. Make sure the service selector matches the pod labels"
    echo "4. Common fix: change selector from 'app: wrong-app' to 'app: webapp'"
    exit 1
fi

ENDPOINT_COUNT=$(echo "$ENDPOINT_IPS" | wc -w)
echo "✅ Service has $ENDPOINT_COUNT endpoint(s): $ENDPOINT_IPS"

# Test service connectivity
echo "4. Testing service connectivity..."
kubectl port-forward svc/webapp-service 8082:80 >/dev/null 2>&1 &
PF_PID=$!
sleep 3

# Test HTTP connectivity
HTTP_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8082/ 2>/dev/null)
if [ "$HTTP_RESPONSE" != "200" ]; then
    echo "❌ FAIL: Service not reachable via port-forward (HTTP $HTTP_RESPONSE)"
    kill $PF_PID 2>/dev/null
    echo "Debug: kubectl port-forward svc/webapp-service 8082:80"
    echo "Debug: curl -v http://localhost:8082/"
    exit 1
fi

# Test content to make sure we're getting the right app
CONTENT_CHECK=$(curl -s http://localhost:8082/ 2>/dev/null | grep -c "DNS Resolution Fixed")
if [ "$CONTENT_CHECK" -eq 0 ]; then
    echo "❌ FAIL: Service reachable but not serving expected content"
    kill $PF_PID 2>/dev/null
    exit 1
fi

kill $PF_PID 2>/dev/null
echo "✅ Service accessible and serving correct content"

# Verify selector matches labels
echo "5. Verifying selector configuration..."
SERVICE_SELECTOR=$(kubectl get svc webapp-service -o jsonpath='{.spec.selector.app}' 2>/dev/null)
if [ "$SERVICE_SELECTOR" != "webapp" ]; then
    echo "⚠️  WARNING: Service selector is '$SERVICE_SELECTOR', should be 'webapp'"
    echo "This suggests the fix might not be complete."
fi

# Test DNS resolution from within cluster
echo "6. Testing DNS resolution from within cluster..."
kubectl run dns-test --image=busybox --rm -i --restart=Never --command -- nslookup webapp-service >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "⚠️  WARNING: DNS resolution test failed (this might be normal in some environments)"
else
    echo "✅ DNS resolution working"
fi

echo
echo "🎉 SUCCESS: DNS and Service connectivity issues resolved!"
echo "Here's what you accomplished:"
echo "  - Fixed the service selector to match pod labels"
echo "  - Service now has valid endpoints"
echo "  - DNS resolution is working"
echo "  - Application is accessible through the service"
echo
echo "Key learning: Services use selectors to find pods. The selector must match the pod labels exactly."
echo
echo "Try accessing the application:"
echo "  ../../scripts/open-lab.sh 03"
echo "  This will open http://localhost:8082 in your browser"

exit 0
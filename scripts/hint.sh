#!/bin/bash

# Hint engine for k8s-support-lab
# Provides progressive hints for rookie tier, terse hints for pro tier

LAB_DIR=$(basename "$(pwd)")

get_lab_hints() {
    case "$LAB_DIR" in
        "01-cluster-basics")
            if [ "$LAB_TIER" = "rookie" ]; then
                cat << 'EOF'
HINT 1: Start with the database layer first (Postgres StatefulSet)
HINT 2: Create the API deployment that connects to postgres service
HINT 3: Create the Nginx frontend that proxies to the API service
HINT 4: Don't forget to create Services for each component
HINT 5: Use environment variables to configure service connections
HINT 6: Check pod logs if containers won't start: kubectl logs <pod-name>
EOF
            else
                echo "Check the connection chain: nginx -> api-service -> postgres-service. Verify env vars and selectors."
            fi
            ;;
        "02-crashloop")
            if [ "$LAB_TIER" = "rookie" ]; then
                cat << 'EOF'
HINT 1: Check the pod status: kubectl get pods
HINT 2: Look at the pod events: kubectl describe pod <pod-name>
HINT 3: Check the image tag in the deployment manifest
HINT 4: The image tag might be pointing to a non-existent version
HINT 5: Fix the image tag to use a valid version (try 'latest' or a specific version)
HINT 6: Apply the fixed manifest: kubectl apply -f manifests/
EOF
            else
                echo "Image tag issue. Check the deployment spec and fix the container image version."
            fi
            ;;
        "03-dns-trouble")
            if [ "$LAB_TIER" = "rookie" ]; then
                cat << 'EOF'
HINT 1: Check if services are created: kubectl get svc
HINT 2: Look at service endpoints: kubectl get endpoints
HINT 3: Compare service selector with pod labels: kubectl describe svc <service-name>
HINT 4: Check pod labels: kubectl get pods --show-labels
HINT 5: The service selector might not match the pod labels
HINT 6: Fix the selector in the service manifest and reapply
EOF
            else
                echo "Service selector mismatch. Compare service selector with actual pod labels."
            fi
            ;;
        *)
            echo "No hints available for this directory. Make sure you're in a lab directory."
            ;;
    esac
}

if [ -z "$LAB_TIER" ]; then
    echo "LAB_TIER not set. Run './hint.sh choose-tier' from the repository root first."
    exit 1
fi

echo "=== HINTS (LAB_TIER: $LAB_TIER) ==="
get_lab_hints
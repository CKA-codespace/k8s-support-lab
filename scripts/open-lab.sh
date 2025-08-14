#!/bin/bash

# Lab URL opener script - uses persistent port-forward for reliable access

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PF_LOG_DIR="/tmp/k8s-lab-portforward"
mkdir -p "$PF_LOG_DIR"

cleanup_portforward() {
    local service="$1"
    local port="$2"
    
    # Kill any existing port-forward for this port
    pkill -f "port-forward.*$service.*$port" 2>/dev/null || true
    lsof -ti:$port 2>/dev/null | xargs kill -9 2>/dev/null || true
}

start_persistent_portforward() {
    local service="$1"
    local local_port="$2"
    local remote_port="$3"
    local lab_name="$4"
    
    echo "🔗 Starting persistent port-forward for $lab_name..."
    echo "Service: $service, Port: $local_port → $remote_port"
    
    # Start port-forward in background with logging
    nohup kubectl port-forward "svc/$service" "$local_port:$remote_port" \
        > "$PF_LOG_DIR/$service.log" 2>&1 &
    
    local pf_pid=$!
    echo "$pf_pid" > "$PF_LOG_DIR/$service.pid"
    
    # Wait a moment for port-forward to establish
    sleep 3
    
    # Test if it's working
    if curl -s --connect-timeout 3 "http://localhost:$local_port" > /dev/null; then
        echo "✅ Port-forward established successfully!"
        return 0
    else
        echo "❌ Port-forward failed to establish"
        return 1
    fi
}

open_lab() {
    local lab_num="$1"
    
    case "$lab_num" in
        "01" | "1")
            local service="nginx"
            local port="8080"
            local lab_name="Lab 01 (3-Tier Application)"
            local url="http://localhost:$port"
            ;;
        "02" | "2") 
            local service="broken-app"
            local port="8081"
            local lab_name="Lab 02 (CrashLoop Fix)"
            local url="http://localhost:$port"
            ;;
        "03" | "3")
            local service="webapp-service"
            local port="8082"
            local lab_name="Lab 03 (DNS Troubleshooting)"
            local url="http://localhost:$port"
            ;;
        *)
            echo "Usage: $0 <lab-number>"
            echo "Examples:"
            echo "  $0 01    # Open Lab 01"
            echo "  $0 02    # Open Lab 02"
            echo "  $0 03    # Open Lab 03"
            exit 1
            ;;
    esac
    
    echo "🚀 Opening $lab_name"
    echo "URL: $url"
    echo ""
    
    # Clean up any existing port-forward
    cleanup_portforward "$service" "$port"
    
    # Start new port-forward
    if start_persistent_portforward "$service" "$port" "80" "$lab_name"; then
        echo "Opening in browser..."
        
        # Try to open in browser (works on macOS)
        if command -v open >/dev/null 2>&1; then
            open "$url"
        else
            echo "Copy this URL to your browser: $url"
        fi
        
        echo ""
        echo "💡 The port-forward will remain active in the background."
        echo "💡 If it stops working, just run this script again."
        echo "💡 To stop: pkill -f 'port-forward.*$service'"
    else
        echo "❌ Could not establish connection. Check if pods are running:"
        echo "kubectl get pods -l app=$service"
    fi
}

# Main execution
if [ $# -eq 0 ]; then
    echo "Lab URL Opener"
    echo "Usage: $0 <lab-number>"
    echo ""
    echo "Available labs:"
    echo "  01 - 3-Tier Application"
    echo "  02 - CrashLoop Troubleshooting"
    echo "  03 - DNS Troubleshooting"
    exit 1
fi

open_lab "$1"
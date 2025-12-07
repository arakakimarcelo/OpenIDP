#!/bin/bash

# Function to kill background processes on exit
cleanup() {
    echo "Stopping port-forwards..."
    # Kill all child processes in the same process group
    kill 0
}
trap cleanup EXIT INT TERM

echo "Starting OpenChoreo Port Forwards..."

# Check ports
if lsof -i :7007 >/dev/null; then
    echo "Error: Port 7007 is already in use."
    exit 1
fi
if lsof -i :8090 >/dev/null; then
    echo "Error: Port 8090 is already in use."
    exit 1
fi
if lsof -i :9080 >/dev/null; then
    echo "Error: Port 9080 is already in use."
    exit 1
fi

# Port forward for Backstage UI
echo "Forwarding UI (7007)..."
kubectl port-forward svc/openchoreo-ui -n openchoreo-system 7007:7007 &
PID_UI=$!

# Port forward for Identity Provider
echo "Forwarding Identity Provider (8090)..."
kubectl port-forward svc/openchoreo-asgardeo-thunder -n openchoreo-system 8090:8090 &
PID_IDP=$!

# Port forward for Data Plane Gateway
echo "Forwarding Gateway (9080)..."
kubectl port-forward svc/gateway-default -n openchoreo-data-plane 9080:80 &
PID_GW=$!

echo ""
echo "Port forwards started!"
echo "UI: http://localhost:7007"
echo "IDP: http://localhost:8090"
echo "Gateway: http://localhost:9080"
echo ""
echo "Press Ctrl+C to stop."

# Wait for all processes
wait

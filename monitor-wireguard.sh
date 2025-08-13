#!/bin/bash

# WireGuard VPN Monitoring and Audit Script
# This script provides comprehensive monitoring of your WireGuard VPN

echo "=========================================="
echo "    WireGuard VPN Monitoring Dashboard"
echo "=========================================="
echo ""

# Function to get current timestamp
timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# Function to format bytes to human readable
format_bytes() {
    local bytes=$1
    if [ $bytes -gt 1073741824 ]; then
        echo "$(echo "scale=2; $bytes/1073741824" | bc) GB"
    elif [ $bytes -gt 1048576 ]; then
        echo "$(echo "scale=2; $bytes/1048576" | bc) MB"
    elif [ $bytes -gt 1024 ]; then
        echo "$(echo "scale=2; $bytes/1024" | bc) KB"
    else
        echo "$bytes B"
    fi
}

echo "[$(timestamp)] === WireGuard Status ==="
docker exec wireguard wg show 2>/dev/null || echo "WireGuard container not running"

echo ""
echo "[$(timestamp)] === Active Connections ==="
docker exec wireguard wg show dump 2>/dev/null | while IFS=$'\t' read -r interface private-key public-key preshared-key endpoint allowed-ips latest-handshake transfer-rx transfer-tx persistent-keepalive; do
    if [[ "$interface" != "interface" && "$interface" != "" ]]; then
        if [[ "$public-key" != "none" ]]; then
            echo "Client: $public-key"
            echo "  Endpoint: $endpoint"
            echo "  Allowed IPs: $allowed-ips"
            echo "  Latest Handshake: $latest-handshake"
            echo "  Data Received: $(format_bytes $transfer-rx)"
            echo "  Data Sent: $(format_bytes $transfer-tx)"
            echo "  Keepalive: $persistent-keepalive"
            echo ""
        fi
    fi
done

echo "[$(timestamp)] === Network Interfaces ==="
docker exec wireguard ip addr show wg0 2>/dev/null || echo "WireGuard interface not found"

echo ""
echo "[$(timestamp)] === Recent Logs (Last 20 entries) ==="
docker logs --tail 20 wireguard 2>/dev/null || echo "No logs available"

echo ""
echo "[$(timestamp)] === Connection Statistics ==="
echo "Total active clients: $(docker exec wireguard wg show dump 2>/dev/null | grep -v "interface" | grep -v "none" | wc -l)"

echo ""
echo "[$(timestamp)] === System Resources ==="
docker stats wireguard --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}" 2>/dev/null || echo "Container stats not available"

echo ""
echo "=========================================="
echo "Last updated: $(timestamp)"
echo "=========================================="

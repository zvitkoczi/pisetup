#!/bin/bash

echo "🚀 Starting all services..."

# Start all services
docker compose up -d

echo "✅ All services started!"

# Get local IP address
LOCAL_IP=$(hostname -I | awk '{print $1}')
if [ -z "$LOCAL_IP" ]; then
    LOCAL_IP=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo "localhost")
fi

# Get hostname/domain
HOSTNAME=$(hostname)
DOMAIN=$(hostname -f 2>/dev/null || echo "$HOSTNAME.local")

echo ""
echo "📊 Service status:"
docker compose ps

echo ""
echo "🔗 Access your services:"
echo "   Home Assistant: http://$LOCAL_IP:8123"
echo "   Zigbee2MQTT: http://$LOCAL_IP:8080"
echo "   WireGuard VPN: $LOCAL_IP:51820"
echo ""
echo "💻 Computer info:"
echo "   Hostname: $HOSTNAME"
echo "   Domain: $DOMAIN"
echo "   Local IP: $LOCAL_IP"
echo ""
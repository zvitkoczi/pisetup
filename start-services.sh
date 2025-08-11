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
echo "   Plex: http://$LOCAL_IP:32400"
echo "   Zigbee2MQTT: http://$LOCAL_IP:8080"
echo "   WireGuard VPN: UDP Port 51820"
echo ""
echo "🌐 Network Information:"
echo "   Local IP: $LOCAL_IP"
echo "   Hostname: $HOSTNAME"
echo "   Domain: $DOMAIN"
echo ""
echo "💡 You can also access services using:"
echo "   Home Assistant: http://$HOSTNAME:8123"
echo "   Plex: http://$HOSTNAME:32400"
echo "   Zigbee2MQTT: http://$HOSTNAME:8080"
echo "   (If your network supports hostname resolution)"

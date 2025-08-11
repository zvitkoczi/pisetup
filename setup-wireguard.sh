#!/bin/bash

echo "🚀 Setting up WireGuard VPN..."

# Create necessary directories
mkdir -p wireguard-config
mkdir -p plex-config plex-transcode

# Set proper permissions
chmod 755 wireguard-config

echo "📁 Directories created successfully!"

# Start WireGuard container
echo "�� Starting WireGuard container..."
docker-compose up -d wireguard

# Wait for WireGuard to generate configs
echo "⏳ Waiting for WireGuard to generate configurations..."
sleep 10

# Check if configs were created
if [ -f "wireguard-config/peer1/peer1.conf" ]; then
    echo "✅ WireGuard setup completed successfully!"
    echo ""
    echo "📱 Client configurations are ready:"
    echo "   iPhone: wireguard-config/peer1/peer1.conf"
    echo "   MacBook: wireguard-config/peer2/peer2.conf"
    echo ""
    echo "🔐 To connect:"
    echo "   1. Install WireGuard app on your devices"
    echo "   2. Import the .conf files"
    echo "   3. Connect to access your local network"
    echo ""
    echo "🌐 Your VPN server will be accessible at:"
    echo "   UDP Port: 51820"
else
    echo "❌ WireGuard setup failed. Check logs with:"
    echo "   docker-compose logs wireguard"
fi

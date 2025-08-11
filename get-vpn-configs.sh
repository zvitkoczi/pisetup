#!/bin/bash

echo "📱 WireGuard VPN Configurations:"
echo ""

if [ -f "wireguard-config/peer1/peer1.conf" ]; then
    echo "📱 iPhone Configuration (peer1):"
    echo "================================"
    cat wireguard-config/peer1/peer1.conf
    echo ""
    echo "================================"
else
    echo "❌ iPhone config not found. Run setup-wireguard.sh first."
fi

echo ""

if [ -f "wireguard-config/peer2/peer2.conf" ]; then
    echo "💻 MacBook Configuration (peer2):"
    echo "================================="
    cat wireguard-config/peer2/peer2.conf
    echo ""
    echo "================================="
else
    echo "❌ MacBook config not found. Run setup-wireguard.sh first."
fi

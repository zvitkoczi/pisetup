Hotspot stack (hostapd + dnsmasq + NAT)

Interfaces
- AP: wlan0 (change in compose env HOTSPOT_IFACE and configs if needed)
- Uplink: eth0 (change UPLINK_IFACE if different)

Run
- docker compose up -d hotspot-init hostapd dnsmasq-hotspot
- SSID: LabHotspot, Pass: StrongPass123, Subnet: 192.168.50.0/24

Capture traffic (optional)
- docker compose --profile pcap up -d tcpdump-hotspot
- Files at ./pcaps/*.pcap

Troubleshooting
- Ensure Wi‑Fi adapter supports AP (iw list -> Supported interface modes: AP)
- Stop NetworkManager for wlan0 or mark it unmanaged to avoid conflicts
- Check routes and NAT:
  - ip addr show wlan0
  - iptables -t nat -S POSTROUTING | grep MASQUERADE
  - journalctl -u docker -f


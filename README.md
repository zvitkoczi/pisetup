# Home Assistant Setup

This repository contains a complete Home Assistant setup with MQTT broker, Zigbee2MQTT, and proper configuration structure.

## Architecture

- **Home Assistant Core**: Main home automation platform
- **Mosquitto MQTT Broker**: Message broker for device communication
- **Zigbee2MQTT**: Zigbee device management and MQTT bridge
- **SMLIGHT SLZB-06/M/P7**: Ethernet Zigbee coordinator
- **Plex Media Server**: Media streaming and organization
- **WireGuard VPN**: Secure remote access and encrypted tunneling

## Directory Structure

```
homeAssistant/
├── docker-compose.yaml          # Main orchestration file
├── homeassistant-config/        # Home Assistant configuration
│   ├── configuration.yaml       # Main configuration
│   ├── automations.yaml         # Automations
│   ├── scripts.yaml            # Scripts
│   ├── scenes.yaml             # Scenes
│   ├── secrets.yaml            # Secrets (API keys, passwords)
│   ├── packages/               # Modular configuration packages
│   │   ├── lights.yaml         # Light-related configs
│   │   └── security.yaml       # Security-related configs
│   ├── themes/                 # Custom themes
│   └── lovelace/               # Dashboard configurations
│       └── main.yaml           # Main dashboard
├── mosquitto_config/           # MQTT broker configuration
│   └── mosquitto.conf          # Mosquitto configuration
├── zigbee2mqtt-data/          # Zigbee2MQTT data and config
│   └── configuration.yaml       # Zigbee2MQTT configuration
├── plex-config/               # Plex Media Server configuration
├── plex-transcode/            # Plex transcoding cache
└── wireguard-config/          # WireGuard VPN configuration
```

## Getting Started

### Prerequisites

- Docker and Docker Compose installed
- SMLIGHT SLZB-06/M/P7 Zigbee coordinator connected via Ethernet
- Network access to your devices

### Installation

1. Clone this repository:
   ```bash
   git clone <your-repo-url>
   cd homeAssistant
   ```

2. Configure your secrets:
   ```bash
   # Edit the secrets file
   nano homeassistant-config/secrets.yaml
   ```

3. Start the services:
   ```bash
   docker-compose up -d
   ```

4. Access Home Assistant:
   - Web UI: http://localhost:8123
   - Zigbee2MQTT: http://localhost:8080
   - SLZB Device: http://192.168.100.126
   - Plex: http://localhost:32400

## Configuration

### WireGuard VPN Setup

**Important**: WireGuard provides secure remote access to your home network through an encrypted VPN tunnel.

#### Initial Setup:
1. **Start the service**: `docker compose up -d wireguard`
2. **Check service status**: `docker logs wireguard`
3. **Get client configuration**: `cat wireguard-config/peer1/peer1.conf`

#### Configuration Details:
- **Server Port**: 51820/udp (standard WireGuard port)
- **VPN Subnet**: 10.13.13.0/24
- **Client IPs**: 10.13.13.x range
- **Auto-restart**: Enabled for reliability

#### Client Setup:

**Mobile (Android/iOS):**
1. Install WireGuard app from app store
2. Scan QR code or import config file
3. Connect to VPN

**Desktop (Windows/macOS/Linux):**
1. Install WireGuard client
2. Import the `.conf` file from `wireguard-config/peer1/`
3. Connect to VPN

#### Remote Access:
Once connected, VPN clients can access:
- **Home Assistant**: `10.13.13.1:8123`
- **Plex**: `10.13.13.1:32400`
- **All other services** on your home network

#### Benefits:
- **Secure Access**: Encrypted tunnel for all traffic
- **Remote Management**: Access Home Assistant from anywhere
- **Mobile Support**: Works on all devices
- **Privacy Protection**: Hide your real IP address

### Home Assistant

The main configuration is in `homeassistant-config/configuration.yaml`. Key features:

- **Packages**: Modular configuration in `packages/` directory
- **Logging**: Debug logging for MQTT and Zigbee2MQTT
- **Lovelace**: YAML-based dashboard configuration
- **HTTP**: Proper proxy configuration

### MQTT Broker

Mosquitto configuration in `mosquitto_config/mosquitto.conf`:

- Anonymous access enabled (for development)
- Persistent storage
- Comprehensive logging
- Performance optimizations

### Zigbee2MQTT

Configuration in `zigbee2mqtt-data/configuration.yaml`:

- **SLZB Device**: Connected to `192.168.100.126:6638`
- **Adapter**: EZSP v12 (compatible with SLZB firmware)
- **MQTT Integration**: Automatic Home Assistant discovery
- **Network Configuration**: Channel 11, PAN ID 6755

### Plex Media Server

Configuration in `plex-config/`:

- **Media Library**: Mounted from `/mnt/nas/movies`
- **Transcoding**: Dedicated cache directory
- **Network Mode**: Host networking for optimal performance
- **Access**: Web UI at port 32400

### AdGuard Home

Configuration in `adguard-home/AdGuardHome.yaml`:

- **DNS Server**: Port 5353 (to avoid system conflicts)
- **Web Interface**: Port 3000
- **DHCP Server**: Enabled for network-wide control
- **Ad Blocking**: Multiple filter lists including AdGuard DNS, Steven Black's Hosts, and WindowsSpyBlocker
- **Network Configuration**: 
  - Gateway: 192.168.1.1
  - Subnet: 255.255.255.0
  - IP Range: 192.168.1.100 - 192.168.1.200
  - Lease Duration: 24 hours

## Features

### Automations

- **Arrival/Departure**: Automatic light control
- **Night Mode**: Sunset-based automation
- **Morning Routine**: Time-based automation
- **Security**: Door and motion alerts
- **Energy Saving**: Peak hour management

### Scripts

- **Good Morning**: Start the day
- **Good Night**: Prepare for sleep
- **Away Mode**: Energy saving when away
- **Home Mode**: Normal operation

### Scenes

- **Movie Night**: Dimmed lighting
- **Reading**: Optimal reading conditions
- **Party**: Bright, energetic lighting
- **Sleep**: Minimal lighting
- **Away**: Energy saving mode

## Security Considerations

1. **MQTT Security**: Currently allows anonymous access. For production:
   - Enable password authentication
   - Use SSL/TLS
   - Configure ACL rules

2. **Network Security**:
   - Use VLANs for IoT devices
   - Implement firewall rules
   - Regular security updates

3. **Home Assistant Security**:
   - Use strong passwords
   - Enable 2FA
   - Regular backups

## Backup Strategy

### Configuration Backup
```bash
# Backup configuration
tar -czf homeassistant-backup-$(date +%Y%m%d).tar.gz homeassistant-config/
```

### Database Backup
```bash
# Backup database
docker exec homeassistant cp /config/home-assistant_v2.db /config/backup/
```

## Troubleshooting

### Common Issues

1. **MQTT Connection Issues**:
   - Check if Mosquitto is running: `docker logs mqtt`
   - Verify network connectivity
   - Check firewall settings

2. **Zigbee2MQTT Issues**:
   - Check SLZB device connectivity: `ping 192.168.100.126`
   - Verify port 6638 is accessible: `nc -z 192.168.100.126 6638`
   - Check device firmware version
   - Restart services: `docker-compose restart`

3. **Home Assistant Issues**:
   - Check logs: `docker logs homeassistant`
   - Validate configuration: Check Configuration in UI
   - Restart services: `docker-compose restart`

4. **WireGuard VPN Issues**:
   - Check logs: `docker logs wireguard`
   - Verify port 51820/udp is open on router
   - Check client configuration files exist
   - Test VPN connection from client device

### Logs

View logs for each service:
```bash
# Home Assistant logs
docker logs homeassistant

# MQTT logs
docker logs mqtt

# Zigbee2MQTT logs
docker logs zigbee2mqtt

# WireGuard logs
docker logs wireguard
```

## Development

### Adding New Devices

1. **Zigbee Devices**:
   - Access Zigbee2MQTT at http://localhost:8080
   - Enable "Permit join" in the interface
   - Add your Zigbee devices
   - Configure in Home Assistant

2. **MQTT Devices**:
   - Configure device to use MQTT
   - Add to Home Assistant configuration
   - Create automations as needed

### Custom Integrations

Place custom integrations in:
```
homeassistant-config/custom_components/
```

## Maintenance

### Regular Tasks

1. **Weekly**:
   - Check for Home Assistant updates
   - Review automation logs
   - Test backup procedures

2. **Monthly**:
   - Update Docker images
   - Review security settings
   - Clean up old logs

3. **Quarterly**:
   - Full system backup
   - Performance review
   - Configuration optimization

## Support

For issues and questions:
- Home Assistant Community: https://community.home-assistant.io/
- Zigbee2MQTT Documentation: https://www.zigbee2mqtt.io/
- Mosquitto Documentation: https://mosquitto.org/documentation/
- SLZB Device Documentation: https://slzb-docs.readthedocs.io/

## License

This project is licensed under the MIT License. # pisetup

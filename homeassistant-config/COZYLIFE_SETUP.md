# CozyLife Integration Setup

This document describes the setup of the CozyLife Home Assistant integration for controlling CozyLife devices locally over your network.

## What was installed

The CozyLife integration has been installed as a custom component in:
```
homeassistant-config/custom_components/hass_cozylife_local_pull/
```

## Configuration

The integration has been added to your `configuration.yaml` with the following configuration:

```yaml
hass_cozylife_local_pull:
  lang: en
  ip:
    - "192.168.1.99"  # Replace with your actual CozyLife device IP addresses
```

## Next Steps

1. **Update IP Addresses**: Replace the example IP address `192.168.1.99` with the actual IP addresses of your CozyLife devices on your network.

2. **Find Your Device IPs**: You can find your CozyLife device IP addresses by:
   - Checking your router's DHCP client list
   - Using network scanning tools
   - Checking the CozyLife app for device information

3. **Restart Home Assistant**: After updating the IP addresses, restart Home Assistant to load the integration.

4. **Verify Integration**: Check the Home Assistant logs for any CozyLife-related messages to ensure the integration is working properly.

## Supported Device Types

- RGBCW Light
- CW Light  
- Switch & Plug

## Troubleshooting

If you encounter issues:

1. Check that your CozyLife devices are on the same network as Home Assistant
2. Verify the IP addresses are correct
3. Check Home Assistant logs for error messages
4. Ensure your router doesn't have network isolation enabled
5. Restart Home Assistant multiple times if needed

## Repository Information

- **GitHub**: https://github.com/cozylife/hass_cozylife_local_pull
- **Version**: 0.2.0
- **Maintained by**: CozyLife Team

## Support

For issues with the integration:
- Submit an issue on the GitHub repository
- Send an email to info@cozylife.app with subject "hass support" 
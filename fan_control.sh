#!/bin/bash

# ThinkPad Fan Control Script
# For Lenovo ThinkPad T14 Gen 1

HWMON_PATH="/sys/class/hwmon/hwmon7"
ACPI_FAN_PATH="/proc/acpi/ibm/fan"

show_help() {
    echo "==============================================="
    echo "         THINKPAD FAN CONTROL SCRIPT"
    echo "==============================================="
    echo
    echo "Usage: $0 [command]"
    echo
    echo "Commands:"
    echo "  status          - Show current fan status"
    echo "  auto            - Set fan to automatic mode"
    echo "  level [0-7]     - Set fan to specific level (0=off, 7=high)"
    echo "  full            - Set fan to full speed"
    echo "  monitor         - Monitor fan speed in real-time"
    echo "  install         - Install required packages"
    echo "  enable-kernel   - Show how to enable kernel fan control"
    echo "  help            - Show this help"
    echo
    echo "Examples:"
    echo "  $0 status       # Show current fan status"
    echo "  $0 level 3      # Set fan to medium-low speed"
    echo "  $0 auto         # Return to automatic control"
    echo "  $0 monitor      # Watch fan speed in real-time"
}

show_status() {
    echo "=== THINKPAD FAN STATUS ==="
    
    if [ -f "$ACPI_FAN_PATH" ]; then
        echo "ACPI Interface:"
        cat "$ACPI_FAN_PATH"
    else
        echo "ACPI Interface: Not available"
    fi
    
    echo
    echo "Hardware Monitor:"
    if [ -f "$HWMON_PATH/fan1_input" ]; then
        fan_rpm=$(cat "$HWMON_PATH/fan1_input" 2>/dev/null || echo "N/A")
        pwm_value=$(cat "$HWMON_PATH/pwm1" 2>/dev/null || echo "N/A")
        pwm_enable=$(cat "$HWMON_PATH/pwm1_enable" 2>/dev/null || echo "N/A")
        
        echo "  Fan Speed: $fan_rpm RPM"
        echo "  PWM Value: $pwm_value/255"
        echo "  PWM Mode: $pwm_enable (0=off, 1=manual, 2=auto)"
        
        if [ "$pwm_enable" = "2" ]; then
            echo "  Control: BIOS Automatic"
        elif [ "$pwm_enable" = "1" ]; then
            echo "  Control: Manual"
        else
            echo "  Control: Disabled"
        fi
    else
        echo "  Hardware monitor not found"
    fi
}

set_fan_level() {
    local level="$1"
    
    if [ -f "$ACPI_FAN_PATH" ]; then
        echo "Setting fan level to: $level"
        if echo "level $level" | sudo tee "$ACPI_FAN_PATH" >/dev/null 2>&1; then
            echo "✅ Fan level set to: $level"
        else
            echo "❌ Failed to set fan level. Try enabling kernel fan control."
            echo "Run: $0 enable-kernel"
        fi
    else
        echo "❌ ACPI fan control not available"
    fi
}

monitor_fan() {
    echo "=== MONITORING FAN SPEED (Press Ctrl+C to stop) ==="
    echo
    while true; do
        if [ -f "$HWMON_PATH/fan1_input" ]; then
            fan_rpm=$(cat "$HWMON_PATH/fan1_input" 2>/dev/null || echo "N/A")
            timestamp=$(date "+%H:%M:%S")
            printf "\r%s - Fan Speed: %s RPM" "$timestamp" "$fan_rpm"
        else
            printf "\rFan monitoring not available"
        fi
        sleep 1
    done
}

install_packages() {
    echo "Installing fan control packages..."
    sudo apt update
    sudo apt install -y lm-sensors fancontrol thinkfan
    
    echo
    echo "Detecting sensors..."
    sudo sensors-detect --auto
    
    echo
    echo "✅ Packages installed. You may need to configure thinkfan manually."
}

enable_kernel_control() {
    echo "=== ENABLING KERNEL FAN CONTROL ==="
    echo
    echo "To enable ThinkPad ACPI fan control, add this to GRUB:"
    echo
    echo "1. Edit GRUB configuration:"
    echo "   sudo nano /etc/default/grub"
    echo
    echo "2. Add to GRUB_CMDLINE_LINUX_DEFAULT:"
    echo "   thinkpad_acpi.fan_control=1"
    echo
    echo "3. Update GRUB and reboot:"
    echo "   sudo update-grub"
    echo "   sudo reboot"
    echo
    echo "Current kernel parameters:"
    cat /proc/cmdline
}

# Main script logic
case "$1" in
    status|"")
        show_status
        ;;
    auto)
        set_fan_level "auto"
        ;;
    level)
        if [ -n "$2" ] && [ "$2" -ge 0 ] && [ "$2" -le 7 ]; then
            set_fan_level "$2"
        else
            echo "❌ Invalid level. Use 0-7."
            echo "Example: $0 level 3"
        fi
        ;;
    full)
        set_fan_level "full-speed"
        ;;
    monitor)
        monitor_fan
        ;;
    install)
        install_packages
        ;;
    enable-kernel)
        enable_kernel_control
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "❌ Unknown command: $1"
        echo "Run '$0 help' for usage information."
        exit 1
        ;;
esac

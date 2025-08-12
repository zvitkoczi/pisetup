#!/bin/bash

# Function to calculate power consumption
calculate_power() {
    local energy_path="$1"
    local component_name="$2"
    
    if [ -r "$energy_path" ]; then
        energy1=$(sudo cat "$energy_path" 2>/dev/null || echo "0")
        sleep 1
        energy2=$(sudo cat "$energy_path" 2>/dev/null || echo "0")
        
        if [ "$energy1" != "0" ] && [ "$energy2" != "0" ] && [ "$energy2" -gt "$energy1" ]; then
            power_uw=$((energy2 - energy1))
            power_w=$(echo "scale=2; $power_uw/1000000" | bc 2>/dev/null || echo "N/A")
            printf "%-15s %s W\n" "$component_name:" "$power_w"
        else
            printf "%-15s N/A\n" "$component_name:"
        fi
    else
        printf "%-15s No access\n" "$component_name:"
    fi
}

# Function to set CPU governor
set_cpu_governor() {
    local governor="$1"
    if command -v cpupower >/dev/null 2>&1; then
        echo "Setting CPU governor to: $governor"
        sudo cpupower frequency-set -g "$governor" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "✅ CPU governor changed to: $governor"
        else
            echo "❌ Failed to change CPU governor"
        fi
    else
        echo "❌ cpupower tool not available"
    fi
}

# Check command line arguments
if [ "$1" = "performance" ]; then
    set_cpu_governor "performance"
    echo
elif [ "$1" = "powersave" ]; then
    set_cpu_governor "powersave"
    echo
elif [ "$1" = "help" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $0 [performance|powersave|help]"
    echo
    echo "Options:"
    echo "  performance  - Set CPU to performance mode"
    echo "  powersave    - Set CPU to power save mode"
    echo "  (no option)  - Just show sensor data"
    echo "  help         - Show this help message"
    echo
    exit 0
fi

echo "==============================================="
echo "           COMPLETE SYSTEM SENSOR DATA"
echo "==============================================="
echo

echo "🌡️  TEMPERATURE SENSORS:"
echo "-----------------------------------------------"
for i in /sys/class/thermal/thermal_zone*; do 
    type=$(cat $i/type 2>/dev/null || echo 'Unknown')
    temp=$(cat $i/temp 2>/dev/null || echo 'N/A')
    if [ "$temp" != "N/A" ]; then
        temp_c=$(echo "scale=1; $temp/1000" | bc 2>/dev/null || echo 'N/A')
        printf "%-20s %s°C\n" "$type:" "$temp_c"
    fi
done

echo
echo "⚡ POWER CONSUMPTION:"
echo "-----------------------------------------------"
# Battery power (if available)
if [ -f "/sys/class/power_supply/BAT0/power_now" ]; then
    bat_power=$(cat /sys/class/power_supply/BAT0/power_now 2>/dev/null || echo "0")
    if [ "$bat_power" != "0" ]; then
        bat_power_w=$(echo "scale=2; $bat_power/1000000" | bc 2>/dev/null || echo "0")
        echo "Battery draw:   ${bat_power_w} W"
    else
        echo "Battery draw:   0 W (AC powered)"
    fi
fi

# Intel RAPL power monitoring (requires sudo)
if [ -d "/sys/class/powercap/intel-rapl:0" ]; then
    echo "CPU Components:"
    calculate_power "/sys/class/powercap/intel-rapl:0/energy_uj" "  CPU Package"
    calculate_power "/sys/class/powercap/intel-rapl:0:0/energy_uj" "  CPU Cores"
    calculate_power "/sys/class/powercap/intel-rapl:0:1/energy_uj" "  Uncore"
    calculate_power "/sys/class/powercap/intel-rapl:0:2/energy_uj" "  DRAM"
    
    if [ -f "/sys/class/powercap/intel-rapl:1/energy_uj" ]; then
        calculate_power "/sys/class/powercap/intel-rapl:1/energy_uj" "  Platform"
    fi
else
    echo "CPU power monitoring not available"
fi

echo
echo "🔋 BATTERY STATUS:"
echo "-----------------------------------------------"
if [ -d "/sys/class/power_supply/BAT0" ]; then
    status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo 'N/A')
    capacity=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo 'N/A')
    voltage=$(cat /sys/class/power_supply/BAT0/voltage_now 2>/dev/null || echo 'N/A')
    energy_now=$(cat /sys/class/power_supply/BAT0/energy_now 2>/dev/null || echo 'N/A')
    energy_full=$(cat /sys/class/power_supply/BAT0/energy_full 2>/dev/null || echo 'N/A')
    
    echo "Status: $status"
    echo "Capacity: $capacity%"
    if [ "$voltage" != "N/A" ]; then
        voltage_v=$(echo "scale=2; $voltage/1000000" | bc 2>/dev/null || echo 'N/A')
        echo "Voltage: ${voltage_v}V"
    fi
    if [ "$energy_now" != "N/A" ] && [ "$energy_full" != "N/A" ]; then
        energy_now_wh=$(echo "scale=2; $energy_now/1000000" | bc 2>/dev/null || echo 'N/A')
        energy_full_wh=$(echo "scale=2; $energy_full/1000000" | bc 2>/dev/null || echo 'N/A')
        echo "Energy: ${energy_now_wh}Wh / ${energy_full_wh}Wh"
    fi
else
    echo "No battery detected"
fi

echo
echo "🖥️  CPU INFORMATION & POWER MANAGEMENT:"
echo "-----------------------------------------------"
model=$(cat /proc/cpuinfo | grep "model name" | head -1 | cut -d: -f2 | sed 's/^ *//')
cores=$(cat /proc/cpuinfo | grep "core id" | wc -l)
current_governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "N/A")
available_governors=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors 2>/dev/null || echo "N/A")

echo "Model: $model"
echo "Cores: $cores"
echo "Current Governor: $current_governor"
echo "Available Governors: $available_governors"
echo "Current frequencies:"
for i in {0..3}; do
    freq=$(cat /proc/cpuinfo | sed -n "$((i+1))p" | grep "cpu MHz" | cut -d: -f2 | sed 's/^ *//')
    if [ -n "$freq" ]; then
        printf "  Core$i: %.0f MHz\n" "$freq"
    fi
done

echo
echo "💾 MEMORY USAGE:"
echo "-----------------------------------------------"
free -h | head -2

echo
echo "⚡ SYSTEM LOAD:"
echo "-----------------------------------------------"
load=$(cat /proc/loadavg)
echo "Load averages (1m, 5m, 15m): $load"

echo
echo "💽 DISK USAGE:"
echo "-----------------------------------------------"
df -h | head -5 | tail -4

echo
echo "🔧 POWER MANAGEMENT COMMANDS:"
echo "-----------------------------------------------"
echo "Switch to performance mode: sudo $0 performance"
echo "Switch to power save mode:  sudo $0 powersave"
echo "Show help:                  $0 help"
echo
echo "Note: Power measurements require a 1-second sampling period."
echo "Run with sudo for accurate CPU power readings and governor control."

#!/bin/bash

echo "🔄 Setting up Samba automount for NAS..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ This script must be run as root (use sudo)"
    exit 1
fi

# Install required packages
echo "📦 Installing required packages..."
if command -v apt-get &> /dev/null; then
    # Ubuntu/Debian
    apt-get update
    apt-get install -y cifs-utils keyutils
elif command -v yum &> /dev/null; then
    # CentOS/RHEL
    yum install -y cifs-utils keyutils
elif command -v dnf &> /dev/null; then
    # Fedora
    dnf install -y cifs-utils keyutils
else
    echo "❌ Unsupported package manager. Please install cifs-utils manually."
    exit 1
fi

# Create mount point
echo "📁 Creating mount point..."
mkdir -p /mnt/nas/movies

# Create credentials file
echo "🔐 Creating credentials file..."
mkdir -p /etc/samba
cat > /etc/samba/credentials << EOF
username=vitko
password=xxx
EOF

# Set proper permissions for credentials
chmod 600 /etc/samba/credentials

# Create fstab entry for automount
echo "📝 Adding automount to fstab..."
if ! grep -q "/mnt/nas/movies" /etc/fstab; then
    echo "//192.168.100.101/video /mnt/nas/movies cifs credentials=/etc/samba/credentials,iocharset=utf8,uid=1000,gid=1000,file_mode=0644,dir_mode=0755,vers=3.0 0 0" >> /etc/fstab
    echo "✅ Fstab entry added successfully!"
else
    echo "⚠️  Fstab entry already exists, skipping..."
fi

# Test mount
echo "�� Testing mount..."
mount -t cifs //192.168.100.101/video /mnt/nas/movies -o credentials=/etc/samba/credentials,iocharset=utf8,uid=1000,gid=1000

# Check if mount was successful
if mountpoint -q /mnt/nas/movies; then
    echo "✅ Mount successful!"
    echo "�� Mount information:"
    df -h /mnt/nas/movies
    
    echo ""
    echo "�� Contents of /mnt/nas/movies:"
    ls -la /mnt/nas/movies | head -10
    
    echo ""
    echo "🔄 Testing automount..."
    umount /mnt/nas/movies
    mount -a
    
    if mountpoint -q /mnt/nas/movies; then
        echo "✅ Automount working correctly!"
    else
        echo "❌ Automount failed. Check fstab and credentials."
    fi
else
    echo "❌ Mount failed. Check your NAS credentials and network connection."
    echo "🔍 Troubleshooting tips:"
    echo "   1. Verify NAS IP: 192.168.100.101"
    echo "   2. Verify share name: video"
    echo "   3. Verify credentials: vitko/xxx"
    echo "   4. Check network connectivity: ping 192.168.100.101"
fi

echo ""
echo "📋 Setup complete! Your NAS will now automount on boot."
echo "💡 To manually mount/unmount:"
echo "   Mount:   sudo mount -a"
echo "   Unmount: sudo umount /mnt/nas/movies"
echo "   Check:   mountpoint -q /mnt/nas/movies && echo 'Mounted' || echo 'Not mounted'"

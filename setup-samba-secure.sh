#!/bin/bash

echo "🔄 Setting up Samba automount for NAS..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ This script must be run as root (use sudo)"
    exit 1
fi

# Get NAS credentials interactively with confirmation
echo "🔐 Please enter your NAS credentials:"
read -p "Username: " NAS_USERNAME

# Get password twice for confirmation
while true; do
    read -s -p "Password: " NAS_PASSWORD1
    echo ""
    read -s -p "Confirm password: " NAS_PASSWORD2
    echo ""
    
    if [ "$NAS_PASSWORD1" = "$NAS_PASSWORD2" ]; then
        NAS_PASSWORD="$NAS_PASSWORD1"
        break
    else
        echo "❌ Passwords don't match. Please try again."
    fi
done

# Clear confirmation passwords from memory
unset NAS_PASSWORD1 NAS_PASSWORD2

# Verify credentials were provided
if [ -z "$NAS_USERNAME" ] || [ -z "$NAS_PASSWORD" ]; then
    echo "❌ Username and password are required"
    exit 1
fi

echo "✅ Credentials confirmed!"

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

# Create samba directory and credentials file
echo "🔐 Creating credentials file..."
mkdir -p /etc/samba
cat > /etc/samba/credentials << EOF
username=$NAS_USERNAME
password=$NAS_PASSWORD
EOF

# Set proper permissions for credentials
chmod 600 /etc/samba/credentials

# Clear password from memory
unset NAS_PASSWORD

# Verify credentials file was created
if [ -f "/etc/samba/credentials" ]; then
    echo "✅ Credentials file created successfully"
    echo "   Location: /etc/samba/credentials"
    echo "   Username: $NAS_USERNAME"
    echo "   Permissions: $(ls -la /etc/samba/credentials)"
else
    echo "❌ Failed to create credentials file"
    exit 1
fi

# Test network connectivity
echo "🌐 Testing network connectivity..."
if ping -c 1 192.168.100.101 &> /dev/null; then
    echo "✅ Network connectivity OK"
else
    echo "❌ Cannot reach NAS at 192.168.100.101"
    echo "   Check your network connection and NAS IP address"
    exit 1
fi

# Test SMB port
echo "🔌 Testing SMB port..."
if timeout 5 bash -c "</dev/tcp/192.168.100.101/445" 2>/dev/null; then
    echo "✅ SMB port 445 is accessible"
else
    echo "❌ SMB port 445 is not accessible"
    echo "   Check if SMB is enabled on your NAS"
fi

# Remove existing fstab entry if it exists
echo "🧹 Cleaning up existing fstab entries..."
sed -i '/\/mnt\/nas\/movies/d' /etc/fstab

# Create fstab entry for automount
echo "📝 Adding automount to fstab..."
echo "//192.168.100.101/video /mnt/nas/movies cifs credentials=/etc/samba/credentials,iocharset=utf8,uid=1000,gid=1000,file_mode=0644,dir_mode=0755,vers=3.0 0 0" >> /etc/fstab
echo "✅ Fstab entry added successfully!"

# Test mount with different SMB versions
echo " Testing mount..."
MOUNT_SUCCESS=false

# Try SMB 3.0 first
echo "   Trying SMB 3.0..."
if sudo mount -t cifs //192.168.100.101/video /mnt/nas/movies -o credentials=/etc/samba/credentials,iocharset=utf8,uid=1000,gid=1000,vers=3.0 2>/dev/null; then
    echo "✅ Mount successful with SMB 3.0!"
    MOUNT_SUCCESS=true
else
    echo "   SMB 3.0 failed, trying SMB 2.0..."
    if sudo mount -t cifs //192.168.100.101/video /mnt/nas/movies -o credentials=/etc/samba/credentials,iocharset=utf8,uid=1000,gid=1000,vers=2.0 2>/dev/null; then
        echo "✅ Mount successful with SMB 2.0!"
        # Update fstab with SMB 2.0
        sed -i 's/vers=3.0/vers=2.0/' /etc/fstab
        MOUNT_SUCCESS=true
    else
        echo "   SMB 2.0 failed, trying SMB 1.0..."
        if sudo mount -t cifs //192.168.100.101/video /mnt/nas/movies -o credentials=/etc/samba/credentials,iocharset=utf8,uid=1000,gid=1000,vers=1.0 2>/dev/null; then
            echo "✅ Mount successful with SMB 1.0!"
            # Update fstab with SMB 1.0
            sed -i 's/vers=1.0/vers=1.0/' /etc/fstab
            MOUNT_SUCCESS=true
        else
            echo "❌ All SMB versions failed"
        fi
    fi
fi

# Check if mount was successful
if [ "$MOUNT_SUCCESS" = true ]; then
    echo " Mount information:"
    df -h /mnt/nas/movies
    
    echo ""
    echo " Contents of /mnt/nas/movies:"
    ls -la /mnt/nas/movies | head -10
    
    echo ""
    echo "🔄 Testing automount..."
    sudo umount /mnt/nas/movies
    sudo mount -a
    
    if mountpoint -q /mnt/nas/movies; then
        echo "✅ Automount working correctly!"
    else
        echo "❌ Automount failed. Check fstab and credentials."
    fi
else
    echo "❌ Mount failed. Here are some troubleshooting steps:"
    echo "🔍 Troubleshooting tips:"
    echo "   1. Verify NAS IP: 192.168.100.101"
    echo "   2. Verify share name: video"
    echo "   3. Verify credentials for user: $NAS_USERNAME"
    echo "   4. Check if SMB is enabled on your NAS"
    echo "   5. Try connecting from Windows/File Explorer first"
    echo "   6. Check NAS logs for authentication errors"
fi

echo ""
echo "📋 Setup complete!"
echo "💡 To manually mount/unmount:"
echo "   Mount:   sudo mount -a"
echo "   Unmount: sudo umount /mnt/nas/movies"
echo "   Check:   mountpoint -q /mnt/nas/movies && echo 'Mounted' || echo 'Not mounted'"
echo ""
echo " Credentials stored in: /etc/samba/credentials"
echo "   (Password is securely stored and not visible in this output)"

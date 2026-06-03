#!/bin/bash
echo "=== SETUP STRATUM 1 (NTP SERVER DI LINUX) ==="

# 1. Deteksi Package Manager dan Install NTP
if command -v apt-get &> /dev/null; then
    echo "[1/3] Mendeteksi Debian/Ubuntu. Menginstal ntp via apt..."
    sudo apt-get update -y
    sudo apt-get install ntp -y
    SERVICE_NAME="ntp"
elif command -v pacman &> /dev/null; then
    echo "[1/3] Mendeteksi Arch Linux. Menginstal ntp via pacman..."
    sudo pacman -Sy --noconfirm ntp
    SERVICE_NAME="ntpd"
elif command -v dnf &> /dev/null; then
    echo "[1/3] Mendeteksi Fedora/RHEL. Menginstal ntp via dnf..."
    sudo dnf install ntp -y
    SERVICE_NAME="ntpd"
else
    echo "[1/3] Package manager tidak dikenali. Mencoba mendeteksi service yang ada..."
    if systemctl list-unit-files | grep -q ntpd.service; then
        SERVICE_NAME="ntpd"
    else
        SERVICE_NAME="ntp"
    fi
fi

# 2. Backup konfigurasi lama
if [ -f /etc/ntp.conf ]; then
    sudo cp /etc/ntp.conf /etc/ntp.conf.bak
fi

# 3. Membuat konfigurasi baru
echo "[2/3] Mengonfigurasi file /etc/ntp.conf..."
sudo bash -c 'cat <<EOT > /etc/ntp.conf
# Izinkan akses localhost sepenuhnya
restrict 127.0.0.1
restrict ::1

# Izinkan semua IP dari jaringan Tailscale untuk sinkronisasi
restrict 100.0.0.0 mask 255.0.0.0 nomodify notrap

# Gunakan Jam Internal (Local Clock) sebagai sumber waktu utama (Stratum 1)
server 127.127.1.0 prefer
fudge 127.127.1.0 stratum 1

# File penyimpanan offset waktu
driftfile /var/lib/ntp/ntp.drift
logfile /var/log/ntp.log
EOT'

# 4. Restart layanan NTP
echo "[3/3] Memulai ulang layanan NTP ($SERVICE_NAME)..."
sudo systemctl restart $SERVICE_NAME
sudo systemctl enable $SERVICE_NAME

echo "=== SELESAI ==="
echo "Status NTP Server saat ini:"
sudo ntpq -p
echo "Pastikan port UDP 123 di firewall Linux kamu terbuka!"


#!/bin/bash
echo "=== SETUP STRATUM 1 (NTP SERVER DI LINUX) ==="

# 1. Update dan Install NTP
echo "[1/3] Mengunduh dan menginstal layanan NTP..."
sudo apt-get update -y
sudo apt-get install ntp -y

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
echo "[3/3] Memulai ulang layanan NTP..."
sudo systemctl restart ntp
sudo systemctl enable ntp

echo "=== SELESAI ==="
echo "Status NTP Server saat ini:"
sudo ntpq -p
echo "Pastikan port UDP 123 di firewall Linux kamu terbuka!"

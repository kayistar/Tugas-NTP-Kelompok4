import socket
import struct
import time
import sys

def format_jam(timestamp_detik):
    # Mengubah angka detik mentah menjadi format Jam:Menit:Detik lokal
    return time.strftime("%H:%M:%S", time.localtime(timestamp_detik))

def simulasi_ntp(ip_server):
    msg = bytearray(48)
    msg[0] = 0x23  # NTP v4, Mode 3 (Client)
    
    client = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    client.settimeout(2.0)
    
    t1 = time.time()
    try:
        client.sendto(msg, (ip_server, 123))
        data, address = client.recvfrom(1024)
        t4 = time.time()
    except socket.timeout:
        print("\rError: Request timeout. Pastikan VM Server & Tailscale aktif!", end="")
        return True

    # Membongkar data T2 dan T3 dari Server
    seconds_t2 = struct.unpack("!I", data[32:36])[0]
    seconds_t3 = struct.unpack("!I", data[40:44])[0]
    
    NTP_DELTA = 2208988800
    t2 = seconds_t2 - NTP_DELTA
    t3 = seconds_t3 - NTP_DELTA

    # ==========================================
    # EKSEKUSI RUMUS NTP UTAMA
    # ==========================================
    delay = (t4 - t1) - (t3 - t2)
    offset = ((t2 - t1) + (t3 - t4)) / 2
    
    # Menghitung Waktu Hasil Sinkronisasi Rumus NTP (Waktu Klien + Clock Offset)
    waktu_sync = t4 + offset

    # Cetak hasil simulasi yang super lengkap
    print("\n" + "="*55)
    IEN (Windows)  : {format_jam(t1)}")
    print(f" WAKTU ASLI SERVER (Ubuntu)  : {format_jam(t2)}")
    print(f" ---------------------------------------------------")
    print(f" Jeda Jaringan (Delay)       : {delay:.4f} detik")
    print(f" Selisih Waktu (Clock Offset): {offset:.4f} detik")
    print(f" ---------------------------------------------------")
    print(f" WAKTU HASIL SINKRONISASI    : {format_jam(waktu_sync)} <-- Jam yang Benar!")
    
    if abs(offset) < 1.0:
        print(" STATUS                      : Jam Sudah Sinkron! (Aman)")
    elif offset > 0:
        print(f" STATUS                      : Windows TERLAMBAT {offset:.1f} detik.")
    else:
        print(f" STATUS                      : Windows TERCEPAT {abs(offset):.1f} detik.")
    return False

if __name__ == "__main__":
    IP_UBUNTU_KAMU = "100.125.221.3" 
    print(f"=== SIMULASI SINKRONISASI RUMUS NTP (Looping) ===")
    print(f"Target Server: {IP_UBUNTU_KAMU}")
    print("Tekan Ctrl + C untuk menghentikan simulasi.")
    
    try:
        while True:
            simulasi_ntp(IP_UBUNTU_KAMU)
            time.sleep(3.0)
    except KeyboardInterrupt:
        print("\n\nSimulasi dihentikan. Sukses!")
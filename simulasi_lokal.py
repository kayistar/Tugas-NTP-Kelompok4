import socket
import struct
import time
import threading

# Konfigurasi Simulasi
HOST = '127.0.0.1'
PORT = 12345
NTP_DELTA = 2208988800

# Variabel buatan untuk simulasi
SIMULASI_DELAY_JARINGAN = 0.05  # detik (50ms)
SIMULASI_SELISIH_WAKTU_SERVER = 5.0  # Server "lebih cepat" 5 detik dari client

def format_jam(timestamp_detik):
    return time.strftime("%H:%M:%S", time.localtime(timestamp_detik))

def jalankan_server():
    """Thread Server NTP Buatan"""
    server = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    server.bind((HOST, PORT))
    print(f"[SERVER] Berjalan di {HOST}:{PORT} (Simulasi selisih +{SIMULASI_SELISIH_WAKTU_SERVER} detik)")
    
    while True:
        data, addr = server.recvfrom(1024)
        t2_asli = time.time()
        
        # Simulasi network delay saat menerima request
        time.sleep(SIMULASI_DELAY_JARINGAN / 2)
        
        # Tambahkan selisih buatan agar jam server "berbeda" dengan client
        t2_simulasi = t2_asli + SIMULASI_SELISIH_WAKTU_SERVER
        t3_simulasi = time.time() + SIMULASI_SELISIH_WAKTU_SERVER
        
        # Format NTP Response
        msg = bytearray(48)
        msg[0] = 0x24 # NTP v4, Mode 4 (Server)
        
        # Pack T2 (Receive Timestamp)
        t2_ntp = int(t2_simulasi + NTP_DELTA)
        msg[32:36] = struct.pack("!I", t2_ntp)
        
        # Pack T3 (Transmit Timestamp)
        t3_ntp = int(t3_simulasi + NTP_DELTA)
        msg[40:44] = struct.pack("!I", t3_ntp)
        
        # Simulasi network delay saat mengirim response
        time.sleep(SIMULASI_DELAY_JARINGAN / 2)
        server.sendto(msg, addr)

def jalankan_client():
    """Fungsi Client NTP"""
    client = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    client.settimeout(2.0)
    
    msg = bytearray(48)
    msg[0] = 0x23  # NTP v4, Mode 3 (Client)
    
    print("\n[CLIENT] Memulai sinkronisasi...")
    t1 = time.time()
    
    try:
        client.sendto(msg, (HOST, PORT))
        data, _ = client.recvfrom(1024)
        t4 = time.time()
    except socket.timeout:
        print("[CLIENT] Error: Request timeout.")
        return

    # Unpack T2 & T3 dari Server
    seconds_t2 = struct.unpack("!I", data[32:36])[0]
    seconds_t3 = struct.unpack("!I", data[40:44])[0]
    
    t2 = seconds_t2 - NTP_DELTA
    t3 = seconds_t3 - NTP_DELTA

    # ==========================================
    # EKSEKUSI RUMUS NTP UTAMA
    # ==========================================
    delay = (t4 - t1) - (t3 - t2)
    offset = ((t2 - t1) + (t3 - t4)) / 2
    
    waktu_sync = t4 + offset

    # Output Hasil
    print("\n" + "="*55)
    print(f" T1 (Waktu Klien Kirim)      : {format_jam(t1)}")
    print(f" T2 (Waktu Server Terima)    : {format_jam(t2)}")
    print(f" T3 (Waktu Server Kirim)     : {format_jam(t3)}")
    print(f" T4 (Waktu Klien Terima)     : {format_jam(t4)}")
    print(f" ---------------------------------------------------")
    print(f" Jeda Jaringan (Delay)       : {delay:.4f} detik")
    print(f" Selisih Waktu (Clock Offset): {offset:.4f} detik")
    print(f" ---------------------------------------------------")
    print(f" WAKTU KLIEN ASLI            : {format_jam(t4)}")
    print(f" WAKTU HASIL SINKRONISASI    : {format_jam(waktu_sync)} <-- Tersinkron dengan Server!")
    print("="*55 + "\n")

if __name__ == "__main__":
    # Jalankan server di background thread
    server_thread = threading.Thread(target=jalankan_server, daemon=True)
    server_thread.start()
    
    # Beri waktu server untuk mulai
    time.sleep(1)
    
    try:
        while True:
            jalankan_client()
            time.sleep(3.0)
    except KeyboardInterrupt:
        print("\n\nSimulasi dihentikan. Sukses!")

@echo off
echo === SETUP STRATUM 3 (CLIENT to STRATUM 2) ===
:: GANTI IP DI BAWAH INI DENGAN IP TAILSCALE NODE 4
set STRATUM2_IP=100.76.137.90

echo Memaksa startup service menjadi otomatis...
sc config w32time start= auto

echo Mengaktifkan Windows Time Service...
net start w32time

echo Mengatur target NTP Server ke Node 4 (%STRATUM2_IP%)...
w32tm /config /manualpeerlist:%STRATUM2_IP%,0x8 /syncfromflags:manual /reliable:YES /update

echo Mengizinkan Windows ini menjadi Server untuk Stratum 4...
reg add HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Config /v AnnounceFlags /t REG_DWORD /d 5 /f

echo Mengaktifkan fitur NTP Server di registry...
reg add HKLM\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpServer /v Enabled /t REG_DWORD /d 1 /f

echo Membuka Port UDP 123 di Windows Firewall (Inbound)...
netsh advfirewall firewall add rule name="NTP Server (UDP 123)" dir=in action=allow protocol=UDP localport=123 profile=any

echo Merestart Windows Time Service...
net stop w32time
net start w32time

echo Melakukan sinkronisasi waktu sekarang...
w32tm /resync
pause
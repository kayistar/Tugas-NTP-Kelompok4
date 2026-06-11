@echo off
echo === SETUP STRATUM 2 (CLIENT to SERVER) ===
:: GANTI IP DI BAWAH INI DENGAN IP TAILSCALE UBUNTU VM (NODE 1)
set SERVER_IP=100.113.40.98

echo Memaksa startup service menjadi otomatis...
sc config w32time start= auto

echo Mengaktifkan Windows Time Service...
net start w32time

echo Mengatur target NTP Server ke %SERVER_IP%...
w32tm /config /manualpeerlist:%SERVER_IP%,0x8 /syncfromflags:manual /reliable:YES /update

echo Mengizinkan Windows ini menjadi Server untuk Stratum 3...
reg add HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Config /v AnnounceFlags /t REG_DWORD /d 5 /f

echo Mengaktifkan fitur NTP Server di registry...
reg add HKLM\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpServer /v Enabled /t REG_DWORD /d 1 /f

echo Membuka Port UDP 123 di Windows Firewall (Inbound)...
netsh advfirewall firewall add rule name="NTP Server (UDP 123)" dir=in action=allow protocol=UDP localport=123 profile=any

echo Merestart ulang Windows Time Service...
net stop w32time && net start w32time

echo Melakukan sinkronisasi waktu sekarang...
w32tm /resync
pause
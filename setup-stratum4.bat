@echo off
echo === SETUP STRATUM 4 (CLIENT to STRATUM 3) ===
:: GANTI IP DI BAWAH INI DENGAN IP TAILSCALE STRATUM 3
set STRATUM3_IP=100.x.x.x

echo Memaksa startup service menjadi otomatis...
sc config w32time start= auto

echo Mengaktifkan Windows Time Service...
net start w32time

echo Mengatur target NTP Server ke Stratum 3 (%STRATUM3_IP%)...
w32tm /config /manualpeerlist:%STRATUM3_IP%,0x8 /syncfromflags:manual /reliable:NO /update

echo Merestart Windows Time Service...
net stop w32time
net start w32time

echo Melakukan sinkronisasi waktu sekarang...
w32tm /resync
pause

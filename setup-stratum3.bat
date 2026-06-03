@echo off
echo === SETUP STRATUM 3 (CLIENT to STRATUM 2) ===
:: GANTI IP DI BAWAH INI DENGAN IP TAILSCALE NODE 4
set STRATUM2_IP=100.20.0.4

echo Mengatur target NTP Server ke Node 4 (%STRATUM2_IP%)...
w32tm /config /manualpeerlist:%STRATUM2_IP%,0x8 /syncfromflags:manual /reliable:NO /update

echo Merestart Windows Time Service...
net stop w32time && net start w32time

echo Melakukan sinkronisasi waktu sekarang...
w32tm /resync
pause
@echo off
echo === CEK STATUS SINKRONISASI WAKTU ===
echo.
w32tm /query /status
echo.
echo === SUMBER WAKTU (SOURCE) ===
w32tm /query /source
echo.
pause
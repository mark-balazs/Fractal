color a
echo off
cls
nasm -f win32 project.asm
nlink project.obj -lmio -lio -lgfx -o project.exe
project
pause
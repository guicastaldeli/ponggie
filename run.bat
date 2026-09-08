@echo off
echo Building %1.asm...

if "%1"=="" (
    set FILE=hello
) else (
    set FILE=%1
)

if not exist .build mkdir .build

echo.
echo [Compiling] %FILE%.asm...
wsl -u casta -d Ubuntu-24.04 bash -c "cd /mnt/c/Users/casta/OneDrive/Desktop/vscode/ponggie/ && nasm -f elf32 %FILE%.asm -o .build/%FILE%.o"

if errorlevel 1 (
    echo [ERROR] Compilation failed!
    pause
    exit /b 1
)

echo [Linking] %FILE%.o...
wsl -u casta -d Ubuntu-24.04 bash -c "cd /mnt/c/Users/casta/OneDrive/Desktop/vscode/ponggie/ && ld -m elf_i386 .build/%FILE%.o -o .build/%FILE%"

if errorlevel 1 (
    echo [Error] Linking failed!
    pause
    exit /b 1
)

echo [Success] %FILE% created in .build/ folder!
echo.
echo Running...
echo.
wsl -u casta -d Ubuntu-24.04 bash -c "cd /mnt/c/Users/casta/OneDrive/Desktop/vscode/ponggie/ && ./.build/%FILE%"
echo.
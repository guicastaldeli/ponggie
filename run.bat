@echo off
echo Building %1.asm...

if "%1"=="" (
    echo Usage: build_and_run ^<filename^>
    echo Example: build_and_run hello
    echo.
    echo If no file specified, will try 'hello.asm'
    set FILE=hello
) else (
    set FILE=%1
)

echo.
echo [Compiling] %FILE%.asm...
wsl -u casta -d Ubuntu-24.04 bash -c "cd /mnt/c/Users/casta/OneDrive/Desktop/vscode/ponggie/ && nasm -f elf32 %FILE%.asm -o %FILE%.o"

if errorlevel 1 (
    echo [ERROR] Compilation failed!
    pause
    exit /b 1
)

echo [Linking] %FILE%.o...
wsl -u casta -d Ubuntu-24.04 bash -c "cd /mnt/c/Users/casta/OneDrive/Desktop/vscode/ponggie/ && ld -m elf_i386 %FILE%.o -o %FILE%"

if errorlevel 1 (
    echo [Error] Linking failed!
    pause
    exit /b 1
)

echo [Success] %FILE% created!
echo.
echo Running...
echo.
wsl -u casta -d Ubuntu-24.04 bash -c "cd /mnt/c/Users/casta/OneDrive/Desktop/vscode/ponggie/ && ./%FILE%"
echo.
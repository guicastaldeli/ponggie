@echo off
echo ========================================
echo Building...
echo ========================================

if not exist .build mkdir .build

echo.
echo [Compiling] all .asm files...
for %%f in (*.asm) do (
    echo   Compiling %%f...
    nasm -f win64 %%f -o .build/%%~nf.obj
    if errorlevel 1 (
        echo [ERROR] Failed to compile %%f!
        pause
        exit /b 1
    )
)

echo.
echo [Linking]...
gcc -mwindows -o .build/hello.exe .build/*.obj

if errorlevel 1 (
    echo [ERROR] Linking failed!
    pause
    exit /b 1
)

echo [Success] hello.exe created in .build/ folder!
echo.
echo Running hello.exe...
echo.
.build\hello.exe
echo.
pause
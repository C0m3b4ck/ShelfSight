@echo off
REM ShelfSight — Windows 9x (95/98/Me) Build Script
REM Requires: MinGW (old i686-w32-mingw32), Qt 4.8.x, Windows 9x SDK
REM
REM This build uses Qt 4.8 because Qt 5+ dropped Windows 9x support.
REM Qt 4.8 must be cross-compiled or installed natively on a 9x-compatible system.
REM MinGW from the Qt 4.8 era (MinGW 4.x or earlier) is recommended.
REM
REM Place this script in the project root next to src/
REM Run from a MinGW shell or MSYS environment.

setlocal enabledelayedexpansion

set SCRIPT_DIR=%~dp0
set SRC_DIR=%SCRIPT_DIR%..\src
set BUILD_DIR=%SCRIPT_DIR%..\build\windows-9x
set QT_DIR=C:\Qt\4.8.7
set MINGW_DIR=C:\MinGW

echo.
echo ==========================================
echo   ShelfSight — Windows 9x Build
echo   (Windows 95 / 98 / Me)
echo ==========================================
echo.

REM ── Check environment ──────────────────────────────────────────────
echo [BUILD] Checking environment...

if not exist "%QT_DIR%\bin\qmake.exe" (
    echo [FAIL] Qt 4.8 not found at %QT_DIR%
    echo        Install Qt 4.8.7 to %QT_DIR% or set QT_DIR
    exit /b 1
)
if not exist "%MINGW_DIR%\bin\g++.exe" (
    echo [FAIL] MinGW not found at %MINGW_DIR%
    echo        Install MinGW 4.x to %MINGW_DIR% or set MINGW_DIR
    exit /b 1
)

set PATH=%QT_DIR%\bin;%MINGW_DIR%\bin;%PATH%
echo [  OK] Environment ready

REM ── Check dependencies ─────────────────────────────────────────────
echo [BUILD] Checking libraries...

REM libsodium for Windows 9x — use pre-built static library
REM Download from: https://download.libsodium.org/libsodium/releases/
set LIBSODIUM_DIR=%SCRIPT_DIR%..\libsodium-win32
if not exist "%LIBSODIUM_DIR%\lib\libsodium.a" (
    echo [WARN] libsodium not found at %LIBSODIUM_DIR%
    echo        Download libsodium 1.0.18 Win32 from:
    echo        https://download.libsodium.org/libsodium/releases/libsodium-1.0.18-msvc.zip
    echo        Extract to %LIBSODIUM_DIR% with lib\libsodium.a and include\sodium\
    set /p INSTALL_LIBS="Download libsodium now? (y/n): "
    if /i "!INSTALL_LIBS!"=="y" (
        echo [BUILD] Please download manually and re-run this script
    )
    exit /b 1
)

echo [  OK] Libraries found

REM ── Create build directory ─────────────────────────────────────────
echo [BUILD] Preparing build directory...
if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"
mkdir "%BUILD_DIR%"
echo [  OK] Build directory ready: %BUILD_DIR%

REM ── Build SQLiteCpp ────────────────────────────────────────────────
echo [BUILD] Building SQLiteCpp...
cd /d "%SRC_DIR%\sqlitecpp"
qmake sqlitecpp.pro CONFIG+=release "QMAKE_CC=gcc" "QMAKE_CXX=g++"
mingw32-make -j4
if not exist "libSQLiteCpp.a" (
    echo [FAIL] SQLiteCpp build failed
    exit /b 1
)
echo [  OK] SQLiteCpp built

REM ── Build ShelfSight ───────────────────────────────────────────────
echo [BUILD] Building ShelfSight...
cd /d "%SRC_DIR%\app"
qmake app.pro CONFIG+=release "QMAKE_CC=gcc" "QMAKE_CXX=g++"
mingw32-make -j4
if not exist "ShelfSight.exe" (
    echo [FAIL] ShelfSight build failed
    exit /b 1
)
echo [  OK] ShelfSight.exe built

REM ── Package ────────────────────────────────────────────────────────
echo [BUILD] Packaging...
mkdir "%BUILD_DIR%\ShelfSight"
copy "%SRC_DIR%\app\ShelfSight.exe" "%BUILD_DIR%\ShelfSight\"
copy "%SCRIPT_DIR%..\LICENSE" "%BUILD_DIR%\ShelfSight\" 2>nul

REM Copy Qt 4.8 runtime DLLs for 9x
copy "%QT_DIR%\bin\QtCore4.dll" "%BUILD_DIR%\ShelfSight\" 2>nul
copy "%QT_DIR%\bin\QtGui4.dll" "%BUILD_DIR%\ShelfSight\" 2>nul
copy "%QT_DIR%\bin\QtSql4.dll" "%BUILD_DIR%\ShelfSight\" 2>nul
copy "%MINGW_DIR%\bin\mingwm10.dll" "%BUILD_DIR%\ShelfSight\" 2>nul

echo.
echo [  OK] Build complete!
echo        Output: %BUILD_DIR%\ShelfSight
echo        Qt DLLs included for Windows 9x compatibility
echo.

endlocal

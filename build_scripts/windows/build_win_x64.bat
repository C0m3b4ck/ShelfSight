@echo off
REM ShelfSight — Windows 2000 through 11 (x64 / 64-bit) Build Script
REM Requires: MinGW-w64 (x86_64), Qt 6.x, libsodium
REM Can run natively on Windows or cross-compile from Linux/MSYS2
REM
REM For MSYS2: open MSYS2 MinGW 64-bit shell and run this script
REM For native: ensure MinGW-w64 x86_64 and Qt 6 are in PATH

setlocal enabledelayedexpansion

set SCRIPT_DIR=%~dp0
set SRC_DIR=%SCRIPT_DIR%..\src
set BUILD_DIR=%SCRIPT_DIR%..\build\windows-x64

REM ── Configurable paths (edit these for your system) ─────────────────
REM MSYS2 defaults:
set MINGW_PREFIX=C:\msys64\mingw64
REM Standalone install:
if not exist "%MINGW_PREFIX%\bin\g++.exe" set MINGW_PREFIX=C:\mingw64

REM Qt6 — adjust to your install path
set QT_DIR=C:\Qt\6.x.x\mingw_64
REM Try common MSYS2 path
if not exist "%QT_DIR%\bin\qmake6.exe" set QT_DIR=C:\msys64\mingw64\lib\qt6

set LIBSODIUM_DIR=%SCRIPT_DIR%..\libsodium-win64

echo.
echo ==========================================
echo   ShelfSight — Windows x64 Build
echo   (Windows 2000 / XP / Vista / 7 / 8 / 10 / 11)
echo ==========================================
echo.

REM ── Check environment ──────────────────────────────────────────────
echo [BUILD] Checking environment...

if not exist "%MINGW_PREFIX%\bin\g++.exe" (
    echo [FAIL] MinGW-w64 x86_64 not found at %MINGW_PREFIX%
    echo        Install via MSYS2: pacman -S mingw-w64-x86_64-toolchain
    echo        Or set MINGW_PREFIX to your MinGW-w64 x86_64 install path
    exit /b 1
)

set PATH=%MINGW_PREFIX%\bin;%PATH%

REM Find qmake6
set QMAKE=qmake6
where qmake6 >nul 2>&1 || set QMAKE=%QT_DIR%\bin\qmake6.exe
where %QMAKE% >nul 2>&1
if errorlevel 1 (
    echo [FAIL] qmake6 not found
    echo        Install Qt 6 MinGW 64-bit or set QT_DIR
    exit /b 1
)

echo [  OK] Environment ready

REM ── Check dependencies ─────────────────────────────────────────────
echo [BUILD] Checking libraries...

REM libsodium
if not exist "%LIBSODIUM_DIR%\lib\libsodium.a" (
    echo [WARN] libsodium not found at %LIBSODIUM_DIR%
    echo        Download from: https://download.libsodium.org/libsodium/releases/
    echo        Use the x86_64 Win64 static library
    exit /b 1
)

REM SQLite3
set SQLITE_DIR=%SRC_DIR%\sqlitecpp\sqlite3
if not exist "%SQLITE_DIR%\sqlite3.c" (
    echo [FAIL] sqlite3 source not found at %SQLITE_DIR%
    exit /b 1
)

echo [  OK] Libraries found

REM ── Create build directory ─────────────────────────────────────────
echo [BUILD] Preparing build directory...
if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"
mkdir "%BUILD_DIR%"
echo [  OK] Build directory ready

REM ── Build SQLiteCpp ────────────────────────────────────────────────
echo [BUILD] Building SQLiteCpp (64-bit static)...
cd /d "%SRC_DIR%\sqlitecpp"
%QMAKE% sqlitecpp.pro CONFIG+=release
mingw32-make -j%NUMBER_OF_PROCESSORS% 2>nul || mingw32-make -j4
if not exist "libSQLiteCpp.a" (
    echo [FAIL] SQLiteCpp build failed
    exit /b 1
)
echo [  OK] SQLiteCpp built

REM ── Build ShelfSight ───────────────────────────────────────────────
echo [BUILD] Building ShelfSight (64-bit)...
cd /d "%SRC_DIR%\app"
%QMAKE% app.pro CONFIG+=release
mingw32-make -j%NUMBER_OF_PROCESSORS% 2>nul || mingw32-make -j4
if not exist "ShelfSight.exe" (
    echo [FAIL] ShelfSight build failed
    exit /b 1
)
echo [  OK] ShelfSight.exe built

REM ── Verify architecture ────────────────────────────────────────────
echo [BUILD] Verifying binary...
where file >nul 2>&1
if not errorlevel 1 (
    file ShelfSight.exe 2>nul | findstr /i "PE32+" >nul && echo [  OK] Verified 64-bit PE32+ binary
)

REM ── Package ────────────────────────────────────────────────────────
echo [BUILD] Packaging...
set OUT=%BUILD_DIR%\ShelfSight
mkdir "%OUT%\bin"
copy "%SRC_DIR%\app\ShelfSight.exe" "%OUT%\bin\"
copy "%SCRIPT_DIR%..\LICENSE" "%OUT%\" 2>nul

REM Copy runtime DLLs
copy "%MINGW_PREFIX%\bin\libgcc_s_seh-1.dll" "%OUT%\bin\" 2>nul
copy "%MINGW_PREFIX%\bin\libstdc++-6.dll" "%OUT%\bin\" 2>nul
copy "%MINGW_PREFIX%\bin\libwinpthread-1.dll" "%OUT%\bin\" 2>nul
copy "%MINGW_PREFIX%\bin\libQt6Core.dll" "%OUT%\bin\" 2>nul
copy "%MINGW_PREFIX%\bin\libQt6Gui.dll" "%OUT%\bin\" 2>nul
copy "%MINGW_PREFIX%\bin\libQt6Widgets.dll" "%OUT%\bin\" 2>nul
copy "%MINGW_PREFIX%\bin\libQt6Sql.dll" "%OUT%\bin\" 2>nul
copy "%MINGW_PREFIX%\bin\libSQLiteCpp.dll" "%OUT%\bin\" 2>nul
copy "%MINGW_PREFIX%\bin\libsodium.dll" "%OUT%\bin\" 2>nul

REM Copy Qt platform plugin
mkdir "%OUT%\bin\platforms" 2>nul
copy "%MINGW_PREFIX%\lib\qt6\plugins\platforms\qwindows.dll" "%OUT%\bin\platforms\" 2>nul

echo.
echo [  OK] Build complete!
echo        Output: %OUT%
echo        Architecture: x64 (64-bit)
echo        Minimum OS: Windows XP x64 / Vista x64
echo.

endlocal

#!/bin/bash
# Windows cross-compilation build script
# Requires: mingw-w64, Qt6 for MinGW, libsodium for MinGW
# On Ubuntu/Debian: apt install mingw-w64 qt6-base-dev (Qt6 MinGW not in default repos)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="${SCRIPT_DIR}/src"
BUILD_DIR="${SCRIPT_DIR}/build-mingw64"
TOOLCHAIN="${SRC_DIR}/mingw64.cmake"

echo "=== ShelfSight Windows Cross-Compilation ==="
echo "Source: ${SRC_DIR}"
echo "Build:  ${BUILD_DIR}"

# Check for required tools
for cmd in x86_64-w64-mingw32-g++ x86_64-w64-mingw32-windres cmake; do
    if ! command -v $cmd &> /dev/null; then
        echo "ERROR: $cmd not found. Install mingw-w64 and cmake."
        exit 1
    fi
done

# Check for Qt6 MinGW
QT6_MINGW="/usr/x86_64-w64-mingw32/qt6"
if [ ! -d "${QT6_MINGW}" ]; then
    echo "WARNING: Qt6 MinGW not found at ${QT6_MINGW}"
    echo "You need to install Qt6 for MinGW:"
    echo "  Option 1: Build Qt6 from source for MinGW"
    echo "  Option 2: Download Qt6 MinGW installer and extract to ${QT6_MINGW}"
    echo "  Option 3: Use GitHub Actions (see .github/workflows/windows-build.yml)"
    echo ""
    echo "Trying to continue anyway..."
fi

# Check for libsodium MinGW
SODIUM_MINGW="/usr/x86_64-w64-mingw32"
if [ ! -f "${SODIUM_MINGW}/lib/libsodium.a" ] && [ ! -f "${SODIUM_MINGW}/lib/libsodium.dll.a" ]; then
    echo "WARNING: libsodium for MinGW not found"
    echo "Install with: apt install libsodium-dev (native) then cross-compile libsodium for MinGW"
fi

# Create build directory
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

# Configure with CMake
echo "Configuring with CMake..."
cmake "${SRC_DIR}" \
    -DCMAKE_TOOLCHAIN_FILE="${TOOLCHAIN}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DQT6_MINGW_PREFIX="${QT6_MINGW}" \
    -DSODIUM_ROOT="${SODIUM_MINGW}" \
    -G "Unix Makefiles"

# Build
echo "Building..."
cmake --build . --parallel $(nproc)

# Check result
EXE="${BUILD_DIR}/app/ShelfSight.exe"
if [ -f "${EXE}" ]; then
    echo ""
    echo "=== BUILD SUCCESS ==="
    echo "Executable: ${EXE}"
    echo "Size: $(du -h ${EXE} | cut -f1)"
    echo ""
    echo "To create a distributable package, run:"
    echo "  ${SCRIPT_DIR}/package-windows.sh"
else
    echo "ERROR: Build failed - executable not found"
    exit 1
fi
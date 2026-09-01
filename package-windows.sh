#!/bin/bash
# Create Windows distribution package
# Run after successful build-windows.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build-mingw64"
EXE="${BUILD_DIR}/app/Release/ShelfSight.exe"
QT6_MINGW="/usr/x86_64-w64-mingw32/qt6"
DIST_DIR="${SCRIPT_DIR}/ShelfSight-Windows"
ZIP_NAME="ShelfSight-Windows-$(date +%Y%m%d).zip"

if [ ! -f "${EXE}" ]; then
    echo "ERROR: ${EXE} not found. Run build-windows.sh first."
    exit 1
fi

echo "Creating distribution package..."

# Clean previous
rm -rf "${DIST_DIR}"
mkdir -p "${DIST_DIR}"

# Copy executable
cp "${EXE}" "${DIST_DIR}/"

# Copy Qt6 DLLs
echo "Copying Qt6 DLLs..."
for dll in Qt6Core Qt6Widgets Qt6Gui Qt6Sql Qt6Network; do
    find "${QT6_MINGW}" -name "${dll}.dll" -exec cp {} "${DIST_DIR}/" \; 2>/dev/null || echo "  WARNING: ${dll}.dll not found"
done

# Copy SQLite3
find "${QT6_MINGW}" -name "libsqlite3*.dll" -exec cp {} "${DIST_DIR}/" \; 2>/dev/null || echo "  WARNING: sqlite3 dll not found"

# Copy libsodium
find /usr/x86_64-w64-mingw32 -name "libsodium*.dll" -exec cp {} "${DIST_DIR}/" \; 2>/dev/null || echo "  WARNING: libsodium dll not found"

# Copy Qt plugins
echo "Copying Qt plugins..."
mkdir -p "${DIST_DIR}/platforms"
cp "${QT6_MINGW}/plugins/platforms/qwindows.dll" "${DIST_DIR}/platforms/" 2>/dev/null || echo "  WARNING: qwindows.dll not found"

mkdir -p "${DIST_DIR}/sqldrivers"
cp "${QT6_MINGW}/plugins/sqldrivers/qsqlite.dll" "${DIST_DIR}/sqldrivers/" 2>/dev/null || echo "  WARNING: qsqlite.dll not found"

mkdir -p "${DIST_DIR}/styles"
cp "${QT6_MINGW}/plugins/styles/qwindowsvistastyle.dll" "${DIST_DIR}/styles/" 2>/dev/null || true

# Copy icon resources if any
mkdir -p "${DIST_DIR}/resources"

# Create README
cat > "${DIST_DIR}/README.txt" << 'EOF'
ShelfSight - Library Management System
======================================

Version: 1.0.0
Build Date: $(date)

Files:
  ShelfSight.exe          - Main application
  Qt6*.dll                - Qt6 runtime libraries
  libsqlite3-0.dll        - SQLite3 database engine
  libsodium.dll           - Cryptography library
  platforms/qwindows.dll  - Windows platform plugin
  sqldrivers/qsqlite.dll  - SQLite database driver

Requirements:
  - Windows 10/11 (64-bit)
  - No installation required - portable application

Usage:
  1. Extract all files to a folder
  2. Run ShelfSight.exe
  3. On first run, create or select database files
  4. Register a SuperAdmin account to access all features

Default databases (created in app directory):
  - books.db
  - readers.db
  - loans.db
  - users.db

Admin Features (SuperAdmin only):
  - Database Selection / Create Database
  - Convert Old Databases (Bookworm CSV import)
  - Backups
  - Accounts Management
  - Troubleshooting
  - Worklog Statistics

License: See LICENSE file
EOF

# Create zip
echo "Creating zip archive..."
cd "${SCRIPT_DIR}"
if command -v 7z &> /dev/null; then
    7z a -tzip "${ZIP_NAME}" "${DIST_DIR}/*"
elif command -v zip &> /dev/null; then
    zip -r "${ZIP_NAME}" "${DIST_DIR}"
else
    echo "ERROR: Neither 7z nor zip found. Install p7zip-full or zip."
    exit 1
fi

echo ""
echo "=== PACKAGE CREATED ==="
echo "Directory: ${DIST_DIR}"
echo "Archive:   ${SCRIPT_DIR}/${ZIP_NAME}"
echo "Size:      $(du -h "${SCRIPT_DIR}/${ZIP_NAME}" | cut -f1)"
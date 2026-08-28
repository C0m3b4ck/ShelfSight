#!/bin/sh
# ShelfSight — FreeBSD i386 (x86) Build Script
# Run natively on FreeBSD i386 installations
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$(cd "$SCRIPT_DIR/../../src" && pwd)"
BUILD_DIR="$SCRIPT_DIR/../../build/freebsd-x86"
JOBS=$(sysctl -n hw.ncpu 2>/dev/null || echo 4)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log()  { printf "${CYAN}[BUILD]${NC} %s\n" "$1"; }
ok()   { printf "${GREEN}[  OK]${NC} %s\n" "$1"; }
warn() { printf "${YELLOW}[WARN]${NC} %s\n" "$1"; }
fail() { printf "${RED}[FAIL]${NC} %s\n" "$1"; exit 1; }

# ── Install dependencies ─────────────────────────────────────────────
install_deps() {
    log "Checking dependencies..."
    local NEED=()
    command -v c++  &>/dev/null || NEED+=("llvm15")
    command -v qmake6 &>/dev/null || NEED+=("qt6-base")
    pkg info -e libsodium &>/dev/null 2>&1 || NEED+=("libsodium")
    pkg info -e sqlite3 &>/dev/null 2>&1 || NEED+=("sqlite3")
    pkg info -e qt6-base &>/dev/null 2>&1 || NEED+=("qt6-base")
    pkg info -e qt6-sql-sqlite &>/dev/null 2>&1 || NEED+=("qt6-sql-sqlite")

    if [ ${#NEED[@]} -eq 0 ]; then
        ok "All dependencies found"
        return 0
    fi

    warn "Missing packages: ${NEED[*]}"
    printf "Install them now? [Y/n] "
    read -r ANSWER
    case "$ANSWER" in
        [Nn]*) fail "Cannot build without dependencies" ;;
    esac

    sudo pkg install -y llvm15 qt6-base qt6-sql-sqlite libsodium sqlite3
    ok "Dependencies installed"
}

clean_build() {
    log "Cleaning build directory..."
    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR"
    ok "Build directory ready: $BUILD_DIR"
}

build_sqlitecpp() {
    log "Building SQLiteCpp (static library)..."
    cd "$SRC_DIR/sqlitecpp"
    qmake6 sqlitecpp.pro CONFIG+=release
    make -j"$JOBS" 2>&1 | tail -3
    if [ ! -f libSQLiteCpp.a ]; then
        fail "SQLiteCpp build failed"
    fi
    ok "SQLiteCpp built"
}

build_app() {
    log "Building ShelfSight..."
    cd "$SRC_DIR/app"
    qmake6 app.pro CONFIG+=release
    make -j"$JOBS" 2>&1 | tail -3
    if [ ! -f ShelfSight ]; then
        fail "ShelfSight build failed"
    fi
    ok "ShelfSight built"
}

package() {
    log "Packaging..."
    local OUT="$BUILD_DIR/ShelfSight"
    mkdir -p "$OUT/bin"
    cp "$SRC_DIR/app/ShelfSight" "$OUT/bin/"

    cat > "$OUT/ShelfSight.sh" << 'LAUNCHER'
#!/bin/sh
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
exec "$SCRIPT_DIR/bin/ShelfSight" "$@"
LAUNCHER
    chmod +x "$OUT/ShelfSight.sh"

    cp "$SCRIPT_DIR/../../LICENSE" "$OUT/" 2>/dev/null || true

    local SIZE=$(du -sh "$OUT" | cut -f1)
    ok "Package ready: $OUT ($SIZE)"
}

echo ""
echo "=========================================="
echo "  ShelfSight — FreeBSD i386 (x86) Build"
echo "=========================================="
echo ""

install_deps
clean_build
build_sqlitecpp
build_app
package

echo ""
ok "Build complete!"
echo ""

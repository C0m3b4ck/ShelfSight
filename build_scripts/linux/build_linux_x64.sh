#!/bin/bash
# ShelfSight — Linux x86_64 Build Script
# Targets: Ubuntu 18.04+, Debian 10+, Fedora 30+, Arch, openSUSE
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$(cd "$SCRIPT_DIR/../../src" && pwd)"
BUILD_DIR="$SCRIPT_DIR/../../build/linux-x64"
INSTALL_PREFIX="/opt/ShelfSight"
JOBS=$(nproc 2>/dev/null || echo 4)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log()  { echo -e "${CYAN}[BUILD]${NC} $1"; }
ok()   { echo -e "${GREEN}[  OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
fail() { echo -e "${RED}[FAIL]${NC} $1"; exit 1; }

# ── Detect package manager ───────────────────────────────────────────
detect_pkgmgr() {
    if command -v apt-get &>/dev/null; then
        echo "apt"
    elif command -v dnf &>/dev/null; then
        echo "dnf"
    elif command -v pacman &>/dev/null; then
        echo "pacman"
    elif command -v zypper &>/dev/null; then
        echo "zypper"
    else
        echo "unknown"
    fi
}

# ── Install dependencies ─────────────────────────────────────────────
install_deps() {
    log "Checking dependencies..."
    local PKGMGR=$(detect_pkgmgr)

    local NEED_INSTALL=()
    command -v g++      &>/dev/null || NEED_INSTALL+=("g++")
    command -v qmake6   &>/dev/null || NEED_INSTALL+=("qt6-base-dev")
    pkg-config --exists sqlite3 2>/dev/null || NEED_INSTALL+=("libsqlite3-dev")
    pkg-config --exists libsodium 2>/dev/null || NEED_INSTALL+=("libsodium-dev")

    if [ ${#NEED_INSTALL[@]} -eq 0 ]; then
        ok "All dependencies found"
        return 0
    fi

    warn "Missing packages: ${NEED_INSTALL[*]}"
    read -rp "Install them now? [Y/n] " ANSWER
    if [[ "$ANSWER" =~ ^[Nn] ]]; then
        fail "Cannot build without dependencies"
    fi

    case "$PKGMGR" in
        apt)
            sudo apt-get update -qq
            sudo apt-get install -y -qq g++ qt6-base-dev libsqlite3-dev libsodium-dev 2>/dev/null \
                || sudo apt-get install -y -qq g++ qt6-base-dev-tools libqt6sql6-sqlite libsodium-dev 2>/dev/null
            ;;
        dnf)
            sudo dnf install -y gcc-c++ qt6-qtbase-devel sqlite-devel libsodium-devel
            ;;
        pacman)
            sudo pacman -S --noconfirm base-devel qt6-base sqlite libsodium
            ;;
        zypper)
            sudo zypper install -y gcc-c++ libqt6base-devel sqlite3-devel libsodium-devel
            ;;
        *)
            fail "Unsupported package manager. Install g++, Qt6, sqlite3, libsodium manually"
            ;;
    esac
    ok "Dependencies installed"
}

# ── Clean build directory ────────────────────────────────────────────
clean_build() {
    log "Cleaning build directory..."
    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR"
    ok "Build directory ready: $BUILD_DIR"
}

# ── Build SQLiteCpp ──────────────────────────────────────────────────
build_sqlitecpp() {
    log "Building SQLiteCpp (static library)..."
    cd "$SRC_DIR/sqlitecpp"
    qmake6 sqlitecpp.pro CONFIG+=release
    make -j"$JOBS" 2>&1 | tail -3
    if [ ! -f libSQLiteCpp.a ]; then
        fail "SQLiteCpp build failed"
    fi
    ok "SQLiteCpp built successfully"
}

# ── Build ShelfSight ─────────────────────────────────────────────────
build_app() {
    log "Building ShelfSight..."
    cd "$SRC_DIR/app"
    qmake6 app.pro CONFIG+=release
    make -j"$JOBS" 2>&1 | tail -3

    if [ ! -f ShelfSight ]; then
        fail "ShelfSight build failed"
    fi
    ok "ShelfSight built successfully"
}

# ── Package ──────────────────────────────────────────────────────────
package() {
    log "Packaging..."
    local OUT="$BUILD_DIR/ShelfSight"
    mkdir -p "$OUT/bin"
    cp "$SRC_DIR/app/ShelfSight" "$OUT/bin/"

    cat > "$OUT/ShelfSight.sh" << 'LAUNCHER'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
exec "$SCRIPT_DIR/bin/ShelfSight" "$@"
LAUNCHER
    chmod +x "$OUT/ShelfSight.sh"

    cat > "$OUT/install.sh" << INSTALL
#!/bin/bash
set -e
sudo mkdir -p $INSTALL_PREFIX
sudo cp -r "$OUT"/* $INSTALL_PREFIX/
sudo chmod +x $INSTALL_PREFIX/ShelfSight.sh
echo "Installed to $INSTALL_PREFIX"
echo "Run: $INSTALL_PREFIX/ShelfSight.sh"
INSTALL
    chmod +x "$OUT/install.sh"

    cp "$SCRIPT_DIR/../../LICENSE" "$OUT/" 2>/dev/null || true

    local SIZE=$(du -sh "$OUT" | cut -f1)
    ok "Package ready: $OUT ($SIZE)"
    ok "Install: cd $OUT && sudo ./install.sh"
}

# ── Main ─────────────────────────────────────────────────────────────
echo ""
echo "=========================================="
echo "  ShelfSight — Linux x86_64 Build"
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

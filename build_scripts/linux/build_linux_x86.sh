#!/bin/bash
# ShelfSight — Linux i686 (x86) Build Script
# Cross-compiles 32-bit binary on 64-bit host, or native on 32-bit systems
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$(cd "$SCRIPT_DIR/../../src" && pwd)"
BUILD_DIR="$SCRIPT_DIR/../../build/linux-x86"
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

ARCH=$(uname -m)
IS_64BIT=false
[ "$ARCH" = "x86_64" ] || [ "$ARCH" = "amd64" ] && IS_64BIT=true

# ── Detect package manager ───────────────────────────────────────────
detect_pkgmgr() {
    if command -v apt-get &>/dev/null; then echo "apt"
    elif command -v dnf &>/dev/null; then echo "dnf"
    elif command -v pacman &>/dev/null; then echo "pacman"
    else echo "unknown"
    fi
}

# ── Install dependencies ─────────────────────────────────────────────
install_deps() {
    log "Checking dependencies..."
    local PKGMGR=$(detect_pkgmgr)

    if $IS_64BIT; then
        log "Detected 64-bit host — will cross-compile for 32-bit"
        local NEED=()
        dpkg --print-architecture 2>/dev/null | grep -q i386 || NEED+=("gcc-multilib" "g++-multilib")
        command -v qmake6 &>/dev/null || NEED+=("qt6-base-dev")

        if [ ${#NEED[@]} -gt 0 ]; then
            warn "Need: ${NEED[*]}"
            read -rp "Install them now? [Y/n] " ANSWER
            if [[ ! "$ANSWER" =~ ^[Nn] ]]; then
                case "$PKGMGR" in
                    apt)
                        sudo dpkg --add-architecture i386
                        sudo apt-get update -qq
                        sudo apt-get install -y -qq gcc-multilib g++-multilib \
                            qt6-base-dev:amd64 \
                            libsqlite3-dev:i386 libsodium-dev:i386 \
                            libqt6sql6-sqlite:i386 2>/dev/null \
                        || sudo apt-get install -y -qq gcc-multilib g++-multilib \
                            qt6-base-dev libsqlite3-dev libsodium-dev
                        ;;
                    dnf)
                        sudo dnf install -y glibc-devel.i686 libgcc.i686 \
                            qt6-qtbase-devel sqlite-devel libsodium-devel
                        ;;
                    *)
                        fail "Install 32-bit dev packages manually"
                        ;;
                esac
            fi
        fi
    else
        log "Detected 32-bit host — native build"
        local NEED=()
        command -v g++ &>/dev/null    || NEED+=("g++")
        command -v qmake6 &>/dev/null || NEED+=("qt6-base-dev")

        if [ ${#NEED[@]} -gt 0 ]; then
            warn "Need: ${NEED[*]}"
            read -rp "Install them now? [Y/n] " ANSWER
            if [[ ! "$ANSWER" =~ ^[Nn] ]]; then
                case "$PKGMGR" in
                    apt) sudo apt-get install -y -qq g++ qt6-base-dev libsqlite3-dev libsodium-dev ;;
                    dnf) sudo dnf install -y gcc-c++ qt6-qtbase-devel sqlite-devel libsodium-devel ;;
                    *) fail "Install dependencies manually" ;;
                esac
            fi
        fi
    fi
    ok "Dependencies ready"
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
    log "Building SQLiteCpp (32-bit static library)..."
    cd "$SRC_DIR/sqlitecpp"

    local QMAKE_EXTRA=""
    if $IS_64BIT; then
        QMAKE_EXTRA="QMAKE_CC=m32 QMAKE_CXX=m32"
    fi

    qmake6 sqlitecpp.pro CONFIG+=release $QMAKE_EXTRA
    make clean 2>/dev/null || true
    make -j"$JOBS" 2>&1 | tail -3
    if [ ! -f libSQLiteCpp.a ]; then
        fail "SQLiteCpp build failed"
    fi
    ok "SQLiteCpp built"
}

# ── Build ShelfSight ─────────────────────────────────────────────────
build_app() {
    log "Building ShelfSight (32-bit)..."
    cd "$SRC_DIR/app"

    local QMAKE_EXTRA=""
    if $IS_64BIT; then
        QMAKE_EXTRA="QMAKE_CC=m32 QMAKE_CXX=m32"
    fi

    qmake6 app.pro CONFIG+=release $QMAKE_EXTRA
    make clean 2>/dev/null || true
    make -j"$JOBS" 2>&1 | tail -3

    if [ ! -f ShelfSight ]; then
        fail "ShelfSight build failed"
    fi

    file ShelfSight | grep -q "32-bit\|ELF 32" && ok "Verified 32-bit binary" || warn "Could not verify binary architecture"
    ok "ShelfSight built"
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

    cp "$SCRIPT_DIR/../../LICENSE" "$OUT/" 2>/dev/null || true

    local SIZE=$(du -sh "$OUT" | cut -f1)
    ok "Package ready: $OUT ($SIZE)"
}

# ── Main ─────────────────────────────────────────────────────────────
echo ""
echo "=========================================="
echo "  ShelfSight — Linux i686 (x86) Build"
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

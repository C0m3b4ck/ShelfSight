#!/bin/sh
# Build ShelfSight as ONE C++ executable with Tcl/Tk and a Tcl/Tk GUI embedded.
#
#   ./tclpack/build_single.sh [appdir] [main.tcl] [output]
#
#   appdir   directory containing the GUI (default: ../app   -- a vTcl app)
#   main.tcl main script inside appdir (default: same name as appdir + ".tcl")
#   output   output binary name     (default: ../shelfSight_single)
#
# Produces a single self-contained binary: statically linked Tcl/Tk +
# libshelf.a + the whole appdir embedded (extracted to ~/.cache at startup).
#
# Requires: g++, tcl8.6-dev, tk8.6-dev, zlib1g-dev, python3
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$DIR/.." && pwd)"

APPDIR="${1:-$ROOT/app}"
MAIN="${2:-$(basename "$APPDIR").tcl}"
OUT="${3:-$ROOT/shelfSight_single}"

test -f "$APPDIR/$MAIN" || {
    echo "error: $APPDIR/$MAIN not found" >&2
    exit 1
}

echo "==> [1/3] packing $APPDIR into embedded_data.cpp"
python3 "$DIR/pack.py" "$DIR/embedded_data.cpp" "$APPDIR"

echo "==> [2/3] compiling (app=$APPDIR, main=$MAIN)"
g++ -std=c++11 -O2 -I/usr/include/tcl8.6 \
    -DSHELF_APP_DIR=\"$(basename "$APPDIR")\" \
    -DSHELF_MAIN=\"$MAIN\" \
    "$DIR/main.cpp" \
    "$DIR/embedded_data.cpp" \
    "$ROOT/libshelf.a" \
    /usr/lib/x86_64-linux-gnu/libtk8.6.a \
    /usr/lib/x86_64-linux-gnu/libtcl8.6.a \
    -lstdc++ -lz -lX11 -lXft -lfontconfig -lXext -lXss \
    -ldl -lm -lpthread \
    -o "$OUT"

echo "==> [3/3] done"
ls -lh "$OUT"
echo "Note: libshelf.a is linked statically; if it uses more libs, add them to the link line."

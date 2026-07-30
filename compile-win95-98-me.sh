#!/usr/bin/env bash
# ShelfSight - Win95/98/Me x86 build
# Requires: i686-w64-mingw32-g++ (apt install mingw-w64)
# GLFW NOTE: GLFW 3.x requires Win98+.  For true Win95 use the WIN32 backend
#             (imgui_impl_win32) by replacing the GLFW backend in the compile list.
set -e
ROOT="$(cd "$(dirname "$0")" && pwd)"
OUT="shelfSight_win95_x86.exe"
CXX="i686-w64-mingw32-g++"
CXXFLAGS="-std=c++11 -O2 -s -ffunction-sections -fdata-sections -Wl,--gc-sections"
CXXFLAGS="$CXXFLAGS -mwindows -I$ROOT/src -I$ROOT/src/imgui"

SRC="
    $ROOT/src/main.cpp
    $ROOT/src/file_man.cpp
    $ROOT/src/glob_vars.cpp
    $ROOT/src/menu_cli.cpp
    $ROOT/src/gui_imgui.cpp
    $ROOT/src/imgui/imgui.cpp
    $ROOT/src/imgui/imgui_draw.cpp
    $ROOT/src/imgui/imgui_tables.cpp
    $ROOT/src/imgui/imgui_widgets.cpp
    $ROOT/src/imgui/imgui_impl_glfw.cpp
    $ROOT/src/imgui/imgui_impl_opengl2.cpp
"

LIBS="-lglfw3 -lopengl32 -lgdi32 -luser32 -lkernel32"

echo "==> Compiling ShelfSight for Win95/98/Me (i686)..."
$CXX $CXXFLAGS -o $OUT $SRC $LIBS
echo "==> Done: $OUT"
strip $OUT
ls -lh $OUT

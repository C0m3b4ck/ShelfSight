#!/usr/bin/env bash
# ShelfSight - Win2000 through Win11 x64 build
# Requires: x86_64-w64-mingw32-g++ (apt install mingw-w64)
set -e
ROOT="$(cd "$(dirname "$0")" && pwd)"
OUT="shelfSight_win2k-win11_x64.exe"
CXX="x86_64-w64-mingw32-g++"
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

echo "==> Compiling ShelfSight for Win2000–Win11 x64..."
$CXX $CXXFLAGS -o $OUT $SRC $LIBS
echo "==> Done: $OUT"
strip $OUT
ls -lh $OUT

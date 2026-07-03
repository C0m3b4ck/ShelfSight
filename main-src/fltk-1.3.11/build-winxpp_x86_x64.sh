#!/usr/bin/env bash
set -euo pipefail

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export CFLAGS="-D_WIN32_WINNT=0x0501"
export CXXFLAGS="-D_WIN32_WINNT=0x0501"

bash ./configure --host=x86_64-w64-mingw32 --disable-shared --enable-images --enable-forms --disable-xft
make -j"$(nproc)"

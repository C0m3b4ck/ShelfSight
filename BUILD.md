# Building ShelfSight

ShelfSight is a Qt 6 C++17 desktop application built with **qmake**. All release builds are fully static.

## Prerequisites

| Component | Debian/Ubuntu | Arch | Windows (MSYS2) |
|-----------|--------------|------|-----------------|
| C++17 compiler | `g++` | `gcc` | MinGW-w64 (`mingw-w64-x86_64-gcc` or `mingw-w64-i686-gcc`) |
| Qt 6 | `qt6-base-dev` | `qt6-base` | `mingw-w64-x86_64-qt6-base` / `mingw-w64-i686-qt6-base` |
| SQLite 3 | `libsqlite3-dev` | `sqlite` | `mingw-w64-x86_64-sqlite3` / `mingw-w64-i686-sqlite3` |
| libsodium | `libsodium-dev` | `libsodium` | `mingw-w64-x86_64-libsodium` / `mingw-w64-i686-libsodium` |
| qmake | `qt6-base-dev-tools` | `qt6-base` | Included with Qt6 |

## Building

### Quick build (dynamic, for development)

```bash
cd src
# Build SQLiteCpp library
cd sqlitecpp
qmake6 sqlitecpp.pro CONFIG+=release
make -j$(nproc)

# Build application
cd ../app
qmake6 app.pro CONFIG+=release
make -j$(nproc)
./ShelfSight
```

### Static build (for distribution)

#### Linux x64 (in Docker, reproducible)

```bash
docker run --rm -v /path/to/ShelfSight:/workspace \
  -w /workspace ubuntu:22.04 bash -c '
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -qq
  apt-get install -y -qq g++ make pkg-config wget xz-utils cmake file \
    libsqlite3-dev libsodium-dev zlib1g-dev libgl-dev libegl-dev \
    qt6-base-dev libqt6sql6-sqlite

  cd /workspace/src/sqlitecpp
  qmake6 sqlitecpp.pro CONFIG+=release
  make -j$(nproc)

  cd /workspace/src/app
  qmake6 app.pro CONFIG+=release \
    "QMAKE_CFLAGS+=-static" "QMAKE_CXXFLAGS+=-static" \
    "QMAKE_LFLAGS+=-static"
  make -j$(nproc)
  strip -s ShelfSight
'
```

#### Linux x86 cross-compile (in Docker)

Requires `g++-12-i686-linux-gnu` cross-compiler and i386 dev libraries. The full build script is at `/tmp/build-all-static.sh` (Docker-based, reproducible).

Key flags for qmake:
```
"QMAKE_CC=i686-linux-gnu-gcc-12"
"QMAKE_CXX=i686-linux-gnu-g++-12"
"QMAKE_LINK=i686-linux-gnu-g++-12"
"QMAKE_CFLAGS+=-static"
"QMAKE_CXXFLAGS+=-static"
"QMAKE_LFLAGS+=-static"
```

#### Windows x64 (MSYS2 MinGW64)

```bash
# In MSYS2 MinGW64 shell:
cd src/sqlitecpp
qmake6 sqlitecpp.pro CONFIG+=release
make -j$(nproc)

cd ../app
qmake6 app.pro CONFIG+=release \
  "QMAKE_CFLAGS+=-static" "QMAKE_CXXFLAGS+=-static" \
  "QMAKE_LFLAGS+=-static-libgcc -static-libstdc++"
make -j$(nproc)
strip ShelfSight.exe
```

#### Windows x86 (MSYS2 MinGW32)

Same as x64 but in the MSYS2 MinGW32 shell. Produces 32-bit PE executable compatible with Windows 2000+.

### Flatpak

A Flatpak manifest is provided at `flatpak/com.github.C0m3b4ck.ShelfSight.yml`:

```bash
flatpak-builder build-dir flatpak/com.github.C0m3b4ck.ShelfSight.yml
```

## Packaging

Release archives are built into `build/`:
- `ShelfSight-linux-x64-static.tar.gz`
- `ShelfSight-linux-x86-static.tar.gz`
- `ShelfSight-windows-x64-static.zip`
- `ShelfSight-windows-x86-static.zip`

Each archive contains:
- `bin/ShelfSight` or `bin/ShelfSight.exe` — the static binary
- `ShelfSight.sh` (Linux only) — launcher script

## Architecture

- **qmake** build system (not CMake)
- **Qt 6.5** widgets, GUI, SQL modules
- **SQLiteCpp** — lightweight C++ SQLite wrapper (built as static lib)
- **libsodium** — Argon2id password hashing and crypto
- All dependencies linked statically for zero-runtime-dependency distribution

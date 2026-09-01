# MinGW-w64 x86_64 toolchain for Qt6 cross-compilation
# Usage: cmake -DCMAKE_TOOLCHAIN_FILE=mingw64.cmake -B build-mingw

set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR x86_64)

# Cross compiler
set(CMAKE_C_COMPILER x86_64-w64-mingw32-gcc)
set(CMAKE_CXX_COMPILER x86_64-w64-mingw32-g++)
set(CMAKE_RC_COMPILER x86_64-w64-mingw32-windres)

# Qt6 for MinGW - must be installed separately
# Typical locations:
# - /usr/x86_64-w64-mingw32/qt6 (if installed via package manager)
# - /opt/qt6-mingw (custom install)
# - C:/Qt/6.x/mingw_64 (Windows host)

set(QT6_MINGW_PREFIX "/usr/x86_64-w64-mingw32/qt6" CACHE PATH "Qt6 MinGW installation prefix")

# Find Qt6 using the MinGW prefix
set(CMAKE_PREFIX_PATH ${QT6_MINGW_PREFIX} ${CMAKE_PREFIX_PATH})
set(CMAKE_FIND_ROOT_PATH ${QT6_MINGW_PREFIX} ${CMAKE_FIND_ROOT_PATH})

# Search for libraries in target directories only
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# Sodium for MinGW
set(SODIUM_ROOT "/usr/x86_64-w64-mingw32" CACHE PATH "Sodium MinGW root")

# Static linking flags for MinGW
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static-libgcc -static-libstdc++ -Wl,-Bstatic -lstdc++ -lpthread -Wl,-Bdynamic")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -static-libgcc -static-libstdc++")

# Windows subsystem
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--subsystem,windows")

# Disable QT_FEATURE_xxx for cross-compilation
set(QT_FEATURE_dbus OFF)
set(QT_FEATURE_openssl OFF)
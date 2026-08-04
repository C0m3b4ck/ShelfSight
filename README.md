# ShelfSight ![GitHub All Releases](https://img.shields.io/github/downloads/C0m3b4ck/ShelfSight/total)
**🇪🇺🇪🇺🇪🇺Made in Europe🇪🇺🇪🇺🇪🇺**
[🇵🇱 Przeczytaj po polsku!](https://github.com/C0m3b4ck/ShelfSight/tree/main/README_PL.md)

## About
ShelfSight is a program for managing libraries both large and small, private or public. It is ***free, open-source, cross-platform and has legacy-support***
A successor to BookwormVB, it is intended to be ***more robust, more efficient and safer***, while having ***broader OS support and better functionality*** than Bibliotekarz.NET in the Polish freeware sphere. 
## Installation
- ***1. Open the "Releases" page on the right-hand side of the page.***
- ***2. Choose the latest release (the one on top).***
- ***3. Download the package that matches your system:***

| Type		| Description |
| ------------- | ----------- |
| **Portable**  | '.7z' archive file, extract using **7zip** and run the binary file inside the extracted folder (**.exe on Windows**). |
| **Installer** | A program that moves the program files to a directory specified by the user (**for example, %APPDATA% on Windows**). |
| **Standalone** | Just the program binary (**.exe on Windows**) - **download and run**. |
## Supported Operating Systems
| Platform | Versions | Architecture | Packages |
| -------- | -------- | ------------ | -------- |
| Microsoft Windows | Versions from XP to 11 (all Windows Server Editions from 2003 to 2025 | x86 and x64 | pre-packaged 'portable', 'installer' and 'standalone'. |
| Linux distributions | Kernel versions from [minimum kernel currently unknown] to 7.x.x | x86 and x64 | 'portable', 'installer' and 'standalone' |
| Microsoft Windows (Legacy) | Windows 2000, NT4, Me, 98, 95 | x86 | Packages might not be provided, support for Legacy versions will be finished after 1.0 release. |
| Microsoft Windows (CE) | Windows CE 2, 3, 4, 5, 6, .NET 4.1, .NET 4.2 | ARM | Support will be considered after MS Windows Legacy support is finalized. |
| Apple MacOS | **(THEORETICALLY)** supported | MacOS X and above | ARM and ARM64| Users need to compile themselves, there are no official MacOS binaries. | 

<img src="badges/95.svg" alt="Windows 95" width="64" /><img src="badges/98.webp" alt="Windows 98" width="64" /><img src="badges/me.svg" alt="Windows ME" width="64" /><img src="badges/nt4.svg" alt="Windows NT 4.0" width="64" /><img src="badges/2000professional.svg" alt="Windows 2000 Professional" width="64" /><img src="badges/2000server.svg" alt="Windows 2000 Server" width="64" /><img src="badges/xp.svg" alt="Windows XP" width="64" /><img src="badges/vista.svg" alt="Windows Vista" width="64" /><img src="badges/server2012.svg" alt="Windows Server 2012" width="64" /><img src="badges/7.svg" alt="Windows 7" width="64" /><img src="badges/8.svg" alt="Windows 8" width="64" /><img src="badges/10.svg" alt="Windows 10" width="64" /><img src="badges/11.svg" alt="Windows 11" width="64" /><img src="badges/linux.webp" alt="Linux" width="64" /><img src="badges/macos.png" alt="MacOS" width="64" />

The badges are meant to represent compatibility. Badges with the word "certified" ARE A VISUAL REPRESENTATION ONLY. This project is not endorsed nor certified by Microsoft.
Downloaded from https://logos.fandom.com/wiki/Microsoft_Windows/Compatible

## Build
### Prerequisites
- CMake >= 3.16 and a C++17 compiler
- [wxWidgets](https://www.wxwidgets.org) 3.x (`libwxgtk3.2-dev` on Debian/Ubuntu)
- SQLite 3 (`libsqlite3-dev`)
- OpenSSL (`libssl-dev`)

### Build
```bash
cd ShelfSight/src
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build -j
ctest --test-dir build        # optional: run headless backend tests
./build/shelfsight [--db <path>]   # --db overrides the database file
```

### Project layout
```
src/
├── backend/     # framework-independent logic (SQLite data layer, crypto, auth, library)
│   └── test_backend.cpp   # headless backend tests (SQL-injection safe paths covered)
├── gui/         # wxWidgets UI (main frame, panels)
├── main.cpp     # wxApp entry point
└── CMakeLists.txt
```
The backend has no GUI dependency and can be built and tested on its own.
## Documentation
- Docs are available in */DOCS/* subfolder. 
- User manuals will be made after 1.0 release.
- For now, check out development videos: https://www.youtube.com/watch?v=Hd-j296d3xY&list=PL_FbJyFLAmlil2avw-L_tHQugj_nknzCE 
## Credits
### Started on June 19th, 2026, by C0m3b4ck. 
### Libraries used:
- [wxWidgets](https://www.wxwidgets.org), a cross-platform C++ GUI toolkit,
- [SQLite](https://www.sqlite.org), a lightweight embedded SQL database,
- [OpenSSL](https://www.openssl.org), for SHA-256 hashing and AES-256-CBC encryption


# ShelfSight ![GitHub All Releases](https://img.shields.io/github/downloads/C0m3b4ck/ShelfSight/total)
**🇪🇺🇪🇺🇪🇺Made in Europe🇪🇺🇪🇺🇪🇺**
[🇵🇱 Przeczytaj po polsku!](https://github.com/C0m3b4ck/ShelfSight/tree/main/README_PL.md)

---

> **ShelfSight Beta — Ready for Testing**
>
> The beta is now available for public testing. If you find a bug, have a suggestion, or want to contribute, please open an issue on the [Issues](https://github.com/C0m3b4ck/ShelfSight/issues) page.
>
> **What's new in this build:**
> - **Worklog** — Session-based change tracking for books, readers, and loans. Every add, edit, and remove is logged with timestamps and can be reviewed in the new Worklog Statistics viewer or exported to file.
> - **Worklog Statistics** — View aggregated counts and individual entries from the current session, available under *Help > Worklog Statistics*.
> - **SuperAdmin-only account controls** — Changing roles and overwriting usernames/passwords for other users now requires SuperAdmin privileges.
> - **Password change support** — SuperAdmins can change other users' passwords directly from the Accounts page. The old password hash is replaced with a freshly Argon2id-hashed value.
> - **Telemetry & Worklog settings** — Both telemetry and worklog can be toggled independently from *Settings > Preferences*.

---

## About
ShelfSight is a program for managing libraries both large and small, private or public. It is ***free, open-source, cross-platform and has legacy-support***
A successor to BookwormVB, it is intended to be ***more robust, more efficient and safer***, while having ***broader OS support and better functionality*** than Bibliotekarz.NET in the Polish freeware sphere. 

### Features
- **Book Management** - Add, edit, search, and soft-delete books with title, author, category, location, and status tracking
- **Reader Management** - Manage library members with student IDs, contact details, and borrowing history
- **Loan System** - Create loans with configurable durations, mark books as returned, track overdue loans, and generate overdue reports
- **Categories & Locations** - Organize books by custom categories and physical locations
- **User Authentication** - Role-based access control with User, Admin, and Superadmin roles; password hashing with libsodium
- **Database Configuration** - Connect to multiple SQLite databases, save/load database configurations, and create new database sets
- **Search & Filter** - Full-text search across all entities with field-specific filtering
- **Undo System** - Undo support for entity modifications (add, edit, remove)
- **Telemetry** - Optional local telemetry logging for usage analytics (no data sent externally)
- **Worklog** - Session-based change tracking for books, readers, and loans with timestamped entries and a statistics viewer
- **Soft Deletion** - Entities are soft-deleted (marked as deleted) rather than permanently removed, preserving data integrity

## Installation

All builds are **fully static** — no DLLs, shared libraries, or runtime dependencies needed. Just extract and run.

### Download
Go to [Releases](https://github.com/C0m3b4ck/ShelfSight/releases) and grab the archive for your platform:

| Platform | File | Notes |
| -------- | ---- | ----- |
| **Windows x64** | `ShelfSight-windows-x64-static.zip` | Windows XP x64 through 11 |
| **Windows x86** | `ShelfSight-windows-x86-static.zip` | Windows 2000 through 11 |
| **Linux x64** | `ShellSight-linux-x64-static.tar.gz` | Any x86_64 distro |
| **Linux x86** | `ShelfSight-linux-x86-static.tar.gz` | Any i686 distro |

### Windows
Extract the zip and run `bin\ShelfSight.exe`. No installation needed.

### Linux
```bash
tar xzf ShelfSight-linux-x64-static.tar.gz
cd ShelfSight-linux-x64
./ShelfSight.sh
```

### Flatpak
A Flatpak manifest is included at `flatpak/com.github.C0m3b4ck.ShelfSight.yml`.
## Supported Operating Systems
| Platform | Versions | Architecture | Packages |
| -------- | -------- | ------------ | -------- |
| Microsoft Windows | Versions from XP to 11 (all Windows Server Editions from 2003 to 2025 | x86 and x64 | pre-packaged 'portable', 'installer' and 'standalone'. |
| Linux distributions | Kernel versions from [minimum kernel currently unknown] to 7.x.x | x86 and x64 | 'portable', 'installer' and 'standalone' |
| Microsoft Windows (Legacy) | Windows 2000, NT4, Me, 98, 95 | x86 | Packages might not be provided, support for Legacy versions will be finished after 1.0 release. |
| Microsoft Windows (CE) | Windows CE 2, 3, 4, 5, 6, .NET 4.1, .NET 4.2 | ARM | Support will be considered after MS Windows Legacy support is finalized. |
| Apple MacOS | **(THEORETICALLY)** supported | MacOS X and above | ARM and ARM64| Users need to compile themselves, there are no official MacOS binaries. | 

<img src="badges/95.svg" alt="Windows 95" width="64" /><img src="badges/98.webp" alt="Windows 98" width="64" /><img src="badges/me.svg" alt="Windows ME" width="64" /><img src="badges/nt4.svg" alt="Windows NT 4.0" width="64" /><img src="badges/2000professional.svg" alt="Windows 2000 Professional" width="64" /><img src="badges/2000server.svg" alt="Windows 2000 Server" width="64" /><img src="badges/xp.svg" alt="Windows XP" width="64" /><img src="badges/vista.svg" alt="Windows Vista" width="64" /><img src="badges/server2012.svg" alt="Windows Server 2012" width="64" /><img src="badges/7.svg" alt="Windows 7" width="64" /><img src="badges/8.svg" alt="Windows 8" width="64" /><img src="badges/10.svg" alt="Windows 10" width="64" /><img src="badges/11.svg" alt="Windows 11" width="64" /><img src="badges/linux.webp" alt="Linux" width="64" /><img src="badges/macos.png" alt="MacOS" width="64" />

The badges are meant to represent compatibility. Badges with the word "certified", "developed for" or other ARE A VISUAL REPRESENTATION ONLY. This project is not endorsed nor certified by Microsoft.
Downloaded from https://logos.fandom.com/wiki/Microsoft_Windows/Compatible

## Build
### Prerequisites
- g++ (or MSYS2 MinGW for Windows)
- [Qt](https://www.qt.io) 6.x with static libs (`qt6-base-dev` on Debian/Ubuntu)
- SQLite 3 (`libsqlite3-dev`)
- libsodium (`libsodium-dev`)
- qmake6

For full build instructions see [BUILD.md](BUILD.md).

### Project layout
```
src/
├── app/          # Main application (Qt6 widgets, business logic, crypto, SQLite data access)
│   ├── main.cpp
│   ├── mainwindow.cpp/h
│   ├── businesslogic.cpp/h
│   ├── crypto.cpp/h
│   └── sqlite_dataaccess.cpp/h
├── sqlitecpp/    # SQLiteCpp static library
├── .pro          # qmake project files
└── build_scripts/
```
### Architecture
ShelfSight uses a layered architecture separating concerns:
- **Domain layer** (`domain.h`) - Data models (Book, Reader, Loan, User) with DTOs for serialization
- **Data access layer** (`sqlite_dataaccess.h/cpp`) - SQLite persistence with thread-safe operations
- **Business logic layer** (`businesslogic.h/cpp`) - Validation rules and CRUD orchestration
- **GUI layer** (`mainwindow.h/cpp`) - Qt 6 interface with workspace-based navigation

Each entity (books, readers, loans, users) has its own SQLite database file, keeping data isolated and manageable.

### Security
- Passwords are hashed using **libsodium** (Argon2) with per-user salts
- Input sanitization prevents SQL injection attacks
- Role-based access control restricts operations by user role
- Role changes and password overwrites are restricted to **SuperAdmin** accounts only
- Headless backend tests cover SQL-injection-safe paths

## Documentation
- Docs are available in */DOCS/* subfolder. 
- User and developer manuals will be made after 1.0 release.
- For now, check out development videos: https://www.youtube.com/watch?v=Hd-j296d3xY&list=PL_FbJyFLAmlil2avw-L_tHQugj_nknzCE 
## Credits
### Started on June 19th, 2026, by C0m3b4ck. 
### Libraries used:
- [Qt](https://www.qt.io), a cross-platform C++ GUI toolkit,
- [SQLite](https://www.sqlite.org), a lightweight embedded SQL database,
- [libsodium](https://libsodium.gitbook.io), for Argon2id password hashing and cryptographic operations


# critcl instructions (ShelfSight)

Build Tcl command bindings for the ShelfSight C++ functions and load them in a
plain `wish`/`tclsh`, using critcl. This is the "GUI-first" path: your GUI is
written in Tcl and only the heavy lifting (dates, DB files, crypto) stays in C++.

## How it works

1. `shim.cpp` - thin `extern "C"` wrappers around the real C++ functions.
2. `libshelf.a` - static library: your real C++ files + the shim.
3. `gui.tcl` - Tcl script that uses critcl to compile a `.so`/`.dll` extension
   on first run, linking `libshelf.a`, and registering `shelf_*` Tcl commands.

`critcl/` is the vendored critcl 3.3.1 package (repo-local, no system install).

## 1. shim.cpp

C++ mangles names, so the C compiler critcl uses cannot call your functions
directly. The shim exposes them as `extern "C"`:

```cpp
#include "file_man.h"
#include <cstdlib>
#include <string>

static char* to_cstr(const std::string& s) {
    char* out = static_cast<char*>(malloc(s.size() + 1));
    if (out == nullptr) return nullptr;
    std::copy(s.begin(), s.end(), out);
    out[s.size()] = '\0';
    return out;
}

extern "C" const char* shelf_today(void) {
    return to_cstr(get_current_date_str());
}

extern "C" const char* shelf_add_days(const char* date, int days) {
    return to_cstr(add_days_to_date(date ? date : "", days));
}
```

Returning `char*` (heap) lets the critcl C glue copy it into a Tcl string and
`free()` it - no leaking `std::string` across the C boundary.

## 2. Build the static library

```sh
g++ -std=c++11 -O2 -fPIC -c src/file_man.cpp src/glob_vars.cpp shim.cpp -Isrc
ar rcs libshelf.a file_man.o glob_vars.o shim.o
rm -f file_man.o glob_vars.o shim.o
```

> `-fPIC` is mandatory - critcl links `libshelf.a` into a shared object and
> non-PIC code will fail to link.

## 3. gui.tcl

```tcl
lappend auto_path [file join [file dirname [file normalize [info script]]] critcl]
package require critcl
package require md5

proc ::critcl::md5_hex {s} {
    if {$::critcl::v::uuidcounter} {
        return [format %032d [incr ::critcl::v::uuidcounter]]
    }
    return [::md5::md5 [encoding convertto utf-8 $s]]
}

critcl::clibraries ./libshelf.a
critcl::ldflags -lstdc++

critcl::ccode {
#include <stdlib.h>
    extern const char* shelf_today(void);
    extern const char* shelf_add_days(const char*, int);
}

critcl::ccommand shelf_today {cd ip objc objv} {
    if (objc != 1) { Tcl_WrongNumArgs(ip, 1, objv, ""); return TCL_ERROR; }
    const char* s = shelf_today();
    Tcl_SetObjResult(ip, Tcl_NewStringObj(s, -1));
    free((void*)s);
    return TCL_OK;
}

critcl::ccommand shelf_add_days {cd ip objc objv} {
    if (objc != 3) { Tcl_WrongNumArgs(ip, 1, objv, "date days"); return TCL_ERROR; }
    int days;
    if (Tcl_GetIntFromObj(ip, objv[2], &days) != TCL_OK) return TCL_ERROR;
    const char* r = shelf_add_days(Tcl_GetStringFromObj(objv[1], NULL), days);
    Tcl_SetObjResult(ip, Tcl_NewStringObj(r, -1));
    free((void*)r);
    return TCL_OK;
}

puts "today + 14 = [shelf_add_days [shelf_today] 14]"
```

Notes on the API used here (critcl 3.3.1):
- `critcl::c` was removed in 3.x - use `critcl::ccode` for raw C blocks and
  `critcl::ccommand name {cd ip objc objv} { body }` for commands.
- The `md5_hex` override above is required because the vendored tree lacks the
  prebuilt `critcl_md5c` C accelerator (it's itself built by critcl, so it
  would never bootstrap). The bundled pure-Tcl `md5` package replaces it.

## 4. Run

```sh
tclsh gui.tcl
```

First run compiles into `~/.critcl/linux-unknown-x86_64/`. The resulting
`v331_*.so` is a normal Tcl extension - copy it (plus `libshelf.a` deps) to
the target machine; critcl itself does not ship.

## Extending to the other shelf_* functions

Add a wrapper in `shim.cpp`, re-run step 2, add an `extern` to the `ccode`
block and a `ccommand` in `gui.tcl`. The existing bindings in `src/gui_tcl.cpp`
are a reference for arg validation and return conventions.

## Win95 compatibility

- Tcl/Tk **8.4.x is the last line that runs on Windows 95**. Tcl 8.5 needs
  Win98+, 8.6 needs 2000+. Final release: 8.4.20.
- critcl only runs on the **build** machine (a dev box, here Linux). The
  `.so`/`.dll` it produces is what runs on the target.
- To produce a Win95 `.dll` you must cross-compile against **Tcl 8.4 headers**
  with an old toolchain (i686 mingw GCC 3.x, or MSVC 6.0). An extension built
  against Tcl 8.6 headers will not load in Tcl 8.4, and modern compilers emit
  code that Win95 cannot run.
- **ttk is a Tk 8.5+ feature.** The embedded GUI in `src/gui_tcl.cpp` uses
  `ttk::` widgets and therefore will NOT work under Tcl/Tk 8.4 on Win95. For a
  Win95 build, the Tcl GUI must use classic widgets (`button`, `entry`,
  `label`, `listbox`, `menu`, ...).

## ClassyTk?

Not needed. `gui.tcl` is plain Tcl/Tk and runs under stock `wish`. ClassyTk is
an optional separate widget set/builder (built on the ClassyTcl object system);
you would only adopt it if you specifically want its widgets or its `cbuild`
drag-and-drop builder. Nothing here depends on it.

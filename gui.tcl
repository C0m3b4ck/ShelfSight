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
    extern int add_ints(int, int);
    extern const char* shelf_today(void);
    extern const char* shelf_add_days(const char*, int);
}

critcl::ccommand add_ints {cd ip objc objv} {
    if (objc != 3) { Tcl_WrongNumArgs(ip, 1, objv, "a b"); return TCL_ERROR; }
    int a, b;
    if (Tcl_GetIntFromObj(ip, objv[1], &a) != TCL_OK) return TCL_ERROR;
    if (Tcl_GetIntFromObj(ip, objv[2], &b) != TCL_OK) return TCL_ERROR;
    Tcl_SetObjResult(ip, Tcl_NewIntObj(add_ints(a, b)));
    return TCL_OK;
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

puts "add_ints(3, 4)          = [add_ints 3 4]"
set today [shelf_today]
puts "today                   = $today"
puts "today + 14 days         = [shelf_add_days $today 14]"
puts "today + 365 days        = [shelf_add_days $today 365]"

/*
 * Windows needs to know which symbols to export.  Unix does not.
 * BUILD_Class should be undefined for Unix.
 */
#include "tcl.h"

#ifdef BUILD_ClassyTk
#undef TCL_STORAGE_CLASS
#define TCL_STORAGE_CLASS DLLEXPORT
#endif /* BUILD_Class */

EXTERN int Classytk_Init(Tcl_Interp *interp);


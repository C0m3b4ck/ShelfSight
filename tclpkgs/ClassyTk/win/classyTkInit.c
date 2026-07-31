#include "tcl.h"
#include "tk.h"
#include "classyTk.h"
#include <sys/types.h>
#include <time.h>
#include <math.h>

extern int Classy_GetOpenFileCmd _ANSI_ARGS_((ClientData clientData,
	Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[]));
extern int Classy_GetSaveFileCmd _ANSI_ARGS_((ClientData clientData,
	Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[]));
extern int Classy_GetFontCmd _ANSI_ARGS_((ClientData clientData,
	Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[]));
extern int Classy_ExportCanvasCmd _ANSI_ARGS_((ClientData clientData,
	Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[]));
extern int Classy_TaskbarPosCmd _ANSI_ARGS_((ClientData clientData,
	Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[]));

int
Classy_Init(interp)
	Tcl_Interp *interp;		/* Interpreter to add extra commands */
{
#ifdef USE_TCL_STUBS
	if (Tcl_InitStubs(interp, "8.1", 0) == NULL) {
		return TCL_ERROR;
	}
	if (Tk_InitStubs(interp, "8.1", 0) == NULL) {
		return TCL_ERROR;
	}
#endif
	Tcl_CreateObjCommand(interp, "Classy::GetOpenFile", Classy_GetOpenFileCmd,
		(ClientData) Tk_MainWindow(interp), (Tcl_CmdDeleteProc *)NULL);
	Tcl_CreateObjCommand(interp, "Classy::GetSaveFile", Classy_GetSaveFileCmd,
		(ClientData) Tk_MainWindow(interp), (Tcl_CmdDeleteProc *)NULL);
	Tcl_CreateObjCommand(interp, "Classy::GetFont", Classy_GetFontCmd,
		(ClientData) Tk_MainWindow(interp), (Tcl_CmdDeleteProc *)NULL);
	Tcl_CreateObjCommand(interp, "Classy::Export", Classy_ExportCanvasCmd,
		(ClientData) Tk_MainWindow(interp), (Tcl_CmdDeleteProc *)NULL);
	Tcl_CreateObjCommand(interp, "Classy::TaskbarPos", Classy_TaskbarPosCmd,
		(ClientData) Tk_MainWindow(interp), (Tcl_CmdDeleteProc *)NULL);
	return TCL_OK;
}




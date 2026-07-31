#include "tcl.h"
#include "class.h"
#include <sys/types.h>
#include <time.h>
#include <math.h>

extern int Classy_ReinitObjCmd _ANSI_ARGS_((ClientData clientData,
	Tcl_Interp *interp, int argc, char *argv[]));
extern int Classy_SuperObjCmd _ANSI_ARGS_((ClientData clientData,
	Tcl_Interp *interp, int argc, char *argv[]));
extern int Classy_PrivateObjCmd _ANSI_ARGS_((ClientData clientData,
	Tcl_Interp *interp, int argc, char *argv[]));
extern int Classy_SetPrivateObjCmd _ANSI_ARGS_((ClientData clientData,
	Tcl_Interp *interp, int argc, char *argv[]));
extern int Classy_GetPrivateObjCmd _ANSI_ARGS_((ClientData clientData,
	Tcl_Interp *interp, int argc, char *argv[]));
extern int Classy_PrivateVarObjCmd _ANSI_ARGS_((ClientData clientData,
	Tcl_Interp *interp, int argc, char *argv[]));
extern void Classy_InitSuper();

int
Class_Init(interp)
	Tcl_Interp *interp;		/* Interpreter to add extra commands */
{
#ifdef USE_TCL_STUBS
        if (Tcl_InitStubs(interp, "8.1", 0) == NULL) {
                return TCL_ERROR;
        }
#endif
	Tcl_CreateObjCommand(interp,"::Class::reinit",(Tcl_ObjCmdProc *)Classy_ReinitObjCmd,
		(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
	Classy_InitSuper();
	Tcl_CreateObjCommand(interp,"super",(Tcl_ObjCmdProc *)Classy_SuperObjCmd,
		(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
	Tcl_CreateObjCommand(interp,"private",(Tcl_ObjCmdProc *)Classy_PrivateObjCmd,
		(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
	Tcl_CreateObjCommand(interp,"setprivate",(Tcl_ObjCmdProc *)Classy_SetPrivateObjCmd,
		(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
	Tcl_CreateObjCommand(interp,"getprivate",(Tcl_ObjCmdProc *)Classy_GetPrivateObjCmd,
		(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
	Tcl_CreateObjCommand(interp,"privatevar",(Tcl_ObjCmdProc *)Classy_PrivateVarObjCmd,
		(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
	return TCL_OK;
}



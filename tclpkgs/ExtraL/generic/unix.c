#include "tcl.h"
#include "extral.h"

#ifdef unix

#include <sys/types.h>
#include <unistd.h>

/*
 *----------------------------------------------------------------------
 *
 * ExtraL_SetUidObjCmd --
 *
 * Results:
 *		A standard Tcl result.
 *
 *
 *----------------------------------------------------------------------
 */

int
ExtraL_SetUidObjCmd(dummy, interp, objc, objv)
	ClientData dummy;		/* Not used. */
	Tcl_Interp *interp;		/* Current interpreter. */
	int objc;			/* Number of arguments. */
	Tcl_Obj *CONST objv[];	/* Argument objects. */
{
	int uid,error;
	if ((objc != 2) && (objc != 3)) {
		Tcl_WrongNumArgs(interp, 1, objv, "uid ?gid?");
		return TCL_ERROR;
	}
	error = Tcl_GetIntFromObj(interp,objv[1],&uid);
	if (error) {return error;}
	setuid((uid_t)uid);
	if (objc != 3) {
		error = Tcl_GetIntFromObj(interp,objv[2],&uid);
		if (error) {return error;}
		setgid((uid_t)uid);
	}
	return TCL_OK;
}

#endif

/*	
 *	 File:    extral.c
 *	 Purpose: extraL extension to Tcl
 *	 Author:  Copyright (c) 1995 Peter De Rijk
 *
 *	 See the file "README" for information on usage and redistribution
 *	 of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 */

#include <stdlib.h>
#include <string.h>
#include <malloc.h>
#include "tcl.h"
#include "general.h"
#define UCHAR(c) ((unsigned char) (c))

/*
 *----------------------------------------------------------------------
 *
 * ExtraL_Array_lgetObjCmd --
 *
 *----------------------------------------------------------------------
 */

int
ExtraL_Array_lgetObjCmd(notUsed, interp, objc, objv)
	ClientData notUsed;				 /* Not used. */
	Tcl_Interp *interp;					/* Current interpreter. */
	int objc;						/* Number of arguments. */
	Tcl_Obj *CONST objv[];	/* Argument objects. */
{
	int listobjc;
	Tcl_Obj **listobjv;
	int i;
	/*
		array set try {a 1 b 2 c 3 d 4 e 5 f 6}
		array_lget try {a d g f}
		array_lget try {a d g f} null
	*/
	Tcl_Obj *defval = NULL, *result, *element;
	if ((objc != 3)&&(objc != 4)) {
		Tcl_WrongNumArgs(interp, 1, objv, "arrayName list ?alldefault?");
		return TCL_ERROR;
	}
	if (Tcl_ListObjGetElements(interp, objv[2], &listobjc, &listobjv) != TCL_OK) {
		return TCL_ERROR;
	}
	if (objc == 4) {
		defval = objv[3];
	}
	i = 0;
	result = Tcl_NewObj();
	while(i<listobjc) {
		element = Tcl_ObjGetVar2(interp,objv[1],listobjv[i],0);
		if (element != NULL) {
			if (objc != 4) Tcl_ListObjAppendElement(interp, result, listobjv[i]);
			Tcl_ListObjAppendElement(interp, result, element);
		} else if (objc == 4) {
			Tcl_ListObjAppendElement(interp, result, defval);
		}
		i++;
	}
	Tcl_SetObjResult(interp,result);
	return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * ExtraL_Array_lappendObjCmd --
 *
 *----------------------------------------------------------------------
 */

int
ExtraL_Array_lappendObjCmd(notUsed, interp, objc, objv)
	ClientData notUsed;				 /* Not used. */
	Tcl_Interp *interp;					/* Current interpreter. */
	int objc;						/* Number of arguments. */
	Tcl_Obj *CONST objv[];	/* Argument objects. */
{
	int listobjc;
	Tcl_Obj **listobjv;
	int len;
	int i;
	if (objc != 3) {
		Tcl_WrongNumArgs(interp, 1, objv, "arrayName list");
		return TCL_ERROR;
	}
	if (Tcl_ListObjGetElements(interp, objv[2], &listobjc, &listobjv) != TCL_OK) {
		return TCL_ERROR;
	}
	i=0;
	len=listobjc-1;
	while(i<len) {
		Tcl_ObjSetVar2(interp, objv[1], listobjv[i], listobjv[i+1], TCL_APPEND_VALUE|TCL_LIST_ELEMENT);
		i+=2;
	}
	return TCL_OK;
}

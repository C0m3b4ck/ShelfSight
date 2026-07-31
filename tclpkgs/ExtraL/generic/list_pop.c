/*	
 *	 File:	extral.c
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
/*
 *----------------------------------------------------------------------
 *
 * ExtraL_List_popCmd --
 *
 *		This procedure is invoked to process the "list_pop" command.
 *		It pops an item out of a list
 *
 * Results:
 *		A standard Tcl result: the popped out elemeny.
 *
 *
 *----------------------------------------------------------------------
 */
int
ExtraL_List_popObjCmd(dummy, interp, objc, objv)
	ClientData dummy;		/* Not used. */
	Tcl_Interp *interp;		/* Current interpreter. */
	int objc;			/* Number of arguments. */
	Tcl_Obj **objv;		/* Argument objects. */
{
	register Tcl_Obj *listObjPtr;
	Tcl_Obj *popPtr, *newValuePtr;
	char *firstStr;
	int listLen;
	long index;
	int result;

	if ((objc != 2)&&(objc != 3)) {
		Tcl_WrongNumArgs(interp, 1, objv, "varName ?index?");
		return TCL_ERROR;
	}

	listObjPtr = Tcl_ObjGetVar2(interp, objv[1], (Tcl_Obj *) NULL,
		(TCL_LEAVE_ERR_MSG | TCL_PARSE_PART1));
	if (listObjPtr == NULL) {
		return TCL_ERROR;
	}

	result=Tcl_ListObjLength(interp,listObjPtr,&listLen);
	if (result==TCL_ERROR) {
		return TCL_ERROR;
	}		
	if (listLen==0) {
		return TCL_OK;
	}
	if (objc==2) {
		index = (listLen - 1);
	} else {
		firstStr = Tcl_GetStringFromObj(objv[2], (int *)NULL);
		if ((*firstStr == 'e') && (strcmp(firstStr, "end") == 0)) {
			index = (listLen - 1);
		} else {
			result=Tcl_GetLongFromObj(interp,objv[2],&index);
			if (result==TCL_ERROR) {
				return TCL_ERROR;
			}
		}
		if (index < 0)  {
			index = 0;
		}
		if (index >= listLen) {
			Tcl_ResetResult(interp);
			Tcl_AppendResult(interp, "list doesn't contain element ",firstStr, (char *) NULL);
			return TCL_ERROR;
		}
	}

	result = Tcl_ListObjIndex(interp,listObjPtr,index,&popPtr);
	if (result != TCL_OK) {
		return result;
	}
	Tcl_SetObjResult(interp,popPtr);

	if (Tcl_IsShared(listObjPtr)) {	
		listObjPtr = Tcl_DuplicateObj(listObjPtr);
	}
	result = Tcl_ListObjReplace(interp, listObjPtr, index, 1, 0, NULL);
	if (result != TCL_OK) {
		Tcl_DecrRefCount(listObjPtr);
		return result;
	}

	newValuePtr = Tcl_ObjSetVar2(interp, objv[1], (Tcl_Obj *) NULL,
		listObjPtr, (TCL_LEAVE_ERR_MSG | TCL_PARSE_PART1));
	if (newValuePtr == NULL) {
		Tcl_DecrRefCount(listObjPtr);
		return TCL_ERROR;
	}
	return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * ExtraL_List_shiftCmd --
 *
 *		This procedure is invoked to process the "lshift" command.
 *		It pops the first item out of a list
 *
 * Results:
 *		A standard Tcl result: the popped out elemeny.
 *
 *
 *----------------------------------------------------------------------
 */

int
ExtraL_List_shiftObjCmd(notUsed, interp, objc, objv)
	ClientData notUsed;				 /* Not used. */
	Tcl_Interp *interp;					/* Current interpreter. */
	int objc;			/* Number of arguments. */
	Tcl_Obj **objv;		/* Argument objects. */
{
	register Tcl_Obj *listObjPtr;
	Tcl_Obj *popPtr, *newValuePtr;
	int listLen;
	long index;
	int result;

	if ((objc != 2)&&(objc != 3)) {
		Tcl_WrongNumArgs(interp, 1, objv, "varName");
		return TCL_ERROR;
	}

	listObjPtr = Tcl_ObjGetVar2(interp, objv[1], (Tcl_Obj *) NULL,
		(TCL_LEAVE_ERR_MSG | TCL_PARSE_PART1));
	if (listObjPtr == NULL) {
		return TCL_ERROR;
	}

	result=Tcl_ListObjLength(interp,listObjPtr,&listLen);
	if (result==TCL_ERROR) {
		return TCL_ERROR;
	}		
	if (listLen==0) {
		return TCL_OK;
	}

	index=0;
	result = Tcl_ListObjIndex(interp,listObjPtr,index,&popPtr);
	if (result != TCL_OK) {
		return result;
	}
	Tcl_SetObjResult(interp,popPtr);

	if (Tcl_IsShared(listObjPtr)) {	
		listObjPtr = Tcl_DuplicateObj(listObjPtr);
	}
	result = Tcl_ListObjReplace(interp, listObjPtr, index, 1, 0, NULL);
	if (result != TCL_OK) {
		Tcl_DecrRefCount(listObjPtr);
		return result;
	}

	newValuePtr = Tcl_ObjSetVar2(interp, objv[1], (Tcl_Obj *) NULL,
		listObjPtr, (TCL_LEAVE_ERR_MSG | TCL_PARSE_PART1));
	if (newValuePtr == NULL) {
		Tcl_DecrRefCount(listObjPtr);
		return TCL_ERROR;
	}
	return TCL_OK;
}

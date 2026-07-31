/*	
 *	 File:    lmath.c
 *	 Purpose: extraL extension to Tcl
 *	 Author:  Copyright (c) 1995 Peter De Rijk
 *
 *	 See the file "README" for information on usage and redistribution
 *	 of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 */

#include <stdlib.h>
#include <string.h>
#include <malloc.h>
#include <math.h>
#include "tcl.h"
#include "general.h"
#define UCHAR(c) ((unsigned char) (c))
 
/*
 *----------------------------------------------------------------------
 *
 * ExtraL_Lmath_averageObjCmd --
 *
 *----------------------------------------------------------------------
 */

int
ExtraL_Lmath_averageObjCmd(notUsed, interp, objc, objv)
	ClientData notUsed;				 /* Not used. */
	Tcl_Interp *interp;					/* Current interpreter. */
	int objc;						/* Number of arguments. */
	Tcl_Obj *CONST objv[];	/* Argument objects. */
{
	int listobjc;
	Tcl_Obj **listobjv;
	double el,result;
	int i,error;
	if (objc != 2) {
		Tcl_WrongNumArgs(interp, 1, objv, "list");
		return TCL_ERROR;
	}
	if (Tcl_ListObjGetElements(interp, objv[1], &listobjc, &listobjv) != TCL_OK) {
		return TCL_ERROR;
	}
	result = 0.0;
	for (i = 0 ; i<listobjc ; i++) {
		error  = Tcl_GetDoubleFromObj(interp,listobjv[i],&el);
		if (error) {return error;}
		result += el;
	}
	Tcl_SetObjResult(interp,Tcl_NewDoubleObj(result/listobjc));
	return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * ExtraL_Lmath_maxObjCmd --
 *
 *----------------------------------------------------------------------
 */

int
ExtraL_Lmath_maxObjCmd(notUsed, interp, objc, objv)
	ClientData notUsed;				 /* Not used. */
	Tcl_Interp *interp;					/* Current interpreter. */
	int objc;						/* Number of arguments. */
	Tcl_Obj *CONST objv[];	/* Argument objects. */
{
	int listobjc;
	Tcl_Obj **listobjv;
	double el,result;
	int i,error,resultpos;
	if (objc != 2) {
		Tcl_WrongNumArgs(interp, 1, objv, "list");
		return TCL_ERROR;
	}
	if (Tcl_ListObjGetElements(interp, objv[1], &listobjc, &listobjv) != TCL_OK) {
		return TCL_ERROR;
	}
	if (listobjc == 0) {return TCL_OK;}
	error  = Tcl_GetDoubleFromObj(interp,listobjv[0],&el);
	if (error) {return error;}
	result = el;
	resultpos = 0;
	for (i = 1 ; i<listobjc ; i++) {
		error  = Tcl_GetDoubleFromObj(interp,listobjv[i],&el);
		if (error) {return error;}
		if (el > result) {
			result = el;
			resultpos = i;
		}
	}
	Tcl_SetObjResult(interp,listobjv[resultpos]);
	return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * ExtraL_Lmath_minObjCmd --
 *
 *----------------------------------------------------------------------
 */

int
ExtraL_Lmath_minObjCmd(notUsed, interp, objc, objv)
	ClientData notUsed;				 /* Not used. */
	Tcl_Interp *interp;					/* Current interpreter. */
	int objc;						/* Number of arguments. */
	Tcl_Obj *CONST objv[];	/* Argument objects. */
{
	int listobjc;
	Tcl_Obj **listobjv;
	double el,result;
	int i,error,resultpos;
	if (objc != 2) {
		Tcl_WrongNumArgs(interp, 1, objv, "list");
		return TCL_ERROR;
	}
	if (Tcl_ListObjGetElements(interp, objv[1], &listobjc, &listobjv) != TCL_OK) {
		return TCL_ERROR;
	}
	if (listobjc == 0) {return TCL_OK;}
	error  = Tcl_GetDoubleFromObj(interp,listobjv[0],&el);
	if (error) {return error;}
	result = el;
	resultpos = 0;
	for (i = 1 ; i < listobjc ; i++) {
		error  = Tcl_GetDoubleFromObj(interp,listobjv[i],&el);
		if (error) {return error;}
		if (el < result) {
			result = el;
			resultpos = i;
		}
	}
	Tcl_SetObjResult(interp,listobjv[resultpos]);
	return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * ExtraL_Lmath_sumObjCmd --
 *
 *----------------------------------------------------------------------
 */

int
ExtraL_Lmath_sumObjCmd(notUsed, interp, objc, objv)
	ClientData notUsed;				 /* Not used. */
	Tcl_Interp *interp;					/* Current interpreter. */
	int objc;						/* Number of arguments. */
	Tcl_Obj *CONST objv[];	/* Argument objects. */
{
	int listobjc;
	Tcl_Obj **listobjv;
	double el,result;
	int i,error;
	if (objc != 2) {
		Tcl_WrongNumArgs(interp, 1, objv, "list");
		return TCL_ERROR;
	}
	if (Tcl_ListObjGetElements(interp, objv[1], &listobjc, &listobjv) != TCL_OK) {
		return TCL_ERROR;
	}
	result = 0.0;
	for (i = 0 ; i<listobjc ; i++) {
		error  = Tcl_GetDoubleFromObj(interp,listobjv[i],&el);
		if (error) {return error;}
		result += el;
	}
	Tcl_SetObjResult(interp,Tcl_NewDoubleObj(result));
	return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * ExtraL_Lmath_calcObjCmd --
 *
 *----------------------------------------------------------------------
 */

int
ExtraL_getnum(interp, obj, typePtr, iPtr, dPtr)
	Tcl_Interp *interp;
	Tcl_Obj *CONST obj;
	char *typePtr;
	int *iPtr;
	double *dPtr;
{
	int error;
	error = Tcl_GetIntFromObj(interp,obj,iPtr);
	if (error) {
		error = Tcl_GetDoubleFromObj(interp,obj,dPtr);
		if (error) {return error;}
		*typePtr = 'd';
	} else {
		*typePtr = 'i';
	}
	return TCL_OK;
}

Tcl_Obj *ExtraL_docalc(calc,t1,el1i,el1d,t2,el2i,el2d)
	char calc;
	char t1;
	char t2;
	int el1i;
	int el2i;
	double el1d;
	double el2d;
{
	Tcl_Obj *resultEl = NULL;
	if ((t1 == 'i') && (t2 == 'i')) {
		if (calc == '+') {
			resultEl = Tcl_NewIntObj(el1i + el2i);
		} else if (calc == '-') {
			resultEl = Tcl_NewIntObj(el1i - el2i);
		} else if (calc == '*') {
			resultEl = Tcl_NewIntObj(el1i * el2i);
		} else if (calc == '/') {
			resultEl = Tcl_NewIntObj(el1i / el2i);
		} else if (calc == '|') {
			resultEl = Tcl_NewIntObj(el1i | el2i);
		}
	} else if ((t1 == 'i') && (t2 == 'd')) {
		if (calc == '+') {
			resultEl = Tcl_NewDoubleObj(el1i + el2d);
		} else if (calc == '-') {
			resultEl = Tcl_NewDoubleObj(el1i - el2d);
		} else if (calc == '*') {
			resultEl = Tcl_NewDoubleObj(el1i * el2d);
		} else if (calc == '/') {
			resultEl = Tcl_NewDoubleObj(el1i / el2d);
		} else if (calc == '|') {
			resultEl = Tcl_NewIntObj(el1i | el2i);
		}
	} else if ((t1 == 'd') && (t2 == 'i')) {
		if (calc == '+') {
			resultEl = Tcl_NewDoubleObj(el1d + el2i);
		} else if (calc == '-') {
			resultEl = Tcl_NewDoubleObj(el1d - el2i);
		} else if (calc == '*') {
			resultEl = Tcl_NewDoubleObj(el1d * el2i);
		} else if (calc == '/') {
			resultEl = Tcl_NewDoubleObj(el1d / el2i);
		} else if (calc == '|') {
			resultEl = Tcl_NewIntObj(el1i | el2i);
		}
	} else {
		if (calc == '+') {
			resultEl = Tcl_NewDoubleObj(el1d + el2d);
		} else if (calc == '-') {
			resultEl = Tcl_NewDoubleObj(el1d - el2d);
		} else if (calc == '*') {
			resultEl = Tcl_NewDoubleObj(el1d * el2d);
		} else if (calc == '/') {
			resultEl = Tcl_NewDoubleObj(el1d / el2d);
		} else if (calc == '|') {
			resultEl = Tcl_NewIntObj(el1i | el2i);
		}
	}
	return resultEl;
}

int
ExtraL_Lmath_calcObjCmd(notUsed, interp, objc, objv)
	ClientData notUsed;				 /* Not used. */
	Tcl_Interp *interp;					/* Current interpreter. */
	int objc;						/* Number of arguments. */
	Tcl_Obj *CONST objv[];	/* Argument objects. */
{
	int listobjc1,listobjc2;
	Tcl_Obj **listobjv1,**listobjv2,*result,*resultEl;
	char *string,t1,t2;
	int el1i,el2i,startpos=-1;
	double el1d,el2d;
	int i,error,len;
	if ((objc != 4) && (objc != 5)) {
		Tcl_WrongNumArgs(interp, 1, objv, "list1 action list2 ?startpos?");
		return TCL_ERROR;
	}
	if (objc == 5) {
		error = Tcl_GetIntFromObj(interp,objv[4],&startpos);
		if (error) {return error;}
	}
	string = Tcl_GetStringFromObj(objv[2],&len);
	if ((len != 1) || (string[0] != '+' && string[0] != '-' && string[0] != '*' && string[0] != '/' && string[0] != '|')) {
		Tcl_AppendResult(interp,"action must be one of +,-,*,/,|");
		return TCL_ERROR;
	}
	if (Tcl_ListObjGetElements(interp, objv[1], &listobjc1, &listobjv1) != TCL_OK) {
		return TCL_ERROR;
	}
	if (Tcl_ListObjGetElements(interp, objv[3], &listobjc2, &listobjv2) != TCL_OK) {
		return TCL_ERROR;
	}
	result = Tcl_NewListObj(0,NULL);
	if (startpos != -1) {
		Tcl_Obj *listObj,**resultpart;
		if  (startpos >= listobjc1) {
			listObj = objv[1];
		} else {
			if (Tcl_IsShared(objv[1])) {
				listObj = Tcl_DuplicateObj(objv[1]);
			} else {
				listObj = objv[1];
				Tcl_IncrRefCount(listObj);
			}
			if (startpos + listobjc2 > listobjc1) {
				listobjc2 = listobjc1 - startpos;
			}
			resultpart = (Tcl_Obj **)Tcl_Alloc(listobjc2*sizeof(Tcl_Obj *));
			for (i = 0 ; i < listobjc2 ; i++) {
				error = ExtraL_getnum(interp,listobjv1[startpos+i],&t1,&el1i,&el1d);
				if (error) {goto startposerror;}
				error = ExtraL_getnum(interp,listobjv2[i],&t2,&el2i,&el2d);
				if (error) {goto startposerror;}
				resultpart[i] = ExtraL_docalc(string[0],t1,el1i,el1d,t2,el2i,el2d);
			}
			error = Tcl_ListObjReplace(interp, listObj, startpos, listobjc2, listobjc2, resultpart);
			if (error) {goto startposerror;}
		}
		Tcl_SetObjResult(interp,listObj);
		return TCL_OK;
		startposerror:
			if (listObj != NULL) {Tcl_DecrRefCount(listObj);}
			if (result != NULL) {Tcl_DecrRefCount(result);}
			while (i) {
				Tcl_DecrRefCount(resultpart[--i]);
			}
			return error;
	} else {
		if ((listobjc1 != 1) && (listobjc2 != 1)) {
			if (listobjc1 < listobjc2) {
				listobjc2 = listobjc1;
			} else if (listobjc1 > listobjc2) {
				listobjc1 = listobjc2;
			}
		}
		if (listobjc1 == 1) {
			error = ExtraL_getnum(interp,listobjv1[0],&t1,&el1i,&el1d);
			if (error) {Tcl_DecrRefCount(result);return error;}
			for (i = 0 ; i < listobjc2 ; i++) {
				error = ExtraL_getnum(interp,listobjv2[i],&t2,&el2i,&el2d);
				if (error) {Tcl_DecrRefCount(result);return error;}
				resultEl = ExtraL_docalc(string[0],t1,el1i,el1d,t2,el2i,el2d);
				error = Tcl_ListObjAppendElement(interp,result,resultEl);
				if (error) {Tcl_DecrRefCount(resultEl);Tcl_DecrRefCount(result);return error;}
			}
		} else if (listobjc2 == 1) {
			error = ExtraL_getnum(interp,listobjv2[0],&t2,&el2i,&el2d);
			if (error) {Tcl_DecrRefCount(result);return error;}
			for (i = 0 ; i < listobjc1 ; i++) {
				error = ExtraL_getnum(interp,listobjv1[i],&t1,&el1i,&el1d);
				if (error) {Tcl_DecrRefCount(result);return error;}
				resultEl = ExtraL_docalc(string[0],t1,el1i,el1d,t2,el2i,el2d);
				error = Tcl_ListObjAppendElement(interp,result,resultEl);
				if (error) {Tcl_DecrRefCount(resultEl);Tcl_DecrRefCount(result);return error;}
			}
		} else {
			for (i = 0 ; i < listobjc1 ; i++) {
				error = ExtraL_getnum(interp,listobjv1[i],&t1,&el1i,&el1d);
				if (error) {Tcl_DecrRefCount(result);return error;}
				error = ExtraL_getnum(interp,listobjv2[i],&t2,&el2i,&el2d);
				if (error) {Tcl_DecrRefCount(result);return error;}
				resultEl = ExtraL_docalc(string[0],t1,el1i,el1d,t2,el2i,el2d);
				error = Tcl_ListObjAppendElement(interp,result,resultEl);
				if (error) {Tcl_DecrRefCount(resultEl);Tcl_DecrRefCount(result);return error;}
			}
		}
		Tcl_SetObjResult(interp,result);
		return TCL_OK;
	}
}

int ExtraL_vectorFromObj(Tcl_Interp *interp,Tcl_Obj *objv,double **resultPtr, int *resultlen) {
	Tcl_Obj **listobjv;
	double *result,el;
	int error, len, i;
	error = Tcl_ListObjGetElements(interp, objv, &len, &listobjv);
	if (error) {return error;}
	result = (double *)Tcl_Alloc(len*sizeof(double));
	if (result == NULL) {return TCL_ERROR;}
	for (i = 0; i < len ; i++) {
		error = Tcl_GetDoubleFromObj(interp,listobjv[i],&el);
		if (error) {return error;}
		result[i] = el;
	}
	*resultlen = len;
	*resultPtr = result;
	return TCL_OK;
}


int
ExtraL_Lmath_filterObjCmd(notUsed, interp, objc, objv)
	ClientData notUsed;				 /* Not used. */
	Tcl_Interp *interp;					/* Current interpreter. */
	int objc;						/* Number of arguments. */
	Tcl_Obj *CONST objv[];	/* Argument objects. */
{
	int len,flen,useunfilteredvalue = 0;
	Tcl_Obj *unfilteredvalue = NULL, *result,*resultEl;
	double *list = NULL,*filter = NULL, el;
	int filterpos;
	int j,error,end, pos;
	if ((objc < 3) || (objc > 5)) {
		Tcl_WrongNumArgs(interp, 1, objv, "list filter ?filterpos? ?unfilteredvalue?");
		return TCL_ERROR;
	}
	error = ExtraL_vectorFromObj(interp, objv[1], &list, &len);
	if (error) {return error;}
	error = ExtraL_vectorFromObj(interp, objv[2], &filter, &flen);
	if (error) {goto error;}
	if (flen > len) {
		Tcl_AppendResult(interp,"filter longer than list",(char *)NULL);
		return TCL_ERROR;
	}
	if (objc > 3) {
		error = Tcl_GetIntFromObj(interp,objv[3],&filterpos);
		if (error) {goto error;}
	} else {
		filterpos = (int)floor(flen/2);
	}
	if (objc > 4) {
		unfilteredvalue = objv[4];
		useunfilteredvalue = 1;
	}
	/* start processing */
	result = Tcl_NewListObj(0,NULL);
	if (!useunfilteredvalue) {
		el  = 0.0;
		for (j = 0; j < flen ; j++) {
			el += list[j]*filter[j];
		}
		resultEl = Tcl_NewDoubleObj(el);
	} else {
		resultEl = unfilteredvalue;
	}
	for (j = 0; j < filterpos ; j++) {
		error = Tcl_ListObjAppendElement(interp,result,resultEl);
		if (error) {goto error;}
	}
	/* main loop */
	end  = len - flen + 1;
	for (pos = 0 ; pos < end ; pos++) {
		el  = 0.0;
		for (j = 0; j < flen ; j++) {
			el += list[pos+j]*filter[j];
		}
		resultEl = Tcl_NewDoubleObj(el);
		error = Tcl_ListObjAppendElement(interp,result,resultEl);
		if (error) {goto error;}
	}
	if (useunfilteredvalue) {
		resultEl = unfilteredvalue;
	}
	end = flen - filterpos - 1;
	for (j = 0; j < end ; j++) {
		error = Tcl_ListObjAppendElement(interp,result,resultEl);
		if (error) {goto error;}
	}
	Tcl_SetObjResult(interp,result);
	if (list != NULL) {Tcl_Free((char *)list);}
	if (filter != NULL) {Tcl_Free((char *)filter);}
	return TCL_OK;
	error:
		if (list != NULL) {Tcl_Free((char *)list);}
		if (filter != NULL) {Tcl_Free((char *)filter);}
		return TCL_ERROR;
}


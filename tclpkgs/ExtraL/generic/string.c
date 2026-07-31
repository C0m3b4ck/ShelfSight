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
#include "general.h"
#define EXACT		0
#define GLOB		1
#define REGEXP		2
 
/*
 *----------------------------------------------------------------------
 *
 * ExtraL_String_ChangeObjCmd --
 *
 *
 * Results:
 *		A standard Tcl result.
 *
 *
 *----------------------------------------------------------------------
 */
int
ExtraL_String_ChangeObjCmd(notUsed, interp, objc, objv)
	ClientData notUsed;				/* Not used. */
	Tcl_Interp *interp;					/* Current interpreter. */
	int objc;						/* Number of arguments. */
	Tcl_Obj *CONST objv[];	/* Argument objects. */
{
	Tcl_Obj *result;
	int listObjc;
	Tcl_Obj **listObjv;
	char *p,*lp;
	int plen,lplen,ppos,tppos,lppos,prev;
	int j;

	if (objc != 3) {
		Tcl_WrongNumArgs(interp, 1, objv, "string changelist");
		return TCL_ERROR;
	}
	if (Tcl_ListObjGetElements(interp, objv[2], &listObjc, &listObjv) != TCL_OK) {
		return TCL_ERROR;
	}
	if ((listObjc != 0)&&(listObjc & 1)) {
		Tcl_AppendResult(interp,"changelist does not have an even number of elements",NULL);
		return TCL_ERROR;
	}
	result = Tcl_NewObj();
	p = Tcl_GetStringFromObj(objv[1],&plen);
	ppos = 0;
	prev = 0;
	while (ppos < plen) {
		for(j=0;j<listObjc;j+=2) {
			lp = Tcl_GetStringFromObj(listObjv[j],&lplen);
			tppos = ppos;
			lppos = 0;
			while ((lppos < lplen)&&(tppos < plen)) {
				if (p[tppos] != lp[lppos]) break;
				tppos++;lppos++;
			}
			if (lppos == lplen) {
				if (prev != ppos) {
					Tcl_AppendToObj(result,p + prev,ppos - prev);
				}
				lp = Tcl_GetStringFromObj(listObjv[j+1],&lplen);
				Tcl_AppendToObj(result,lp,lplen);
				ppos = tppos-1;
				prev = tppos;
				break;
			}
		}
		ppos++;
	}
	if (ppos == plen) {
		Tcl_AppendToObj(result,p + prev,plen - prev);
	}
	Tcl_SetObjResult(interp,result);
	return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * ExtraL_String_ReplaceObjCmd --
 *
 *
 * Results:
 *		A standard Tcl result.
 *
 *
 *----------------------------------------------------------------------
 */
int
ExtraL_String_ReplaceObjCmd(notUsed, interp, objc, objv)
	ClientData notUsed;				/* Not used. */
	Tcl_Interp *interp;					/* Current interpreter. */
	int objc;						/* Number of arguments. */
	Tcl_Obj *CONST objv[];	/* Argument objects. */
{
	Tcl_Obj *result;
	char *replacement,*string;
	int i,error;
	int first,last,slen,rlen;
	/* */
	if (objc != 5) {
		Tcl_WrongNumArgs(interp, 1, objv, "string first last replacement");
		return TCL_ERROR;
	}
	error = Tcl_GetIntFromObj(interp, objv[2], &first);
	if (error) {return error;}
	error = Tcl_GetIntFromObj(interp, objv[3], &last);
	if (error) {return error;}
	if (first < 0) {
		Tcl_AppendResult(interp,"first position < 0",NULL);
		return TCL_ERROR;
	}
	if (last < first) {
		last = first;
	} else {
		last++;
	}
	replacement = Tcl_GetStringFromObj(objv[4],&rlen);
	string = Tcl_GetStringFromObj(objv[1],&slen);
	result = Tcl_NewStringObj("",0);
	if (first < slen) {
		if (last < slen) {
			Tcl_AppendToObj(result, string, first);
			Tcl_AppendToObj(result, replacement, rlen);
			Tcl_AppendToObj(result, string+last, slen-last);
		} else {
			Tcl_AppendToObj(result, string, first);
			Tcl_AppendToObj(result, replacement, rlen);
		}
	} else {
		Tcl_AppendToObj(result, string, slen);
		for (i = slen + 1 ; i <= first ; i++) {Tcl_AppendToObj(result, " ", 1);}
		Tcl_AppendToObj(result, replacement, rlen);
	}
	Tcl_SetObjResult(interp,result);
	return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * ExtraL_String_reverseObjCmd --
 *
 *		This procedure is invoked to process the "sreverse" command.
 *
 * Results:
 *		A standard Tcl result.
 *
 *
 *----------------------------------------------------------------------
 */

int
ExtraL_String_reverseObjCmd(notUsed, interp, objc, objv)
	ClientData notUsed;				/* Not used. */
	Tcl_Interp *interp;					/* Current interpreter. */
	int objc;						/* Number of arguments. */
	Tcl_Obj *CONST objv[];	/* Argument objects. */
{
	char *string, *result,*pos;
	int stringlen,i;
	if (objc != 2) {
		Tcl_WrongNumArgs(interp, 1, objv, "string");
		return TCL_ERROR;
	}
	string = Tcl_GetStringFromObj(objv[1], &stringlen);
	result = (char *)Tcl_Alloc(stringlen*sizeof(char));
	pos = result;
	i = stringlen;
	for(i--;i >= 0;i--) {
		*pos++ = string[i];
	}
	Tcl_SetObjResult(interp,Tcl_NewStringObj(result,stringlen));
	Tcl_Free(result);
	return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * ExtraL_String_FindObjCmd --
 *
 *		This procedure is invoked to process the "sfind" command.
 *		It finds all occurences of a pattern in a list, and returns
 *		their indexes as a list.
 *
 * Results:
 *		A standard Tcl result.
 *
 *
 *----------------------------------------------------------------------
 */

int
ExtraL_String_FindObjCmd(clientData, interp, objc, objv)
	ClientData clientData;	/* Not used. */
	Tcl_Interp *interp;		/* Current interpreter. */
	int objc;			/* Number of arguments. */
	Tcl_Obj *CONST objv[];	/* Argument values. */
{
	char *string;
	char *bytes, *patternBytes;
	int i, match, mode, result, length, stringlen;
	Tcl_Obj *indexObj, *resultObj;
	static CONST char *switches[] =
		{"-exact", "-glob", "-regexp", (char *) NULL};
	mode = EXACT;
	if (objc == 4) {
		if (Tcl_GetIndexFromObj(interp, objv[1], switches,
			"search mode", 0, &mode) != TCL_OK) {
			return TCL_ERROR;
		}
	} else if (objc != 3) {
		Tcl_WrongNumArgs(interp, 1, objv, "?mode? string pattern");
		return TCL_ERROR;
	}
	string = Tcl_GetStringFromObj(objv[objc-2], &stringlen);
	patternBytes = Tcl_GetStringFromObj(objv[objc-1], &length);
 	Tcl_ResetResult(interp);
	resultObj = Tcl_GetObjResult(interp);
	for (i = 0; i < stringlen; i++) {
		match = 0;
		bytes = string+i;
		switch (mode) {
			case EXACT:
				if (i+length < stringlen) {
					match = (memcmp(bytes, patternBytes,(size_t) length) == 0);
				}
				break;
			case GLOB:
				/*
				* WARNING: will not work with data containing NULLs.
				*/
				match = Tcl_StringMatch(bytes, patternBytes);
				break;
			case REGEXP:
				/*
				* WARNING: will not work with data containing NULLs.
				*/
				match = Tcl_RegExpMatch(interp, bytes, patternBytes);
				if (match < 0) {
					return TCL_ERROR;
				}
				break;
		}
		if (match) {
			indexObj = Tcl_NewIntObj(i);
			result = Tcl_ListObjAppendElement(interp,resultObj,indexObj);
			if (result != TCL_OK) {return result;}
		}
	}
	Tcl_SetObjResult(interp,resultObj);
	return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * ExtraL_String_ForeachCmd --
 *
 *		This procedure is invoked to process the "string_foreach" command.
 *
 * Results:
 *		A standard Tcl result.
 *
 *
 *----------------------------------------------------------------------
 */
int
ExtraL_String_ForeachCmd(dummy, interp, objc, objv)
	ClientData dummy;		/* Not used. */
	Tcl_Interp *interp;		/* Current interpreter. */
	int objc;			/* Number of arguments. */
	Tcl_Obj *CONST objv[];	/* Argument objects. */
{
	Tcl_ObjType	*tclListType=Tcl_GetObjType("list");
	int result = TCL_OK;
	int i;			/* i selects a value list */
	int j, maxj;		/* Number of loop iterations */
	int v;			/* v selects a loop variable */
	int numLists;		/* Count of value lists */
	Tcl_Obj *bodyPtr;
	/*
	 * We copy the argument object pointers into a local array to avoid
	 * the problem that "objv" might become invalid. It is a pointer into
	 * the evaluation stack and that stack might be grown and reallocated
	 * if the loop body requires a large amount of stack space.
	 */
#define NUM_ARGS 9
	Tcl_Obj *(argObjStorage[NUM_ARGS]);
	Tcl_Obj **argObjv = argObjStorage;
#define STATIC_LIST_SIZE 4
	int indexArray[STATIC_LIST_SIZE];	  /* Array of value list indices */
	int varcListArray[STATIC_LIST_SIZE];  /* # loop variables per list */
	Tcl_Obj **varvListArray[STATIC_LIST_SIZE]; /* Array of var name lists */
	int argcListArray[STATIC_LIST_SIZE];  /* Array of value list sizes */
	char *argvListArray[STATIC_LIST_SIZE]; /* Array of value lists */
	int *index = indexArray;
	int *varcList = varcListArray;
	Tcl_Obj ***varvList = varvListArray;
	int *argcList = argcListArray;
	char **argvList = argvListArray;
	if (objc < 4 || (objc%2 != 0)) {
		Tcl_WrongNumArgs(interp, 1, objv,
			"varList string ?varList string ...? command");
		return TCL_ERROR;
	}
	/*
	 * Create the object argument array "argObjv". Make sure argObjv is
	 * large enough to hold the objc arguments.
	 */
	if (objc > NUM_ARGS) {
		argObjv = (Tcl_Obj **) ckalloc(objc * sizeof(Tcl_Obj *));
	}
	for (i = 0;  i < objc;  i++) {
		argObjv[i] = objv[i];
	}
	/*
	 * Manage numList parallel value lists.
	 * argvList[i] is a value list counted by argcList[i]
	 * varvList[i] is the list of variables associated with the value list
	 * varcList[i] is the number of variables associated with the value list
	 * index[i] is the current pointer into the value list argvList[i]
	 */
	numLists = (objc-2)/2;
	if (numLists > STATIC_LIST_SIZE) {
		index = (int *) Tcl_Alloc(numLists * sizeof(int));
		varcList = (int *) Tcl_Alloc(numLists * sizeof(int));
		varvList = (Tcl_Obj ***) Tcl_Alloc(numLists * sizeof(Tcl_Obj **));
		argcList = (int *) Tcl_Alloc(numLists * sizeof(int));
		argvList = (char **) Tcl_Alloc(numLists * sizeof(Tcl_Obj **));
	}
	for (i = 0;  i < numLists;  i++) {
		index[i] = 0;
		varcList[i] = 0;
		varvList[i] = (Tcl_Obj **) NULL;
		argcList[i] = 0;
		argvList[i] = (char *) NULL;
	}
	/*
	 * Break up the value lists and variable lists into elements
	 */
	maxj = 0;
	for (i = 0;  i < numLists;  i++) {
		result = Tcl_ListObjGetElements(interp, argObjv[1+i*2],
				&varcList[i], &varvList[i]);
		if (result != TCL_OK) {
			goto done;
		}
		if (varcList[i] < 1) {
			Tcl_AppendToObj(Tcl_GetObjResult(interp),
				"foreach varlist is empty", -1);
			result = TCL_ERROR;
			goto done;
		}
		argvList[i] = Tcl_GetStringFromObj(argObjv[2+i*2],&argcList[i]);
		j = argcList[i] / varcList[i];
		if ((argcList[i] % varcList[i]) != 0) {
			j++;
		}
		if (j > maxj) {
			maxj = j;
		}
	}
	/*
	 * Iterate maxj times through the lists in parallel
	 * If some value lists run out of values, set loop vars to ""
	 */
	bodyPtr = argObjv[objc-1];
	for (j = 0;  j < maxj;  j++) {
		for (i = 0;  i < numLists;  i++) {
			/*
			* If a variable or value list object has been converted to
			* another kind of Tcl object, convert it back to a list object
			* and refetch the pointer to its element array.
			*/
			if (argObjv[1+i*2]->typePtr != tclListType) {
				result = Tcl_ListObjGetElements(interp, argObjv[1+i*2],
						&varcList[i], &varvList[i]);
				if (result != TCL_OK) {
					panic("Extral_String_ForeachObjCmd: could not reconvert variable list %d to a list object\n", i);
				}
			}
			argvList[i] = Tcl_GetStringFromObj(argObjv[2+i*2],&argcList[i]);
			for (v = 0;  v < varcList[i];  v++) {
				int k = index[i]++;
				Tcl_Obj *valuePtr, *varValuePtr;
				int isEmptyObj = 0;
				
				if (k < argcList[i]) {
					valuePtr = Tcl_NewStringObj(argvList[i]+k,1);
				} else {
					valuePtr = Tcl_NewObj(); /* empty string */
					isEmptyObj = 1;
				}
				varValuePtr = Tcl_ObjSetVar2(interp, varvList[i][v],
					NULL, valuePtr, 0);
				if (varValuePtr == NULL) {
					if (isEmptyObj) {
					Tcl_DecrRefCount(valuePtr);
					}
					Tcl_ResetResult(interp);
					Tcl_AppendStringsToObj(Tcl_GetObjResult(interp),
					"couldn't set loop variable: \"",
					Tcl_GetString(varvList[i][v]), "\"", (char *) NULL);
					result = TCL_ERROR;
					goto done;
				}
			}
		}
		result = Tcl_EvalObjEx(interp, bodyPtr, 0);
		if (result != TCL_OK) {
			if (result == TCL_CONTINUE) {
			result = TCL_OK;
			} else if (result == TCL_BREAK) {
			result = TCL_OK;
			break;
			} else if (result == TCL_ERROR) {
				Tcl_AddErrorInfo(interp, "\n    (\"string_foreach\" body line)");
				break;
			} else {
				break;
			}
		}
	}
	if (result == TCL_OK) {
		Tcl_ResetResult(interp);
	}
	done:
	if (numLists > STATIC_LIST_SIZE) {
		Tcl_Free((char *) index);
		Tcl_Free((char *) varcList);
		Tcl_Free((char *) argcList);
		Tcl_Free((char *) varvList);
		Tcl_Free((char *) argvList);
	}
	if (argObjv != argObjStorage) {
		Tcl_Free((char *) argObjv);
	}
	return result;
#undef STATIC_LIST_SIZE
#undef NUM_ARGS
}

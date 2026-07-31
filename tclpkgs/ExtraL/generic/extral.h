/*	
 *	 File:    extral.h
 *	 Purpose: extraL extension to Tcl
 *	 Author:  Copyright (c) 1995 Peter De Rijk
 *
 *	 See the file "README" for information on usage and redistribution
 *	 of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 */

/*
 * Windows needs to know which symbols to export.  Unix does not.
 * BUILD_Class should be undefined for Unix.
 */

#ifdef BUILD_Extral
#undef TCL_STORAGE_CLASS
#define TCL_STORAGE_CLASS DLLEXPORT
#endif /* BUILD_Extral */

#define EXTERN 

/*
 * format- and scantime functions and definitions
 */

EXTERN int ExtraL_ScanTime _ANSI_ARGS_((Tcl_Interp *interp,
	int musthavedate,
	int musthavetime,
	Tcl_Obj *dateObj,
	Tcl_Obj **result));

EXTERN int ExtraL_FormatTime _ANSI_ARGS_((Tcl_Interp *interp,
	Tcl_Obj *time,
	char *format,
	char **result));

/*
 * map functions and definitions
 */

typedef int ExtraL_MapTypeSetProc _ANSI_ARGS_((Tcl_Interp *interp,
	Tcl_Obj *structure,Tcl_Obj *data,Tcl_Obj *oldvalue,int tagsc,Tcl_Obj **tagsv,
	Tcl_Obj **value));
typedef int ExtraL_MapTypeGetProc _ANSI_ARGS_((Tcl_Interp *interp,
	Tcl_Obj *structure,Tcl_Obj *data,int tagsc,Tcl_Obj **tagsv,
	Tcl_Obj **value));
typedef int ExtraL_MapTypeUnsetProc _ANSI_ARGS_((Tcl_Interp *interp,
	Tcl_Obj *structure,Tcl_Obj *data,Tcl_Obj *oldvalue,int tagsc,Tcl_Obj **tagsv,
	Tcl_Obj **value));
EXTERN int ExtraL_MapsetStruct _ANSI_ARGS_((Tcl_Interp *interp,
	Tcl_Obj *structure,
	Tcl_Obj *data,
	Tcl_Obj *list,
	int tagsc,
	Tcl_Obj **tagsv,
	Tcl_Obj *value,
	Tcl_Obj **resultPtr));

EXTERN int ExtraL_MapunsetStruct _ANSI_ARGS_((Tcl_Interp *interp,
	Tcl_Obj *structure,
	Tcl_Obj *data,
	Tcl_Obj *list,
	int tagsc,
	Tcl_Obj **tagsv,
	Tcl_Obj **resultPtr));

EXTERN int ExtraL_MapgetStruct _ANSI_ARGS_((Tcl_Interp *interp,
	Tcl_Obj *structure,
	Tcl_Obj *data,
	Tcl_Obj *list,
	int tagsc,
	Tcl_Obj **tagsv,
	Tcl_Obj **resultPtr));


EXTERN int ExtraL_MapCreateType _ANSI_ARGS_((Tcl_Interp *interp,
	char *key,
	ExtraL_MapTypeSetProc *setproc,
	ExtraL_MapTypeGetProc *getproc,
	ExtraL_MapTypeUnsetProc *unsetproc));

EXTERN int ExtraL_MapFindTag _ANSI_ARGS_((Tcl_Interp *interp,
	Tcl_Obj *list,
	char *tag,
	int taglen,
	Tcl_Obj **resultPtr,
	int *posPtr));

int ExtraL_ObjEqual _ANSI_ARGS_((Tcl_Obj *obj1,Tcl_Obj *obj2));

EXTERN int Extral_Init(Tcl_Interp *interp);


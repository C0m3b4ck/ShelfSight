/*	
 *	 File:    class.h
 *	 Purpose: Class extension to Tcl
 *	 Author:  Copyright (c) 1995 Peter De Rijk
 *
 *	 See the file "README" for information on usage and redistribution
 *	 of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 */

#include "hash.h"

/*
 * Windows needs to know which symbols to export.  Unix does not.
 * BUILD_Class should be undefined for Unix.
 */

#ifdef BUILD_Class
#undef TCL_STORAGE_CLASS
#define TCL_STORAGE_CLASS DLLEXPORT
#endif /* BUILD_Class */

/* This EXTERN declaration is needed for Tcl < 8.0.3 */
#ifndef EXTERN
# ifdef __cplusplus
#  define EXTERN extern "C"
# else
#  define EXTERN extern
# endif
#endif

typedef struct Method {
	int copy;
	void *func;
	Tcl_Obj *proc;
	Tcl_Obj *args;
	int min;
	int max;
} Method;

typedef struct Class {
	Tcl_Command token;
	struct Class *parent;
	Tcl_Interp *interp;
	Tcl_Obj *class;
	Classy_HashTable methods;
	Classy_HashTable classmethods;
	Classy_HashTable children;
	Classy_HashTable subclasses;
	Method *init;
	Method *classdestroy;
	Method *destroy;
	Tcl_Obj *trace;
	ClientData clientdata;
} Class;

typedef struct Object {
	Tcl_Command token;
	Class *parent;
	Tcl_Obj *name;
	Tcl_Obj *trace;
	ClientData clientdata;
} Object;

typedef int Classy_Method _ANSI_ARGS_((Tcl_Interp *interp,
	Class *class,
	Object *object,
	int argc,
	Tcl_Obj *CONST argv[]));

extern int Classy_CreateClassMethod _ANSI_ARGS_((Tcl_Interp *interp,
	char *classname,
	Tcl_Obj *name,
	Classy_Method *func));

extern int Classy_CreateMethod _ANSI_ARGS_((Tcl_Interp *interp,
	char *classname,
	Tcl_Obj *name,
	Classy_Method *func));

extern Tcl_Obj *Classy_ObjectPrivateVar(
	char *name,
	char *var);

extern int Class_Init(
	Tcl_Interp *interp);

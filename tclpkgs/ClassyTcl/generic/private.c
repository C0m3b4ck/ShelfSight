/*
 *       File:    private.c
 *       Purpose: object extension to Tcl
 *       Author:  Copyright (c) 1998 Peter De Rijk
 *
 *       See the file "README" for information on usage and redistribution
 *       of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 */

#include <string.h>
#include "tcl.h"
#include "class.h"

int Classy_PropagateVar(
	Tcl_Interp *interp,
	Class *class,
	Tcl_Obj *name,
	Tcl_Obj *value)
{
	Classy_HashEntry *entry;
	Classy_HashSearch search;
	Class *subclass;
	Tcl_Obj *val,*temp;
	int error;

	entry = Classy_FirstHashEntry(&(class->subclasses), &search);
	while(1) {
		if (entry == NULL) break;
		subclass = (Class *)Classy_GetHashValue(entry);
		temp = Tcl_NewObj();
		Tcl_AppendStringsToObj(temp, "::Class::", Tcl_GetStringFromObj(subclass->class,NULL), ",,vd", (char *)NULL);
		val = Tcl_ObjGetVar2(interp, temp, name, TCL_GLOBAL_ONLY);
		Tcl_DecrRefCount(temp);
		if (val == NULL) {
			temp = Tcl_NewObj();
			Tcl_AppendStringsToObj(temp, "::Class::", Tcl_GetStringFromObj(subclass->class,NULL), ",,v,", 
				Tcl_GetStringFromObj(name,NULL), (char *)NULL);
			Tcl_ObjSetVar2(interp,temp,NULL,value,TCL_PARSE_PART1|TCL_GLOBAL_ONLY);
			Tcl_DecrRefCount(temp);
			error = Classy_PropagateVar(interp,subclass,name,value);
			if (error != TCL_OK) {return error;}
		}
		entry = Classy_NextHashEntry(&search);
	}
	return TCL_OK;
}

int Classy_PrivateMethod(
	Tcl_Interp *interp,
	Class *class,
	Object *object,
	int argc,
	Tcl_Obj *CONST argv[])
{
	Tcl_Obj *temp,*res;
	int error;

	if (argc==0) {
		Tcl_Obj **objv,*result,*src;
		char *name;
		int len,start,objc,i;
		name = Tcl_GetStringFromObj(object->name, &len);
		error = Tcl_VarEval(interp, "lsort [info vars ::Class::",name, ",,v,*]",(char *)NULL);
		if (error != TCL_OK) {return error;}
		src = Tcl_GetObjResult(interp);
		error = Tcl_ListObjGetElements(interp, src, &objc, &objv);
		if (error != TCL_OK) {return error;}
		start = len + 13;
		result = Tcl_NewObj();
		i = 0;
		while(i<objc) {
			name = Tcl_GetStringFromObj(objv[i],&len);
			error = Tcl_ListObjAppendElement(interp, result, Tcl_NewStringObj(name+start,len-start));
			if (error != TCL_OK) {Tcl_DecrRefCount(result);return error;}
			i++;
		}
		Tcl_SetObjResult(interp,result);
		return TCL_OK;
	} else if (argc==1) {
		temp = Tcl_NewObj();
		Tcl_AppendStringsToObj(temp, "::Class::", Tcl_GetStringFromObj(object->name,NULL), ",,v,", 
			Tcl_GetStringFromObj(argv[0],NULL), (char *)NULL);
		res = Tcl_ObjGetVar2(interp,temp,NULL,TCL_PARSE_PART1|TCL_GLOBAL_ONLY);
		Tcl_DecrRefCount(temp);
		if (res != NULL) {
			Tcl_SetObjResult(interp,res);
			return TCL_OK;
		} else {
			Tcl_ResetResult(interp);
			Tcl_AppendResult(interp,"\"", Tcl_GetStringFromObj(object->name,NULL), 
				"\" does not have a private variable \"", Tcl_GetStringFromObj(argv[0],NULL), "\"",NULL);
			return TCL_ERROR;
		}
	} else if (argc==2) {
		temp = Tcl_NewObj();
		Tcl_AppendStringsToObj(temp, "::Class::", Tcl_GetStringFromObj(object->name,NULL), ",,v,", 
			Tcl_GetStringFromObj(argv[0],NULL), (char *)NULL);
		Tcl_SetObjResult(interp,Tcl_ObjSetVar2(interp,temp,NULL,argv[1],TCL_PARSE_PART1|TCL_GLOBAL_ONLY));
		Tcl_DecrRefCount(temp);
		return TCL_OK;
	} else {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"wrong # args: should be \"",Tcl_GetStringFromObj(object->name,NULL),
			" private ?varName? ?newValue?\"", (char *)NULL);
		return TCL_ERROR;
	}
	return TCL_OK;
}

int Classy_PrivateClassMethod(
	Tcl_Interp *interp,
	Class *class,
	Object *object,
	int argc,
	Tcl_Obj *CONST argv[])
{
	Tcl_Obj *temp,*res;
	int error;

	if (argc==0) {
		Tcl_Obj **objv,*result,*src;
		char *name;
		int len,start,objc,i;
		name = Tcl_GetStringFromObj(class->class, &len);
		error = Tcl_VarEval(interp, "lsort [info vars ::Class::",name, ",,v,*]",(char *)NULL);
		if (error != TCL_OK) {return error;}
		src = Tcl_GetObjResult(interp);
		error = Tcl_ListObjGetElements(interp, src, &objc, &objv);
		if (error != TCL_OK) {return error;}
		start = len + 13;
		result = Tcl_NewObj();
		i = 0;
		while(i<objc) {
			name = Tcl_GetStringFromObj(objv[i],&len);
			error = Tcl_ListObjAppendElement(interp, result, Tcl_NewStringObj(name+start,len-start));
			if (error != TCL_OK) {Tcl_DecrRefCount(result);return error;}
			i++;
		}
		Tcl_SetObjResult(interp,result);
		return TCL_OK;
	} else if (argc==1) {
		temp = Tcl_NewObj();
		Tcl_AppendStringsToObj(temp, "::Class::", Tcl_GetStringFromObj(class->class,NULL), ",,v,", 
			Tcl_GetStringFromObj(argv[0],NULL), (char *)NULL);
		res = Tcl_ObjGetVar2(interp,temp,NULL,TCL_PARSE_PART1|TCL_GLOBAL_ONLY);
		Tcl_DecrRefCount(temp);
		if (res != NULL) {
			Tcl_SetObjResult(interp,res);
			return TCL_OK;
		} else {
			Tcl_ResetResult(interp);
			Tcl_AppendResult(interp,"\"", Tcl_GetStringFromObj(class->class,NULL), 
				"\" does not have a private variable \"", Tcl_GetStringFromObj(argv[0],NULL), "\"",NULL);
			return TCL_ERROR;
		}
	} else if (argc==2) {
		error = Classy_PropagateVar(interp,class,argv[0],argv[1]);
		if (error != TCL_OK) {return error;}
		temp = Tcl_NewObj();
		Tcl_AppendStringsToObj(temp, "::Class::", Tcl_GetStringFromObj(class->class,NULL), ",,vd", (char *)NULL);
		res = Tcl_ObjSetVar2(interp, temp, argv[0], Tcl_NewObj(), TCL_GLOBAL_ONLY|TCL_LEAVE_ERR_MSG);
		if (res == NULL) {Tcl_DecrRefCount(temp);return TCL_ERROR;}
		Tcl_SetStringObj(temp,"",0);
		Tcl_AppendStringsToObj(temp, "::Class::", Tcl_GetStringFromObj(class->class,NULL), ",,v,", 
			Tcl_GetStringFromObj(argv[0],NULL), (char *)NULL);
		Tcl_SetObjResult(interp,Tcl_ObjSetVar2(interp,temp,NULL,argv[1],TCL_PARSE_PART1|TCL_GLOBAL_ONLY));
		Tcl_DecrRefCount(temp);
		return TCL_OK;
	} else {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"wrong # args: should be \"",Tcl_GetStringFromObj(class->class,NULL),
			" private ?varName? ?newValue?\"", (char *)NULL);
		return TCL_ERROR;
	}
	return TCL_OK;
}

Tcl_Obj *Classy_ObjectPrivateVar(
	char *name,
	char *var)
{
	Tcl_Obj *result;
	char buffer[100];
	char *dbuffer;
	int objlen,varlen,bsize=0,end;
	objlen = strlen(name);
	dbuffer = buffer;
	varlen = strlen(var);
	end = objlen+13+varlen;
	if (end > 98) {
		if (bsize == 0) {
			dbuffer = (char *)Tcl_Alloc(end*sizeof(char *));
			bsize = end-1;
		}
	}
	memcpy(dbuffer,"::Class::",9);
	memcpy(dbuffer+9,name,objlen);
	memcpy(dbuffer+9+objlen,",,v,",4);
	memcpy(dbuffer+objlen+13,var,varlen);
	result = Tcl_NewStringObj(dbuffer,end);
	if (bsize != 0) {
		Tcl_Free(dbuffer);
	}
	return result;
}

int Classy_PrivateObjCmd(
	ClientData clientdata,
	Tcl_Interp *interp,
	int argc,
	Tcl_Obj *CONST argv[])
{
	char buffer[100];
	char *obj, *var, *dbuffer;
	int error,objlen,varlen,bsize=0,i,end;
	if (argc < 2) {
		Tcl_ResetResult(interp);
		Tcl_SetResult(interp,"no value given for parameter \"object\" to \"private\"",TCL_STATIC);
		return TCL_ERROR;
	}
	obj = Tcl_GetStringFromObj(argv[1],&objlen);
	dbuffer = buffer;
	memcpy(dbuffer,"::Class::",9);
	memcpy(dbuffer+9,obj,objlen);
	memcpy(dbuffer+9+objlen,",,v,",4);
	for (i=2;i<argc;i++) {
		var = Tcl_GetStringFromObj(argv[i],&varlen);
		end = objlen+13+varlen;
		if (end > 98) {
			if (bsize == 0) {
				dbuffer = (char *)Tcl_Alloc(end*sizeof(char *));
				memcpy(dbuffer,"::Class::",9);
				memcpy(dbuffer+9,obj,objlen);
				memcpy(dbuffer+9+objlen,",,v,",4);
				bsize = end-1;
			} else if (end>bsize) {
				dbuffer = (char *)Tcl_Realloc(dbuffer,end*sizeof(char *));
				bsize = end-1;
			}
		}
		memcpy(dbuffer+objlen+13,var,varlen);
		dbuffer[end] = '\0';
		error = Tcl_UpVar(interp, "#0", dbuffer, var, 0);
	}
	if (bsize != 0) {
		Tcl_Free(dbuffer);
	}
	return TCL_OK;
}

int Classy_SetPrivateObjCmd(
	ClientData clientdata,
	Tcl_Interp *interp,
	int argc,
	Tcl_Obj *CONST argv[])
{
	Tcl_Obj *temp;
	if (argc != 4) {
		Tcl_ResetResult(interp);
		Tcl_WrongNumArgs(interp,argc,argv,"object var value");
		return TCL_ERROR;
	}
	temp = Classy_ObjectPrivateVar(Tcl_GetStringFromObj(argv[1],NULL),Tcl_GetStringFromObj(argv[2],NULL));
	if (Tcl_ObjSetVar2(interp, temp, NULL, argv[3], TCL_GLOBAL_ONLY|TCL_PARSE_PART1|TCL_LEAVE_ERR_MSG) == NULL) {
		return TCL_ERROR;
	}
	Tcl_DecrRefCount(temp);
	return TCL_OK;
}

int Classy_GetPrivateObjCmd(
	ClientData clientdata,
	Tcl_Interp *interp,
	int argc,
	Tcl_Obj *CONST argv[])
{
	Tcl_Obj *result,*temp;
	if (argc != 3) {
		Tcl_ResetResult(interp);
		Tcl_WrongNumArgs(interp,argc,argv,"object var");
		return TCL_ERROR;
	}
	temp = Classy_ObjectPrivateVar(Tcl_GetStringFromObj(argv[1],NULL),Tcl_GetStringFromObj(argv[2],NULL));
	result = Tcl_ObjGetVar2(interp, temp, NULL, TCL_GLOBAL_ONLY|TCL_PARSE_PART1|TCL_LEAVE_ERR_MSG);
	if (result == NULL) {
		return TCL_ERROR;
	}
	Tcl_DecrRefCount(temp);
	Tcl_SetObjResult(interp,result);
	return TCL_OK;
}

int Classy_PrivateVarObjCmd(
	ClientData clientdata,
	Tcl_Interp *interp,
	int argc,
	Tcl_Obj *CONST argv[])
{
	if (argc != 3) {
		Tcl_ResetResult(interp);
		Tcl_WrongNumArgs(interp,argc,argv,"object var");
		return TCL_ERROR;
	}
	Tcl_SetObjResult(interp,Classy_ObjectPrivateVar(Tcl_GetStringFromObj(argv[1],NULL),Tcl_GetStringFromObj(argv[2],NULL)));
	return TCL_OK;
}



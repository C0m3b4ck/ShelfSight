/*
 *       File:    method.c
 *       Purpose: object extension to Tcl
 *       Author:  Copyright (c) 1998 Peter De Rijk
 *
 *       See the file "README" for information on usage and redistribution
 *       of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 */

#include <string.h>
#include "tcl.h"
#include "class.h"
#include "method.h"

int Classy_ParseArgs(
	Tcl_Interp *interp,
	Tcl_Obj *args,
	int *minptr,
	int *maxptr,
	Tcl_Obj *rname,
	Tcl_Obj **resultargs)
{
	Tcl_Obj **objv, *temp, *temp2,*rargs;
	int objc,i,len,min,max,error;

	min = 0;
	max = 0;
	error = Tcl_ListObjGetElements(interp, args, &objc, &objv);
	if (error != TCL_OK) {return error;}
	if Tcl_IsShared(rname) {
		rargs = Tcl_DuplicateObj(rname);
	} else {
		rargs = rname;
	}
	Tcl_IncrRefCount(rargs);
	if (objc == 0) {
		min = 0;
		max = 0;
	} else {
		for(i=0;i<objc;i++) {
			error = Tcl_ListObjLength(interp, objv[i], &len);
			if (error != TCL_OK) {return error;}
			if (len == 1) {
				min++;
				max++;
				error = Tcl_ListObjAppendElement(interp, rargs, objv[i]);
				if (error == TCL_ERROR) {return error;}
			} else {
				max++;
				temp = Tcl_NewStringObj("?",1);
				error = Tcl_ListObjIndex(interp, objv[i], 0, &temp2);
				if (error == TCL_ERROR) {Tcl_DecrRefCount(temp);return error;}
				Tcl_AppendStringsToObj(temp,Tcl_GetStringFromObj(temp2,NULL),"?",NULL);
				error = Tcl_ListObjAppendElement(interp, rargs, temp);
				if (error == TCL_ERROR) {return error;}
			}
		}
		if (strcmp(Tcl_GetStringFromObj(objv[objc-1],NULL),"args")==0) {
			min--;
			max = -1;
			error = Tcl_ListObjLength(interp, rargs, &len);
			if (error == TCL_ERROR) {return error;}
			temp = Tcl_NewStringObj("...",3);
			error = Tcl_ListObjReplace(interp, rargs, len-1, 1, 1, &temp);
			if (error == TCL_ERROR) {return error;}
		}
	}
	*minptr = min;
	*maxptr = max;
	*resultargs = rargs;
	return TCL_OK;
}

int Classy_ExecClassMethod(
	Tcl_Interp *interp,
	Method *method,
	Class *class,
	Object *object,
	int argc,
	Tcl_Obj *CONST argv[])
{
	int error,i;
	if (method->proc != NULL) {
		Tcl_CmdInfo cmdinfo;
		Tcl_Obj *objvstatic[10],**objv;
		int objc;

		if ((argc < method->min)||((method->max != -1)&&(argc > method->max))) {
			Tcl_ResetResult(interp);
			Tcl_AppendResult(interp,"wrong # args: should be \"",Tcl_GetStringFromObj(class->class,NULL), 
				" ", Tcl_GetStringFromObj(method->args,NULL), "\"", (char *)NULL);
			return TCL_ERROR;
		}

		if (argc<7) {
			objv = objvstatic;
		} else {
			objv = (Tcl_Obj **)Tcl_Alloc((argc+3)*sizeof(Tcl_Obj *));
		}
		objv[0] = method->proc;
		objv[1] = class->class;
		objc = 2;
		for(i=0;i<argc;i++) {
			objv[objc++] = argv[i];
		}
		objv[objc] = NULL;
		i = Tcl_GetCommandInfo(interp,Tcl_GetStringFromObj(method->proc,NULL),&cmdinfo);
		if (i==0) {return TCL_OK;}
		error = cmdinfo.objProc(cmdinfo.objClientData,interp,objc,objv);
		return error;
	} else {
		error = ((Classy_Method *)method->func)(interp,class,object,argc,argv);
		return error;
	}
}

int Classy_ExecMethod(
	Tcl_Interp *interp,
	Method *method,
	Class *class,
	Object *object,
	int argc,
	Tcl_Obj *CONST argv[])
{
	int error,i;
	if (method->proc != NULL) {
		Tcl_CmdInfo cmdinfo;
		Tcl_Obj *objvstatic[20],**objv;
		int objc;

		if ((argc < method->min)||((method->max != -1)&&(argc > method->max))) {
			Tcl_ResetResult(interp);
			if (object != NULL) {
				Tcl_AppendResult(interp,"wrong # args: should be \"",Tcl_GetStringFromObj(object->name,NULL), 
					" ", Tcl_GetStringFromObj(method->args,NULL), "\"", (char *)NULL);
			} else {
				Tcl_AppendResult(interp,"wrong # args: should be \"",Tcl_GetStringFromObj(class->class,NULL), 
					" ", Tcl_GetStringFromObj(method->args,NULL), "\"", (char *)NULL);
			}
			return TCL_ERROR;
		}

		if (argc<16) {
			objv = objvstatic;
		} else {
			objv = (Tcl_Obj **)Tcl_Alloc((argc+4)*sizeof(Tcl_Obj *));
		}
		objv[0] = method->proc;
		objv[1] = class->class;
		if (object != NULL) {
			objv[2] = object->name;
		} else {
			objv[2] = class->class;
		}
		objc = 3;
		for(i=0;i<argc;i++) {
			objv[objc++] = argv[i];
			Tcl_IncrRefCount(argv[i]);
		}
		objv[objc] = NULL;
		i = Tcl_GetCommandInfo(interp,Tcl_GetStringFromObj(method->proc,NULL),&cmdinfo);
		if (i == 0) {return TCL_OK;}
		error = cmdinfo.objProc(cmdinfo.objClientData,interp,objc,objv);
		for(i=0;i<argc;i++) {
			Tcl_DecrRefCount(argv[i]);
		}
		return error;
	} else {
		error = ((Classy_Method *)method->func)(interp,class,object,argc,argv);
		return error;
	}
}

int Classy_FreeMethod(Method *method) {
	if (method->proc != NULL) {
		Tcl_DecrRefCount(method->proc);
		method->proc = NULL;
	}
	if (method->args != NULL) {
		Tcl_DecrRefCount(method->args);
		method->args = NULL;
	}
	return TCL_OK;
}

int Classy_CreateTclClassMethod(
	Tcl_Interp *interp,
	Method *method,
	Tcl_Obj *name,
	Tcl_Obj *args,
	Tcl_Obj *body,
	Tcl_Obj *rname)	
{
	Tcl_Obj *createObj = NULL, *realargs = NULL;
	int error;
	method->copy = 0;
	method->func = NULL;
	method->proc = name;
	Tcl_IncrRefCount(method->proc);
	createObj = Tcl_NewStringObj("proc",4);
	Tcl_IncrRefCount(createObj);
	error = Tcl_ListObjAppendElement(interp,createObj,method->proc);
	if (error != TCL_OK) {goto error;}
	realargs = Tcl_NewStringObj("class",5);
	Tcl_IncrRefCount(realargs);
	error = Tcl_ListObjAppendList(interp,realargs,args);
	if (error != TCL_OK) {goto error;}
	error = Tcl_ListObjAppendElement(interp,createObj,realargs);
	if (error != TCL_OK) {goto error;}
	error = Tcl_ListObjAppendElement(interp,createObj,body);
	if (error != TCL_OK) {goto error;}
	error = Tcl_EvalObj(interp,createObj);
	if (error != TCL_OK) {goto error;}
	error = Classy_ParseArgs(interp,args,&(method->min),&(method->max),rname,&(method->args));
	error:
		if (createObj != NULL) Tcl_DecrRefCount(createObj);
		if (realargs != NULL) Tcl_DecrRefCount(realargs);
		return error;
}

int Classy_CreateTclMethod(
	Tcl_Interp *interp,
	Method *method,
	Tcl_Obj *name,
	Tcl_Obj *args,
	Tcl_Obj *body,
	Tcl_Obj *rname)	
{
	Tcl_Obj *createObj = NULL, *realargs = NULL;
	int error;

	method->copy = 0;
	method->proc = name;
	method->func = NULL;
	Tcl_IncrRefCount(method->proc);
	createObj = Tcl_NewStringObj("proc",4);
	Tcl_IncrRefCount(createObj);
	error = Tcl_ListObjAppendElement(interp,createObj,method->proc);
	if (error != TCL_OK) {goto error;}
	realargs = Tcl_NewStringObj("class object",12);
	Tcl_IncrRefCount(realargs);
	error = Tcl_ListObjAppendList(interp,realargs,args);
	if (error != TCL_OK) {goto error;}
	error = Tcl_ListObjAppendElement(interp,createObj,realargs);
	if (error != TCL_OK) {goto error;}
	error = Tcl_ListObjAppendElement(interp,createObj,body);
	if (error != TCL_OK) {goto error;}
	error = Tcl_EvalObj(interp,createObj);
	if (error != TCL_OK) {return error;}
	error = Classy_ParseArgs(interp,args,&(method->min),&(method->max),rname,&(method->args));
	error:
		if (createObj != NULL) Tcl_DecrRefCount(createObj);
		if (realargs != NULL) Tcl_DecrRefCount(realargs);
		return error;
}

void Classy_CopyMethods(
	Classy_HashTable *src,
	Classy_HashTable *dst)
{
	Classy_HashSearch search;
	Classy_HashEntry *entry;
	Method *srcmethod,*method;
	Tcl_Obj *key;
	int new;

	entry = Classy_FirstHashEntry(src, &search);
	while(1) {
		if (entry == NULL) break;
		srcmethod = (Method *)Classy_GetHashValue(entry);
		key = Classy_GetHashKey(src, entry);
		entry = Classy_CreateHashEntry(dst,key,&new);
		if (new == 1) {
			method = (Method *)Tcl_Alloc(sizeof(Method));
			Classy_SetHashValue(entry,(ClientData)method);
		} else {
			method = (Method *)Classy_GetHashValue(entry);
			Classy_FreeMethod(method);
		}
		method->copy = 1;
		method->proc = srcmethod->proc;
		if (method->proc != NULL) {Tcl_IncrRefCount(method->proc);}
		method->args = srcmethod->args;
		if (method->args != NULL) {Tcl_IncrRefCount(method->args);}
		method->func = srcmethod->func;
		method->min = srcmethod->min;
		method->max = srcmethod->max;
		entry = Classy_NextHashEntry(&search);
	}
}

int Classy_CopyMethod(
	Classy_HashTable *src,
	Classy_HashTable *dst,
	Tcl_Obj *name)
{
	Classy_HashEntry *entry;
	Method *srcmethod,*method;
	int new;

	entry = Classy_FindHashEntry(src, name);
	if (entry == NULL) {return 0;}
	srcmethod = (Method *)Classy_GetHashValue(entry);
	entry = Classy_CreateHashEntry(dst,name,&new);
	if (new == 1) {
		method = (Method *)Tcl_Alloc(sizeof(Method));
		Classy_SetHashValue(entry,(ClientData)method);
	} else {
		method = (Method *)Classy_GetHashValue(entry);
		if (method->copy == 0) {return 0;}
		Classy_FreeMethod(method);
	}
	method->copy = 1;
	method->proc = srcmethod->proc;
	if (method->proc != NULL) {Tcl_IncrRefCount(method->proc);}
	method->args = srcmethod->args;
	if (method->args != NULL) {Tcl_IncrRefCount(method->args);}
	method->func = srcmethod->func;
	method->min = srcmethod->min;
	method->max = srcmethod->max;
	return 1;
}

int Classy_PropagateMethod(
	Tcl_Interp *interp,
	Class *class,
	int type,
	Tcl_Obj *name)
{
	Classy_HashEntry *entry;
	Classy_HashSearch search;
	Class *subclass;
	int done,error;

	entry = Classy_FirstHashEntry(&(class->subclasses), &search);
	while(1) {
		if (entry == NULL) break;
		subclass = (Class *)Classy_GetHashValue(entry);
		if (type == 'm') {
			done = Classy_CopyMethod(&(class->methods),&(subclass->methods),name);
		} else {
			done = Classy_CopyMethod(&(class->classmethods),&(subclass->classmethods),name);
		}
		if (done == 1) {
			error = Classy_PropagateMethod(interp,subclass,type,name);
			if (error != TCL_OK) {return error;}
		}
		entry = Classy_NextHashEntry(&search);
	}
	return TCL_OK;
}

int Classy_PropagateDeleteMethod(
	Tcl_Interp *interp,
	Class *class,
	int type,
	Tcl_Obj *name)
{
	Classy_HashEntry *entry,*mentry;
	Classy_HashSearch search;
	Class *subclass;
	Method *method;
	int error;

	entry = Classy_FirstHashEntry(&(class->subclasses), &search);
	while(1) {
		if (entry == NULL) break;
		subclass = (Class *)Classy_GetHashValue(entry);
		if (type == 'm') {
			mentry = Classy_FindHashEntry(&(subclass->methods),name);
		} else {
			mentry = Classy_FindHashEntry(&(subclass->classmethods),name);
		}
		if (mentry != NULL) {
			method = (Method *)Classy_GetHashValue(mentry);
			if (method->copy != 0) {
				error = Classy_PropagateDeleteMethod(interp,subclass,type,name);
				if (error != TCL_OK) {return error;}
				Classy_DeleteHashEntry(mentry);
				Classy_FreeMethod(method);
			}
		}
		entry = Classy_NextHashEntry(&search);
	}
	return TCL_OK;
}

int Classy_InfoClassMethods(
	Tcl_Interp *interp,
	Class *class,
	Tcl_Obj *pattern)
{
	Tcl_Obj *temp;
	Tcl_Obj *name;
	char *namestring;
	int error;

	if (pattern == NULL) {
		Classy_HashEntry *entry;
		Classy_HashSearch search;
		entry = Classy_FirstHashEntry(&(class->classmethods), &search);
		while(1) {
			if (entry == NULL) break;
			name = Classy_GetHashKey(&(class->methods),entry);
			namestring = Tcl_GetStringFromObj(name,NULL);
			if (namestring[0] != '_') {
				Tcl_AppendElement(interp, namestring);
			}
			entry = Classy_NextHashEntry(&search);
		}
		temp = Tcl_NewStringObj("lsort",5);
		Tcl_IncrRefCount(temp);
		error = Tcl_ListObjAppendElement(interp,temp,Tcl_GetObjResult(interp));
		if (error != TCL_OK) {Tcl_DecrRefCount(temp);return error;}
		error = Tcl_EvalObj(interp,temp);
		Tcl_DecrRefCount(temp);
		return error;
	} else {
		Classy_HashEntry *entry;
		Classy_HashSearch search;
		char *p;
		entry = Classy_FirstHashEntry(&(class->classmethods), &search);
		while(1) {
			if (entry == NULL) break;
			name = Classy_GetHashKey(&(class->methods),entry);
			namestring = Tcl_GetStringFromObj(name,NULL);
			p = Tcl_GetStringFromObj(pattern,NULL);
			if (Tcl_StringMatch(namestring, p) == 1) {
				Tcl_AppendElement(interp, namestring);
			}
			entry = Classy_NextHashEntry(&search);
		}
		temp = Tcl_NewStringObj("lsort",5);
		Tcl_IncrRefCount(temp);
		error = Tcl_ListObjAppendElement(interp,temp,Tcl_GetObjResult(interp));
		if (error != TCL_OK) {Tcl_DecrRefCount(temp);return error;}
		error = Tcl_EvalObj(interp,temp);
		Tcl_DecrRefCount(temp);
		return error;
	}
}

int Classy_ClassMethodClassMethod(
	Tcl_Interp *interp,
	Class *class,
	Object *object,
	int argc,
	Tcl_Obj *CONST argv[])
{
	Method *method,*oldmethod;
	Classy_HashEntry *entry;
	Tcl_Obj *procname;
	Tcl_Obj *nameObj;
	char *name;
	char *classname;
	int namelen,error,i,new;

	if (argc!=3) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"wrong # args: should be \"",Tcl_GetStringFromObj(class->class,NULL),
			" classmethod name args body\"", (char *)NULL);
		return TCL_ERROR;
	}
	classname = Tcl_GetStringFromObj(class->class,NULL);
	nameObj = argv[0];
	name = Tcl_GetStringFromObj(nameObj,&namelen);
	if ((namelen == 11)&&(strncmp(name,"classmethod",11)==0)) {
	} else if ((namelen == 6)&&(strncmp(name,"method",6)==0)) {
	} else if ((namelen == 12)&&(strncmp(name,"deletemethod",12)==0)) {
	} else if ((namelen == 17)&&(strncmp(name,"deleteclassmethod",17)==0)) {
	} else if ((namelen == 8)&&(strncmp(name,"subclass",8)==0)) {
	} else if ((namelen == 6)&&(strncmp(name,"parent",6)==0)) {
	} else if ((namelen == 8)&&(strncmp(name,"children",8)==0)) {
	} else if ((namelen == 3)&&(strncmp(name,"new",3)==0)) {
	} else if ((namelen == 7)&&(strncmp(name,"destroy",7)==0)) {
		if (strcmp(classname,"Class")==0) {
			Tcl_ResetResult(interp);
			Tcl_AppendResult(interp,"destroy classmethod of base Class cannot be redefined", (char *)NULL);
			return TCL_ERROR;
		}
		Tcl_GetStringFromObj(argv[1],&i);
		if (i!=0) {
			Tcl_ResetResult(interp);
			Tcl_AppendResult(interp,"destroy classmethod cannot have arguments", (char *)NULL);
			return TCL_ERROR;
		}
		if (class->classdestroy != NULL) {
			Classy_FreeMethod(class->classdestroy);
			Tcl_Free((char *)class->classdestroy);
		}
		method = (Method *)Tcl_Alloc(sizeof(Method));
		procname = Tcl_NewObj();
		Tcl_AppendStringsToObj(procname,"::Class::",classname,",,classdestroy",(char *)NULL);
		error = Classy_CreateTclClassMethod(interp,method,procname,argv[1],argv[2],Tcl_NewStringObj("classdestroy",12));
		if (error != TCL_OK) {Tcl_Free((char *)method);return error;}
		class->classdestroy=method;
		Tcl_SetObjResult(interp,nameObj);
		return TCL_OK;
	} else {
		Tcl_IncrRefCount(nameObj);
		method = (Method *)Tcl_Alloc(sizeof(Method));
		procname = Tcl_NewObj();
		Tcl_IncrRefCount(procname);
		Tcl_AppendStringsToObj(procname,"::Class::",classname,",,cm,",name,(char *)NULL);
		error = Classy_CreateTclClassMethod(interp,method,procname,argv[1],argv[2],nameObj);
		Tcl_DecrRefCount(procname);
		if (error != TCL_OK) {Tcl_DecrRefCount(nameObj);	return error;}
		entry = Classy_CreateHashEntry(&(class->classmethods),nameObj,&new);
		if (new == 0) {
			oldmethod = (Method *)Classy_GetHashValue(entry);
			Classy_FreeMethod(oldmethod);
			Tcl_Free((char *)oldmethod);
		}
		Classy_SetHashValue(entry,(ClientData)method);
		error = Classy_PropagateMethod(interp,class,'c',nameObj);
		if (error != TCL_OK) {Tcl_DecrRefCount(nameObj);return error;}
		Tcl_SetObjResult(interp,nameObj);
		Tcl_DecrRefCount(nameObj);
		return TCL_OK;
	}
	Tcl_ResetResult(interp);
	Tcl_AppendResult(interp, "\"", name, "\" classmethod cannot be redefined", (char *)NULL);
	return TCL_ERROR;
}

int Classy_DeleteClassMethodClassMethod(
	Tcl_Interp *interp,
	Class *class,
	Object *object,
	int argc,
	Tcl_Obj *CONST argv[])
{
	Method *method;
	Classy_HashEntry *entry;
	Tcl_Obj *string, *nameObj;
	char *name;
	char *classname;
	int namelen,error;

	if (argc!=1) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"wrong # args: should be \"",Tcl_GetStringFromObj(class->class,NULL),
			" deleteclassmethod name\"", (char *)NULL);
		return TCL_ERROR;
	}

	classname = Tcl_GetStringFromObj(class->class,NULL);
	nameObj = argv[0];
	name = Tcl_GetStringFromObj(nameObj,&namelen);
	if ((namelen == 11)&&(strncmp(name,"classmethod",11)==0)) {
	} else if ((namelen == 6)&&(strncmp(name,"method",6)==0)) {
	} else if ((namelen == 12)&&(strncmp(name,"deletemethod",12)==0)) {
	} else if ((namelen == 17)&&(strncmp(name,"deleteclassmethod",17)==0)) {
	} else if ((namelen == 8)&&(strncmp(name,"subclass",8)==0)) {
	} else if ((namelen == 6)&&(strncmp(name,"parent",6)==0)) {
	} else if ((namelen == 8)&&(strncmp(name,"children",8)==0)) {
	} else if ((namelen == 3)&&(strncmp(name,"new",3)==0)) {
	} else if ((namelen == 4)&&(strncmp(name,"init",4)==0)) {
		if (strcmp(classname,"Class")==0) {
			Tcl_ResetResult(interp);
			Tcl_AppendResult(interp,"init classmethod of base Class cannot be deleted", (char *)NULL);
			return TCL_ERROR;
		}
		if (class->init != NULL) {
			Classy_FreeMethod(class->init);
			Tcl_Free((char *)class->init);
			class->init = NULL;
			string = Tcl_NewObj();
			Tcl_IncrRefCount(string);
			Tcl_AppendStringsToObj(string,"rename ::Class::",classname,",,init {}",(char *)NULL);
			Tcl_EvalObj(interp,string);
			Tcl_DecrRefCount(string);
		}
		Tcl_ResetResult(interp);
		return TCL_OK;
	} else if ((namelen == 7)&&(strncmp(name,"destroy",7)==0)) {
		if (strcmp(classname,"Class")==0) {
			Tcl_ResetResult(interp);
			Tcl_AppendResult(interp,"destroy classmethod of base Class cannot be deleted", (char *)NULL);
			return TCL_ERROR;
		}
		if (class->classdestroy != NULL) {
			Classy_FreeMethod(class->classdestroy);
			Tcl_Free((char *)class->classdestroy);
			class->classdestroy = NULL;
			string = Tcl_NewObj();
			Tcl_IncrRefCount(string);
			Tcl_AppendStringsToObj(string,"rename ::Class::",classname,",,classdestroy {}",(char *)NULL);
			Tcl_EvalObj(interp,string);
			Tcl_DecrRefCount(string);
		}
		Tcl_ResetResult(interp);
		return TCL_OK;
	} else {
		entry = Classy_FindHashEntry(&(class->classmethods),nameObj);
		method = (Method *)Classy_GetHashValue(entry);
		Classy_FreeMethod(method);
		Classy_DeleteHashEntry(entry);
		string = Tcl_NewObj();
		Tcl_IncrRefCount(string);
		Tcl_AppendStringsToObj(string,"rename ::Class::",classname,",,cm,",name," {}",(char *)NULL);
		Tcl_EvalObj(interp,string);
		Tcl_DecrRefCount(string);
		Tcl_SetResult(interp,name,TCL_VOLATILE);
		error = Classy_PropagateDeleteMethod(interp,class,'c',nameObj);
		if (error != TCL_OK) {return error;}
		Tcl_ResetResult(interp);
		return TCL_OK;
	}
	Tcl_ResetResult(interp);
	Tcl_AppendResult(interp, "\"", name, "\" classmethod cannot be delted", (char *)NULL);
	return TCL_ERROR;
}

int Classy_InfoMethods(
	Tcl_Interp *interp,
	Class *class,
	Tcl_Obj *pattern)
{
	Tcl_Obj *temp, *nameObj;
	char *name;
	int error;

	if (pattern == NULL) {
		Classy_HashEntry *entry;
		Classy_HashSearch search;
		entry = Classy_FirstHashEntry(&(class->methods), &search);
		while(1) {
			if (entry == NULL) break;
			nameObj = Classy_GetHashKey(&(class->methods),entry);
			name = Tcl_GetStringFromObj(nameObj,NULL);
			if (name[0] != '_') {
				Tcl_AppendElement(interp, name);
			}
			entry = Classy_NextHashEntry(&search);
		}
		temp = Tcl_NewStringObj("lsort",5);
		Tcl_IncrRefCount(temp);
		error = Tcl_ListObjAppendElement(interp,temp,Tcl_GetObjResult(interp));
		if (error != TCL_OK) {Tcl_DecrRefCount(temp);return error;}
		error = Tcl_EvalObj(interp,temp);
		Tcl_DecrRefCount(temp);
		return error;
	} else {
		Classy_HashEntry *entry;
		Classy_HashSearch search;
		char *p;
		entry = Classy_FirstHashEntry(&(class->methods), &search);
		while(1) {
			if (entry == NULL) break;
			nameObj = Classy_GetHashKey(&(class->methods),entry);
			name = Tcl_GetStringFromObj(nameObj,NULL);
			p = Tcl_GetStringFromObj(pattern,NULL);
			if (Tcl_StringMatch(name, p) == 1) {
				Tcl_AppendElement(interp, name);
			}
			entry = Classy_NextHashEntry(&search);
		}
		temp = Tcl_NewStringObj("lsort",5);
		Tcl_IncrRefCount(temp);
		error = Tcl_ListObjAppendElement(interp,temp,Tcl_GetObjResult(interp));
		if (error != TCL_OK) {Tcl_DecrRefCount(temp);return error;}
		error = Tcl_EvalObj(interp,temp);
		Tcl_DecrRefCount(temp);
		return error;
	}
}

int Classy_MethodClassMethod(
	Tcl_Interp *interp,
	Class *class,
	Object *object,
	int argc,
	Tcl_Obj *CONST argv[])
{
	Method *method,*oldmethod;
	Classy_HashEntry *entry;
	Tcl_Obj *procname, *nameObj;
	char *name;
	char *classname;
	int namelen, error,i, new;

	if (argc!=3) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"wrong # args: should be \"",Tcl_GetStringFromObj(class->class,NULL),
			" method name args body\"", (char *)NULL);
		return TCL_ERROR;
	}

	classname = Tcl_GetStringFromObj(class->class,NULL);
	nameObj = argv[0];
	name = Tcl_GetStringFromObj(nameObj,&namelen);
	if ((namelen == 4)&&(strncmp(name,"init",4)==0)) {
		if (strcmp(classname,"Class")==0) {
			Tcl_ResetResult(interp);
			Tcl_AppendResult(interp,"init method of base Class cannot be redefined", (char *)NULL);
			return TCL_ERROR;
		}
		if (class->init != NULL) {
			Classy_FreeMethod(class->init);
			Tcl_Free((char *)class->init);
			class->init = NULL;
		}
		method = (Method *)Tcl_Alloc(sizeof(Method));
		procname = Tcl_NewObj();
		Tcl_AppendStringsToObj(procname,"::Class::",classname,",,init",(char *)NULL);
		error = Classy_CreateTclMethod(interp,method,procname,argv[1],argv[2],Tcl_NewStringObj("init",4));
		if (error != TCL_OK) {Tcl_Free((char *)method);return error;}
		class->init=method;
		Tcl_SetResult(interp,name,TCL_VOLATILE);
		return TCL_OK;
	} else if ((namelen == 7)&&(strncmp(name,"destroy",7)==0)) {
		if (strcmp(classname,"Class")==0) {
			Tcl_ResetResult(interp);
			Tcl_AppendResult(interp,"destroy method of base Class cannot be redefined", (char *)NULL);
			return TCL_ERROR;
		}
		Tcl_GetStringFromObj(argv[1],&i);
		if (i!=0) {
			Tcl_ResetResult(interp);
			Tcl_AppendResult(interp,"destroy method cannot have arguments", (char *)NULL);
			return TCL_ERROR;
		}
		if (class->destroy != NULL) {
			Classy_FreeMethod(class->destroy);
			Tcl_Free((char *)class->destroy);
		}
		method = (Method *)Tcl_Alloc(sizeof(Method));
		procname = Tcl_NewObj();
		Tcl_AppendStringsToObj(procname,"::Class::",classname,",,destroy",(char *)NULL);
		error = Classy_CreateTclMethod(interp,method,procname,argv[1],argv[2],Tcl_NewStringObj("destroy",7));
		if (error != TCL_OK) {Tcl_Free((char *)method);return error;}
		class->destroy = method;
		Tcl_SetResult(interp,name,TCL_VOLATILE);
		return TCL_OK;
	} else {
		Tcl_IncrRefCount(nameObj);
		method = (Method *)Tcl_Alloc(sizeof(Method));
		procname = Tcl_NewObj();
		Tcl_IncrRefCount(procname);
		Tcl_AppendStringsToObj(procname,"::Class::",classname,",,m,",name,(char *)NULL);
		error = Classy_CreateTclMethod(interp,method,procname,argv[1],argv[2],nameObj);
		Tcl_DecrRefCount(procname);
		if (error != TCL_OK) {Tcl_DecrRefCount(nameObj);return error;}
		entry = Classy_CreateHashEntry(&(class->methods),nameObj,&new);
		if (new == 0) {
			oldmethod = (Method *)Classy_GetHashValue(entry);
			Classy_FreeMethod(oldmethod);
			Tcl_Free((char *)oldmethod);
		}
		Classy_SetHashValue(entry,(ClientData)method);
		error = Classy_PropagateMethod(interp,class,'m',nameObj);
		if (error != TCL_OK) {Tcl_DecrRefCount(nameObj);return error;}
		Tcl_SetObjResult(interp,nameObj);
		Tcl_DecrRefCount(nameObj);
		return TCL_OK;
	}
}

int Classy_DeleteMethodClassMethod(
	Tcl_Interp *interp,
	Class *class,
	Object *object,
	int argc,
	Tcl_Obj *CONST argv[])
{
	Method *method;
	Classy_HashEntry *entry;
	Tcl_Obj *string, *nameObj;
	char *name;
	char *classname;
	int namelen, error;

	if (argc!=1) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"wrong # args: should be \"",Tcl_GetStringFromObj(class->class,NULL),
			" deletemethod\"", (char *)NULL);
		return TCL_ERROR;
	}

	classname = Tcl_GetStringFromObj(class->class,NULL);
	nameObj = argv[0];
	name = Tcl_GetStringFromObj(nameObj,&namelen);
	if ((namelen == 7)&&(strncmp(name,"destroy",7)==0)) {
		if (strcmp(classname,"Class")==0) {
			Tcl_ResetResult(interp);
			Tcl_AppendResult(interp,"destroy method of base Class cannot be deleted", (char *)NULL);
			return TCL_ERROR;
		}
		if (class->destroy != NULL) {
			Classy_FreeMethod(class->destroy);
			Tcl_Free((char *)class->destroy);
			class->destroy = NULL;
			string = Tcl_NewObj();
			Tcl_IncrRefCount(string);
			Tcl_AppendStringsToObj(string,"rename ::Class::",classname,",,destroy {}",(char *)NULL);
			Tcl_EvalObj(interp,string);
			Tcl_DecrRefCount(string);
		}
		Tcl_ResetResult(interp);
		return TCL_OK;
	} else {
		entry = Classy_FindHashEntry(&(class->methods),nameObj);
		method = (Method *)Classy_GetHashValue(entry);
		Classy_FreeMethod(method);
		Classy_DeleteHashEntry(entry);
		string = Tcl_NewObj();
		Tcl_IncrRefCount(string);
		Tcl_AppendStringsToObj(string,"rename ::Class::",classname,",,m,",name," {}",(char *)NULL);
		Tcl_EvalObj(interp,string);
		Tcl_DecrRefCount(string);
		Tcl_SetResult(interp,name,TCL_VOLATILE);
		error = Classy_PropagateDeleteMethod(interp,class,'m',nameObj);
		if (error != TCL_OK) {return error;}
		Tcl_ResetResult(interp);
		return TCL_OK;
	}
}

extern int Classy_CreateClassMethod(
	Tcl_Interp *interp,
	char *classname,
	Tcl_Obj *nameObj,
	Classy_Method *func) 
{
	Tcl_CmdInfo cmdinfo;
	Class *class;
	Method *method;
	Classy_HashEntry *entry;
	char *name;
	int namelen,new,found,error;

	found = Tcl_GetCommandInfo(interp,classname,&cmdinfo);
	if (found == 0) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"class \"",classname,"\" does not exist", (char *)NULL);
		return TCL_ERROR;
	}
	class = (Class *)cmdinfo.objClientData;
	name = Tcl_GetStringFromObj(nameObj,&namelen);
	if ((namelen == 4)&&(strncmp(name,"init",4)==0)) {
		if (class->init != NULL) {
			Classy_FreeMethod(class->init);
			Tcl_Free((char *)class->init);
		}
		method = (Method *)Tcl_Alloc(sizeof(Method));
		method->copy = 0;
		method->proc = NULL;
		method->args = NULL;
		method->func = func;
		class->init=method;
		Tcl_SetResult(interp,name,TCL_VOLATILE);
		return TCL_OK;
	} else if ((namelen == 7)&&(strncmp(name,"destroy",7)==0)) {
		if (class->classdestroy != NULL) {
			Classy_FreeMethod(class->classdestroy);
			Tcl_Free((char *)class->classdestroy);
		}
		method = (Method *)Tcl_Alloc(sizeof(Method));
		method->copy = 0;
		method->proc = NULL;
		method->args = NULL;
		method->func = func;
		class->classdestroy=method;
		Tcl_SetResult(interp,name,TCL_VOLATILE);
		return TCL_OK;
	} else {
		entry = Classy_CreateHashEntry(&(class->classmethods),nameObj,&new);
		if (new == 1) {
			method = (Method *)Tcl_Alloc(sizeof(Method));
			Classy_SetHashValue(entry,(ClientData)method);
		} else {
			method = (Method *)Classy_GetHashValue(entry);
			Classy_FreeMethod(method);
		}
		method->copy = 0;
		method->proc = NULL;
		method->args = NULL;
		method->func = func;
		error = Classy_PropagateMethod(interp,class,'c',nameObj);
		if (error != TCL_OK) {return error;}
		Tcl_SetResult(interp,name,TCL_VOLATILE);
		return TCL_OK;
	}
}

extern int Classy_CreateMethod(
	Tcl_Interp *interp,
	char *classname,
	Tcl_Obj *nameObj,
	Classy_Method *func) 
{
	Tcl_CmdInfo cmdinfo;
	Class *class;
	Method *method;
	Classy_HashEntry *entry;
	char *name;
	int namelen,new,found,error;

	found = Tcl_GetCommandInfo(interp,classname,&cmdinfo);
	if (found == 0) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"class \"",classname,"\" does not exist", (char *)NULL);
		return TCL_ERROR;
	}
	class = (Class *)cmdinfo.objClientData;
	name = Tcl_GetStringFromObj(nameObj,&namelen);
	if ((namelen == 7)&&(strncmp(name,"destroy",7)==0)) {
		if (class->destroy != NULL) {
			Classy_FreeMethod(class->destroy);
			Tcl_Free((char *)class->destroy);
		}
		method = (Method *)Tcl_Alloc(sizeof(Method));
		method->copy = 0;
		method->proc = NULL;
		method->args = NULL;
		method->func = func;
		class->destroy=method;
		Tcl_SetResult(interp,name,TCL_VOLATILE);
		return TCL_OK;
	} else {
		nameObj = Tcl_NewStringObj(name,namelen);
		entry = Classy_CreateHashEntry(&(class->methods),nameObj,&new);
		if (new == 1) {
			method = (Method *)Tcl_Alloc(sizeof(Method));
			Classy_SetHashValue(entry,(ClientData)method);
		} else {
			method = (Method *)Classy_GetHashValue(entry);
			Classy_FreeMethod(method);
		}
		method->copy = 0;
		method->proc = NULL;
		method->args = NULL;
		method->func = func;
		error = Classy_PropagateMethod(interp,class,'m',nameObj);
		if (error != TCL_OK) {return error;}
		Tcl_SetResult(interp,name,TCL_VOLATILE);
		return TCL_OK;
	}
}

int Classy_InfoMethodinfo(
	Tcl_Interp *interp,
	Class *class,
	Object *object,
	int argc,
	Tcl_Obj *CONST argv[])
{
	Classy_HashEntry *entry;
	Method *method;
	Tcl_Obj *nameObj;
	char *option,*name,*cmd;
	int optionlen;

	if (object != NULL) {
		cmd = Tcl_GetStringFromObj(object->name,NULL);
	} else {
		cmd = Tcl_GetStringFromObj(class->class,NULL);
	}
	option = Tcl_GetStringFromObj(argv[0],&optionlen);
	nameObj = argv[1];
	name = Tcl_GetStringFromObj(nameObj,NULL);
	if (strcmp(name,"init") == 0) {
		method = class->init;
	} else if (strcmp(name,"destroy") == 0) {
		method = class->destroy;
	} else {
		entry = Classy_FindHashEntry(&(class->methods), nameObj);
		if (entry == NULL) {
			method = NULL;
		} else {
			method = (Method *)Classy_GetHashValue(entry);
		}
	}
	if (method == NULL) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"class \"",cmd,
			"\" does not have a method \"", name, "\"", (char *)NULL);
		return TCL_ERROR;
	}
	Tcl_ResetResult(interp);
	if ((optionlen == 4) &&(strncmp(option,"body",4) == 0)) {
		if (method->proc == NULL) {
			Tcl_AppendResult(interp,"method \"",name,"\" of ",cmd , "\" is defined in C", (char *)NULL);
			return TCL_ERROR;
		}
		Tcl_VarEval(interp,"info body ",Tcl_GetStringFromObj(method->proc,NULL),(char *)NULL);
		return TCL_OK;
	} else if ((optionlen == 4) &&(strncmp(option,"args",4) == 0)) {
		if (method->proc == NULL) {
			Tcl_AppendResult(interp,"method \"",name,"\" of ",cmd , "\" is defined in C", (char *)NULL);
			return TCL_ERROR;
		}
		Tcl_VarEval(interp,"lrange [info args ",Tcl_GetStringFromObj(method->proc,NULL),"] 2 end",(char *)NULL);
		return TCL_OK;
	} else if ((optionlen == 7) &&(strncmp(option,"default",7) == 0)) {
		if (method->proc == NULL) {
			Tcl_AppendResult(interp,"method \"",name,"\" of ",cmd , "\" is defined in C", (char *)NULL);
			return TCL_ERROR;
		}
		if (argc != 4) {
			Tcl_AppendResult(interp,"wrong # args: should be \"",
				cmd,
				" info method default name arg varname\"", (char *)NULL);
			return TCL_ERROR;
		}
		Tcl_VarEval(interp,"info default ",Tcl_GetStringFromObj(method->proc,NULL),
			" ",Tcl_GetStringFromObj(argv[2],NULL)," ",Tcl_GetStringFromObj(argv[3],NULL), (char *)NULL);
		return TCL_OK;
	} else {
		Tcl_AppendResult(interp,"wrong option \"",option,
			"\" must be body, args or default", (char *)NULL);
		return TCL_ERROR;
	}
}

int Classy_InfoClassMethodinfo(
	Tcl_Interp *interp,
	Class *class,
	int argc,
	Tcl_Obj *CONST argv[])
{
	Classy_HashEntry *entry;
	Method *method;
	Tcl_Obj *nameObj;
	char *option,*name;
	int optionlen;

	option = Tcl_GetStringFromObj(argv[0],&optionlen);
	nameObj = argv[1];
	name = Tcl_GetStringFromObj(nameObj,NULL);
	entry = Classy_FindHashEntry(&(class->classmethods), nameObj);
	if (entry == NULL) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"class \"",Tcl_GetStringFromObj(class->class,NULL),
			"\" does not have a classmethod \"", name, "\"", (char *)NULL);
		return TCL_ERROR;
	}
	method = (Method *)Classy_GetHashValue(entry);
	Tcl_ResetResult(interp);
	if (method->proc == NULL) {
		Tcl_AppendResult(interp,"classmethod \"",name,
			"\" of class ",Tcl_GetStringFromObj(class->class,NULL) , "\" is defined in C", (char *)NULL);
		return TCL_ERROR;
	}
	if ((optionlen == 4) &&(strncmp(option,"body",4) == 0)) {
		Tcl_VarEval(interp,"info body ",Tcl_GetStringFromObj(method->proc,NULL),(char *)NULL);
		return TCL_OK;
	} else if ((optionlen == 4) &&(strncmp(option,"args",4) == 0)) {
		Tcl_VarEval(interp,"lrange [info args ",Tcl_GetStringFromObj(method->proc,NULL),"] 1 end",(char *)NULL);
		return TCL_OK;
	} else if ((optionlen == 7) &&(strncmp(option,"default",7) == 0)) {
		if (argc != 4) {
			Tcl_AppendResult(interp,"wrong # args: should be \"",
				Tcl_GetStringFromObj(class->class,NULL),
				" info classmethod default name arg varname\"", (char *)NULL);
			return TCL_ERROR;
		}
		Tcl_VarEval(interp,"info default ",Tcl_GetStringFromObj(method->proc,NULL),
			" ",Tcl_GetStringFromObj(argv[2],NULL)," ",Tcl_GetStringFromObj(argv[3],NULL), (char *)NULL);
		return TCL_OK;
	} else {
		Tcl_AppendResult(interp,"wrong option \"",option,
			"\" must be body, args or default", (char *)NULL);
		return TCL_ERROR;
	}
}



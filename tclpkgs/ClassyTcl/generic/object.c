/*
 *       File:    object.c
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

Classy_Method Classy_MethodClassMethod;

void Classy_FreeObject(char *clientdata) {
	Object *object = (Object *)clientdata;
	if (object->name != NULL) {
		Tcl_DecrRefCount(object->name);
		object->name = NULL;
	}
	if (object->trace != NULL) {
		Tcl_DecrRefCount(object->trace);
		object->trace = NULL;
	}
	Tcl_Free(clientdata);
}

int Classy_ObjectObjCmd(
	ClientData clientdata,
	Tcl_Interp *interp,
	int argc,
	Tcl_Obj *argv[])
{
	Class *class;
	Object *object;
	Classy_HashEntry *entry;
	Tcl_Obj *cmdObj;
	char *cmd;
	int error;

	object = (Object *)clientdata;
	class = object->parent;
	if (argc<2) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"wrong # args: should be \"",Tcl_GetStringFromObj(argv[0],NULL)," cmd ...\"", (char *)NULL);
		return TCL_ERROR;
	}
	if (object->trace != NULL) {
		Tcl_Obj *cmd;
		cmd = Tcl_DuplicateObj(object->trace);
		Tcl_IncrRefCount(cmd);
		error = Tcl_ListObjAppendElement(interp, cmd, Tcl_NewListObj(argc,argv));
		if (error != TCL_OK) {Tcl_DecrRefCount(cmd);return error;}
		error = Tcl_EvalObj(interp,cmd);
		Tcl_DecrRefCount(cmd);
		if (error != TCL_OK) {return error;}
	}
	cmdObj = argv[1];
	cmd = Tcl_GetStringFromObj(cmdObj,NULL);
	argv+=2;
	argc-=2;
	entry = Classy_FindHashEntry(&(class->methods), cmdObj);
	if (entry == NULL) {
		error = Tcl_VarEval(interp,"Class::auto_load_method ",Tcl_GetStringFromObj(class->class,NULL)," m ",cmd,(char *)NULL);
		if (error) {return error;}
		entry = Classy_FindHashEntry(&(class->methods), cmdObj);
	}
	if (entry != NULL) {
		Method *method;
		method = (Method *)Classy_GetHashValue(entry);
		Tcl_Preserve((ClientData)object);
		error = Classy_ExecMethod(interp,method,class,object,argc,argv);
		if (error != TCL_OK) {
			Tcl_Obj *errorObj = Tcl_NewStringObj("\nwhile invoking method \"",24);
			Tcl_AppendStringsToObj(errorObj, cmd, "\" of object \"", Tcl_GetStringFromObj(object->name,NULL), "\"\n", (char *) NULL);
			Tcl_AddObjErrorInfo(interp, Tcl_GetStringFromObj(errorObj,NULL), -1);
			Tcl_DecrRefCount(errorObj);
		}
		Tcl_Release((ClientData)object);
		return error;
	} else {
		Tcl_Obj *result, **objv;
		int objc,i;
		Tcl_ResetResult(interp);
		error = Classy_InfoMethods(interp,class,NULL);
		if (error != TCL_OK) {return error;}
		result = Tcl_GetObjResult(interp);
		Tcl_IncrRefCount(result);
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"bad option \"",cmd ,"\": must be ", (char *)NULL);
		error = Tcl_ListObjGetElements(interp, result, &objc, &objv);
		if (error != TCL_OK) {return error;}
		Tcl_AppendElement(interp, Tcl_GetStringFromObj(objv[0],NULL));
		for (i=1;i<objc;i++) {
			Tcl_AppendResult(interp, ", ", Tcl_GetStringFromObj(objv[i],NULL), NULL);
		}
		Tcl_DecrRefCount(result);
		return TCL_ERROR;
	}
}

/* This function destroys an object
 * it calls the destructors of each parent class
 */

static Classy_destroyerror;

void Classy_ObjectDestroy(ClientData clientdata) {
	Class *class, *tempclass;
	Object *object;
	Tcl_Obj *destroy_errors = NULL;
	Classy_HashEntry *entry;
	char *string;
	int error;
	object = (Object *)clientdata;
	Tcl_Preserve(clientdata);
	class = object->parent;
	tempclass = class;
	while(1) {
		if (tempclass->destroy != NULL) {
			error = Classy_ExecMethod(class->interp,tempclass->destroy,class,object,0,NULL);
			if (error) {
				if (destroy_errors == NULL) {
					destroy_errors = Tcl_GetObjResult(class->interp);
					Tcl_IncrRefCount(destroy_errors);
				} else {
					Tcl_AppendToObj(destroy_errors,"\n",1);
					Tcl_AppendObjToObj(destroy_errors,Tcl_GetObjResult(class->interp));
				}
			}
		}
		tempclass = tempclass->parent;
		if (tempclass == NULL) break;
	}
	string = Tcl_GetStringFromObj(object->name,NULL);
	entry = Classy_FindHashEntry(&(class->children),object->name);
	if (entry != NULL) {Classy_DeleteHashEntry(entry);}
	Tcl_VarEval(class->interp,"foreach ::Class::var [info vars ::Class::", string,",,*] {unset $::Class::var}", (char *)NULL);
	Tcl_EventuallyFree(clientdata,Classy_FreeObject);
	Tcl_Release(clientdata);
	if (destroy_errors != NULL) {
		Tcl_SetVar2Ex(class->interp,"::errorInfo",NULL,destroy_errors,TCL_GLOBAL_ONLY);
		Classy_destroyerror = 1;
	} else {
		Classy_destroyerror = 0;
	}
}

int Classy_ObjectDestroyObjCmd(
	Tcl_Interp *interp,
	Class *class,
	Object *object,
	int argc,
	Tcl_Obj *CONST argv[])
{
	Tcl_Preserve((ClientData)object);
	Tcl_DeleteCommandFromToken(interp,object->token);
	Tcl_Release((ClientData)object);
	if (Classy_destroyerror) {
		CONST char *string;
		string = Tcl_GetVar(interp,"::errorInfo",TCL_GLOBAL_ONLY);
		Tcl_AppendResult(interp,"\"",(char *)string,"\" in destroy method of object \"",
			Tcl_GetStringFromObj(object->name,NULL),"\" for class \"",Tcl_GetStringFromObj(class->class,NULL),"\"",(char *)NULL);
		return TCL_ERROR;
	} else {
		return TCL_OK;
	}
}

static Classy_HashTable classcurrent;
void Classy_InitSuper() {
	Classy_InitHashTable(&classcurrent);
}

static int objectnum = 1;
int Classy_NewClassMethod(
	Tcl_Interp *interp,
	Class *class,
	Object *object,
	int argc,
	Tcl_Obj *CONST argv[])
{
	Class *tempclass;
	Classy_HashEntry *entry;
	Tcl_Obj *name,*tempobj;
	Tcl_CmdInfo cmdinfo;
	char *string;
	char buffer[22];
	int len,pos,found,error,new;
	if (argc < 0) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"wrong # args: should be \"",Tcl_GetStringFromObj(class->class,NULL),
			" new ?object? ?args?\"", (char *)NULL);
		return TCL_ERROR;
	}
	if (argc > 0) {
		string = Tcl_GetStringFromObj(argv[0],&len);
	}
	if ((argc == 0) || ((len == 5) && (strncmp(string,"#auto",5) == 0))) {
		sprintf(buffer,"::Class::o%d",objectnum++);
		len = strlen(buffer);
		string = buffer;
	} else if (len > 2) {
		if ((string[0]==':')&&(string[1]==':')) {
			string += 2;
			len -= 2;
		}
		pos = len - 1;
		while (pos>1) {
			if ((string[pos]==':')&&(string[pos-1]==':')) break;
			pos--;
		}
		if (pos != 1) {
			string[pos-1] = '\0';
			error = Tcl_VarEval(interp,"namespace eval ",string, " {}", (char *)NULL);
			if (error != TCL_OK) {return error;}
			error = Tcl_VarEval(interp,"namespace eval ::Class::",string, " {}", (char *)NULL);
			if (error != TCL_OK) {return error;}
			string[pos-1] = ':';
		}
	}
	name = Tcl_NewStringObj(string,len);
	found = Tcl_GetCommandInfo(interp,string,&cmdinfo);
	if (found == 1) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"command \"",string,"\" exists", (char *)NULL);
		return TCL_ERROR;
	}
	entry = Tcl_CreateHashEntry(&(class->children),name,&new);
	if (new == 1) {
		object = (Object *)Tcl_Alloc(sizeof(Object));
		Classy_SetHashValue(entry,(ClientData)object);
	} else {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"command \"",string,"\" exists", (char *)NULL);
		return TCL_ERROR;
	}
	object->parent = class;
	object->name = name;
	Tcl_IncrRefCount(name);
	object->trace = NULL;
	object->token = Tcl_CreateObjCommand(interp,string,(Tcl_ObjCmdProc *)Classy_ObjectObjCmd,
		(ClientData)object,(Tcl_CmdDeleteProc *)Classy_ObjectDestroy);
	tempclass = class;
	while(1) {
		if (tempclass->init != NULL) {
			Tcl_Obj *stringkey;
			Tcl_ResetResult(interp);
			stringkey = Tcl_NewStringObj(string,len);
			Tcl_AppendToObj(stringkey,",init",5);
			entry = Tcl_CreateHashEntry(&classcurrent,stringkey,&new);
			Classy_SetHashValue(entry, (ClientData)tempclass);
			if (argc > 0) {
				error = Classy_ExecMethod(interp,tempclass->init,class,object,argc-1,argv+1);
			} else {
				error = TCL_OK;
			}
			Classy_DeleteHashEntry(entry);
			if (error != TCL_OK) {
				Tcl_Obj *errorObj, *errorinfo;
				errorObj = Tcl_GetObjResult(interp);
				Tcl_IncrRefCount(errorObj);
				tempobj = Tcl_NewStringObj("errorInfo",-1);
				errorinfo = Tcl_ObjGetVar2(interp, tempobj, NULL, TCL_GLOBAL_ONLY);
				Tcl_DecrRefCount(tempobj);
				Tcl_IncrRefCount(errorinfo);
				Tcl_DeleteCommandFromToken(interp,object->token);
				Tcl_ResetResult(interp);
				Tcl_AddObjErrorInfo(interp, Tcl_GetStringFromObj(errorinfo,NULL), -1);
				Tcl_SetObjResult(interp,errorObj);
				Tcl_DecrRefCount(errorObj);
				Tcl_DecrRefCount(errorinfo);
				return error;
			}
			break;
		}
		tempclass = tempclass->parent;
		if (tempclass == NULL) {
			break;
		}
	}
	Tcl_SetObjResult(interp,name);
	return TCL_OK;
}

int Classy_TraceMethod(
	Tcl_Interp *interp,
	Class *class,
	Object *object,
	int argc,
	Tcl_Obj *CONST argv[])
{
	char *command;
	int len;
	if (argc!=1) {
		Tcl_ResetResult(interp);
		Tcl_WrongNumArgs(interp,argc,argv," procedure");
		return TCL_ERROR;
	}
	command = Tcl_GetStringFromObj(argv[0],&len);
	if (len != 0) {
		if (object != NULL) {
			object->trace = Tcl_DuplicateObj(argv[0]);
			Tcl_IncrRefCount(object->trace);
		} else {
			class->trace = Tcl_DuplicateObj(argv[0]);
			Tcl_IncrRefCount(class->trace);
		}
	} else {
		if (object != NULL) {
			if (object->trace != NULL) {
				Tcl_DecrRefCount(object->trace);
				object->trace = NULL;
			}
		} else {
			if (class->trace != NULL) {
				Tcl_DecrRefCount(class->trace);
				class->trace = NULL;
			}
		}
	}
	return TCL_OK;
}

int Classy_SuperObjCmd(
	ClientData clientdata,
	Tcl_Interp *interp,
	int argc,
	Tcl_Obj *CONST argv[])
{
	Tcl_CmdInfo cmdinfo;
	Classy_HashEntry *entry, *mentry;
	Class *class, *current;
	Object *object = NULL;
	Method *cmethod, *bmethod;
	char *classname, *objectname,*option;
	Tcl_Obj *stringkey, *optionObj;
	int found, error, optlen, new, skip;
	if (argc<1) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"wrong # args: should be \"super option ...\"", (char *)NULL);
		return TCL_ERROR;
	}
	/* get class and object from variables in local scope, check for init */
	classname = Tcl_GetVar(interp, "class", TCL_LEAVE_ERR_MSG);
	if (classname == NULL) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"no variable \"class\" found", (char *)NULL);
		return TCL_ERROR;
	}
	found = Tcl_GetCommandInfo(interp, classname, &cmdinfo);
	if (found == 0) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"class \"",classname,"\" does not exist", (char *)NULL);
		return TCL_ERROR;
	}
	class = (Class *)cmdinfo.objClientData;
	objectname = Tcl_GetVar(interp, "object", TCL_LEAVE_ERR_MSG);
	optionObj = argv[1];
	option = Tcl_GetStringFromObj(optionObj,&optlen);
	if (objectname == NULL) {
		if ((optlen == 4) &&(strncmp(option,"init",4)==0)) {
			Tcl_ResetResult(interp);
			Tcl_AppendResult(interp,"no variable \"object\" found", (char *)NULL);
			return TCL_ERROR;
		} else {
			stringkey = Tcl_NewStringObj(classname,strlen(classname));
			Tcl_AppendToObj(stringkey,",",1);
			Tcl_AppendToObj(stringkey,option,optlen);
		}
	} else {
		found = Tcl_GetCommandInfo(interp, objectname, &cmdinfo);
		if (found == 0) {
			Tcl_ResetResult(interp);
			Tcl_AppendResult(interp,"object \"",objectname,"\" does not exist", (char *)NULL);
			return TCL_ERROR;
		}
		object = (Object *)cmdinfo.objClientData;
		stringkey = Tcl_NewStringObj(objectname,strlen(objectname));
		Tcl_AppendToObj(stringkey,",",1);
		Tcl_AppendToObj(stringkey,option,optlen);
	}
	entry = Tcl_CreateHashEntry(&classcurrent,stringkey,&new);
	if (new == 0) {
		current = (Class *)Classy_GetHashValue(entry);
	} else {
		current = class;
	}
	if ((optlen == 4) &&(strncmp(option,"init",4)==0)) {
		/* init has to be dealt with differently */
		if (current->parent != NULL) {
			current = current->parent;
			while(1) {
				if (current->init != NULL) {
					Classy_SetHashValue(entry, (ClientData)current);
					error = Classy_ExecMethod(interp,current->init,class,object,argc-2,argv+2);
					if (new != 0) {Classy_DeleteHashEntry(entry);}
					return error;
				}
				current = current->parent;
				if (current == NULL) break;
			}
		}
		Tcl_SetResult(interp,objectname,TCL_VOLATILE);
	} else if (objectname != NULL) {
		/* find method to execute */
		if (current->parent == NULL) {
			Tcl_ResetResult(interp);
			Tcl_AppendResult(interp,"No method \"",option,"\" defined for super of ",objectname,
				" (at class \"",Tcl_GetStringFromObj(current->class,NULL),"\"", (char *)NULL);
			if (new != 0) {Classy_DeleteHashEntry(entry);}
			return TCL_ERROR;
		}
		mentry = Classy_FindHashEntry(&(current->methods), optionObj);
		if (mentry != NULL) {
			cmethod = (Method *)Classy_GetHashValue(mentry);
			if (cmethod->copy == 1) {skip = 1;} else {skip = 0;}
			current = current->parent;
			while(1) {
				mentry = Classy_FindHashEntry(&(current->methods), optionObj);
				if (mentry == NULL) break;
				bmethod = (Method *)Classy_GetHashValue(mentry);
				if (bmethod->copy == 0) {
					if (skip) {
						skip = 0;
					} else {
						Classy_SetHashValue(entry, (ClientData)current);
						Tcl_Preserve((ClientData)object);
						Classy_SetHashValue(entry, (ClientData)current);
						error = Classy_ExecMethod(interp,bmethod,class,object,argc-2,argv+2);
						Tcl_Release((ClientData)object);
						if (new != 0) {Classy_DeleteHashEntry(entry);}
						return error;
					}
				}
				if (current->parent == NULL) break;
				current = current->parent;
			}
		}
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"No method \"",option,"\" defined for super of ",objectname,
			" (at class \"",Tcl_GetStringFromObj(current->class,NULL),"\")", (char *)NULL);
		if (new != 0) {Classy_DeleteHashEntry(entry);}
		return TCL_ERROR;
	} else {
		/* no object found, so find a classmethod to execute */
		if (current->parent == NULL) {
			Tcl_ResetResult(interp);
			Tcl_AppendResult(interp,"No classmethod \"",option,"\" defined for super of ",classname,
				" (at class \"",Tcl_GetStringFromObj(current->class,NULL),"\"", (char *)NULL);
			if (new != 0) {Classy_DeleteHashEntry(entry);}
			return TCL_ERROR;
		}
		mentry = Classy_FindHashEntry(&(current->classmethods), optionObj);
		if (mentry != NULL) {
			cmethod = (Method *)Classy_GetHashValue(mentry);
			if (cmethod->copy == 1) {skip = 1;} else {skip = 0;}
			current = current->parent;
			while(1) {
				mentry = Classy_FindHashEntry(&(current->classmethods), optionObj);
				if (mentry == NULL) break;
				bmethod = (Method *)Classy_GetHashValue(mentry);
				if (bmethod->copy == 0) {
					if (skip) {
						skip = 0;
					} else {
						Classy_SetHashValue(entry, (ClientData)current);
						Tcl_Preserve((ClientData)class);
						Classy_SetHashValue(entry, (ClientData)current);
						error = Classy_ExecClassMethod(interp,bmethod,class,NULL,argc-2,argv+2);
						Tcl_Release((ClientData)class);
						if (new != 0) {Classy_DeleteHashEntry(entry);}
						return error;
					}
				}
				if (current->parent == NULL) break;
				current = current->parent;
			}
		}
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"No classmethod \"",option,"\" defined for super of ",classname,
			" (at class \"",Tcl_GetStringFromObj(current->class,NULL),"\")", (char *)NULL);
		if (new != 0) {Classy_DeleteHashEntry(entry);}
		return TCL_ERROR;
	}
	
	if (new != 0) {Classy_DeleteHashEntry(entry);}
	return TCL_OK;
}

int Classy_ChangeclassMethod(
	Tcl_Interp *interp,
	Class *class,
	Object *object,
	int argc,
	Tcl_Obj *CONST argv[])
{
	Tcl_CmdInfo cmdinfo;
	Class *newclass;
	Classy_HashEntry *entry;
	char *classname;
	int classlen,found,new;
	if (argc != 1) {
		Tcl_ResetResult(interp);
		Tcl_WrongNumArgs(interp,argc,argv," class");
		return TCL_ERROR;
	}
	classname = Tcl_GetStringFromObj(argv[0],&classlen);
	Tcl_VarEval(interp,"auto_load {",classname,"}",(char *)NULL);
	found = Tcl_GetCommandInfo(interp, classname, &cmdinfo);
	if (found == 0) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"class \"",classname,"\" does not exist", (char *)NULL);
		return TCL_ERROR;
	}
	newclass = (Class *)cmdinfo.objClientData;
	entry = Tcl_CreateHashEntry(&(newclass->children),object->name,&new);
	if (new == 1) {
		Classy_SetHashValue(entry,(ClientData)object);
	} else {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"command \"",object->name,"\" exists", (char *)NULL);
		return TCL_ERROR;
	}
	entry = Classy_FindHashEntry(&(class->children),object->name);
	if (entry != NULL) {Classy_DeleteHashEntry(entry);}
	object->parent = newclass;
	return TCL_OK;
}

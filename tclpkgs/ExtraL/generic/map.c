/*	
 *	 File:	map.c
 *	 Purpose: extraL extension to Tcl
 *	 Author:  Copyright (c) 1995 Peter De Rijk
 *
 *	 See the file "README" for information on usage and redistribution
 *	 of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 */

#include "tcl.h"
#include "extral.h"
#include <string.h>

extern ExtraL_MapTypeSetProc ExtraL_MapSetDouble;
extern ExtraL_MapTypeSetProc ExtraL_MapSetInt;
extern ExtraL_MapTypeSetProc ExtraL_MapSetBool;
extern ExtraL_MapTypeSetProc ExtraL_MapSetRegexp;
extern ExtraL_MapTypeSetProc ExtraL_MapSetBetween;
extern ExtraL_MapTypeSetProc ExtraL_MapSetDBetween;
extern ExtraL_MapTypeSetProc ExtraL_MapSetDate;
extern ExtraL_MapTypeGetProc ExtraL_MapGetDate;
extern ExtraL_MapTypeSetProc ExtraL_MapSetTime;
extern ExtraL_MapTypeGetProc ExtraL_MapGetTime;
extern ExtraL_MapTypeSetProc ExtraL_MapSetList;
extern ExtraL_MapTypeGetProc ExtraL_MapGetList;
extern ExtraL_MapTypeSetProc ExtraL_MapSetNamed;
extern ExtraL_MapTypeGetProc ExtraL_MapGetNamed;
extern ExtraL_MapTypeUnsetProc ExtraL_MapUnsetList;
extern ExtraL_MapTypeUnsetProc ExtraL_MapUnsetNamed;

#ifdef unix
#define extern
#endif

struct Type {
	ExtraL_MapTypeSetProc *setproc;
	ExtraL_MapTypeGetProc *getproc;
	ExtraL_MapTypeUnsetProc *unsetproc;
};

static Tcl_HashTable typesTable;

/*
int ExtraL_CopyObj(Tcl_Obj *objPtr,Tcl_Obj *dupPtr) {
	register Tcl_ObjType *typePtr = objPtr->typePtr;
	if (objPtr->bytes == NULL) {
		dupPtr->bytes = NULL;
	} else if (objPtr->bytes != tclEmptyStringRep) {
		int len = objPtr->length;

		dupPtr->bytes = (char *) ckalloc((unsigned) len+1);
		if (len > 0) {
			memcpy((VOID *) dupPtr->bytes, (VOID *) objPtr->bytes,(unsigned) len);
		}
		dupPtr->bytes[len] = '\0';
		dupPtr->length = len;
	}
	if (typePtr != NULL) {
		typePtr->dupIntRepProc(objPtr, dupPtr);
	}
*/
/*	string = Tcl_GetStringFromObj(src,&len);
	Tcl_SetStringObj(dst,string,len);
*/
/*}*/

extern int ExtraL_MapCreateType(interp,key,setproc,getproc,unsetproc)
	Tcl_Interp *interp;
	char *key;
	ExtraL_MapTypeSetProc *setproc;
	ExtraL_MapTypeGetProc *getproc;
	ExtraL_MapTypeUnsetProc *unsetproc;
{
	Tcl_HashEntry *entry;
	struct Type *type;
	int new;

	entry = Tcl_CreateHashEntry(&typesTable,key,&new);
	if (new == 1) {
		type = (struct Type *)Tcl_Alloc(sizeof(struct Type));
		Tcl_SetHashValue(entry,(ClientData)type);
	} else {
		type = (struct Type *)Tcl_GetHashValue(entry);
	}
	type->setproc = setproc;
	type->getproc = getproc;
	type->unsetproc = unsetproc;
	return TCL_OK;
}

int ExtraL_MapsetValidate(interp,submap,data,ctag,clen,oldvalue,tagsc,tagsv,value,resultPtr) 
	Tcl_Interp *interp;
	Tcl_Obj *submap;
	Tcl_Obj *data;
	char *ctag;
	int clen;
	Tcl_Obj *oldvalue;
	int tagsc;
	Tcl_Obj **tagsv;
	Tcl_Obj *value;
	Tcl_Obj **resultPtr;
{
	Tcl_HashEntry *entry;
	struct Type *type;
	ExtraL_MapTypeSetProc *cmd;
	int error;
	
	entry = Tcl_FindHashEntry(&typesTable, ctag);
	if (entry != NULL) {
		type = (struct Type *)Tcl_GetHashValue(entry);
		*resultPtr = value;
		cmd = type->setproc;
		if (cmd!=NULL) {
			error = (*cmd)(interp,submap,data,oldvalue,tagsc,tagsv,resultPtr);
			if (error != TCL_OK) {return error;}
		}
		return TCL_OK;
	} else {
		Tcl_Obj *cmdObj;
		Tcl_Obj **listv;
		int listc;

		error = Tcl_ListObjGetElements(interp, submap, &listc, &listv);
		if (error != TCL_OK) {return error;}
		cmdObj = Tcl_NewStringObj("::Extral::set",13);
		Tcl_IncrRefCount(cmdObj);
		Tcl_AppendToObj(cmdObj,ctag+1,clen-1);
		error = Tcl_ListObjAppendElement(interp,cmdObj,submap);
		if (error != TCL_OK) {Tcl_DecrRefCount(cmdObj);return error;}
		if (data != NULL) {
			error = Tcl_ListObjAppendElement(interp,cmdObj,data);
		} else {
			error = Tcl_ListObjAppendElement(interp,cmdObj,Tcl_NewObj());
		}
		if (error != TCL_OK) {Tcl_DecrRefCount(cmdObj);return error;}
		if (oldvalue == NULL) {
			error = Tcl_ListObjAppendElement(interp,cmdObj,Tcl_NewObj());
		} else {
			error = Tcl_ListObjAppendElement(interp,cmdObj,oldvalue);
		}
		if (error != TCL_OK) {Tcl_DecrRefCount(cmdObj);return error;}
		error = Tcl_ListObjAppendElement(interp,cmdObj,Tcl_NewListObj(tagsc,tagsv));
		if (error != TCL_OK) {Tcl_DecrRefCount(cmdObj);return error;}
		error = Tcl_ListObjAppendElement(interp,cmdObj,value);
		if (error != TCL_OK) {Tcl_DecrRefCount(cmdObj);return error;}
		error = Tcl_EvalObj(interp,cmdObj);
		Tcl_DecrRefCount(cmdObj);
		if (error == 5) {
			return 5;
		} else if (error != TCL_OK) {
			return error;
		} else {
			*resultPtr = Tcl_GetObjResult(interp);
			return TCL_OK;
		}
	}
}

int ExtraL_MapunsetValidate(interp,submap,data,ctag,clen,oldvalue,tagsc,tagsv,resultPtr)
	Tcl_Interp *interp;
	Tcl_Obj *submap;
	Tcl_Obj *data;
	char *ctag;
	int clen;
	Tcl_Obj *oldvalue;
	int tagsc;
	Tcl_Obj **tagsv;
	Tcl_Obj **resultPtr;
{
	Tcl_HashEntry *entry;
	struct Type *type;
	ExtraL_MapTypeSetProc *cmd;
	int error;
	
	entry = Tcl_FindHashEntry(&typesTable, ctag);
	if (entry != NULL) {
		type = (struct Type *)Tcl_GetHashValue(entry);
		cmd = type->unsetproc;
		if (cmd!=NULL) {
			error = (*cmd)(interp,submap,data,oldvalue,tagsc,tagsv,resultPtr);
			if (error != TCL_OK) {return error;}
			return TCL_OK;
		} else {
			return 5;
		}
	}

	{
		Tcl_Obj *cmdObj;
		Tcl_Obj **listv;
		int listc;

		error = Tcl_ListObjGetElements(interp, submap, &listc, &listv);
		if (error != TCL_OK) {return error;}
		cmdObj = Tcl_NewStringObj("::Extral::unset",13);
		Tcl_IncrRefCount(cmdObj);
		Tcl_AppendToObj(cmdObj,ctag+1,clen-1);
		error = Tcl_ListObjAppendElement(interp,cmdObj,submap);
		if (error != TCL_OK) {Tcl_DecrRefCount(cmdObj);return error;}
		if (data != NULL) {
			error = Tcl_ListObjAppendElement(interp,cmdObj,data);
		} else {
			error = Tcl_ListObjAppendElement(interp,cmdObj,Tcl_NewObj());
		}
		if (error != TCL_OK) {Tcl_DecrRefCount(cmdObj);return error;}
		if (oldvalue == NULL) {
			error = Tcl_ListObjAppendElement(interp,cmdObj,Tcl_NewObj());
		} else {
			error = Tcl_ListObjAppendElement(interp,cmdObj,oldvalue);
		}
		if (error != TCL_OK) {Tcl_DecrRefCount(cmdObj);return error;}
		error = Tcl_ListObjAppendElement(interp,cmdObj,Tcl_NewListObj(tagsc,tagsv));
		if (error != TCL_OK) {Tcl_DecrRefCount(cmdObj);return error;}

		error = Tcl_EvalObj(interp,cmdObj);
		Tcl_DecrRefCount(cmdObj);
		if (error == 5) {
			return 5;
		} else if (error != TCL_OK) {
			return error;
		} else {
			*resultPtr = Tcl_GetObjResult(interp);
			return TCL_OK;
		}
	}
}

int ExtraL_MapgetValidate(interp,submap,data,ctag,clen,tagsc,tagsv,resultPtr) 
	Tcl_Interp *interp;
	Tcl_Obj *submap;
	Tcl_Obj *data;
	char *ctag;
	int clen;
	int tagsc;
	Tcl_Obj **tagsv;
	Tcl_Obj **resultPtr;
{
	Tcl_HashEntry *entry;
	struct Type *type;
	ExtraL_MapTypeGetProc *cmd;
	int error,i;
	
	entry = Tcl_FindHashEntry(&typesTable, ctag);
	if (entry != NULL) {
		type = (struct Type *)Tcl_GetHashValue(entry);
		cmd = type->getproc;
		if (cmd!=NULL) {
			error = (*cmd)(interp,submap,data,tagsc,tagsv,resultPtr);
			if (error != TCL_OK) {return error;}
		} else {
			int listlen;
			if (*resultPtr != NULL) {Tcl_GetStringFromObj(*resultPtr, &listlen);} else {listlen = 0;}
			if (listlen == 0) {
				error = Tcl_ListObjLength(interp, submap, &i);
				if (error != TCL_OK) {return error;}
				error = Tcl_ListObjIndex(interp, submap, i-1, resultPtr);
				if (error != TCL_OK) {return error;}
			}
			return TCL_OK;
		}
		return TCL_OK;
	}

	{
		Tcl_Obj *cmdObj;
		Tcl_Obj **listv;
		int listc;

		error = Tcl_ListObjGetElements(interp, submap, &listc, &listv);
		if (error != TCL_OK) {return error;}
	
		cmdObj = Tcl_NewStringObj("::Extral::get",13);
		Tcl_IncrRefCount(cmdObj);
		Tcl_AppendToObj(cmdObj,ctag+1,clen-1);
		error = Tcl_ListObjAppendElement(interp,cmdObj,submap);
		if (error != TCL_OK) {Tcl_DecrRefCount(cmdObj);return error;}
		if (data != NULL) {
			error = Tcl_ListObjAppendElement(interp,cmdObj,data);
		} else {
			error = Tcl_ListObjAppendElement(interp,cmdObj,Tcl_NewObj());
		}
		if (error != TCL_OK) {Tcl_DecrRefCount(cmdObj);return error;}
		error = Tcl_ListObjAppendElement(interp,cmdObj,Tcl_NewListObj(tagsc,tagsv));
		if (error != TCL_OK) {Tcl_DecrRefCount(cmdObj);return error;}
		if (*resultPtr != NULL) {
			error = Tcl_ListObjAppendElement(interp,cmdObj,*resultPtr);
		} else {
			error = Tcl_ListObjAppendElement(interp,cmdObj,Tcl_NewObj());
		}
		if (error != TCL_OK) {Tcl_DecrRefCount(cmdObj);return error;}
		error = Tcl_EvalObj(interp,cmdObj);
		Tcl_DecrRefCount(cmdObj);
		if (error != TCL_OK) {return error;}
		*resultPtr = Tcl_GetObjResult(interp);
		return TCL_OK;
	}
}

int ExtraL_ObjEqual(obj1, obj2)
	Tcl_Obj *obj1;
	Tcl_Obj *obj2;
{
	char *obj1string, *obj2string;
	int obj1len, obj2len;
	if ((obj1==NULL)||(obj2==NULL)) {return 0;}
	obj1string=Tcl_GetStringFromObj(obj1,&obj1len);
	obj2string=Tcl_GetStringFromObj(obj2,&obj2len);
	if ((obj1len == obj2len)&&(memcmp(obj1string,obj2string,obj1len)==0)) {
		return 1;
	} else {
		return 0;
	}
}

int ExtraL_MapFindTag(interp, list, tag, taglen, resultPtr, posPtr)
	Tcl_Interp *interp;
	Tcl_Obj *list;
	char *tag;
	int taglen;
	Tcl_Obj **resultPtr;
	int *posPtr;
{
	Tcl_Obj **listv, *subtag;
	int listc;
	char *ctag;
	int clen, pos, i, error;

	if (list == NULL) {
		*posPtr = -1;
		*resultPtr = NULL;
		return TCL_OK;
	}

	if (Tcl_ListObjGetElements(interp, list, &listc, &listv) != TCL_OK) {
		return TCL_ERROR;
	}
	if ((listc != 0)&&(listc & 1)) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"error: \"", Tcl_GetStringFromObj(list,&pos),"\" does not have an even number of elements",(char *)NULL);
		return TCL_ERROR;
	}
	if (listc == 0) {
		*posPtr = -1;
		*resultPtr = NULL;
		return TCL_OK;
	}
	for(pos=0;pos<listc;pos+=2) {
		error = Tcl_ListObjIndex(interp, listv[pos], 0, &subtag);
		if (error != TCL_OK) {return error;}
		if (subtag == NULL) {
			ctag = "";
			clen = 0;
		} else {
			ctag = Tcl_GetStringFromObj(subtag,&clen);
		}
		if ((clen==1)&&(ctag[0]=='?')) {
			for (i=1; i<=2; i++) {
				error = Tcl_ListObjIndex(interp, listv[pos], i, &subtag);
				if (error != TCL_OK) {return error;}
				if (subtag == NULL) {
					ctag = "";
					clen = 0;
				} else {
					ctag = Tcl_GetStringFromObj(subtag,&clen);
				}
				if ((clen==taglen)&&(memcmp(ctag,tag,taglen)==0)) {
					pos++;
					*posPtr = pos;
					*resultPtr = listv[pos];
					return TCL_OK;
				}
			}
		} else {
			ctag = Tcl_GetStringFromObj(listv[pos],&clen);
			if ((clen==taglen)&&(memcmp(ctag,tag,taglen)==0)) {
				pos++;
				*posPtr = pos;
				*resultPtr = listv[pos];
				return TCL_OK;
			}
		}
	}
	ctag=Tcl_GetStringFromObj(listv[0],&clen);
	*posPtr = -1;
	*resultPtr = NULL;
	return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 *		C backend for map_set with struct
 *	 list gets changed directly, so should not be shared
 *
 *----------------------------------------------------------------------
 */

extern int ExtraL_MapsetStruct(interp, map, data, list, tagsc, tagsv, value, resultPtr)
	Tcl_Interp *interp;
	Tcl_Obj *map;
	Tcl_Obj *data;
	Tcl_Obj *list;
	int tagsc;
	Tcl_Obj **tagsv;
	Tcl_Obj *value;
	Tcl_Obj **resultPtr;
{
	Tcl_Obj *temp, *tagObj,*result,*res;
	char *ctag = NULL,*tag;
	Tcl_Obj *submap, *sublist, *structtag, *subtag;
	int sublistpos, structpos;
	int clen,len;
	int error;
	int pos;

	result = NULL;
	error = Tcl_ListObjIndex(interp, map, 0, &temp);
	if (error != TCL_OK) {return error;}
	if (temp != NULL) {
		ctag = Tcl_GetStringFromObj(temp,&clen);
	} else {
		clen = 0;
	}
	if ((clen>1)&&(ctag[0]=='*')&&(ctag[1]!=' ')) {
		/* endnode */
		error = ExtraL_MapsetValidate(interp,map,data,ctag,clen,list,tagsc,tagsv,value,&res);
		if (error != TCL_OK) {return error;}
		*resultPtr = res;
		return TCL_OK;
	} else if (tagsc == 0) {
		/*
		# Go further down map by value
		# ----------------------------------
		*/
		int tempc;
		Tcl_Obj **tempv;
		if (Tcl_ListObjGetElements(interp, value, &tempc, &tempv) != TCL_OK) {
			return TCL_ERROR;
		}
		if (tempc & 1) {
			Tcl_ResetResult(interp);
			Tcl_AppendResult(interp,"error: incorrect value trying to assign \"", Tcl_GetStringFromObj(value,&len),"\" to map \"", Tcl_GetStringFromObj(map,&len),"\"",(char *)NULL);
			return TCL_ERROR;
		} else if (tempc!=0) {
			if (list == NULL) {
				result = Tcl_NewObj();
			} else {
				result = Tcl_DuplicateObj(list);
			}
			for(pos=0;pos<tempc;pos+=2) {
				tagObj = tempv[pos];
				tag = Tcl_GetStringFromObj(tagObj,&len);
				/* check map if needed */
				error = ExtraL_MapFindTag(interp, map, tag, len, &submap, &structpos);
				if (error != TCL_OK) {Tcl_DecrRefCount(result);return TCL_ERROR;}
				if (structpos == -1) {
					Tcl_ResetResult(interp);
					Tcl_AppendResult(interp,"error: tag \"", tag, "\" not present in map \"", Tcl_GetStringFromObj(map,&len),"\"",(char *)NULL);
					Tcl_DecrRefCount(result);
					return TCL_ERROR;	
				}
			
				/* try to find the next tag */
				error = Tcl_ListObjIndex(interp, map, structpos-1, &structtag);
				if (error != TCL_OK) {Tcl_DecrRefCount(result);return error;}
				error = Tcl_ListObjIndex(interp, structtag, 0, &subtag);
				if (error != TCL_OK) {Tcl_DecrRefCount(result);return error;}
				ctag = Tcl_GetStringFromObj(subtag,&clen);
				if ((clen==1)&&(ctag[0]=='?')) {
					error = Tcl_ListObjIndex(interp, structtag, 2, &tagObj);
					if (error != TCL_OK) {Tcl_DecrRefCount(result);return error;}
					if (tagObj == NULL) {tagObj = Tcl_NewObj();}
					tag = Tcl_GetStringFromObj(tagObj,&len);
				}
				error = ExtraL_MapFindTag(interp, result, tag, len, &sublist, &sublistpos);
				if (error != TCL_OK) {Tcl_DecrRefCount(result);return TCL_ERROR;}
		
				error = ExtraL_MapsetStruct(interp, submap, data, sublist, 0, NULL, tempv[pos+1], &res);
				if (error == TCL_ERROR) {
					Tcl_AppendResult(interp," at field \"",tag ,"\"",(char *) NULL);
					Tcl_DecrRefCount(result);return error;
				} else if (error == 5) {
					if (sublistpos != -1) {
						error = Tcl_ListObjLength(interp,result,&len);
						if (error != TCL_OK) {Tcl_DecrRefCount(result);return error;}
						if (len == 2) {
							Tcl_DecrRefCount(result);
							result = NULL; 
						} else {
							error = Tcl_ListObjReplace(interp,result,sublistpos-1,2,0,NULL);
							if (error != TCL_OK) {Tcl_DecrRefCount(result);return error;}
						}
					}
				} else {
					if (sublistpos != -1) {
						error = Tcl_ListObjReplace(interp,result,sublistpos,1,1,&res);
						if (error != TCL_OK) {Tcl_DecrRefCount(result);return error;}
					} else {
						error = Tcl_ListObjAppendElement(interp,result,tagObj);
						if (error != TCL_OK) {Tcl_DecrRefCount(result);return error;}
						error = Tcl_ListObjAppendElement(interp,result,res);
						if (error != TCL_OK) {Tcl_DecrRefCount(result);return error;}
					}
				}
			}
		}
	} else {
		/*
		# Go further down map by tags
		# ---------------------------------
		*/
		tagObj = tagsv[0];
		tag = Tcl_GetStringFromObj(tagsv[0],&len);
		tagsc--;
		tagsv++;
		/* check map if needed */
		error = ExtraL_MapFindTag(interp, map, tag, len, &submap, &structpos);
		if (error != TCL_OK) {return TCL_ERROR;}
		if (structpos == -1) {
			Tcl_ResetResult(interp);
			Tcl_AppendResult(interp,"error: tag \"", tag, "\" not present in map \"", Tcl_GetStringFromObj(map,&len),"\"",(char *)NULL);
			return TCL_ERROR;	
		}
	
		/* try to find the next tag */
		error = Tcl_ListObjIndex(interp, map, structpos-1, &structtag);
		if (error != TCL_OK) {return error;}
		error = Tcl_ListObjIndex(interp, structtag, 0, &subtag);
		if (error != TCL_OK) {return error;}
		ctag = Tcl_GetStringFromObj(subtag,&clen);
		if ((clen==1)&&(ctag[0]=='?')) {
			error = Tcl_ListObjIndex(interp, structtag, 2, &tagObj);
			if (error != TCL_OK) {return error;}
			if (tagObj == NULL) {tagObj = Tcl_NewObj();}
			tag = Tcl_GetStringFromObj(tagObj,&len);
		}
		error = ExtraL_MapFindTag(interp, list, tag, len, &sublist, &sublistpos);
		if (error != TCL_OK) {return TCL_ERROR;}

		error = ExtraL_MapsetStruct(interp, submap, data, sublist, tagsc, tagsv, value, &res);
		if (error == TCL_ERROR) {
			Tcl_AppendResult(interp," at field \"",tag ,"\"",(char *) NULL);
			return error;
		} else if (error == 5) {
			sublist = res;
			if (sublistpos != -1) {
				error = Tcl_ListObjLength(interp,list,&len);
				if (error != TCL_OK) {return error;}
				if (len == 2) {
					result = NULL; 
				} else {
					result = Tcl_DuplicateObj(list);
					error = Tcl_ListObjReplace(interp,result,sublistpos-1,2,0,NULL);
					if (error != TCL_OK) {Tcl_DecrRefCount(result);return error;}
				}
			}
		} else {
			if (list == NULL) {
				result = Tcl_NewObj();
			} else {
				result = Tcl_DuplicateObj(list);
			}
			if (sublistpos != -1) {
				error = Tcl_ListObjReplace(interp,result,sublistpos,1,1,&res);
				if (error != TCL_OK) {
					Tcl_DecrRefCount(result);
					return error;
				}
			} else {
				error = Tcl_ListObjAppendElement(interp,result,tagObj);
				if (error != TCL_OK) {
					Tcl_DecrRefCount(result);
					return error;
				}
				error = Tcl_ListObjAppendElement(interp,result,res);
				if (error != TCL_OK) {
					Tcl_DecrRefCount(result);
					return error;
				}
			}
		}
	}
	if (result == NULL) {
		return 5;
	} else {
		*resultPtr = result;
		return TCL_OK;
	}
}

/*
 *----------------------------------------------------------------------
 *
 *		C backend for map_set
 *	 list gets changed directly, so should not be shared
 *
 *----------------------------------------------------------------------
 */

extern int ExtraL_Mapset(interp, list, tagsc, tagsv, value, resultPtr)
	Tcl_Interp *interp;
	Tcl_Obj *list;
	int tagsc;
	Tcl_Obj **tagsv;
	Tcl_Obj *value;
	Tcl_Obj **resultPtr;
{
	Tcl_Obj *res,*result;
	char *tag;
	Tcl_Obj *sublist;
	int sublistpos;
	int len,i;
	int error;

	tag = Tcl_GetStringFromObj(tagsv[0],&len);

	/* try to find the next tag */
	error = ExtraL_MapFindTag(interp, list, tag, len, &sublist, &sublistpos);
	if (error != TCL_OK) {return TCL_ERROR;}

	*resultPtr = NULL;
	result = Tcl_DuplicateObj(list);
	/* change or ad the element */
	if (sublistpos != -1) {
		if (tagsc != 1) {
			error = ExtraL_Mapset(interp, sublist, tagsc-1, tagsv+1, value, &res);
			if (error != TCL_OK) {Tcl_DecrRefCount(result);return error;}
			error = Tcl_ListObjReplace(interp,result,sublistpos,1,1,&res);
			if (error != TCL_OK) {Tcl_DecrRefCount(result);Tcl_DecrRefCount(res);return error;}
		} else {
			error = Tcl_ListObjReplace(interp,result,sublistpos,1,1,&value);
			if (error != TCL_OK) {Tcl_DecrRefCount(result);return error;}
		}
	} else if (tagsc == 1) {
		error = Tcl_ListObjAppendElement(interp,result,tagsv[0]);
		if (error != TCL_OK) {Tcl_DecrRefCount(result);return error;}
		error = Tcl_ListObjAppendElement(interp,result,value);
		if (error != TCL_OK) {Tcl_DecrRefCount(result);return error;}
	} else {
		res = Tcl_NewObj();
		error = Tcl_ListObjAppendElement(interp, res, tagsv[tagsc-1]);
		error = Tcl_ListObjAppendElement(interp, res, value);
		if (error != TCL_OK) {Tcl_DecrRefCount(result);Tcl_DecrRefCount(res);return error;}

		i = tagsc-2;
		while (1) {
			if (i==0) break;
			sublist = res;
			res = Tcl_NewObj();
			error = Tcl_ListObjAppendElement(interp, res, tagsv[i]);
			error = Tcl_ListObjAppendElement(interp, res, sublist);
			if (error != TCL_OK) {Tcl_DecrRefCount(result);Tcl_DecrRefCount(res);Tcl_DecrRefCount(sublist);return error;}
			i--;
		}

		error = Tcl_ListObjAppendElement(interp,result,tagsv[0]);
		if (error != TCL_OK) {Tcl_DecrRefCount(result);Tcl_DecrRefCount(res);return error;}
		error = Tcl_ListObjAppendElement(interp,result,res);
		if (error != TCL_OK) {Tcl_DecrRefCount(result);Tcl_DecrRefCount(res);return error;}
	}
	*resultPtr = result;
	return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 *		C backend for map_unset with struct
 *	 list gets changed directly, so should not be shared
 *
 *----------------------------------------------------------------------
 */

extern int ExtraL_MapunsetStruct(interp, map, data, list, tagsc, tagsv, resultPtr)
	Tcl_Interp *interp;
	Tcl_Obj *map;
	Tcl_Obj *data;
	Tcl_Obj *list;
	int tagsc;
	Tcl_Obj **tagsv;
	Tcl_Obj **resultPtr;
{
	Tcl_Obj *temp, *tagObj,*result,*res;
	char *ctag = NULL,*tag;
	Tcl_Obj *submap, *sublist, *structtag, *subtag;
	int sublistpos, structpos;
	int clen,len;
	int error;

	result = NULL;
	error = Tcl_ListObjIndex(interp, map, 0, &temp);
	if (error != TCL_OK) {return error;}
	if (temp != NULL) {
		ctag = Tcl_GetStringFromObj(temp,&clen);
	} else {
		clen = 0;
	}
	if ((clen>1)&&(ctag[0]=='*')&&(ctag[1]!=' ')) {
		/* endnode */
		error = ExtraL_MapunsetValidate(interp,map,data,ctag,clen,list,tagsc,tagsv,&res);
		if (error != TCL_OK) {return error;}
		*resultPtr = res;
		return TCL_OK;
	} else if (tagsc == 0) {
		*resultPtr = NULL;
		return 5;
	} else {
		/*
		# Go further down map by tags
		# ---------------------------------
		*/
		tagObj = tagsv[0];
		tag = Tcl_GetStringFromObj(tagsv[0],&len);
		tagsc--;
		tagsv++;
		/* check map if needed */
		error = ExtraL_MapFindTag(interp, map, tag, len, &submap, &structpos);
		if (error != TCL_OK) {return TCL_ERROR;}
		if (structpos == -1) {
			Tcl_ResetResult(interp);
			Tcl_AppendResult(interp,"error: tag \"", tag, "\" not present in map \"", Tcl_GetStringFromObj(map,&len),"\"",(char *)NULL);
			return TCL_ERROR;	
		}
	
		/* try to find the next tag */
		error = Tcl_ListObjIndex(interp, map, structpos-1, &structtag);
		if (error != TCL_OK) {return error;}
		error = Tcl_ListObjIndex(interp, structtag, 0, &subtag);
		if (error != TCL_OK) {return error;}
		ctag = Tcl_GetStringFromObj(subtag,&clen);
		if ((clen==1)&&(ctag[0]=='?')) {
			error = Tcl_ListObjIndex(interp, structtag, 2, &tagObj);
			if (error != TCL_OK) {return error;}
			if (tagObj == NULL) {tagObj = Tcl_NewObj();}
			tag = Tcl_GetStringFromObj(tagObj,&len);
		}
		error = ExtraL_MapFindTag(interp, list, tag, len, &sublist, &sublistpos);
		if (error != TCL_OK) {return TCL_ERROR;}
		if (sublistpos == -1) {
			sublist = NULL;
		}

		error = ExtraL_MapunsetStruct(interp, submap, data, sublist, tagsc, tagsv, &res);
		if (error == TCL_ERROR) {
			Tcl_AppendResult(interp," at field \"",tag ,"\"",(char *) NULL);
			return error;
		} else if (error == 5) {
			sublist=temp;
			if (sublistpos != -1) {
				error = Tcl_ListObjLength(interp,list,&len);
				if (error != TCL_OK) {return error;}
				if (len == 2) {
					result = NULL; 
				} else {
					result = Tcl_DuplicateObj(list);
					error = Tcl_ListObjReplace(interp,result,sublistpos-1,2,0,NULL);
					if (error != TCL_OK) {Tcl_DecrRefCount(result);return error;}
				}
			}
		} else {
			if (list == NULL) {
				result = Tcl_NewObj();
			} else {
				result = Tcl_DuplicateObj(list);
			}
			if (sublistpos != -1) {
				error = Tcl_ListObjReplace(interp,result,sublistpos,1,1,&res);
				if (error != TCL_OK) {
					Tcl_DecrRefCount(result);
					return error;
				}
			} else {
				error = Tcl_ListObjAppendElement(interp,result,tagObj);
				if (error != TCL_OK) {
					Tcl_DecrRefCount(result);
					return error;
				}
				error = Tcl_ListObjAppendElement(interp,result,res);
				if (error != TCL_OK) {
					Tcl_DecrRefCount(result);
					return error;
				}
			}
		}
	}
	if (result == NULL) {
		return 5;
	} else {
		*resultPtr = result;
		return TCL_OK;
	}
}

/*
 *----------------------------------------------------------------------
 *
 *		C backend for map_unset without struct
 *	 list gets changed directly, so should not be shared
 *
 *----------------------------------------------------------------------
 */

extern int ExtraL_Mapunsetnostruct(interp, list, tagsc, tagsv)
	Tcl_Interp *interp;
	Tcl_Obj *list;
	int tagsc;
	Tcl_Obj **tagsv;
{
	int workc;
	Tcl_Obj **workv;
	Tcl_Obj *temp;
	char *ctag,*tag;
	int clen,len;
	int result;
	int pos;

	if (Tcl_ListObjGetElements(interp, list, &workc, &workv) != TCL_OK) {
		return TCL_ERROR;
	}
	if ((workc != 0)&&(workc & 1)) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"error: list \"", Tcl_GetStringFromObj(list,&len),"\" does not have an even number of elements",(char *)NULL);
		return TCL_ERROR;
	}
	tag = Tcl_GetStringFromObj(tagsv[0],&len);
	for(pos = 0;pos < workc;pos += 2) {
		ctag = Tcl_GetStringFromObj(workv[pos],&clen);
		if (clen == len) {
			if (memcmp(ctag,tag,len)==0) {
				if (tagsc == 1) {
					result = Tcl_ListObjReplace(interp,list,pos,2,0,NULL);
					if (result != TCL_OK) {
						return result;
					}
					break;
				} else {
					pos++;
					temp = Tcl_DuplicateObj(workv[pos]);
					result = ExtraL_Mapunsetnostruct(interp, temp, tagsc-1, tagsv+1);
					if (result != TCL_OK) {
						Tcl_DecrRefCount(temp);return result;
					}
					result = Tcl_ListObjReplace(interp,list,pos,1,1,&temp);
					if (result != TCL_OK) {
						Tcl_DecrRefCount(temp);return result;
					}
					break;
				}
			}
		}
	}
	return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 *		C backend for map_get with struct
 *
 *----------------------------------------------------------------------
 */

extern int ExtraL_MapgetStruct(interp, map, data, list, tagsc, tagsv, resultPtr)
	Tcl_Interp *interp;
	Tcl_Obj *map;
	Tcl_Obj *data;
	Tcl_Obj *list;
	int tagsc;
	Tcl_Obj **tagsv;
	Tcl_Obj **resultPtr;
{
	Tcl_Obj *temp, *submap, *sublist, *res;
	char *ctag,*tag;
	int clen,len;
	int error;
	int pos;

/*
printf("struct: %s\n",Tcl_GetStringFromObj(map,&error));
if (list != NULL) {printf("list: %s\n",Tcl_GetStringFromObj(list,&error));}
if (tagsc != 0) {printf("tags: %d\ntag: %s\n",tagsc,Tcl_GetStringFromObj(tagsv[0],&error));}
printf("\n");
fflush(stdout);
*/
	Tcl_ListObjIndex(interp, map, 0, &temp);
	if (temp == NULL) {
		ctag="";
		clen=0;
	} else {
		ctag = Tcl_GetStringFromObj(temp,&clen);
	}
	/* 
	# Is this an endnode
	# ------------------
	*/
	if ((clen>1)&&(ctag[0]=='*')&&(ctag[1]!=' ')) {
		if (tagsc>0) {
			error = ExtraL_MapgetValidate(interp,map,data,ctag,clen,tagsc,tagsv,&list);
			if (error != TCL_OK) {return TCL_ERROR;}
			*resultPtr = list;
			return TCL_OK;
		} else {
			error = ExtraL_MapgetValidate(interp,map,data,ctag,clen,0,NULL,&list);
			if (error != TCL_OK) {return TCL_ERROR;}
			*resultPtr = list;
			return TCL_OK;
		}
	}

	/* 
	# out of tags
	# -----------
	*/
	if (tagsc == 0) {
		Tcl_Obj **tempv;
		int tempc;
		Tcl_Obj *result, *subtag;
		int i;

		error = Tcl_ListObjGetElements(interp, map, &tempc, &tempv);
		if (error != TCL_OK) {return error;}
		if (tempc & 1) {
			Tcl_ResetResult(interp);
			Tcl_AppendResult(interp,"error: map \"", Tcl_GetStringFromObj(map,&len),"\" does not have an even number of elements",(char *)NULL);
			return TCL_ERROR;
		} else if (tempc != 0) {
			result = Tcl_NewObj();
			for(pos=0;pos<tempc;pos+=2) {
				error = Tcl_ListObjIndex(interp, tempv[pos], 0, &subtag);
				if (error != TCL_OK) {Tcl_DecrRefCount(result);return error;}
				ctag = Tcl_GetStringFromObj(subtag,&clen);
				if ((clen==1)&&(ctag[0]=='?')) {
					error = Tcl_ListObjIndex(interp, tempv[pos], 1, &subtag);
					if (error != TCL_OK) {Tcl_DecrRefCount(result);return error;}
					if (subtag == NULL) {subtag = Tcl_NewObj();}
					error = Tcl_ListObjAppendElement(interp,result,subtag);
					if (error != TCL_OK) {Tcl_DecrRefCount(result);return error;}
					error = Tcl_ListObjIndex(interp, tempv[pos], 2, &subtag);
					if (error != TCL_OK) {Tcl_DecrRefCount(result);return error;}
					if (subtag == NULL) {
						ctag = "";
						clen = 0;
					} else {
						ctag = Tcl_GetStringFromObj(subtag,&clen);
					}
					error = ExtraL_MapFindTag(interp,list,ctag,clen,&sublist,&i);
					if (error != TCL_OK) {Tcl_DecrRefCount(result);return error;}
					error = ExtraL_MapgetStruct(interp, tempv[pos+1], data, sublist, 0, NULL, &res);
					if (error != TCL_OK) {Tcl_DecrRefCount(result);return error;}
					error = Tcl_ListObjAppendElement(interp,result,res);
					if (error != TCL_OK) {Tcl_DecrRefCount(result);return error;}
				} else {
					ctag = Tcl_GetStringFromObj(tempv[pos],&clen);
					error = Tcl_ListObjAppendElement(interp,result,tempv[pos]);
					if (error != TCL_OK) {Tcl_DecrRefCount(result);return error;}
					error = ExtraL_MapFindTag(interp,list,ctag,clen,&sublist,&i);
					if (error != TCL_OK) {Tcl_DecrRefCount(result);return error;}
					error = ExtraL_MapgetStruct(interp, tempv[pos+1], data, sublist, 0, NULL, &res);
					if (error != TCL_OK) {Tcl_DecrRefCount(result);return error;}
					error = Tcl_ListObjAppendElement(interp,result,res);
					if (error != TCL_OK) {Tcl_DecrRefCount(result);return error;}
				}
			}
			*resultPtr = result;
			return TCL_OK;
		} else {
			*resultPtr = list;
			return TCL_OK;
		}
	} else {
		Tcl_Obj *structtag, *subtag;
		/* 
		# find submap corresponding to tag 
		# --------------------------------------
		*/

		tag = Tcl_GetStringFromObj(tagsv[0],&len);
		error = ExtraL_MapFindTag(interp,map,tag,len,&submap,&pos);
		if (error != TCL_OK) {return error;}
		if (pos == -1) {
			Tcl_ResetResult(interp);
			Tcl_AppendResult(interp,"error: tag \"", tag, "\" not present in map \"", Tcl_GetStringFromObj(map,&len),"\"",(char *)NULL);
			return TCL_ERROR;	
		}
		error = Tcl_ListObjIndex(interp, map, pos-1, &structtag);
		if (error != TCL_OK) {return error;}
		error = Tcl_ListObjIndex(interp, structtag, 0, &subtag);
		if (error != TCL_OK) {return error;}
		ctag = Tcl_GetStringFromObj(subtag,&clen);
		if ((clen==1)&&(ctag[0]=='?')) {
			error = Tcl_ListObjIndex(interp, structtag, 2, &subtag);
			if (error != TCL_OK) {return error;}
			if (subtag == NULL) {subtag = Tcl_NewObj();}
			tag = Tcl_GetStringFromObj(subtag,&len);
		}
	
		/* 
			find the tag
			------------
		*/
		error = ExtraL_MapFindTag(interp,list,tag,len,&sublist,&pos);
		if (error != TCL_OK) {return error;}
	
		/* set the result */
		error = ExtraL_MapgetStruct(interp, submap, data, sublist, tagsc-1, tagsv+1, &res);
		if (error != TCL_OK) {return error;}
		*resultPtr = res;
		return TCL_OK;
	}
}
/*
 *----------------------------------------------------------------------
 *
 *		C backend for map_get
 *
 *----------------------------------------------------------------------
 */

extern int ExtraL_Mapget(interp, list, tags, resultPtr)
	Tcl_Interp *interp;
	Tcl_Obj *list;
	Tcl_Obj *tags;
	Tcl_Obj **resultPtr;
{
	int listc;
	Tcl_Obj **listv,*result;
	int tagsc;
	Tcl_Obj **tagsv;
	char *ctag,*tag;
	int clen,len,curtag;
	int pos;

	if (Tcl_ListObjGetElements(interp, tags, &tagsc, &tagsv) != TCL_OK) {
		return TCL_ERROR;
	}
	result = list;
	for(curtag=0;curtag<tagsc;curtag++) {
		if (Tcl_ListObjGetElements(interp, result, &listc, &listv) != TCL_OK) {
			return TCL_ERROR;
		}
		if ((listc != 0)&&(listc & 1)) {
			Tcl_ResetResult(interp);
			Tcl_AppendResult(interp,"error: list \"", Tcl_GetStringFromObj(result,&len),"\" does not have an even number of elements",(char *)NULL);
			return TCL_ERROR;
		}
		tag = Tcl_GetStringFromObj(tagsv[curtag],&len);
		for(pos = 0; pos < listc; pos += 2) {
			ctag=Tcl_GetStringFromObj(listv[pos],&clen);
			if (clen == len) {
				if (memcmp(ctag,tag,len) == 0) {
					result = listv[++pos];
					break;
				}
			}
		}
		if (pos == listc) {
			Tcl_ResetResult(interp);
			Tcl_AppendResult(interp,"tag \"", tag,"\" not found",(char *)NULL);
			return TCL_ERROR;
		}
	}
	*resultPtr = result;
	return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * ExtraL_MapsetObjCmd --
 *
 *		This procedure is invoked to process the "map_set" command.
 *
 * Results:
 *		A standard Tcl result.
 *
 *
 *----------------------------------------------------------------------
 */

int ExtraL_MapsetObjCmd(notUsed, interp, objc, objv)
	ClientData notUsed;				 /* Not used. */
	Tcl_Interp *interp;					/* Current interpreter. */
	int objc;						/* Number of arguments. */
	Tcl_Obj *CONST objv[];	/* Argument objects. */
{
	Tcl_Obj *current, *res;
	Tcl_Obj **tagsv;
	int tagsc;
	Tcl_Obj *map, *data;
	char *string;
	int pos, error, i;

	if (objc < 3) {
		Tcl_WrongNumArgs(interp, 1, objv, "?-map schema? ?-data clientdata? list field value ?field value ...?");
		return TCL_ERROR;
	}
	map = NULL;
	data = NULL;
	pos = 1;
	while(pos < objc) {
		string = Tcl_GetStringFromObj(objv[pos], &i);
		if ((i==4)&&(strncmp(string,"-map",4) == 0)) {
			map = objv[pos+1];
			pos += 2;
		} else if ((i==5)&&(strncmp(string,"-data",5) == 0)) {
			data = objv[pos+1];
			pos += 2;
		} else {
			break;
		}
	}

	if ((objc < (pos+3))||(objc & 1)) {
		Tcl_WrongNumArgs(interp, 1, objv, "?-map schema? ?-data clientdata? list field value ?field value ...?");
		return TCL_ERROR;
	}

	current = objv[pos];
	Tcl_IncrRefCount(current);
	for(i = pos+1 ; i < objc ; i+=2) {
		error = Tcl_ListObjGetElements(interp, objv[i], &tagsc, &tagsv);
		if (error != TCL_OK)	{Tcl_DecrRefCount(current);return error;}
		if (map == NULL) {
			if (tagsc == 0) {
				Tcl_DecrRefCount(current);
				current = objv[i+1];
				Tcl_IncrRefCount(current);
			} else {
				error = ExtraL_Mapset(interp, current, tagsc, tagsv, objv[i+1],&res);
				Tcl_DecrRefCount(current);
				if (error != TCL_OK)	{return error;}
				current = res;
			}
		} else {
			error = ExtraL_MapsetStruct(interp, map, data, current, tagsc, tagsv, objv[i+1],&res);
			Tcl_DecrRefCount(current);
			if (error == TCL_ERROR)	{
				return error;
			} else if (error == 5) {
				current = Tcl_NewObj();
			} else {
				current = res;
			}
		}
	}
	Tcl_SetObjResult(interp,current);
	return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * ExtraL_MapunsetCmd --
 *
 *		This procedure is invoked to process the "map_unset" command.
 *
 * Results:
 *		A standard Tcl result.
 *
 *
 *----------------------------------------------------------------------
 */

int ExtraL_MapunsetObjCmd(notUsed, interp, objc, objv)
	ClientData notUsed;				 /* Not used. */
	Tcl_Interp *interp;					/* Current interpreter. */
	int objc;						/* Number of arguments. */
	Tcl_Obj *CONST objv[];	/* Argument objects. */
{
	Tcl_Obj *current,*res;
	Tcl_Obj **tagsv;
	int tagsc;
	Tcl_Obj *map, *data;
	char *string;
	int pos, error, i;

	if (objc < 2) {
		Tcl_WrongNumArgs(interp, 1, objv, "?-map schema? ?-data clientdata? list field ?field ...?");
		return TCL_ERROR;
	}
	map = NULL;
	data = NULL;
	pos = 1;
	while(pos < objc) {
		string = Tcl_GetStringFromObj(objv[pos], &i);
		if ((i==4)&&(strncmp(string,"-map",4) == 0)) {
			map = objv[pos+1];
			pos += 2;
		} else if ((i==5)&&(strncmp(string,"-data",5) == 0)) {
			data = objv[pos+1];
			pos += 2;
		} else {
			break;
		}
	}

	if ((objc-pos) < 2) {
		Tcl_WrongNumArgs(interp, 1, objv, "?-map schema? ?-data clientdata? list field ?field ...?");
		return TCL_ERROR;
	}
	if (map == NULL) {
		current = Tcl_DuplicateObj(objv[pos]);
		for(i = pos+1 ; i < objc ; i++) {
			error = Tcl_ListObjGetElements(interp, objv[i], &tagsc, &tagsv);
			if (error != TCL_OK)	{Tcl_DecrRefCount(current);return error;}
			if (tagsc == 0) {
				Tcl_SetListObj(current,1,objv+i+1);
			} else {
				error = ExtraL_Mapunsetnostruct(interp, current, tagsc, tagsv);
				if (error != TCL_OK)	{Tcl_DecrRefCount(current);return error;}
			}
		}
	} else {
		current = objv[pos];
		Tcl_IncrRefCount(current);
		for(i = pos+1 ; i < objc ; i++) {
			error = Tcl_ListObjGetElements(interp, objv[i], &tagsc, &tagsv);
			if (error != TCL_OK)	{return error;}
			error = ExtraL_MapunsetStruct(interp, map, data, current, tagsc, tagsv, &res);
			Tcl_DecrRefCount(current);
			if (error == TCL_ERROR)	{
				return error;
			} else if (error == 5) {
				current = Tcl_NewObj();
			} else {
				current = res;
			}
		}
	}
	Tcl_SetObjResult(interp,current);
	return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * ExtraL_MapgetCmd --
 *
 *		This procedure is invoked to process the "map_get" command.
 *
 * Results:
 *		A standard Tcl result.
 *
 *
 *----------------------------------------------------------------------
 */

int ExtraL_MapgetObjCmd(notUsed, interp, objc, objv)
	ClientData notUsed;
	Tcl_Interp *interp;
	int objc;
	Tcl_Obj *CONST objv[];
{
	Tcl_Obj **tagsv;
	int tagsc;
	Tcl_Obj *result;
	Tcl_Obj *map, *data;
	char *string;
	int i, error;

	if (objc < 2) {
		Tcl_WrongNumArgs(interp, 1, objv, "?-map schema? ?-data clientdata? list field ?field ...?");
		return TCL_ERROR;
	}
	map = NULL;
	data = NULL;
	objc -= 1;
	objv += 1;
	while(objc > 0) {
		string = Tcl_GetStringFromObj(objv[0], &i);
		if ((i==4)&&(strncmp(string,"-map",4) == 0)) {
			map = objv[1];
			objc -= 2;
			objv += 2;
		} else if ((i==5)&&(strncmp(string,"-data",5) == 0)) {
			data = objv[1];
			objc -= 2;
			objv += 2;
		} else {
			break;
		}
	}
	if (objc < 2) {
		Tcl_WrongNumArgs(interp, 1, objv, "?-map schema? ?-data clientdata? list field ?field ...?");
		return TCL_ERROR;
	}
	if (objc == 2) {
		if (map != NULL) {
			error = Tcl_ListObjGetElements(interp, objv[1], &tagsc, &tagsv);
			if (error != TCL_OK) {return TCL_ERROR;}
			error = ExtraL_MapgetStruct(interp, map, data, objv[0], tagsc, tagsv, &result);
		} else {
			error = ExtraL_Mapget(interp, objv[0], objv[1], &result);
		}
		if (error != TCL_OK) {return TCL_ERROR;}
	} else {
		Tcl_Obj *res;
		result = Tcl_NewObj();
		if (map != NULL) {
			for(i=1;i<objc;i++) {
				error = Tcl_ListObjGetElements(interp, objv[i], &tagsc, &tagsv);
				if (error != TCL_OK) {Tcl_DecrRefCount(result);return TCL_ERROR;}
				error = ExtraL_MapgetStruct(interp, map, data, objv[0], tagsc, tagsv, &res);
				if (error != TCL_OK) {Tcl_DecrRefCount(result);return TCL_ERROR;}
				error = Tcl_ListObjAppendElement(interp, result, res);
				if (error != TCL_OK) {Tcl_DecrRefCount(result);return TCL_ERROR;}
			}
		} else {
			for(i=1;i<objc;i++) {
				error = ExtraL_Mapget(interp, objv[0], objv[i], &res);
				if (error != TCL_OK) {Tcl_DecrRefCount(result);return TCL_ERROR;}
				error = Tcl_ListObjAppendElement(interp, result, res);
				if (error != TCL_OK) {Tcl_DecrRefCount(result);return TCL_ERROR;}
			}
		}
	}
	Tcl_SetObjResult(interp,result);
	return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * ExtraL_MapfieldsObjCmd --
 *
 *		This procedure is invoked to process the "map_fields" command.
 *
 * Results:
 *		A standard Tcl result.
 *
 *
 *----------------------------------------------------------------------
 */

int ExtraL_MapfieldsObjCmd(notUsed, interp, objc, objv)
	ClientData notUsed;				 /* Not used. */
	Tcl_Interp *interp;					/* Current interpreter. */
	int objc;						/* Number of arguments. */
	Tcl_Obj *CONST objv[];	/* Argument objects. */
{
	int listArgc;
	Tcl_Obj **listArgv, *resultObj, *valueObj, *tags, *subtag, *list;
	int pos, error, i, clen;
	char *ctag;

	if ((objc != 2)&&(objc != 3)&&(objc != 4)) {
		Tcl_WrongNumArgs(interp, 1, objv, "list field ?valueVar?");
		return TCL_ERROR;
	}
	list = objv[1];
	if (objc==2) {
		tags = Tcl_NewObj();
		error = ExtraL_Mapget(interp, list, tags, &list);
		Tcl_DecrRefCount(tags);
	} else {
		tags = objv[2];
		error = ExtraL_Mapget(interp, list, tags, &list);
	}

	if (error != TCL_OK) {return error;}
	if (Tcl_ListObjGetElements(interp, list, &listArgc, &listArgv) != TCL_OK) {
		return TCL_ERROR;
	}
	if ((listArgc != 0)&&(listArgc & 1)) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"error: list \"", Tcl_GetStringFromObj(objv[1],&i),"\" does not have an even number of elements",(char *)NULL);
		return TCL_ERROR;
	}
	/* Initialise result */
	Tcl_ResetResult(interp);
	resultObj = Tcl_NewObj();
	for(pos=0;pos<listArgc;pos+=2) {
		error = Tcl_ListObjIndex(interp, listArgv[pos], 0, &subtag);
		if (error != TCL_OK) {return error;}
		if (subtag != NULL) {
			ctag = Tcl_GetStringFromObj(subtag,&clen);
		} else {
			ctag = "";
			clen = 0;
		}
		if ((clen==1)&&(ctag[0]=='?')) {
			error = Tcl_ListObjIndex(interp, listArgv[pos], 1, &subtag);
			if (subtag == NULL) {subtag = Tcl_NewObj();}
			if (error != TCL_OK) {return error;}
			error = Tcl_ListObjAppendElement(interp,resultObj,subtag);
		} else {
			error = Tcl_ListObjAppendElement(interp,resultObj,listArgv[pos]);
		}
		if (error!=TCL_OK) {return error;}
	}
	if (objc == 4) {
		valueObj = Tcl_NewObj();
		for(pos=1;pos<listArgc;pos+=2) {
			error = Tcl_ListObjAppendElement(interp,valueObj,listArgv[pos]);
			if (error!=TCL_OK) {return error;}
		}
		if (Tcl_ObjSetVar2(interp, objv[3], (Tcl_Obj *) NULL,
			valueObj, (TCL_LEAVE_ERR_MSG | TCL_PARSE_PART1)) == NULL) {
				return TCL_ERROR;
		}
	}
	Tcl_SetObjResult(interp,resultObj);
	return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * ExtraL_MapfindCmd --
 *
 *		This procedure is invoked to process the "map_find" command.
 *
 * Results:
 *		A standard Tcl result.
 *
 *
 *----------------------------------------------------------------------
 */

int ExtraL_MapfindObjCmd(notUsed, interp, objc, objv)
	ClientData notUsed;				 /* Not used. */
	Tcl_Interp *interp;					/* Current interpreter. */
	int objc;						/* Number of arguments. */
	Tcl_Obj *CONST objv[];	/* Argument objects. */
{
	int listArgc;
	Tcl_Obj **listArgv;
	Tcl_Obj *resultObj;
	char *ctag,*tag;
	int clen,len;
	int pos;
	int i;

	if ((objc != 3)) {
		Tcl_WrongNumArgs(interp, 1, objv, "list tag");
		return TCL_ERROR;
	}

	if (Tcl_ListObjGetElements(interp, objv[1], &listArgc, &listArgv) != TCL_OK) {
		return TCL_ERROR;
	}
	if ((listArgc != 0)&&(listArgc & 1)) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"error: list \"", Tcl_GetStringFromObj(objv[1],&i),"\" does not have an even number of elements",(char *)NULL);
		return TCL_ERROR;
	}

	tag=Tcl_GetStringFromObj(objv[2],&len);

	/* Initialise result */

	resultObj=Tcl_GetObjResult(interp);
	for(pos=0;pos<listArgc;pos+=2) {
		ctag=Tcl_GetStringFromObj(listArgv[pos],&clen);
		if (clen==len) {
			if (memcmp(ctag,tag,len)==0) {
				Tcl_SetIntObj(resultObj,++pos);
				return TCL_OK;
			}
		}
	}
	Tcl_ResetResult(interp);
	Tcl_SetIntObj(resultObj,-1);
	return TCL_OK;
}

int ExtraL_MapInit(interp)
	Tcl_Interp *interp;
{
	Tcl_InitHashTable(&typesTable,TCL_STRING_KEYS);
	Tcl_CreateObjCommand(interp,"map_set",(Tcl_ObjCmdProc *)ExtraL_MapsetObjCmd,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
	Tcl_CreateObjCommand(interp,"map_unset",(Tcl_ObjCmdProc *)ExtraL_MapunsetObjCmd,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
	Tcl_CreateObjCommand(interp,"map_get",(Tcl_ObjCmdProc *)ExtraL_MapgetObjCmd,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
	Tcl_CreateObjCommand(interp,"map_fields",(Tcl_ObjCmdProc *)ExtraL_MapfieldsObjCmd,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
	Tcl_CreateObjCommand(interp,"map_find",(Tcl_ObjCmdProc *)ExtraL_MapfindObjCmd,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
	ExtraL_MapCreateType(interp,"*string",(ExtraL_MapTypeSetProc *)NULL,(ExtraL_MapTypeGetProc *)NULL,(ExtraL_MapTypeUnsetProc *)NULL);
	ExtraL_MapCreateType(interp,"*text",(ExtraL_MapTypeSetProc *)NULL,(ExtraL_MapTypeGetProc *)NULL,(ExtraL_MapTypeUnsetProc *)NULL);
	ExtraL_MapCreateType(interp,"*any",(ExtraL_MapTypeSetProc *)NULL,(ExtraL_MapTypeGetProc *)NULL,(ExtraL_MapTypeUnsetProc *)NULL);
	ExtraL_MapCreateType(interp,"*int",(ExtraL_MapTypeSetProc *)ExtraL_MapSetInt,(ExtraL_MapTypeGetProc *)NULL,(ExtraL_MapTypeUnsetProc *)NULL);
	ExtraL_MapCreateType(interp,"*double",(ExtraL_MapTypeSetProc *)ExtraL_MapSetDouble,(ExtraL_MapTypeGetProc *)NULL,(ExtraL_MapTypeUnsetProc *)NULL);
	ExtraL_MapCreateType(interp,"*bool",(ExtraL_MapTypeSetProc *)ExtraL_MapSetBool,(ExtraL_MapTypeGetProc *)NULL,(ExtraL_MapTypeUnsetProc *)NULL);
	ExtraL_MapCreateType(interp,"*regexp",(ExtraL_MapTypeSetProc *)ExtraL_MapSetRegexp,(ExtraL_MapTypeGetProc *)NULL,(ExtraL_MapTypeUnsetProc *)NULL);
	ExtraL_MapCreateType(interp,"*between",(ExtraL_MapTypeSetProc *)ExtraL_MapSetBetween,(ExtraL_MapTypeGetProc *)NULL,(ExtraL_MapTypeUnsetProc *)NULL);
	ExtraL_MapCreateType(interp,"*dbetween",(ExtraL_MapTypeSetProc *)ExtraL_MapSetDBetween,(ExtraL_MapTypeGetProc *)NULL,(ExtraL_MapTypeUnsetProc *)NULL);
	ExtraL_MapCreateType(interp,"*date",(ExtraL_MapTypeSetProc *)ExtraL_MapSetDate,(ExtraL_MapTypeGetProc *)ExtraL_MapGetDate,(ExtraL_MapTypeUnsetProc *)NULL);
	ExtraL_MapCreateType(interp,"*time",(ExtraL_MapTypeSetProc *)ExtraL_MapSetTime,(ExtraL_MapTypeGetProc *)ExtraL_MapGetTime,(ExtraL_MapTypeUnsetProc *)NULL);
	ExtraL_MapCreateType(interp,"*list",(ExtraL_MapTypeSetProc *)ExtraL_MapSetList,(ExtraL_MapTypeGetProc *)ExtraL_MapGetList,(ExtraL_MapTypeUnsetProc *)ExtraL_MapUnsetList);
	ExtraL_MapCreateType(interp,"*named",(ExtraL_MapTypeSetProc *)ExtraL_MapSetNamed,(ExtraL_MapTypeGetProc *)ExtraL_MapGetNamed,(ExtraL_MapTypeUnsetProc *)ExtraL_MapUnsetNamed);
	return TCL_OK;
}


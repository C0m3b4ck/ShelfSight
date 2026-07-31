#include <stdio.h>
#include "classyTk.h"

#include "tkPort.h"
#include "tkInt.h"
#include "tkWinInt.h"
#include "tkFileFilter.h"
#include <windows.h>    /* includes basic windows functionality */
#include <commdlg.h>    /* includes common dialog functionality */
#include <dlgs.h>       /* includes common dialog template defines */
#include <cderr.h>      /* includes the common dialog error codes */

int
Classy_GetFontCmd(notUsed, interp, objc, objv)
	ClientData notUsed;        	        /* Not used. */
	Tcl_Interp *interp;        	        /* Current interpreter. */
	int objc;		  	/* Number of arguments. */
	Tcl_Obj *CONST objv[];	/* Argument objects. */
{
	Tcl_Obj *result = NULL, *tempObj = NULL;
	char *string;
	int i,error;
	CHOOSEFONT pcf;
	LOGFONT lf;
	int size, oldMode;

	if (objc < 1) {
		Tcl_WrongNumArgs(interp, 1, objv, "?name? ?size? ?style? ?style? ...");
		return TCL_ERROR;
	}
	GetObject (GetStockObject (SYSTEM_FONT), sizeof (LOGFONT),
		(LPSTR) &lf) ;

	pcf.lStructSize      = sizeof (CHOOSEFONT) ;
	pcf.hwndOwner        = NULL ;
	pcf.lpLogFont        = &lf ;
	pcf.Flags            = CF_INITTOLOGFONTSTRUCT | CF_SCREENFONTS;
	lf.lfWeight=FW_NORMAL;
	lf.lfUnderline=FALSE;
	lf.lfStrikeOut=FALSE;
	lf.lfHeight=0;
	lf.lfWidth=0;
	pcf.rgbColors=RGB(0, 0, 0);

	if (objc > 1) {
		string = Tcl_GetStringFromObj(objv[1],&size);
		if (size > 31) {size = 31;}
		strncpy(lf.lfFaceName,string,size+1);
		if (size == 31) {lf.lfFaceName[32]='\0';}
	}
	if (objc > 2) {
		if (Tcl_GetIntFromObj(interp,objv[2],&size)==TCL_ERROR) {
			return TCL_ERROR;
		}
		lf.lfHeight=-size*1.339;
		lf.lfWidth=0;
	}
	for (i = 3 ; i < objc ; i++) {
		string = Tcl_GetStringFromObj(objv[i],NULL);
Tcl_SetVar(interp,"test",string,TCL_GLOBAL_ONLY|TCL_LIST_ELEMENT);
Tcl_SetVar(interp,"test","----",TCL_GLOBAL_ONLY|TCL_LIST_ELEMENT);
		if (strcmp(string,"thin")==0) lf.lfWeight=FW_THIN;
		else if (strcmp(string,"extralight")==0) lf.lfWeight=FW_EXTRALIGHT;
		else if (strcmp(string,"light")==0) lf.lfWeight=FW_LIGHT;
		else if (strcmp(string,"normal")==0) lf.lfWeight=FW_NORMAL;
		else if (strcmp(string,"regular")==0) lf.lfWeight=FW_REGULAR;
		else if (strcmp(string,"medium")==0) lf.lfWeight=  FW_MEDIUM;
		else if (strcmp(string,"semibold")==0) lf.lfWeight=FW_SEMIBOLD;
		else if (strcmp(string,"bold")==0) lf.lfWeight=FW_BOLD;
		else if (strcmp(string,"extrabold")==0) lf.lfWeight=FW_EXTRABOLD;
		else if (strcmp(string,"heavy")==0) lf.lfWeight=FW_HEAVY;
		else if (strcmp(string,"black")==0) lf.lfWeight=FW_BLACK;
		if (strcmp(string,"italic")==0) lf.lfItalic=TRUE;
		if (strcmp(string,"underline")==0) lf.lfUnderline=TRUE;
		if (strcmp(string,"strikeout")==0) lf.lfStrikeOut=TRUE;
	}
    oldMode = Tcl_SetServiceMode(TCL_SERVICE_ALL);
 /*	TkWinEnterModalLoop(interp);*/
	if (ChooseFont(&pcf)==FALSE) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"No font selected",NULL);
		return TCL_ERROR;
	}
    (void) Tcl_SetServiceMode(oldMode);
/*	TkWinLeaveModalLoop(interp);*/
	result = Tcl_NewListObj(0,NULL);
	tempObj = Tcl_NewStringObj(pcf.lpLogFont->lfFaceName,-1);
	if (tempObj == NULL) {goto error;}
	error = Tcl_ListObjAppendElement(interp,result,tempObj);
	if (error) {goto error;}
	tempObj = Tcl_NewIntObj(pcf.iPointSize/10);
	if (tempObj == NULL) {goto error;}
	error = Tcl_ListObjAppendElement(interp,result,tempObj);
	tempObj = NULL;
	if (error) {goto error;}
	error = TCL_OK;
	switch (pcf.lpLogFont->lfWeight) {
		case FW_THIN		: error = Tcl_ListObjAppendElement(interp,result,Tcl_NewStringObj("thin",-1));break;
		case FW_EXTRALIGHT	: error = Tcl_ListObjAppendElement(interp,result,Tcl_NewStringObj("extralight",-1));break;
		case FW_LIGHT		: error = Tcl_ListObjAppendElement(interp,result,Tcl_NewStringObj("light",-1));break;
		case FW_NORMAL		: error = Tcl_ListObjAppendElement(interp,result,Tcl_NewStringObj("normal",-1));break;
		case FW_MEDIUM		: error = Tcl_ListObjAppendElement(interp,result,Tcl_NewStringObj("medium",-1));break;
		case FW_SEMIBOLD	: error = Tcl_ListObjAppendElement(interp,result,Tcl_NewStringObj("semibold",-1));break;
		case FW_BOLD		: error = Tcl_ListObjAppendElement(interp,result,Tcl_NewStringObj("bold",-1));break;
		case FW_EXTRABOLD	: error = Tcl_ListObjAppendElement(interp,result,Tcl_NewStringObj("extrabold",-1));break;
		case FW_HEAVY		: error = Tcl_ListObjAppendElement(interp,result,Tcl_NewStringObj("heavy",-1));break;
	}
	if (error) {goto error;}
	if (pcf.lpLogFont->lfItalic>0) {
		error = Tcl_ListObjAppendElement(interp,result,Tcl_NewStringObj("italic",-1));
		if (error) {goto error;}
	}
	if (pcf.lpLogFont->lfUnderline>0) {
		error = Tcl_ListObjAppendElement(interp,result,Tcl_NewStringObj("underline",-1));
		if (error) {goto error;}
	}
	if (pcf.lpLogFont->lfStrikeOut>0) {
		error = Tcl_ListObjAppendElement(interp,result,Tcl_NewStringObj("strikeout",-1));
		if (error) {goto error;}
	}
	Tcl_SetObjResult(interp,result);
	return TCL_OK;
	error:
		if (result != NULL) {Tcl_DecrRefCount(result);}
		if (tempObj != NULL) {Tcl_DecrRefCount(tempObj);}
}

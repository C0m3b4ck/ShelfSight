/*
 * gpExportVisitor.c --
 *
 *	This file implements export to printer and clipboard under MS Windows
 */

#include <math.h>
#include "tcl.h"
#include "tk.h"
#include "tkWinInt.h"
#include "tkCanvas.h"

#include <commdlg.h>    /* includes common dialog functionality */
#include <dlgs.h>       /* includes common dialog template defines */
#include <cderr.h>      /* includes the common dialog error codes */

/****************************************************************
** Hash table support
**
** Provided by the hdc extension
****************************************************************/
static int  hdc_loaded = 0;
static int (*hdc_init) (Tcl_Interp *interp);
static const char * (*hdc_create) (Tcl_Interp *interp, void *ptr, int type);
static int (*hdc_valid) (Tcl_Interp *interp, const char *hdcname, int type);
static int (*hdc_delete) (Tcl_Interp *interp, const char *hdcname);
static void * (*hdc_get) (Tcl_Interp *interp, const char *hdcname);
static int (*hdc_typeof) (Tcl_Interp *interp, const char *hdcname);
static const char * (*hdc_prefixof) (Tcl_Interp *interp, int type, const char *newprefix);
static int (*hdc_list) (Tcl_Interp *interp, int type, const char *out[], int *poutlen);

int init_hdc_functions(Tcl_Interp *interp)
{
	void *fn[7];
	int result;
	const char *cp;
	if (hdc_loaded) {return TCL_OK;}
	if (! Tcl_PkgRequire (interp, "hdc", "0.2", 0) ) {
		return TCL_ERROR;
	}
	if ( Tcl_Eval(interp, "hdc FunctionVector") == TCL_OK ) {
		cp = Tcl_GetStringResult(interp);
		result = sscanf(cp, "%lx%lx%lx%lx%lx%lx%lx", &fn[0], &fn[1], &fn[2], &fn[3], &fn[4], &fn[5], &fn[6]);
		if ( result == 7) {
			hdc_create = fn[0];
			hdc_delete = fn[1];
			hdc_get    = fn[2];
			hdc_typeof = fn[3];
			hdc_prefixof = fn[4];
			hdc_list     = fn[5];
			hdc_valid    = fn[6];
		}
	}
	hdc_loaded = 1;
	return TCL_OK;
}

static HDC get_dc(Tcl_Interp *interp, const char *name)
{
  /* ANY type of DC should be ok here */
  if ( hdc_loaded == 0 || hdc_valid == 0 || hdc_valid(interp, name, -1) == 0 )
  {
    char *strend;
    unsigned long tmp;
    
    /* Perhaps it is a numeric DC */
    tmp = strtoul(name, &strend, 0);
    if ( strend != 0 && strend > name )
    {
      DWORD objtype = GetObjectType((HGDIOBJ)tmp);
      switch (objtype)
      {
        /* Any of the DC types are OK. */
        case OBJ_DC: case OBJ_MEMDC: case OBJ_METADC: case OBJ_ENHMETADC:
          break;
        /* Anything else is invalid */
        case 0: /* Function failed */
        default:
          tmp = 0;
          Tcl_AppendResult(interp, "Error: Wrong type of handle for this operation: ",
                       "need a drawing context, got non-context address: ", name, "\n", 0);
          break;
      }
      return (HDC)tmp;
    }
    else
    {
      Tcl_AppendResult(interp, "Error: Wrong type of handle for this operation: ",
                       "need a drawing context, got: ", name, "\n", 0);
      return 0;
    }
  }

  {
    HDC hdc = (HDC)hdc_get(interp, name);
    DWORD objtype = GetObjectType((HGDIOBJ)hdc);
    switch (objtype)
    {
      /* Any of the DC types are OK. */
      case OBJ_DC: case OBJ_MEMDC: case OBJ_METADC: case OBJ_ENHMETADC:
        break;
      /* Anything else is invalid */
      case 0: /* Function failed */
      default:
        hdc = 0;
        Tcl_AppendResult(interp, "Error: Wrong type of handle for this operation: ",
                                 "need a drawing context, got: ", name, "\n", 0);
        break;
    }
    return hdc;
  }
}

/*
 *----------------------------------------------------------------------
 *----------------------------------------------------------------------
 *----------------------------------------------------------------------
 *----------------------------------------------------------------------
 */
/*
 * These are internal routines.
 */

static int ProcessCDError _ANSI_ARGS_((Tcl_Interp *interp, DWORD dwErrorCode, HWND hWnd));

/*
 *----------------------------------------------------------------------
 *
 * ProcessCDError --
 *
 *	This procedure gets called if a Windows-specific error message
 *	has occurred during the execution of a common dialog or the
 *	user has pressed the CANCEL button.
 *
 * Results:
 *	If an error has indeed happened, returns a standard TCL result
 *	that reports the error code in string format. If the user has
 *	pressed the CANCEL button (dwErrorCode == 0), resets
 *	interp->result to the empty string.
 *
 * Side effects:
 *	interp->result is changed.
 *
 *----------------------------------------------------------------------
 */
static int ProcessCDError(interp, dwErrorCode, hWnd)
    Tcl_Interp * interp;		/* Current interpreter. */
    DWORD dwErrorCode;			/* The Windows-specific error code */
    HWND hWnd;				/* window in which the error happened*/
{
    char *string;

    switch(dwErrorCode) {
      case 0:	  /* User has hit CANCEL */
	return TCL_OK;

      case CDERR_DIALOGFAILURE:   string="CDERR_DIALOGFAILURE";  	break;
      case CDERR_STRUCTSIZE:      string="CDERR_STRUCTSIZE";   		break;
      case CDERR_INITIALIZATION:  string="CDERR_INITIALIZATION";   	break;
      case CDERR_NOTEMPLATE:      string="CDERR_NOTEMPLATE";   		break;
      case CDERR_NOHINSTANCE:     string="CDERR_NOHINSTANCE";   	break;
      case CDERR_LOADSTRFAILURE:  string="CDERR_LOADSTRFAILURE";   	break;
      case CDERR_FINDRESFAILURE:  string="CDERR_FINDRESFAILURE";   	break;
      case CDERR_LOADRESFAILURE:  string="CDERR_LOADRESFAILURE";   	break;
      case CDERR_LOCKRESFAILURE:  string="CDERR_LOCKRESFAILURE";   	break;
      case CDERR_MEMALLOCFAILURE: string="CDERR_MEMALLOCFAILURE";   	break;
      case CDERR_MEMLOCKFAILURE:  string="CDERR_MEMLOCKFAILURE";   	break;
      case CDERR_NOHOOK:          string="CDERR_NOHOOK";   	 	break;
      case PDERR_SETUPFAILURE:    string="PDERR_SETUPFAILURE";   	break;
      case PDERR_PARSEFAILURE:    string="PDERR_PARSEFAILURE";   	break;
      case PDERR_RETDEFFAILURE:   string="PDERR_RETDEFFAILURE";   	break;
      case PDERR_LOADDRVFAILURE:  string="PDERR_LOADDRVFAILURE";   	break;
      case PDERR_GETDEVMODEFAIL:  string="PDERR_GETDEVMODEFAIL";   	break;
      case PDERR_INITFAILURE:     string="PDERR_INITFAILURE";   	break;
      case PDERR_NODEVICES:       string="PDERR_NODEVICES";   		break;
      case PDERR_NODEFAULTPRN:    string="PDERR_NODEFAULTPRN";   	break;
      case PDERR_DNDMMISMATCH:    string="PDERR_DNDMMISMATCH";   	break;
      case PDERR_CREATEICFAILURE: string="PDERR_CREATEICFAILURE";   	break;
      case PDERR_PRINTERNOTFOUND: string="PDERR_PRINTERNOTFOUND";   	break;
      case CFERR_NOFONTS:         string="CFERR_NOFONTS";   	 	break;
      case FNERR_SUBCLASSFAILURE: string="FNERR_SUBCLASSFAILURE";   	break;
      case FNERR_INVALIDFILENAME: string="FNERR_INVALIDFILENAME";   	break;
      case FNERR_BUFFERTOOSMALL:  string="FNERR_BUFFERTOOSMALL";   	break;
	
      default:
	sprintf(string,"%d",(int)dwErrorCode);
    }

    Tcl_AppendResult(interp, "Win32 internal error: ", string, NULL); 
    return TCL_ERROR;
}

/*
 *----------------------------------------------------------------------
 *
 * Classy_ExportCanvasPrint --
 *
 *----------------------------------------------------------------------
 */
int
Classy_ExportCanvasPrint(canvas, tkwin, interp, objc, objv)
	TkCanvas *canvas;
	Tk_Window tkwin;
	Tcl_Interp *interp;
	int objc;
	Tcl_Obj *CONST objv[];
{
	PRINTDLG lppd;
	DOCINFO lpdi;
	TkWinDrawable drawable;
	Tk_Item *itemPtr;
	BOOL b;
	HDC hdc;
	HWND hwnd;
	HENHMETAFILE hemf;
	Tk_Uid tag = NULL, seltag=NULL, *tagPtr;
	double fx=1.0, fy=1.0;
	char *string,*bitmapid = NULL;
	float xof,yof;
	float drawable_pixX,drawable_pixY,drawable_mmX,drawable_mmY;
	int originx=0, originy=0,width,height;
	int error,pos,i,res,stringlen,count;
Tcl_AppendResult(interp,"start\n",(char *)NULL);
	if (objc < 3) {
		Tcl_WrongNumArgs(interp, 1, objv, "print canvas ?-tag tag? ?-originx xorigin? ?-originy yorigin? ?-scalex xscale? ?-scaley yscale?");
		return TCL_ERROR;
	}
	if (Tk_WindowId(tkwin) == None) {
		Tk_MakeWindowExist(tkwin);
	}
	pos = 3;
	while(pos < objc) {
		string = Tcl_GetStringFromObj(objv[pos], &i);
		if ((i==7)&&(strncmp(string,"-scalex",7) == 0)) {
			if ((pos+1) >= objc) {
				Tcl_AppendResult(interp,"no value given for option \"-scalex\"",(char *)NULL);
				return TCL_ERROR;
			}
			error = Tcl_GetDoubleFromObj(interp,objv[pos+1],&fx);
			if (error) {return error;}
			pos += 2;
		} else if ((i==7)&&(strncmp(string,"-scaley",7) == 0)) {
			if (pos+1 >= objc) {
				Tcl_AppendResult(interp,"no value given for option \"-scaley\"",(char *)NULL);
				return TCL_ERROR;
			}
			error = Tcl_GetDoubleFromObj(interp,objv[pos+1],&fy);
			if (error) {return error;}
			pos += 2;
		} else if ((i==8)&&(strncmp(string,"-originx",8) == 0)) {
			if (pos+1 >= objc) {
				Tcl_AppendResult(interp,"no value given for option \"-originx\"",(char *)NULL);
				return TCL_ERROR;
			}
			error = Tcl_GetIntFromObj(interp,objv[pos+1],&originx);
			if (error) {return error;}
			pos += 2;
		} else if ((i==8)&&(strncmp(string,"-originy",8) == 0)) {
			if (pos+1 >= objc) {
				Tcl_AppendResult(interp,"no value given for option \"-originy\"",(char *)NULL);
				return TCL_ERROR;
			}
			error = Tcl_GetIntFromObj(interp,objv[pos+1],&originy);
			if (error) {return error;}
			pos += 2;
		} else if ((i==4)&&(strncmp(string,"-tag",4) == 0)) {
			if ((pos+1) >= objc) {
				Tcl_AppendResult(interp,"no value given for option \"-tag\"",(char *)NULL);
				return TCL_ERROR;
			}
			if (strcmp(Tcl_GetStringFromObj(objv[pos+1],NULL),"all") == 0) {
				tag = NULL;
			} else {
				tag = Tk_GetUid(Tcl_GetStringFromObj(objv[pos+1],NULL));
			}
			pos += 2;
		} else if ((i==10)&&(strncmp(string,"-selecttag",10) == 0)) {
			if ((pos+1) >= objc) {
				Tcl_AppendResult(interp,"no value given for option \"-selecttag\"",(char *)NULL);
				return TCL_ERROR;
			}
			if (strcmp(Tcl_GetStringFromObj(objv[pos+1],NULL),"all") == 0) {
				seltag = NULL;
			} else {
				seltag = Tk_GetUid(Tcl_GetStringFromObj(objv[pos+1],NULL));
			}
			pos += 2;
		} else {
			Tcl_AppendResult(interp,"unkown option \"", string, "\": should be one of -tag, -scalex, -scaley",(char *)NULL);
			return TCL_ERROR;
			break;
		}
	}
	lppd.lStructSize = sizeof(PRINTDLG);
	lppd.hwndOwner = (HWND)NULL;	/* filled in below */
	lppd.hDevMode = (HANDLE) NULL;
	lppd.hDevNames = (HANDLE) NULL;
	lppd.hDC  = (HDC) NULL;
/*	lppd.Flags = PD_NOPAGENUMS | PD_PRINTSETUP | PD_RETURNDC | PD_USEDEVMODECOPIESANDCOLLATE;*/
	lppd.Flags = PD_RETURNDC | PD_NOPAGENUMS;
	if (seltag == NULL) {
		lppd.Flags |= PD_NOSELECTION;
	}
	lppd.nFromPage = 1;
	lppd.nToPage = 1;
	lppd.nMinPage = 1;
	lppd.nMaxPage = 1;
	lppd.nCopies = 1;
	lppd.hInstance = (HANDLE) NULL;
	lppd.lpfnPrintHook = (LPPRINTHOOKPROC) NULL;
	lppd.lpfnSetupHook = (LPSETUPHOOKPROC) NULL;
	lppd.lpPrintTemplateName = (LPSTR) NULL;
	lppd.lpSetupTemplateName = (LPSTR) NULL;
	lppd.hPrintTemplate = (HANDLE) NULL;
	lppd.hSetupTemplate = (HANDLE) NULL;
	lppd.hwndOwner = (HWND)Tk_GetHWND(Tk_WindowId(tkwin));
	drawable.type = TWD_WINDC;
	drawable.winDC.type = TWD_WINDC;
	hdc = GetDC(hwnd);
	if (PrintDlg(&lppd)==FALSE) {
		error = ProcessCDError(interp, CommDlgExtendedError(), lppd.hwndOwner);
		if (error == TCL_ERROR) {
			Tcl_AppendResult(interp, " while invoking PrintDlg ",(char *) NULL);
		}
		return error;
	}
/*
Tcl_AppendResult(interp,"dialog",(char *)NULL);
return TCL_ERROR;
*/
	if (lppd.Flags && PD_SELECTION) {
		tag = seltag;
	}
	drawable.winDC.hdc = lppd.hDC;
	lpdi.cbSize = sizeof(DOCINFO);
	lpdi.lpszDocName = "Canvas printout";
	lpdi.lpszOutput = (LPTSTR) NULL;
	lpdi.lpszDatatype = (LPTSTR) NULL;
	lpdi.fwType = 0;
	error=StartDoc(drawable.winDC.hdc,&lpdi);
	if (error <= 0) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp, "Startdoc failed",(char *) NULL);
		ProcessCDError(interp, CommDlgExtendedError(), lppd.hwndOwner);
		return TCL_ERROR;
	}
	error = StartPage(drawable.winDC.hdc);
	if (error <= 0) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp, "StartPage failed",(char *) NULL);
		ProcessCDError(interp, CommDlgExtendedError(), lppd.hwndOwner);
		return TCL_ERROR;
	}
	error=SetMapMode(drawable.winDC.hdc, MM_TEXT);
	if (error == 0) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp, "SetMapMode failed",(char *) NULL);
		return TCL_ERROR;
	}
	width=canvas->width;
	height=canvas->height;
	if (Tk_GetPixels(interp, tkwin, "1i",&res) != TCL_OK) {
		return TCL_ERROR;
	}
	SetWindowExtEx(drawable.winDC.hdc, 
		(int)(100.0*res),
		(int)(100.0*res),
		NULL);
	SetViewportExtEx(drawable.winDC.hdc, 
		(int)(100.0*fx*GetDeviceCaps(drawable.winDC.hdc, LOGPIXELSX)),
		(int)(100.0*fy*GetDeviceCaps(drawable.winDC.hdc, LOGPIXELSY)),
		NULL);
	SetWindowOrgEx(drawable.winDC.hdc, 0,0,NULL);
	SetViewportOrgEx(drawable.winDC.hdc, 0,0,NULL);
	/*
	 * do export
	 */
	canvas->drawableXOrigin = originx - 30;
	canvas->drawableYOrigin = originy - 30;
	{
		Tk_ItemType *itemtype = Tk_GetItemTypes();
		while (itemtype != NULL) {
			if (strcmp(itemtype->name,"bitmap") == 0) {
				bitmapid = itemtype->name;
			}
			itemtype = itemtype->nextPtr;
		}
	}
	if (tag == NULL) {
	 	for (itemPtr = canvas->firstItemPtr; itemPtr != NULL;	itemPtr = itemPtr->nextPtr) {
			if ((*itemPtr->typePtr).name == bitmapid) {continue;}
			(*itemPtr->typePtr->displayProc)(
				(Tk_Canvas) canvas, itemPtr,
				canvas->display, (unsigned long) &drawable, 
				0, 0, 32767, 32767);
		}
	} else {
	 	for (itemPtr = canvas->firstItemPtr; itemPtr != NULL;	itemPtr = itemPtr->nextPtr) {
			if ((*itemPtr->typePtr).name == bitmapid) {continue;}
			for (tagPtr = itemPtr->tagPtr, count = itemPtr->numTags; count > 0; tagPtr++, count--) {
				if (*tagPtr == tag) {
					(*itemPtr->typePtr->displayProc)(
						(Tk_Canvas) canvas, itemPtr,
						canvas->display, (unsigned long) &drawable, 
						0, 0, 32767, 32767);
					break;
				}
			}
		}
	}
	EndPage(drawable.winDC.hdc);
	EndDoc(drawable.winDC.hdc);
	DeleteDC(drawable.winDC.hdc);
	return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * Classy_ExportCanvasClipboard --
 *
 *----------------------------------------------------------------------
 */
int
Classy_ExportCanvasClipboard(canvas, tkwin, interp, objc, objv)
	TkCanvas *canvas;
	Tk_Window tkwin;
	Tcl_Interp *interp;
	int objc;
	Tcl_Obj *CONST objv[];
{
	TkWinDrawable drawable;
	Tk_Item *itemPtr;
	BOOL b;
	HDC hdc;
	HWND hwnd;
	HENHMETAFILE hemf;
	HMETAFILE hwmf;
	METAFILEPICT mfpict;
	Tk_Uid tag = NULL, *tagPtr;
	int originx=0, originy=0;
	double scale=1.0;
	char *string, *bitmapid;
	float xof,yof;
	float drawable_pixX,drawable_pixY,drawable_mmX,drawable_mmY;
	int width,height;
	int error,pos,i,res,stringlen,count,print;

	if (objc < 3) {
		Tcl_WrongNumArgs(interp, 1, objv, "clipboard canvas ?-scale scale? ?-tag tag? ?-originx xorigin? ?-originy yorigin?");
		return TCL_ERROR;
	}
	pos = 3;
	while(pos < objc) {
		string = Tcl_GetStringFromObj(objv[pos], &i);
		if ((i==6)&&(strncmp(string,"-scale",6) == 0)) {
			if ((pos+1) >= objc) {
				Tcl_AppendResult(interp,"no value given for option \"-scale\"",(char *)NULL);
				return TCL_ERROR;
			}
			error = Tcl_GetDoubleFromObj(interp,objv[pos+1],&scale);
			if (error) {return error;}
			pos += 2;
		} else if ((i==8)&&(strncmp(string,"-originx",8) == 0)) {
			if (pos+1 >= objc) {
				Tcl_AppendResult(interp,"no value given for option \"-originx\"",(char *)NULL);
				return TCL_ERROR;
			}
			error = Tcl_GetIntFromObj(interp,objv[pos+1],&originx);
			if (error) {return error;}
			pos += 2;
		} else if ((i==8)&&(strncmp(string,"-originy",8) == 0)) {
			if (pos+1 >= objc) {
				Tcl_AppendResult(interp,"no value given for option \"-originy\"",(char *)NULL);
				return TCL_ERROR;
			}
			error = Tcl_GetIntFromObj(interp,objv[pos+1],&originy);
			if (error) {return error;}
			pos += 2;
		} else if ((i==4)&&(strncmp(string,"-tag",4) == 0)) {
			if ((pos+1) >= objc) {
				Tcl_AppendResult(interp,"no value given for option \"-tag\"",(char *)NULL);
				return TCL_ERROR;
			}
			if (strcmp(Tcl_GetStringFromObj(objv[pos+1],NULL),"all") == 0) {
				tag = NULL;
			} else {
				tag = Tk_GetUid(Tcl_GetStringFromObj(objv[pos+1],NULL));
			}
			pos += 2;
		} else {
			Tcl_AppendResult(interp,"unkown option \"", string, "\": should be one of -tag, -scale",(char *)NULL);
			return TCL_ERROR;
			break;
		}
	}
	if (Tk_WindowId(tkwin) == None) {
		Tk_MakeWindowExist(tkwin);
	}
	hwnd = (HWND)Tk_GetHWND(Tk_WindowId(tkwin));
	drawable.type = TWD_WINDC;
	drawable.winDC.type = TWD_WINDC;
	hdc = GetDC(hwnd);
	width=canvas->width;
	height=canvas->height;
	drawable.winDC.hdc = CreateEnhMetaFile(hdc, (LPCTSTR) NULL, (RECT *)NULL, (LPCTSTR)NULL);
	if (!(drawable.winDC.hdc)) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp, "Couldn't create Enhanced Metafile",
		(char *) NULL);
		return TCL_ERROR;
	}
	error=SetMapMode(drawable.winDC.hdc, MM_TEXT);
	if (error == 0) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp, "SetMapMode failed",(char *) NULL);
		return TCL_ERROR;
	}
	if (Tk_GetPixels(interp, tkwin, "1i",&res) != TCL_OK) {
		return TCL_ERROR;
	}
	SetWindowExtEx(drawable.winDC.hdc, 
		(int)(100.0*res),
		(int)(100.0*res),
		NULL);
	SetViewportExtEx(drawable.winDC.hdc, 
		(int)(100.0*scale*GetDeviceCaps(drawable.winDC.hdc, LOGPIXELSX)),
		(int)(100.0*scale*GetDeviceCaps(drawable.winDC.hdc, LOGPIXELSY)),
		NULL);
	SetWindowOrgEx(drawable.winDC.hdc, 0,0,NULL);
	SetViewportOrgEx(drawable.winDC.hdc, 0,0,NULL);
	/*
	 * do export
	 */
	canvas->drawableXOrigin = originx;
	canvas->drawableYOrigin = originy;
	{
		Tk_ItemType *itemtype = Tk_GetItemTypes();
		while (itemtype != NULL) {
			if (strcmp(itemtype->name,"bitmap") == 0) {
				bitmapid = itemtype->name;
			}
			itemtype = itemtype->nextPtr;
		}
	}
	if (tag == NULL) {
	 	for (itemPtr = canvas->firstItemPtr; itemPtr != NULL;	itemPtr = itemPtr->nextPtr) {
			if ((*itemPtr->typePtr).name == bitmapid) {continue;}
			(*itemPtr->typePtr->displayProc)(
				(Tk_Canvas) canvas, itemPtr,
				canvas->display, (unsigned long) &drawable, 
				0, 0, 32767, 32767);
		}
	} else {
	 	for (itemPtr = canvas->firstItemPtr; itemPtr != NULL;	itemPtr = itemPtr->nextPtr) {
			if ((*itemPtr->typePtr).name == bitmapid) {continue;}
			for (tagPtr = itemPtr->tagPtr, count = itemPtr->numTags; count > 0; tagPtr++, count--) {
				if (*tagPtr == tag) {
					(*itemPtr->typePtr->displayProc)(
						(Tk_Canvas) canvas, itemPtr,
						canvas->display, (unsigned long) &drawable, 
						0, 0, 32767, 32767);
					break;
				}
			}
		}
	}
	hemf=CloseEnhMetaFile(drawable.winDC.hdc);
	b = OpenClipboard(hwnd);
	if (b == FALSE) {
		CloseClipboard();
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp, "Couldn't open clipboard",(char *) NULL);
		return TCL_ERROR;
	}
	b = EmptyClipboard();
	if (b == FALSE) {
		CloseClipboard();
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp, "Couldn't empty clipboard",(char *) NULL);
		return TCL_ERROR;
	}
	SetClipboardData(CF_ENHMETAFILE,(HANDLE)hemf);
	CloseClipboard();
	return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * Classy_Canvas2hdc --
 *
 *----------------------------------------------------------------------
 */
int
Classy_ExportCanvasHdc(canvas, tkwin, interp, objc, objv)
	TkCanvas *canvas;
	Tk_Window tkwin;
	Tcl_Interp *interp;
	int objc;
	Tcl_Obj *CONST objv[];
{
	DWORD objtype;
	TkWinDrawable drawable;
	Tk_Item *itemPtr;
	BOOL b;
	Tk_Uid tag = NULL, seltag=NULL, *tagPtr;
	double fx=1.0, fy=1.0;
	char *string,*bitmapid = NULL;
	float xof,yof;
	float drawable_pixX,drawable_pixY,drawable_mmX,drawable_mmY;
	int originx=0, originy=0,width,height;
	int error,pos,i,res,stringlen,count;
	error = init_hdc_functions(interp);
	if (error) {return error;}
	if (objc < 3) {
		Tcl_WrongNumArgs(interp, 1, objv, "hdc canvas hdc ?-tag tag? ?-originx xorigin? ?-originy yorigin? ?-scalex xscale? ?-scaley yscale?");
		return TCL_ERROR;
	}
	if (Tk_WindowId(tkwin) == None) {
		Tk_MakeWindowExist(tkwin);
	}
	drawable.type = TWD_WINDC;
	drawable.winDC.type = TWD_WINDC;
	drawable.winDC.hdc = get_dc(interp, Tcl_GetStringFromObj(objv[3],NULL));
	/* Check hDC */
	if (drawable.winDC.hdc == (HDC)0 ) {
		Tcl_AppendResult(interp, "Device context ", Tcl_GetStringFromObj(objv[3],NULL), " is invalid for GDI", 0);
		return TCL_ERROR;
	}
	pos = 4;
	while(pos < objc) {
		string = Tcl_GetStringFromObj(objv[pos], &i);
		if ((i==7)&&(strncmp(string,"-scalex",7) == 0)) {
			if ((pos+1) >= objc) {
				Tcl_AppendResult(interp,"no value given for option \"-scalex\"",(char *)NULL);
				return TCL_ERROR;
			}
			error = Tcl_GetDoubleFromObj(interp,objv[pos+1],&fx);
			if (error) {return error;}
			pos += 2;
		} else if ((i==7)&&(strncmp(string,"-scaley",7) == 0)) {
			if (pos+1 >= objc) {
				Tcl_AppendResult(interp,"no value given for option \"-scalex\"",(char *)NULL);
				return TCL_ERROR;
			}
			error = Tcl_GetDoubleFromObj(interp,objv[pos+1],&fy);
			if (error) {return error;}
			pos += 2;
		} else if ((i==8)&&(strncmp(string,"-originx",8) == 0)) {
			if (pos+1 >= objc) {
				Tcl_AppendResult(interp,"no value given for option \"-originx\"",(char *)NULL);
				return TCL_ERROR;
			}
			error = Tcl_GetIntFromObj(interp,objv[pos+1],&originx);
			if (error) {return error;}
			pos += 2;
		} else if ((i==8)&&(strncmp(string,"-originy",8) == 0)) {
			if (pos+1 >= objc) {
				Tcl_AppendResult(interp,"no value given for option \"-originy\"",(char *)NULL);
				return TCL_ERROR;
			}
			error = Tcl_GetIntFromObj(interp,objv[pos+1],&originy);
			if (error) {return error;}
			pos += 2;
		} else if ((i==4)&&(strncmp(string,"-tag",4) == 0)) {
			if ((pos+1) >= objc) {
				Tcl_AppendResult(interp,"no value given for option \"-tag\"",(char *)NULL);
				return TCL_ERROR;
			}
			if (strcmp(Tcl_GetStringFromObj(objv[pos+1],NULL),"all") == 0) {
				tag = NULL;
			} else {
				tag = Tk_GetUid(Tcl_GetStringFromObj(objv[pos+1],NULL));
			}
			pos += 2;
		} else if ((i==10)&&(strncmp(string,"-selecttag",10) == 0)) {
			if ((pos+1) >= objc) {
				Tcl_AppendResult(interp,"no value given for option \"-selecttag\"",(char *)NULL);
				return TCL_ERROR;
			}
			if (strcmp(Tcl_GetStringFromObj(objv[pos+1],NULL),"all") == 0) {
				seltag = NULL;
			} else {
				seltag = Tk_GetUid(Tcl_GetStringFromObj(objv[pos+1],NULL));
			}
			pos += 2;
		} else {
			Tcl_AppendResult(interp,"unkown option \"", string, "\": should be one of -tag, -scalex, -scaley",(char *)NULL);
			return TCL_ERROR;
			break;
		}
	}
	error=SetMapMode(drawable.winDC.hdc, MM_ANISOTROPIC);
	if (error == 0) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp, "SetMapMode failed",(char *) NULL);
		return TCL_ERROR;
	}
	width=canvas->width;
	height=canvas->height;
	if (Tk_GetPixels(interp, tkwin, "1i",&res) != TCL_OK) {
		return TCL_ERROR;
	}
	SetWindowExtEx(drawable.winDC.hdc, 
		(int)(100.0*res),
		(int)(100.0*res),
		NULL);
	SetViewportExtEx(drawable.winDC.hdc, 
		(int)(100.0*fx*GetDeviceCaps(drawable.winDC.hdc, LOGPIXELSX)),
		(int)(100.0*fy*GetDeviceCaps(drawable.winDC.hdc, LOGPIXELSY)),
		NULL);
	SetWindowOrgEx(drawable.winDC.hdc, 0,0,NULL);
	SetViewportOrgEx(drawable.winDC.hdc, 0,0,NULL);
	/*
	 * do export
	 */
	canvas->drawableXOrigin = originx;
	canvas->drawableYOrigin = originy;
	{
		Tk_ItemType *itemtype = Tk_GetItemTypes();
		while (itemtype != NULL) {
			if (strcmp(itemtype->name,"bitmap") == 0) {
				bitmapid = itemtype->name;
			}
			itemtype = itemtype->nextPtr;
		}
	}
	if (tag == NULL) {
	 	for (itemPtr = canvas->firstItemPtr; itemPtr != NULL;	itemPtr = itemPtr->nextPtr) {
			/*if ((*itemPtr->typePtr).name == bitmapid) {continue;}*/
			(*itemPtr->typePtr->displayProc)(
				(Tk_Canvas) canvas, itemPtr,
				canvas->display, (unsigned long) &drawable, 
				0, 0, 32767, 32767);
		}
	} else {
	 	for (itemPtr = canvas->firstItemPtr; itemPtr != NULL;	itemPtr = itemPtr->nextPtr) {
			/*if ((*itemPtr->typePtr).name == bitmapid) {continue;}*/
			for (tagPtr = itemPtr->tagPtr, count = itemPtr->numTags; count > 0; tagPtr++, count--) {
				if (*tagPtr == tag) {
					(*itemPtr->typePtr->displayProc)(
						(Tk_Canvas) canvas, itemPtr,
						canvas->display, (unsigned long) &drawable, 
						0, 0, 32767, 32767);
					break;
				}
			}
		}
	}
	return TCL_OK;
}

int
Classy_ExportCanvasCmd(clientData, interp, objc, objv)
	ClientData clientData;	/* Main window associated with interpreter. */
	Tcl_Interp *interp;		/* Current interpreter. */
	int objc;			/* Number of arguments. */
	Tcl_Obj *CONST objv[];	/* Argument objects. */
{
	Tcl_CmdInfo canvasCmd;
	TkCanvas *canvas;
	Tk_Window tkwin;
	TkWindow *winPtr;
	char *string;
	int stringlen;
	if (objc < 3) {
		Tcl_WrongNumArgs(interp, 1, objv, "option canvasName ...");
		return TCL_ERROR;
	}
	string = Tcl_GetStringFromObj(objv[2],&stringlen);
	tkwin = Tk_NameToWindow(interp,string,Tk_MainWindow(interp));
	if (tkwin == NULL) {return TCL_ERROR;}
	winPtr = (TkWindow *) tkwin;
	if (winPtr->classUid != Tk_GetUid("Canvas")) {
		Tcl_AppendResult(interp, "\"", string, "\" is not a canvas", (char *) NULL);
		return TCL_ERROR;
	}
	canvas = (TkCanvas *)winPtr->instanceData;
	string = Tcl_GetStringFromObj(objv[1],&stringlen);
	if ((stringlen == 5) && (strncmp(string,"print", stringlen) == 0)) {
		return Classy_ExportCanvasPrint(canvas, tkwin, interp, objc, objv);
	} else if ((stringlen == 9) && (strncmp(string,"clipboard", stringlen) == 0)) {
		return Classy_ExportCanvasClipboard(canvas, tkwin, interp, objc, objv);
	} else if ((stringlen == 3) && (strncmp(string,"hdc", stringlen) == 0)) {
		return Classy_ExportCanvasHdc(canvas, tkwin, interp, objc, objv);
	} else {
		Tcl_AppendResult(interp, "bad option \"", string,"\": must be hdc, print or clipboard",		(char *) NULL);
		return TCL_ERROR;
	}
}


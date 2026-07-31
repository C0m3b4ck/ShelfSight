
/*
 * tkWinDialog.c --
 *
 *	Contains the Windows implementation of the common dialog boxes.
 *
 * Copyright (c) 1996-1997 Sun Microsystems, Inc.
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 * RCS: @(#) $Id: classyTkDialog.c 1.1 Thu, 12 Apr 2001 15:47:33 +0200 peter $
 *
 * Changes Peter De Rijk
 * This is the same as the Tk code for the open and save file dialogs,
 * but with some changes:
 * * added -selectmode (to allow multiple selections)
 * * Doesn't put up a diolog if the file already exists (I think this is up
 *   to the application; you sometimes need other choices then the default
 *   ones, eg. overwrite, append or cancel.
 * * allows input of none existant files (up to the application)
 */

#include "classyTk.h"
#include "tkWinInt.h"
#include "tkFileFilter.h"

#include <commdlg.h>    /* includes common dialog functionality */
#include <dlgs.h>       /* includes common dialog template defines */
#include <cderr.h>      /* includes the common dialog error codes */
#include <string.h>

typedef struct ThreadSpecificData { 
    int debugFlag;            /* Flags whether we should output debugging 
			       * information while displaying a builtin 
			       * dialog. */
    Tcl_Interp *debugInterp;  /* Interpreter to used for debugging. */
    UINT WM_LBSELCHANGED;     /* Holds a registered windows event used for
			       * communicating between the Directory
			       * Chooser dialog and its hook proc. */
} ThreadSpecificData;
static Tcl_ThreadDataKey dataKey;

/*
 * Definitions of procedures used only in this file.
 */

static int 		Classy_GetFileName(ClientData clientData, 
			    Tcl_Interp *interp, int objc, 
			    Tcl_Obj *CONST objv[], int isOpen);
static int 		Classy_MakeFilter(Tcl_Interp *interp, char *string, 
			    Tcl_DString *dsPtr);
static UINT APIENTRY	OFNHookProc(HWND hdlg, UINT uMsg, WPARAM wParam, 
			    LPARAM lParam);
static void		SetTkDialog(ClientData clientData);

/*
 *----------------------------------------------------------------------
 *
 * Classy_GetOpenFileCmd --
 *
 *	This procedure implements the "open file" dialog box for the
 *	Windows platform. See the user documentation for details on what
 *	it does.
 *
 * Results:
 *	See user documentation.
 *
 * Side effects:
 *	A dialog window is created the first this procedure is called.
 *
 *----------------------------------------------------------------------
 */

int
Classy_GetOpenFileCmd(clientData, interp, objc, objv)
    ClientData clientData;	/* Main window associated with interpreter. */
    Tcl_Interp *interp;		/* Current interpreter. */
    int objc;			/* Number of arguments. */
    Tcl_Obj *CONST objv[];	/* Argument objects. */
{
    return Classy_GetFileName(clientData, interp, objc, objv, 1);
}

/*
 *----------------------------------------------------------------------
 *
 * Tk_GetSaveFileCmd --
 *
 *	Same as Tk_GetOpenFileCmd but opens a "save file" dialog box
 *	instead
 *
 * Results:
 *	Same as Tk_GetOpenFileCmd.
 *
 * Side effects:
 *	Same as Tk_GetOpenFileCmd.
 *
 *----------------------------------------------------------------------
 */

int
Classy_GetSaveFileCmd(clientData, interp, objc, objv)
    ClientData clientData;	/* Main window associated with interpreter. */
    Tcl_Interp *interp;		/* Current interpreter. */
    int objc;			/* Number of arguments. */
    Tcl_Obj *CONST objv[];	/* Argument objects. */
{
    return Classy_GetFileName(clientData, interp, objc, objv, 0);
}

/*
 *----------------------------------------------------------------------
 *
 * Classy_GetFileName --
 *
 *	Calls GetOpenFileName() or GetSaveFileName().
 *
 * Results:
 *	See user documentation.
 *
 * Side effects:
 *	See user documentation.
 *
 *----------------------------------------------------------------------
 */

/* Classy patch */
#define SELECTMODE_BROWSE 1
#define SELECTMODE_MULTI 2
/* Classy patch */

static int 
Classy_GetFileName(clientData, interp, objc, objv, open)
    ClientData clientData;	/* Main window associated with interpreter. */
    Tcl_Interp *interp;		/* Current interpreter. */
    int objc;			/* Number of arguments. */
    Tcl_Obj *CONST objv[];	/* Argument objects. */
    int open;			/* 1 to call GetOpenFileName(), 0 to 
				 * call GetSaveFileName(). */
{
    OPENFILENAME ofn;
    TCHAR file[MAX_PATH], savePath[MAX_PATH];
    int result, winCode, oldMode, i;
    char *extension, *filter, *title;
    Tk_Window tkwin;
    Tcl_DString utfFilterString, utfDirString;
    Tcl_DString extString, filterString, dirString, titleString;
    ThreadSpecificData *tsdPtr = (ThreadSpecificData *) 
            Tcl_GetThreadData(&dataKey, sizeof(ThreadSpecificData));
/* Classy patch */
    int selectmode = SELECTMODE_BROWSE;
    static char *optionStrings[] = {
	"-defaultextension", "-filetypes", "-initialdir", "-initialfile",
	"-parent",	"-title",	"-selectmode", NULL
    };
    enum options {
	FILE_DEFAULT,	FILE_TYPES,	FILE_INITDIR,	FILE_INITFILE,
	FILE_PARENT,	FILE_TITLE, FILE_SELECTMODE
    };
/* Classy patch */
    result = TCL_ERROR;
    file[0] = '\0';

    /*
     * Parse the arguments.
     */

    extension = NULL;
    filter = NULL;
    Tcl_DStringInit(&utfFilterString);
    Tcl_DStringInit(&utfDirString);
    tkwin = (Tk_Window) clientData;
    title = NULL;
    for (i = 1; i < objc; i += 2) {
	int index;
	char *string;
	Tcl_Obj *optionPtr, *valuePtr;

	optionPtr = objv[i];
	valuePtr = objv[i + 1];

	if (Tcl_GetIndexFromObj(interp, optionPtr, optionStrings, "option", 
		0, &index) != TCL_OK) {
	    goto end;
	}
	if (i + 1 == objc) {
	    string = Tcl_GetStringFromObj(optionPtr, NULL);
	    Tcl_AppendResult(interp, "value for \"", string, "\" missing", 
		    (char *) NULL);
	    goto end;
	}

	string = Tcl_GetStringFromObj(valuePtr, NULL);
	switch ((enum options) index) {
	    case FILE_DEFAULT: {
		if (string[0] == '.') {
		    string++;
		}
		extension = string;
		break;
	    }
	    case FILE_TYPES: {
		Tcl_DStringFree(&utfFilterString);
		if (Classy_MakeFilter(interp, string, &utfFilterString) != TCL_OK) {
		    goto end;
		}
		filter = Tcl_DStringValue(&utfFilterString);
		break;
	    }
	    case FILE_INITDIR: {
		Tcl_DStringFree(&utfDirString);
		if (Tcl_TranslateFileName(interp, string, 
			&utfDirString) == NULL) {
		    goto end;
		}
		break;
	    }
	    case FILE_INITFILE: {
		Tcl_DString ds;

		if (Tcl_TranslateFileName(interp, string, &ds) == NULL) {
		    goto end;
		}
		Tcl_UtfToExternal(NULL, NULL, Tcl_DStringValue(&ds), 
			Tcl_DStringLength(&ds), 0, NULL, (char *) file, 
			sizeof(file), NULL, NULL, NULL);
		break;
	    }
	    case FILE_PARENT: {
		tkwin = Tk_NameToWindow(interp, string, tkwin);
		if (tkwin == NULL) {
		    goto end;
		}
		break;
	    }
	    case FILE_TITLE: {
		title = string;
		break;
	    }
/* Classy patch */
	    case FILE_SELECTMODE: {
		if (strcmp(string,"browse") == 0) {
			selectmode = SELECTMODE_BROWSE;
		} else {
			selectmode = SELECTMODE_MULTI;
		}
		break;
	    }
/* Classy patch */
	}
    }

    if (filter == NULL) {
	if (Classy_MakeFilter(interp, "", &utfFilterString) != TCL_OK) {
	    goto end;
	}
    }

    Tk_MakeWindowExist(tkwin);

    ofn.lStructSize		= sizeof(ofn);
    ofn.hwndOwner		= Tk_GetHWND(Tk_WindowId(tkwin));
    ofn.hInstance		= (HINSTANCE) GetWindowLong(ofn.hwndOwner, 
					GWL_HINSTANCE);
    ofn.lpstrFilter		= NULL;
    ofn.lpstrCustomFilter	= NULL;
    ofn.nMaxCustFilter		= 0;
    ofn.nFilterIndex		= 0;
    ofn.lpstrFile		= (LPTSTR) file;
    ofn.nMaxFile		= MAX_PATH;
    ofn.lpstrFileTitle		= NULL;
    ofn.nMaxFileTitle		= 0;
    ofn.lpstrInitialDir		= NULL;
    ofn.lpstrTitle		= NULL;
    ofn.Flags			= OFN_HIDEREADONLY | OFN_PATHMUSTEXIST;
    if (selectmode == SELECTMODE_MULTI) {
	    ofn.Flags			= ofn.Flags | OFN_ALLOWMULTISELECT;
    }
    ofn.nFileOffset		= 0;
    ofn.nFileExtension		= 0;
    ofn.lpstrDefExt		= NULL;
    ofn.lpfnHook		= OFNHookProc;
    ofn.lCustData		= (LPARAM) interp;
    ofn.lpTemplateName		= NULL;

    if (LOBYTE(LOWORD(GetVersion())) >= 4) {
	/*
	 * Use the "explorer" style file selection box on platforms that
	 * support it (Win95 and NT4.0 both have a major version number
	 * of 4).
	 */

	ofn.Flags |= OFN_EXPLORER;
    }

/* Classy patch deleted this
    if (open != 0) {
	ofn.Flags |= OFN_FILEMUSTEXIST;
    } else {
	ofn.Flags |= OFN_OVERWRITEPROMPT;
    }
*/

    if (tsdPtr->debugFlag != 0) {
	ofn.Flags |= OFN_ENABLEHOOK;
    }

    if (extension != NULL) {
	Tcl_UtfToExternalDString(NULL, extension, -1, &extString);
	ofn.lpstrDefExt = (LPTSTR) Tcl_DStringValue(&extString);
    }
    Tcl_UtfToExternalDString(NULL, Tcl_DStringValue(&utfFilterString),
	    Tcl_DStringLength(&utfFilterString), &filterString);
    ofn.lpstrFilter = (LPTSTR) Tcl_DStringValue(&filterString);

    if (Tcl_DStringValue(&utfDirString)[0] != '\0') {
	Tcl_UtfToExternalDString(NULL, Tcl_DStringValue(&utfDirString),
		Tcl_DStringLength(&utfDirString), &dirString);
        ofn.lpstrInitialDir = (LPTSTR) Tcl_DStringValue(&dirString);
    }
    if (title != NULL) {
	Tcl_UtfToExternalDString(NULL, title, -1, &titleString);
	ofn.lpstrTitle = (LPTSTR) Tcl_DStringValue(&titleString);
    }

    /*
     * Popup the dialog.  
     */

    GetCurrentDirectory(MAX_PATH, savePath);
    oldMode = Tcl_SetServiceMode(TCL_SERVICE_ALL);
    if (open != 0) {
	winCode = GetOpenFileName(&ofn);
    } else {
	winCode = GetSaveFileName(&ofn);
    }
    Tcl_SetServiceMode(oldMode);
    SetCurrentDirectory(savePath);

    /*
     * Clear the interp result since anything may have happened during the
     * modal loop.
     */

    Tcl_ResetResult(interp);

    /*
     * Process the results.
     */

	if (winCode != 0) {
		char *p,*cpos;
		Tcl_DString ds;
/* Classy patch */
		if ((ofn.Flags & OFN_EXPLORER)&&(ofn.Flags & OFN_ALLOWMULTISELECT)) {
			cpos=ofn.lpstrFile;
			while (1) {
				Tcl_ExternalToUtfDString(NULL, (char *) cpos, -1, &ds);
				for (p = Tcl_DStringValue(&ds); *p != '\0'; p++) {
					/*
					 * Change the pathname to the Tcl "normalized" pathname, where
					 * back slashes are used instead of forward slashes
					 */
					if (*p == '\\') {*p = '/';}
				}
				Tcl_AppendElement(interp, Tcl_DStringValue(&ds));
				Tcl_DStringFree(&ds);
				while (*cpos != '\0') {cpos++;}
				cpos++;
				if (*cpos == '\0') break;
			}
		} else {
/* Classy patch end*/
			Tcl_ExternalToUtfDString(NULL, (char *) ofn.lpstrFile, -1, &ds);
			for (p = Tcl_DStringValue(&ds); *p != '\0'; p++) {
				/*
				 * Change the pathname to the Tcl "normalized" pathname, where
				 * back slashes are used instead of forward slashes
				 */
				if (*p == '\\') {*p = '/';}
			}
			Tcl_AppendResult(interp, Tcl_DStringValue(&ds), NULL);
			Tcl_DStringFree(&ds);
/* Classy patch */
		}
/* Classy patch end*/
	}
	if (ofn.lpstrTitle != NULL) {
		Tcl_DStringFree(&titleString);
	}
	if (ofn.lpstrInitialDir != NULL) {
		Tcl_DStringFree(&dirString);
	}
	Tcl_DStringFree(&filterString);
	if (ofn.lpstrDefExt != NULL) {
		Tcl_DStringFree(&extString);
	}
	result = TCL_OK;

    end:
    Tcl_DStringFree(&utfDirString);
    Tcl_DStringFree(&utfFilterString);

    return result;
}

/*
 *-------------------------------------------------------------------------
 *
 * OFNHookProc --
 *
 *	Hook procedure called only if debugging is turned on.  Sets
 *	the "tk_dialog" variable when the dialog is ready to receive
 *	messages.
 *
 * Results:
 *	Returns 0 to allow default processing of messages to occur.
 *
 * Side effects:
 *	None.
 *
 *-------------------------------------------------------------------------
 */

static UINT APIENTRY 
OFNHookProc(
    HWND hdlg,		// handle to child dialog window
    UINT uMsg,		// message identifier
    WPARAM wParam,	// message parameter
    LPARAM lParam) 	// message parameter
{
    ThreadSpecificData *tsdPtr = (ThreadSpecificData *) 
            Tcl_GetThreadData(&dataKey, sizeof(ThreadSpecificData));
    OPENFILENAME *ofnPtr;

    if (uMsg == WM_INITDIALOG) {
	SetWindowLong(hdlg, GWL_USERDATA, lParam);
    } else if (uMsg == WM_WINDOWPOSCHANGED) {
	/*
	 * This message is delivered at the right time to both 
	 * old-style and explorer-style hook procs to enable Tk
	 * to set the debug information.  Unhooks itself so it 
	 * won't set the debug information every time it gets a 
	 * WM_WINDOWPOSCHANGED message.
	 */

        ofnPtr = (OPENFILENAME *) GetWindowLong(hdlg, GWL_USERDATA);
	if (ofnPtr != NULL) {
	    if (ofnPtr->Flags & OFN_EXPLORER) {
		hdlg = GetParent(hdlg);
	    }
	    tsdPtr->debugInterp = (Tcl_Interp *) ofnPtr->lCustData;
	    Tcl_DoWhenIdle(SetTkDialog, (ClientData) hdlg);
	    SetWindowLong(hdlg, GWL_USERDATA, (LPARAM) NULL);
	}
    }
    return 0;
}

/*
 *----------------------------------------------------------------------
 *
 * Classy_MakeFilter --
 *
 *	Allocate a buffer to store the filters in a format understood by
 *	Windows
 *
 * Results:
 *	A standard TCL return value.
 *
 * Side effects:
 *	ofnPtr->lpstrFilter is modified.
 *
 *----------------------------------------------------------------------
 */
static int 
Classy_MakeFilter(interp, string, dsPtr) 
    Tcl_Interp *interp;		/* Current interpreter. */
    char *string;		/* String value of the -filetypes option */
    Tcl_DString *dsPtr;		/* Filled with windows filter string. */
{
    char *filterStr;
    char *p;
    int pass;
    FileFilterList flist;
    FileFilter *filterPtr;

    TkInitFileFilters(&flist);
    if (TkGetFileFilters(interp, &flist, string, 1) != TCL_OK) {
	return TCL_ERROR;
    }

    if (flist.filters == NULL) {
	/*
	 * Use "All Files (*.*) as the default filter if none is specified
	 */
	char *defaultFilter = "All Files (*.*)";

	p = filterStr = (char*)ckalloc(30 * sizeof(char));

	strcpy(p, defaultFilter);
	p+= strlen(defaultFilter);

	*p++ = '\0';
	*p++ = '*';
	*p++ = '.';
	*p++ = '*';
	*p++ = '\0';
	*p++ = '\0';
	*p = '\0';

    } else {
	/* We format the filetype into a string understood by Windows:
	 * {"Text Documents" {.doc .txt} {TEXT}} becomes
	 * "Text Documents (*.doc,*.txt)\0*.doc;*.txt\0"
	 *
	 * See the Windows OPENFILENAME manual page for details on the filter
	 * string format.
	 */

	/*
	 * Since we may only add asterisks (*) to the filter, we need at most
	 * twice the size of the string to format the filter
	 */
	filterStr = ckalloc(strlen(string) * 3);

	for (filterPtr = flist.filters, p = filterStr; filterPtr;
	        filterPtr = filterPtr->next) {
	    char *sep;
	    FileFilterClause *clausePtr;

	    /*
	     *  First, put in the name of the file type
	     */
	    strcpy(p, filterPtr->name);
	    p+= strlen(filterPtr->name);
	    *p++ = ' ';
	    *p++ = '(';

	    for (pass = 1; pass <= 2; pass++) {
		/*
		 * In the first pass, we format the extensions in the 
		 * name field. In the second pass, we format the extensions in
		 * the filter pattern field
		 */
		sep = "";
		for (clausePtr=filterPtr->clauses;clausePtr;
		         clausePtr=clausePtr->next) {
		    GlobPattern *globPtr;
		

		    for (globPtr=clausePtr->patterns; globPtr;
			    globPtr=globPtr->next) {
			strcpy(p, sep);
			p+= strlen(sep);
			strcpy(p, globPtr->pattern);
			p+= strlen(globPtr->pattern);

			if (pass==1) {
			    sep = ",";
			} else {
			    sep = ";";
			}
		    }
		}
		if (pass == 1) {
		    if (pass == 1) {
			*p ++ = ')';
		    }
		}
		*p ++ = '\0';
	    }
	}

	/*
	 * Windows requires the filter string to be ended by two NULL
	 * characters.
	 */
	*p++ = '\0';
	*p = '\0';
    }

    Tcl_DStringAppend(dsPtr, filterStr, p - filterStr);
    ckfree((char *) filterStr);

    TkFreeFileFilters(&flist);
    return TCL_OK;
}

static void 
SetTkDialog(ClientData clientData)
{
    ThreadSpecificData *tsdPtr = (ThreadSpecificData *) 
            Tcl_GetThreadData(&dataKey, sizeof(ThreadSpecificData));
    char buf[32];
    HWND hwnd;

    hwnd = (HWND) clientData;

    sprintf(buf, "0x%08x", (int)hwnd);
    Tcl_SetVar(tsdPtr->debugInterp, "tk_dialog", buf, TCL_GLOBAL_ONLY);
}

int 
Classy_TaskbarPosCmd(clientData, interp, objc, objv)
    ClientData clientData;	/* Main window associated with interpreter. */
    Tcl_Interp *interp;		/* Current interpreter. */
    int objc;			/* Number of arguments. */
    Tcl_Obj *CONST objv[];	/* Argument objects. */
{
	Tcl_Obj *result = NULL;
	HWND hwndTaskBar;
	RECT rect;
	hwndTaskBar = FindWindow( "Shell_TrayWnd", 0 ); 
	if (hwndTaskBar == NULL) {
		Tcl_AppendResult(interp, "", 0);
	}
	if (!GetWindowRect( hwndTaskBar, &rect )) {
		Tcl_AppendResult(interp, "", 0);
	}
	result = Tcl_GetObjResult(interp);
	Tcl_ListObjAppendElement(interp,result,Tcl_NewIntObj(rect.left));
	Tcl_ListObjAppendElement(interp,result,Tcl_NewIntObj(rect.top));
	Tcl_ListObjAppendElement(interp,result,Tcl_NewIntObj(rect.right));
	Tcl_ListObjAppendElement(interp,result,Tcl_NewIntObj(rect.bottom));
	return TCL_OK;
}

/* 
 * tclCmdIL.c --
 *
 * adaptation from code in the original Tcl8.0 release
 * Copyright (c) 1987-1993 The Regents of the University of California.
 * Copyright (c) 1993-1997 Lucent Technologies.
 * Copyright (c) 1994-1997 Sun Microsystems, Inc.
 * -reflist option and building into Extral by Peter De Rijk
 *
 */

/*
 #include "tclInt.h"
 #include "tclPort.h"
*/
#define UCHAR(c) ((unsigned char) (c))
#include <ctype.h>
#include <string.h>
#include "tcl.h"

/*
 * During execution of the "lsort" command, structures of the following
 * type are used to arrange the objects being sorted into a collection
 * of linked lists.
 */

typedef struct SortElement {
    Tcl_Obj *refobjPtr;			/* ref Object for sort. */
    Tcl_Obj *objPtr;			/* Object being sorted. */
    struct SortElement *nextPtr;        /* Next element in the list, or
					 * NULL for end of list. */
} SortElement;

/*
 * The "lsort" command needs to pass certain information down to the
 * function that compares two list elements, and the comparison function
 * needs to pass success or failure information back up to the top-level
 * "lsort" command.  The following structure is used to pass this
 * information.
 */

typedef struct SortInfo {
    int isIncreasing;		/* Nonzero means sort in increasing order. */
    int sortMode;		/* The sort mode.  One of SORTMODE_*
				 * values defined below */
    Tcl_DString compareCmd;	/* The Tcl comparison command when sortMode
				 * is SORTMODE_COMMAND.  Pre-initialized to
				 * hold base of command.*/
    int index;			/* If the -index option was specified, this
				 * holds the index of the list element
				 * to extract for comparison.  If -index
				 * wasn't specified, this is -1. */
    Tcl_Interp *interp;		/* The interpreter in which the sortis
				 * being done. */
    int resultCode;		/* Completion code for the lsort command.
				 * If an error occurs during the sort this
				 * is changed from TCL_OK to  TCL_ERROR. */
} SortInfo;

/*
 * The "sortMode" field of the SortInfo structure can take on any of the
 * following values.
 */

#define SORTMODE_ASCII      0
#define SORTMODE_INTEGER    1
#define SORTMODE_REAL       2
#define SORTMODE_COMMAND    3
#define SORTMODE_DICTIONARY 4
#define SORTMODE_NATURAL 5

/*
 * Forward declarations for procedures defined in this file:
 */

static int		DictionaryCompare _ANSI_ARGS_((char *left,
			    char *right));
static SortElement *    MergeSort _ANSI_ARGS_((SortElement *headPt,
			    SortInfo *infoPtr));
static SortElement *    MergeLists _ANSI_ARGS_((SortElement *leftPtr,
			    SortElement *rightPtr, SortInfo *infoPtr));
static int		SortCompare _ANSI_ARGS_((Tcl_Obj *firstPtr,
			    Tcl_Obj *second, SortInfo *infoPtr));

/*
 *----------------------------------------------------------------------
 *
 * function from tclUtil.c that is not exported, but needed here.
 *
 *----------------------------------------------------------------------
 */
/*
 *----------------------------------------------------------------------
 *
 * Extral_TclGetIntForIndex --
 *
 *	This procedure returns an integer corresponding to the list index
 *	held in a Tcl object. The Tcl object's value is expected to be
 *	either an integer or a string of the form "end([+-]integer)?". 
 *
 * Results:
 *	The return value is normally TCL_OK, which means that the index was
 *	successfully stored into the location referenced by "indexPtr".  If
 *	the Tcl object referenced by "objPtr" has the value "end", the
 *	value stored is "endValue". If "objPtr"s values is not of the form
 *	"end([+-]integer)?" and
 *	can not be converted to an integer, TCL_ERROR is returned and, if
 *	"interp" is non-NULL, an error message is left in the interpreter's
 *	result object.
 *
 * Side effects:
 *	The object referenced by "objPtr" might be converted to an
 *	integer object.
 *
 *----------------------------------------------------------------------
 */

/*
 *----------------------------------------------------------------------
 *
 * Extral_TclCheckBadOctal --
 *
 *	This procedure checks for a bad octal value and appends a
 *	meaningful error to the interp's result.
 *
 * Results:
 *	1 if the argument was a bad octal, else 0.
 *
 * Side effects:
 *	The interpreter's result is modified.
 *
 *----------------------------------------------------------------------
 */

int
Extral_TclCheckBadOctal(interp, value)
    Tcl_Interp *interp;		/* Interpreter to use for error reporting. 
				 * If NULL, then no error message is left
				 * after errors. */
    char *value;		/* String to check. */
{
    register char *p = value;

    /*
     * A frequent mistake is invalid octal values due to an unwanted
     * leading zero. Try to generate a meaningful error message.
     */

    while (isspace(UCHAR(*p))) {	/* INTL: ISO space. */
	p++;
    }
    if (*p == '+' || *p == '-') {
	p++;
    }
    if (*p == '0') {
	while (isdigit(UCHAR(*p))) {	/* INTL: digit. */
	    p++;
	}
	while (isspace(UCHAR(*p))) {	/* INTL: ISO space. */
	    p++;
	}
	if (*p == '\0') {
	    /* Reached end of string */
	    if (interp != NULL) {
		Tcl_AppendResult(interp, " (looks like invalid octal number)",
			(char *) NULL);
	    }
	    return 1;
	}
    }
    return 0;
}

int
Extral_TclGetIntForIndex(interp, objPtr, endValue, indexPtr)
    Tcl_Interp *interp;		/* Interpreter to use for error reporting. 
				 * If NULL, then no error message is left
				 * after errors. */
    Tcl_Obj *objPtr;		/* Points to an object containing either
				 * "end" or an integer. */
    int endValue;		/* The value to be stored at "indexPtr" if
				 * "objPtr" holds "end". */
    int *indexPtr;		/* Location filled in with an integer
				 * representing an index. */
{
    char *bytes;
    int length, offset;

    if (objPtr->typePtr == Tcl_GetObjType("int")) {
	*indexPtr = (int)objPtr->internalRep.longValue;
	return TCL_OK;
    }

    bytes = Tcl_GetStringFromObj(objPtr, &length);

    if ((*bytes != 'e') || (strncmp(bytes, "end",
	    (size_t)((length > 3) ? 3 : length)) != 0)) {
	if (Tcl_GetIntFromObj(NULL, objPtr, &offset) != TCL_OK) {
	    goto intforindex_error;
	}
	*indexPtr = offset;
	return TCL_OK;
    }

    if (length <= 3) {
	*indexPtr = endValue;
    } else if (bytes[3] == '-') {
	/*
	 * This is our limited string expression evaluator
	 */
	if (Tcl_GetInt(interp, bytes+3, &offset) != TCL_OK) {
	    return TCL_ERROR;
	}
	*indexPtr = endValue + offset;
    } else {
		intforindex_error:
		if (interp != NULL) {
		    Tcl_AppendStringsToObj(Tcl_GetObjResult(interp),
			    "bad index \"", bytes,
			    "\": must be integer or end?-integer?", (char *) NULL);
		    Extral_TclCheckBadOctal(interp, bytes);
		}
		return TCL_ERROR;
    }
    return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * Tcl_LsortObjCmd --
 *
 *	This procedure is invoked to process the "lsort" Tcl command.
 *	See the user documentation for details on what it does.
 *
 * Results:
 *	A standard Tcl result.
 *
 * Side effects:
 *	See the user documentation.
 *
 *----------------------------------------------------------------------
 */

int
ExtraL_SSortObjCmd(clientData, interp, objc, objv)
    ClientData clientData;	/* Not used. */
    Tcl_Interp *interp;		/* Current interpreter. */
    int objc;			/* Number of arguments. */
    Tcl_Obj *CONST objv[];	/* Argument values. */
{
    int i, index, dummy;
    Tcl_Obj *resultPtr;
	Tcl_Obj *reflist = NULL, **reflistObjv;
	int reflistObjc;
    int length;
    Tcl_Obj *cmdPtr, **listObjPtrs;
    SortElement *elementArray;
    SortElement *elementPtr;        
    SortInfo sortInfo;                  /* Information about this sort that
                                         * needs to be passed to the 
                                         * comparison function */
    static CONST char *switches[] =
	    {"-ascii", "-command", "-decreasing", "-dictionary", "-natural",
	    "-increasing", "-index", "-integer", "-real", "-reflist", (char *) NULL};

    resultPtr = Tcl_GetObjResult(interp);
    if (objc < 2) {
	Tcl_WrongNumArgs(interp, 1, objv, "?options? list");
	return TCL_ERROR;
    }

    /*
     * Parse arguments to set up the mode for the sort.
     */

    sortInfo.isIncreasing = 1;
    sortInfo.sortMode = SORTMODE_ASCII;
    sortInfo.index = -1;
    sortInfo.interp = interp;
    sortInfo.resultCode = TCL_OK;
    cmdPtr = NULL;
    for (i = 1; i < objc-1; i++) {
		if (Tcl_GetIndexFromObj(interp, objv[i], switches, "option", 0, &index)
			!= TCL_OK) {
		    return TCL_ERROR;
		}
		switch (index) {
		    case 0:			/* -ascii */
			sortInfo.sortMode = SORTMODE_ASCII;
			break;
		    case 1:			/* -command */
			if (i == (objc-2)) {
			    Tcl_AppendToObj(resultPtr,
				    "\"-command\" option must be followed by comparison command",
				    -1);
			    return TCL_ERROR;
			}
			sortInfo.sortMode = SORTMODE_COMMAND;
			cmdPtr = objv[i+1];
			i++;
			break;
		    case 2:			/* -decreasing */
			sortInfo.isIncreasing = 0;
			break;
		    case 3:			/* -dictionary */
			sortInfo.sortMode = SORTMODE_DICTIONARY;
			break;
		    case 4:			/* -dictionary */
			sortInfo.sortMode = SORTMODE_NATURAL;
			break;
		    case 5:			/* -increasing */
			sortInfo.isIncreasing = 1;
			break;
		    case 6:			/* -index */
			if (i == (objc-2)) {
			    Tcl_AppendToObj(resultPtr,
				    "\"-index\" option must be followed by list index",
				    -1);
			    return TCL_ERROR;
			}
			if (Extral_TclGetIntForIndex(interp, objv[i+1], -2, &sortInfo.index)
				!= TCL_OK) {
			    return TCL_ERROR;
			}
			cmdPtr = objv[i+1];
			i++;
			break;
		    case 7:			/* -integer */
			sortInfo.sortMode = SORTMODE_INTEGER;
			break;
		    case 8:			/* -real */
			sortInfo.sortMode = SORTMODE_REAL;
		    case 9:			/* -reflist */
			if (i == (objc-2)) {
			    Tcl_AppendToObj(resultPtr,
				    "\"-reflist\" option must be followed by the reflist",
				    -1);
			    return TCL_ERROR;
			}
			reflist = objv[i+1];
			i++;
			break;
		}
    }
    if (sortInfo.sortMode == SORTMODE_COMMAND) {
	Tcl_DStringInit(&sortInfo.compareCmd);
	Tcl_DStringAppend(&sortInfo.compareCmd,
		Tcl_GetStringFromObj(cmdPtr, &dummy), -1);
    }

    sortInfo.resultCode = Tcl_ListObjGetElements(interp, objv[objc-1],
	    &length, &listObjPtrs);
    if (sortInfo.resultCode != TCL_OK) {
	goto done;
    }
    if (length <= 0) {
        return TCL_OK;
    }
	if (reflist!=NULL) {
		if (Tcl_ListObjGetElements(interp, reflist, &reflistObjc, &reflistObjv) != TCL_OK) {
			sortInfo.resultCode = TCL_ERROR;
			goto done;
		}
	}
    elementArray = (SortElement *) Tcl_Alloc(length * sizeof(SortElement));
    for (i=0; i < length; i++){
		if (reflist!=NULL) {
			elementArray[i].refobjPtr = reflistObjv[i];
		} else {
			elementArray[i].refobjPtr = listObjPtrs[i];
		}
		elementArray[i].objPtr = listObjPtrs[i];
		elementArray[i].nextPtr = &elementArray[i+1];
    }
    elementArray[length-1].nextPtr = NULL;
    elementPtr = MergeSort(elementArray, &sortInfo);
    if (sortInfo.resultCode == TCL_OK) {
		/*
		 * Note: must clear the interpreter's result object: it could
		 * have been set by the -command script.
		 */
	
		Tcl_ResetResult(interp);
		resultPtr = Tcl_GetObjResult(interp);
		for (; elementPtr != NULL; elementPtr = elementPtr->nextPtr){
		    Tcl_ListObjAppendElement(interp, resultPtr, elementPtr->objPtr);
		}
    }
    Tcl_Free((char*) elementArray);

    done:
    if (sortInfo.sortMode == SORTMODE_COMMAND) {
		Tcl_DStringFree(&sortInfo.compareCmd);
    }
    return sortInfo.resultCode;
}

/*
 *----------------------------------------------------------------------
 *
 * MergeSort -
 *
 *	This procedure sorts a linked list of SortElement structures
 *	use the merge-sort algorithm.
 *
 * Results:
 *      A pointer to the head of the list after sorting is returned.
 *
 * Side effects:
 *	None, unless a user-defined comparison command does something
 *	weird.
 *
 *----------------------------------------------------------------------
 */

static SortElement *
MergeSort(headPtr, infoPtr)
    SortElement *headPtr;               /* First element on the list */
    SortInfo *infoPtr;                  /* Information needed by the
                                         * comparison operator */
{
    /*
     * The subList array below holds pointers to temporary lists built
     * during the merge sort.  Element i of the array holds a list of
     * length 2**i.
     */

#   define NUM_LISTS 30
    SortElement *subList[NUM_LISTS];
    SortElement *elementPtr;
    int i;

    for(i = 0; i < NUM_LISTS; i++){
        subList[i] = NULL;
    }
    while (headPtr != NULL) {
	elementPtr = headPtr;
	headPtr = headPtr->nextPtr;
	elementPtr->nextPtr = 0;
	for (i = 0; (i < NUM_LISTS) && (subList[i] != NULL); i++){
	    elementPtr = MergeLists(subList[i], elementPtr, infoPtr);
	    subList[i] = NULL;
	}
	if (i >= NUM_LISTS) {
	    i = NUM_LISTS-1;
	}
	subList[i] = elementPtr;
    }
    elementPtr = NULL;
    for (i = 0; i < NUM_LISTS; i++){
        elementPtr = MergeLists(subList[i], elementPtr, infoPtr);
    }
    return elementPtr;
}

/*
 *----------------------------------------------------------------------
 *
 * MergeLists -
 *
 *	This procedure combines two sorted lists of SortElement structures
 *	into a single sorted list.
 *
 * Results:
 *      The unified list of SortElement structures.
 *
 * Side effects:
 *	None, unless a user-defined comparison command does something
 *	weird.
 *
 *----------------------------------------------------------------------
 */

static SortElement *
MergeLists(leftPtr, rightPtr, infoPtr)
    SortElement *leftPtr;               /* First list to be merged; may be
					 * NULL. */
    SortElement *rightPtr;              /* Second list to be merged; may be
					 * NULL. */
    SortInfo *infoPtr;                  /* Information needed by the
                                         * comparison operator. */
{
    SortElement *headPtr;
    SortElement *tailPtr;

    if (leftPtr == NULL) {
        return rightPtr;
    }
    if (rightPtr == NULL) {
        return leftPtr;
    }
    if (SortCompare(leftPtr->refobjPtr, rightPtr->refobjPtr, infoPtr) > 0) {
		tailPtr = rightPtr;
		rightPtr = rightPtr->nextPtr;
    } else {
		tailPtr = leftPtr;
		leftPtr = leftPtr->nextPtr;
    }
    headPtr = tailPtr;
    while ((leftPtr != NULL) && (rightPtr != NULL)) {
		if (SortCompare(leftPtr->refobjPtr, rightPtr->refobjPtr, infoPtr) > 0) {
		    tailPtr->nextPtr = rightPtr;
		    tailPtr = rightPtr;
		    rightPtr = rightPtr->nextPtr;
		} else {
		    tailPtr->nextPtr = leftPtr;
		    tailPtr = leftPtr;
		    leftPtr = leftPtr->nextPtr;
		}
    }
    if (leftPtr != NULL) {
       tailPtr->nextPtr = leftPtr;
    } else {
       tailPtr->nextPtr = rightPtr;
    }
    return headPtr;
}

/*
 *----------------------------------------------------------------------
 *
 * SortCompare --
 *
 *	This procedure is invoked by MergeLists to determine the proper
 *	ordering between two elements.
 *
 * Results:
 *      A negative results means the the first element comes before the
 *      second, and a positive results means that the second element
 *      should come first.  A result of zero means the two elements
 *      are equal and it doesn't matter which comes first.
 *
 * Side effects:
 *	None, unless a user-defined comparison command does something
 *	weird.
 *
 *----------------------------------------------------------------------
 */
int naturalcompare (char const *a, char const *b,int alen,int blen);

static int
SortCompare(objPtr1, objPtr2, infoPtr)
    Tcl_Obj *objPtr1, *objPtr2;		/* Values to be compared. */
    SortInfo *infoPtr;                  /* Information passed from the
                                         * top-level "lsort" command */
{
    int order, dummy, listLen, index;
    Tcl_Obj *objPtr;
    char buffer[30];

    order = 0;
    if (infoPtr->resultCode != TCL_OK) {
	/*
	 * Once an error has occurred, skip any future comparisons
	 * so as to preserve the error message in sortInterp->result.
	 */

	return order;
    }
    if (infoPtr->index != -1) {
	/*
	 * The "-index" option was specified.  Treat each object as a
	 * list, extract the requested element from each list, and
	 * compare the elements, not the lists.  The special index "end"
	 * is signaled here with a large negative index.
	 */

	if (Tcl_ListObjLength(infoPtr->interp, objPtr1, &listLen) != TCL_OK) {
	    infoPtr->resultCode = TCL_ERROR;
	    return order;
	}
	if (infoPtr->index < -1) {
	    index = listLen - 1;
	} else {
	    index = infoPtr->index;
	}

	if (Tcl_ListObjIndex(infoPtr->interp, objPtr1, index, &objPtr)
		!= TCL_OK) {
	    infoPtr->resultCode = TCL_ERROR;
	    return order;
	}
	if (objPtr == NULL) {
	    objPtr = objPtr1;
	    missingElement:
	    sprintf(buffer, "%d", infoPtr->index);
	    Tcl_AppendStringsToObj(Tcl_GetObjResult(infoPtr->interp),
			"element ", buffer, " missing from sublist \"",
			Tcl_GetStringFromObj(objPtr, (int *) NULL),
			"\"", (char *) NULL);
	    infoPtr->resultCode = TCL_ERROR;
	    return order;
	}
	objPtr1 = objPtr;

	if (Tcl_ListObjLength(infoPtr->interp, objPtr2, &listLen) != TCL_OK) {
	    infoPtr->resultCode = TCL_ERROR;
	    return order;
	}
	if (infoPtr->index < -1) {
	    index = listLen - 1;
	} else {
	    index = infoPtr->index;
	}

	if (Tcl_ListObjIndex(infoPtr->interp, objPtr2, index, &objPtr)
		!= TCL_OK) {
	    infoPtr->resultCode = TCL_ERROR;
	    return order;
	}
	if (objPtr == NULL) {
	    objPtr = objPtr2;
	    goto missingElement;
	}
	objPtr2 = objPtr;
    }
    if (infoPtr->sortMode == SORTMODE_ASCII) {
	order = strcmp(Tcl_GetStringFromObj(objPtr1, &dummy),
		Tcl_GetStringFromObj(objPtr2, &dummy));
    } else if (infoPtr->sortMode == SORTMODE_DICTIONARY) {
	order = DictionaryCompare(
		Tcl_GetStringFromObj(objPtr1, &dummy),
		Tcl_GetStringFromObj(objPtr2, &dummy));
    } else if (infoPtr->sortMode == SORTMODE_NATURAL) {
	char *a,*b;
	int alen,blen;
	a = Tcl_GetStringFromObj(objPtr1, &alen);
	b = Tcl_GetStringFromObj(objPtr2, &blen);
	order = naturalcompare(a,b,alen,blen);
    } else if (infoPtr->sortMode == SORTMODE_INTEGER) {
	int a, b;

	if ((Tcl_GetIntFromObj(infoPtr->interp, objPtr1, &a) != TCL_OK)
		|| (Tcl_GetIntFromObj(infoPtr->interp, objPtr2, &b)
		!= TCL_OK)) {
	    infoPtr->resultCode = TCL_ERROR;
	    return order;
	}
	if (a > b) {
	    order = 1;
	} else if (b > a) {
	    order = -1;
	}
    } else if (infoPtr->sortMode == SORTMODE_REAL) {
	double a, b;

	if ((Tcl_GetDoubleFromObj(infoPtr->interp, objPtr1, &a) != TCL_OK)
	      || (Tcl_GetDoubleFromObj(infoPtr->interp, objPtr2, &b)
		      != TCL_OK)) {
	    infoPtr->resultCode = TCL_ERROR;
	    return order;
	}
	if (a > b) {
	    order = 1;
	} else if (b > a) {
	    order = -1;
	}
    } else {
	int oldLength;

	/*
	 * Generate and evaluate a command to determine which string comes
	 * first.
	 */

	oldLength = Tcl_DStringLength(&infoPtr->compareCmd);
	Tcl_DStringAppendElement(&infoPtr->compareCmd,
		Tcl_GetStringFromObj(objPtr1, &dummy));
	Tcl_DStringAppendElement(&infoPtr->compareCmd,
		Tcl_GetStringFromObj(objPtr2, &dummy));
	infoPtr->resultCode = Tcl_Eval(infoPtr->interp, 
		Tcl_DStringValue(&infoPtr->compareCmd));
	Tcl_DStringTrunc(&infoPtr->compareCmd, oldLength);
	if (infoPtr->resultCode != TCL_OK) {
	    Tcl_AddErrorInfo(infoPtr->interp,
		    "\n    (-compare command)");
	    return order;
	}

	/*
	 * Parse the result of the command.
	 */

	if (Tcl_GetIntFromObj(infoPtr->interp,
		Tcl_GetObjResult(infoPtr->interp), &order) != TCL_OK) {
	    Tcl_ResetResult(infoPtr->interp);
	    Tcl_AppendToObj(Tcl_GetObjResult(infoPtr->interp),
		    "-compare command returned non-numeric result", -1);
	    infoPtr->resultCode = TCL_ERROR;
	    return order;
	}
    }
    if (!infoPtr->isIncreasing) {
	order = -order;
    }
    return order;
}

/*
 *----------------------------------------------------------------------
 *
 * DictionaryCompare
 *
 *	This function compares two strings as if they were being used in
 *	an index or card catalog.  The case of alphabetic characters is
 *	ignored, except to break ties.  Thus "B" comes before "b" but
 *	after "a".  Also, integers embedded in the strings compare in
 *	numerical order.  In other words, "x10y" comes after "x9y", not
 *      before it as it would when using strcmp().
 *
 * Results:
 *      A negative result means that the first element comes before the
 *      second, and a positive result means that the second element
 *      should come first.  A result of zero means the two elements
 *      are equal and it doesn't matter which comes first.
 *
 * Side effects:
 *	None.
 *
 *----------------------------------------------------------------------
 */

static int
DictionaryCompare(left, right)
    char *left, *right;          /* The strings to compare */
{
    int diff, zeros;
    int secondaryDiff = 0;

    while (1) {
	if (isdigit(UCHAR(*right)) && isdigit(UCHAR(*left))) {
	    /*
	     * There are decimal numbers embedded in the two
	     * strings.  Compare them as numbers, rather than
	     * strings.  If one number has more leading zeros than
	     * the other, the number with more leading zeros sorts
	     * later, but only as a secondary choice.
	     */

	    zeros = 0;
	    while ((*right == '0') && (*(right + 1) != '\0')) {
		right++;
		zeros--;
	    }
	    while ((*left == '0') && (*(left + 1) != '\0')) {
		left++;
		zeros++;
	    }
	    if (secondaryDiff == 0) {
		secondaryDiff = zeros;
	    }

	    /*
	     * The code below compares the numbers in the two
	     * strings without ever converting them to integers.  It
	     * does this by first comparing the lengths of the
	     * numbers and then comparing the digit values.
	     */

	    diff = 0;
	    while (1) {
		if (diff == 0) {
		    diff = *left - *right;
		}
		right++;
		left++;
		if (!isdigit(UCHAR(*right))) {
		    if (isdigit(UCHAR(*left))) {
			return 1;
		    } else {
			/*
			 * The two numbers have the same length. See
			 * if their values are different.
			 */

			if (diff != 0) {
			    return diff;
			}
			break;
		    }
		} else if (!isdigit(UCHAR(*left))) {
		    return -1;
		}
	    }
	    continue;
	}
        diff = *left - *right;
        if (diff) {
            if (isupper(UCHAR(*left)) && islower(UCHAR(*right))) {
                diff = tolower(*left) - *right;
                if (diff) {
		    return diff;
                } else if (secondaryDiff == 0) {
		    secondaryDiff = -1;
                }
            } else if (isupper(UCHAR(*right)) && islower(UCHAR(*left))) {
                diff = *left - tolower(UCHAR(*right));
                if (diff) {
		    return diff;
                } else if (secondaryDiff == 0) {
		    secondaryDiff = 1;
                }
            } else {
                return diff;
            }
        }
        if (*left == 0) {
	    break;
	}
        left++;
        right++;
    }
    if (diff == 0) {
	diff = secondaryDiff;
    }
    return diff;
}

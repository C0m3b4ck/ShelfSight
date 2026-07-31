/*	
 *	 File:    extral.c
 *	 Purpose: extraL extension to Tcl
 *	 Author:  Copyright (c) 1995 Peter De Rijk
 *
 *	 See the file "README" for information on usage and redistribution
 *	 of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 */

#include <stdlib.h>
#include <string.h>
#include <malloc.h>
#include "tcl.h"
#include "general.h"

/*------------------------------------------------------------------*/
PBOOL ExtraL_find_bool(char *string, char *trues,char *falses)
{
	if (strcmp(string,trues)==0) return(true);
	else if (strcmp(string,falses)==0) return(false);
	else return(other);
}
/*------------------------------------------------------------------*/
char *ExtraL_numstr(int num)
{
	char *result=NULL;
	int number;
	int i;

	i=1;
	number=10;
	while(num>=number) {
		 number*=10;
		 i++;
	}
	result=(char *)malloc((i+1)*sizeof(char));
	sprintf(result, "%*d", i,	num);
	return(result);
}
/*--------------------------------------------------------------------*/
int *ExtraL_get_intlist(Tcl_Interp *interp, char *string, int *number, int min)
{
	int *list;
	int listArgc;
	CONST char **listArgv;
	int i;
	int temp;

	if (Tcl_SplitList(interp, string, &listArgc, &listArgv) != TCL_OK) {
		return(NULL);
	}

	/*---- get index list ----*/
	*number=listArgc;
	if (listArgc!=0) {
		list=(int *)malloc(listArgc*sizeof(int));
	} else {
		list=(int *)malloc(1*sizeof(int));
	}
	if (list==NULL) {
		ckfree((char *) listArgv);
		Tcl_AppendResult(interp, "GetInt couldn't allocate memory", (char *) NULL);
		return(NULL);
	}
	i=0;
	while(i<listArgc) {
		if (Tcl_GetInt(interp, listArgv[i], &temp) != TCL_OK) {
			ckfree((char *) listArgv);
			free(list);
			return(NULL);
		}
		if (temp<min) {
			Tcl_AppendResult(interp, "Index ", listArgv[i], "too small!",	(char *) NULL);
			ckfree((char *) listArgv);
			free(list);
			return(NULL);
		}
	list[i]=temp;
	i++;
	}
	ckfree((char *) listArgv);
	return(list);
}
/*------------------------------------------------------------------*/
#define FILEBUFFER 1000

int ExtraL_read_file(Tcl_Channel file, Tcl_DString *result)
{
	char *temp;
	int b;

	temp=(char *)Tcl_Alloc((FILEBUFFER+1)*sizeof(char));
	while(1) {
		b = Tcl_Read(file,temp,FILEBUFFER);
		if (b==-1) {Tcl_Free(temp);return TCL_ERROR;}
		Tcl_DStringAppend(result,temp,b);
		if (b<FILEBUFFER) break;
	}
	Tcl_Free(temp);
	return TCL_OK;
}

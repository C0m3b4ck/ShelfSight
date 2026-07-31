/*
 *	 File:    date.c
 *	 Purpose: extraL extension to Tcl
 *	 Author:  Copyright (c) 1995 Peter De Rijk
 *
 *	 See the file "README" for information on usage and redistribution
 *	 of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 */

#include "tcl.h"
#include "extral.h"
#include <ctype.h>
#include <string.h>
#include <math.h>

/*
 *----------------------------------------------------------------------
 *
 * ScanTime C API
 *
 *----------------------------------------------------------------------
 */

int ExtraL_ScanTime(interp,musthavedate,musthavetime,dateObj,resultObj)
	Tcl_Interp *interp;
	int musthavedate;
	int musthavetime;
	Tcl_Obj *dateObj;
	Tcl_Obj **resultObj;
{
	Tcl_Obj *el;
	char *date;
	char temp[8];
	char *ctemp = NULL;
	char ch;
	int year=-1,month=-1,day=-1,bc=0,hour=-1,min=-1,sec=-1,ms=-1;
	int first=-1,second=-1,days=-1,schrikkel = 0;
	int busyhour=0;
	int i,j,len,temppos;
	int error,result;
	date = Tcl_GetStringFromObj(dateObj,&len);
	temppos = 0;
	i=0;
	while(i<=len) {
		if (i!=len) {
			ch = date[i];
		} else {
			ch = ' ';
		}
		if ((ch == ':')||(ch == '.')||((ch == ' ')&&(busyhour == 1))) {
			int pos;
			if (temppos == 0) {
				i++;
				continue;
			}
			if ((ch == ':')||(ch == '.')) {
				busyhour = 1;
			} else {
				busyhour = 0;
			}
			temp[temppos] = '\0';
			pos = 0;
			if (hour == -1) {
				while (pos < (temppos-1)) {
					if (temp[pos] != '0') break;
					pos++;
				}
				error = Tcl_GetInt(interp, temp+pos, &hour);
				if (error != TCL_OK) {return error;}
			} else if (min == -1) {
				while (pos < (temppos-1)) {
					if (temp[pos] != '0') break;
					pos++;
				}
				error = Tcl_GetInt(interp, temp+pos, &min);
				if (error != TCL_OK) {return error;}
			} else if (sec == -1) {
				while (pos < (temppos-1)) {
					if (temp[pos] != '0') break;
					pos++;
				}
				error = Tcl_GetInt(interp, temp+pos, &sec);
				if (error != TCL_OK) {return error;}
			} else if (ms == -1) {
				int p,t,i;
				p = 100;
				ms = 0;
				i = 0;
				while(1) {
					if (temp[i] == '\0') break;
					t = temp[i]-48;
					if ((t < 0)||(t > 9)) {
						Tcl_AppendResult(interp,"Error in formatting of miliseconds",(char *)NULL);
						return TCL_ERROR;
					}
					ms += p*t;
					p /= 10;
					i++;
				}
			}
			temppos = 0;
		} else if ((ispunct(ch)!=0)||(ch==' ')) {
			if (temppos == 0) {
				i++;
				continue;
			}
			temp[temppos] = '\0';
			if (temppos>=4) {
				char *start = temp;
				while ((*start != '\0')&&(*start == '0')) {
					start++;
				}
				if (*start == '\0') {
					year = 0;
				} else {
					int i=0;
					while (i<temppos) {
						if (!isdigit(temp[i])) break;
						i++;
					}
					if (i != temppos) {
						if (((i+1)<temppos)&&((temp[i]=='B')||(temp[i]=='b'))&&((temp[i+1]=='C')||(temp[i+1]=='c'))) {
							bc = 1;
						}
						temp[i] = '\0';
					}
					error = Tcl_GetInt(interp, start, &year);
					/* do not check error: this might be e.g. a CEST that we want to ignore */
				}
			} else if (isalpha(temp[0])) {
				if (strncmp(temp,"jan",3)==0) {month = 1;}
				else if (strncmp(temp,"feb",3)==0) {month = 2;}
				else if (strncmp(temp,"mar",3)==0) {month = 3;}
				else if (strncmp(temp,"apr",3)==0) {month = 4;}
				else if (strncmp(temp,"may",3)==0) {month = 5;}
				else if (strncmp(temp,"jun",3)==0) {month = 6;}
				else if (strncmp(temp,"jul",3)==0) {month = 7;}
				else if (strncmp(temp,"aug",3)==0) {month = 8;}
				else if (strncmp(temp,"sep",3)==0) {month = 9;}
				else if (strncmp(temp,"oct",3)==0) {month = 10;}
				else if (strncmp(temp,"nov",3)==0) {month = 11;}
				else if (strncmp(temp,"dec",3)==0) {month = 12;}
				else if (strncmp(temp,"bc",2)==0) {bc = 1;}
			} else {
				char  *start=temp;
				while ((*start != '\0')&&(*start == '0')) {
					start++;
				}
				if (*start == '\0') {
					j = 0;
				} else {
					error = Tcl_GetInt(interp, start, &j);
					if (error != TCL_OK) {return error;}
				}
				if (first == -1) {
					first = j;
				} else {
					second = j;
				}
			}
			temppos = 0;
		} else {
			if (temppos == 7) {
				temppos = 0;
			}
			temp[temppos++] = tolower(ch);
		}
		i++;
	}
	if (month == -1) {
		month = first;
		day = second;
	} else {
		day = first;
	}
	if (musthavedate == 1) {
		if (year == -1) {
			ctemp = "year";
		} else if (month == -1) {
			ctemp = "month";
		} else if (day == -1) {
			ctemp = "day";
		}
		if (ctemp != NULL) {
			Tcl_ResetResult(interp);
			Tcl_AppendResult(interp,"error while parsing date \"",date, "\": ", ctemp, " not found",(char *)NULL);
			return TCL_ERROR;
		}
	} else {
		if (year == -1) {
			year = 1;
		}
		if (month == -1) {
			month = 1;
		}
		if (day == -1) {
			day = 1;
		}
	}
	if ((month<1)||(month>12)) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"error while parsing date in \"",date, "\": invalid month", (char *)NULL);
		return TCL_ERROR;
	}
	/* check and calculate days */
	if (year==0) {
		ctemp = "(unfortunately) there is no year 0";
	} else if (bc == 1) {
		i = year;
	} else {
		i = year-1;
	}
	result = i*365+i/4-i/100+i/400;
	schrikkel = 0;
	if (year%4 == 0) {
		if ((year%100 != 0)||(year%400 == 0)) {
			schrikkel = 1;
		}
	}
	if (bc == 1) {
		result = -result;
	}
	switch(month) {
		case 1:
			days = 31;
			break;
		case 2:
			days = 28+schrikkel;
			result += 31;
			break;
		case 3:
			days = 31;
			result += (59+schrikkel);
			break;
		case 4:
			days = 30;
			result += (90+schrikkel);
			break;
		case 5:
			days = 31;
			result += (120+schrikkel);
			break;
		case 6:
			days = 30;
			result += (151+schrikkel);
			break;
		case 7:
			days = 31;
			result += (181+schrikkel);
			break;
		case 8:
			days = 31;
			result += (212+schrikkel);
			break;
		case 9:
			days = 30;
			result += (243+schrikkel);
			break;
		case 10:
			days = 31;
			result += (273+schrikkel);
			break;
		case 11:
			days = 30;
			result += (304+schrikkel);
			break;
		case 12:
			days = 31;
			result += (334+schrikkel);
			break;
	}
	if ((day<1)||(day>days)) {
		ctemp = "invalid day";
	}
	result += (day-1);
	if (ctemp != NULL) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"error while parsing date in \"",date, "\": ", ctemp, (char *)NULL);
		return TCL_ERROR;
	}

	/* add the time */
	if (musthavetime == 1) {
		if (hour == -1) {
			ctemp = "hours";
		} else if (min == -1) {
			ctemp = "minutes";
		}
		if (ctemp != NULL) {
			Tcl_ResetResult(interp);
			Tcl_AppendResult(interp,"error while parsing time \"",date, "\": ", ctemp, " not found",(char *)NULL);
			return TCL_ERROR;
		}
	} else {
		if (hour == -1) {
			hour = 0;
		}
		if (min == -1) {
			min = 0;
		}
	}
	if (sec == -1) {
		sec = 0;
	}
	if (ms == -1) {
		ms = 0;
	}
	if ((hour<0)||(hour>23)) {
		ctemp = "invalid hour";
	}
	if ((min<0)||(min>59)) {
		ctemp = "invalid minutes";
	}
	if (sec == -1) {sec = 0;}
	if ((sec<0)||(sec>59)) {
		ctemp = "invalid seconds";
	}
	if (ms == -1) {ms = 0;}
	if ((ms<0)||(ms>999)) {
		ctemp = "invalid miliseconds";
	}
	if (ctemp != NULL) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"error while parsing time in \"",date, "\": ", ctemp, (char *)NULL);
		return TCL_ERROR;
	}
	*resultObj = Tcl_NewListObj(0,NULL);
	el = Tcl_NewIntObj(result);
	error = Tcl_ListObjAppendElement(interp, *resultObj, el);
	if (error) {Tcl_DecrRefCount(*resultObj);*resultObj = NULL;Tcl_DecrRefCount(el);return TCL_ERROR;}
	el = Tcl_NewIntObj(hour*3600000 + min*60000 + sec*1000 + ms);
	error = Tcl_ListObjAppendElement(interp, *resultObj, el);
	if (error) {Tcl_DecrRefCount(*resultObj);*resultObj = NULL;Tcl_DecrRefCount(el);return TCL_ERROR;}
	return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * ExtraL_ScanTimeCmd --
 *
 *		This procedure is invoked to process the "scantime" command.
 *
 * Results:
 *		A standard Tcl result.
 *
 *
 *----------------------------------------------------------------------
 */

int
ExtraL_ScanTimeObjCmd(notUsed, interp, objc, objv)
	ClientData notUsed;				 /* Not used. */
	Tcl_Interp *interp;					/* Current interpreter. */
	int objc;						/* Number of arguments. */
	Tcl_Obj *CONST objv[];	/* Argument objects. */
{
	Tcl_Obj *result;
	char *temp;
	int musthavedate,musthavetime;
	int error;

	if ((objc != 2)&&(objc != 3)) {
		Tcl_WrongNumArgs(interp, 1, objv, "time ?date/time/both?");
		return TCL_ERROR;
	}

	if (objc == 3) {
		temp = Tcl_GetStringFromObj(objv[2],&error);
		if (strncmp(temp,"time",error) == 0) {
			musthavedate = 0;
			musthavetime = 1;
		} else if (strncmp(temp,"both",error) == 0) {
			musthavedate = 1;
			musthavetime = 1;
		} else {
			musthavedate = 1;
			musthavetime = 0;
		}
	} else {
		musthavedate = 1;
		musthavetime = 0;
	}
	error = ExtraL_ScanTime(interp,musthavedate,musthavetime,objv[1],&result);
	if (error != TCL_OK) {return error;}
	Tcl_SetObjResult(interp,result);
	return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * FormatTime C API
 *
 *----------------------------------------------------------------------
 */


int
ExtraL_FormatTime(Tcl_Interp *interp, Tcl_Obj *timeObj, char *format, char **result)
{
	Tcl_Obj **listv;
	int listc;
	char *buffer, *fpos, *temp, *smonth;
	char b[2];
	int buffersize=1;
	int i,error;
	int year=-1,month=-1,day=-1,bc=0,hour=-1,min=-1,sec=-1,ms=-1;
	int date,time,days, schrikkel=0;
	int seconds;

	error = Tcl_ListObjGetElements(interp, timeObj, &listc, &listv);
	if (listc != 2) {
		Tcl_AppendResult(interp,"time should be a list of two integers (or a double for the old format)", (char *)NULL);
		return TCL_ERROR;
	}
	error = Tcl_GetIntFromObj(interp,listv[0], &date);
	if (error) {return TCL_ERROR;}
	error = Tcl_GetIntFromObj(interp,listv[1], &time);
	if (error) {return TCL_ERROR;}
	/* get date */
	if (date<0) {
		bc = 1;
		date = -date;
	}
	days = date;
	/* Start from something likely, try to add 1 year untill we get more days than given */
	year = (int)floor((double)days/365.25);
	while(1) {
		i = year+1;
		i = i*365 + i/4 - i/100 + i/400;
		if (bc == 1) {
			if (i>=days) break;
		} else if (i>days) break;
		year++;
	}
	/* How many days left after substracting all the days in the years accounted for */
	days = days - (year*365 + year/4 - year/100 + year/400);
	year++;
	if (year%4 == 0) {
		if ((year%100 != 0)||(year%400 == 0)) {
			schrikkel = 1;
		}
	}
	if (bc == 1) {
		days = 365 + schrikkel - days + 1;
	} else {
		days++;
	}
	if (days>(334+schrikkel)) {
		day = days-(334+schrikkel);
		smonth = "December";
		month = 12;
	} else if (days>(304+schrikkel)) {
		day = days-(304+schrikkel);
		smonth = "November";
		month = 11;
	} else if (days>(273+schrikkel)) {
		day = days-(273+schrikkel);
		smonth = "October";
		month = 10;
	} else if (days>(243+schrikkel)) {
		day = days-(243+schrikkel);
		smonth = "September";
		month = 9;
	} else if (days>(212+schrikkel)) {
		day = days-(212+schrikkel);
		smonth = "August";
		month = 8;
	} else if (days>(181+schrikkel)) {
		day = days-(181+schrikkel);
		smonth = "July";
		month = 7;
	} else if (days>(151+schrikkel)) {
		day = days-(151+schrikkel);
		smonth = "June";
		month = 6;
	} else if (days>(120+schrikkel)) {
		day = days-(120+schrikkel);
		smonth = "May";
		month = 5;
	} else if (days>(90+schrikkel)) {
		day = days-(90+schrikkel);
		smonth = "April";
		month = 4;
	} else if (days>(59+schrikkel)) {
		day = days-(59+schrikkel);
		smonth = "March";
		month = 3;
	} else if (days>31) {
		day = days-31;
		smonth = "February";
		month = 2;
	} else {
		day = days;
		smonth = "January";
		month = 1;
	}

	/* get time */
	seconds = (int)((double)time/1000.0);
	ms = time - (seconds*1000);
	hour = (int)floor((double)seconds/3600.0);
	seconds = seconds - (hour*3600.0);
	min = (int)floor(seconds/60.0);
	seconds = seconds - (min*60.0);
	sec = (int)(seconds);
	seconds = seconds - sec;

	temp = format;
	while(*temp != '\0') {
		if (*temp != '%') {
			buffersize +=1;
		} else if (temp[1] == 'Y') {
			buffersize +=7;
		} else if (temp[1] == 'B') {
			buffersize += strlen(smonth);
		} else {
			buffersize +=3;
		}
		temp++;
	}
	buffer = Tcl_Alloc(buffersize*sizeof(char));
	if (buffer == NULL) {return TCL_ERROR;}
	fpos = format;
	i = 0;
	while(*fpos != '\0') {
		if (*fpos == '%') {
			fpos++;
			if (*fpos == '\0') break;
			switch(*fpos) {
				case '%' :
					buffer[i++] = '%';
					break;
				case 'Y' :
					i += sprintf(buffer+i,"%4.4d",year);
					if (bc == 1) {
						i += sprintf(buffer+i,"BC");
					}
					break;
				case 'd' :
					i += sprintf(buffer+i,"%2.2d",day);
					break;
				case 'e' :
					i += sprintf(buffer+i,"%d",day);
					break;
				case 'j' :
					i += sprintf(buffer+i,"%3.3d",days);
					break;
				case 'm' :
					i += sprintf(buffer+i,"%2.2d",month);
					break;
				case 'b' :
					i += sprintf(buffer+i,"%3.3s",smonth);
					break;
				case 'B' :
					i += sprintf(buffer+i,"%s",smonth);
					break;
				case 'H' :
					i += sprintf(buffer+i,"%2.2d",hour);
					break;
				case 'M' :
					i += sprintf(buffer+i,"%2.2d",min);
					break;
				case 'S' :
					i += sprintf(buffer+i,"%2.2d",sec);
					break;
				case 's' :
					i += sprintf(buffer+i,"%3.3d",ms);
					break;
				default :
					Tcl_ResetResult(interp);
					b[0]=*fpos;
					b[1]='\0';
					Tcl_AppendResult(interp,"format option ", b, " not supported", (char *)NULL);
					return TCL_ERROR;
			}
		} else {
			buffer[i++] = *fpos;
		}
		fpos++;
	}
	*result = buffer;
	return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * old FormatTime C API
 *
 *----------------------------------------------------------------------
 */

int
ExtraL_FormatTime_old(Tcl_Interp *interp, double time, char *format, char **result)
{
	char *buffer, *fpos, *temp, *smonth;
	char b[2];
	int buffersize=1;
	int i;
	int year=-1,month=-1,day=-1,bc=0,hour=-1,min=-1,sec=-1,ms=-1;
	int days, schrikkel=0;
	double seconds;

	/* get date */
	if (time<0) {
		bc = 1;
		time = -time;
	}
	days = (int)floor(time/86400.0);
	year = (int)floor((double)days/365.25);
	while(1) {
		i = year+1;
		i = i*365 + i/4 - i/100 + i/400;
		if (bc == 1) {
			if (i>=days) break;
		} else if (i>days) break;
		year++;
	}
	seconds = time - days*86400.0;
	days = days - (year*365 + year/4 - year/100 + year/400);
	year++;
	if (year%4 == 0) {
		if ((year%100 != 0)||(year%400 == 0)) {
			schrikkel = 1;
		}
	}
	if (bc == 1) {
		if (seconds == 0) {
			days = 365 + schrikkel - days + 1;
		} else {
			days = 365 + schrikkel - days;
			seconds = 86400.0 - seconds;
		}
	} else {
		days++;
	}
	if (days>(334+schrikkel)) {
		day = days-(334+schrikkel);
		smonth = "December";
		month = 12;
	} else if (days>(304+schrikkel)) {
		day = days-(304+schrikkel);
		smonth = "November";
		month = 11;
	} else if (days>(273+schrikkel)) {
		day = days-(273+schrikkel);
		smonth = "October";
		month = 10;
	} else if (days>(243+schrikkel)) {
		day = days-(243+schrikkel);
		smonth = "September";
		month = 9;
	} else if (days>(212+schrikkel)) {
		day = days-(212+schrikkel);
		smonth = "August";
		month = 8;
	} else if (days>(181+schrikkel)) {
		day = days-(181+schrikkel);
		smonth = "July";
		month = 7;
	} else if (days>(151+schrikkel)) {
		day = days-(151+schrikkel);
		smonth = "June";
		month = 6;
	} else if (days>(120+schrikkel)) {
		day = days-(120+schrikkel);
		smonth = "May";
		month = 5;
	} else if (days>(90+schrikkel)) {
		day = days-(90+schrikkel);
		smonth = "April";
		month = 4;
	} else if (days>(59+schrikkel)) {
		day = days-(59+schrikkel);
		smonth = "March";
		month = 3;
	} else if (days>31) {
		day = days-31;
		smonth = "February";
		month = 2;
	} else {
		day = days;
		smonth = "January";
		month = 1;
	}

	/* get time */
	hour = (int)floor(seconds/3600.0);
	seconds = seconds - (hour*3600.0);
	min = (int)floor(seconds/60.0);
	seconds = seconds - (min*60.0);
	sec = (int)(seconds);
	seconds = seconds - sec;
	ms = (int)(seconds*100);

	temp = format;
	while(*temp != '\0') {
		if (*temp != '%') {
			buffersize +=1;
		} else if (temp[1] == 'Y') {
			buffersize +=7;
		} else if (temp[1] == 'B') {
			buffersize += strlen(smonth);
		} else {
			buffersize +=3;
		}
		temp++;
	}
	buffer = Tcl_Alloc(buffersize*sizeof(char));
	if (buffer == NULL) {return TCL_ERROR;}
	fpos = format;
	i = 0;
	while(*fpos != '\0') {
		if (*fpos == '%') {
			fpos++;
			if (*fpos == '\0') break;
			switch(*fpos) {
				case '%' :
					buffer[i++] = '%';
					break;
				case 'Y' :
					i += sprintf(buffer+i,"%4.4d",year);
					if (bc == 1) {
						i += sprintf(buffer+i,"BC");
					}
					break;
				case 'd' :
					i += sprintf(buffer+i,"%2.2d",day);
					break;
				case 'e' :
					i += sprintf(buffer+i,"%d",day);
					break;
				case 'j' :
					i += sprintf(buffer+i,"%3.3d",days);
					break;
				case 'm' :
					i += sprintf(buffer+i,"%2.2d",month);
					break;
				case 'b' :
					i += sprintf(buffer+i,"%3.3s",smonth);
					break;
				case 'B' :
					i += sprintf(buffer+i,"%s",smonth);
					break;
				case 'H' :
					i += sprintf(buffer+i,"%2.2d",hour);
					break;
				case 'M' :
					i += sprintf(buffer+i,"%2.2d",min);
					break;
				case 'S' :
					i += sprintf(buffer+i,"%2.2d",sec);
					break;
				case 's' :
					i += sprintf(buffer+i,"%2.2d",ms);
					break;
				default :
					Tcl_ResetResult(interp);
					b[0]=*fpos;
					b[1]='\0';
					Tcl_AppendResult(interp,"format option ", b, " not supported", (char *)NULL);
					return TCL_ERROR;
			}
		} else {
			buffer[i++] = *fpos;
		}
		fpos++;
	}
	*result = buffer;
	return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * ExtraL_FormatTimeCmd --
 *
 *		This procedure is invoked to process the "formattime" command.
 *
 * Results:
 *		A standard Tcl result.
 *
 *
 *----------------------------------------------------------------------
 */

int
ExtraL_FormatTimeObjCmd(notUsed, interp, objc, objv)
	ClientData notUsed;
	Tcl_Interp *interp;
	int objc;
	Tcl_Obj *CONST objv[];
{
	char *format, *result;
	double time;
	int len;
	int error;

	if ((objc != 2)&&(objc != 3)) {
		Tcl_WrongNumArgs(interp, 1, objv, "time ?formatstring?");
		return TCL_ERROR;
	}
	if (objc == 3) {
		format = Tcl_GetStringFromObj(objv[2],&len);
	} else {
		format = "%Y-%m-%d %H:%M:%S";
		len = 23;
	}
	error = Tcl_ListObjLength(interp, objv[1], &len);
	if (len == 2) {
		error = ExtraL_FormatTime(interp, objv[1], format, &result);
		if (error) {return error;}
	} else {
		error = Tcl_GetDoubleFromObj(interp,objv[1], &time);
		if (error) {goto error;}
		error = ExtraL_FormatTime_old(interp, time, format, &result);
		if (error) {return error;}
	}
	Tcl_SetResult(interp,result,TCL_VOLATILE);
	Tcl_Free(result);
	return TCL_OK;
	error:
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"time should be a list of two integers (or a double for the old format)", (char *)NULL);
		return TCL_ERROR;
}


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

/* 
    "natural" sort order: deals with mixed alphabetic and numbers
 */
#define UCHAR(c) ((unsigned char) (c))
#define NATDIGIT(c) (isdigit(UCHAR(*(c))))
#define isblank(char) (char == ' ' || char == '\t')

int naturalcompare (char const *a, char const *b,int alen,int blen) {
	int diff, digitleft,digitright;
	int secondaryDiff = 0,prezero,invert,comparedigits,prevdigit=0;
	char *left=NULL,*right=NULL,*keep=NULL;
	while (isblank(*a) && alen) {a++; alen--;}
	while (isblank(*b) && blen) {b++; blen--;}
	left = (char *)a;
	right = (char *)b;
	/* fprintf(stdout,"%s <> %s\n",a,b);fflush(stdout); */
	while (1) {
		diff = *left - *right;
		if (!alen || *left == '\0') {
			if (!blen || *right == '\0') {return secondaryDiff;} else {break;}
		}
		if (!blen || *right == '\0') {break;}
		if (*left != *right) {
			if (diff) {	
				/* only sort on case if no other diff -> keep secondaryDiff for case diff */
				if (isupper(UCHAR(*left)) && islower(UCHAR(*right))) {
					diff = tolower(*left) - *right;
					if (diff) {
						break;
					} else if (secondaryDiff == 0) {
						secondaryDiff = -1;
					}
				} else if (isupper(UCHAR(*right)) && islower(UCHAR(*left))) {
					diff = *left - tolower(UCHAR(*right));
					if (diff) {
						break;
					} else if (secondaryDiff == 0) {
						secondaryDiff = 1;
					}
				} else if (*right == '+') {
					if (*left == '-') {
						if (NATDIGIT(left+1) && NATDIGIT(right+1)) {return -1;} else {return 1;}
					} else if (NATDIGIT(right+1) && NATDIGIT(left)) {
						secondaryDiff = -1;
						right++; blen--;
						continue;
					}
				} else if (*left == '+') {
					if (*right == '-') {
						if (NATDIGIT(left+1) && NATDIGIT(right+1)) {return 1;} else {return -1;}
					} else if (NATDIGIT(left+1) && NATDIGIT(right)) {
						secondaryDiff = 1;
						left++; alen--;
						continue;
					}
				} else {
					break;
				}
			}
		}
		prevdigit = NATDIGIT(right);
		left++; alen--;
		right++; blen--;
	}
	digitright = blen && NATDIGIT(right);
	digitleft = alen && NATDIGIT(left);
	if (*left == '-') {
		if (digitright) {
			if (!prevdigit) {
				return -1;
			} else {
				return 1;
			}
		} else {
			return(*left - *right);
		}
	} else if (*right == '-' && digitleft) {
		if (digitleft) {
			if (!prevdigit) {
				return 1;
			} else {
				return -1;
			}
		} else {
			return(*left - *right);
		}
	}
	/* fprintf(stdout,"digit %s <> %s: %d, %d\n",left,right,digitleft,digitright);fflush(stdout); */

	comparedigits = 1;
	if (!digitright) {
		if (!digitleft || (right == b) || !NATDIGIT(right-1)) {comparedigits = 0;}
	}
	if (!digitleft) {
		if ((left == a) || !NATDIGIT(left-1)) {comparedigits = 0;}
	}

	if (!comparedigits) {
		if (diff == 0) {return secondaryDiff;} else {return diff;}
	}
	/*
	 * There are decimal numbers embedded in the two
	 * strings.  Compare them as numbers, rather than
	 * strings.  If one number has more leading zeros than
	 * the other, the number with more leading zeros sorts
	 * later, but only as a secondary choice.
	 */
	/* first take steps back (keep) to check for -0.0 */
	keep = left;
	prezero = 1;
	while (keep > a) {
		keep--;
		if (!NATDIGIT(keep)) break;
		if (*keep != '0') prezero = 0;
	}
	if (*keep == '.') {
		while (keep > a) {
			keep--;
			if (!NATDIGIT(keep)) break;
		}
		if (*keep == '-') {
			invert = -1;
		} else {
			invert = 1;
		}
		if (diff == 0) {return invert*secondaryDiff;} else {return invert*diff;}
	} else {
		if (*keep == '-') {
			invert = -1;
		} else {
			if (NATDIGIT(keep) && (*keep != '0')) {prezero = 0;}
			invert = 1;
		}
		if (prezero) {
			if (*left == '0') {
				secondaryDiff = 1;
				while (*left == '0') {
					left++; alen--;
				}
			} else if (*right == '0') {
				secondaryDiff = -1;
				while (*right == '0') {
					right++; blen--;
				}
			}
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
			if (!blen || !NATDIGIT(right)) {
				if (alen && NATDIGIT(left)) {
					return invert;
				} else {
					/*
					 * The two numbers have the same length. See
					 * if their values are different.
					 */
	
					if (diff != 0) {
						return invert*diff;
					} else {
						return invert*secondaryDiff;
					}
				}
			} else if (!alen || !NATDIGIT(left)) {
				return -1*invert;
			}
			right++; blen--;
			left++; alen--;
		}
	}
	fprintf(stderr,"shouldnt get here\n"); exit(1);
	return 0;
}


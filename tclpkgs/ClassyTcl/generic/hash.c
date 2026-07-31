/* 
 * tclHash.c --
 *
 *	Implementation of in-memory hash tables for Tcl and Tcl-based
 *	applications.
 *
 * Copyright (c) 1991-1993 The Regents of the University of California.
 * Copyright (c) 1994 Sun Microsystems, Inc.
 * 
 * changes to support objects by Peter De Rijk
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 * SCCS: @(#) tclHash.c 1.16 96/04/29 10:30:49
 */

#include "tcl.h"
#include "hash.h"
#include <string.h>
#include <string.h>
#include <stdlib.h>

/*
 * When there are this many entries per bucket, on average, rebuild
 * the hash table to make it larger.
 */

#define REBUILD_MULTIPLIER	3

/*
 * Procedure prototypes for static procedures in this file:
 */

static Classy_HashEntry *	BogusFind _ANSI_ARGS_((Classy_HashTable *tablePtr,
			    Tcl_Obj *keyObj));
static Classy_HashEntry *	BogusCreate _ANSI_ARGS_((Classy_HashTable *tablePtr,
			    Tcl_Obj *keyObj, int *newPtr));
static void		RebuildTable _ANSI_ARGS_((Classy_HashTable *tablePtr));
static Classy_HashEntry *	Classy_ObjFind _ANSI_ARGS_((Classy_HashTable *tablePtr,
			    Tcl_Obj *keyObj));
static Classy_HashEntry *	Classy_ObjCreate _ANSI_ARGS_((Classy_HashTable *tablePtr,
			    Tcl_Obj *keyObj, int *newPtr));

/*
 *----------------------------------------------------------------------
 *
 * Classy_InitHashTable --
 *
 *	Given storage for a hash table, set up the fields to prepare
 *	the hash table for use.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	TablePtr is now ready to be passed to Classy_FindHashEntry and
 *	Classy_CreateHashEntry.
 *
 *----------------------------------------------------------------------
 */

void
Classy_InitHashTable(tablePtr)
    register Classy_HashTable *tablePtr;	/* Pointer to table record, which
					 * is supplied by the caller. */
{
    tablePtr->buckets = tablePtr->staticBuckets;
    tablePtr->staticBuckets[0] = tablePtr->staticBuckets[1] = 0;
    tablePtr->staticBuckets[2] = tablePtr->staticBuckets[3] = 0;
    tablePtr->numBuckets = Classy_SMALL_HASH_TABLE;
    tablePtr->numEntries = 0;
    tablePtr->rebuildSize = Classy_SMALL_HASH_TABLE*REBUILD_MULTIPLIER;
    tablePtr->downShift = 28;
    tablePtr->mask = 3;
	tablePtr->findProc = Classy_ObjFind;
	tablePtr->createProc = Classy_ObjCreate;
}

/*
 *----------------------------------------------------------------------
 *
 * Classy_DeleteHashEntry --
 *
 *	Remove a single entry from a hash table.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	The entry given by entryPtr is deleted from its table and
 *	should never again be used by the caller.  It is up to the
 *	caller to free the clientData field of the entry, if that
 *	is relevant.
 *
 *----------------------------------------------------------------------
 */

void
Classy_DeleteHashEntry(entryPtr)
    Classy_HashEntry *entryPtr;
{
    register Classy_HashEntry *prevPtr;

    if (*entryPtr->bucketPtr == entryPtr) {
		*entryPtr->bucketPtr = entryPtr->nextPtr;
    } else {
		for (prevPtr = *entryPtr->bucketPtr; ; prevPtr = prevPtr->nextPtr) {
		    if (prevPtr == NULL) {
				(void) fprintf(stderr,"%s","malformed bucket chain in Classy_DeleteHashEntry");
				(void) fprintf(stderr, "\n");
				(void) fflush(stderr);
				abort();
		    }
		    if (prevPtr->nextPtr == entryPtr) {
				prevPtr->nextPtr = entryPtr->nextPtr;
				break;
		    }
		}
    }
    entryPtr->tablePtr->numEntries--;
	Tcl_DecrRefCount(entryPtr->key);
	Tcl_Free((char *) entryPtr);
}

/*
 *----------------------------------------------------------------------
 *
 * Classy_DeleteHashTable --
 *
 *	Free up everything associated with a hash table except for
 *	the record for the table itself.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	The hash table is no longer useable.
 *
 *----------------------------------------------------------------------
 */

void
Classy_DeleteHashTable(tablePtr)
    register Classy_HashTable *tablePtr;		/* Table to delete. */
{
    register Classy_HashEntry *hPtr, *nextPtr;
    int i;

    /*
     * Free up all the entries in the table.
     */

    for (i = 0; i < tablePtr->numBuckets; i++) {
		hPtr = tablePtr->buckets[i];
		while (hPtr != NULL) {
			Tcl_DecrRefCount(hPtr->key);
		    nextPtr = hPtr->nextPtr;
		    Tcl_Free((char *) hPtr);
		    hPtr = nextPtr;
		}
    }

    /*
     * Free up the bucket array, if it was dynamically allocated.
     */

    if (tablePtr->buckets != tablePtr->staticBuckets) {
	Tcl_Free((char *) tablePtr->buckets);
    }

    /*
     * Arrange for panics if the table is used again without
     * re-initialization.
     */

    tablePtr->findProc = BogusFind;
    tablePtr->createProc = BogusCreate;
}

/*
 *----------------------------------------------------------------------
 *
 * Classy_FirstHashEntry --
 *
 *	Locate the first entry in a hash table and set up a record
 *	that can be used to step through all the remaining entries
 *	of the table.
 *
 * Results:
 *	The return value is a pointer to the first entry in tablePtr,
 *	or NULL if tablePtr has no entries in it.  The memory at
 *	*searchPtr is initialized so that subsequent calls to
 *	Classy_NextHashEntry will return all of the entries in the table,
 *	one at a time.
 *
 * Side effects:
 *	None.
 *
 *----------------------------------------------------------------------
 */

Classy_HashEntry *
Classy_FirstHashEntry(tablePtr, searchPtr)
    Classy_HashTable *tablePtr;		/* Table to search. */
    Classy_HashSearch *searchPtr;		/* Place to store information about
					 * progress through the table. */
{
    searchPtr->tablePtr = tablePtr;
    searchPtr->nextIndex = 0;
    searchPtr->nextEntryPtr = NULL;
    return Classy_NextHashEntry(searchPtr);
}

/*
 *----------------------------------------------------------------------
 *
 * Classy_NextHashEntry --
 *
 *	Once a hash table enumeration has been initiated by calling
 *	Classy_FirstHashEntry, this procedure may be called to return
 *	successive elements of the table.
 *
 * Results:
 *	The return value is the next entry in the hash table being
 *	enumerated, or NULL if the end of the table is reached.
 *
 * Side effects:
 *	None.
 *
 *----------------------------------------------------------------------
 */

Classy_HashEntry *
Classy_NextHashEntry(searchPtr)
    register Classy_HashSearch *searchPtr;	/* Place to store information about
					 * progress through the table.  Must
					 * have been initialized by calling
					 * Classy_FirstHashEntry. */
{
    Classy_HashEntry *hPtr;

    while (searchPtr->nextEntryPtr == NULL) {
	if (searchPtr->nextIndex >= searchPtr->tablePtr->numBuckets) {
	    return NULL;
	}
	searchPtr->nextEntryPtr =
		searchPtr->tablePtr->buckets[searchPtr->nextIndex];
	searchPtr->nextIndex++;
    }
    hPtr = searchPtr->nextEntryPtr;
    searchPtr->nextEntryPtr = hPtr->nextPtr;
    return hPtr;
}

/*
 *----------------------------------------------------------------------
 *
 * Classy_HashStats --
 *
 *	Return statistics describing the layout of the hash table
 *	in its hash buckets.
 *
 * Results:
 *	The return value is a malloc-ed string containing information
 *	about tablePtr.  It is the caller's responsibility to free
 *	this string.
 *
 * Side effects:
 *	None.
 *
 *----------------------------------------------------------------------
 */

char *
Classy_HashStats(tablePtr)
    Classy_HashTable *tablePtr;		/* Table for which to produce stats. */
{
#define NUM_COUNTERS 10
    int count[NUM_COUNTERS], overflow, i, j;
    double average, tmp;
    register Classy_HashEntry *hPtr;
    char *result, *p;

    /*
     * Compute a histogram of bucket usage.
     */

    for (i = 0; i < NUM_COUNTERS; i++) {
	count[i] = 0;
    }
    overflow = 0;
    average = 0.0;
    for (i = 0; i < tablePtr->numBuckets; i++) {
	j = 0;
	for (hPtr = tablePtr->buckets[i]; hPtr != NULL; hPtr = hPtr->nextPtr) {
	    j++;
	}
	if (j < NUM_COUNTERS) {
	    count[j]++;
	} else {
	    overflow++;
	}
	tmp = j;
	average += (tmp+1.0)*(tmp/tablePtr->numEntries)/2.0;
    }

    /*
     * Print out the histogram and a few other pieces of information.
     */

    result = (char *) Tcl_Alloc((unsigned) ((NUM_COUNTERS*60) + 300));
    sprintf(result, "%d entries in table, %d buckets\n",
	    tablePtr->numEntries, tablePtr->numBuckets);
    p = result + strlen(result);
    for (i = 0; i < NUM_COUNTERS; i++) {
	sprintf(p, "number of buckets with %d entries: %d\n",
		i, count[i]);
	p += strlen(p);
    }
    sprintf(p, "number of buckets with %d or more entries: %d\n",
	    NUM_COUNTERS, overflow);
    p += strlen(p);
    sprintf(p, "average search distance for entry: %.1f", average);
    return result;
}

/*
 *----------------------------------------------------------------------
 *
 *
 *----------------------------------------------------------------------
 */

static unsigned int
Classy_HashObj(stringObj)
    Tcl_Obj *stringObj;/* String from which to compute hash value. */
{
	register unsigned int result;
	char *string;
	int stringlen;
	register int i;

    /*
     * I tried a zillion different hash functions and asked many other
     * people for advice.  Many people had their own favorite functions,
     * all different, but no-one had much idea why they were good ones.
     * I chose the one below (multiply by 9 and add new character)
     * because of the following reasons:
     *
     * 1. Multiplying by 10 is perfect for keys that are decimal strings,
     *    and multiplying by 9 is just about as good.
     * 2. Times-9 is (shift-left-3) plus (old).  This means that each
     *    character's bits hang around in the low-order bits of the
     *    hash value for ever, plus they spread fairly rapidly up to
     *    the high-order bits to fill out the hash value.  This seems
     *    works well both for decimal and non-decimal strings.
     */

	string = Tcl_GetStringFromObj(stringObj,&stringlen);
	result = 0;
	for (i=0;i<stringlen;i++) {
		result += (result<<3) + string[i];
	}
	return result;
}
static unsigned int
Classy_HashObj_String(string,stringlen)
	char *string;/* String from which to compute hash value. */
	int stringlen;
{
	register unsigned int result;
	register int i;
	result = 0;
	for (i=0;i<stringlen;i++) {
		result += (result<<3) + string[i];
	}
    return result;
}

/*
 *----------------------------------------------------------------------
 *
 * Classy_ObjFind --
 *
 *	Given a hash table with string keys, and a string key, find
 *	the entry with a matching key.
 *
 * Results:
 *	The return value is a token for the matching entry in the
 *	hash table, or NULL if there was no matching entry.
 *
 * Side effects:
 *	None.
 *
 *----------------------------------------------------------------------
 */

static Classy_HashEntry *
Classy_ObjFind(tablePtr, keyObj)
    Classy_HashTable *tablePtr;	/* Table in which to lookup entry. */
    Tcl_Obj *keyObj;		/* Key to use to find matching entry. */
{
    register Classy_HashEntry *hPtr;
    register CONST char *p2, *key;
    int index,keylen,p2len,i;

    index = Classy_HashObj(keyObj) & tablePtr->mask;

    /*
     * Search all of the entries in the appropriate bucket.
     */
	key = Tcl_GetStringFromObj(keyObj,&keylen);

    for (hPtr = tablePtr->buckets[index]; hPtr != NULL; hPtr = hPtr->nextPtr) {
		p2 = Tcl_GetStringFromObj(hPtr->key,&p2len);
		if (p2len != keylen) continue;
		for(i=0;i<keylen;i++) {
			if (key[i] != p2[i]) break;
		}
		if (i == keylen) {
			return hPtr;
		}
    }
    return NULL;
}

/*
 *----------------------------------------------------------------------
 *
 * Classy_ObjCreate --
 *
 *	Given a hash table with string keys, and a string key, find
 *	the entry with a matching key.  If there is no matching entry,
 *	then create a new entry that does match.
 *
 * Results:
 *	The return value is a pointer to the matching entry.  If this
 *	is a newly-created entry, then *newPtr will be set to a non-zero
 *	value;  otherwise *newPtr will be set to 0.  If this is a new
 *	entry the value stored in the entry will initially be 0.
 *
 * Side effects:
 *	A new entry may be added to the hash table.
 *
 *----------------------------------------------------------------------
 */

static Classy_HashEntry *
Classy_ObjCreate(tablePtr, keyObj, newPtr)
    Classy_HashTable *tablePtr;	/* Table in which to lookup entry. */
    Tcl_Obj *keyObj;		/* Key to use to find or create matching
				 * entry. */
    int *newPtr;		/* Store info here telling whether a new
				 * entry was created. */
{
    register Classy_HashEntry *hPtr;
    register CONST char *p2, *key;
    int index,keylen,p2len,i;

    index = Classy_HashObj(keyObj) & tablePtr->mask;

    /*
     * Search all of the entries in this bucket.
     */
	key = Tcl_GetStringFromObj(keyObj,&keylen);

    for (hPtr = tablePtr->buckets[index]; hPtr != NULL; hPtr = hPtr->nextPtr) {
		p2 = Tcl_GetStringFromObj(hPtr->key,&p2len);
		if (p2len != keylen) continue;
		for(i=0;i<keylen;i++) {
			if (key[i] != p2[i]) break;
		}
		if (i == keylen) {
			*newPtr = 0;
			return hPtr;
		}
    }

    /*
     * Entry not found.  Add a new one to the bucket.
     */

    *newPtr = 1;
	hPtr = (Classy_HashEntry *) Tcl_Alloc(sizeof(Classy_HashEntry));
    hPtr->tablePtr = tablePtr;
    hPtr->bucketPtr = &(tablePtr->buckets[index]);
    hPtr->nextPtr = *hPtr->bucketPtr;
    hPtr->clientData = 0;
	Tcl_IncrRefCount(keyObj);
	hPtr->key = keyObj;
    *hPtr->bucketPtr = hPtr;
    tablePtr->numEntries++;

    /*
     * If the table has exceeded a decent size, rebuild it with many
     * more buckets.
     */

    if (tablePtr->numEntries >= tablePtr->rebuildSize) {
	RebuildTable(tablePtr);
    }
    return hPtr;
}

static Classy_HashEntry *
BogusFind(tablePtr, keyObj)
    Classy_HashTable *tablePtr;	/* Table in which to lookup entry. */
    Tcl_Obj *keyObj;		/* Key to use to find matching entry. */
{
	(void) fprintf(stderr,"%s","called Classy_FindHashEntry on deleted table");
	(void) fprintf(stderr, "\n");
	(void) fflush(stderr);
	abort();
    return NULL;
}

/*
 *----------------------------------------------------------------------
 *
 * BogusCreate --
 *
 *	This procedure is invoked when an Classy_CreateHashEntry is called
 *	on a table that has been deleted.
 *
 * Results:
 *	If panic returns (which it shouldn't) this procedure returns
 *	NULL.
 *
 * Side effects:
 *	Generates a panic.
 *
 *----------------------------------------------------------------------
 */

	/* ARGSUSED */
static Classy_HashEntry *
BogusCreate(tablePtr, keyObj, newPtr)
    Classy_HashTable *tablePtr;	/* Table in which to lookup entry. */
    Tcl_Obj *keyObj;		/* Key to use to find or create matching
				 * entry. */
    int *newPtr;		/* Store info here telling whether a new
				 * entry was created. */
{
	(void) fprintf(stderr,"%s","called Classy_CreateHashEntry on deleted table");
	(void) fprintf(stderr, "\n");
	(void) fflush(stderr);
	abort();
    return NULL;
}

/*
 *----------------------------------------------------------------------
 *
 * RebuildTable --
 *
 *	This procedure is invoked when the ratio of entries to hash
 *	buckets becomes too large.  It creates a new table with a
 *	larger bucket array and moves all of the entries into the
 *	new table.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Memory gets reallocated and entries get re-hashed to new
 *	buckets.
 *
 *----------------------------------------------------------------------
 */

static void
RebuildTable(tablePtr)
    register Classy_HashTable *tablePtr;	/* Table to enlarge. */
{
    int oldSize, count, index;
    Classy_HashEntry **oldBuckets;
    register Classy_HashEntry **oldChainPtr, **newChainPtr;
    register Classy_HashEntry *hPtr;

    oldSize = tablePtr->numBuckets;
    oldBuckets = tablePtr->buckets;

    /*
     * Allocate and initialize the new bucket array, and set up
     * hashing constants for new array size.
     */

    tablePtr->numBuckets *= 4;
    tablePtr->buckets = (Classy_HashEntry **) Tcl_Alloc((unsigned)
	    (tablePtr->numBuckets * sizeof(Classy_HashEntry *)));
    for (count = tablePtr->numBuckets, newChainPtr = tablePtr->buckets;
	    count > 0; count--, newChainPtr++) {
	*newChainPtr = NULL;
    }
    tablePtr->rebuildSize *= 4;
    tablePtr->downShift -= 2;
    tablePtr->mask = (tablePtr->mask << 2) + 3;

    /*
     * Rehash all of the existing entries into the new bucket array.
     */

    for (oldChainPtr = oldBuckets; oldSize > 0; oldSize--, oldChainPtr++) {
	for (hPtr = *oldChainPtr; hPtr != NULL; hPtr = *oldChainPtr) {
	    *oldChainPtr = hPtr->nextPtr;
		index = Classy_HashObj(hPtr->key) & tablePtr->mask;
	    hPtr->bucketPtr = &(tablePtr->buckets[index]);
	    hPtr->nextPtr = *hPtr->bucketPtr;
	    *hPtr->bucketPtr = hPtr;
	}
    }

    /*
     * Free up the old bucket array, if it was dynamically allocated.
     */

    if (oldBuckets != tablePtr->staticBuckets) {
	Tcl_Free((char *) oldBuckets);
    }
}

Classy_HashEntry *
Classy_Find_String_HashEntry(tablePtr, key,keylen)
	Classy_HashTable *tablePtr;	/* Table in which to lookup entry. */
	char *key;		/* Key to use to find matching entry. */
	int keylen;
{
    register Classy_HashEntry *hPtr;
    register CONST char *p2;
    int index,p2len,i;

    index = Classy_HashObj_String(key,keylen) & tablePtr->mask;

    /*
     * Search all of the entries in the appropriate bucket.
     */
    for (hPtr = tablePtr->buckets[index]; hPtr != NULL; hPtr = hPtr->nextPtr) {
		p2 = Tcl_GetStringFromObj(hPtr->key,&p2len);
		if (p2len != keylen) continue;
		for(i=0;i<keylen;i++) {
			if (key[i] != p2[i]) break;
		}
		if (i == keylen) {
			return hPtr;
		}
    }
    return NULL;
}

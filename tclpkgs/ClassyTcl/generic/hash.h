/*
 * tcl.h --
 *
 *	This header file describes the externally-visible facilities
 *	of the Tcl interpreter.
 *
 * Copyright (c) 1987-1994 The Regents of the University of California.
 * Copyright (c) 1994-1997 Sun Microsystems, Inc.
 * Copyright (c) 1993-1996 Lucent Technologies.
 * 
 * changes to support objects by Peter De Rijk
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 * SCCS: @(#) tcl.h 1.326 97/11/20 12:40:43
 */

/*
 * Structure definition for an entry in a hash table.  No-one outside
 * Tcl should access any of these fields directly;  use the macros
 * defined below.
 */

/* This EXTERN declaration is needed for Tcl < 8.0.3 */
#ifndef EXTERN
# ifdef __cplusplus
#  define EXTERN extern "C"
# else
#  define EXTERN extern
# endif
#endif

typedef struct Classy_HashEntry {
    struct Classy_HashEntry *nextPtr;	/* Pointer to next entry in this
					 * hash bucket, or NULL for end of
					 * chain. */
    struct Classy_HashTable *tablePtr;	/* Pointer to table containing entry. */
    struct Classy_HashEntry **bucketPtr;	/* Pointer to bucket that points to
					 * first entry in this entry's chain:
					 * used for deleting the entry. */
    ClientData clientData;		/* Application stores something here
					 * with Classy_SetHashValue. */
	Tcl_Obj *key;
} Classy_HashEntry;

/*
 * Structure definition for a hash table.  Must be in tcl.h so clients
 * can allocate space for these structures, but clients should never
 * access any fields in this structure.
 */

#define Classy_SMALL_HASH_TABLE 4
typedef struct Classy_HashTable {
    Classy_HashEntry **buckets;		/* Pointer to bucket array.  Each
					 * element points to first entry in
					 * bucket's hash chain, or NULL. */
    Classy_HashEntry *staticBuckets[Classy_SMALL_HASH_TABLE];
					/* Bucket array used for small tables
					 * (to avoid mallocs and frees). */
    int numBuckets;			/* Total number of buckets allocated
					 * at **bucketPtr. */
    int numEntries;			/* Total number of entries present
					 * in table. */
    int rebuildSize;			/* Enlarge table when numEntries gets
					 * to be this large. */
    int downShift;			/* Shift count used in hashing
					 * function.  Designed to use high-
					 * order bits of randomized keys. */
    int mask;				/* Mask value used in hashing
					 * function. */
    Classy_HashEntry *(*findProc) _ANSI_ARGS_((struct Classy_HashTable *tablePtr,
	    Tcl_Obj *keyObj));
    Classy_HashEntry *(*createProc) _ANSI_ARGS_((struct Classy_HashTable *tablePtr,
	    Tcl_Obj *keyObj, int *newPtr));
} Classy_HashTable;

/*
 * Structure definition for information used to keep track of searches
 * through hash tables:
 */

typedef struct Classy_HashSearch {
    Classy_HashTable *tablePtr;		/* Table being searched. */
    int nextIndex;			/* Index of next bucket to be
					 * enumerated after present one. */
    Classy_HashEntry *nextEntryPtr;	/* Next entry to be enumerated in the
					 * the current bucket. */
} Classy_HashSearch;

/*
 * Acceptable key types for hash tables:
 */

#define Classy_STRING_KEYS		0
#define Classy_ONE_WORD_KEYS	1

/*
 * Macros for clients to use to access fields of hash entries:
 */

#define Classy_GetHashValue(h) ((h)->clientData)
#define Classy_SetHashValue(h, value) ((h)->clientData = (ClientData) (value))
#define Classy_GetHashKey(tablePtr, h) ((h)->key)

/*
 * Macros to use for clients to use to invoke find and create procedures
 * for hash tables:
 */

#define Classy_FindHashEntry(tablePtr, key) \
	(*((tablePtr)->findProc))(tablePtr, key)
#define Classy_CreateHashEntry(tablePtr, key, newPtr) \
	(*((tablePtr)->createProc))(tablePtr, key, newPtr)
extern void		Classy_DeleteHashEntry _ANSI_ARGS_((
			    Classy_HashEntry *entryPtr));
extern void		Classy_DeleteHashTable _ANSI_ARGS_((
			    Classy_HashTable *tablePtr));
extern Classy_HashEntry *	Classy_FirstHashEntry _ANSI_ARGS_((
			    Classy_HashTable *tablePtr,
			    Classy_HashSearch *searchPtr));
extern char *		Classy_HashStats _ANSI_ARGS_((Classy_HashTable *tablePtr));
extern void		Classy_InitHashTable _ANSI_ARGS_((Classy_HashTable *tablePtr));
extern Classy_HashEntry *	Classy_NextHashEntry _ANSI_ARGS_((
			    Classy_HashSearch *searchPtr));
extern Classy_HashEntry *Classy_Find_String_HashEntry _ANSI_ARGS_((
			Classy_HashTable *tablePtr,
			char *key,
			int keylen));

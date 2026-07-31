int Classy_ExecClassMethod _ANSI_ARGS_((Tcl_Interp *interp,
	Method *method,
	Class *class,
	Object *object,
	int argc,
	Tcl_Obj *CONST argv[]));

int Classy_ExecMethod _ANSI_ARGS_((Tcl_Interp *interp,
	Method *method,
	Class *class,
	Object *object,
	int argc,
	Tcl_Obj *CONST argv[]));

int Classy_FreeMethod _ANSI_ARGS_((Method *method));

int Classy_CreateTclClassMethod _ANSI_ARGS_((Tcl_Interp *interp,
	Method *method,
	Tcl_Obj *name,
	Tcl_Obj *args,
	Tcl_Obj *body,
	Tcl_Obj *rname));	

int Classy_CreateTclMethod _ANSI_ARGS_((Tcl_Interp *interp,
	Method *method,
	Tcl_Obj *name,
	Tcl_Obj *args,
	Tcl_Obj *body,
	Tcl_Obj *rname));	

void Classy_CopyMethods _ANSI_ARGS_((Classy_HashTable *src,
	Classy_HashTable *dst));

int Classy_CopyMethod _ANSI_ARGS_((Classy_HashTable *src,
	Classy_HashTable *dst,
	Tcl_Obj *name));

Classy_Method Classy_ClassMethodClassMethod;
Classy_Method Classy_DeleteClassMethodClassMethod;
Classy_Method Classy_MethodClassMethod;
Classy_Method Classy_DeleteMethodClassMethod;

int Classy_InfoClassMethods _ANSI_ARGS_((Tcl_Interp *interp,Class *class,Tcl_Obj *pattern));
int Classy_InfoMethods _ANSI_ARGS_((Tcl_Interp *interp,Class *class,Tcl_Obj *pattern));
int Classy_InfoClassMethodinfo _ANSI_ARGS_((Tcl_Interp *interp,Class *class,int argc,Tcl_Obj *CONST argv[]));
int Classy_InfoMethodinfo _ANSI_ARGS_((Tcl_Interp *interp,Class *class,Object *object,int argc,Tcl_Obj *CONST argv[]));


# Some convenience functions that are always loaded
#
# Copyright (c) 1996 Peter De Rijk
#
# See the file "README" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# =============================================================

#doc {convenience invoke} cmd {
#invoke vars cmd ...
#} descr {
# invoke simply evals $cmd in a private space. This eg. allows using
# temporary variables in bindings without creating these in global scope.
# It is also very convenient to use values appended to a command given
# to a binding:
# Further arguments (when given) are parameters that will be available in the
# variables given in vars. If more parameters are supplied than vars are given,
# the remaining parameters will be stored in the variable args.
#}
proc invoke {vars cmd args} {
	foreach var $vars {
		set $var [list_shift args]
	}
	eval $cmd
}


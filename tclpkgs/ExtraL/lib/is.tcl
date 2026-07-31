# Copyright (c) 1996 Peter De Rijk
#
# See the file "README.txt" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# =============================================================

#doc validatecommands title {
# Validation commands
#} shortdescr {
#isint, isdouble
#}

#doc {validatecommands isint} cmd {
#isint value
#} descr {
#returns 1 if value is an integer, 0 if it is not
#} example {
#	% isint 1
#	1
#	% isint a
#	0
#	% isint 1.2
#	0
#}
proc isint {value} {
	if [catch {expr {1 >> $value}} e] {
		if {$e eq "negative shift argument"} {
			return 1
		} else {
			return 0
		}
	} else {
		return 1
	}
}

#doc {validatecommands isdouble} cmd {
#isdouble value
#} descr {
#returns 1 if value is a real number, 0 if it is not
#} example {
#	% isdouble 1.2
#	1
#	% isdouble 1
#	1
#	% isdouble a
#	0
#}
proc isdouble {value} {
	if [catch {expr {$value+0}}] {
		return 0
	} else {
		return 1
	}
}

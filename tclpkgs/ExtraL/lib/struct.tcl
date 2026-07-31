# Code to use references and structures in Tcl
# The example creates, prints and destroys a simple linked list
#
# Copyright (c) 1996 Peter De Rijk
#
# See the file "README" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# =============================================================
#doc struct title {
#Structures
#} descr {
#	This code emulates structures in a way. all data is actually stored in 
#	one global array extraL__Struct. You cannot use the generic array command 
#	on structure structure members
#}
#doc {struct struct} cmd {
#struct new
#} descr {
#	returns an unused pointer to a structure.
#} example {
#	set current [struct new]
#}
#doc {struct set} cmd {
#struct set struct->member value
#} descr {
#	sets the value of a member
#} example {
#	struct set $current->field Test
#	struct set $current->data(a) 1
#}
#doc {struct value} cmd {
#struct value struct->member
#} descr {
#	returns the value of a member
#} example {
#	struct value $current->field
#	struct value $current->data(a)
#}
#doc {struct unset} cmd {
#struct unset struct?->member?
#} descr {
#	unsets a member or the entire struct
#} example {
#	struct unset $current->field
#	struct unset $current
#}
#doc {struct var} cmd {
#struct var struct?->member?
#} descr {
#	gives the actual variable name where the member is stored (global): 
#	This can be used in -textvariable options etc.
#} example {
#	entry .try -textvariable [struct var $current->field]
#	pack .try
#}
#doc {struct arrayset} cmd {
#struct arrayset struct->member items values
#} descr {
#	sets values in an array member
#} example {
#	% struct arrayset $current->value {a b c} {1 2 3}
#	% struct value $current->value(b)
#	2
#}
#doc {struct arrayget} cmd {
#struct arrayget struct->member
#} descr {
#	% struct arrayget $current->value
#	b 2 a 1 c 3
#}
#doc {struct arraynames} cmd {
#struct arraynames struct->member
#} descr {
#	% struct arraynames $current->value
#	b a c
#}
#doc {struct arraysize} cmd {
#struct arraysize struct->member
#} descr {
#	% struct arraysize $current->value
#	3
#}

namespace eval struct {
	proc example {} {
		set pointer [examplecreate]
		exampleread $pointer
		exampledestruct $pointer
	}
	
	proc examplecreate {} {
		set current [struct new]
		set root $current
		foreach value {a b c d} {
			struct set $current->value $value
			struct set $current->next [struct new]
			set keep $current
			set current [struct set $current->next]
		}
		struct set $keep->next ""
		return $root
	}
	
	proc exampleread {current} {
		while 1 {
			puts stdout [struct set $current->value]
			puts [struct array get $current->array]
			if {[struct set $current->next] == ""} {break}
			set keep $current
			set current [struct set $current->next]
		}
	}
	
	proc exampledestruct {current} {
		while 1 {
			if {[struct set $current->next] == ""} {break}
			set keep $current
			set current [struct set $current->next]
			struct unset $keep
		}
	}
}

proc struct {option args} {
	variable pointernr
	if [string match $option new] {
		if ![string match $args ""] {
			error "wrong # args: should be \"struct new\""
		}
		if ![info exists pointernr] {
			set pointernr 0
		}
		incr pointernr
		set name Struct$pointernr
		set struct::$name-> $pointernr
		return $name
	}
	set var [lindex $args 0]
	switch $option {
		names {
			set names [namespace eval struct {info vars *->}]
			set result ""
			foreach name $names {
				regexp {^(.+)->} $name temp name
				lappend result $name
			}
			return $result
		}
		fields {
			set len [llength $args]
			if {$len!=1} {
				error "wrong # args: should be \"struct fields struct\""
			}
			set names [namespace eval struct [list info vars $var->*]]
			set result ""
			foreach name $names {
				if [regexp {^.+->(.+)$} $name temp name] {
					lappend result $name
				}
			}
			return $result
		}
		set {
			set len [llength $args]
			if {($len!=1)&&($len!=2)} {
				error "wrong # args: should be \"struct set struct ?value?\""
			}
			if {$len==1} {
				set error [catch {set struct::$var} result]
			} else {
				set error [catch {set struct::$var [lindex $args 1]} result]
			}
			if $error {
				regsub {struct::} $result {} result
				error $result
			} else {
				return $result
			}
		}
		unset {
			if {[llength $args]!=1} {
				error "wrong # args: should be \"struct unset struct\""
			}
			if ![regexp -- {->} $var] {
				set error [catch {namespace eval struct "foreach var \[info vars $var->*\] \{unset \$var\}"} result]
			} else {
				set error [catch {unset struct::$var} result]
			}
			if $error {
				regsub {struct::} $result {} result
				error $result
			} else {
				return $result
			}
		}
		array {
			set len [llength $args]
			if {$len<2} {
				error "wrong # args: should be \"struct array option arrayName ?arg ...? \""
			}
			set option [list_shift args]
			set var [list_shift args]
			set error [catch {eval {array $option struct::$var} $args} result]
			if $error {
				regsub {struct::} $result {} result
				error $result
			} else {
				return $result
			}
		}
		clearall {
			if [info exists pointernr] {
				unset pointernr
			}
			namespace delete struct
			namespace eval struct {
			}
		}
		default {
			error "bad option \"$option\": should be new, set, unset, array, names, fields or clearall"
		}
	}
}

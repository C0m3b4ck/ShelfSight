#
# ClassyTcl
# --------- Peter De Rijk
#
# Class-tcl
#
# Create the base class Class, the work namespace ::Class
# and all supplementary commands: tcl version
#
# ----------------------------------------------------------------------

# namespace used for auto names
namespace eval ::Class::Class {}

#doc {Class cm} h2 {
# Classmethods
#} descr {
# The classmethods defined by Class can be invoked from all classes.
#}
#doc {Class m} h2 {
# Methods
#} descr {
# The methods defined by Class can be invoked from all objects
#}

proc ::Class::correctcmd {fcmd cmd} {
	set result "$cmd"
	if [regexp {,,cm,} $fcmd] {
		set list [lrange [info args $fcmd] 1 end]
	} else {
		set list [lrange [info args $fcmd] 2 end]
	}
	foreach arg $list {
		if {"$arg" == "args"} {
			append result " ..."
		} elseif [info default $fcmd $arg def] {
			append result " ?$arg?"
		} else {
			append result " $arg"
		}
	}
	return $result
}

proc ::Class::classerror {class object result cmd arg} {
#putsvars class object result cmd arg
	global errorInfo
	set ::Class::error $result 
	set ::Class::errorInfo $errorInfo 
	if [regexp "wrong # args: should be \"(\[^ \]*) " $result temp fcmd] {
		set error "wrong # args: should be \"$object [Class::correctcmd $fcmd $cmd]\""
	} elseif [regexp "called \"(.*)\" with too many arguments" $result temp fcmd] {
		set error "wrong # args: should be \"$object [Class::correctcmd $fcmd $cmd]\""
	} elseif [regexp "no value given for parameter \".*\" to \"(.*)\"" $result temp fcmd] {
		set error "wrong # args: should be \"$object [Class::correctcmd $fcmd $cmd]\""
	} elseif [regexp "^invalid command name \"(::Class::${class},,c?m,.*)\"$" $result temp fcmd] {
		if {"$class"=="$object"} {
			set methods [join [lsort [concat [::Class::info_ $class $object methods] [::Class::info_ $class $object classmethods]]] ", "]
		} else {
			set methods [join [lsort [::Class::info_ $class $object methods]] ", "]
		}
		set error "bad option \"$cmd\": must be $methods"
	} else {
		set error $result
	}
	return $error
}

if {![info exists ::Class::objectnum]} {set ::Class::objectnum 1}

#doc {Class cm new} cmd {
# ClassName new <u>object</u> ?...?
#} descr {
# create a new instance (or object) with the name $<u>object</u> of class 
# ClassName. When the actual object is created,
# the init method of class ClassName will be invoked with the arguments
# given after $<u>object</u>.<br>
# Usually, the init method of the superclass
# must be invoked somehere in the init method with appropriate parameters.
# This can be done using the command 
#<pre>super init ?...?</pre>.
#}
proc ::Class::new {class arg} {
#putsvars class arg
	set object [lindex $arg 0]
	if {![llength $arg] || [string equal $object #auto]} {
		set object ::Class::o$::Class::objectnum
		set arg [list $object]
		incr ::Class::objectnum
		set namespace Class
	} else {
		regsub {^::} $object {} object
		set namespace [namespace qualifiers $object]
		if {"$namespace" != ""} {
			namespace eval $namespace {}
		}
		if {"[info commands ::$object]" != ""} {
			return -code error "command \"$object\" exists"
		}
	}
	set ::Class::parent($object) $class
	set ::Class::${class},,child($object) 1
	set body [format {
		set error [catch {uplevel ::Class::%s,,m,${cmd} %s %s $args} result]
		if {$error} {
			if {[string match "invalid command name*" $result]} {
				Class::auto_load_method %s m $cmd
				set error [catch {uplevel ::Class::%s,,m,${cmd} %s %s $args} result]
			}
			if {$error} {
				return -code error -errorinfo [set ::errorInfo] [Class::classerror %s %s $result $cmd $args]
			}
		}
		return $result
	} [list $class] [list $class] [list $object] [list $class] [list $class] [list $class] [list $object] [list $class] [list $object]]
	proc ::$object {cmd args} $body
#	set ::Class::current $class
	if [info exists ::Class::${class},,init] {
		if [catch {uplevel ::Class::${class},,init [list $class] $arg} result] {
			set errorInfo [set ::errorInfo]
			::Class::objectdestroy $class $object
			return -code error -errorinfo $errorInfo $result
		} else {
			return $object
		}
	} elseif {"$class" != "Class"} {
		if [catch {eval super init [lrange $arg 1 end]} result] {
			set errorInfo [set ::errorInfo]
			::Class::objectdestroy $class $object
			return -code error -errorinfo $errorInfo $result
		} else {
			return $object
		}
	} else {
		return $object
	}
}

#doc {Class m changeclass} cmd {
# pathName changeclass <u>newclass</u> ?...?
#} descr {
# change the class of an instance (or object) with the name $<u>pathnName</u> to newclass
# This can be useful to eg. change to a derived subclass (and back) based on data given
# The command does not do any checking whether the class being changed to is compatible.
#}
proc ::Class::changeclass {class object arg} {
#puts [list new $class $arg]
	set len [llength $arg]
	if {$len != 1} {
		return -code error "wrong # args: should be \"$object changeclass newclass\""
	}
	set newclass [lindex $arg 0]
	auto_load $newclass
	unset ::Class::${class},,child($object)
	set ::Class::${newclass},,child($object) 1
	set ::Class::parent($object) $newclass
	set body [format {
		if [catch {uplevel ::Class::%s,,m,${cmd} %s %s $args} result] {
			return -code error -errorinfo [set ::errorInfo] [Class::classerror %s %s $result $cmd $args]
		}
		return $result
	} [list $newclass] [list $newclass] [list $object] [list $newclass] [list $object]]
	proc ::$object {cmd args} $body
	return $object
}

#doc {Class cm subclass} cmd {
# ClassName subclass <u>SubClass</u>
#} descr {
# create a new class named $<u>SubClass</u> that inherits data
# and methods from class ClassName. ClassName is the parent or
# superclass of SubClass.
#}
proc ::Class::subclass {class arg} {
	set len [llength $arg]
	if {$len != 1} {
		return -code error "wrong # args: should be \"$class subclass class\""
	}
	set child [lindex $arg 0]
	regsub {^::} $child {} child
	set namespace [namespace qualifiers $child]
	if {"$namespace" != ""} {
		namespace eval $namespace {}
	}
	set ::Class::parent($child) $class
	set ::Class::${class},,subclass($child) 1
#	set body [info body ::$class]
#	regsub -all " $class " $body " [list $child] " body
	set body {
		if [regexp {^\.} $cmd] {set args [concat $cmd $args];set cmd new}
		set error [catch {uplevel ::Class::@class@,,cm,${cmd} @class@ $args} result]
		if {$error} {
			if {[string match "invalid command name*" $result]} {
				Class::auto_load_method @class@ cm $cmd
				set error [catch {uplevel ::Class::@class@,,cm,${cmd} @class@ $args} result]
			}
			if {$error} {
				set error [::Class::classerror @class@ @class@ $result $cmd $args]
				return -code error -errorinfo [set ::errorInfo] $error
			}
		}
		return $result
	}
	regsub -all @class@ $body [list $child] body
	if {"[info commands ::$child]" != ""} {
		set error [catch {info body ::$child} curbody]
		if {$error || ([info args ::$child] ne "cmd args") || ($curbody ne $body)} {
			return -code error "command \"$child\" exists"
		} else {
			return $child
		}
	}
	proc ::$child {cmd args} $body
	# copy methods
	foreach cmd [info commands ::Class::${class},,m,*] {
		regexp "^::Class::${class},,m,(.*)\$" $cmd temp name
		set args ""
		foreach arg [info args $cmd] {
			if [info default $cmd $arg def] {
				lappend args [list $arg $def]
			} else {
				lappend args $arg
			}
		}
		proc ::Class::${child},,m,${name} $args [info body $cmd]
	}
	# copy classmethods
	foreach cmd [info commands ::Class::${class},,cm,*] {
		regexp "^::Class::${class},,cm,(.*)\$" $cmd temp name
		set args ""
		foreach arg [info args $cmd] {
			if [info default $cmd $arg def] {
				lappend args [list $arg $def]
			} else {
				lappend args $arg
			}
		}
		proc ::Class::${child},,cm,${name} $args [info body $cmd]
	}
	# copy class variables
	foreach var [info vars ::Class::${class},,v,*] {
		regexp "^::Class::${class},,v,(.*)\$" $var temp name
		if [array exists $var] {
			array set ::Class::${child},,v,${name} [array get $var]
		} else {
			set ::Class::${child},,v,${name} [set $var]
		}
	}
	return $child
}

#doc {Class cm destroy} cmd {
# Classname destroy
#} descr {
# destroys a class. All its instances and subclasses and their
# instances will also be destroyed. If the classmethod destroy
# if defined for the class, it will be invoked after the 
# desctruction of its children, but before destroying the class
# itself and and its instances.
#}
proc ::Class::classdestroy {class} {
#puts "destroying class $class"
	foreach child [array names ::Class::${class},,subclass] {
		catch {::$child destroy}
	}
	foreach child [array names ::Class::${class},,child] {
		catch {::$child destroy}
	}
	catch {::Class::${class},,classdestroy $class}
	if [info exists ::Class::parent($class)] {
		if {"$class" != "Class"} {
			set parent [set ::Class::parent($class)]
			if [info exists ::Class::${parent},,subclass($class)] {
				unset ::Class::${parent},,subclass($class)
			}
		}
		unset ::Class::parent($class)
	}
	foreach var [info vars ::Class::${class},,*] {
		unset $var
	}
	foreach cmd [info commands ::Class::${class},,*] {
		rename $cmd {}
	}
	catch {rename ::$class {}}
}

#doc {Class m destroy} cmd {
# pathName destroy
#} descr {
# destroys an object.
# The destroy method of the objects class (if defined) and those
# of its superclasses (if defined) will be invoked before the 
# destruction of the actual object.
#}
proc ::Class::objectdestroy {class object} {
#puts "destroying object $object"
	set current $class
	while {"$current" != ""} {
		if [catch {::Class::$current,,destroy $class $object} errorline] {
			if {![string equal $errorline "invalid command name \"::Class::$current,,destroy\""]} {
				lappend error "\"$errorline\" in destroy method of object \"$object\" for class \"$current\""
			}
		}
		set current [set ::Class::parent($current)]
	}
	if [info exists ::Class::parent($object)] {
		unset ::Class::parent($object)
	}
	if [info exists ::Class::${class},,child($object)] {
		unset ::Class::${class},,child($object)
	}
	foreach var [info vars ::Class::${object},,*] {
		unset $var
	}
	catch {rename ::$object {}}
	if {[info exists error]} {
		error [join $error \n]
	}
	return ""
}

proc super {method args} {
	upvar class class object object
	set level [info level]
	set plevel [expr {$level-2}]
	if [info exists ::Class::current($plevel)] {
		set current $::Class::current($plevel)
	} else {
		set current $class
	}
	if {"$method" == "init"} {
		while 1 {
			set current [set ::Class::parent($current)]
			if {"$current" == "Class"} {
				return $object
			}
			if [info exists ::Class::${current},,init] {
				break
			}
		}
		set ::Class::current($level) $current
		set error [catch {eval ::Class::${current},,init {$class $object} $args} result]
		unset ::Class::current($level)
	} elseif [info exists object] {
		set proc ::Class::${current},,m,${method}
		if [catch {info body $proc} body] {
			error "No method \"$method\" defined for super of $object (at class \"$current\")"
		}
		regexp "^#(\[^\n\]+)" $body temp cclass
		while 1 {
			set current [set ::Class::parent($current)]
			set proc ::Class::${current},,m,${method}
			if [catch {info body $proc} body] {
				error "No method \"$method\" defined for super of $object (at class \"$current\")"
			}
			regexp "^#(\[^\n\]+)" $body temp bclass
			if {"$bclass" != "$cclass"} break
		}
		set ::Class::current($level) $current
		set error [catch {eval $proc {$class $object} $args} result]
		unset ::Class::current($level)
	} else {
		set proc ::Class::${current},,cm,${method}
		if [catch {info body $proc} body] {
			error "No classmethod \"$method\" defined for super of $class (at class \"$current\")"
		}
		regexp "^#(\[^\n\]+)" $body temp cclass
		while 1 {
			set current [set ::Class::parent($current)]
			set proc ::Class::${current},,cm,${method}
			if [catch {info body $proc} body] {
				error "No classmethod \"$method\" defined for super of $class (at class \"$current\")"
			}
			regexp "^#(\[^\n\]+)" $body temp bclass
			if {"$bclass" != "$cclass"} break
		}
		set ::Class::current($level) $current
		set error [catch {eval $proc {$class} $args} result]
		unset ::Class::current($level)
	}
	if $error {
		error $result
	} else {
		return $result
	}
}

proc ::Class::method_def {class method} {
	set proc ::Class::${class},,m,${method}
	if [catch {info body $proc} body] {
		error "No method \"$method\" defined for class \"$class\""
	}
	regexp "^#(\[^\n\]+)" $body temp bclass
	return $bclass
}

proc ::Class::propagatemethod {class type name args body} {
	if ![info exists ::Class::${class},,subclass] {
		return ""
	}
	foreach subclass [array names ::Class::${class},,subclass] {
		if {![catch {::Class::method_def $subclass $name} defclass]} {
			if {[string equal $subclass $defclass]} continue
		}
		set temp ::Class::${subclass},,$type,${name}
		proc $temp $args $body
		::Class::propagatemethod $subclass $type $name $args $body
	}
}

proc ::Class::propagatedeletemethod {class type name} {
	if ![info exists ::Class::${class},,subclass] {
		return ""
	}
	foreach subclass [array names ::Class::${class},,subclass] {
		set temp ::Class::${subclass},,$type,${name}
		if [regexp "^#$class\n" [info body $temp]] {
			rename $temp {}
			::Class::propagatedeletemethod $subclass $type $name
		}
	}
}

#doc {Class m info} cmd {
# pathName info <u>option</u> ?...?
#} descr {
#<b>pathName info class</b><br>
# returns the class of pathName<br>
#<b>pathName info classmethods ?pattern?</b><br>
# returns a list of all available classmethods except the hidden ones (those starting 
# with an underscore is returned. When it is invoked with one argument, a list
# of all classmethods matching the pattern is returned<br>
#<b>pathName info methods ?pattern?</b><br>
# returns a list of all available methods except the hidden methods (those starting 
# with an underscore is returned. When it is invoked with one argument, a list
# of all methods matching the pattern is returned<br>
#<b>pathName info parent</b><br>
# returns the parent of pathName<br>
#<b>pathName info children</b><br>
# returns the children of pathName<br>
#<b>pathName info subclasses</b><br>
# returns the subclasses pathName<br>
#<b>pathName info classmethod option name ...</b><br>
# returns information about the classmethod $name of pathName. Following options are supported:
#<ul>
#<li> body: returns the body of the classmethod (if it is defined in Tcl)
#<li> args: returns the arguments of the classmethod
#<li> default arg varname: returns 0 if the argument $arg does not have a default value, 
# otherwise it returns 1, and places the default value in the variable varname
#</ul>
#<br><b>pathName info method option name ...</b><br>
# returns information about the method $name of pathName. It takes the same options 
# as "info classmethod"
#}
proc ::Class::info_ {class object arg} {
	set len [llength $arg]
	if {$len < 1} {
		return -code error "wrong # args: should be \"$object info option ?...?\""
	}
	set option [lindex $arg 0]
	switch $option {
		parent {
			return [set ::Class::parent($object)]
		}
		class {
			return $class
		}
		children {
			if {"$class" == "$object"} {
				return [lsort [array names ::Class::${class},,child]]
			}
		}
		subclasses {
			if {"$class" == "$object"} {
				if [info exists ::Class::${class},,subclass] {
					return [array names ::Class::${class},,subclass]
				} else {
					return ""
				}
			}
		}
		methods {
			if {$len == 1} {
				set result ""
				foreach cmd [lsort [info commands ::Class::${class},,m,*]] {
					if [regexp "^::Class::${class},,m,(\[^_\].*)\$" $cmd temp name] {
						lappend result $name
					}
				}
				return $result
			} elseif {$len == 2} {
				set result ""
				foreach cmd [lsort [info commands ::Class::${class},,m,[lindex $arg 1]]] {
					regexp "^::Class::${class},,m,(.*)\$" $cmd temp name
					lappend result $name
				}
				return $result
			} else {
				return -code error "wrong # args: should be \"$object info methods ?pattern?\""
			}
		}
		classmethods {
			if {("$class" == "$object")||("$object"=="")} {
				if {$len == 1} {
						set result ""
						foreach cmd [lsort [info commands ::Class::${class},,cm,*]] {
							if [regexp "^::Class::${class},,cm,(\[^_\].*)\$" $cmd temp name] {
								lappend result $name
							}
						}
						return $result
					} elseif {$len == 2} {
						set result ""
						foreach cmd [lsort [info commands ::Class::${class},,cm,[lindex $arg 1]]] {
							regexp "^::Class::${class},,cm,(.*)\$" $cmd temp name
							lappend result $name
						}
						return $result
					}
				}
			}
		method {
			set name [lindex $arg 2]
			if {"$name" == "init"} {
				set tmpclass $class
				while 1 {
					set proc ::Class::${tmpclass},,$name
					if [string length [info commands $proc]] break
					if {"$tmpclass" == "Class"} {return {}}
					set tmpclass [set ::Class::parent($tmpclass)]
				}
			} elseif {"$name" == "destroy"} {
				set proc ::Class::${class},,destroy
			} else {
				set proc ::Class::${class},,m,$name
			}
			switch [lindex $arg 1] {
				body {
					set body [info body $proc]
					regsub "^#.+\n" $body {} body
					return $body
				}
				args {
					return [lrange [info args $proc] 2 end]
				}
				default {
					if {$len != 5} {
						return -code error "wrong # args: should be \"$object info method default arg varname\""
					}
					return [uplevel 2 info default $proc [lindex $arg 3] [lindex $arg 4]]
				}
				default {
					return -code error "wrong option \"[lindex $arg 1]\" must be body, args or default"
				}
			}
		}
		classmethod {
			if {"$class" == "$object"} {
				set name [lindex $arg 2]
				set proc ::Class::${class},,cm,$name
				switch [lindex $arg 1] {
					body {
						set body [info body $proc]
						regsub "^#.+\n" $body {} body
						return $body
					}
					args {
						return [lrange [info args $proc] 1 end]
					}
					default {
						if {$len != 5} {
							return -code error "wrong # args: should be \"$class info classmethod default arg varname\""
						}
						return [uplevel 2 info default $proc [lindex $arg 3] [lindex $arg 4]]
					}
					default {
						return -code error "wrong option \"[lindex $arg 0]\" must be body, args or default"
					}
				}
			} else {
				return -code error "object cannot have classmethods"
			}
		}
	}
	if {"$class" != "$object"} {
		return -code error "wrong option \"$option\" must be parent, class, methods or method"
	} else {
		return -code error "wrong option \"$option\" must be parent, class, children, subclasses, methods, method, classmethods or classmethod"
	}
}

#doc {Class cm method} cmd {
# ClassName method <u>name</u> <u>args</u> <u>body</u>
#} descr {
# define a new method named $<u>name</u> for class ClassName.
# Whenever the method is invoked, the contents of body will be executed.
# The arguments <u>args</u> and <u>body</u> follow the same conventions
# as in the Tcl command proc.
#<br>
# In body two extra local variables are available named class and object.
# They contain the name of respectively the class and the object that
# invoked the method. If the method was invoked from a class, the values
# of variables class and object will be identical (name of the class).
#}
proc ::Class::method {class arg} {
	set len [llength $arg]
	if {$len != 3} {
		return -code error "wrong # args: should be \"$class method name args body\""
	}
	set name [lindex $arg 0]
	set args [lindex $arg 1]
	set body "#$class\n"
	append body [lindex $arg 2]
	if {"$name" == "init"} {
		if {"$class" == "Class"} {
			return -code error "init classmethod of base Class cannot be redefined"
		}
		if {"$body" == ""} {
			if [info exists ::Class::${class},,init] {
				unset ::Class::${class},,init
				rename ::Class::${class},,init {}
			}
		} else {
			set ::Class::${class},,init 1
			set args [concat class object $args]
			proc [list ::Class::${class},,init] $args $body
		}
		return $name
	} elseif {"$name" == "destroy"} {
		if {"$class" == "Class"} {
			return -code error "destroy method of base Class cannot be redefined"
		}
		if {"$args" != ""} {
			return -code error "destroy method cannot have arguments"
		}
		if {"$body" != ""} {
			proc ::Class::${class},,destroy {class object} $body
		} elseif {"[info commands ::Class::${class},,destroy]" != ""} {
			rename ::Class::$class,,destroy {}
		}
		return $name
	} else {
		set args [concat class object $args]
		proc [list ::Class::${class},,m,${name}] $args $body
#		if [catch {proc [list ::Class::${class},,m,${name}] $args $body} result] {
#			regsub "procedure \".+\"" $result "method \"$name\" of class \"$class\"" result
#			return -code error $result
#		}
		::Class::propagatemethod $class m $name $args $body
		return $name
	}
}

#doc {Class cm classmethod} cmd {
# ClassName classmethod <u>name</u> <u>args</u> <u>body</u>
#} descr {
# define a new classmethod named $<u>name</u> for class ClassName.
# Whenever the classmethod is invoked, the contents of body will be executed.
# The arguments <u>args</u> and <u>body</u> follow the same conventions
# as in the Tcl command proc.
#<br>
# In body two extra local variables are available named class and object.
# Because a classmethod can only be invoked from a class, they are both
# contain the name of the class that invoked the method.
#}
proc ::Class::classmethod {class arg} {
	set len [llength $arg]
	if {$len != 3} {
		return -code error "wrong # args: should be \"$class method name args body\""
	}
	set name [lindex $arg 0]
	set args [lindex $arg 1]
	set body "#$class\n"
	append body [lindex $arg 2]
	switch $name {
		classmethod - deleteclassmethod - method - deletemethod - subclass - 
		new {return -code error "\"$name\" classmethod cannot be redefined"}
		destroy {
			if {"$class" == "Class"} {
				return -code error "destroy classmethod of base Class cannot be redefined"
			}
			if {"$args" != ""} {
				return -code error "destroy classmethod cannot have arguments"
			}
			if {"$body" != ""} {
				proc ::Class::${class},,classdestroy {class} $body
			} elseif {"[info commands ::Class::${class},,classdestroy]" != ""} {
				rename ::Class::$class,,classdestroy {}
			}
			return $name
		}
	}
	set args [concat class $args]
	proc [list ::Class::${class},,cm,${name}] $args $body
#	if [catch {proc [list ::Class::${class},,cm,${name}] $args $body} result] {
#		regsub "procedure \".+\"" $result "classmethod \"$name\" of class \"$class\"" result
#		return -code error $result
#	}
	::Class::propagatemethod $class cm $name $args $body
	return $name
}

#doc {Class cm deletemethod} cmd {
# ClassName deletemethod <u>name</u>
#} descr {
# delete the method named $<u>name</u> from class ClassName.
# Some special methods cannot be deleted.
#}
proc ::Class::deletemethod {class arg} {
	set len [llength $arg]
	if {$len != 1} {
		return -code error "wrong # args: should be \"$class deletemethod name\""
	}
	set name [lindex $arg 0]
	switch $name {
		init {
			if {"$class" == "Class"} {
				return -code error "init classmethod of base Class cannot be deleted"
			}
			if [info exists ::Class::${class},,init] {
				unset ::Class::${class},,init
				rename ::Class::${class},,init {}
				return $name
			}
		}
		destroy {
			if {"$class" == "Class"} {
				return -code error "destroy method of base Class cannot be deleted"
			}
			if {"[info commands ::Class::${class},,destroy]" != ""} {
				rename ::Class::${class},,destroy {}
			}
		}
		default {
			if {"[info commands ::Class::${class},,m,${name}]" != ""} {
				rename ::Class::${class},,m,${name} {}
				::Class::propagatedeletemethod $class m $name
			}
		}
	}
	return {}
}

#doc {Class cm deleteclassmethod} cmd {
# ClassName deleteclassmethod <u>name</u>
#} descr {
# delete the classmethod named $<u>name</u> from class ClassName.
# Some special classmethods cannot be deleted.
#}
proc ::Class::deleteclassmethod {class arg} {
	set len [llength $arg]
	if {$len != 1} {
		return -code error "wrong # args: should be \"$class deleteclassmethod name\""
	}
	set name [lindex $arg 0]
	switch $name {
		classmethod - method - deletemethod - deleteclassmethod - subclass -
		new {return -code error "\"$name\" classmethod cannot be deleted"}
		destroy {
			if {"$class" == "Class"} {
				return -code error "destroy classmethod of base Class cannot be deleted"
			}
			if {"[info commands ::Class::${class},,classdestroy]" != ""} {
				rename ::Class::$class,,classdestroy {}
			}
			return $name
		}
	}
	if {"[info commands ::Class::${class},,cm,${name}]" != ""} {
		rename ::Class::${class},,cm,${name} {}
		::Class::propagatedeletemethod $class cm $name
	}
	return {}
}

#
# ------------------------------------------------------
# Create the base Class
# ------------------------------------------------------
#
namespace eval ::Class {
	set parent(Class) ""
}

proc ::Class {cmd args} {
	if [regexp {^\.} $cmd] {set args [concat $cmd $args];set cmd new}
	if [catch {uplevel ::Class::Class,,cm,${cmd} Class $args} result] {
		set error [::Class::classerror Class Class $result $cmd $args]
		return -code error -errorinfo [set ::errorInfo] $error
	}
	return $result
}

# Class classmethods
# ------------------
proc ::Class::Class,,cm,classmethod {class args} {
#Class
	::Class::classmethod $class $args
}

proc ::Class::Class,,cm,new {class args} {
#Class
	::Class::new $class $args
}

proc ::Class::Class,,cm,destroy {class} {
#Class
	::Class::classdestroy $class
	return {}
}

proc ::Class::Class,,cm,method {class args} {
#Class
	::Class::method $class $args
}

proc ::Class::Class,,cm,deletemethod {class args} {
#Class
	::Class::deletemethod $class $args
}

proc ::Class::Class,,cm,deleteclassmethod {class args} {
#Class
	::Class::deleteclassmethod $class $args
}

proc ::Class::Class,,cm,subclass {class args} {
#Class
	::Class::subclass $class $args
}

proc ::Class::Class,,cm,private {class args} {
#Class
	::Class::classprivatecmd $class $args
}

proc ::Class::Class,,cm,info {class args} {
#Class
	::Class::info_ $class $class $args
}

# Class methods
# -------------
proc ::Class::Class,,m,destroy {class object} {
#Class
	::Class::objectdestroy $class $object
	return $object
}

proc ::Class::Class,,m,private {class object args} {
#Class
	::Class::privatecmd $class $object $args
}

proc ::Class::Class,,m,info {class object args} {
#Class
	::Class::info_ $class $object $args
}

proc ::Class::Class,,m,changeclass {class object args} {
#Class
	::Class::changeclass $class $object $args
}

#
# =========================================
# Variable access
# =========================================
#
#doc {Class m private} cmd {
# pathName private ?<u>name</u>? ?<u>value</u>?
#} descr {
# private is used to get or change data associated with an object.
# Without arguments a list of all private variables is returned.
# If the name argument is given, but not the value argument, the 
# current value of private variable $<u>name</u> is returned. If both arguments
# are present, the private variable $<u>name</u> is set to $<u>value</u>.
#}
proc ::Class::privatecmd {class object arg} {
	set len [llength $arg]
	if {$len == 0} {
		set list ""
		foreach var [lsort [info vars ::Class::${object},,v,*]] {
			regexp "^::Class::${object},,v,(.*)\$" $var temp name
			lappend list $name
		}
		return $list
	} elseif {$len == 1} {
		set name ::Class::${object},,v,[lindex $arg 0]
		if [info exists $name] {
			return [set $name]
		} else {
			return -code error "\"$object\" does not have a private variable \"[lindex $arg 0]\""
		}
	} elseif {$len == 2} {
		return [set ::Class::${object},,v,[lindex $arg 0] [lindex $arg 1]]
	} else {
		return -code error "wrong # args: should be \"$object private ?varName? ?newValue?\""
	}
}

#doc {Class cm private} cmd {
# ClassName private ?<u>name</u>? ?<u>value</u>?
#} descr {
# classmethod private is used to get or change private data 
# associated with a class.
# Without arguments a list of all private class variables is returned.
# If the name argument is given, but not the value argument, the 
# current value of private class variable $<u>name</u> is returned. If both arguments
# are present, the private class variable $<u>name</u> is set to $<u>value</u>.
#}
proc ::Class::classprivatecmd {class arg} {
	set len [llength $arg]
	if {$len == 0} {
		set list ""
		foreach var [lsort [info vars ::Class::${class},,v,*]] {
			regexp "^::Class::${class},,v,(.*)\$" $var temp name
			lappend list $name
		}
		return $list
	} elseif {$len == 1} {
		set name ::Class::${class},,v,[lindex $arg 0]
		if [info exists $name] {
			return [set $name]
		} else {
			return -code error "\"$class\" does not have a private variable \"[lindex $arg 0]\""
		}
	} elseif {$len == 2} {
		set name [lindex $arg 0]
		set ::Class::${class},,vd($name) 1
		Class::propagatevar $class $name [lindex $arg 1]
		return [set ::Class::${class},,v,$name [lindex $arg 1]]
	} else {
		return -code error "wrong # args: should be \"$class private ?varName? ?newValue?\""
	}
}

proc ::Class::propagatevar {class name value} {
	if ![info exists ::Class::${class},,subclass] {
		return ""
	}
	foreach subclass [array names ::Class::${class},,subclass] {
		if ![info exists ::Class::${subclass},,vd($name)] {
			setprivate $subclass $name $value
			::Class::propagatevar $subclass $name $value
		}
	}
}

proc private {object args} {
	foreach var $args {
		uplevel upvar #0 [list ::Class::${object},,v,$var] [list $var]
	}
}

proc privatevar {object var} {
	return ::Class::${object},,v,$var
}

proc setprivate {object var value} {
	set ::Class::${object},,v,$var $value
}

proc getprivate {object var} {
	set ::Class::${object},,v,$var
}

Class classmethod trace {command} {
	set temp [info body $class]
	regsub "^.*# class trace done\n" $temp {} temp
	if {"$command" != ""} {
		set temp {
			uplevel 1 [list @command@ [eval list {@class@ [list $cmd]} $args]]
			# class trace done
		}
		regsub -all {@command@} $temp $command temp
		regsub -all {@class@} $temp [list $class] temp
		append temp [info body $class]
	}
	proc ::$class [info args $class] $temp
}

Class method trace {command} {
	set temp [info body $object]
	regsub "^.*# object trace done\n" $temp {} temp
	if {"$command" != ""} {
		set temp {
			uplevel 1 [list @command@ [eval list {@object@ [list $cmd]} $args]]
			# object trace done
		}
		regsub -all {@command@} $temp $command temp
		regsub -all {@object@} $temp [list $object] temp
		append temp [info body $object]
	}
	proc ::$object [info args $object] $temp
}

#if ![llength [info commands ::Tk::rename]] {
#	rename rename ::Tk::rename
#}
#proc rename {oldName newName} {
#	if ![regexp ^:: $oldName] {
#		set oldName [uplevel 1 namespace current]::$oldName
#	}
#	regsub ^(::)+ $oldName {} temp
#	if {![string length $newName] && [info exists ::Class::parent($temp)]} {
#		$oldName destroy
#	} else {
#		uplevel 1 [list ::Tk::rename $oldName $newName]
#	}
#}

#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Classy::Default
# ----------------------------------------------------------------------
#doc Default title {
#Default
#} index {
# Common tools
#} shortdescr {
# class (not a widget) used by the default mechanism
#Default
#} descr {
# subclass of <a href="Class.html">Class</a><br>
# The class Default is used to query and change default values
# in ClassyTk programs. This is done by calling methods from
# the class Classy::Default itself; the class is not intended
# to be instanciated.<p>
# Any list of default values in the Default system is
# identified by a type and a key. Two types are in use by
# ClassyTk Widgets:
#<dl>
#<dt>app<dd>to store default values set and queried using the 
# <a href="DefaultMenu.html">DefaultMenu</a>. These are typically
# used in all kinds of entries.
#<dt>geometry<dd>to keep the position and size of <a href="Dialog.html">
# Dialogs</a>.
#</dl>
#}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Class subclass Classy::Default

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

#doc {Default get} cmd {
#Default get type ?key? ?notfound?
#} descr {
# query the default system.
#<dl>
#<dt>no arguments<dd>return a list of all keys of type type and their values
#<dt>?key?<dd>return the defaults list associated with the key of type type
#<dt>?key? ?notfound?<dd>return the defaults list associated with the key of 
# type type. If the key does not exists, return notfound.
#</dl>
#}
Classy::Default classmethod get {type {key {}} {notfound {}}} {
	private $class defaults_$type
	if {"$key"==""} {
		if [info exists defaults_${type}] {
			return [array get defaults_${type}]
		}
	}
	if [info exists defaults_${type}($key)] {
		return [set defaults_${type}($key)]
	} else {
		return $notfound
	}
}

#doc {Default set} cmd {
#Default set type key value
#} descr {
# set the defaults list associated with key key of type type to value.
#}
Classy::Default classmethod set {type key value} {
	private $class defaults_$type
	set defaults_${type}($key) $value
}

#doc {Default unset} cmd {
#Default unset type key
#} descr {
# unset the value associated with key key of type type.
#}
Classy::Default classmethod unset {type key} {
	private $class defaults_$type
	unset defaults_${type}($key)
}

#doc {Default add} cmd {
#Default add type key value
#} descr {
# add value to the defaults list associated with key key of type type.
#}
Classy::Default classmethod add {type key value} {
	private $class defaults_$type
	if ![info exists defaults_${type}($key)] {
		set defaults_${type}($key) [list $value]
	} elseif {[lsearch -exact [set defaults_${type}($key)] $value]==-1} {
		list_unshift defaults_${type}($key) $value
	}
}

#doc {Default remove} cmd {
#Default remove type key value
#} descr {
# remove value from the defaults list associated with key key of type type.
#}
Classy::Default classmethod remove {type key value} {
	private $class defaults_$type
	if [info exists defaults_${type}($key)] {
		set defs [set defaults_${type}($key)]
		set pos [lsearch -exact $defs $value]
		if {$pos==-1} return
		if {$pos==0} {
			set temp ""
		} else {
			set temp "[lrange $defs 0 [expr $pos-1]] "
		}
		append temp [lrange $defs [expr $pos+1] end]
		set defaults_${type}($key) $temp
	}
}

#doc {Default names} cmd {
#Default names ?type? ?pattern?
#} descr {
# returns a list of all keys of type $type that match $pattern (if given).
# If type is not given, it returns a list of all types.
#}
Classy::Default classmethod names {{type {}} {pattern *}} {
	if {"$type"!=""} {
		private $class defaults_$type
		array names defaults_$type $pattern
	} else {
		set types ""
		foreach var [$class private] {
			if [regexp {^defaults_(.*)$} $var temp var] {
				lappend types $var
			}
		}
		return $types
	}
}

#doc {Default load} cmd {
#Default load ?type? ?file?
#} descr {
# Without arguments, all default values are reloaded. If type
# is given, only the defaults of type type will be reloaded.
# If file is specified, the values will be loaded from file rather
# than the normal loacation.
#}
Classy::Default classmethod load {{type {}} {file {}}} {
	if {"$type" == ""} {
		foreach dir [set ::Classy::dirs] {
			set dir [file join $dir def]
			foreach type [dirglob $dir *] {
				private $class defaults_$type
				if [file exists [file join $dir $type]] {
					catch {array set defaults_$type [file_read [file join $dir $type]]}
				}
			}
		}
		return {}
	}
	private $class defaults_$type
	if [string length $file] {
		array set defaults_$type [file_read $file]
		return
	}
	set file $type.def
	foreach dir [set ::Classy::dirs] {
		set dir [file join $dir def]
		foreach file [dirglob $dir *] {
			if [file exists [file join $dir $type]] {
				catch {array set defaults_$type [file_read [file join $dir $file]]}
			}
		}
	}
}

#doc {Default save} cmd {
#Default save ?type? ?file?
#} descr {
# Without arguments, all default values are saved. If type
# is given, only the defaults of type type will be saved.
# If file is specified, the values will be saved to file rather
# than the normal location.
#}
Classy::Default classmethod save {{type {}} {file {}}} {
	if {"$type" == ""} {
		set todo [$class names]
	} else {
		set todo $type
	}
	set workdir [file join $::Classy::dira(appuser) def]
	if ![file writable $workdir] {
		return "not saved"
	}
	foreach type $todo {
		private $class defaults_$type
		set f [open [file join $workdir $type] "w"]
		foreach {name value} [array get defaults_$type] {
			puts $f "[list $name] [list $value]"
		}
		close $f
	}
	return {}
}

#doc {Default clear} cmd {
#Default clear ?type?
#} descr {
# remove all defaults. If the type argument is given, remove only defaults
# of type type.
#}
Classy::Default classmethod clear {{type {}}} {
	if {"$type" == ""} {
		set todo [$class names]
	} else {
		set todo $type
	}
	foreach type $todo {
		private $class defaults_$type
		if [info exists defaults_$type] {unset defaults_$type}
	}
}

Classy::Default load
atexit add {
	catch {Classy::Default save}
}


#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Builder
# ----------------------------------------------------------------------
#doc Builder title {
#Builder
#} index none shortdescr {
# widget used by the ClassyTk Builder
#} descr {
# The builder is used to easily build ClassyTk applications
#}
#doc {Builder options} h2 {
#	Builder specific options
#}
#doc {Builder command} h2 {
#	Builder specific methods
#}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Classy::Toplevel subclass Classy::Builder

Classy::Builder method init {args} {
	super init -keepgeometry all -resize {10 10}
	set w [Classy::window $object]
	private $object browse
	Classy::DynaTool $object.tool -type Classy_Builder -cmdw $object
	frame $object.bframe
	Classy::TreeWidget $object.browse -width 80 -height 10 -takefocus 1 \
		-opencommand "$object opennode" \
		-closecommand "$object closenode" \
		-endnodecommand "$object selectnode" \
		-executecommand "$object openendnode"
	Classy::rebind $object.browse $object
	Classy::DynaMenu attachmainmenu Classy_Builder $object
	grid $object.tool -row 0 -columnspan 3 -sticky ew
	grid rowconfigure $object 0 -weight 0
	grid rowconfigure $object 1 -weight 1
	grid $object.browse -in $object.bframe -row 1 -column 0 -sticky nsew
	grid columnconfigure $object.bframe 0 -weight 1
	grid rowconfigure $object.bframe 1 -weight 1
	grid $object.bframe -sticky nsew
	grid columnconfigure $object 0 -weight 1	
	# REM Initialise options and variables
	# ------------------------------------
	setprivate $object defdir [file join $::Classy::appdir lib]
	# REM Create bindings
	# --------------------
	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
	Classy::todo $object _drawtree
	Classy::update Classy::Builder-init idletasks
	return $object
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------
Classy::Builder addoption -dir {dir Directory code} {
	private $object defdir
	set value [string trimright $value /]
	if {"$value" == ""} {
		if ![info exists defdir] {
			set defdir $::Classy::appdir
		} else return
	} elseif {"$value" == "code"} {
		set defdir [file join $::Classy::appdir lib]
	} elseif {"$value" == "config"} {
		set defdir [file join $::Classy::appdir conf]
	} elseif {"$value" == "help"} {
		set defdir [file join $::Classy::appdir help]
	} else {
		if ![file isdir $value] {
			set value [file dirname $value]
		}
		set defdir $value
	}
	Classy::todo $object _drawtree
}

# ------------------------------------------------------------------
#  destroy
# ------------------------------------------------------------------

#doc {Builder command destroy} cmd {
#pathname destroy 
#} descr {
#}
Classy::Builder method destroy {} {
	if {"winfo children .]" == ".classy__"} {
		if ![Classy::yorn "Close application?"] return
		exit
	}
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::Builder chainallmethods {$object.browse} Classy::TreeWidget

Classy::Builder method new {type {name {}}} {
	global auto_index
	private $object browse options defdir
	if {("$type" == "function")&&(![inlist {file function} $browse(type)])} {
		error "You can only add a function to a tcl file"
	}
	if {("$type" == "option")&&(![inlist {dialog toplevel topframe option method} $browse(type)])} {
		error "You can only add an option to a dialog, toplevel or topframe"
	}
	if {("$type" == "method")&&(![inlist {dialog toplevel topframe option method} $browse(type)])} {
		error "You can only add a method to a dialog, toplevel or topframe"
	}
	if {"$name" == ""} {
		catch {destroy $object.temp}
		Classy::InputDialog $object.temp -title "New $type" -label "Name" \
			-command [list $object new $type]
		return
	}
	set browse(type) $type
	set file $browse(file)
	if [inlist {file toplevel dialog topframe} $type] {
		if ![regexp {\.tcl$} $name] {set fname $name.tcl} else {set fname $name}
		if [file isdir $browse(file)] {
			set file [file join $browse(file) $fname]
		} else {
			set file [file join [file dir $browse(file)] $fname]
		}
		set browse(file) $file
		if [file exists $file] {
			error "file \"$file\" exists"
		}
		switch $type {
			file {
				set f [open $file w]
				puts $f "#Functions"
				close $f
				set dir [file dir $file]
				set base [list $file {} file]
				if {"$dir" == "$defdir"} {
					$object.browse addnode {} $base -text [file tail $file] -image [Classy::geticon newfile]
				} else {
					$object.browse addnode [list $dir {} dir] $base -text [file tail $file] -image [Classy::geticon newfile]
				}
			}
			dialog {set cmd Dialog}
			toplevel {set cmd Toplevel}
			topframe {set cmd Topframe}
		}
		if {"$type" != "file"} {
			set create [list Classy::$cmd subclass [list $name]]
			set code "\n[list $name] method init {args} \{"
			append code \n\t[list super init]
			append code "\n\tset window \$object"
			append code \n\t[list if {"$args" == "___Classy::Builder__create"} {return $window}]
			append code \n\t[list # Configure initial "\[$object cmdw\]"]
			append code \n\t[list if {"$args" != ""} {eval $window configure $args}]
			append code "\n\treturn \$window"
			append code \n\}
			set f [open $file w]
			puts $f $create
			puts $f $code
			close $f
			set dir [file dir $file]
			set base [list $file $name [string tolower $cmd]]
			set parent [list $dir {} dir]
			$object.browse addnode $parent $base \
				-text $name -image [Classy::geticon new[string tolower $cmd]]
		}
		return
	} elseif [string_equal $type option] {
		if ![regexp ^- $name] {set name -$name}
		if [inlist [$object infile ls $file] $name] {
			error "\"$name\" exists in file \"$file\"!"
		}
	} elseif [string_equal $type method] {
		if [string_equal $name init] {
			error "init method is reserved"
		}
		if [inlist [$object infile ls $file] $name] {
			error "\"$name\" exists in file \"$file\"!"
		}
	} elseif [string_equal $type function] {
		if [inlist [$object infile ls $file] $name] {
			error "\"$name\" exists in file \"$file\"!"
		}
		if [info exists auto_index($name)] {
			set file [lindex $auto_index($name) 1]
			if ![Classy::yorn "function \"$name\" probably exists in file \"$file\"! continue anyway?"] return
		}
		if [file isdir $file] {return -code error "please select a file instead of a directory"}
	} else {
		error "unknown type \"$type\""
	}
	switch $type {
		function {
			set f [open $file a]
			puts $f "\nproc [list $name] \{\} \{\}"
			close $f
			set pnode [list $file {} file]
		}
		option {
			foreach {ptype pname} [$object filetype $file] break
			regsub ^- $name {} name1
			set name2 "[string toupper [string index $name1 0]][string range $name1 1 end]"
			set f [open $file a]
			set line "\n$pname addoption [list $name] [list [list $name1 $name2 {}]] \{\}"
			catch {auto_load $pname}
			catch {uplevel #0 $line}
			puts $f $line
			close $f
			set pnode [list $file $pname $ptype]
		}
		method {
			foreach {ptype pname} [$object filetype $file] break
			set f [open $file a]
			set line "\n$pname method [list $name] \{\} \{\}"
			catch {uplevel #0 $line}
			puts $f $line
			close $f
			set pnode [list $file $pname $ptype]
		}
		dialog {set typecmd Dialog}
		toplevel {set typecmd Toplevel}
		topframe {set typecmd Topframe}
		default {error "unkown type: \"$type\"}
	}
	if [info exists typecmd] {
		set create \n[list Classy::$typecmd subclass [list $name]]
		set code "\n[list $name] method init {args} \{"
		append code \n\t[list super init]
		append code "\n\tset window \$object"
		append code \n\t[list if {"$args" == "___Classy::Builder__create"} {return $window}]
		append code \n\t[list # Configure initial "\[$object cmdw\]"]
		append code \n\t[list if {"$args" != ""} {eval $window configure $args}]
		append code "\n\treturn \$window"
		append code \n\}
		set f [open $file a]
		puts $f \n$create
		puts $f $code
		close $f
		set pnode [list $file {} file]
	}
	set base [list $file $name $type]
	$object.browse addnode $pnode $base -type end -text $name -image [Classy::geticon new$type]
	Classy::update Classy::Builder-new idletasks
	$object selectnode $base
}

Classy::Builder method _creatededit {w} {
	if ![winfo exists $w] {
		Classy::WindowBuilder $w
		$w place
	} else {
		$w place
	}
}

Classy::Builder method open {file function type} {
	global auto_index
	private $object browse open
#	if [$object closeedit] return
	set browse(base) [list $file $function $type]
	set browse(file) $file
	set browse(name) $function
	set browse(type) $type
	set open(type) $type
	if {"$function" == ""} {
		if ![file isdir $file] {Classy::edit $file}
		return
	}
	switch $type {
		toplevel -
		topframe -
		dialog {
			$object _creatededit $object.dedit
			$object.dedit open $file
		}
		dir {}
		file {
			if ![file isdir $file] {Classy::edit $file}
		}
		option {
			set filetype [$object filetype $file]
			$object optionedit $object.optionedit $file [lindex $filetype 1] $function $type
		}
		method {
			set filetype [$object filetype $file]
			$object methodedit $object.methodedit $file [lindex $filetype 1] $function $type
		}
		function {
			$object fedit $object.fedit $file $function $type
		}
	}
}

Classy::Builder method infile {cmd file args} {
	private $object browse
	switch $cmd {
		get {
			set function [lindex $args 0]
			set c [cmd_split [file_read $file]]
			set pos [lsearch -glob $c [list proc $function *]]
			if {$pos != -1} {
				return [lindex $c $pos]\n
			}
			set pos [lsearch -glob $c [list * subclass $function]]
			if {$pos != -1} {
				set result [lindex $c $pos]\n
				set pos [lsearch -glob $c [list $function method init *]]
				append result [lindex $c $pos]\n
				return $result
			}
			set pos [lsearch -glob $c [list * addoption $function *]]
			if {$pos != -1} {
				return [lindex $c $pos]\n
			}
			set pos [lsearch -glob $c [list * method $function *]]
			if {$pos != -1} {
				return [lindex $c $pos]\n
			}
			error "\"$function\" not found in file \"$file\""
		}
		set {
			set function [lindex $args 0]
			set code [lindex $args 1]
			set done 0
			set c [cmd_split [file_read $file]]
			switch -glob -- $code [list \
				"proc *" {
					uplevel #0 $code
					set pos [lsearch -glob $c [list proc $function *]]
					if {$pos == -1} {
						lappend c {} $code
					} else {
						set c [lreplace $c $pos $pos $code]
					}
					catch {Class::auto_mkindex [file dirname $file] *.tcl}
					set ::auto_index($function) [list source $file]
					$object infile _save $file $function $c
					Classy::delproc $function
				} \
				"* subclass *" {
					regsub "^\[^\n\]+subclass $function\n" $code {} temp
					uplevel #0 $temp
					set pos [lsearch -glob $c [list $function method init *]]
					set c [lreplace $c $pos $pos]
					set pos [lsearch -glob $c [list * subclass $function]]
					if {$pos == -1} {
						error "dialog \"$function\" not in file \"$file\""
					}
					set c [lreplace $c $pos $pos $code]
					$object infile _save $file $function $c
				} \
				"* addoption $function *" {
					uplevel #0 $code
					set pos [lsearch -glob $c "* addoption $function *"]
					if {$pos == -1} {
						lappend c {} $code
					} else {
						set c [lreplace $c $pos $pos $code]
					}
					$object infile _save $file $function $c
				} \
				"* method $function *" {
					uplevel #0 $code
					set pos [lsearch -glob $c "* method $function *"]
					if {$pos == -1} {
						lappend c {} $code
					} else {
						set c [lreplace $c $pos $pos $code]
					}
					$object infile _save $file $function $c
				} \
				default {
					error "Cannot save: unkown type"
				} \
			]
		}
		_save {
			catch {file copy -force $file $file~}
			set function [lindex $args 0]
			set c [lindex $args 1]
			set f [open $file w]
			set space 0
			foreach line $c {
				if ![string length $line] {
					if $space continue
					set space 1
				} else {
					set space 0
				}
				puts $f $line
			}
			close $f
		}
		ls {
			if [llength $args] {
				upvar [lindex $args 0] types
				set types ""
			}
			set c [cmd_split [file_read $file]]
			set result ""
			foreach line $c {
				if {"[string index $line 0]" == "#"} {
				} elseif {[llength $line] == 0} {
				} elseif {"[lindex $line 0]" == "proc"} {
					lappend types function
					lappend result [lindex $line 1]
				} elseif {"[lindex $line 1]" == "method"} {
					set name [lindex $line 2]
					if [string_equal $name init] continue
					lappend types method
					lappend result $name
				} elseif {"[lindex $line 1]" == "addoption"} {
					lappend types option
					lappend result [lindex $line 2]
				}
			}
			return $result
		}
		delete {
			set function [lindex $args 0]
			set c [cmd_split [file_read $file]]
			set pos [lsearch -glob $c [list proc $function *]]
			if {$pos != -1} {
				set c [lreplace $c $pos $pos]
				$object infile _save $file $function $c
				Classy::delproc $function
				unset -nocomplain ::auto_index($function)
				return {}
			}
			set pos [lsearch -glob $c [list * subclass $function]]
			if {$pos != -1} {
				set c [lreplace $c $pos $pos]
				set poss [list_find -glob $c [list $function addoption *]]
				set c [list_sub $c -exclude $poss]
				set poss [list_find -glob $c [list $function method *]]
				set c [list_sub $c -exclude $poss]
				$object infile _save $file $function $c
				Classy::delproc $function
				unset -nocomplain ::auto_index($function)
				return {}
			}
			set pos [lsearch -glob $c [list * method $function *]]
			if {$pos != -1} {
				set c [lreplace $c $pos $pos]
				$object infile _save $file $function $c
				catch {[lindex [lindex $c $pos] 0] deletemethod $function}
				return {}
			}
			set pos [lsearch -glob $c [list * addoption $function *]]
			if {$pos != -1} {
				set c [lreplace $c $pos $pos]
				$object infile _save $file $function $c
				return {}
			}
			error "\"$function\" not found in file \"$file\""
		}
		rename {
			set function [lindex $args 0]
			set newfunction [lindex $args 1]
			set ls [$object infile ls $file]
			if {[lsearch -exact $ls $newfunction] != -1} {
				error "proc \"$newfunction\" already exists  in file \"$file\""
			}
			if [string length [info commands $newfunction]] {
				error "command \"$newfunction\" already exists"
			}
			set c [cmd_split [file_read $file]]
			set pos [lsearch -glob $c [list proc $function *]]
			if {$pos != -1} {
				regsub "^proc $function" [lindex $c $pos] "proc $newfunction" line
				set c [lreplace $c $pos $pos $line]
				uplevel #0 $line
				$object infile _save $file $function $c
				Classy::delproc $function
				unset -nocomplain ::auto_index($function)
				catch {Class::auto_mkindex [file dirname $file] *.tcl}
				set ::auto_index($newfunction) [list source $file]
				return $newfunction
			}
			set pos [lsearch -glob $c [list * subclass $function]]
			if {$pos != -1} {
				regsub "subclass $function\$" [lindex $c $pos] "subclass $newfunction" line
				set c [lreplace $c $pos $pos $line]
				uplevel #0 $line
				set c [lreplace $c $pos $pos $line]
				uplevel #0 $line
				set poss [list_find -glob $c [list $function addoption *]]
				set poss [concat $poss [list_find -glob $c [list $function method *]]]
				foreach pos $poss {
					regsub "^$function " [lindex $c $pos] "$newfunction " line
					set c [lreplace $c $pos $pos $line]
					uplevel #0 $line
				}
				$object infile _save $file $function $c
				Classy::delproc $function
				unset -nocomplain ::auto_index($function)
				return $newfunction
			}
			set pos [lsearch -glob $c [list * method $function *]]
			if {$pos != -1} {
				regsub "method $function" [lindex $c $pos] "method $newfunction" line
				set c [lreplace $c $pos $pos $line]
				$object infile _save $file $function $c
				catch {[lindex [lindex $c $pos] 0] deletemethod $function}
				return {}
			}
			set pos [lsearch -glob $c [list * addoption $function *]]
			if {$pos != -1} {
				regsub "addoption $function" [lindex $c $pos] "addoption $newfunction" line
				set c [lreplace $c $pos $pos $line]
				$object infile _save $file $function $c
				return {}
			}
			error "\"$function\" not found in file \"$file\""
		}
		add {
			set code [lindex $args 0]
			if [string match "proc *" $code] {
				set function [lindex $code 1]
			} else {
				set split [cmd_split $code]
				set function [lindex [lindex $split 0] 2]
			}
			set funcs [$object infile ls $file]
			if {[lsearch -exact $funcs $function] != -1} {
				set num 1
				while {[lsearch -exact $funcs $function#$num] != -1} {incr num}
				set newfunction $function#$num
				switch -glob -- $code {
					"proc *" {
						regsub "^proc $function" $code "proc $newfunction" code
					}
					"* subclass *" {
						set newcode ""
						foreach line $split {
							regsub "subclass $function\$" $line "subclass $newfunction" line
							regsub "^$function " $line "$newfunction " line
							append newcode $line\n
						}
						set code $newcode
					}
					"* addoption *" {
						regsub " addoption $function" $code " addoption $newfunction" code
					}
					"* method *" {
						regsub " method $function" $code " method $newfunction" code
					}
				}
				set function $newfunction
			}
			$object infile set $file $function $code
		}
	}
}

Classy::Builder method cut {} {
	$object copy
	$object delete
}

Classy::Builder method delete {} {
	global auto_index
	private $object options browse
	set file $browse(file)
	set pnode [$object.browse parentnode $browse(base)]
	switch $browse(type) {
		file - dialog - toplevel - topframe {
			file copy -force $file $file~
			file delete $file
			$object.browse deletenode $browse(base)
			catch {Class::auto_mkindex [file dirname $file] *.tcl}
		}
		dir - color - font - misc - key - mouse - menu - tool {
			set function $browse(name)
			$object infile delete $file $function
			$object.browse deletenode $browse(base)
		}
		{option method} {
			set function $browse(name)
			$object infile delete $file $function
			$object.browse deletenode $browse(base)
		}
		default {
			set function $browse(name)
			$object infile delete $file $function
			$object.browse deletenode $browse(base)
		}
	}
	$object selectnode $pnode
}

Classy::Builder method copy {} {
	global auto_index
	private $object options browse
	set file $browse(file)
	set browse(cliptype) $browse(type)
	switch $browse(type) {
		file - dialog - toplevel - topframe {
			set browse(clipbf) $file
			set browse(clipb) [file_read $file]
			clipboard clear
			clipboard append $browse(clipb)
			return $file
		}
		dir {
			error "Cannot copy dir to clipboard"
		}
		default {
			set browse(clipb) {}
			set function $browse(name)
			set work [$object infile get $file $function]
			set browse(clipbf) {}
			set browse(clipb) $work
			clipboard clear
			clipboard append $work
			return $work
		}
	}
}

proc Classy::renameobj {c name newname} {
	set pos [lsearch -glob $c [list * subclass $name]]
	if {$pos == -1} {
		error "\"$name\" not found"
	}
	regsub "subclass $name\$" [lindex $c $pos] "subclass $newname" line
	set c [lreplace $c $pos $pos $line]
	set poss [list_find -glob $c [list $name addoption *]]
	eval lappend poss [concat $poss [list_find -glob $c [list $name method *]]]
	foreach pos $poss {
		regsub "^$name " [lindex $c $pos] "$newname " line
		set c [lreplace $c $pos $pos $line]
	}
	return $c
}

Classy::Builder method paste {{file {}}} {
	global auto_index
	private $object options browse
	if {"$file" == ""} {
		set file $browse(file)
	}
	if [inlist {file dialog toplevel topframe} $browse(cliptype)] {
		if ![file isdir $file] {
			set file [file dir $file]
		}
		set root [list $file {} dir]
	}
	if [file isdir $file] {
		if {"$browse(clipbf)" == ""} {
			set base [file join $file clipboard]
			set ext .tcl
		} else {
			set ext [file extension $browse(clipbf)]
			set tail [file tail $browse(clipbf)]
			set base [file join $file [file root $tail]]
			set oldname [file root [file tail $base]]
		}
		if [file exists $base$ext] {
			set num 1
			while {[file exists $base#$num$ext]} {incr num}
			set base $base#$num
		}
		set file $base$ext
		set name [file root [file tail $base]]
		if [inlist {dialog toplevel topframe} $browse(cliptype)] {
			set c [cmd_split $browse(clipb)]
			set c [Classy::renameobj $c $oldname $name]
			set f [open $file w]
			foreach line $c {
				puts $f "$line"
			}
			close $f
		} else {
			file_write $file $browse(clipb)
		}
		if {"$browse(cliptype)" == "file"} {
			$object.browse addnode $root [list $file {} file] -text [file tail $file] -image [Classy::geticon newfile]
		} else {
			$object.browse addnode $root [list $file $name $browse(cliptype)] \
				-type end -text $name -image [Classy::geticon new$browse(cliptype)]
		}
	} elseif {"$browse(clipbf)" != ""} {
		error "Can only paste file in directory"
	} else {
		set node $browse(base)
		set pnode [$object.browse parentnode $browse(base)]
		$object infile add $file $browse(clipb)
		if [inlist {file toplevel dialog topframe} $browse(type)] {
			set pnode $node
		}
		$object closenode $pnode
		$object opennode $pnode
	}
}

Classy::Builder method openendnode {base} {
	private $object browse
	if {"$base" == ""} return
	set browse(base) $base
	set browse(file) [lindex $base 0]
	set browse(name) [lindex $base 1]
	set browse(type) [lindex $base 2]
	$object open $browse(file) $browse(name) $browse(type)
	$object.browse selection set $base
}

Classy::Builder method selectnode {base} {
	private $object browse defdir
	if {"$base" == ""} {
		set browse(base) $base
		set browse(file) $defdir
		set browse(name) {}
		set browse(type) dir
	} else {
		set browse(base) $base
		set browse(file) [lindex $base 0]
		set browse(name) [lindex $base 1]
		set browse(type) [lindex $base 2]
	}
	$object.browse selection set $base
}

Classy::Builder method closenode {base} {
	private $object browse
	if {"$base" == ""} return
	set browse(base) $base
	set browse(file) [lindex $base 0]
	set browse(name) [lindex $base 1]
	set browse(type) [lindex $base 2]
	$object.browse clearnode $base
#	if ![file isdir $browse(file)] {
#		catch {$object open $browse(file) $browse(name) $browse(type)}
#	}
	$object.browse selection set $base
}

Classy::Builder method filetype {file} {
	if [file isdir $file] {
		return dir
	} elseif [regexp {~$} $file]  {
		return ignore
	} elseif {"[file tail $file]" == "tclIndex"}  {
		return ignore
	} else {
		set f [open $file]
		set line ""
		while {![eof $f] && ![string length $line]} {set line [gets $f]}
		close $f
		if [regexp {^Classy::Toplevel subclass (.+)$} $line temp func] {
			return [list toplevel $func]
		} elseif [regexp {^Classy::Dialog subclass (.+)$} $line temp func] {
			return [list dialog $func]
		} elseif [regexp {^Classy::Topframe subclass (.+)$} $line temp func] {
			return [list topframe $func]
		} elseif {"[file extension $file]" == ".tcl"} {
			return tcl
		} else {
			return other
		}
	}
}

Classy::Builder method opennode {args} {
	private $object browse
	if {[llength $args] == 1} {
		set base [lindex $args 0]
		set root $base
	} else {
		set root [lindex $args 0]
		set base [lindex $args 1]
	}
	if {"$base" == ""} return
	set browse(base) $base
	set browse(file) [lindex $base 0]
	set browse(name) [lindex $base 1]
	set browse(type) [lindex $base 2]
	if [file isdir $browse(file)] {
		set list ""
		set olist ""
		foreach file [glob -nocomplain [file join $browse(file) *]] {
			foreach {type func} [$object filetype $file] {break}
			switch $type {
				dir {$object.browse addnode $root [list $file {} dir] -text [file tail $file]}
				ignore {}
				toplevel - dialog - topframe {
					$object.browse addnode $root [list $file $func $type] \
						-text $func -image [Classy::geticon new$type]
				}
				tcl {
					lappend list $file
				}
				other {
					lappend olist $file
				}
			}
		}
		foreach file [lsort $list] {
			set type file
			set image [Classy::geticon newfile]
			$object.browse addnode $root [list $file {} $type] -text [file tail $file] -image $image
		}
		foreach file [lsort $olist] {
			$object.browse addnode $root [list $file {} file] -text [file tail $file] -type end -image [Classy::geticon newfile]
		}
	} else {
		set funcs [$object infile ls $browse(file) types]
		foreach func $funcs type $types {
			$object.browse addnode $root [list $browse(file) $func $type] -type end -text $func -image [Classy::geticon new$type]
		}
	}
	$object.browse selection set $base
}

Classy::Builder method _drawtree {} {
	private $object options browse defdir
	$object.browse clearnode {}
	$object.browse addnode {} [list $defdir {} dir] -text [file tail $defdir]
	catch {Class::auto_mkindex $defdir *.tcl}
	catch {source [file join $defdir tclIndex]}
	$object opennode [list $defdir {} dir]
	$object.browse redraw
	Classy::update Classy::Builder-drawtree idletasks
	set select [lindex [$object.browse children {}] 0]
	catch {$object opennode $select}
}

Classy::Builder method fedit {w file function type} {
	set num 1
	while 1 {
		if ![winfo exists $object.fedit$num] break
		incr num
	}
	set w $object.fedit$num
	Classy::Toplevel $w -keepgeometry all -resize {2 2}
	Classy::Entry $w.args -label "$function arguments"
	Classy::Editor $w.edit -closecommand [list destroy $w]
	pack $w.args -side top -fill both
	pack $w.edit -side top -fill both -expand yes
	set code [$object infile get $file $function]
	$w.args set [lindex $code 2]
	$w.edit set [string trimright [string trimleft [lindex $code 3] "\n"] "\n"]
	$w configure -title $function
	$w.edit textchanged 0
	$w.edit configure -savecommand [list $object savefunction $w $file $function]
}

Classy::Builder method savefunction {w file function code} {
	set def "proc $function [list [$w.args get]] \{\n$code\n\}"
	uplevel #0 $def
	$object infile set $file $function $def
	$w.edit textchanged 0
	$w configure -title $function
}

Classy::Builder method methodedit {w file parent function type} {
	set num 1
	while 1 {
		if ![winfo exists $object.methodedit$num] break
		incr num
	}
	set w $object.methodedit$num
	Classy::Toplevel $w -keepgeometry all -resize {2 2}
	Classy::Entry $w.args -label "$function arguments"
	Classy::Editor $w.edit -closecommand [list destroy $w]
	pack $w.args -side top -fill both
	pack $w.edit -side top -fill both -expand yes
	set code [$object infile get $file $function]
	$w.args set [lindex $code 3]
	$w.edit set [string trimright [string trimleft [lindex $code 4] "\n"] "\n"]
	$w configure -title "$parent method $function"
	$w.edit textchanged 0
	$w.edit configure -savecommand [list $object savemethod $w $file $parent $function]
}

Classy::Builder method savemethod {w file parent function code} {
	set def "\n$parent method [list $function] [list [$w.args get]] \{\n$code\n\}"
	uplevel #0 $def
	$object infile set $file $function $def
	$w.edit textchanged 0
	$w configure -title "$parent option $function"
}

Classy::Builder method optionedit {w file parent function type} {
	set num 1
	while 1 {
		if ![winfo exists $object.fedit$num] break
		incr num
	}
	set w $object.fedit$num
	Classy::Toplevel $w -keepgeometry all -resize {2 2}
	Classy::Entry $w.name -label "Name"
	Classy::Entry $w.class -label "Class"
	Classy::Entry $w.default -label "Default"
	Classy::Editor $w.edit -closecommand [list destroy $w]
	grid $w.name $w.class $w.default -sticky we
	grid $w.edit -columnspan 3 -sticky nswe
	grid rowconfigure $w 1 -weight 1
	grid columnconfigure $w 0 -weight 1
	grid columnconfigure $w 1 -weight 1
	grid columnconfigure $w 2 -weight 1
	set code [$object infile get $file $function]
	set temp [lindex $code 3]
	$w.name set [lindex $temp 0]
	$w.class set [lindex $temp 1]
	$w.default set [lindex $temp 2]
	$w.edit set [string trimright [string trimleft [lindex $code 4] "\n"] "\n"]
	$w configure -title "$parent option $function"
	$w.edit textchanged 0
	$w.edit configure -savecommand [list $object saveoption $w $file $parent $function]
}

Classy::Builder method saveoption {w file parent function code} {
	set def "\n$parent addoption [list $function] [list [list [$w.name get] [$w.class get] [$w.default get]]] \{\n$code\n\}"
	uplevel #0 $def
	$object infile set $file $function $def
	$w.edit textchanged 0
	$w configure -title "$parent option $function"
}

Classy::Builder method rename {args} {
	if {"$args" == ""} {
		Classy::InputDialog $object.input -label "Rename \"[lindex [lindex [$object.browse selection] 0] 1]\" to" \
			-command "$object rename [$object.browse selection]"
		return
	}
	set src [lindex $args 0]
	set dst [lindex $args 1]
	switch [lindex $src 2] {
		file {
			set dst [file join [file dir $src] $dst]
			file copy [lindex $src 0] $dst
			file delete [lindex $src 0]
			set parent [$object.browse parentnode $src]
			$object.browse deletenode $src
			$object.browse addnode $parent [lreplace $src 0 0 $dst] -text [file tail $dst] -image [Classy::geticon newfile]
		}
		toplevel - dialog - topframe {
			set dstfile [file join [file dir $src] $dst.tcl]
			set c [file_read [lindex $src 0]]
			regexp "Classy::(Toplevel|Dialog|Topframe) subclass (\[^\n \t\]+)" $c temp temp oldname
			set c [cmd_split $c]
			set c [Classy::renameobj $c $oldname $dst]
			set f [open $dstfile w]
			foreach line $c {
				puts $f "$line"
			}
			close $f
			file delete [lindex $src 0]
			catch {Class::auto_mkindex [file dirname $dstfile] *.tcl}
			set parent [$object.browse parentnode $src]
			$object.browse deletenode $src
			$object.browse addnode $parent [list $dstfile $dst [lindex $src 2]] \
				-type end -text $dst -image [Classy::geticon new[lindex $src 2]]
		}
		dir {
		}
		default {
			set type [lindex $src 2]
			set parent [$object.browse parentnode $src]
			$object infile rename [lindex $src 0] [lindex $src 1] $dst
			$object.browse deletenode $src
			$object.browse addnode $parent [lreplace $src 1 1 $dst] -type end -text [file tail $dst] -image [Classy::geticon new$type]
		}
	}
}

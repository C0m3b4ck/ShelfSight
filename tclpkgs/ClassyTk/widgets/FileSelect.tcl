#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Classy::FileSelect
# ----------------------------------------------------------------------
#doc FileSelect title {
#FileSelect
#} index {
# Dialogs
#} shortdescr {
# Motif type File Selector Dialog: used by <a href="savefile.html">selectfile</a> depending on configuration
#} descr {
# subclass of <a href="Dialog.html">Dialog</a><br>
# Offers a Motif type of file selection dialog
#}
#doc {FileSelect options} h2 {
#	FileSelect specific options
#}
#doc {FileSelect command} h2 {
#	FileSelect specific methods
#}

if {"[Classy::Default get app Classy__FileSelect__curfilter]"==""} {
	Classy::Default set app Classy__FileSelect__curfilter [pwd]/*
	Classy::Default set app Classy__FileSelect__curdir [pwd]
}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Classy::Dialog subclass Classy::FileSelect

Classy::FileSelect method init {args} {
	super init
	$object add go "Select" [list $object _command] default
	set w $object.options
	checkbutton $w.hidden -text "Show (Unix) hidden files" -variable [privatevar $object hidden] \
		-command "$object configure -hidden \[getprivate $object hidden\];$object refresh"
	Classy::Entry $w.filter -label "Filter" -orient horizontal -combo 20
	listbox $w.dirs -yscrollcommand "$w.dirsbar set" -exportselection no -width 0
	scrollbar $w.dirsbar -orient vertical -command "$w.dirs yview" -takefocus 0
	listbox $w.files -yscrollcommand "$w.filesbar set" -exportselection no
	scrollbar $w.filesbar -orient vertical -command "$w.files yview" -takefocus 0
	Classy::Entry $w.file -label "File" -orient horizontal \
		-combo 20 \
		-command [list $object _entrycmd] \
		-validate [list $w.files selection clear 0 end]
	frame $w.extra
	Classy::Paned $w.pane -window $w.dirs
	grid $w.filter - - - - -sticky we
	grid $w.hidden - - - - -sticky we
	grid $w.dirs $w.dirsbar $w.pane $w.files $w.filesbar -sticky nswe
	grid $w.file - - - - -sticky we
	grid $w.extra - - - - -sticky we
	grid columnconfigure $w 0 -minsize 40
	grid columnconfigure $w 3 -weight 50
	grid rowconfigure $w 2 -weight 100
	# REM Initialise variables and options
	# ------------------------------------
	set textvarpos [lsearch -exact $args "-textvariable"]
	if {$textvarpos!=-1} {
		incr textvarpos
		upvar #0 [lindex $args $textvarpos] textvar
	}
	set filter *
	set dir ""
	if [info exists textvar] {
		if [regexp ^\{ $textvar] {
			set dir [file dir [lindex $textvar 0]]
			set filter *[file extension [lindex $textvar 0]]
		} else {
			set dir [file dir $textvar]
			set filter *[file extension $textvar]
		}
		if ![file isdir $dir] {set dir ""}
	}
	if {("[$object cget -selectmode]" != "browse")&&([llength $dir] > 1)} {
		set dir [list $dir]
	}
	if {"$dir"==""} {
		set dir [Classy::Default get app Classy__FileSelect__curdir]
	}
	if {"$dir"==""} {
		set dir [pwd]
	}
	setprivate $object options(-dir) $dir
	setprivate $object options(-filter) $filter
	if [info exists textvar] {
		$w.file nocmdset $textvar
	} else {
		$w.file nocmdset $dir
	}
	$w.filter nocmdset [file join $dir $filter]
	# REM Create bindings
	# -------------------
	$w.filter configure -command [list $object _filtercmd] -textvariable [privatevar $object options(-filter)]
	bind $w.files <<Action>> "$object dirset;focus $w.files"
	bind $w.files <<Action-ButtonRelease>> "$object dirset"
	bind $w.files <<Action-Motion>> "$object dirset;focus $w.files"
	bind $w.files <<MExecute>> "$object dirset \[$w.files get @%x,%y\]; $object invoke go;break;"
	bindtags $w.files "Listbox $w.files $object all"
	bind $w.files <<Return>> "$object dirset"
	bind $w.files <<Invoke>> "$object dirset"
	bind $w.file <<Complete>> "$w.file insert insert \[Classyfilecompletion \[$w.file get 0 insert\]\] ; break"
	bind $w.filter <<Complete>> "$w.file insert insert \[Classyfilecompletion \[$w.file get 0 insert\]\] ; break"
	bind $w.dirs <<MExecute>> "$object movedir \[$w.dirs get @%x,%y\]"
	bind $w.dirs <<Return>> "$object movedir \[$w.dirs get active\];break"
	bind $w.file.entry <<Complete>> "$w.file nocmdset \[Classyfilecomplete \[$w.file get\]\];break"
	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval {$object configure -resize {1 1}} $args}
	$w configure
	focus $w.file
	Classy::todo $object refresh
	return $object
}

Classy::FileSelect method _filtercmd {filter} {
	$object configure -filter $filter
}

Classy::FileSelect method _entrycmd {value} {
	private $object options
	if {[file isdir $value] && ![true $options(-selectdir)]} {
		$object configure -dir $value
	} else {
		$object invoke go
	}
}

Classy::FileSelect component extra {$object.options.extra}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

#doc {FileSelect options -dir} option {-dir dir Dir} descr {
#}
Classy::FileSelect addoption	-dir [list dir Dir ""] {
	private $object options
	set keep [file tail $options(-filter)]
	if {$keep == ""} {set keep *}
	set options(-filter) [file normalize [file join $value $keep]]
	Classy::todo $object refresh
}
#doc {FileSelect options -filter} option {-filter filter Filter} descr {
#}
Classy::FileSelect addoption	-filter {filter Filter *} {
	private $object options
	set value [file normalize $value]
	if {[file isdir $value]} {set value [file join $value *]}
	set options(-dir) [file dir $value]
	Classy::todo $object refresh
}
#doc {FileSelect options -hidden} option {-hidden hidden Hidden} descr {
#}
Classy::FileSelect addoption	-hidden {hidden Hidden 0} {
	Classy::todo $object refresh
}
Classy::FileSelect addoption	-transfercommand {transferCommand TransferCommand {}}

#doc {FileSelect options -command} option {-command command Command} descr {
#}
Classy::FileSelect addoption	-command [list command Command {}] {}

#doc {FileSelect options -default} option {-default default Default} descr {
#}
Classy::FileSelect chainoption -default {$object.options.file} -default

#doc {FileSelect options -combo} option {-combo combo Combo} descr {
#}
Classy::FileSelect chainoption -combo {$object.options.file} -combo

#doc {FileSelect options -combopreset} option {-combopreset comboPreset ComboPreset} descr {
#}
Classy::FileSelect chainoption -combopreset {$object.options.file} -combopreset

#doc {FileSelect options -filtercombo} option {-filtercombo filtercombo filterCombo} descr {
#}
Classy::FileSelect chainoption -filtercombo {$object.options.filter} -combo

#doc {FileSelect options -filtercombopreset} option {-filtercombopreset filtercomboPreset filterComboPreset} descr {
#}
Classy::FileSelect chainoption -filtercombopreset {$object.options.filter} -combopreset

#doc {FileSelect options -defaultfilter} option {-defaultfilter default Default} descr {
#}
Classy::FileSelect chainoption -defaultfilter {$object.options.filter} -default

#doc {FileSelect options -textvariable} option {-textvariable textVariable Variable} descr {
#}
Classy::FileSelect chainoption -textvariable {$object.options.file} -textvariable

#doc {FileSelect options -selectmode} option {-selectmode selectMode SelectMode} descr {
#}
Classy::FileSelect chainoption -selectmode {$object.options.files} -selectmode

#doc {FileSelect options -selectdir} option {-selectdir selectDir SelectDir} descr {
#}
Classy::FileSelect addoption	-selectdir [list selectDir SelectDir 0] {
	private $object options
	if {[string_equal $value $options(-selectdir)]} return
	set w $object.options
	if {$value} {
		grid forget $w.files
		grid forget $w.filesbar
		grid columnconfigure $w 3 -weight 0
		grid columnconfigure $w 0 -weight 1
	} else {
		grid $w.files -row 2 -column 3 -sticky nswe
		grid $w.filesbar -row 2 -column 4 -sticky nswe
		grid columnconfigure $w 3 -weight 50
		grid columnconfigure $w 0 -weight 0
	}
	Classy::todo $object refresh
}
# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------


#doc {FileSelect command refresh} cmd {
#pathname refresh 
#} descr {
#}
Classy::FileSelect method refresh {} {
	private $object options
	set w $object.options
	$w.dirs delete 0 end
	$w.files delete 0 end
	set pwd [pwd]
	set dir $options(-dir)
	if [file isdirectory $dir] {
		cd $dir
		$w.dirs insert end "."
		$w.dirs insert end ".."
	} else {
		return
	}
	set list ""
	if [true $options(-hidden)] {
		catch {set list [lsort [glob .*]]}
		set list [list_remove $list . ..]
	}
	catch {eval lappend list [lsort [glob *]]}
	foreach file $list {
		if [file isdir $dir/$file] {
			$w.dirs insert end $file
		} else {
			if {[string match $options(-filter) $dir/$file]} {
				$w.files insert end $file
			}
		}
	}
	Classy::Default set app Classy__FileSelect__curdir $options(-dir)
	Classy::Default set app Classy__FileSelect__curfilter $options(-filter)
	cd $pwd
	$w.filter nocmdset [file join $options(-dir) $options(-filter)]
	set file [file join $options(-dir) [file tail " "]]
	if {"[$object cget -selectmode]" == "browse"} {
		$w.file nocmdset [string trimright $file]
	} else {
		$w.file nocmdset [list [string trimright $file]]
	}
}

#doc {FileSelect command get} cmd {
#pathname get 
#} descr {
#}
Classy::FileSelect method get {} {
	private $object options
	if {"[$object cget -selectmode]" == "browse"} {
		set file [$object.options.file get]
		if {"[file pathtype $file]"=="absolute"} {
			return $file 
		} else {
			set split [file split $file]
			set split [list_remove $split .]
			return [eval file join [pwd] $split]
		}
	} else {
		set result {}
		foreach file [$object.options.file get] {
			if {"[file pathtype $file]"=="absolute"} {
				lappend result $file 
			} else {
				set split [file split $file]
				set split [list_remove $split .]
				lappend result [eval file join [pwd] $split]
			}
		}
		return $result
	}
}

#doc {FileSelect command set} cmd {
#pathname set file
#} descr {
#}
Classy::FileSelect method set {file} {
	private $object options
	if {"[file pathtype $file]"=="relative"} {
		set file [file join [pwd] $file]
	}
	set options(-dir) [file dir $file]
	$object configure -dir $options(-dir) -filter *[file extension $file]
	Classy::update Classy::FileSelect-set idletasks
	$object.options.file nocmdset $file
}


#doc {FileSelect command dirset} cmd {
#pathname dirset ?file?
#} descr {
#}
Classy::FileSelect method dirset {{file {}}} {
	private $object options
	if {"[$object cget -selectmode]" == "browse"} {
		if {"$file"!=""} {
			set temp [file join $options(-dir) $file]
		} else {
			set pos [$object.options.files curselection]
			if [string length $pos] {
				set file [$object.options.files get $pos]
			} else {
				set file $options(-dir)
			}
			set temp [file join $options(-dir) $file]
		}
	} else {
		if {"$file"!=""} {
			set temp [list [file join $options(-dir) $file]]
		} else {
			set sel [$object.options.files curselection]
			if ![llength $sel] {
				set temp [list $options(-dir)]
			} else {
				set temp ""
				foreach pos $sel {
					set file [$object.options.files get $pos]
					lappend temp [file join $options(-dir) $file]
				}
			}
		}
	}
	$object.options.file nocmdset $temp
}

#doc {FileSelect command movedir} cmd {
#pathname movedir movedir
#} descr {
#}
Classy::FileSelect method movedir {movedir} {
	private $object options
	if {"$movedir"==".."} {
		set new [file dirname $options(-dir)]
		if {("$new"=="$options(-dir)")&&("[file pathtype $options(-dir)]"!="absolute")} {
			set new [file dirname [pwd]]
		}
	} elseif {"$movedir"=="."} {
		set new $options(-dir)
	} else {
		set new [file join $options(-dir) $movedir]
	}
	$object configure -dir $new
}

Classy::FileSelect method _command {} {
	private $object options
	$object.options.file _combo_add
	set command [get options(-command) ""]
	if {"$command" != ""} {
		uplevel #0 $command [list [$object get]]
	}
}


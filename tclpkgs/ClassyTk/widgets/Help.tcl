#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Help
# ----------------------------------------------------------------------
#doc Help title {
#Help
#} index {
# Common tools
#} shortdescr {
# Help widget
#} descr {
# subclass of <a href="Dialog.html">Dialog</a><br>
# The help widget is a toplevel with a menu that displays HTML
# help files. It has all the options and methods of the 
# <a href="HTML.html">HTML widget</a>.
# It is usually called via the help command.
#}
#doc {Help options} h2 {
#	Help specific options
#}
#doc {Help command} h2 {
#	Help specific methods
#}

list_addnew ::Classy::help_path [file join $Class::dir help]
list_addnew ::Classy::help_path [file join $Classy::dir help]
list_addnew ::Classy::help_path [file join $Extral::dir docs]

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Classy::Toplevel subclass Classy::Help

Classy::Help method init {args} {
	super init
	Classy::HTML $object.html
	if {[Classy::HTML private type] ne "optcl"} {
		$object.html configure -yscrollcommand "$object.vbar set" \
			-width 10 -height 5
		# for html_library
		$object.html bindlink <<Action>> "$object gethelp \[%W linkat %x %y\]"
		$object.html bindlink <<Adjust>> {Classy::newhelp [%W linkat %x %y]}
		# for tkhtml
		scrollbar $object.vbar -orient vertical -command [list $object.html yview]
	}
	Classy::DynaMenu attachmainmenu Classy_Help $object
	Classy::DynaTool $object.tool -type Classy_Help
	$object.tool cmdw $object
	pack $object.tool -side top -fill x
	if {[Classy::HTML private type] ne "optcl"} {
		if {"[option get $object scrollSide ScrollSide]" == "right"} {
			pack $object.vbar -side right -fill y
		} else {
			pack $object.vbar -side left -fill y
		}
	}
	pack $object.html -expand yes -fill both
	private $object curfile history
	set curfile ""
	set history {}
	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
	$object place
	return $object
}

Classy::Help private generalmenu {
	action "Help on Help" {%W gethelp classy_help} <<HelpHelp>>
	action "Tcl/Tk" {%W gethelp tcltk} <<HelpTcl>>
	action "ClassyTcl" {%W gethelp ClassyTcl} <<HelpClassyTcl>>
	action "ClassyTk" {%W gethelp ClassyTk} <<HelpClassyTk>>
	action "Extral" {%W gethelp Extral} <<HelpExtral>>
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------
Classy::Help chainoptions {$object.html}
Classy::Help chainoption -background {$object} -background {$object.html} -background
Classy::Help chainoption -highlightbackground {$object} -highlightbackground {$object.html} -highlightbackground
Classy::Help chainoption -highlightcolor {$object} -highlightcolor {$object.html} -highlightcolor

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------
Classy::Help chainallmethods {$object.html} Classy::HTML

#doc {Help command gethelp} cmd {
#pathname gethelp name
#} descr {
# find a helpfile in the Classy::help_path and display it
#}
Classy::Help method gethelp {name} {
	if {"[file pathtype $name]" == "absolute"} {
		set url file:$name
	} elseif {[regexp {^http:/|^file:|^ftp:/|^data:/} $name]} {
		set url $name
	} else {
		if {"[file extension $name]" == ""} {
			set name $name.html
		}
		set i [llength $::Classy::help_path]
		incr i -1
		while {$i > -1} {
			set dir [lindex $::Classy::help_path $i]
			if {"[file pathtype $dir]" != "absolute"} {
				set dir [file join [pwd] $dir]
			}
			incr i -1
			set file [file join $dir $name]
			if [file exists $file] break
		}
		if ![file exists $file] return
		set url file:$file
	}
	$object.html _clear
	if [catch {$object.html geturl $url} result] {
		set nname [file root [file tail $name]]
		if {![string_equal $nname $name]} {
			$object gethelp $nname
		}
	}
}

#doc {Help command save} cmd {
#pathname save filename ?text?
#} descr {
# save the current content. You can save as a plain text file by 
# specifying text as a parameter
#}
Classy::Help method save {filename {how {}}} {
	private $object.html html
	if {"$how" == "text"} {
		file_write $filename [[Classy::window $object.html] get 1.0 end]
	} else {
		file_write $filename $html
	}
}

Classy::Help method historymenu {} {
	set w $object.history
	Classy::SelectDialog $w -title "Reopen list" \
		-command "$object gethelp"
	$w fill [$object.html history]
}

Classy::Help method search {what string} {
	if {"$string"==""} {return}
	switch $what {
		file {$object gethelp $string}
		word {
			set w $object.html
			# doesn't work with tkhtml
			set htmltype [Classy::HTML private type]
			if {$htmltype eq "htmllib"} {
				$w tag configure found -background red
				$w tag remove found 1.0 end
				set current 1.0
				while 1 {
					set pos [$w search -exact -nocase -count ::Classy::temp $string $current end]
					if {"$pos"==""} {break}
					set current [$w index "$pos + $::Classy::temp c"]
					$w tag add found $pos $current
				}
			} elseif {$htmltype eq "tkhtml"} {
				set source [$w source]
				set dir [file dir [$w cget -url]]
				set files {}
				while (1) {
					if {![regexp {(href|HREF) *= *"?([^<>"]+)"?} $source match temp file]} break
					if {[string_equal $file ""]} break
					lappend files [$w fullurl $file]
					regsub $match $source {href="<@>"} source
				}
				regsub -all $string $source {<b><font color=red>\0</font></b>} source
				foreach file $files {
					regsub <@> $source $file source
				}
				$w set $source
			}
		}
		grep {
			set w $object.html
			set files ""
			foreach dir $::Classy::help_path {
				foreach file [glob [file join $dir *]] {
					if ![file isdir $file] {
						set c [file_read $file]
						if [regexp -- $string $c] {
							lappend files $file
						}
					}
				}
			}
			if {"$files"==""} {error "None found";return}
			set html "Help files containing \"$string\":<p>"
			foreach file $files {
				append html "<a href=\"file:$file\">[file root [file tail $file]]</a><br>"
			}
			$object set $html
		}
	}
}

Classy::Help method edit {} {
	set url [$object.html cget -url]
	if {[regexp {^file:///*localhost(.*)$} $url temp file]} {
		edit $file
	} elseif {[regexp {^file://*(/.*)$} $url temp file]} {
		edit $file
	}
}

Classy::Help method getcontentsmenu {} {
	set current 1.0
	set w $object.html
	set contentsmenu ""
	set c [split [$w get 1.0 end] "\n"]
	set poss [list_find $c ""]
	foreach pos $poss {
		incr pos
		set line [lindex $c $pos]
		set len [llength $line]
		if {($len > 0)&&($len < 6)} {
			append contentsmenu "\t[list action "$line" "$w yview [expr {$pos+1}].0"]\n"
		}
	}
	set data "action Top {%W see 1.0} <<TopHelp>>\n$contentsmenu"
	return [list $data Classy::Help_contents]
}

Classy::Help method retry {url query result} {
	$object gethelp [file tail $url]
}

Classy::Help method getgeneralmenu {} {
	private $object generalmenu
	if [info exists generalmenu] {
		if {"$generalmenu" != ""} {
			set result $generalmenu
		} else {
			set result [getprivate $class generalmenu]
		}
	} else {
		set result [getprivate $class generalmenu]
	}
	return [list $result Classy::Help_general]
}

set ::Classy::helpfind file
proc Classy::Help_find {w} {
	Classy::Entry $w -width 30
	set p [winfo parent $w]
	return [varsubst w {
		$w configure -command {%W search $::Classy::helpfind}
	}]
}

proc Classy::newhelp {{subject {help}}} {
	set w .classy__.help
	set num 1
	while {[winfo exists $w$num] == 1} {incr num}
	set w $w$num
	Classy::Help $w
	$w gethelp $subject
}

proc Classy::help {{subject {classy_help}}} {
	if ![winfo exists .classy__.help] {
		Classy::Help .classy__.help
	}
	if ![winfo ismapped .classy__.help] {wm deiconify .classy__.help}
	raise .classy__.help
	Classy::update Classy::help idletasks
	.classy__.help configure -resize {445 395}
	.classy__.help gethelp $subject
}

# ------------------------------------------------------------------
#  destructor
# ------------------------------------------------------------------

#doc {Help command destroy} cmd {
#pathname destroy 
#} descr {
#}
Classy::Help method destroy {} {
	Classy::Default set geometry $object [winfo geometry $object]
}

proc Classy::Help_findword {w} {
	radiobutton $w -text Word -variable ::Classy::helpfind -value word
	return {}
}

proc Classy::Help_findfile {w} {
	radiobutton $w -text File -variable ::Classy::helpfind -value file
	return {}
}

proc Classy::Help_findinfile {w} {
	radiobutton $w -text "In file" -variable ::Classy::helpfind -value grep
	return {}
}


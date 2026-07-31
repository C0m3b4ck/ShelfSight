#
# Initialisation of the ClassyWidgets
# ----------------------------------- Peter De Rijk
#
# See the file "README.txt" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# ---------------------------------------------------------------

package require Tk

if {[package require Extral] < 2.0} {
	error "version conflict for package \"Extral\": need version 2.0 or later"
}

if {[package require Class] < 1.0} {
	error "version conflict for package \"Class\": need version 1.0 or later"
}

# $Format: "set ::Classy::version $ProjectMajorVersion$.$ProjectMinorVersion$"$
set ::Classy::version 1.1
# $Format: "set ::Classy::patchlevel $ProjectPatchLevel$"$
set ::Classy::patchlevel 0
package provide ClassyTk $::Classy::version

lappend auto_path [file join ${::Classy::dir} lib] [file join ${::Classy::dir} widgets] [file join ${::Classy::dir} dialogs]
namespace eval ::Classy {}

#----------------------------------------------------------------------
# Find the appdir.
#----------------------------------------------------------------------
if {"$tcl_platform(platform)"=="unix"} {
	if {"$::Classy::script"==""} {set ::Classy::script "wish"}
	if {"[file pathtype $::Classy::script]"!="absolute"} {set ::Classy::script [file join [pwd] $::Classy::script]}
	while 1 {
		if [catch {set link [file readlink $::Classy::script]}] break
		if {"[file pathtype $link]"=="absolute"} {
			set ::Classy::script $link
		} else {
			set ::Classy::script [file join [file dirname $::Classy::script] $link]
		}
	}
}
set Classy::script [file normalize $::Classy::script]
set Classy::appdir [file dir $::Classy::script]

#----------------------------------------------------------------------
# load library on Windows
#----------------------------------------------------------------------
if {"$tcl_platform(platform)"=="windows"} {
	package require pkgtools
	pkgtools::init $Classy::dir classy Classy::GetOpenFile {}
}
# ----------------------------------------------------------------------
# Change the destroy command
# ----------------------------------------------------------------------
namespace eval ::Tk {}
if {"[info commands ::Tk::destroy]" == ""} {
	rename destroy ::Tk::destroy
}

proc destroy {args} {
	foreach w $args {
		if {"$w" == "."} {
			exit
		}
		if {"$w" == ".classy__"} continue
		foreach name [array names ::Classy::busy $w,*] {
			unset ::Classy::busy($name)
		}
		foreach name [array names ::Classy::busy $w.*,*] {
			unset ::Classy::busy($name)
		}
		if {"[info commands ::Classy::Tk_$w]" != ""} {
			catch {$w destroy}
		}
		foreach c [info commands ::Classy::Tk_$w.*] {
			regexp {^::Classy::Tk_(.*)$} $c temp child
			catch {$child destroy}
		}
		Classy::destroyrebind $w
	}
	eval ::Tk::destroy [list_remove $args .classy__]
	catch {Classy::Balloon revoke}
}

if {"[info commands send]" == ""} {
	proc send {args} {
	while 1 {
		set arg [list_shift args]
		if ![regexp ^- $arg] break
		if {"$arg" == "--"} {
			list_shift args
			break
		}
		if {[llength $args] == 0} {return -code error "wrong # args: must be \"send ?options? appname args\""}
	}
   	eval uplevel #0 $args
   }
}

#proc Classy::chainw {w cw} {
#	Classy::delproc ::Tk::$w
#	rename $w ::Tk::$w
#	proc ::$w args [varsubst {w cw} {
#		set error [catch {uplevel ::Tk::$w $args} result]
#		if {($error == 1)&&([string match {bad option *} $result])} {
#			set error2 [catch {uplevel ::$cw $args} result2]
#			if {($error2 == 1)&&([string match {bad option *} $result2])} {
#				return -code $error $result
#			} else {
#				return -code $error2 $result2
#			}
#			
#		} else {
#			return -code $error $result
#		}
#	}]
#}

#----------------------------------------------------------------------
# Initialise
#----------------------------------------------------------------------
frame .classy__
entry .classy__.dummy
button .classy__.dummyb

source [file join $::Classy::dir lib Widget.tcl]
source [file join [set ::Classy::dir] lib tools.tcl]
source [file join [set ::Classy::dir] lib conf.tcl]
option add *ColorList {{blue cyan green yellow orange red magenta} {blue3 cyan3 green3 yellow3 orange3 red3 magenta3} {black gray20 gray40 gray50 gray60 gray80 white}} widgetDefault
set Classy::colors	{
	Background darkBackground lightBackground Foreground
	activeBackground activeForeground disabledForeground
	selectBackground selectForeground selectColor highlightBackground highlightColor
}
set Classy::fonts	{Font BoldFont ItalicFont BoldItalicFont NonPropFont}

puts "loading config"
Classy::initconf
puts "config done"
if {[option get . patchTk PatchTk]==1} {
	if {$tk_version < 8.4} {
		source [file join [set ::Classy::dir] patches 8.3 patchtk.tcl]
		source [file join [set ::Classy::dir] patches 8.3 miscpatches.tcl]
	} else {
		source [file join [set ::Classy::dir] patches patchtk.tcl]
		source [file join [set ::Classy::dir] patches miscpatches.tcl]
	}
}

source [file join [set ::Classy::dir] lib rebind.tcl]

# ----------------------------------------------------------------------
# Change the bgerror command
# ----------------------------------------------------------------------

source [file join $::Classy::dir lib error.tcl]

# ----------------------------------------------------------------------
# class to command table (used in Builder and Config)
# ----------------------------------------------------------------------
array set ::Classy::cmds {
	Classy::Topframe frame
	Graph blt::graph
}

atexit add {
	catch {eval destroy [winfo children .]}
}

invoke {} {
	set clicks [clock clicks]
	after 1
	set ::Classy::clickspms [expr {[clock clicks]-$clicks}]
}

# ----------------------------------------------------------------------
# version specific hacks
# ----------------------------------------------------------------------
if {$tk_version < 8.4} {
	namespace eval ::tk {}
	interp alias {} ::tk::CancelRepeat {} ::tkCancelRepeat
	interp alias {} ::tk::ButtonEnter {} ::tkButtonEnter
	interp alias {} ::tk::ButtonLeave {} ::tkButtonLeave
	interp alias {} ::tk::ButtonDown {} ::tkButtonDown
	interp alias {} ::tk::ButtonUp {} ::tkButtonUp
	interp alias {} ::tk::FocusOK {} ::tkFocusOK
	interp alias {} ::tk::MbPost {} ::tkMbPost
	interp alias {} ::tk::EntryButton1 {} ::tkEntryButton1
	upvar #0 tkPriv tk::Priv
}
option add *inactiveSelectBackground #c3c3c3 widgetDefault

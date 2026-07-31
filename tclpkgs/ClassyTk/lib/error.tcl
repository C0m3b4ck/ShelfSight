#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# New error handling
# ----------------------------------------------------------------------
#auto_load Classy::dialog
#auto_load busy
if {"[option get . bgerror Bgerror]" == "Classy"} {

if {![llength [info commands bgerror]]} {
	auto_load bgerror
}
namespace eval Tk {}
if {"[info commands ::Tk::bgerror]" == ""} {
	rename bgerror ::Tk::bgerror
}

proc bgerror {err} {
	global errorInfo errorCode
	set info $errorInfo
	set code $errorCode
	set curerr $err
	# cleanup several things that may be problematic after an error: remove busy, progress
	catch {Classy::Progress reset 1}
	::Classy::busy remove
	::Classy::msg {}
	# try tkerror if it exists
	set errorInfo $info
	set ret [catch {::tkerror $err} msg]
	if {$ret != 1} {return -code $ret $msg}
	foreach grab [grab current .] {
		grab release $grab
	}
	Classy::update bgerror idletasks
	set ::Classy::error(action) ok
	set e [catch {
		set w .bgerrorDialog.options
		if {![winfo exists .bgerrorDialog]} {
			set ::Classy::error(err) {}
			set ::Classy::error(info) {}
			set ::Classy::error(code) {}
			::Classy::Dialog .bgerrorDialog -title "Message from Tcl Script" -keepgeometry no -closebutton 0
			.bgerrorDialog add ok "OK" {} default 
			.bgerrorDialog add trace "Stack Trace" [list Classy::stacktrace]
			.bgerrorDialog persistent add trace
			# 2. Fill the top part with bitmap and message
			label $w.bitmap -bitmap error
			pack $w.bitmap -side left -padx 3m -pady 3m
		} else {
			destroy $w.msg
		}
		lappend ::Classy::error(err) $err
		lappend ::Classy::error(info) $info
		lappend ::Classy::error(code) $code
		set err [string trim [join $::Classy::error(err) \n-------\n]]\n
		if {([string length $err] > 500) || ([regexp -all \n $err] > 10)} {
			Classy::ScrolledText $w.msg -width 30 -height 5
			$w.msg insert end $err
			$w.msg configure -bd 0 -highlightthickness 0 -state disable -wrap char
		} else {
			label $w.msg -justify left -text "[string range $err 0 4000]" -wraplength 3i
		}
		pack $w.msg -side right -expand 1 -fill both -padx 3m -pady 3m
		focus .bgerrorDialog
	} result]
	set errorInfo $info
	if {$e} {
		if {[winfo exists .bgerrorDialog]} {
			destroy .bgerrorDialog
		}
		puts $info
		::tk::dialog::error::bgerror [string range $err 0 4000]
		return -code break
	}
	Classy::update bgerror idletasks
#	tkwait window .bgerrorDialog
	Classy::todo .bgerrorDialog place
	return -code break
}

proc Classy::stacktrace {{num 0}} {
	if [catch {
		if {[llength $::Classy::error(info)] > 1} {
			set info "Several successive errors were recorded. They are:"
			append info \n----------------------------------------\n
			append info [join $::Classy::error(info) \n\n----------------------------------------\n\n]
		} else {
			set info [lindex $::Classy::error(info) 0]
		}
		set w [edit]
		$w.editor.edit set $info
		$w.editor.edit textchanged 0
		wm title $w "Stack Trace"
	}] {
		Tk::bgtrace $info
	}
	# Be sure to release any grabs that might be present on the
	# screen, since they could make it impossible for the user
	# to interact with the stack trace.
	if {[grab current .] != ""} {
		grab release [grab current .]
	}
	set ::Classy::error(action) ok
}

proc ::Tk::bgtrace info {
	global tcl_platform
	set w .bgerrorTrace
	catch {destroy $w}
	toplevel $w -class ErrorTrace
	wm minsize $w 1 1
	wm title $w "Stack Trace for Error"
	wm iconname $w "Stack Trace"
	button $w.ok -text OK -command "destroy $w" -default active
	if {$tcl_platform(platform) == "macintosh"} {
		text $w.text -relief flat -bd 2 -highlightthickness 0 -setgrid true  -yscrollcommand "$w.scroll set" -width 60 -height 20
	} else {
		text $w.text -relief sunken -bd 2 -yscrollcommand "$w.scroll set"  -setgrid true -width 60 -height 20
	}
	scrollbar $w.scroll -relief sunken -command "$w.text yview"
	pack $w.ok -side bottom -padx 3m -pady 2m
	pack $w.scroll -side right -fill y
	pack $w.text -side left -expand yes -fill both
	$w.text insert 0.0 $info
	$w.text mark set insert 0.0
	bind $w <Return> "destroy $w"
	bind $w.text <Return> "destroy $w; break"
	# Center the window on the screen.
	wm withdraw $w
	Classy::update Tk::bgtrace idletasks
	set x [expr [winfo screenwidth $w]/2 - [winfo reqwidth $w]/2  - [winfo vrootx [winfo parent $w]]]
	set y [expr [winfo screenheight $w]/2 - [winfo reqheight $w]/2  - [winfo vrooty [winfo parent $w]]]
	wm geom $w +$x+$y
	wm deiconify $w
}

}


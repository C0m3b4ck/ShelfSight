#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# HTML
# ----------------------------------------------------------------------
#doc HTML title {
#HTML
#} index {
# New widgets
#} shortdescr {
# displays HTML
#} descr {
# subclass of <a href="Widget.html">Widget</a><br>
# creates a HTML display widget. 
# The HTML class is based on the <a href="http://www.hwaci.com/sw/tkhtml/">html 
# widget by D. Richard Hipp</a> if present as a loadable package. It understands 
# HTML 3.2. Forms support is not incorporated yet. 
# If the compiled html widget is not found, ClassyTk reverts to the Tcl-only html 
# library by Stephen Uhler</a> that understands HTML 2.0. 
# The HTML class adds things such as asyncronous transfers and history.
#}
#doc {HTML options} h2 {
#	HTML specific options
#}
#doc {HTML command} h2 {
#	HTML specific methods
#}

Widget subclass Classy::HTML

if {![catch {package require optcl}]} {
	Classy::HTML private type optcl
	source [file join $::Classy::dir widgets HTML-optcl.tcl]
	set ::Classy::tkhtmllib 0
} elseif {![catch {package require hv} Classy::hv]} {
	Classy::HTML destroy
	Classy::HTML-hv subclass Classy::HTML
	Classy::HTML private type hv3
	set ::Classy::tkhtmllib 0
} elseif {![catch {package require Tkhtml} Classy::tkhtmllib]} {
	if {[llength [info commands html]]} {
		if {$::Classy::tkhtmllib < 3} {
			Classy::HTML private type tkhtml
			set ::Classy::tkhtmllib 1
		} else {
			Classy::HTML private type tkhtml3
			set ::Classy::tkhtmllib 3
		}
	} else {
		Classy::HTML private type htmllib
		set ::Classy::tkhtmllib 0
	}
} else {
	Classy::HTML private type htmllib
	set ::Classy::tkhtmllib 0
	source [file join $::Classy::dir widgets HTML-htmllib.tcl]
}

if {$::Classy::tkhtmllib == 3} {
	Classy::HTML destroy
	Classy::HTML3 subclass Classy::HTML
	Classy::HTML private type tkhtml3
} elseif {$::Classy::tkhtmllib} {
	source [file join $::Classy::dir widgets HTML-tkhtml.tcl]
}

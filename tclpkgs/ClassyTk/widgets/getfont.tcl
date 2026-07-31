#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Classy::getfont
# ----------------------------------------------------------------------
#doc getfont title {
#getfont
#} index {
# Dialogs
#} shortdescr {
# returns a font selected by the user
#}
#doc {getfont getfont} cmd {
#getfont ?option value ...?
#} descr {
# returns a font selected by the user. The select method depends om the
# ClassyTk configuration. Possible options are
#<dl>
#<dt>-font
#</dl>
#}
proc Classy::getfont {args} {
	global tcl_platform
	set pos [lsearch -exact $args -command]
	if {($pos == -1)&&("$tcl_platform(platform)"=="windows")&&("[option get . getFont GetFont]"=="Win")} {
		set len [llength $args]
		if {$len==0} {
			set font ""
		} elseif {[llength $args]==1} {
			set font [lindex $args 0]
		} elseif {[llength $args]==2} {
			if {[lindex $args 0]!="-font"} {
				error "Illegal option \"[lindex $args 0]\"\n must be -font"
			}
			set font [lindex $args 1]
		} else {
			error "Wrong # arguments, format is \"getfont ?-font font?\""
		}
		set family [lindex $font 0]
		if {"$family"==""} {set family Arial}
		set size [lindex $font 1]
		if {"$size"==""} {
			set size 12
		} else {
			set size [expr int($size+0.5)]
		}
		set style [list_concat [lrange $font 2 end]]
		if {"$style"==""} {set style normal}
		set result [eval {Classy::GetFont $family $size} $style]
		return $result
	} else {
		set ::Classy::temp ""
		::Classy::Dialog .classy__.fontselect -help classy_font_select \
			-closecommand {unset -nocomplain ::Classy::temp;}
		set w [.classy__.fontselect component options]
		set pos [lsearch -exact $args -command]
		if {$pos != -1} {
			set pos2 [expr {$pos+1}]
			.classy__.fontselect add go "Select" "[lindex $args $pos2] \[$w.fontselect get\]" default
			set args [lreplace $args $pos $pos2]
			.classy__.fontselect persistent add go
		} else {
			.classy__.fontselect add go "Select" "set ::Classy::temp \[$w.fontselect get\]" default
		}
		::Classy::FontSelect $w.fontselect \
			-command "$w.fontselect.font nocmdset \[$w.fontselect get\]"
		if [catch {
			if {"$args"!=""} {eval $w.fontselect configure $args}
		} error] {
			destroy .classy__.fontselect
			error $error
		}
		pack $w.fontselect -fill both -expand yes
		focus $w.fontselect
		Classy::update Classy::getfont idletasks
		if {$pos == -1} {
			tkwait window .classy__.fontselect
			if {![info exists ::Classy::temp]} {
				error "No font selected"
			} else {
				return $::Classy::temp
			}
		}
	}
}

proc Classy::createfont {fontname font} {
	set font [font actual $font]
	if {"$fontname"!=""} {
		catch {font delete $fontname}
		eval {font create $fontname} $font
	} else {
		eval font create $font
	}
}

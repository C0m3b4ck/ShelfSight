#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Classy::savefile
# ----------------------------------------------------------------------
#doc savefile title {
#savefile
#} index {
# Dialogs
#} shortdescr {
# select a file name to save a file to
#}
#doc {savefile savefile} cmd {
#savefile ?option value ...?
#} descr {
# returns a filename to save a file to selected by the user. The selection
# method depends om the ClassyTk configuration. Possible options are
#<dl>
#<dt>-defaultextension
#<dt>-filetypes
#<dt>-initialdir
#<dt>-initialfile
#<dt>-title
#<dt>-filter
#<dt>-default
#<dt>-combo
#<dt>-combopreset
#<dt>-transfercommand
#<dt>-help
#</dl>
#}
proc Classy::savefile {args} {
	global tcl_platform
	Classy::parseopt $args opt {
		-defaultextension {} {}
		-filetypes {} {}
		-initialdir {} {}
		-initialfile {} {}
		-title {} {Save file}
		-filter {} *
		-default {} {}
		-combo {} 20
		-combopreset {} {}
		-transfercommand {} {}
		-help {} classy_file_save
	} remain
	if {"$remain"!=""} {
		error "Unknown options \"$remain\""
	}
	if {"$opt(-filter)" != ""} {
		set filter $opt(-filter)
		if {[file isdir $filter]} {set filter $filter/*}
	} elseif {$opt(-initialfile) != ""} {
		set filter [file dir $opt(-initialfile)]/*[file extension $opt(-initialfile)]
		set initialfile [file tail $opt(-initialfile)]
	} elseif {$opt(-initialdir) != ""} {
		set filter $opt(-initialdir)/*
	} else {
		set filter [::Classy::Default get app Classy__FileSelect__curfilter]
		if {"$filter"==""} {
			set filter [pwd]/*
		}
	}
	if {$opt(-defaultextension) ne ""} {
		set filter [file dir $filter]/*.$opt(-defaultextension)
	}
	set filter [file nativename [Classy::filefilter $filter]]
	set dir [file dir $filter]
	if {("$tcl_platform(platform)"=="windows")&&("[option get . saveFile SaveFile]"=="Win")} {
		if {"$opt(-initialfile)"==""} {
			set opt(-initialfile) $opt(-initialdir)
		}
		set driveletter [string index $opt(-initialfile) 1]
		regsub -all {[\:\*\"\|]} $opt(-initialfile) _ initialfile
		if {$driveletter eq ":"} {set initialfile [string_replace $initialfile 1 1 :]}
		set temp [file normalize [file join $dir $initialfile]]
		set dir [file dir $temp] ; set initialfile [file tail $initialfile]
		set file [tk_getSaveFile -defaultextension $opt(-defaultextension) \
					-filetypes $opt(-filetypes) -initialdir $dir \
					-initialfile $initialfile -title $opt(-title)]
		::Classy::Default set app Classy__FileSelect__curfilter [file dir $file]/*
		::Classy::Default set app Classy__FileSelect__curdir [file dir $file]
		if {$file eq ""} {
			error "No file selected"
		}
		set result $file
	} else {
		catch {destroy .classy__.selectfile}
		Classy::FileSelect .classy__.selectfile -dir $dir \
			-title $opt(-title) -command {set ::Classy::selectfile} \
			-filter $filter -help $opt(-help) \
			-default $opt(-default) -combo $opt(-combo) -combopreset $opt(-combopreset) \
			-closecommand {set ::Classy::selectfile ""}
		if {"$remain"!=""} {eval .classy__.selectfile configure $remain}
		if {"$opt(-initialfile)"!=""} {
			.classy__.selectfile set $opt(-initialfile)
		}
		tkwait window .classy__.selectfile
		if {$::Classy::selectfile eq ""} {
			error "No file selected"
		}
		set result $::Classy::selectfile
	}
	Classy::Default set app Classy__FileSelect__curfilter [list [file dirname $result]/*]
	Classy::Default set app Classy__FileSelect__curdir [list [file dirname $result]]
	return $result
}



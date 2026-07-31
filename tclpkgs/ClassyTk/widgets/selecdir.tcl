#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Classy::selectfile
# ----------------------------------------------------------------------
#doc selectfile title {
#selectfile
#} index {
# Dialogs
#} shortdescr {
# select a file to open
#}
#doc {selectfile selectdir} cmd {
#selectfile ?option value ...?
#} descr {
# returns a filename selected by the user. The selection
# method depends om the ClassyTk configuration. Possible options are
#<dl>
#<dt>-initialdir
#<dt>-title
#<dt>-filter
#<dt>-selectmode<dd>single, browse, multiple, extended or persistent
#<dt>-default
#<dt>-combo {} 20
#<dt>-combopreset {} {}
#<dt>-filtercombo {} 20
#<dt>-filtercombopreset {} {}
#<dt>-mustexist
#<dt>-filtercombo {} 20
#</dl>
#}
proc Classy::selectdir {args} {
	global tcl_platform
	Classy::parseopt $args opt {
		-initialdir {} {}
		-title {} {Select file}
		-filter {} {}
		-selectmode {single browse multiple extended persistent} browse
		-default {} {}
		-combo {} 20
		-combopreset {} {}
		-filtercombo {} 20
		-filtercombopreset {} {}
		-help {} Classy_file_select
		-mustexist {0 1} 0
	}
	if {"$opt(-filter)" != ""} {
		set filter $opt(-filter)
		if {[file isdir $filter]} {set filter $filter/*}
	} elseif {$opt(-initialdir) != ""} {
		set filter $opt(-initialdir)/*
	} else {
		set filter [::Classy::Default get app Classy__FileSelect__curfilter]
		if {"$filter"==""} {
			set filter [pwd]/*
		}
	}
	set filter [file nativename [Classy::filefilter $filter]]
	set dir [file dir $filter]
	if {("$tcl_platform(platform)"=="windows")&&("[option get . selectFile SelectFile]"=="Win")} {
		if {"$opt(-selectmode)"=="single"} {
			set opt(-selectmode) browse
		}
		set result [tk_chooseDirectory -initialdir $dir \
			-title $opt(-title) -mustexist $opt(-mustexist)]
		if {$result eq ""} {
			error "No map selected"
		}
		if {"$opt(-selectmode)"=="browse"} {
			Classy::Default set app Classy__FileSelect__curfilter [list $result/*]
			Classy::Default set app Classy__FileSelect__curdir [list $result]
			return $result
		} elseif {[llength $result]<2} {
			Classy::Default set app Classy__FileSelect__curfilter [list [file dirname [lindex $result 0]]/*]
			Classy::Default set app Classy__FileSelect__curdir [list [file dirname [lindex $result 0]]]
			return $result
		} else {
			set dir [list_shift result]
			Classy::Default set app Classy__FileSelect__curfilter [list $dir/*]
			Classy::Default set app Classy__FileSelect__curdir [list $dir]
			set temp ""
			foreach file $result {
				lappend temp [file join $dir $file]
			}
			return $temp
		}
	} else {
		catch {destroy .classy__.selectfile}
		Classy::FileSelect .classy__.selectfile -dir $dir \
			-title $opt(-title) -textvariable ::Classy::selectfile \
			-filter $filter -selectmode $opt(-selectmode) -help $opt(-help) \
			-default $opt(-default) -combo $opt(-combo) -combopreset $opt(-combopreset) \
			-filtercombo $opt(-filtercombo) -filtercombopreset $opt(-filtercombopreset) \
			-closecommand {set ::Classy::selectfile ""} -selectdir 1
		tkwait window .classy__.selectfile
		if {$::Classy::selectfile eq ""} {
			error "No map selected"
		}
		return $::Classy::selectfile
	}
}


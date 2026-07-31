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
#doc {selectfile selectfile} cmd {
#selectfile ?option value ...?
#} descr {
# returns a filename selected by the user. The selection
# method depends om the ClassyTk configuration. Possible options are
#<dl>
#<dt>-defaultextension
#<dt>-filetypes
#<dt>-initialdir
#<dt>-initialfile
#<dt>-title
#<dt>-filter
#<dt>-selectmode<dd>single, browse, multiple, extended or persistent
#<dt>-default
#<dt>-combo {} 20
#<dt>-combopreset {} {}
#<dt>-filtercombo {} 20
#<dt>-filtercombopreset {} {}
#<dt>-help
#</dl>
#}
proc Classy::selectfile {args} {
	global tcl_platform
	Classy::parseopt $args opt {
		-defaultextension {} {}
		-filetypes {} {}
		-initialdir {} {}
		-initialfile {} {}
		-title {} {Select file}
		-filter {} {}
		-selectmode {single browse multiple extended persistent} browse
		-default {} {}
		-combo {} 20
		-combopreset {} {}
		-filtercombo {} 20
		-filtercombopreset {} {}
		-help {} Classy_file_select
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
	if {("$tcl_platform(platform)"=="windows")&&("[option get . selectFile SelectFile]"=="Win")} {
		if {("$opt(-filetypes)" == "")&&("$opt(-defaultextension)" != "")} {
			set opt(-filetypes) [list \
				[list "$opt(-defaultextension) file" \
				$opt(-defaultextension)] {{All Files} *}]
		}
		if {($opt(-selectmode) eq "single") || ($opt(-selectmode) eq "browse")} {
			set multiple 0
		} else {
			set multiple 1
		}
		set driveletter [string index $opt(-initialfile) 1]
		regsub -all {[\:\*\"\|]} $opt(-initialfile) _ initialfile
		if {$driveletter eq ":"} {set initialfile [string_replace $initialfile 1 1 :]}
		set result [tk_getOpenFile -defaultextension $opt(-defaultextension) \
			-filetypes $opt(-filetypes) -initialdir $dir \
			-initialfile $initialfile -title $opt(-title) \
			-multiple $multiple]
		if {$result eq ""} {
			error "No file selected"
		}
	} else {
		catch {destroy .classy__.selectfile}
		Classy::FileSelect .classy__.selectfile -dir $dir \
			-title $opt(-title) -textvariable ::Classy::selectfile \
			-filter $filter -selectmode $opt(-selectmode) -help $opt(-help) \
			-default $opt(-default) -combo $opt(-combo) -combopreset $opt(-combopreset) \
			-filtercombo $opt(-filtercombo) -filtercombopreset $opt(-filtercombopreset) \
			-closecommand {set ::Classy::selectfile ""}
		if {"$opt(-initialfile)" != ""} {
			.classy__.selectfile set $opt(-initialfile)
		}
		tkwait window .classy__.selectfile
		if {$::Classy::selectfile eq ""} {
			error "No file selected"
		}
		set result $::Classy::selectfile
	}
	if {"$opt(-selectmode)"=="browse"} {
		Classy::Default set app Classy__FileSelect__curfilter [list [file dirname $result]/*]
		Classy::Default set app Classy__FileSelect__curdir [list [file dirname $result]]
		return $result
	} else {
		Classy::Default set app Classy__FileSelect__curfilter [list [file dirname [lindex $result 0]]/*]
		Classy::Default set app Classy__FileSelect__curdir [list [file dirname [lindex $result 0]]]
		return $result
	}
}


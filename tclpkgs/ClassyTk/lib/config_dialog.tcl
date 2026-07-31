if 0 {
	set args [list [lindex $descrlist 1]]
	set data [lindex $args 0]
	set descr [lindex $descrlist 0]
}
proc Classy::config_join {descr args} {
	set clist [map_fields $descr]
	if [regexp ^_ [lindex $clist 1]] {
		return [eval {list_concat $descr} $args]
	}
	foreach data $args {
		foreach el [map_fields $data] {
			set index [lsearch -exact $clist $el]
			if {$index != -1} {
				set cdata [map_get $descr $el]
				set ndata [map_get $data $el]
				set descr [map_set $descr $el [Classy::config_join $cdata $ndata]]
			} else {
				lappend descr $el [map_get $data [list $el]]
			}
		}
	}
	return $descr
}

proc Classy::config_changed {{value {}}} {
	upvar #0 Classy::config config
	upvar #0 Classy::configchanged configchanged
	if ![string length $value] {
		return [get config(changed) 0]
	} elseif [string_equal $value 0] {
		if [get config(changed) 0] {
			set w .classy__.config
			set title [$w cget -title]
			regsub { \*$} $title {} title
			$w configure -title $title
		}
		set config(changed) 0
	} else {
		if ![get config(changed) 0] {
			set w .classy__.config
			set title [$w cget -title]
			if ![regexp { \*$} $title] {
				append title " *"
				$w configure -title $title
			}
			set config(changed) 1
		}
		if ![string_equal $value 1] {
			set configchanged($value) 1
		}
	}
}

proc Classy::config_set {name w value} {
	upvar #0 Classy::config config
	upvar #0 Classy::configdata configdata
	set line [map_get $config(descr) $name]
	set type [string range [lindex $line 0] 1 end]
	set key [lindex $line 1]
	set configdata($type,$key) $value
	Classy::config_changed $type,$key
	if [info exists config(last)] {
		eval Classy::config_item $config(last)
	}
}

proc Classy::config_item {name w item} {
	upvar #0 Classy::config config
	upvar #0 Classy::configdata configdata
	upvar #0 Classy::configdefault configdefault
	set config(last) [list $name $w $item]
	lappend name $item
	set line [map_get $config(descr) $name]
	foreach {type key descr} $line break
	set type [string range $type 1 end]
	if [info exists configdata($type,$key)] {
		set value $configdata($type,$key)
		set color [Classy::realcolor Background]
	} elseif [info exists configdefault($type,$key)] {
		set value $configdefault($type,$key)
		append descr "\n(not set, default used)"
		set color [Classy::realcolor darkBackground]
	} else {
		append descr "\n(nowhere set, system default used)"
		set value ""
		set color [Classy::realcolor darkBackground]
	}
	$w.select configure -type $type -label [lindex $name end] -command [list Classy::config_set $name $w]
	$w.descr configure -text $descr -bg $color
	$w.select set $value
}

proc Classy::config_drawlevel {name w} {
	upvar #0 Classy::config config
	set descr [map_get $config(descr) $name]
	if [regexp ^_ [lindex [lindex $descr 1] 0]] {
		if ![winfo exists $w.list] {
			Classy::ListBox $w.list -exportselection 0
			label $w.descr -bd 2 -relief groove -anchor nw -justify left
			Classy::Selector $w.select
			frame $w.buttons
			grid $w.list -column 0 -row 0 -rowspan 3 -sticky ns
			grid $w.descr -column 1 -row 0 -sticky we
			grid $w.select -column 1 -row 1 -sticky nswe
			grid $w.buttons -column 1 -row 2 -sticky nswe
			grid rowconfigure $w 1 -weight 1
			grid columnconfigure $w 1 -weight 1
			eval $w.list insert end [list_unmerge $descr]
			$w.list configure \
				-command [list Classy::config_item $name $w] \
				-browsecommand [list Classy::config_item $name $w]
			$w.list activate 0
			$w.list selection set 0
			button $w.buttons.unset -text "Default entry" -command [list Classy::config_unset]
			button $w.buttons.unsetlist -text "Default list" -command [list Classy::config_unsetlist]
			button $w.buttons.unsetall -text "Default all" -command [list Classy::config_unsetall]
			button $w.buttons.reset -text "Reset entry" -command [list Classy::config_reset]
			button $w.buttons.resetlist -text "Reset list" -command [list Classy::config_resetlist]
			button $w.buttons.resetall -text "Reset all" -command [list Classy::config_resetall]
			pack $w.buttons.unset $w.buttons.unsetlist $w.buttons.unsetall $w.buttons.reset $w.buttons.resetlist $w.buttons.resetall -side left
		}
		focus $w.list
	} else {
		if [winfo exists $w.book] return
		Classy::NoteBook $w.book -highlightthickness 0
		set w $w.book
		pack $w -fill both -expand yes
		set num 1
		set tabs [map_fields $descr]
		foreach tab $tabs {
			set wb [frame $w.b$num]
			incr num
			set temp $name
			lappend temp $tab
			$w manage $tab $wb -command [list Classy::config_drawlevel $temp $wb]
		}
		$w select [lindex $tabs 0]
	}	
}

proc Classy::config_reset {} {
	upvar #0 Classy::config config
	upvar #0 Classy::configdata configdata
	if ![info exists config(last)] return
	set name [lindex $config(last) 0]
	lappend name [lindex $config(last) 2]
	set line [map_get $config(descr) $name]
	set type [string range [lindex $line 0] 1 end]
	set key [lindex $line 1]
	if ![catch {map_get $config(orig) $type,$key} value] {
		set configdata($type,$key) $value
	} else {
		unset -nocomplain configdata($type,$key)
	}
	eval Classy::config_item $config(last)
}

proc Classy::config_resetlist {} {
	upvar #0 Classy::config config
	upvar #0 Classy::configdata configdata
	if ![info exists config(last)] return
	set base [lindex $config(last) 0]
	set list [map_fields [map_get $config(descr) $base]]
	foreach item $list {
		set name $base
		lappend name $item
		set line [map_get $config(descr) $name]
		set type [string range [lindex $line 0] 1 end]
		set key [lindex $line 1]
		if ![catch {map_get $config(orig) $type,$key} value] {
			set configdata($type,$key) $value
		} else {
			unset -nocomplain configdata($type,$key)
		}
	}
	eval Classy::config_item $config(last)
}

proc Classy::config_resetall {} {
	upvar #0 Classy::config config
	upvar #0 Classy::configdata configdata
	unset -nocomplain configdata
	array set configdata $config(orig)
	if {[info exists config(last)]} {
		eval Classy::config_item $config(last)
	}
}

proc Classy::config_unset {} {
	upvar #0 Classy::config config
	upvar #0 Classy::configdata configdata
	if ![info exists config(last)] return
	set name [lindex $config(last) 0]
	lappend name [lindex $config(last) 2]
	set line [map_get $config(descr) $name]
	set type [string range [lindex $line 0] 1 end]
	set key [lindex $line 1]
	if {![catch {unset configdata($type,$key)}]} {
		Classy::config_changed $type,$key
	}
	eval Classy::config_item $config(last)
}

proc Classy::config_unsetlist {} {
	upvar #0 Classy::config config
	upvar #0 Classy::configdata configdata
	if ![info exists config(last)] return
	set base [lindex $config(last) 0]
	set list [map_fields [map_get $config(descr) $base]]
	foreach item $list {
		set name $base
		lappend name $item
		set line [map_get $config(descr) $name]
		set type [string range [lindex $line 0] 1 end]
		set key [lindex $line 1]
		if {![catch {unset configdata($type,$key)}]} {
			Classy::config_changed $type,$key
		}
	}
	eval Classy::config_item $config(last)
}

proc Classy::config_unsetall {} {
	upvar #0 Classy::config config
	upvar #0 Classy::configdata configdata
	foreach key [array names configdata] {
		Classy::config_changed $key
	}
	unset -nocomplain configdata
	if ![info exists config(last)] return
	eval Classy::config_item $config(last)
}

proc Classy::config_themes {args} {
	set result ""
	foreach clevel {appuser appdef user def} {
		set dir $::Classy::dira($clevel)
		set dir [file join $dir themes]
		foreach file [dirglob $dir *] {
			lappend result "$file ($clevel)"
		}
	}
	return $result
}

proc Classy::config_loadfile {file} {
	upvar #0 Classy::config config
	upvar #0 Classy::configdata configdata
	set file [lindex $file 0]
	if [Classy::yorn "Clear all settings at current level before loading settings in file \"$file\""] {
		Classy::config_unsetall
	}
	catch {destroy .classy__.config.load}
	foreach {key value} [file_read $file] {
		set configdata($key) $value
		Classy::config_changed $key
	}
	if [info exists config(last)] {
		eval Classy::config_item $config(last)
	}
	Classy::config_changed 1
}

proc Classy::config_loadtheme {theme} {
	upvar #0 Classy::config config
	upvar #0 Classy::configdata configdata
	set theme [lindex $theme 0]
	if [Classy::yorn "Clear all settings at current level before loading settings in theme \"$theme\""] {
		Classy::config_unsetall
	}
	catch {destroy .classy__.config.load}
	regexp {^(.*) \((.*)\)$} $theme temp name level
	set file [file join $Classy::dira($level) themes $name]
	foreach {key value} [file_read $file] {
		set configdata($key) $value
		Classy::config_changed $key
	}
	if [info exists config(last)] {
		eval Classy::config_item $config(last)
	}
}

proc Classy::config_deletetheme theme {
	upvar #0 Classy::config config
	upvar #0 Classy::configdata configdata
	catch {destroy .classy__.config.load}
	set theme [lindex $theme 0]
	regexp {^(.*) \((.*)\)$} $theme temp name level
	set file [file join $Classy::dira($level) themes $name]
	file delete $file
}

proc Classy::config_selecttheme {} {
	upvar #0 Classy::config config
	catch {destroy .classy__.config.load}
	set w .classy__.config.load
	Classy::Dialog $w -title "Load theme or file" -help classy_config_themes
	$w add select "Select theme" "Classy::config_loadtheme \[$w.options.theme get\]" default
	$w add load "Load theme from file" "Classy::config_loadfile \[Classy::selectfile\]" default
	$w add delete "Delete theme" "Classy::config_deletetheme \[$w.options.theme get\]"
	set w $w.options
	Classy::ListBox $w.theme -command {Classy::config_loadtheme}
	eval $w.theme insert end [Classy::config_themes]
	pack $w.theme -fill both -expand yes
	focus $w.theme
	set config(clear) 1
}

proc Classy::config_selectlevel {} {
	upvar #0 Classy::config config
	catch {destroy .classy__.config.level}
	set w .classy__.config.level
	Classy::Dialog $w -title "Select configuration level"
	set w $w.options
	Classy::OptionBox $w.level -label "Configuration Level" -orient vertical -variable ::Classy::config(level)
	$w.level add appuser "User application settings" -command {Classy::config_level appuser}
	$w.level add appdef "Default application settings" -command {Classy::config_level appdef}
	$w.level add user "User General (ClassyTk) settings" -command {Classy::config_level user}
	$w.level add def "Default ClassyTk settings" -command {Classy::config_level def}
	pack $w.level -fill x
}

proc Classy::config_save {} {
	upvar #0 Classy::config config
	upvar #0 Classy::configdata configdata
	set dir $::Classy::dira($config(level))
	if {![Classy::file_writable $dir]} {
		error "No permission to write to directory \"$dir\" that contains this configuration level"
	}
	set file [file join $dir conf]
	set f [open $file w]
	foreach key [lsort [array names configdata]] {
		regexp {^([^,]*),(.*)$} $key temp type name
		puts $f [list $key $configdata($key)]
	}
	close $f
	Classy::config_changed 0
}

proc Classy::config_saveas {level name} {
	upvar #0 Classy::configdata configdata
	if ![string_equal $level file] {
		set file [file join $Classy::dira($level) themes $name]
	} else {
		set file $name
	}
	set f [open $file w]
	foreach key [lsort [array names configdata]] {
		puts $f [list $key $configdata($key)]
	}
	close $f
	destroy .classy__.config.saveas
}

proc Classy::config_saveasdialog {} {
	set w .classy__.config.saveas
	catch {destroy $w}
	Classy::Dialog $w -title "Save configuration as" -help classy_config_saveas
	set w $w.options
	Classy::Entry $w.appuser -label "User application theme" -labelwidth 20 \
		-command {Classy::config_saveas appuser}
	Classy::Entry $w.appdef -label "Default application theme" -labelwidth 20 \
		-command {Classy::config_saveas appdef}
	Classy::Entry $w.user -label "User ClassyTk theme" -labelwidth 20 \
		-command {Classy::config_saveas user}
	Classy::Entry $w.def -label "Default ClassyTk theme" -labelwidth 20 \
		-command {Classy::config_saveas def}
	Classy::FileEntry $w.file -label "Save theme to file" -labelwidth 20 \
		-command {Classy::config_saveas file}
	pack $w.appuser -fill x
	pack $w.appdef -fill x
	pack $w.user -fill x
	pack $w.def -fill x
	pack $w.file -fill x
}

proc Classy::config_level {level} {
	upvar #0 Classy::config config
	upvar #0 Classy::configdata configdata
	upvar #0 Classy::configdefault configdefault
	upvar #0 Classy::configchanged configchanged
	if [get config(changed) 0] {
		if ![Classy::yorn "Settings have changed: Are you sure you want do discard your new settings"] {
			set config(level) $config(keeplevel)
			return
		}
	}
	set config(keeplevel) $level
	set w .classy__.config
	set title "User Configuration for application"
	set config(level) $level
	switch $level {
		appuser {set title "User application settings"}
		appdef {set title "Default application settings"}
		user {set title "User General (ClassyTk) settings"}
		def {set title "Default ClassyTk settings"}
	}
	$w configure -title $title
	unset -nocomplain configdata
	unset -nocomplain configdefault
	set config(level) $level
	set levels {def user appdef appuser}
	set pos [lsearch -exact $levels $level]
	set levels [lrange $levels 0 $pos]
	foreach clevel $levels {
		if [string_equal $level $clevel] {
			set var configdata
		} else {
			set var configdefault
		}
		set dir $::Classy::dira($clevel)
		set file [file join $dir conf]
		if [file exists $file] {
			catch {array set $var [file_read $file]}
		}
	}
	set config(orig) [array get configdata]
	Classy::config_changed 0
	unset -nocomplain configchanged
	if [info exists config(last)] {
		eval Classy::config_item $config(last)
	}
}

proc Classy::config_findkey {pos type key} {
	upvar #0 Classy::config config
	set data [map_get $config(descr) $pos]
	foreach {field value} $data {
		if [regexp ^_ [lindex $value 0]] {
			foreach {ctype ckey descr def} $value break
			if {[string_equal $ckey $key]&&[string_equal $ctype $type]} {
				lappend pos $field
				return $pos
			}
		} else {
			set tpos $pos
			lappend tpos $field
			set result [Classy::config_findkey $tpos $type $key]
			if [llength $result] {return $result}
		}
	}
	return {}
}

proc Classy::config_gotokey {key} {
	regexp {^([^,]*),(.*)$} $key temp type key
	set pos [Classy::config_findkey {} _$type $key]
	Classy::config_gotoitem $pos
}

proc Classy::config_gotoitem {name} {
	upvar #0 Classy::config config
	upvar #0 Classy::configdata configdata
	upvar #0 Classy::configdefault configdefault
	set w .classy__.config.options
	set pre {}
	foreach el $name {
		if [catch {set w [$w.book select $el]}] {
			break
		}
		lappend pre $el
	}
	set pos [lsearch -exact [$w.list get 0 end] $el]
	Classy::config_item $pre $w $el
	$w.list activate $pos
	$w.list selection clear 0 end
	$w.list selection set $pos
}

proc Classy::config_descredit {} {
	upvar #0 Classy::config config
	set file [file join $::Classy::dira(appdef) conf.descr]
	foreach {pos w tail} $config(last) break
	lappend pos $tail
	Classy::config_edit $file "destroy .classy__.config; [list Classy::config_dialog $pos]"
}

proc Classy::config_dialog {{start {}}} {
	upvar #0 Classy::config config
	upvar #0 Classy::configdata configdata
	upvar #0 Classy::configchanged configchanged
	catch {destroy .classy__.config}
	unset -nocomplain config
	unset -nocomplain configdata
	set descrlist {}
	foreach dir [list_reverse [set ::Classy::dirs]] {
		set file [file join $dir conf.descr]
		if [file exists $file] {
			catch {lappend descrlist [file_read $file]}
		}
	}
	set descr [eval Classy::config_join $descrlist]
	set w .classy__.config
	Classy::Dialog $w -title "User Configuration for application" -help classy_configure
	$w configure -help 
	$w configure -closecommand {
		if [Classy::config_changed] {
			if ![Classy::yorn "Settings have changed: Are you sure you want do discard your new settings"] return
		}
	}
	$w add save Save [list Classy::config_save]
	$w add apply Apply [list Classy::config_apply]
	$w add themes "Themes" [list Classy::config_selecttheme]
	$w add saveas "Save as" [list Classy::config_saveasdialog]
#	$w add level "Select level" [list Classy::config_selectlevel]
	$w add descr "Description ed" [list Classy::config_descredit]
	# Level select
	Classy::OptionBox $w.options.level -orient horizontal -variable ::Classy::config(level)
	$w.options.level add appuser "User application settings" -command {Classy::config_level appuser}
	$w.options.level add appdef "Default application settings" -command {Classy::config_level appdef}
	$w.options.level add user "User General (ClassyTk) settings" -command {Classy::config_level user}
	$w.options.level add def "Default ClassyTk settings" -command {Classy::config_level def}
	pack $w.options.level -fill x
	# Notebook
	set w $w.options.book
	Classy::NoteBook $w -highlightthickness 0 -width 400 -height 300
	pack $w -fill both -expand yes
	set num 1
	set tabs [map_fields $descr]
	foreach tab $tabs {
		set wb [frame $w.b$num]
		incr num
		$w manage $tab $wb -command [list Classy::config_drawlevel [list $tab] $wb]
	}
	set config(descr) $descr
	$w select [lindex $tabs 0]
	set config(level) appuser
	Classy::config_changed 0
	unset -nocomplain configchanged
	Classy::config_level appuser
	set config(keeplevel) appuser
	if [string length $start] {
		Classy::config_gotoitem $start
	}
}

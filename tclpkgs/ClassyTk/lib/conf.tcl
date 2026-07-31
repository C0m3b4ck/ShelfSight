#
# ClassyTk configuration 
# ----------------------- Peter De Rijk
#
# conf
# ----------------------------------------------------------------------

proc Classy::file_writable {name} {
	if {[file isdirectory $name]} {
		set fileName [file join $name writabletest.dummy]
		set isdir 1
	} elseif {[file exists $name]} {
		set fileName $name
		set isdir 0
	} else {
		return 0
	}
	if {[catch {open $fileName a} fp]} {
		# not writable
		return 0
	} else {
		close $fp
		if {$isdir} {
		    file delete $fileName
		}
		return 1
	}
}

invoke {} {
	global env tcl_platform script
	if [info exists env(CLASSYCONFIG)] {
		set configdir $env(CLASSYCONFIG)
	} elseif [info exists env(APPDATA)] {
		set configdir $env(APPDATA)
	} elseif [info exists env(HOME)] {
		set configdir $env(HOME)
	} else {
		set configdir [file normalize ~]
	}
	if {($tcl_platform(platform) eq "windows") && ![Classy::file_writable $configdir]} {
		package require registry
		set mydocuments [registry get "HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\User Shell Folders" Personal]
		string_change $mydocuments [list $ \\$ \\ \\\\]
		regsub -all {%([^%]+)%} $mydocuments {$env(\1)} mydocuments
		set mydocuments [subst -nobackslashes -nocommands $mydocuments]
		set configdir [file join $mydocuments {Application Data}]
		file mkdir $configdir
	}
#	if {[info exists script] && ([file normalize [pwd]] eq [file dir $script])} {
#		cd [file normalize ~]
#	}
	set ::Classy::dira(def) [file join [set ::Classy::dir] conf]
	set ::Classy::dira(user) [file join $configdir .classy][set ::Classy::version]
	set ::Classy::dira(appdef) [file join [set ::Classy::appdir] conf]
	set ::Classy::appname [tk appname]
	regsub { #[0-9]+$} $::Classy::appname {} ::Classy::appname
	if {[info exists ::Classy::appversion]} {
		append ::Classy::appname [set ::Classy::appversion]
	}
	set ::Classy::dira(appuser) [file join $configdir .classy-apps $::Classy::appname]
	set ::Classy::dirs [list \
		$::Classy::dira(def) \
		$::Classy::dira(user) \
		$::Classy::dira(appdef) \
		$::Classy::dira(appuser)]
	
	foreach type {user appuser} {
		foreach dir {themes icons def} {
			set dir [file join $::Classy::dira($type) $dir]
			catch {file mkdir $dir}
		}
	}
}

proc Classy::realcolor {color} {
	if {[lsearch -exact {Background darkBackground lightBackground Foreground activeBackground activeForeground disabledForeground selectBackground selectForeground selectColor highlightBackground highlightColor} $color] != -1} {
		set temp [option get . $color $color]
		if {"$temp" != ""} {
			set color $temp
		} else {
			switch $color {
				Background {set color [.classy__.dummyb cget -bg]}
				darkBackground  {set color [.classy__.dummyb cget -bg]}
				lightBackground  {set color [.classy__.dummy cget -bg]}
				Foreground  {set color [.classy__.dummyb cget -fg]}
				activeBackground  {set color [.classy__.dummyb cget -bg]}
				activeForeground  {set color [.classy__.dummyb cget -fg]}
				disabledForeground  {set color [.classy__.dummyb cget -fg]}
				selectBackground  {set color [.classy__.dummy cget -selectbackground]}
				selectForeground  {set color [.classy__.dummy cget -selectforeground]}
				selectColor  {set color [.classy__.dummy cget -bg]}
				highlightBackground  {set color [.classy__.dummy cget -highlightbackground]}
				highlightColor  {set color [.classy__.dummy cget -highlightcolor]}
			}
		}
	}
	if {"$color" == ""} {error "could not convert color"}
	return $color
}

proc Classy::realfont {font} {
	if {[inlist {Font BoldFont ItalicFont BoldItalicFont NonPropFont} $font]} {
		if {[package vsatisfies [package require Tk] 8.5]} {
			set temp [option get . $font $font]
			if {"$temp" != ""} {
				set font $temp
			} else {
				set temp [font actual TkDefaultFont]
				switch $font {
					Font {set font $temp}
					BoldFont {set font [map_set $temp -weight bold]}
					ItalicFont {set font [map_set $temp -slant italic]}
					BoldItalicFont {set font [map_set $temp -weight bold -slant italic]}
					NonPropFont {set font [font actual TkDefaultFont]}
				}
			}
		} else {
			set temp [option get . $font $font]
			if {"$temp" != ""} {
				set font $temp
			} else {
				set temp [font actual [.classy__.dummy cget -font]]
				switch $font {
					Font {set font $temp}
					BoldFont {set font [map_set $temp -weight bold]}
					ItalicFont {set font [map_set $temp -slant italic]}
					BoldItalicFont {set font [map_set $temp -weight bold -slant italic]}
					NonPropFont {set font [map_set $temp -family courier]}
				}
			}
		}
	}
	return $font
}

proc Classy::getpapersize {descr} {
	if {[llength $descr] != 1} {return $descr}
	set portrait 0
	set orient -p
	set p $descr
	regexp {^(.+)(-l|-p)$} $descr temp p orient
	set c [map_get [Classy::optionget . paperSizes PaperSizes {
		Letter    "612p 792p"
		Tabloid   "792p 1224p"
		Ledger    "1224p 792p"
		Legal     "612p 1008p"
		Statement "396p 612p"
		Executive "540p 720p"
		A0        "2380p 3368p"
		A1        "1684p 2380p"
		A2        "1190p 1684p"
		A3        "842p 1190p"
		A4        "595p 842p"
		A5        "420p 595p"
		B4        "729p 1032p"
		B5        "516p 729p"
		Folio     "612p 936p"
		Quarto    "610p 780p"
	}] $p]
	if {"$orient" == "-l"} {
		set c [list_reverse $c]
	}
	return $c
}

proc Classy::conf_buildcache {cachefile files} {
	set cachedir [file dir $cachefile]
	foreach file $files {
		catch {array set conf [file_read $file]}
	}
	set result ""
	foreach color {
		Background darkBackground lightBackground Foreground activeBackground activeForeground 
		disabledForeground selectBackground selectForeground selectColor highlightBackground highlightColor
	} {
		set key *$color
		set option color,*$color
		if [info exists conf($option)] {
			set value $conf($option)
			option add $key [Classy::realcolor $value] widgetDefault
			append result [list option add $key [Classy::realcolor $value] widgetDefault]\n
			unset conf($option)
		} else {
#			option add $key [Classy::realcolor $color] widgetDefault
#			append result [list option add $key [Classy::realcolor $color] widgetDefault]\n
		}
	}
	foreach option [array names conf color,*] {
		if ![info exists conf($option)] continue
		foreach {type key} [split $option ,] break
		set value $conf($option)
		option add $key [Classy::realcolor $value] widgetDefault
		append result [list option add $key [Classy::realcolor $value] widgetDefault]\n
		unset conf($option)
	}
	foreach font {Font BoldFont ItalicFont BoldItalicFont NonPropFont} {
		set key *$font
		set option font,*$font
		if [info exists conf($option)] {
			set value $conf($option)
			option add $key [Classy::realfont $value] widgetDefault
			append result [list option add $key [Classy::realfont $value] widgetDefault]\n
			unset conf($option)
		} else {
#			option add $key [Classy::realfont $font] widgetDefault
#			append result [list option add $key [Classy::realfont $font] widgetDefault]\n
		}
	}
	foreach option [array names conf font,*] {
		if ![info exists conf($option)] continue
		foreach {type key} [split $option ,] break
		set value $conf($option)
		option add $key [Classy::realfont $value] widgetDefault
		append result [list option add $key [Classy::realfont $value] widgetDefault]\n
		unset conf($option)
	}
	foreach option [array names conf key,*] {
		if ![info exists conf($option)] continue
		foreach {type key} [split $option ,] break
		set value $conf($option)
		eval {event add $key} $value
		append result [concat [list event add $key] $value]\n
		unset conf($option)
	}
	# Mouse button bindings
	# Which mousebutton does what?
	# Action = select, invoke button, ...
	# Menu = popup associated popup menu
	# Adjust = Alternative action, depends on the widget
	#          e.g. when you click on a dialog button with Action,
	#          it will execute the action, and close the dialog.
	#          Often you can use the adjust button to execute
	#          the action without closing the dialog.
	#          In entries or texts under X, it works as the copy button 
	# -----------------------------------------------------------------
	foreach {name pre num} {Action {} 1 Adjust {} 2 Menu {} 3 MAdd Control- 1 MExtend Shift- 1} {
		if [info exists conf(mouse,<<$name>>)] {
			set option mouse,<<$name>>
			set key <<$name>>
			set value $conf($option)
			regexp {^<(.*)([0-9]+)>$} $value temp pre num
			unset conf(mouse,<<$name>>)
		}
		event add <<$name>> <$pre$num>
		append result [list event add <<$name>> <$pre$num>]\n
		regsub {Button-} $pre {} pre
		foreach combo {
			ButtonRelease ButtonPress
		} {
			event add <<$name-$combo>> <${pre}$combo-$num>
			append result [list event add <<$name-$combo>> <${pre}$combo-$num>]\n
		}
		foreach combo {
			Motion Leave Enter
		} {
			event add <<$name-$combo>> <${pre}B$num-$combo>
			append result [list event add <<$name-$combo>> <${pre}B$num-$combo>]\n
		}
	}
	foreach option [array names conf mouse,*] {
		foreach {type key} [split $option ,] break
		set value $conf($option)
		eval {event add $key} $value
		append result [concat [list event add $key] $value]\n
		unset conf($option)
	}
	set menudir [file join $cachedir menu]
	catch {file delete -force $menudir}
	file mkdir $menudir
	foreach option [array names conf menu,*] {
		foreach {type key} [split $option ,] break
		set value $conf($option)
		file_write [file join $menudir $key] $value
		unset conf($option)
	}
	set toolbardir [file join $cachedir toolbar]
	catch {file delete -force $toolbardir}
	file mkdir $toolbardir
	foreach option [array names conf toolbar,*] {
		foreach {type key} [split $option ,] break
		set value $conf($option)
		file_write [file join $toolbardir $key] $value
		unset conf($option)
	}
	foreach conft [array names conf] {
		foreach {type key} [split $conft ,] break
		set value $conf($conft)
		option add $key $value widgetDefault
		append result [list option add $key $value widgetDefault]\n
	}
	file_write $cachefile $result
}

proc Classy::config_update {time {runinit 1}} {
	set time [clock scan $time]
	set todo {}
	foreach {level} {appuser user} {
		set basedir $::Classy::dira($level)
		set file [file join $basedir conf]
		if {![file exists $file]} continue
		set ftime [file mtime $file]
		if {$ftime < $time} {
			lappend todo $file
		}
	}
	if {![llength $todo]} return
	foreach file $todo {
		file delete -force $file
	}
	set file [file join [lindex $::Classy::dirs 0] conf]
	file mtime $file [clock scan now]
	if {$runinit} Classy::initconf
}

proc Classy::initconf {} {
	global tcl_platform Classy_update
	if {[info exists Classy_update]} {
		Classy::config_update $Classy_update 0
	}
	set cachefile [file join $::Classy::dira(appuser) config.cache]
	set files ""
	foreach dir [set ::Classy::dirs] {
		lappend files [file join $dir conf]
		set file [file join $dir conf_$tcl_platform(platform)]
		if {[file exists $file]} {
			lappend files $file
		}
		if {[package vsatisfies [package require Tk] 8.5]} {
			set file [file join $dir conf_$tcl_platform(platform)8.5]
			if {[file exists $file]} {
				lappend files $file
			}
		}
	}
	if {![file exists $cachefile]} {
		set makecache 1
	} else {
		set makecache 0
		set mtime [file mtime $cachefile]
		foreach file $files {
			if [catch {file mtime $file} nmtime] continue
			if {$nmtime > $mtime} {
				set makecache 1
				set nfile $file
				break
			}
		}
	}
	if $makecache {
		puts "making cache"
		if [catch {Classy::conf_buildcache $cachefile $files} result] {
			error "error while loading configuration files: $result"
		}
	} else {
		foreach event [event info] {
			event delete $event
		}
		uplevel 0 [list source $cachefile]
	}
	foreach font {Font BoldFont ItalicFont BoldItalicFont NonPropFont} {
		Classy::createfont $font [Classy::realfont $font]
	}
}

proc Classy::getconf {file} {
	foreach dir [list_reverse [set ::Classy::dirs]] {
		set result [file join $dir $file]
		if [file exists $result] break
	}
	if ![file exists $result] {error "Configuration file \"$file\" not found"}
	return $result
}

proc Classy::newconfig {type level {pos {}} {key {}} {descr {}}} {
	if {![string length $pos]||![string length $key]||![string length $descr]} {
		catch {destroy .classy__.temp}
		Classy::Dialog .classy__.temp -title "New $type"
		grid columnconfigure .classy__.temp.options 0 -weight 1
		grid rowconfigure .classy__.temp.options 1 -weight 1
		Classy::Entry .classy__.temp.options.pos -label Position
		grid .classy__.temp.options.pos -sticky we
		.classy__.temp.options.pos set $pos
		Classy::Entry .classy__.temp.options.key -label Key
		grid .classy__.temp.options.key -sticky we
		.classy__.temp.options.key set $key
		Classy::Entry .classy__.temp.options.descr -width 25 -label Description
		grid .classy__.temp.options.descr -sticky nswe
		.classy__.temp.options.descr set "description of $type"
		.classy__.temp add go "Go" "Classy::newconfig $type $level \[.classy__.temp.options.pos get\] \[.classy__.temp.options.key get\] \[.classy__.temp.options.descr get\]" default
		return
	}
	catch {set ltype [map_get {color Colors font Fonts misc Misc mouse Mouse key Keys menu Menus toolbar Toolbars} $type]}
	lappend pos $key
	switch $type {
		toolbar {
			if [inlist [Classy::DynaTool types] $key] {
				error "Toolbar \"$key\" already exists"
			}
			set file [file join $Classy::dira($level) conf.descr]
			set c [file_read $file]
			set c [map_set $c $pos [list _toolbar $key $descr {}]]
			file_write $file $c
			Classy::Config dialog -node $pos -level appdef
		}
		menu {
			if [inlist [Classy::DynaMenu types] $key] {
				error "Toolbar \"$key\" already exists"
			}
			set file [file join $Classy::dira($level) conf.descr]
			set c [file_read $file]
			set c [map_set $c $pos [list _menu $key $descr {}]]
			file_write $file $c
			Classy::Config dialog -node $pos -level appdef
		}
		default {
			error "Unkown type: \"$type\""
		}
	}
	return $pos
}

proc Classy::Config {option args} {
	set window .classy__.config
	set len [llength $args]
	switch $option {
		dialog {
			if ![winfo exists $window] {
				::Classy::config_dialog
			}
			::Classy::parseopt $args opt {
				-key {} {}
				-node {} {}
				-level {} {}
				-reload {0 1} 0
			}
			if [true $opt(-reload)] {
				::Classy::config_dialog
			}
			if [llength $opt(-node)] {
				::Classy::config_gotoitem $opt(-node)
			}
			if [llength $opt(-key)] {
				::Classy::config_gotokey $opt(-key)
			}
			if [llength $opt(-level)] {
				::Classy::config_level $opt(-level)
			}
		}
		new {
			return [eval ::Classy::newconfig $args]
		}
		find {
			unset -nocomplain result
			set pattern [lindex $args 0]
			foreach dir $::Classy::dirs {
				foreach file [glob -nocomplain [file join $dir $pattern]] {
					set result([file tail $file]) $file
				}
			}
			return [array get result]
		}
		get {
			if {($len < 2) || ($len > 3)} {
				error "format is: Classy::Config get type item ?level?"
			}
			foreach {type item level} $args break
			if {$level ne ""} {
				set list $level
			} else {
				set list {appuser appdef user def}
			}
			foreach level $list {
				set file [file join $::Classy::dira($level) conf]
				if {[file exists $file]} {
					array set configcache [file_read $file]
				}
				if {[info exists configcache($type,$item)]} {
					return $configcache($type,$item)
				}
			}
		}
		set {
			if {($len < 3) || ($len > 4)} {
				error "format is: Classy::Config set type item value ?level?"
			}
			foreach {type item value level} $args break
			if {$level ne ""} {
				set $level appuser
			}
			set file [file join $::Classy::dira($level) conf]
			if {[file exists $file]} {
				array set configcache [file_read $file]
			}
			set configcache($type,$item) $value
			file copy -force $file $file.old
			set f [open $file w]
			foreach {key value} [array get configcache] {
				puts $f [list $key $value]\n
			}
			close $f
		}
		default {
			error "Unknown option, should be one of dialog, config, get, set or new"
		}
	}
}

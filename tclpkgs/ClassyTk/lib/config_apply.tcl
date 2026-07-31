proc Classy::config_reconfigurefont list {
	foreach w $list {
		if ![catch {$w _reconfigure}] return
		set children [winfo children $w]
		if {"$children" != ""} {
			Classy::config_reconfigurefont $children
		}
		catch {set list [$w configure -font]}
		catch {$w configure -font [option get $w [lindex $list 1] [lindex $list 2]]}
	}
}

proc Classy::config_reconfigurecolor list {
	foreach w $list {
		if ![catch {$w _reconfigure}] return
		set children [winfo children $w]
		if {"$children" != ""} {
			Classy::config_reconfigurecolor $children
		}
		foreach option {
				-activebackground -activeforeground -background -disabledforeground -forground
				-highlightbackground -highlightcolor -insertbackground -selectbackground
				-selectforeground -troughcolor 
		} {
			catch {
				set list [$w configure $option]
				$w configure $option [option get $w [lindex $list 1] [lindex $list 2]]
			}
		}
	}
}

proc Classy::config_apply {} {
	upvar #0 ::Classy::config config
	upvar #0 ::Classy::configdata configdata
	upvar #0 ::Classy::configchanged configchanged
	upvar #0 ::Classy::configdefault configdefault
	foreach name [array names configchanged] {
		regexp {^([^,]*),(.*)$} $name temp type key
		if [info exists configdata($name)] {
			switch $type {
				color - font - mouse - menu - toolbar {
					set [set type]($key) $configdata($name)
				}
				key {
					set keys($key) $configdata($name)
				}
				default {set fconf($key) $configdata($name)}
			}
		} elseif [info exists configdefault($name)] {
			switch $type {
				color - font - mouse - menu - toolbar {
					set [set type]($key) $configdefault($name)
				}
				key {
					set keys($key) $configdefault($name)
				}
				default {set fconf($key) $configdefault($name)}
			}
		}
	}
	if [info exists color] {
		set all 0
		foreach option {
			Background darkBackground lightBackground Foreground activeBackground activeForeground 
			disabledForeground selectBackground selectForeground selectColor highlightBackground highlightColor
		} {
			set avoid(color,*$option) 1
			if [info exists color(*$option)] {
				option add *$option [Classy::realcolor $color(*$option)] widgetDefault
				unset color(*$option)
				set all 1
			} else {
				option add *$option [Classy::realcolor $option] widgetDefault
			}
		}
		if {$all} {
			foreach name [array names configdefault color,*] {
				if [info exists avoid($name)] continue
				regsub {^color,} $name {} key
				if [info exists color($key)] {
					set value $color($key)
				} elseif [info exists configdefault($name)] {
					set value $configdefault($name)
				}
				option add $key [Classy::realcolor $value] widgetDefault
			}
		} else {
			foreach key [array names color] {
				option add $key [Classy::realcolor $color($key)] widgetDefault
			}
		}
		Classy::config_reconfigurecolor .
	}
	if [info exists font] {
		set all 0
		unset -nocomplain avoid
		foreach option {Font BoldFont ItalicFont BoldItalicFont NonPropFont} {
			set avoid(font,*$option) 1
			if [info exists font(*$option)] {
				option add *$option [Classy::realfont $font(*$option)] widgetDefault
				unset font(*$option)
				set all 1
			} else {
				option add *$option [Classy::realfont $option] widgetDefault
			}
		}
		if {$all} {
			foreach name [array names configdefault font,*] {
				if [info exists avoid($name)] continue
				regsub {^font,} $name {} key
				if [info exists font($key)] {
					set value $font($key)
				} else {
					set value $configdefault($name)
				}
				option add $key [Classy::realfont $value] widgetDefault
			}
		} else {
			foreach key [array names font] {
				option add $key [Classy::realfont $font($key)] widgetDefault
			}
		}
		Classy::config_reconfigurefont .
	}
	if [info exists mouse] {
		foreach {name pre num} {Action {} 1 Adjust {} 2 Menu {} 3 MAdd Control- 1 MExtend Shift- 1} {
			if [info exists mouse(<<$name>>)] {
				regexp {^<(.*)([0-9]+)>$} $mouse(<<$name>>) temp pre num
				unset mouse(<<$name>>)
			} elseif [info exists configdefault(mouse,<<$name>>)] {
				foreach {type key value} $configdefault(mouse,<<$name>>) {}
				regexp {^<(.*)([0-9]+)>$} $value temp pre num
			}
			event delete <<$name>>
			event add <<$name>> <$pre$num>
			regsub {Button-} $pre {} pre
			foreach combo {
				ButtonRelease ButtonPress
			} {
				event delete <<$name-$combo>>
				event add <<$name-$combo>> <${pre}$combo-$num>
			}
			foreach combo {
				Motion Leave Enter
			} {
				event delete <<$name-$combo>>
				event add <<$name-$combo>> <${pre}B$num-$combo>
			}
		}
	}
	if [info exists key] {
		foreach key [array names keys] {
			event delete $key
			eval {event add $key} $keys($key)
		}
	}
	if [info exists menu] {
		foreach key [array names menu] {
			Classy::DynaMenu define $key $menu($key)
		}
	}
	if [info exists toolbar] {
		foreach key [array names toolbar] {
			Classy::DynaTool define $key $toolbar($key)
		}
	}
	foreach key [array names fconf] {
		option add $key $fconf($key) widgetDefault
	}
}


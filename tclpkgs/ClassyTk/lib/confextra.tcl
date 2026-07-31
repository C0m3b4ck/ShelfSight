#
# ClassyTk configuration helpers functions
# ----------------------------------------- Peter De Rijk
#
# confextra
# ----------------------------------------------------------------------

foreach name {Font BoldFont ItalicFont BoldItalicFont NonPropFont} {
	set ::Classy::optionget_special($name) font
}
foreach name {Background darkBackground lightBackground Foreground activeBackground activeForeground disabledForeground selectBackground selectForeground selectColor highlightBackground highlightColor} {
	set ::Classy::optionget_special($name) color
}

proc Classy::optionget {w name class {def {}}} {
	set result [::option get $w $name $class]
	if ![string length $result] {
		if [catch {lindex [$w configure -[string tolower $name]] 3} result] {
			if [catch {lindex [$w configure	-[string tolower $class]] 3} result] {
				set result $def
			}
		}
		if ![string length $result] {
			set result $def
		}
	}
	if [info exists ::Classy::optionget_special($result)] {
		return [Classy::real$::Classy::optionget_special($result) $result]
	} else {
		return $result
	}
}

proc Classy::getbitmap {name {reload {}}} {
	if [info exists ::Classy::bitmaps($name)] {
		if {"$reload" == ""} {
			return $::Classy::bitmaps($name)
		} else {
			unset ::Classy::bitmaps($name)
		}
	}
	set file ""
	foreach type {appuser appdef user def} {
		set base [file join $::Classy::dira($type) icons $name]
		foreach type {{} .xbm} {
			if [file exists $base$type] {
				set file $base$type
			}
		}
	}
	if {"$file" == ""} {
		error "Could not find bitmap \"$name\""
	}
	set ::Classy::bitmaps($name) "@$file"
	return "@$file"
}

proc Classy::findicon {name} {
	foreach type {appuser appdef user def} {
		set base [file join $::Classy::dira($type) icons $name]
		foreach type {{} .gif .xbm} {
			if [file exists $base$type] {
				return $base$type
			}
		}
	}
}

proc Classy::geticon {name {reload {}}} {
	if [info exists ::Classy::icons($name)] {
		if {"$reload" == ""} {
			return $::Classy::icons($name)
		} else {
			image delete $::Classy::icons($name)
			unset ::Classy::icons($name)
		}
	}
	set file [Classy::findicon $name]
	if {"$file" == ""} {
		error "Could not find icon \"$name\""
	} else {
		if {"[file extension $file]"==".xbm"} {
			image create bitmap ::Classy::icon_$name -file $file
		} else {
			image create photo ::Classy::icon_$name -file $file
		}
	}
	set ::Classy::icons($name) ::Classy::icon_$name
	return ::Classy::icon_$name
}

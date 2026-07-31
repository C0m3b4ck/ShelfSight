#
# Classy::Table
#

proc ::Classy::WindowBuilder::add_Classy::Table {object base args} {
	private $object data
	Classy::Table $base -rows 5 -cols 4
	eval $base configure $args
	return $base
}

proc ::Classy::WindowBuilder::start_Classy::Table {object base} {
	private $object data bindtags
	set bindtags($base) [bindtags $base]
	bindtags $base $data(tags)
	$object _recursestartedit $base [winfo children $base]
	$base _redraw
}

proc ::Classy::WindowBuilder::edit_Classy::Table {object w} {
	::Classy::WindowBuilder::defattredit $object $w {
		-rows Rows 0 -cols Columns 0
		-titlerows "Title rows" 0 -titlecols "Title cols" 0
		-variable "Variable" 0
		-command "Command" 1
		yscroll "Vert. scrollbar" 0 xscroll "Hor. scrollbar" 0
	} 11
}

proc ::Classy::WindowBuilder::attr_Classy::Table_xscroll {object w args} {
	private $object data
	if {"$args" == ""} {
		return [$object outw [lindex [$w cget -xscrollcommand] 0]]
	} else {
		set value [lindex $args 0]
		if {"$value" != ""} {
			set data(opt-command,$value) "\"[$object outw $w] xview\""
			set data(opt-xscrollcommand,$w) "\"[$object outw $value] set\""
			$value configure -command "$w xview"
			$w configure -xscrollcommand "$value set"
		} else {
			set scroll [lindex [$w cget -xscrollcommand] 0]
			$scroll configure -command ""
			$w configure -xscrollcommand ""
			unset -nocomplain data(opt-command,$value)
			unset -nocomplain data(opt-xscrollcommand,$w)
		}
	}
}

proc ::Classy::WindowBuilder::attr_Classy::Table_yscroll {object w args} {
	private $object data
	if {"$args" == ""} {
		return [$object outw [lindex [$w cget -yscrollcommand] 0]]
	} else {
		set value [lindex $args 0]
		if {"$value" != ""} {
			set data(opt-command,$value) "\"[$object outw $w] yview\""
			set data(opt-yscrollcommand,$w) "\"[$object outw $value] set\""
			$value configure -command "$w yview"
			$w configure -yscrollcommand "$value set"
		} else {
			set scroll [lindex [$w cget -yscrollcommand] 0]
			$scroll configure -command ""
			$w configure -yscrollcommand ""
			unset -nocomplain data(opt-command,$value)
			unset -nocomplain data(opt-yscrollcommand,$w)
		}
	}
}


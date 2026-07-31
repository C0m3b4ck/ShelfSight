#
# Classy::Canvas
#

proc ::Classy::WindowBuilder::add_Classy::Canvas {object base args} {
	private $object data
	Classy::Canvas $base -width 50 -height 50
	eval $base configure $args
	$base create image  5 5 -anchor nw -image [Classy::geticon Builder/classy__canvas]
	return $base
}

proc ::Classy::WindowBuilder::attr_Classy::Canvas_xscroll {object w args} {
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

proc ::Classy::WindowBuilder::attr_Classy::Canvas_yscroll {object w args} {
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

proc ::Classy::WindowBuilder::edit_Classy::Canvas {object w} {
	::Classy::WindowBuilder::defattredit $object $w {
		yscroll "Vert. scrollbar" 0 xscroll "Hor. scrollbar" 0 -undosteps Undosteps 0
	} 12
}


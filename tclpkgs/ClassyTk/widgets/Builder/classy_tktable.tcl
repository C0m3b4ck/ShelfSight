#
# Classy::Table
#

proc ::Classy::WindowBuilder::edit_Classy::TkTable {object w} {
	::Classy::WindowBuilder::defattredit $object $w {
		-rows Rows 0 -cols Columns 0
		-labels "Labels" 0
		-labelsort "Label Sort" 0
		-grow "Grow table when ends are reached" 0
		-variabletype "Variable Type" 0
		-variable "Variable" 0
		-command "Command" 1
		-browsecommand "Browse Command" 1
		-changedcommand "Changed Command" 1
		yscroll "Vert. scrollbar" 0 xscroll "Hor. scrollbar" 0
	} 11
}

proc ::Classy::WindowBuilder::attr_Classy::TkTable_xscroll {object w args} {
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

proc ::Classy::WindowBuilder::attr_Classy::TkTable_yscroll {object w args} {
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


#
# Classy::Text
#

proc ::Classy::WindowBuilder::add_Classy::Text {object base args} {
	Classy::Text $base -width 10 -height 5
	eval $base configure $args
	return $base
}

proc ::Classy::WindowBuilder::attr_Classy::Text_content {object w args} {
	if {"$args" == ""} {
		return [$w get]
	} else {
		$w set [lindex $args 0]
	}
}

proc ::Classy::WindowBuilder::attr_Classy::Text_xscroll {object w args} {
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

proc ::Classy::WindowBuilder::attr_Classy::Text_yscroll {object w args} {
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

proc ::Classy::WindowBuilder::edit_Classy::Text {object w} {
	::Classy::WindowBuilder::defattredit $object $w {
		yscroll "Vert. scrollbar" 0 xscroll "Hor. scrollbar" 0 -wrap Wrap 0 content Content 1
	} 12 0
}

proc ::Classy::WindowBuilder::generate_Classy::Text {object base} {
	private $object data
	set body ""
	set outw [$object outw $base]
	append body "\tClassy::Text $outw [$object getoptions $base]\n"
	append body "\t[$object gridwconf $base]\n"
	set value [string trimright [$base get] "\n "]
	if {"$value" != ""} {
		append data(parse) "\t$outw set [list $value]\n"
	}
	append body [$object generatebindings $base $outw]
	return $body
}



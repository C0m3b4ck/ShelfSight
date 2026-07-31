#
# Text
#

proc ::Classy::WindowBuilder::add_Text {object w args} {
	Text $w -width 10 -height 5
	eval $w configure $args
}

proc ::Classy::WindowBuilder::attr_Text_content {object w args} {
	if {"$args" == ""} {
		return [$w get 1.0 end]
	} else {
		$w delete 1.0 end
		$w insert end [lindex $args 0]
	}
}

proc ::Classy::WindowBuilder::attr_Text_xscroll {object w args} {
	private $object data
	if {"$args" == ""} {
		return [lindex [$w cget -xscrollcommand] 0]
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

proc ::Classy::WindowBuilder::attr_Text_yscroll {object w args} {
	private $object data
	if {"$args" == ""} {
		return [lindex [$w cget -yscrollcommand] 0]
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

proc ::Classy::WindowBuilder::edit_Text {object w} {
	::Classy::WindowBuilder::defattredit $object $w {
		yscroll "Vert. scrollbar" 0 xscroll "Hor. scrollbar" 0 -wrap Wrap 0 content Content 1
	} 12 0
}

proc ::Classy::WindowBuilder::generate_Text {object base} {
	set body ""
	set outw [$object outw $base]
	append body "\ttext $outw [$object getoptions $base]\n"
	append body "\t[$object gridwconf $base]\n"
	append body "\t$outw insert end \"[$base get 1.0 end]\"\n"
	append body [$object generatebindings $base $outw]
	return $body
}



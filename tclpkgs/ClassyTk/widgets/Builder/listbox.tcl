#
# Listbox
#
array set ::Classy::WindowBuilder::options {
	list text
}

proc ::Classy::WindowBuilder::attr_Listbox_command {object w args} {
	if {"$args" == ""} {
		return [bind $w <<MExecute>>]
	} else {
		bind $w <<MExecute>> [lindex $args 0]
	}
}

proc ::Classy::WindowBuilder::attr_Listbox_list {object w args} {
	if {"$args" == ""} {
		return [$w get 0 end]
	} else {
		$w delete 0 end
		regsub -all "\n" [lindex $args 0] { } list
		eval $w insert end $list
	}
}

proc ::Classy::WindowBuilder::attr_Listbox_xscroll {object w args} {
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

proc ::Classy::WindowBuilder::attr_Listbox_yscroll {object w args} {
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

proc ::Classy::WindowBuilder::edit_Listbox {object w} {
	::Classy::WindowBuilder::defattredit $object $w {
		yscroll "Vert. scrollbar" 0 xscroll "Hor. scrollbar" 0 command Command 1 list List 1
	} 12
}

proc ::Classy::WindowBuilder::generate_Listbox {object base} {
	set body ""
	set outw [$object outw $base]
	append body "\tlistbox $outw [$object getoptions $base]\n"
	append body "\t[$object gridwconf $base]\n"
	append body "\t$outw insert end [$base get 0 end]\n"
	append body [$object generatebindings $base $outw]
	return $body
}



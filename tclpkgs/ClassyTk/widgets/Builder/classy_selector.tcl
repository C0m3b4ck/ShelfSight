#
# Classy::Selector
#

proc ::Classy::WindowBuilder::add_Classy::Selector {object base args} {
	Classy::Selector $base -type color
	$base set white
	eval $base configure $args
	update idletasks
	return $base
}

proc ::Classy::WindowBuilder::attr_Classy::Selector_initialvalue {object w args} {
	if {"$args" == ""} {
		return [$w get]
	} else {
		$w set [lindex $args 0]
	}
}

proc ::Classy::WindowBuilder::attr_Classy::Selector_-type {object w args} {
	if {"$args" == ""} {
		return [$w cget -type]
	} else {
		$w configure -type [lindex $args 0]
		update idletasks
		$object _recursestartedit $w [winfo children $w]
	}
}

proc ::Classy::WindowBuilder::edit_Classy::Selector {object w} {
#	::Classy::WindowBuilder::defattredit $object $w {
#		-type Type 0 -variable Variable 0 -label Label 0 initialvalue "initial value" 0 -command Command 1
#	} 8 0
	::Classy::WindowBuilder::defattredit $object $w {
		-type Type 0 -variable Variable 0 -label Label 0 -command Command 1
	} 8 0
}


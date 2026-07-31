#
# Classy::OptionMenu
#

proc ::Classy::WindowBuilder::attr_Classy::OptionMenu_initialvalue {object w args} {
	if {"$args" == ""} {
		return [$w get]
	} else {
		$w set [lindex $args 0]
	}
}

proc ::Classy::WindowBuilder::edit_Classy::OptionMenu {object w} {
	private $object current
	set base $current(w)
#	::Classy::WindowBuilder::defattredit $object $w {
#		-textvariable Textvariable  0 initialvalue "initial value" 0 -command Command 1 -list List 1
#	} 10 0
	::Classy::WindowBuilder::defattredit $object $w {
		-textvariable Textvariable  0 -command Command 1 -list List 1
	} 10 0
}

proc ::Classy::WindowBuilder::generate_Classy::OptionMenu {object base} {
	private $object current data
	set outw [$object outw $base]
	set body ""
	append body "\tClassy::OptionMenu $outw [$object getoptions $base -menu]"
	append body "\n\t[$object gridwconf $base]\n"
	# append body "\t$outw set [list [$base get]]\n"
	return $body
}


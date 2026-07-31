#
# Entry
#
proc ::Classy::WindowBuilder::edit_Classy::Entry {object base} {
	::Classy::WindowBuilder::defattredit $object $base {
		-label Label 0 -textvariable Textvariable 0 
		-orient Orientation 0 -labelwidth Labelwidth 0 
		-combo Combo 0
		-combopreset ComboPreset 0
		-default Default 0
		-command Command 1
	} 12 0
}

proc ::Classy::WindowBuilder::add_Classy::Entry {object base args} {
	Classy::Entry $base -width 4 -label label
	eval $base configure $args
	return $base
}

proc ::Classy::WindowBuilder::edit_Classy::NumEntry {object base} {
	::Classy::WindowBuilder::defattredit $object $base {
		-label Label 0 -textvariable Textvariable 0 -orient Orientation 0 -labelwidth Labelwidth 0 -command Command 1
	} 10 0
}

proc ::Classy::WindowBuilder::add_Classy::NumEntry {object base args} {
	Classy::NumEntry $base -width 4 -label label
	eval $base configure $args
	return $base
}

#
# Progress
#

proc ::Classy::WindowBuilder::add_Classy::Progress {object base args} {
	Classy::Progress $base -width 50
	eval $base configure $args
	return $base
}

#
# Message
#
proc ::Classy::WindowBuilder::configure_Classy::Message {object w} {
}

proc ::Classy::WindowBuilder::edit_Classy::Message {object w} {
	::Classy::WindowBuilder::defattredit $object $w {
		-justify Justify 0 -max 100 -text Text 1
	} 8 0
}

proc ::Classy::WindowBuilder::add_Classy::Message {object base args} {
	Classy::Message $base -text message
	eval $base configure $args
	return $base
}



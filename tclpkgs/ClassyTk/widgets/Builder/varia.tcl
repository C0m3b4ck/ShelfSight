#
# Button
#

proc ::Classy::WindowBuilder::edit_Button {object w} {
	::Classy::WindowBuilder::defattredit $object $w {
		-text Text 0 -image Image 0 -anchor Anchor 0 -command Command 1
	} 8 0
}

proc ::Classy::WindowBuilder::add_button {object base args} {
	button $base -text button
	eval $base configure $args
	return $base
}

#
# Checkbutton
#

proc ::Classy::WindowBuilder::add_checkbutton {object base args} {
	checkbutton $base -text button
	eval $base configure $args
	return $base
}

proc ::Classy::WindowBuilder::edit_Checkbutton {object w} {
	::Classy::WindowBuilder::defattredit $object $w {
		-variable Variable 0 -text Text 0 -image Image 0 -anchor Anchor 0 -indicatoron Indicator 0 -command Command 1
	} 8 0
}

#
# Radiobutton
#

proc ::Classy::WindowBuilder::add_radiobutton {object base args} {
	radiobutton $base -text button
	eval $base configure $args
	return $base
}

proc ::Classy::WindowBuilder::edit_Radiobutton {object w} {
	::Classy::WindowBuilder::defattredit $object $w {
		-variable Variable 0 -value Value 0 -text Text 0 -image Image 0 -indicatoron Indicator 0 -anchor Anchor 0 -command Command 1
	} 8 0
}

#
# Label
#
proc ::Classy::WindowBuilder::edit_Label {object w} {
	::Classy::WindowBuilder::defattredit $object $w {
		-text Text 0 -image Image 0 -anchor Anchor 0 -justify Justify 0
	} 8
}

proc ::Classy::WindowBuilder::add_label {object base args} {
	label $base -text label
	eval $base configure $args
	return $base
}

#
# Entry
#
proc ::Classy::WindowBuilder::edit_Entry {object w} {
	::Classy::WindowBuilder::defattredit $object $w {
		-textvariable Textvariable 0
	} 10
}

proc ::Classy::WindowBuilder::add_entry {object base args} {
	entry $base -width 4
	eval $base configure $args
	return $base
}

#
# Scrollbar
#
proc ::Classy::WindowBuilder::attr_Scrollbar_scroll {object w args} {
	private $object data
	if {"$args" == ""} {
		return [$object outw [lindex [$w cget -command] 0]]
	} else {
		if {"[$w cget -orient]" == "horizontal"} {
			set o x
		} else {
			set o y
		}
		set value [lindex $args 0]
		set data(opt-command,$w) "\"[$object outw $value] ${o}view\""
		set data(opt-${o}scrollcommand,$value) "\"[$object outw $w] set\""
		$w configure -command "$value ${o}view"
		$value configure -${o}scrollcommand "$w set"
	}
}

proc ::Classy::WindowBuilder::edit_Scrollbar {object w} {
	::Classy::WindowBuilder::defattredit $object $w {
		scroll "Scroll window" 0 -orient Orientation 0 -command Command 1
	} 0
}

#
# Text
#

proc ::Classy::WindowBuilder::add_text {object base args} {
	text $base -width 10 -height 5
	eval $base configure $args
	return $base
}

proc ::Classy::WindowBuilder::edit_Text {object w} {
	::Classy::WindowBuilder::defattredit $object $w {
		
	} 10
}

#
# Message
#
proc ::Classy::WindowBuilder::edit_Message {object w} {
	::Classy::WindowBuilder::defattredit $object $w {
		-anchor Anchor 0 -justify Justify 0 -text Text 1
	} 8 0
}

proc ::Classy::WindowBuilder::add_message {object base args} {
	message $base -text message
	eval $base configure $args
	return $base
}



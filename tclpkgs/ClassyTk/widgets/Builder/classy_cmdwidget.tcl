#
# Classy::CmdWidget
#

proc ::Classy::WindowBuilder::add_Classy::CmdWidget {object base args} {
	Classy::CmdWidget $base -width 10 -height 5
	eval $base configure $args
	return $base
}

proc ::Classy::WindowBuilder::edit_Classy::CmdWidget {object w} {
	::Classy::WindowBuilder::defattredit $object $w {
		-prompt Prompt 0 -wrap Wrap 0
	} 12
}



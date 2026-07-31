#
# Frame
#

proc ::Classy::WindowBuilder::add_frame {object base args} {
	frame $base -bd 2 -relief groove -width 10 -height 10
	eval $base configure $args
	return $base
}

proc ::Classy::WindowBuilder::start_Frame {object base} {
	private $object data bindtags
	set bindtags($base) [bindtags $base]
	$object startedit [winfo children $base]
	if ![info exists data(bind,$base)] {
		bindtags $base $data(tags)
	}
	$object select $base
}

proc ::Classy::WindowBuilder::generate_Frame {object base} {
	set body ""
	set outw [$object outw $base]
	append body "\tframe $outw [$object getoptions $base]\n"
	append body [$object generatebindings $base $outw]
	append body "\t[$object gridwconf $base]\n"
	append body [$object generate [winfo children $base]]
	append body [$object gridconf $base]
	return $body
}

proc ::Classy::WindowBuilder::edit_Frame {object w} {
	::Classy::WindowBuilder::defattredit $object $w {
		-relief Relief 0 -borderwidth Borderwidth 0
	} 15 1
}



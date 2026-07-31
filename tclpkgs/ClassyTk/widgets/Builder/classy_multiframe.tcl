#
# Classy::MultiFrame
#

proc ::Classy::WindowBuilder::add_Classy::MultiFrame {object base args} {
	Classy::MultiFrame $base -bd 2 -relief groove -width 10 -height 10
	eval $base configure $args
	return $base
}

proc ::Classy::WindowBuilder::start_Classy::MultiFrame {object base} {
	private $object data bindtags
	set bindtags($base) [bindtags $base]
	bindtags $base $data(tags)
	$object startedit [winfo children $base]
	$base redraw
}

proc ::Classy::WindowBuilder::edit_Classy::MultiFrame {object w} {
	::Classy::WindowBuilder::defattredit $object $w {
		-relief Relief 0 -borderwidth "Border width" 0
	} 8
}

proc ::Classy::WindowBuilder::generate_Classy::MultiFrame {object base} {
	private $object current data
	set outw [$object outw $base]
	set body ""
	append body "\tClassy::MultiFrame $outw [$object getoptions $base]\n"
	append body [$object generatebindings $base $outw]
	append body "\t[$object gridwconf $base]\n"
	return $body
}


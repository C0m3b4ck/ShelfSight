#
# Classy::ScrolledFrame
#

proc ::Classy::WindowBuilder::add_Classy::ScrolledFrame {object base args} {
	private $object data
	Classy::ScrolledFrame $base -bd 2 -relief groove -width 10 -height 10
	eval $base configure $args
	return $base
}

proc ::Classy::WindowBuilder::start_Classy::ScrolledFrame {object base} {
	private $object data bindtags
	set bindtags($base) [bindtags $base]
	bindtags $base $data(tags)
	$object _recursestartedit $base [winfo children $base]
	unset -nocomplain data(redir,$base.view.frame)
	$object startedit $base.view.frame
	$object protected $base.view.frame set delete
	$base redraw
}

proc ::Classy::WindowBuilder::edit_Classy::ScrolledFrame {object w} {
	::Classy::WindowBuilder::defattredit $object $w {
		-relief Relief 0 -borderwidth "Border width" 0
	} 8
}

proc ::Classy::WindowBuilder::generate_Classy::ScrolledFrame {object base} {
	private $object current data
	set outw [$object outw $base]
	set body ""
	append body "\tClassy::ScrolledFrame $outw [$object getoptions $base]\n"
	append body [$object generatebindings $base $outw]
	append body "\t[$object gridwconf $base]\n"
	append body "\t[$object generate [winfo children $base.view.frame]]"
	return $body
}


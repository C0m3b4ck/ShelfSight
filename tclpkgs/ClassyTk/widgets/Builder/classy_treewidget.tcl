#
# Classy::TreeWidget
#

proc ::Classy::WindowBuilder::add_Classy::TreeWidget {object base args} {
	private $object data
	Classy::TreeWidget $base -width 50 -height 50
	eval $base configure $args
	$base addnode {} tree -text Tree
	return $base
}

proc ::Classy::WindowBuilder::start_Classy::TreeWidget {object base} {
	private $object data bindtags
	set bindtags($base) [bindtags $base]
	bindtags $base $data(tags)
	$object _recursestartedit $base [winfo children $base]
}

proc ::Classy::WindowBuilder::edit_Classy::TreeWidget {object w} {
	::Classy::WindowBuilder::defattredit $object $w {
		-closecommand closecommand 1 -opencommand opencommand 1
		-endnodecommand endnodecommand 1
	} 12
}



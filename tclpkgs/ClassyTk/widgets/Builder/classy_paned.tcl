#
# Classy::Paned
#

proc ::Classy::WindowBuilder::edit_Classy::Paned {object w} {
	private $object current
	set base $current(w)
	::Classy::WindowBuilder::defattredit $object $w {
		-window Window 0 -snaptoborder "Snap to border" 0 -orient Orientation 0
	} 12
}


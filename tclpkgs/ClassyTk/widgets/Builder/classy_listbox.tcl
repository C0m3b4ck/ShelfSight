#
# Classy::Listbox
#

proc ::Classy::WindowBuilder::add_Classy::ListBox {object base args} {
	Classy::ListBox $base -width 10 -height 4
	eval $base configure $args
	return $base
}

proc ::Classy::WindowBuilder::edit_Classy::ListBox {object w} {
	::Classy::WindowBuilder::defattredit $object $w {
		-width Width 0 -height Height 0 -command Command 1 -browsecommand Browsecommand 1 -content Content 1
	} 12 0
}

proc ::Classy::WindowBuilder::generate_Classy::ListBox {object base} {
	set body ""
	set outw [$object outw $base]
	append body "\tClassy::ListBox $outw [$object getoptions $base -xscrollcommand -yscrollcommand]\n"
	append body "\t[$object gridwconf $base]\n"
	append body [$object generatebindings $base $outw]
	return $body
}



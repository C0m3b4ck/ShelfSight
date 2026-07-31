#
# Classy::Fold
#

proc ::Classy::WindowBuilder::add_Classy::Fold {object base args} {
	private $object data
	Classy::Fold $base -title Fold
	eval $base configure $args
	[$base component content] configure -height 10
	return $base
}

proc ::Classy::WindowBuilder::start_Classy::Fold {object base} {
	private $object data bindtags
	set bindtags($base) [bindtags $base]
	bindtags $base $data(tags)
	foreach w {title spacer} {
		bindtags $base.$w $data(tags)
		set data(redir,$base.$w) $base
	}
	$object startedit $base.content
	$object protected $base.content set delete
}

proc ::Classy::WindowBuilder::edit_Classy::Fold {object w} {
	::Classy::WindowBuilder::defattredit $object $w {
		-title Title 0 -relief Relief 0 -borderwidth "Border width" 0 -opencommand opencommand 1
	} 8 0
}

proc ::Classy::WindowBuilder::generate_Classy::Fold {object base} {
	private $object current data
	set outw [$object outw $base]
	set body ""
	append body "\tClassy::Fold $outw [$object getoptions $base]\n"
	append body [$object generatebindings $base $outw]
	append body "\t[$object gridwconf $base]\n"
	append body "\t[$object generate [winfo children $base.content]]"
	append body "\t[$object gridconf $base.content]\n"
	return $body
}



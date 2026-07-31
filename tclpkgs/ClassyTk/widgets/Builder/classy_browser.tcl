#
# Classy::Browser
#

proc ::Classy::WindowBuilder::add_Classy::Browser {object base args} {
	private $object data
	Classy::Browser $base -width 50 -height 50 -list [glob [pwd]/*] \
		-gettext {invoke dir {file tail $dir}}
	set data(opt-list,$base) {[glob [pwd]/*]}
	eval $base configure $args
	return $base
}

proc ::Classy::WindowBuilder::start_Classy::Browser {object base} {
	private $object data bindtags
	set bindtags($base) [bindtags $base]
	bindtags $base $data(tags)
	$object _recursestartedit $base [winfo children $base]
}

proc ::Classy::WindowBuilder::edit_Classy::Browser {object w} {
	::Classy::WindowBuilder::defattredit $object $w {
		-order order 0 -data Data 0 -dataunder dataunder 0 -list list 1
		-getimage getimage 1 -gettext gettext 1 -getdata getdata 1
		
	} 12 0
}

proc ::Classy::WindowBuilder::generate_Classy::Browser {object base} {
	private $object current data
	set outw [$object outw $base]
	set body ""
	append body "\tClassy::Browser $outw [$object getoptions $base -xscrollcommand]\n"
	append body [$object generatebindings $base $outw]
	append body "\t[$object gridwconf $base]\n"
	return $body
}

array set ::Classy::WindowBuilder::options {
	-dataalign {Display int}
	-minx {Display int}
	-miny {Display int}
	-dataunder {Display bool}
	-datafont {Display font}
	-padtext {Display int}
	-order {Display order}
	-data {Display line}
}


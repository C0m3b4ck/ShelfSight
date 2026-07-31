#
# Classy::ScrolledText
#

proc ::Classy::WindowBuilder::add_Classy::ScrolledText {object base args} {
	Classy::ScrolledText $base -width 10 -height 5
	eval $base configure $args
	return $base
}

proc ::Classy::WindowBuilder::attr_Classy::ScrolledText_content {object w args} {
	if {"$args" == ""} {
		return [$w get]
	} else {
		$w set [lindex $args 0]
	}
}

proc ::Classy::WindowBuilder::attr_Classy::ScrolledText_content {object w args} {
	if {"$args" == ""} {
		return [$w get]
	} else {
		$w set [lindex $args 0]
	}
}

proc ::Classy::WindowBuilder::edit_Classy::ScrolledText {object w} {
	::Classy::WindowBuilder::defattredit $object $w {
		-wrap Wrap 0 content Content 1
	} 12 0
}

proc ::Classy::WindowBuilder::generate_Classy::ScrolledText {object base} {
	private $object data
	set body ""
	set outw [$object outw $base]
	append body "\tClassy::ScrolledText $outw [$object getoptions $base -xscrollcommand -yscrollcommand]\n"
	append body "\t[$object gridwconf $base]\n"
	set value [string trimright [$base get] "\n "]
	if {"$value" != ""} {
		append data(parse) "\t$outw set [list $value]\n"
	}
	append body [$object generatebindings $base $outw]
	return $body
}



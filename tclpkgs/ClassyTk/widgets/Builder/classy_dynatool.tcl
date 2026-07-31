#
# Classy::DynaTool
#

proc ::Classy::WindowBuilder::add_Classy::DynaTool {object base args} {
	private $object data current
	if [info exists ::Classy::targetwindow] {
		set toolwin $::Classy::targetwindow
	} else {
		set toolwin $current(w)
	}
	Classy::DynaTool $base -type Classy_Dummy -cmdw $toolwin
	set data(opt-type,$base) Classy_Dummy
	set data(opt-cmdw,$base) [$object outw $toolwin]
	return $base
}

proc ::Classy::WindowBuilder::start_Classy::DynaTool {object base} {
	private $object data bindtags
	Classy::update Classy::WindowBuilder::start_Classy::DynaTool idletasks
	set bindtags($base) [bindtags $base]
	$object _recursestartedit $base [winfo children $base]
	bindtags $base $data(tags)
	$object select $base
}

proc ::Classy::WindowBuilder::delete_Classy::DynaTool {object w} {
	private $object data
	set base $data(base)
	return ""
}

proc ::Classy::WindowBuilder::configure_Classy::DynaTool {object w} {
	Classy::todo $w redraw
}

proc ::Classy::WindowBuilder::attr_Classy::DynaTool_-type {object w args} {
	if {"$args" == ""} {
		return [$w cget -type]
	} else {
		$w configure -type [lindex $args 0]
		Classy::update Classy::WindowBuilder::attr_Classy::DynaTool_-type idletasks
		$object _recursestartedit $w [winfo children $w]
	}
}

proc ::Classy::WindowBuilder::edit_Classy::DynaTool {object w} {
	set c [$object current]
	eval destroy [winfo children $w]
	frame $w.general
	::Classy::WindowBuilder::defattredit $object $w.general {
		-type Type 0 -orient Orientation 0 -cmdw cmdw 0 -max Max 0
	} 12 0
	button $w.select -text "Select tool" -command [varsubst {object w} {
		set ::Classy::temp [Classy::select tool [Classy::DynaTool types]]
		if {"$::Classy::temp" != ""} {
			$w.general.w0.value set $::Classy::temp
		}
	}]
	button $w.edit -text "Edit tool" -command "Classy::Config dialog -key toolbar,\[$object attribute get -type\] -level appdef"
	button $w.new -text "New tool" -command [list Classy::Config new toolbar appdef [list Toolbars Application] New]
	grid $w.select $w.edit $w.new -sticky nswe
	grid $w.general -sticky nswe -columnspan 4
	grid columnconfigure $w 3 -weight 1
	grid rowconfigure $w 3 -weight 1
}

proc ::Classy::WindowBuilder::generate_Classy::DynaTool {object base} {
	set body ""
	set outw [$object outw $base]
	append body "\tClassy::DynaTool $outw [$object getoptions $base -width -height]\n"
	append body "\t[$object gridwconf $base]\n"
	append body [$object generatebindings $base $outw]
	return $body
}



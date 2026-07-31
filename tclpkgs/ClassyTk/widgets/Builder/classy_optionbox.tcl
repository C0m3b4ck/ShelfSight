#
# Classy::OptionBox
#

proc ::Classy::WindowBuilder::start_Classy::OptionBox {object base} {
	private $object data bindtags
	set bindtags($base) [bindtags $base]
	bindtags $base $data(tags)
	$object _recursestartedit $base [winfo children $base]
	foreach b [winfo children $base.box] {
		unset -nocomplain data(redir,$b)
		set data(class,$b) Classy::OptionBoxButton
	}
}

#proc ::Classy::WindowBuilder::attr_Classy::OptionBox_initialvalue {object w args} {
#	if {"$args" == ""} {
#		return [$w get]
#	} else {
#		$w set [lindex $args 0]
#	}
#}

proc ::Classy::WindowBuilder::edit_Classy::OptionBox_add {object w base} {
	private $object data
	set value [$w.addvalue get]
	set text [$w.addtext get]
	if {"$value" == ""} {error "No value given"}
	set new [$object current add $value $text]
	$object startedit $new
	unset -nocomplain data(redir,$new)
	set data(class,$new) Classy::OptionBoxButton
}

proc ::Classy::WindowBuilder::edit_Classy::OptionBox {object w} {
	private $object current
	frame $w.general
	set base $current(w)
#	::Classy::WindowBuilder::defattredit $object $w.general {
#		-label Label 0 -variable Variable 0 -orient Orientation 0 initialvalue "initial value" 0
#	} 8
	::Classy::WindowBuilder::defattredit $object $w.general {
		-label Label 0 -variable Variable 0 -orient Orientation 0
	} 8
	button $w.add -text "Add Field" \
		-command [list ::Classy::WindowBuilder::edit_Classy::OptionBox_add $object $w $base]
	Classy::Entry $w.addvalue -label Value -width 4
	$w.addvalue set option
	Classy::Entry $w.addtext -label Text -width 4
	$w.addtext set Option
	grid $w.general -sticky we -columnspan 3
	grid $w.add $w.addvalue $w.addtext -sticky we
	grid columnconfigure $w 0 -weight 0
	grid columnconfigure $w 1 -weight 1
	grid columnconfigure $w 2 -weight 1
	grid rowconfigure $w 100 -weight 1
}

proc ::Classy::WindowBuilder::generate_Classy::OptionBox {object base} {
	private $object current data
	set outw [$object outw $base]
	set body ""
	append body "\tClassy::OptionBox $outw [$object getoptions $base]\n"
	append body [$object generatebindings $base $outw]
	append body "\t[$object gridwconf $base]"
	append body "\n"
	foreach b [$base items] {
		catch {append body "\t$outw add [list $b] [list [[$base button $b] cget -text]]\n"}
	}
#	set value [$base get]
#	if [string length $value] {
#		append body "\t$outw set [list $value]\n"
#	}
	return $body
}

proc ::Classy::WindowBuilder::edit_Classy::OptionBoxButton {object w} {
	private $object current
	frame $w.general
	::Classy::WindowBuilder::defattredit $object $w {
		-text Text 0 -value Value 0
	} 8 1
	# button $w.set -text "Set as initial value" -command "$current(w) select"
	grid $w.set -row 3
	grid rowconfigure $w 3 -weight 0
	grid rowconfigure $w 100 -weight 1
}



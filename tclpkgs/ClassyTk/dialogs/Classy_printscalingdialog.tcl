Classy::Dialog subclass Classy_printscalingdialog
Classy_printscalingdialog method init args {
	super init
	# Create windows
	Classy::Entry $object.options.entry1 \
		-label label \
		-width 4
	Classy::Entry $object.options.entry2 \
		-label label \
		-width 4
	Classy::Entry $object.options.entry3 \
		-label label \
		-width 4
	entry $object.options.entry4 \
		-width 4
	frame $object.options.frame1  \
		-borderwidth 2 \
		-height 10 \
		-relief groove \
		-width 10
	checkbutton $object.options.scaledxy1 \
		-text {Scaled XY} \
		-variable scaledxy1
	grid $object.options.scaledxy1 -row 1 -column 0 -sticky nesw
	frame $object.options.anchor1  \
		-borderwidth 0 \
		-height 10 \
		-width 10
	grid $object.options.anchor1 -row 4 -column 0 -sticky nsw
	radiobutton $object.options.anchor1.anchornw \
		-indicatoron 0 \
		-text Topleft \
		-value nw
	grid $object.options.anchor1.anchornw -row 0 -column 0 -sticky nesw
	radiobutton $object.options.anchor1.anchorc \
		-indicatoron 0 \
		-text Center \
		-value center
	grid $object.options.anchor1.anchorc -row 0 -column 1 -sticky nesw
	radiobutton $object.options.anchor1.anchorse \
		-indicatoron 0 \
		-text BottomRight \
		-value se
	grid $object.options.anchor1.anchorse -row 0 -column 2 -sticky nesw
	Classy::Entry $object.options.x1 \
		-label "Paper X" \
		-width 4
	grid $object.options.x1 -row 2 -column 0 -sticky nesw
	Classy::Entry $object.options.y1 \
		-label "Paper Y" \
		-width 4
	grid $object.options.y1 -row 3 -column 0 -sticky nesw
	Classy::Entry $object.options.pagex1 \
		-label {Printer X} \
		-width 4
	grid $object.options.pagex1 -row 5 -column 0 -sticky nesw
	Classy::Entry $object.options.pagey1 \
		-label {Printer Y} \
		-width 4
	grid $object.options.pagey1 -row 6 -column 0 -sticky nesw
	Classy::NumEntry $object.options.scale1 \
		-width 3
	grid $object.options.scale1 -row 0 -column 0 -sticky nesw
	grid columnconfigure $object.options 0 -weight 1

	if {"$args" == "___Classy::Builder__create"} {return $object}
	# Parse this
	# Configure initial arguments
	if {"$args" != ""} {eval $object configure $args}
	return $object
}


Classy_printscalingdialog addoption -printdialog {printdialog Printdialog {}} {
	private $value options
	$object.options.scaledxy1 configure \
		-variable [privatevar $value options(-scaledxy)]
	$object.options.anchor1.anchornw configure \
		-variable [privatevar $value options(-pageanchor)]
	$object.options.anchor1.anchorc configure \
		-variable [privatevar $value options(-pageanchor)]
	$object.options.anchor1.anchorse configure \
		-variable [privatevar $value options(-pageanchor)]
	$object.options.x1 configure \
		-textvariable [privatevar $value options(-paperx)]
	$object.options.y1 configure \
		-textvariable [privatevar $value options(-papery)]
	$object.options.pagex1 configure \
		-textvariable [privatevar $value options(-printx)]
	$object.options.pagey1 configure \
		-textvariable [privatevar $value options(-printy)]
	$object.options.scale1 configure \
		-textvariable [privatevar $value options(-scale)]
	if $options(-autoscale) {
		$object.options.scale1 configure	-state disabled
	} else {
		$object.options.scale1 configure	-state normal
	}
}

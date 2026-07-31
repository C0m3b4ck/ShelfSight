Classy::Dialog subclass pagedialog
pagedialog method init args {
	super init
	# Create windows
	Classy::Selector $object.options.color \
		-label {Paper color} \
		-type color
	grid $object.options.color -row 0 -column 0 -sticky nesw
	frame $object.options.size  \
		-borderwidth 2 \
		-height 10 \
		-relief groove \
		-width 10
	grid $object.options.size -row 1 -column 0 -sticky nesw
	Classy::Entry $object.options.size.width \
		-label Width \
		-width 4
	grid $object.options.size.width -row 1 -column 0 -sticky nesw
	Classy::Entry $object.options.size.height \
		-label Height \
		-width 4
	grid $object.options.size.height -row 1 -column 1 -sticky nesw
	Classy::OptionMenu $object.options.size.select  \
		-text A4
	grid $object.options.size.select -row 0 -column 0 -columnspan 2 -sticky nesw
	$object.options.size.select set A4
	Classy::OptionBox $object.options.size.orient  \
		-label Orientation
	grid $object.options.size.orient -row 2 -column 0 -columnspan 2 -sticky nesw
	$object.options.size.orient add -p Portrait
	$object.options.size.orient add -l Landscape
	$object.options.size.orient set -p
	grid rowconfigure $object.options.size 2 -weight 1

	if {"$args" == "___Classy::Builder__create"} {return $object}
	# Parse this
	$object configure  \
		-keepgeometry 0 \
		-help page_setup \
		-title {Page properties}
	$object.options.size.width configure \
		-validate [varsubst object {_pagewidth $object}]
	$object.options.size.height configure \
		-validate [varsubst object {_pageheight $object}]
	$object.options.size.select configure \
		-command [varsubst object {_pageselect $object}] \
		-list [lsort -dictionary [array names ::papersizes]]
	$object.options.size.orient configure \
		-command [varsubst object {_pageorient $object}]
	$object add b1 Change [varsubst object {_setpagesize $object}] default
	$object persistent set b1
	# Configure initial arguments
	if {"$args" != ""} {eval $object configure $args}
# ClassyTk Finalise
_pageinit $object
	return $object
}
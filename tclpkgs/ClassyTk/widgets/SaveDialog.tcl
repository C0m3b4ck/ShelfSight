#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Classy::SaveDialog
# ----------------------------------------------------------------------
#doc SaveDialog title {
#SaveDialog
#} index {
# Dialogs
#} shortdescr {
# widget used by <a href="savefile.html">savefile</a>
#} descr {
# subclass of <a href="Dialog.html">Dialog</a><br>
#<b>experimental work</b>
#}
#doc {SaveDialog options} h2 {
#	SaveDialog specific options
#}
#doc {SaveDialog command} h2 {
#	SaveDialog specific methods
#}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

if 1 {
proc Classy::SaveDialog {args} {
	eval Classy::FileSelect $args
}

} else {
# experimental: this is NOT working
# ---------------------------------------------------------------------------
Classy::Dialog subclass Classy::SaveDialog

Classy::SaveDialog method init {args} {
	super init
	global iconpool
	label $object.options.icon -image $iconpool(file:__xxx)
	Classy::Entry $object.options.entry -label File -command [list invoke {value} [varsubst object {
		global iconpool
		regexp {\.([^.]*)$} $value temp ext
		if [info exists iconpool(file:$ext)] {
			$object.options.icon configure -image $iconpool(file:$ext)
		} else {
			$object.options.icon configure -image $iconpool(file:__xxx)
		}
	}]]
	frame $object.options.extra

	pack $object.options.icon -padx 5 -pady 5
	pack $object.options.entry -fill x -expand yes
	pack $object.options.extra -fill x -expand yes
	$object add save "Save" {} default

	# REM Initialise options and variables
	# ------------------------------------

	# REM Configure initial arguments
	# -------------------------------
	$object configure -closecommand "destroy $object"

	if {"$args" != ""} {eval $object configure $args}

	bind $object.options.icon <<Action-Motion>> "Classy::DragDrop start %X %Y $object"
	focus $object.options.entry.entry
	return $object
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------
Classy::SaveDialog addoption -transfercommand {}

#doc {SaveDialog options -default} option {-default ? ?} descr {
#}
Classy::SaveDialog chainoption -default {$object.options.entry} -default

#doc {SaveDialog options -combo} option {-combo ? ?} descr {
#}
Classy::SaveDialog chainoption -combo {$object.options.entry} -combo

#doc {SaveDialog options -combopreset} option {-combopreset ? ?} descr {
#}
Classy::SaveDialog chainoption -combopreset {$object.options.entry} -combopreset

#doc {SaveDialog options -buttontext} option {-buttontext ? ?} descr {
#}
Classy::SaveDialog chainoption -buttontext {$object.actions.save} -text

#doc {SaveDialog options -textvariable} option {-textvariable ? ?} descr {
#}
Classy::SaveDialog chainoption -textvariable {$object.options.entry} -textvariable

#doc {SaveDialog options -command} option {-command ? ?} descr {
#}
Classy::SaveDialog chainoption -command {$object.actions.save} -command

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

#doc {SaveDialog command get} cmd {
#pathname get 
#} descr {
#}
Classy::SaveDialog method get {} {
	return [$object.options.entry get]
}

#doc {SaveDialog command set} cmd {
#pathname set value
#} descr {
#}
Classy::SaveDialog method set {value} {
	$object.options.entry set $value
}

#doc {SaveDialog command startdrag} cmd {
#pathname startdrag 
#} descr {
#}
Classy::SaveDialog method startdrag {} {
	set transfercommand [getprivate $object options(-transfercommand)]
	set file [$object.options.entry get]
	d&d__startdrag [$object.options.icon cget -image] $object.options.icon "\
			SaveDialog \{$object $file\} \
			mem_indirect [list [concat $object [eval $transfercommand]]]"
}

}

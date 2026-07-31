#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Classy::FileEntry
# ----------------------------------------------------------------------
#doc FileEntry title {
#FileEntry
#} index {
# Tk improvements
#} shortdescr {
# <a gref="Entry.html">Classy::Entry</a> with file browse button
#} descr {
# subclass of <a href="Entry.html">Entry</a><br>
# provides nearly the same options and methods as Entry,
# bit has a "Browse" button which upon invocation will open a
# file selection dialog. When a file is selected in this dialog, it 
# will be inserted in the entry.
#}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

option add *Classy::FileEntry.highlightThickness 0 widgetDefault
option add *Classy::FileEntry*Frame.highlightThickness 0 widgetDefault
option add *Classy::FileEntry*Frame.borderWidth 0 widgetDefault
option add *Classy::FileEntry.label.anchor w widgetDefault
option add *Classy::FileEntry.label.highlightThickness 0 widgetDefault
option add *Classy::FileEntry.label.borderWidth 0 widgetDefault
option add *Classy::FileEntry.frame.entry.highlightThickness 0 widgetDefault
option add *Classy::FileEntry.frame.entry.borderWidth 1 widgetDefault
option add *Classy::FileEntry.frame.entry.relief sunken widgetDefault
option add *Classy::FileEntry.entry.width 5 widgetDefault
option add *Classy::FileEntry.entry.relief flat widgetDefault
option add *Classy::FileEntry.entry.borderWidth 0 widgetDefault
option add *Classy::FileEntry.entry.highlightThickness 1 widgetDefault
option add *Classy::FileEntry.defaults.combo.borderWidth 1 widgetDefault
option add *Classy::FileEntry.defaults.combo.relief raised widgetDefault
option add *Classy::FileEntry.defaults.combo.list.relief sunken widgetDefault
option add *Classy::FileEntry.defaults.combo.list.borderWidth 1 widgetDefault

Classy::Entry subclass Classy::FileEntry

Classy::FileEntry method init {args} {
	super init
	button $object.browse -text "Browse" -command [list $object browse]
	bindtags $object.entry [list $object Classy::FileEntry Classy::Entry $object.entry Entry . all]
	pack $object.browse -in $object.frame -side left

	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
	return $object
}

#doc {FileEntry options -selectmode} option {-selectmode selectMode SelectMode} descr {
#}
Classy::FileEntry addoption -selectmode {selectMode SelectMode browse} {
	if ![inlist {single browse multiple extended persistent} $value] {
		error "bad selectmode \"$value\": must be single, browse, multiple, extended, or persistent"
	}
}

#doc {FileEntry options -selecttype} option {-selecttype selectType SelectType} descr {
#}
Classy::FileEntry addoption -selecttype {selectType SelectType file} {
	if ![inlist {file dir} $value] {
		error "bad selectmode \"$value\": must be file or dir"
	}
}

Classy::FileEntry method browse {args} {
	private $object options
	set ::Classy::current [$object get]
	if {$options(-selecttype) eq "file"} {
		set ::Classy::current [::Classy::selectfile -title "[$object cget -label]" \
			-initialdir [file dirname $::Classy::current] -filter *[file extension $::Classy::current] \
			-selectmode [getprivate $object options(-selectmode)] \
			]
	} else {
		set ::Classy::current [::Classy::selectdir -title "[$object cget -label]" \
			-initialdir [file dirname $::Classy::current] \
			-selectmode [getprivate $object options(-selectmode)] \
			]
	}
	if {"$::Classy::current"!=""} {$object set $::Classy::current}
}

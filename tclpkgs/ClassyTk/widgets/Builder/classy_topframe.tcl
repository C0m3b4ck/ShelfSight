#
# Classy::Topframe
#

proc ::Classy::WindowBuilder::start_Classy::Topframe {object base} {
	private $object data bindtags
	set bindtags($base) [bindtags $base]
	$object startedit [winfo children $base]
	bindtags $base $data(tags)
	$object select $base
}

proc ::Classy::WindowBuilder::edit_Classy::Topframe {object w} {
	set c [$object current]
	eval destroy [winfo children $w]
	frame $w.general
	::Classy::WindowBuilder::defattredit $object $w.general {
		-relief Relief 0 -borderwidth Borderwidth 0
	} 12
	set ::Classy::WindowBuilder::error {}
	grid $w.general -sticky nswe
	grid columnconfigure $w 0 -weight 1
	grid rowconfigure $w 0 -weight 1
}

proc ::Classy::WindowBuilder::generate_Classy::Topframe {object base} {
	private $object current data
	set body ""
	set outw [$object outw $base]
#	set opt [eval $object getoptions $base $data(options)]
	set opt [$object getoptions $base]
	if [llength $opt] {
		append data(parse) "\t\$object configure $opt\n"
	}
	set opt [$object getoptions $base]
	if [llength $opt] {
		append body "\t\$object configure $opt\n"
	}
	append body [$object generatebindings $base $outw]
	set children ""
	foreach child [winfo children $base] {
		if ![regexp "^$base.classy__\[a-z\]+\$" $child] {
			lappend children $child
		}
	}
	append body [$object generate $children]
	append body [$object gridconf $base]
	append body "\n"
	return $body
}

set ::Classy::WindowBuilder::parents(Classy::Topframe) 1



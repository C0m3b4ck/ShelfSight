#
# Classy::NoteBook
#

proc ::Classy::WindowBuilder::add_Classy::NoteBook {object base args} {
	Classy::NoteBook $base
	if {"$args" != ""} {eval $base configure $args}
	frame $base.f1 -width 10 -height 10
	update idletasks
	raise $base.f1
	$base manage label $base.f1 -sticky nwse
	$base select label
	return $base
}

proc ::Classy::WindowBuilder::start_Classy::NoteBook {object base} {
	private $object data bindtags
	set bindtags($base) [bindtags $base]
	foreach w [list $base $base.label $base.book $base.cover_] {
		bindtags $w $data(tags)
	}
	bindtags $base [list $data(tags) ::Classy::NoteBook]
	foreach label [$base labels] {
		set b [$base window $label]
		$object startedit $b
		$object protected $b set delete
		bindtags $b $data(tags)
		set b "$base.tab[getprivate $base button($label)]"
		set data(class,$b) Classy::NoteBookButton
		bindtags $b $data(tags)
	}
	set data(optinitialselection,$base) [$base select]
}

proc ::Classy::WindowBuilder::attr_Classy::NoteBook_initialselection {object w args} {
	private $object data
	if {"$args" == ""} {
		if ![info exists data(optinitialselection,$w)] {
			return [lindex [$w labels] 0]
		} else {
			return $data(optinitialselection,$w)
		}
	} else {
		set data(optinitialselection,$w) [lindex $args 0]
		$w select [lindex $args 0]
	}
}

proc ::Classy::WindowBuilder::attr_Classy::NoteBook_order {object w args} {
	if {"$args" == ""} {
		return [$w labels]
	} else {
		eval $w reorder [lindex $args 0]
	}
}

proc ::Classy::WindowBuilder::edit_Classy::NoteBook {object w} {
	private $object current
	frame $w.general
	set base $current(w)
	::Classy::WindowBuilder::defattredit $object $w.general {
		-label Label 0 order Order 0 initialselection "Initial selection" 0
	} 12
	catch {destroy .classy__.temp}
	button $w.add -text "Add Tab" -command [varsubst {object w base} {
			::Classy::InputDialog .classy__.temp -title "Tab name" -label "Tab name" \
			-command "::Classy::WindowBuilder::edit_Classy::NoteBook_add $object $w $base"
		}]
	grid $w.general -sticky we -columnspan 2
	grid $w.add -sticky we
	grid columnconfigure $w 0 -weight 0
	grid columnconfigure $w 1 -weight 1
	grid rowconfigure $w 100 -weight 1
}

proc ::Classy::WindowBuilder::delete_Classy::NoteBook {object base} {
	private $object current data
	foreach name [array names data pr,$base.tab*] {
		unset data($name)
	}
	foreach name [array names data class,$base.tab*] {
		unset data($name)
	}
}

proc ::Classy::WindowBuilder::generate_Classy::NoteBook {object base} {
	private $object current data
	set outw [$object outw $base]
	set body ""
	append body "\tClassy::NoteBook $outw [$object getoptions $base]\n"
	append body [$object generatebindings $base $outw]
	append body "\t[$object gridwconf $base]"
	append body "\n"
	set labels ""
	foreach b [$base labels] {
		set w [$base window $b]
		append body [$object generate $w]
		set label [[$base button $b] cget -text]
		catch {append body "\t$outw manage $label [$object outw $w]\n"}
		lappend labels $label
	}
	if [info exists data(optinitialselection,$base)] {
		if {[lsearch -exact $labels $data(optinitialselection,$base)] != -1} {
			append body "\t$outw select $data(optinitialselection,$base)\n"
		}
	} else {
			append body "\t$outw select [lindex [$base labels] 0]\n"
	}
	return $body
}

#
# Classy::NoteBookButton
#

proc ::Classy::WindowBuilder::attr_Classy::NoteBookButton_label {object w args} {
	if {"$args" == ""} {
		return [$w cget -text]
	} else {
		[winfo parent $w] rename [$w cget -text] [lindex $args 0]
	}
	$object startedit [winfo parent $w]
}

proc ::Classy::WindowBuilder::edit_Classy::NoteBookButton {object w} {
	private $object current
	$current(w) invoke
	frame $w.general
	button $w.delete
	::Classy::WindowBuilder::defattredit $object $w {
		label Label 0
	} 8 1
}

proc ::Classy::WindowBuilder::edit_Classy::NoteBook_add {object w base name} {
	private $object data
	set list ""
	foreach b [winfo children $base] {
		if [regexp "^$object.tab\[0-9\]+\$" $b] {lappend list $b}
	}
	set num 1
	while {[winfo exists $base.f$num]} {incr num}
	set new $base.f$num
	frame $new
	$object startedit $new
	$base manage $name $new -sticky nwse
	raise $new
	foreach label [$base labels] {
		set b [$base window $label]
		unset -nocomplain data(redir,$b)
		$object protected $b set delete
		bindtags $b $data(tags)
		set b $base.tab[getprivate $base button($label)]	
		unset -nocomplain data(redir,$b)
		set data(class,$b) Classy::NoteBookButton
		bindtags $b $data(tags)
	}
}

proc ::Classy::WindowBuilder::delete_Classy::NoteBookButton {object w} {
	[winfo parent $w] delete [lindex [$w cget -command] 2]
}


#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# WindowBuilder
# ----------------------------------------------------------------------
#doc WindowBuilder title {
#WindowBuilder
#} index none shortdescr {
# a widget used in the ClassyTk builder
#} descr {
# subclass of <a href="Widget.html">Widget</a><br>
#}
#doc {WindowBuilder options} h2 {
#	WindowBuilder specific options
#}
#doc {WindowBuilder command} h2 {
#	WindowBuilder specific methods
#}

source [file join $::Classy::dir widgets WindowBuilderTypes.tcl]
option add *Classy::WindowBuilder_select.background black widgetDefault
option add *Classy::WindowBuilder_select.highlightBackground black widgetDefault
option add *Classy::WindowBuilder_select.nonstickyForeground black widgetDefault
option add *Classy::WindowBuilder_select.nonstickyBackground white widgetDefault
option add *Classy::WindowBuilder_select.stickyBackground black widgetDefault
option add *Classy::WindowBuilder_select.stickyForeground black widgetDefault
option add *Classy::WindowBuilder_select.width 5 widgetDefault
option add *Classy::WindowBuilder_select.height 5 widgetDefault
option add *Classy::WindowBuilder_tool.highlightThickness 0 widgetDefault
option add *Classy::WindowBuilder_tool.indel.background \
	[Classy::optionget . darkBackground DarkBackground darkBackground] widgetDefault
option add *Classy::WindowBuilder_tool.resize.background \
	[Classy::optionget . darkBackground DarkBackground darkBackground] widgetDefault

bind Classy::WindowBuilder_select <<Action-ButtonPress>> "\[Classy::WindowBuilder_win %W\] _sticky start %W %X %Y"
bind Classy::WindowBuilder_select <<Action-Motion>> "\[Classy::WindowBuilder_win %W\] _sticky motion %W %X %Y"
bind Classy::WindowBuilder_select <<Action-ButtonRelease>> "\[Classy::WindowBuilder_win %W\] _sticky action %W %X %Y"
bind Classy::WindowBuilder_tool <<Drop>> "\[Classy::WindowBuilder_win %W\] drop %W;break"

bind Classy::WindowBuilder <<Adjust>> "\[Classy::WindowBuilder_win %W\] insertname %W"
bind Classy::WindowBuilder <<Drag>> "\[Classy::WindowBuilder_win %W\] drag %W %X %Y"
bind Classy::WindowBuilder <<Drop>> "\[Classy::WindowBuilder_win %W\] drop %W;break"
bind Classy::WindowBuilder <<Action-ButtonRelease>> "\[Classy::WindowBuilder_win %W\] select %W"
bind Classy::WindowBuilder <Configure> "\[Classy::WindowBuilder_win %W\] _configure %W"

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Classy::Toplevel subclass Classy::WindowBuilder

Classy::WindowBuilder method init {args} {
	super init	-keepgeometry all -resize {2 2}
	private $object current options
	set current(w) ""
	set w [Classy::window $object]
	Classy::DynaMenu attachmainmenu Classy_WindowBuilder $object
	frame $object.toolhold
		Classy::DynaTool $object.tool -type Classy_WindowBuilder -cmdw $object
		Classy::OptionMenu $object.children -list {Select {Select parent}} \
			-command "$object select"
		$object.children set Select
		Classy::Entry $object.current -label "Current window" -width 15 \
			-command "$object rename"
		grid $object.tool -in $object.toolhold -row 0 -column 0 -sticky ew
		grid $object.children -in $object.toolhold -row 0 -column 1 -sticky nsew
		grid $object.current -in $object.toolhold -row 0 -column 2 -sticky nsew
		grid columnconfigure $object.toolhold 2 -weight 1
	Classy::DynaTool $object.icons -type Classy_WindowBuilder_icons -cmdw $object -width 30
	foreach c [winfo children $object.icons] {
		if {"[winfo class $c]" == "Button"} {
			set command [$c cget -command]
			regexp { add ([^ {}]+)} $command temp type
			set name [string tolower $type]
			regsub -all : $name _ name
			bind $c <<Drag>> "Classy::DragDrop start %X %Y $type -types [list [list create $command]] -image [Classy::geticon Builder/$name]"			
		}
	}
	Classy::Paned $object.pane -window $object.icons -orient horizontal
	Classy::NoteBook $object.book
		$object.book configure -width 100 -height 100
		$object.book propagate off
		frame $object.edit
		$object.book manage Attributes $object.edit -sticky nwse -command [list $object drawedit]
		$object _createattributes $object.attr
		$object.book manage "All Attr." $object.attr -sticky nwse -command [list $object attribute rebuild]
		$object _createbindings $object.bindings
		$object.book manage Bindings $object.bindings -sticky nwse -command [list $object bindings rebuild]
		$object _creategeometry $object.geom
		$object.book manage Geometry $object.geom -sticky nwse
		$object _createcode $object.code
		$object.book manage Code $object.code -sticky nwse
		$object.book select Attributes
		frame $object.fcode
			Classy::Text $object.fcode.text -wrap none -width 10 -height 10 -state disabled -cursor X_cursor \
				-xscrollcommand [list $object.fcode.hscroll set] -yscrollcommand [list $object.fcode.vscroll set]
			scrollbar $object.fcode.vscroll -orient vertical -command [list $object.fcode.text yview]
			scrollbar $object.fcode.hscroll -orient horizontal -command [list $object.fcode.text xview]
			grid $object.fcode.text $object.fcode.vscroll -sticky nwse
			grid $object.fcode.hscroll -sticky we
			grid columnconfigure $object.fcode 0 -weight 1
			grid rowconfigure $object.fcode 0 -weight 1
		$object.book manage "Final Code" $object.fcode -sticky nwse -command [list $object finalcode]
	grid $object.toolhold -row 0 -column 0 -columnspan 3 -sticky ew
	grid $object.icons -row 1 -column 0 -sticky new
	grid $object.pane -row 1 -column 1 -sticky ns
	grid $object.book -row 1 -column 2 -sticky nsew
	grid rowconfigure $object 1 -weight 1
	grid columnconfigure $object 2 -weight 1
	grid columnconfigure $object 0 -minsize 75
	# REM Initialise options and variables
	# ------------------------------------
	$object.tool configure -width [$object.tool reqwidth]
	# REM Create bindings
	# --------------------
	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
	Classy::update Classy::WindowBuilder-init idletasks
	return $object
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

# ------------------------------------------------------------------
#  destroy
# ------------------------------------------------------------------

#doc {WindowBuilder command destroy} cmd {
#pathname destroy 
#} descr {
#}
Classy::WindowBuilder method destroy {} {
	Classy::DynaTool delete Classy::WindowWindowBuilder_$object
	$object.tree destroy
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------
Classy::WindowBuilder method select {w} {
	private $object current prev data
	if {"$w" == ""} return
	if [info exists data(redir,$w)] {set w $data(redir,$w)}
	switch -glob -- $w {
		{} {
			set current(w) ""
			Classy::todo $object redraw
			return
		}
		"Select parent" {
			set w [winfo parent $current(w)]
		}
		"Select" {
			return
		}
		{$object*} {
			set keep $object
			set object $data(base)
			eval set w $w
			set object $keep
		}
	}
	if [info exists data(redir,$w)] {set w $data(redir,$w)}
	if {[string first $data(base) $w] != 0} return
	unset -nocomplain current
	set current(w) $w
	if {"$w" == $data(base)} {
		set current(p) $data(base)
	} elseif [info exists data(parent,$w)] {
		set current(p) $data(parent,$w)
	} elseif {"[winfo manager $w]" == "grid"} {
		set current(p) [winfo parent $w]
	} else {
		private $object border
		if [info exists border(parent)] {
			set current(p) $border(parent)
		}
	}
	$object geometryset rebuild
	switch [$object.book get] {
		"All Attr." {$object attribute rebuild}
		Bindings {$object bindings rebuild}
	}
	$object.current nocmdset [$object outw $w]
	set flist ""
	if [catch {$w children} list] {
		set list [winfo children $w]
	}
	if {$w eq $data(base)} {
		set list [list_remove $list $w.classy__nw $w.classy__n $w.classy__ne $w.classy__e $w.classy__se $w.classy__s $w.classy__sw $w.classy__w $w.classy__c0 $w.classy__c1 $w.classy__c2 $w.classy__c3 $w.classy__r0 $w.classy__r1 $w.classy__r2 $w.classy__r3 $w.classy__cend $w.classy__rend]
	}
	foreach item $list {
		if {![info exists data(redir,$item)]} {
			lappend flist $item
		}
	}
	$object.children configure -list [concat {Select {Select parent}} $flist]
	$object.children set Select
	focus $w
	Classy::todo $object redraw
	Classy::todo $object drawedit
}

Classy::WindowBuilder method current {} {
	private $object current
	return $current(w)
}

Classy::WindowBuilder method insertname {w} {
	private $object current prev data
	clipboard clear -displayof $object			  
	clipboard append -displayof $object [$object outw $w]
	set w [focus -lastfor $object]
	if {"$w" != ""} {
		event generate $w <<Paste>>
	}
}

Classy::WindowBuilder method _baseexists {} {
	private $object current
	if ![info exists current(w)] {return 0}
	if ![string length $current(w)] {return 0}
	if ![winfo exists $current(w)] {return 0}
	return 1
}

Classy::WindowBuilder method redraw {{always 0}} {
	if ![$object _baseexists] return
	$object _drawborders $always
	$object _drawselectedw
}

Classy::WindowBuilder method _drawborders {{always 0}} {
	private $object current border
	if [info exists border(always)] {
		set always 1
		unset border(always)
	}
	if ![info exists current(p)] return
	set parent $current(p)
	set colsize [grid size $parent]
	set rowsize [list_pop colsize]
	if [info exists border(parent)] {
		if {"$border(parent)" == "$parent"} {
			incr colsize -2
			incr rowsize -2
			while {$rowsize>0} {
				if {[grid rowconfigure $parent $rowsize -weight] != 0} break
				if {"[Classy::griditem $parent 0 $rowsize $colsize $rowsize]" != ""} break
				incr rowsize -1
			}
			while {$colsize>0} {
				if {[grid columnconfigure $parent $colsize -weight] != 0} break
				if {"[Classy::griditem $parent $colsize 0 $colsize $rowsize]" != ""} break
				incr colsize -1
			}
			incr colsize
			incr rowsize
			if !$always {
				if {($colsize == $border(colsize)) && ($rowsize == $border(rowsize))} {
					return
				}
			}
		}
		foreach win [grid slaves $border(parent)] {
			if [regexp {.classy__[a-z0-9]+$} $win] {grid forget $win}
		}
	}
	if {"$parent" != "$object"} {
		if {$rowsize == 0} {set rowsize 1}
		if {$colsize == 0} {set colsize 1}
		set w $object.work
		set border(rowsize) $rowsize
		set border(colsize) $colsize
		set colpos [expr {$colsize+1}]
		set rowpos [expr {$rowsize+1}]
		if ![winfo exists $w.classy__cend] {
			set b $w.classy__rend
			button $b -image [Classy::geticon Builder/indel_row] \
				-highlightthickness 0
			bindtags $b "Classy::WindowBuilder_tool [bindtags $b]"
			$b configure -command "$object _indelrow end"
			set b $w.classy__cend
			button $b -image [Classy::geticon Builder/indel_col] \
				-highlightthickness 0
			bindtags $b "Classy::WindowBuilder_tool [bindtags $b]"
			$b configure -command "$object _indelcol end"
		}
		grid $w.classy__cend -in $parent -row $rowpos -column $colsize -sticky nsew
		grid $w.classy__rend -in $parent -row $rowsize -column $colpos -sticky nsew
		raise $w.classy__cend
		raise $w.classy__rend
		for {set i 0} {$i < $colsize} {incr i} {
			set b $w.classy__c$i
			if ![winfo exists $b] {
				frame $b -bd 0 -class Classy::WindowBuilder_tool
				button $b.indel -image [Classy::geticon Builder/indel_col] \
					-highlightthickness 0 \
					-command "$object _indelcol $i"
				button $b.resize -highlightthickness 0
				bindtags $b.indel "Classy::WindowBuilder_tool [bindtags $b.indel]"
				bindtags $b.resize "Classy::WindowBuilder_tool [bindtags $b.resize]"
				grid $b.indel $b.resize -sticky nsew
				grid columnconfigure $b 1 -weight 1
			}
			if [grid columnconfigure $parent $i -weight] {
				$b.resize configure -image [Classy::geticon Builder/resize_col] \
						-command "$object geometryset columnweight 0 $i"
			} else {
				$b.resize configure -image [Classy::geticon Builder/noresize_col] \
						-command "$object geometryset columnweight 1 $i"
			}
			grid $b -in $parent -row $rowpos -column $i -sticky nsew
			raise $w.classy__c$i
		}
		for {set i 0} {$i < $rowsize} {incr i} {
			set b $w.classy__r$i
			if ![winfo exists $b] {
				frame $b -bd 0 -class Classy::WindowBuilder_tool
				button $b.indel -image [Classy::geticon Builder/indel_row] \
					-highlightthickness 0 \
					-command "$object _indelrow $i"
				button $b.resize -highlightthickness 0
				bindtags $b.indel "Classy::WindowBuilder_tool [bindtags $b.indel]"
				bindtags $b.resize "Classy::WindowBuilder_tool [bindtags $b.resize]"
				grid $b.indel -sticky nsew
				grid $b.resize -sticky nsew
				grid rowconfigure $b 1 -weight 1
			}
			if [grid rowconfigure $parent $i -weight] {
				$b.resize configure -image [Classy::geticon Builder/resize_row] \
						-command "$object geometryset rowweight 0 $i"
			} else {
				$b.resize configure -image [Classy::geticon Builder/noresize_row] \
						-command "$object geometryset rowweight 1 $i"
			}
			grid $w.classy__r$i -in $parent -row $i -column $colpos -sticky nsew
			raise $w.classy__r$i
		}
	} else {
		set border(rowsize) 0
		set border(colsize) 0
	}
	set border(parent) $parent
}

Classy::WindowBuilder method _drawselectedw {args} {
	private $object current data
	if {"$args" == ""} {
		if ![info exists current(w)] return
		set selw $current(w)
	} else {
		set selw [lindex $args 0]
	}
	if {"$selw" == ""} {
		foreach name {nw n ne e se s sw w} {
			catch {place forget $w.classy__$name}
		}
	} else {
		if {"[winfo manager $selw]" == "grid"} {set grid 1} else {set grid 0}
		set w $object.work
		if ![winfo exists $w.classy__nw] {
			foreach name {nw n ne e se s sw w} {
				catch {frame $w.classy__$name -class Classy::WindowBuilder_select}
			}
			$w.classy__se configure -cursor sizing
			$w.classy__e configure -cursor sb_h_double_arrow
			$w.classy__s configure -cursor sb_v_double_arrow
		}
		if $grid {
			array set current [grid info $selw]
			foreach name {n e s w} {
				if {[string first $name $current(-sticky)] != -1} {
					set current(sticky$name) 1
				} else {
					set current(sticky$name) 0
				}
				if $current(sticky$name) {
					$w.classy__$name configure -bg [option get $w.classy__$name stickyBackground Background] \
						-highlightbackground [option get $w.classy__$name stickyForeground Foreground]
				} else {
					$w.classy__$name configure -bg [option get $w.classy__$name nonstickyBackground Background] \
						-highlightbackground [option get $w.classy__$name nonstickyForeground Foreground]
				}
			}
		}
		set sx [expr {([$w.classy__nw cget -width]+1)/2}]
		set sy [expr {([$w.classy__nw cget -height]+1)/2}]
		if [info exists current(-in)] {
			set p $current(-in)
			set bbox [grid bbox $p $current(-column) $current(-row) \
				[expr {$current(-column)+$current(-columnspan)-1}] \
				[expr {$current(-row)+$current(-rowspan)-1}]]
			set x [expr {[winfo rootx $p] - [winfo rootx $object.work]+[lindex $bbox 0]}]
			set y [expr {[winfo rooty $p] - [winfo rooty $object.work]+[lindex $bbox 1]}]
			set wi [lindex $bbox 2]
			set he [lindex $bbox 3]
		} else {
			set x [expr {[winfo rootx $selw] - [winfo rootx $object.work]}]
			set y [expr {[winfo rooty $selw] - [winfo rooty $object.work]}]
			set wi [expr {[winfo width $selw]-2*[$selw cget -bd]}]
			set he [expr {[winfo height $selw]-2*[$selw cget -bd]}]
		}
		place $w.classy__nw -x [expr {$x-$sx}] -y [expr {$y-$sy}]
		place $w.classy__n -x [expr {$x+$wi/2-$sx}] -y [expr {$y-$sy}]
		place $w.classy__ne -x [expr {$x+$wi-$sx}] -y [expr {$y-$sy}]
		place $w.classy__e -x [expr {$x+$wi-$sx}] -y [expr {$y+$he/2-$sy}]
		place $w.classy__se -x [expr {$x+$wi-$sx}] -y [expr {$y+$he-$sy}]
		place $w.classy__s -x [expr {$x+$wi/2-$sx}] -y [expr {$y+$he-$sy}]
		place $w.classy__sw -x [expr {$x-$sx}] -y [expr {$y+$he-$sy}]
		place $w.classy__w -x [expr {$x-$sx}] -y [expr {$y+$he/2-$sy}]
		foreach name {nw n ne e se s sw w} {
			catch {raise $w.classy__$name}
		}
	}
}

Classy::WindowBuilder method add {type args} {
	private $object current data components
	if {"$type" == "Classy::DynaMenu"} {
		if {"$data(type)" != "toplevel"} {
			error "A main menu can only be added to a toplevel"
		}
		set base $data(base)
		if {"$data(opt-mainmenu,$base)" != ""} return
		$base configure -menu [eval Classy::DynaMenu menu Classy_Dummy $base]
		set data(opt-mainmenu,$base) Classy_Dummy
		set data(opt-menuwin,$base) $base
		Classy::todo $object select $base
		return {}
	}
	set w [$object newname [string tolower [namespace tail $type]]]
	if {"$type" == "Classy::any"} {
		set type [Classy::getvalue -title "Enter widget type" -label "Enter widget type" -close 1 -combo 20]
		set result $w
		$type $w
		if {"$args" != ""} {eval $w configure $args}
	} else {
		if {"[info commands ::Classy::WindowBuilder::add_$type]" == ""} {
			auto_load ::Classy::WindowBuilder::add_$type
		}
		if {"[info commands ::Classy::WindowBuilder::add_$type]" != ""} {
			set result [eval {::Classy::WindowBuilder::add_$type $object $w} $args]
		} else {
			set result $w
			$type $w
			if {"$args" != ""} {eval $w configure $args}
		}
	}
	if {"$current(-column)" == ""} {
		set current(-column) 0
	}
	set components($w) $type
	if [winfo exists $w] {
		if ![info exists data(drop)] {
			set p [winfo parent $w]
			set row [$object newpos $p $current(-column)]
			grid $w -sticky nwse -column $current(-column) -row $row
		}
		$object startedit $w
		$object select $w
	}
	Classy::todo $object redraw
	return $result
}

Classy::WindowBuilder method newpos {p col} {
	set row -1
	foreach slave [grid slaves $p -column $col] {
		if [regexp {.classy__[a-z0-9]+$} $slave] continue
		set temp [map_get [grid info $slave] -row]
		if {$temp > $row} {set row $temp}
	}
	incr row
	return $row
}

Classy::WindowBuilder method newname {{base w}} {
	private $object current
	if [info exists ::Classy::WindowBuilder::parents([winfo class $current(w)])] {
		set parent $current(w)
	} else {
		set parent $current(p)
	}
	if {"[pack slaves $parent]" != ""} {
		error "Parent has packed slaves: cannot mix gridder and packer"
	}
	if ![info exists ::Classy::WindowBuilder::parents([$object itemclass $parent])] {
		error "Adding child windows to to parent window \"$parent\" is not possible"
	}
	set num 1
	while {[winfo exists $parent.$base$num]} {
		incr num
	}
	return $parent.$base$num
}

Classy::WindowBuilder method needsave {} {
	private $object data current border
	if ![info exists data(base)] {return 0}
	# Get old code from file
	set file $data(file)
	set c [cmd_split [file_read $file]]
	set pos 0
	foreach line $c {
		if [string length $c] break
		incr pos
	}
	incr pos
	set code [join [lrange $c $pos end] \n]
	if {"[lindex $line 1]" != "subclass"} {error "This is not a ClassyTk Builder file"}
	set type [lindex $line 0]
	set function [lindex $line 2]
	set pos [lsearch -glob $c [list $function method init *]]
	set code [lindex $c $pos]
	# Get new code
	set newcode [$object code]
	if ![string_equal $code $newcode] {
		return 1
	} else {
		return 0
	}
}

Classy::WindowBuilder method close {} {
	private $object data current border
	if [$object needsave] {
		if ![Classy::yorn "Current session has not been saved, abort?"] {
			return 1
		}
	}
	Classy::Default set geometry $object [wm geometry $object]
	if [winfo exists $object.work] {
		if {"[wm grid $object.work]" == ""} {
			set geom [winfo geometry $object.work]
		} else {
			set geom [wm geometry $object.work]
		}
		Classy::Default set geometry $object.work.keep $geom
		catch {$object.work configure -destroycommand {}}
		destroy $object.work
		catch {Classy::Default unset geometry $object.work}
	}
	unset -nocomplain current
	unset -nocomplain data
	unset -nocomplain border
	wm withdraw $object
	return 0
}

Classy::WindowBuilder method code {{function {}}} {
	private $object current data
	catch {set keep $current(w)}
	$object select {} 
	set base $data(base)
	if {"$function" == ""} {
		set function $data(function)
	}
	set data(parse) ""
	set body "$function method init args \{\n"
	append body "\tsuper init\n"
	append body "\t# Create windows\n"
	append body [$object generate $base]
	append body "\t[list if {"$args" == "___Classy::Builder__create"} {return $object}]\n"
	set init [string trimright [$object.code.book.f2.initialise get]]
	if [string length $init] {
		append body "# ClassyTk Initialise\n"
		append body $init
		append body "\n"
	}
	if [string length $data(parse)] {
		append body "\t# Parse this\n"
		append body $data(parse)
	}
	append body "\t# Configure initial arguments\n"
	append body "\t[list if {"$args" != ""} {eval $object configure $args}]\n"
	set init [string trimright [$object.code.book.f3.finalise get]]
	if [string length $init] {
		append body "# ClassyTk Finalise\n"
		append body $init
		append body "\n"
	}
	append body "\treturn \$object\n"
	append body "\}"
#	foreach option $data(options) {
#		append body "\n\n"
#		append body [list $data(function) addoption $option [list $data(options,$option,name) $data(options,$option,class) $data(options,$option,def)] $data(options,$option,code)]
#	}
#	foreach method $data(methods) {
#		if {"$method" == "init"} continue
#		append body "\n\n"
#		append body [list $data(function) method $method $data(methods,$method,args) $data(methods,$method,code)]
#	}
	catch {$object select $keep}
	return $body
}

Classy::WindowBuilder method open {file} {
	global auto_index components
	private $object data current border components
	unset -nocomplain components
	set c [cmd_split [file_read $file]]
	set pos 0
	foreach line $c {
		if [string length $c] break
		incr pos
	}
	incr pos
	set code [join [lrange $c $pos end] \n]
	if {"[lindex $line 1]" != "subclass"} {error "This is not a ClassyTk Builder file"}
	set type [lindex $line 0]
	set function [lindex $line 2]
	if [$object needsave] {
		if ![Classy::yorn "Current session has not been saved, abort?"] {
			return 1
		}
	}
	wm title $object $function
	catch {$object.work configure -destroycommand {}}
	catch {destroy $object.work}
	unset -nocomplain current
	unset -nocomplain data
	unset -nocomplain border
	set data(tags) [list Classy::WindowBuilder [Classy::DynaMenu bindtag Classy_WindowBuilder]]
	set data(opt) 1
	set data(param) {}
	set pos [lsearch -glob $c [list $function method init *]]
	set code [lindex $c $pos]
	set data(function) $function
	set data(file) $file
	if ![llength [info commands $function]] {
		uplevel #0 source $file
	} else {
		uplevel #0 $code
	}
	set data(code) $code
	catch {uplevel #0 $type subclass $function}
	catch {uplevel #0 $code}
	switch -- $type {
		Classy::Topframe {
			set data(type) topframe
			Classy::Toplevel $object.work -resize {2 2}
			set window $object.work.frame
			uplevel #0 $function $window ___Classy::Builder__create
			grid $window -row 0 -column 0 -sticky nsew
			grid columnconfigure $object.work 0 -weight 1
			grid rowconfigure $object.work 0 -weight 1
			set data(base) $window
		}
		Classy::Dialog {
			set data(type) dialog
			set window $object.work
			uplevel #0 $function $window ___Classy::Builder__create
			set data(base) $object.work
		}
		Classy::Toplevel  {
			set data(type) toplevel
			set window $object.work
			uplevel #0 $function $window ___Classy::Builder__create
			set data(base) $object.work
		}
		default {
			error "unknown type"
		}
	}
	set ::Classy::builder(edit) $window
	set data(class,$window) $type
	set geom [Classy::Default get geometry $object.work.keep]
	if {"$geom" != ""} {
		wm geometry $object.work $geom
		set geom [split [winfo geometry $object.work] "x+"]
		set w [lindex $geom 0]
		set h [lindex $geom 1]
		if {"[wm grid $object.work]" == ""} {
			set min 100
		} else {
			set min 10
		}
		if {($w < $min) || ($h < $min)} {
			if {$w < $min} {set w $min}
			if {$h < $min} {set h $min}
			wm geometry $object.work ${w}x${h}
		}
	}
	$object parsecode $data(code)
	$object startedit $data(base)
#	Classy::todo $object select $data(base)
	wm title $object $file
}

Classy::WindowBuilder method parsecode {code {window {}}} {
	private $object data components
	if {"$window" == ""} {
		set window $data(base)
		set list [cmd_split [lindex $code 4]]
		# initialise
		set pos [lsearch -regexp $list {^# ClassyTk Initialise}]
		set init ""
		if {$pos != -1} {
			set init [lrange $list [expr {$pos+1}] end]
			foreach sep [list "\t# Parse this" {# ClassyTk Finalise}] {
				set pos [lsearch -regexp $init $sep]
				if {$pos != -1} {incr pos -1 ; break}
				set pos end
			}
			set init [lrange $init 0 $pos]
			$object.code.book.f2.initialise set [join $init \n]
		} else {
			$object.code.book.f2.initialise set {}
		}
		# parse
		set pos [lsearch -regexp $list "^\t# Parse this"]
		if {$pos != -1} {
			incr pos
			set parse [lrange $list $pos end]
			set pos [lsearch -regexp $parse "^\t# Configure initial arguments"]
			if {$pos != -1} {
				incr pos -1
				set parse [lrange $parse 0 $pos]
			}
		} else {
			set parse ""
		}
		# finalise
		set pos [lsearch -regexp $list {^# ClassyTk Finalise}]
		if {$pos != -1} {
			set range [lrange $list [expr {$pos+1}] end]
			set range [list_remove $range "\treturn \$object"]
			$object.code.book.f3.finalise set [join $range \n]
		} else {
			$object.code.book.f3.finalise set {}
		}
	} else {
		set parse ""
		set list [cmd_split $code]
	}
	# find components
	foreach line $list {
		if {[string index $line 0] eq "#"} continue
		if {$line eq ""} continue
		if {[regexp "___Classy::Builder__create" $line]} break
		set e1 ""
		set e2 ""
		regexp {^[ \n\t]*([^ ]+)} $line temp e1
		regexp {^[ \n\t]*([^ ]+) ([^ ]+)} $line temp e1 e2
		if {$e2 eq "columnconfigure"} break
		if {![inlist {grid super {}} $e1]} {
			set components([string map [list \$object $window] $e2]) $e1
		}
	}
	#
	set data(opt-menuwin,$window) ""
	set i 0
	set len [llength $parse]
	while {$i<$len} {
		set line [cmd_parse [lindex $parse $i]]
		if {"[lindex $line 0]" == "bind"} {
			set keep $object
			set object $window
			eval set w [lindex $line 1]
			set object $keep
			set event [lindex $line 2]
			set value [lindex $line 3]
			switch -regexp -- $value {
				{^".*"$} - {^\[.*\]$} {
					set data(ev$event,$w) $value
				}
				default {
					unset -nocomplain data(ev$event,$w)
					bind $w $event [lindex $value 0]
				}
			}
		} elseif {"[lindex $line 1]" == "configure"} {
			set keep $object
			set object $window
			eval set w [lindex $line 0]
			if {[string_equal [lindex $line 0] {$object}]&&[string_equal [lindex $line 2] {-destroycommand}]} {
				set value [lindex $line 3]
				switch -regexp -- $value {
					{^".*"$} - {^\[.*\]$} {
						set data(opt-destroycommand,$w) $value
					}
					default {
						set data(opt-destroycommand,$w) [lindex $value 0]
					}
				}
				set line [lreplace $line 2 3]
			}
			foreach {option value} [lrange $line 2 end] {
				switch -regexp -- $value {
					{^".*"$} - {^\[.*\]$} {
						set data(opt$option,$w) $value
					}
					default {
						unset -nocomplain data(opt$option,$w)
					}
				}
				catch {eval $w configure $option $value}
			}
			set object $keep
		} elseif {"[lrange $line 0 1]" == "Classy::DynaMenu attachmainmenu"} {
			set data(opt-mainmenu,$window) [lindex $line 2]
			if {"[lindex $line 3]" != ""} {
				if [info exists data(opt-menuwin,$window)] {
					append data(opt-menuwin,$window) " "
				}
				append data(opt-menuwin,$window) [lindex $line 3]
			}
			set keep $object
			set object $window
			catch {eval [eval concat $line]}
			set object $keep
		} elseif [string match {$object*} [lindex $line 0]] {
			set base [lindex $line 0]
			set keep $object
			set object $window
			eval set base $base
			catch {eval [eval concat $line]}
			set object $keep
			set type [$object itemclass $base]
			if {"[info commands ::Classy::WindowBuilder::parse_$type]" == ""} {
				auto_load ::Classy::WindowBuilder::parse_$type
			}
			if {"[info commands ::Classy::WindowBuilder::parse_$type]" != ""} {
				::Classy::WindowBuilder::parse_$type $object $base $line
			}
		}
		incr i
	}
}

Classy::WindowBuilder method test {{param {}}} {
	private $object current data
	set data(code) [$object code]
	set class [lindex $data(code) 0]
	set w .[string tolower [string index $class 0]][string range $class 1 end]
	catch {$w configure -destroycommand ""}
	catch {destroy $w}
	uplevel #0 $data(code)
	if {"$data(type)" != "topframe"} {
		set w [eval $data(function) $w $param]
	} else {
		catch {destroy $object.test}
		Classy::Toplevel $object.test
		eval $data(function) $object.test.frame $param
		pack $object.test.frame -fill both -expand yes
	}
}

Classy::WindowBuilder method testparam {args} {
	private $object data
	catch {destroy .classy__.temp}
	Classy::InputDialog .classy__.temp -title "Test parameters" -label "Parameters" \
		-textvariable [privatevar $object data(param)] \
		-command "$object test"
}

Classy::WindowBuilder method getoption {base option} {
	private $object data
	if [info exists data(opt$option,$base)] {
		return $data(opt$option,$base)
	} else {
		return	[list [$base cget $option]]
	}
}

# options given inargs are ignored
Classy::WindowBuilder method getoptions {base args} {
	private $object data
	set outw [$object outw $base]
	set result ""
	set parse ""
	set rem ""
	set type [$object itemclass $base]
	catch {destroy .classy__.classy_temp}
	Classy::delproc ::Classy::Tk_.classy__.classy_temp
	set cmd [$object class2cmd $type $base]
	$cmd .classy__.classy_temp
	foreach defline [.classy__.classy_temp configure] {
		set defl([lindex $defline 0]) [lindex $defline 4]
	}
	foreach line [$base configure] {
		if {[llength $line] != 5} continue
		set option [lindex $line 0]
		if {"$option" == "-class"} continue
		if {[lsearch -exact $args $option] != -1} continue
		if {($data(opt)&&[info exists data(opt$option,$base)])} {
			append parse " \\\n\t\t$option $data(opt$option,$base)"
		} else {
			set def ""
			catch {set def $defl($option)}
			set real [lindex $line 4]
			if {"$def" != "$real"} {
				if {"[option get $base [lindex $line 1] [lindex $line 2]]" != "$real"} {
					append result " \\\n\t\t$option [list $real]"
				}
			}
		}
	}
	catch {destroy .classy__.classy_temp}
	if {"$parse" != ""} {
		append data(parse) "\t[$object outw $base] configure$parse\n"
	}
	return $result
}

Classy::WindowBuilder method gridwconf {base} {
	if {"[winfo manager $base]" != "grid"} return
	array set ginfo [grid info $base]
	set parent [winfo parent $base]
	set options [list -row $ginfo(-row) -column $ginfo(-column)]
	if {"$ginfo(-in)" != "$parent"} {
		append options " -in [$object outw $ginfo(-in)]"
	}
	foreach {option def} {-columnspan 1 -rowspan 1 -ipadx 0 -ipady 0 -padx 0 -pady 0 -sticky {}} {
		if {"$ginfo($option)" != "$def"} {
			append options " $option $ginfo($option)"
		}
	}
	return "grid [$object outw $base] $options"
}

Classy::WindowBuilder method gridconf {base} {
	set body ""
	set col [grid size $base]
	set row [list_pop col]
	set outw [$object outw $base]
	for {set i 0} {$i<$col} {incr i} {
		set options ""
		foreach {opt value} [grid columnconfigure $base $i] {
			if {$value != 0} {lappend options $opt $value}
		}
		if {"$options" != ""} {
			append body "\tgrid columnconfigure $outw $i $options\n"
		}
	}
	for {set i 0} {$i<$row} {incr i} {
		set options ""
		foreach {opt value} [grid rowconfigure $base $i] {
			if {$value != 0} {lappend options $opt $value}
		}
		if {"$options" != ""} {
			append body "\tgrid rowconfigure $outw $i $options\n"
		}
	}
	return $body
}

Classy::WindowBuilder method current {args} {
	private $object current
	if {"$args" == ""} {
		return $current(w)
	} else {
		eval set cur $current(w)
		eval $cur $args
	}
}

Classy::WindowBuilder method drawedit {} {
	private $object current
	eval destroy [winfo children $object.edit]
	Classy::cleargrid $object.edit
	if ![$object _baseexists] return
	set type [$object itemclass $current(w)]
	if {"[info commands ::Classy::WindowBuilder::edit_$type]" == ""} {
		auto_load ::Classy::WindowBuilder::edit_$type
	}
	if {"[info commands ::Classy::WindowBuilder::edit_$type]" != ""} {
		::Classy::WindowBuilder::edit_$type $object $object.edit
	} else {
		label $object.edit.gen -text "no special functions available"
		grid $object.edit.gen -sticky we
		label $object.edit.unknown -text "for type \"$type\""
		grid $object.edit.unknown -sticky we
		grid rowconfigure $object.edit 100 -weight 1
	}
}

Classy::WindowBuilder method _recursestartedit {top list} {
	private $object data bindtags
	foreach base $list {
		set bindtags($base) [bindtags $base]
		bindtags $base $data(tags)
		set data(redir,$base) $top
		$object _recursestartedit $top [winfo children $base]
	}
}

Classy::WindowBuilder method startedit {list} {
	private $object data bindtags
	foreach base $list {
		set type [$object itemclass $base]
		if {"[info commands ::Classy::WindowBuilder::start_$type]" == ""} {
			auto_load ::Classy::WindowBuilder::start_$type
		}
		if {"[info commands ::Classy::WindowBuilder::start_$type]" != ""} {
			::Classy::WindowBuilder::start_$type $object $base
		} else {
			set bindtags($base) [bindtags $base]
			bindtags $base $data(tags)
			set list [winfo children $base]
			if [llength $list] {
				$object _recursestartedit $base $list
			}
#			if [regexp ^Classy:: $type] {
#				$object _recursestartedit $base [winfo children $base]
#			}
		}
	}
}

Classy::WindowBuilder method protected {base args} {
	private $object data
	if {[llength $args] == 0} {
		if [info exists data(pr,$base)] {
			return $data(pr,$base)
		} else {
			return ""
		}
	} elseif {[llength $args] == 1} {
		if [info exists data(pr,$base)] {
			if {[lsearch -exact $data(pr,$base) [lindex $args 0]] != -1} {
				return 1
			} else {
				return 0
			}
		} else {
			return 0
		}
	} else {
		switch [lindex $args 0] {
			set {
				set data(pr,$base) [lrange $args 1 end]
				if {"$data(pr,$base)" == ""} {unset data(pr,$base)}
			}
		}
	}
}

Classy::WindowBuilder method recurseunset {{list {}}} {
	private $object data
	foreach base $list {
		$object recurseunset [winfo children $base]
		foreach name [array names data *,$base] {unset data($name)}
	}
}

Classy::WindowBuilder method delete {{list {}}} {
	private $object data current components
	set keep $current(w)
	if {"$list" == ""} {set list $keep}
#	catch {$object finalcode}
	set p [winfo parent [lindex $list end]]
	foreach base $list {
		set type [$object itemclass $base]
		if [$object protected $base delete] continue
		if {"[info commands ::Classy::WindowBuilder::delete_$type]" == ""} {
			auto_load ::Classy::WindowBuilder::delete_$type
		}
		if {"[info commands ::Classy::WindowBuilder::delete_$type]" != ""} {
			::Classy::WindowBuilder::delete_$type $object $base
		}
		catch {$object recurseunset $base}
		catch {destroy $base}
		unset -nocomplain components($base)
	}
	$object select $p
}

Classy::WindowBuilder method outw {base} {
	private $object data
	return [string_change $base [list $data(base) {$object}]]
}

Classy::WindowBuilder method generatebindings {base outw} {
	private $object data bindtags
	set body ""
	foreach event [$object bindings events $base] {
		if [info exists data(ev$event,$base)] {
			set binding $data(ev$event,$base)
		} else {
			set binding [list [bind [Classy::rebind $base] $event]]
		}
		append data(parse) "\tbind $outw $event $binding\n"
	}
	return $body
}

Classy::WindowBuilder method generate {list} {
	private $object data
	set body {}
	foreach base $list {
		set type [$object itemclass $base]
puts "generating $type $base"
		if {"[info commands ::Classy::WindowBuilder::generate_$type]" == ""} {
			auto_load ::Classy::WindowBuilder::generate_$type
		}
		if {"[info commands ::Classy::WindowBuilder::generate_$type]" != ""} {
			append body [::Classy::WindowBuilder::generate_$type $object $base]
		} else {
			set cmd [$object class2cmd $type $base]
			set outw [$object outw $base]
			append body "\t$cmd $outw[$object getoptions $base]\n"
			append body "\t[$object gridwconf $base]\n"
			append body [$object generatebindings $base $outw]
		}
	}
	return $body	
}

Classy::WindowBuilder method itemclass {w} {
	private $object data
	if [info exists data(class,$w)] {
		return $data(class,$w)
	} else {
		if ![catch {$w info class} class] {
			return $class
		} else {
			return [winfo class $w]
		}
	}
}

Classy::WindowBuilder method finalcode {} {
	private $object data
	if [winfo exists $data(base)] {
		set data(code) [$object code]
	}
	$object.fcode.text configure -state normal
	$object.fcode.text delete 1.0 end
	$object.fcode.text insert end $data(code)
	$object.fcode.text configure -state disabled
}

Classy::WindowBuilder method recreate {} {
	private $object data
	if [winfo exists $data(base)] {
		if ![catch {set code [$object code]}] {
			set data(code) $code
		}
	}
	uplevel #0 $data(code)
	catch {$data(base) configure -destroycommand {}}
	catch {destroy $data(base)}
	if {"$data(type)" == "topframe"} {
		catch {destroy $object.work}
		Classy::Toplevel $object.work
		Classy::update Classy::WindowBuilder-recreate
		set error [catch {$data(function) $data(base)} result]
		set errorinfo $::errorInfo
		grid $object.work.frame -row 0 -column 0 -sticky nsew
		grid columnconfigure $object.work 0 -weight 1
		grid rowconfigure $object.work 0 -weight 1
		set data(base) $object.work.frame
	} else {
		Classy::update Classy::WindowBuilder-recreate
		set error [catch {$data(function) $data(base)} result]
		set errorinfo $::errorInfo
	}
	$object parsecode $data(code)
	$object startedit $data(base)
	if $error {return -code error -errorinfo $errorinfo $result}
}

Classy::WindowBuilder method save {{file {}}} {
	global auto_index
	private $object data
	switch $data(type) {
		toplevel {set type Toplevel}
		topframe {set type Topframe}
		dialog {set type Dialog}
	}
	if [string length $file] {
		catch {uplevel #0 Classy::$type subclass $data(function)}
		set data(function) [file root [file tail $file]]
		set data(file) $file
		wm title $object $file
	} else {
		set file $data(file)
	}
	set function $data(function)
	set code [$object code]
	if ![info complete $code] {
		error "error: generated code not complete (contains unmatched braces, parentheses, ...)"
	}
	uplevel #0 $code
#	file_write $file "Classy::$type subclass $function\n$code"
	set c [cmd_split [file_read $file]]
	set pos [lsearch -glob $c [list $function method init *]]
	if {$pos == -1} {
		error "dialog \"$function\" not in file \"$file\""
	}
	set c [lreplace $c $pos $pos $code]
	catch {file copy -force $file $file~}
	set f [open $file w]
	set space 0
	foreach line $c {
		if ![string length $line] {
			if $space continue
			set space 1
		} else {
			set space 0
		}
		puts $f $line
	}
	close $f
	set result $function
	Class::auto_mkindex [file dir $file]
	return $result
}

Classy::WindowBuilder method gridremovecolumn {p pos} {
	foreach slave [grid slaves $p -column $pos] {
		if {"$slave" == "$object.work.classy__c$pos"} continue
		if {[map_get [grid info $slave] -column] == $pos} {
			error "cannot remove column $pos: it is not empty"
			return
		}
	}
	foreach slave [grid slaves $p] {
		if [regexp {\.classy__[a-z0-9]+$} $slave] continue
		array set info [grid info $slave]
		set c $info(-column)
		if {$c > $pos} {
			grid $slave -column [expr {$c-1}]
		} elseif {[expr {$c+$info(-columnspan)}] > $pos} {
			grid $slave -columnspan [expr {$info(-columnspan)-1}]
		}
	}
	
	set colsize [lindex [grid size $p] 0]
	incr pos
	for {set i $pos} {$i<$colsize} {incr i} {
		set to [expr {$i-1}]
		eval grid columnconfigure $p $to [grid columnconfigure $p $i]
	}
	grid columnconfigure $p $i -weight 0 -pad 0 -minsize 0
	Classy::todo $object redraw
}

Classy::WindowBuilder method gridinsertcolumn {p pos} {
	foreach slave [grid slaves $p] {
		if [regexp {\.classy__[a-z0-9]+$} $slave] continue
		array set info [grid info $slave]
		set c $info(-column)
		if {$c >= $pos} {
			grid $slave -column [expr {$c+1}]
		} elseif {[expr {$c+$info(-columnspan)}] > $pos} {
			grid $slave -columnspan [expr {$info(-columnspan)+1}]
		}
	}
	set colsize [lindex [grid size $p] 0]
	set i $colsize
	incr i -1
	for {} {$i>=$pos} {incr i -1} {
		set to [expr {$i+1}]
		eval grid columnconfigure $p $to [grid columnconfigure $p $i]
	}
	grid columnconfigure $p $pos -weight 0 -pad 0 -minsize 0
	Classy::todo $object redraw
}

Classy::WindowBuilder method gridremoverow {p pos} {
	foreach slave [grid slaves $p -row $pos] {
		if {"$slave" == "$object.work.classy__r$pos"} continue
		if {[map_get [grid info $slave] -row] == $pos} {
			error "cannot remove row $pos: it is not empty"
			return
		}
	}
	foreach slave [grid slaves $p] {
		if [regexp {\.classy__[a-z0-9]+$} $slave] continue
		array set info [grid info $slave]
		set c $info(-row)
		if {$c > $pos} {
			grid $slave -row [expr {$c-1}]
		} elseif {[expr {$c+$info(-rowspan)}] > $pos} {
			grid $slave -rowspan [expr {$info(-rowspan)-1}]
		}
	}
	
	set rowsize [lindex [grid size $p] 1]
	grid rowconfigure $p $pos -weight 0 -pad 0 -minsize 0
	incr pos
	for {set i $pos} {$i<$rowsize} {incr i} {
		set to [expr {$i-1}]
		eval grid rowconfigure $p $to [grid rowconfigure $p $i]
	}
	grid rowconfigure $p $i -weight 0 -pad 0 -minsize 0
	Classy::todo $object redraw 1
}

Classy::WindowBuilder method gridinsertrow {p pos} {
	foreach slave [grid slaves $p] {
		if [regexp {\.classy__[a-z0-9]+$} $slave] continue
		array set info [grid info $slave]
		set c $info(-row)
		if {$c >= $pos} {
			grid $slave -row [expr {$c+1}]
		} elseif {[expr {$c+$info(-rowspan)}] > $pos} {
			grid $slave -rowspan [expr {$info(-rowspan)+1}]
		}
	}
	set rowsize [lindex [grid size $p] 1]
	set i $rowsize
	incr i -1
	for {} {$i>=$pos} {incr i -1} {
		set to [expr {$i+1}]
		eval grid rowconfigure $p $to [grid rowconfigure $p $i]
	}
	grid rowconfigure $p $pos -weight 0 -pad 0 -minsize 0
	Classy::todo $object redraw
}

Classy::WindowBuilder method _indelcol {pos} {
	private $object current
	if {"$pos" == "end"} {
		set size [expr {[lindex [grid size $current(p)] 0]-2}]
		grid columnconfigure $current(p) $size -weight 1
		Classy::todo $object redraw
		return
	}
	foreach slave [grid slaves $current(p) -column $pos] {
		if {"$slave" == "$object.work.classy__c$pos"} continue
		if {[map_get [grid info $slave] -column] == $pos} {
			$object gridinsertcolumn $current(p) $pos
			return
		}
	}
	$object gridremovecolumn $current(p) $pos
	Classy::todo $object redraw 1
}

Classy::WindowBuilder method _indelrow {pos} {
	private $object current
	if {"$pos" == "end"} {
		set size [expr {[lindex [grid size $current(p)] 1]-2}]
		grid rowconfigure $current(p) $size -weight 1
		Classy::todo $object redraw
		return
	}
	foreach slave [grid slaves $current(p) -row $pos] {
		if {"$slave" == "$object.work.classy__r$pos"} continue
		if {[map_get [grid info $slave] -row] == $pos} {
			$object gridinsertrow $current(p) $pos
			return
		}
	}
	$object gridremoverow $current(p) $pos
	Classy::todo $object redraw 1
}

Classy::WindowBuilder method switch {p w col row} {
	set to [Classy::griditem $p $col $row]
	if {"$to" == ""} {
		$object _place $w $p $col $row
	} else {
		array set info [grid info $w]
		grid forget $w
		$object _place $to $p $info(-column) $info(-row)
		unset info(-row)
		unset info(-column)
		eval grid $w -column $col -row $row [array get info]
		$object _place $w $p $col $row
	}
}

Classy::WindowBuilder method gridinsert {p col row} {
	foreach slave [grid slaves $p -column $col] {
		set slave([map_get [grid info $slave] -row]) $slave
	}
	set pos $row
	while ([info exists slave($pos)]) {
		grid configure $slave($pos) -row [expr {$pos+1}]
		incr pos
	}
}

Classy::WindowBuilder method _sticky {action w x y} {
	private $object current
	if {"$action" == "start"} {
		set current(done) 0
		set current(x) $x
		set current(y) $y
	} elseif {"$action" == "motion"} {
		regexp {s$|e$|se$} $w side
		if ![info exists side] return
		set X [expr {$x - [winfo rootx $current(p)]}]
		set Y [expr {$y - [winfo rooty $current(p)]}]
		raise $object.work.classy__$side
		set col [grid location $current(p) $X $Y]
		set row [list_pop col]
		set colspan $current(-columnspan)
		set rowspan $current(-rowspan)
		if {"$side" == "e"} {
			set colspan [expr {$col - $current(-column)+1}]
			if {$colspan < 1} {set colspan 1}
		} elseif {"$side" == "s"} {
			set rowspan [expr {$row - $current(-row)+1}]
			if {$rowspan < 1} {set rowspan 1}
		} else {
			set colspan [expr {$col - $current(-column)+1}]
			if {$colspan < 1} {set colspan 1}
			set rowspan [expr {$row - $current(-row)+1}]
			if {$rowspan < 1} {set rowspan 1}
		}
		if {$colspan < $current(-columnspan)} {
			$object geometryset -columnspan $colspan
		} elseif {$colspan > $current(-columnspan)} {
			set list [Classy::griditem $current(p) \
				[expr {$current(-column)+$current(-columnspan)}] \
				$current(-row) \
				[expr {$current(-column)+$colspan-1}] \
				[expr {$current(-row)+$rowspan-1}]]
			if {"$list" == ""} {
				$object geometryset -columnspan $colspan
			}
		}
		if {$rowspan < $current(-rowspan)} {
			$object geometryset -rowspan $rowspan
		} elseif {$rowspan > $current(-rowspan)} {
			set list [Classy::griditem $current(p) \
				$current(-column) \
				[expr {$current(-row)+$current(-rowspan)}] \
				[expr {$current(-column)+$colspan-1}] \
				[expr {$current(-row)+$rowspan-1}]]
			if {"$list" == ""} {
				$object geometryset -rowspan $rowspan
			}
		}
	} elseif {"$action" == "action"} {
		if !$current(done) {
			if {([expr {abs($current(x)-$x)}]>2)||([expr {abs($current(y)-$y)}]>2)} return
			regexp {([a-z]+)$} $w side
			foreach side [split $side ""] {
				if ![info exists current(sticky$side)] return
				if $current(sticky$side) {
					set current(sticky$side) 0
				} else {
					set current(sticky$side) 1
				}
				$object geometryset dir
			}
		}
	}
}

Classy::WindowBuilder method geometryset {type {value {}} {pos {}}} {
	private $object current
	if ![inlist {rebuild rowweight columnweight} $type] {
		if ![info exists current(-in)] {
			return -code error "Not managed by grid"
		}
		set p $current(-in)
	}
	set code [catch {
	switch -- $type {
		up {
			if {"$pos" == ""} {set pos $current(-row)}
			$object switch $p $current(w) $current(-column) [expr {$pos-1}]
		}
		down {
			if {"$pos" == ""} {set pos $current(-row)}
			$object switch $p $current(w) $current(-column) [expr {$pos+1}]
		}
		left {
			if {"$pos" == ""} {set pos $current(-column)}
			$object switch $p $current(w) [expr {$pos-1}] $current(-row)
		}
		right {
			if {"$pos" == ""} {set pos $current(-column)}
			$object switch $p $current(w) [expr {$pos+1}] $current(-row)
		}
		spanup {
			grid $current(w) -rowspan [expr {$current(-rowspan)-1}]
		}
		spandown {
			grid $current(w) -rowspan [expr {$current(-rowspan)+1}]
		}
		spanleft {
			grid $current(w) -columnspan [expr {$current(-columnspan)-1}]
		}
		spanright {
			grid $current(w) -columnspan [expr {$current(-columnspan)+1}]
		}
		columnweight {
			if {"$pos" == ""} {
				set pos $current(-column)
				set parent $p
			} else {
				set parent $current(p)
			}
			grid columnconfigure $parent $pos -weight $value
			set w $object.work
			if $value {
				$w.classy__c$pos.resize configure -image [Classy::geticon Builder/resize_col] \
						-command "$object geometryset columnweight 0 $pos"
			} else {
				$w.classy__c$pos.resize configure -image [Classy::geticon Builder/noresize_col] \
						-command "$object geometryset columnweight 1 $pos"
			}
		}
		rowweight {
			if {"$pos" == ""} {
				set pos $current(-row)
				set parent $p
			} else {
				set parent $current(p)
			}
			grid rowconfigure $parent $pos -weight $value
			set w $object.work
			if $value {
				$w.classy__r$pos.resize configure -image [Classy::geticon Builder/resize_row] \
						-command "$object geometryset rowweight 0 $pos"
			} else {
				$w.classy__r$pos.resize configure -image [Classy::geticon Builder/noresize_row] \
						-command "$object geometryset rowweight 1 $pos"
			}
		}
		-row {
			$object _place $current(w) $p $current(-column) $value
		}
		-column {
			$object _place $current(w) $p $value $current(-row)
		}
		-rowspan {
			grid $current(w) -rowspan $value
		}
		-columnspan {
			grid $current(w) -columnspan $value
		}
		rebuild {
		}
		-sticky {
			grid configure $current(w) -sticky $value
			$object.geom.fast.sticky set $value
			set value ""
			foreach dir {n s e w} {
				if {[string first $dir $value] != -1} {
					set current(sticky$dir) 1
				} else {
					set current(sticky$dir) 0
				}
			}
		}		
		dir {
			set value ""
			foreach dir {n s e w} {
				if $current(sticky$dir) {
					append value $dir
				}
			}
			grid configure $current(w) -sticky $value
			$object.geom.fast.sticky set $value
		}		
		default {
			grid configure $current(w) $type $value
		}
	}
	} result]
#	unset -nocomplain current
	unset -nocomplain current(-in)
	array set current [grid info $current(w)]
	if ![info exists current(-in)] return
	set p $current(-in)
	foreach option {weight minsize pad} {
		set current(row$option) [grid rowconfigure $p $current(-row) -$option]
		set current(column$option) [grid columnconfigure $p $current(-column) -$option]
	}
	if $current(rowweight) {
		set current(rowresize) 1
	} else {
		set current(rowresize) 0
	}
	if $current(columnweight) {
		set current(columnresize) 1
	} else {
		set current(columnresize) 0
	}
	foreach dir {n s e w} {
		if [regexp $dir $current(-sticky)] {
			set current(sticky$dir) 1
		} else {
			set current(sticky$dir) 0
		}
	}
	if $code {return -code error -errorinfo $::errorInfo $result}
	Classy::update Classy::WindowBuilder-geometryset idletasks
	Classy::todo $object redraw
}

Classy::WindowBuilder method _creategeometry {w} {
	private $object current
	frame $w 
#	set w .try.dedit.geom
#	eval destroy [winfo children $w]
#	Classy::cleargrid $w
	frame $w.fast -relief groove -bd 2
	grid $w.fast -row 0 -column 0 -sticky we -columnspan 2
		Classy::NumEntry $w.fast.row -label Row -labelwidth 6 -constraint int -width 2 \
			 -command "$object geometryset -row" \
			 -textvariable [privatevar $object current(-row)]
		Classy::NumEntry $w.fast.column -label Column -labelwidth 6 -constraint int -width 2 \
			 -command "$object geometryset -column" \
			 -textvariable [privatevar $object current(-column)]
		Classy::Selector $w.fast.sticky -type sticky -label Sticky \
			-variable [privatevar $object current(-sticky)] \
			-command "$object geometryset -sticky"
		grid $w.fast.row -in $w.fast -row 0 -column 0 -sticky n
		grid $w.fast.column -in $w.fast -row 1 -column 0 -sticky n
		grid $w.fast.sticky -in $w.fast -row 0 -column 1 -rowspan 3
		grid columnconfigure $w.fast 3 -weight 1
	frame $w.row -relief groove -bd 2
	grid $w.row -row 1 -column 1 -sticky we
		label $w.row.label -text "Row"
		grid $w.row.label -sticky we
	frame $w.column -relief groove -bd 2
	grid $w.column -row 1 -column 0 -sticky we
		label $w.column.label -text "Column"
		grid $w.column.label -sticky we
		foreach {type id label option} {
			column span "Span" -columnspan
			column weight "Resize" columnweight
			column cpad "Column pad" columnpad
			column min "Minimum size" columnminsize
			column pad "External padding" -padx
			column ipad "internal padding" -ipadx
			row span "Span" -rowspan
			row weight "Resize" rowweight
			row rpad "Row pad" rowpad
			row min "Minimum size" rowminsize
			row pad "External padding" -pady
			row ipad "internal padding" -ipady
		} {
			Classy::NumEntry $w.$type.$id -label $label -labelwidth 15 -constraint int -width 1 \
				 -command "$object geometryset $option" -textvariable [privatevar $object current($option)]
			grid $w.$type.$id -sticky we
		}
		grid rowconfigure $w.row 100 -weight 1
		grid columnconfigure $w.row 0 -weight 1
		grid rowconfigure $w.column 100 -weight 1
		grid columnconfigure $w.column 0 -weight 1
	grid rowconfigure $w 2 -weight 1
	grid columnconfigure $w 0 -weight 1
	grid columnconfigure $w 1 -weight 1

}

Classy::WindowBuilder method attribute {action args} {
	private $object current data
	if ![$object _baseexists] return
	set w $current(w)
	set option [lindex $args 0]
	switch -- $action {
		setf? {
			set value [lindex $args 1]
			switch -regexp -- $value {
				{^".*"$} - {^\[.*\]$} {
					set data(opt$option,$w) $value
					set keep $object
					set object $data(base)
					if [catch {eval set value $value} ::Classy::WindowBuilder::error] {
						set value "dummy"
					}
					set object $keep
				}
				{\$object} {
					set value "\[varsubst object [list $value]\]"
					set data(opt$option,$w) $value
					set keep $object
					set object $data(base)
					catch {eval set value $value} ::Classy::WindowBuilder::error
					set object $keep
				}
				default {
					unset -nocomplain data(opt$option,$w)
				}
			}
			set cmd ::Classy::WindowBuilder::attr_[$object itemclass $w]_$option
			if {"[info commands $cmd]" == ""} {
				$w configure $option $value
			} else {
				$cmd $object $w $value
			}
		}
		get {
			if [info exists data(opt$option,$w)] {
				if [regexp "^\\\[varsubst object" $data(opt$option,$w)] {
					set len [string length $data(opt$option,$w)]
					return [lindex [string range $data(opt$option,$w) 1 [expr {$len-2}]] 2]
				} else {
					return $data(opt$option,$w)
				}
			} else {
				set cmd ::Classy::WindowBuilder::attr_[$object itemclass $w]_$option
				if {"[info commands $cmd]" == ""} {
					return [$w cget $option]
				} else {
					return [$cmd $object $w]
				}
			}
		}
		select {
			private $object attredit
			unset -nocomplain attredit
			set v $object.attr.edit
			set list $current(group,[$object.attr.type get])
			$object.attr.list activate [lsearch -exact $list $option]
			$object.attr.list selection clear 0 end
			$object.attr.list selection set [lsearch -exact $list $option]
			eval destroy [winfo children $v]
			Classy::cleargrid $v
			label $v.label -text $option
			grid $v.label -row 0 -column 0 -sticky we
			$object _createattributeedit $v.value $option [string range $option 1 end]
			grid $v.value -row 1 -column 0 -sticky nswe
			grid columnconfigure $v 0 -weight 1
			grid rowconfigure $v 1 -weight 1
		}
		group {
			$object.attr.list delete 0 end 
			if [info exists current(group,$option)] {
				eval $object.attr.list insert end $current(group,$option)
				$object attribute select [lindex $current(group,$option) 0]
			}
		}
		rebuild {
			set cgroup [$object.attr.type get]
			set coption [$object.attr.list get active]
			foreach type [array names current group,*] {
				unset current($type)
			}
			set list All
			foreach conf [$w configure] {
				if {[llength $conf] == 2} continue
				set option [lindex $conf 0]
				if [info exists ::Classy::WindowBuilder::options($option)] {
					set entry [set ::Classy::WindowBuilder::options($option)]
					if {[llength $entry] == 2} {
						set type [list_shift entry]
					} else {
						set type Misc
					}
				} else {
					set type Misc
				}
				lappend current(group,$type) $option
				lappend current(group,All) $option
				if {[lsearch -exact [set ::Classy::WindowBuilder::options(common)] $option] != -1} {
					lappend current(group,Common) $option
					list_addnew list Common
				}
				list_addnew list $type
			}
			foreach name [array names current group,*] {
				set current($name) [lsort $current($name)]
			}
			$object.attr.type configure -list [lsort $list]
			if {[lsearch -exact $list $cgroup] != -1} {
				$object.attr.type set $cgroup
			} else {
				$object.attr.type set Display
			}
			$object.attr.list delete 0 end
			set list $current(group,[$object.attr.type get])
			eval $object.attr.list insert end $list
			set pos [lsearch -exact $list $coption]
			if {$pos != -1} {
				$object attribute select [lindex $list $pos]
			} else {
				$object attribute select [lindex $list 0]
			}
		}
		default {
			grid configure $current(w) $type $value
		}
	}
	Classy::update Classy::WindowBuilder-attribute idletasks
	Classy::todo $object redraw
}

Classy::WindowBuilder method _createattributeedit {v option title {w 0}} {
	private $object data
	if [info exists ::Classy::WindowBuilder::options($option)] {
		set entry [set ::Classy::WindowBuilder::options($option)]
		if {[llength $entry] == 2} {
			set entry [lindex $entry 1]
		}
	} else {
		set entry line
	}
	if {"[info commands ::Classy::WindowBuilder::attredit_$entry]" != ""} {
		::Classy::WindowBuilder::attredit_$entry $object $v $option $title $w
	} else {
		::Classy::WindowBuilder::attredit_line $object $v $option $title $w
	}
}

Classy::WindowBuilder method _createattributes {w} {
	private $object current
	frame $w
	eval destroy [winfo children $w]
	Classy::cleargrid $w
	Classy::OptionMenu $w.type -list {Misc Colors Sizes} -command "$object attribute group"
	listbox $w.list -yscrollcommand [list $w.scroll set] -takefocus 1 -width 10
	scrollbar $w.scroll -orient vertical -command [list $w.list yview]
	frame $w.edit
	Classy::Paned $w.pane -orient horizontal -window $w.list
	grid $w.type -row 0 -column 0 -columnspan 2 -sticky nwse
	grid $w.list -row 1 -column 0 -sticky nwse
	grid $w.scroll -row 1 -column 1 -sticky ns
	grid $w.pane -row 0 -column 2 -rowspan 2 -sticky ns
	grid $w.edit -row 0 -column 3 -rowspan 2 -sticky nwse
	grid columnconfigure $w 3 -weight 1
	grid rowconfigure $w 1 -weight 1
	bind $w.list <<Invoke>> [varsubst {w object} {
		$object attribute select [$w.list get active]
	}]
	bind $w.list <<Action-ButtonRelease>> [varsubst {w object} {
		tk::CancelRepeat
		%W activate @%x,%y
		$object attribute select [$w.list get active]
	}]
}

Classy::WindowBuilder method bindings {action args} {
	private $object current data
	if ![$object _baseexists] return
	set w $current(w)
	set event [lindex $args 0]
	switch -- $action {
		setf? {
			if {"$event" == ""} return
			set value [string trimleft [string trimright [lindex $args 1]]]
			switch -regexp -- $value {
				{^".*"$} - {^\[.*\]$} {
					set keep $object
					set object $data(base)
					catch {eval bind $w $event $value} ::Classy::err
					set object $keep
					set data(ev$event,$w) $value
				}
				{\$object} {
					set keep $object
					set object $data(base)
					set value "\[varsubst object [list $value]\]"
					catch {eval bind $w $event $value} ::Classy::err
					set object $keep
					set data(ev$event,$w) $value
				}
				default {
					bind $w $event $value
					unset -nocomplain data(ev$event,$w)
				}
			}
			$object bindings rebuild
		}
		set {
			if {"$event" == ""} return
			set value [lindex $args 1]
			bind $w $event $value
			unset -nocomplain data(ev$event,$w)
			$object bindings rebuild
		}
		get {
			if [info exists data(ev$event,$w)] {
				set value $data(ev$event,$w)
				if [regexp "^\\\[varsubst object" $value] {
					set len [string length $value]
					return [lindex [string range $value 1 [expr {$len-2}]] 2]
				} else {
					return $value
				}
			} else {
				return [bind $w $event]
			}
		}
		select {
			set v $object.bindings.edit
			set list [$object.bindings.list get 0 end]
			$object.bindings.list activate [lsearch -exact $list $event]
			$object.bindings.list selection clear 0 end
			$object.bindings.list selection set active
			eval destroy [winfo children $v]
			Classy::cleargrid $v
			Classy::Selector $v.value -type text -label "binding to $event" -command [varsubst {object v event} {
				$object bindings setf? $event [string trimright [$v.value get]]
			}]
			grid $v.value -row 0 -column 0 -sticky nswe
			grid columnconfigure $v 0 -weight 1
			grid rowconfigure $v 0 -weight 1
			$v.value set [$object bindings get $event]
		}
		rebuild {
			set cevent [$object.bindings.list get active]
			set list [lsort [$object bindings events $w]]
			$object.bindings.list delete 0 end
			eval $object.bindings.list insert end $list
			set pos [lsearch -exact $list $cevent]
			if {$pos != -1} {
				$object bindings select [lindex $list $pos]
			} else {
				$object bindings select [lindex $list 0]
			}
		}
		events {
			if [llength $args] {set w [lindex $args 0]}
			set result ""
			foreach name [array names data ev*,$w] {
				regexp ^ev(.+),$w $name temp event
				lappend result $event
			}
			foreach event [bind $w] {
				lappend result $event
			}
			return [lsort [list_remdup $result]]
		}
		default {
			grid configure $current(w) $type $value
		}
	}
	Classy::update Classy::WindowBuilder-bindings idletasks
	Classy::todo $object redraw
}

Classy::WindowBuilder method _newevent {w} {
	$object.bindings.new set [Classy::select Events [lsort [concat [event info] <<Drop>>]]]
}

Classy::WindowBuilder method _createbindings {w} {
	private $object current
	frame $w
	frame $w.b
	button $w.delete -text "Delete event" -command "$object bindings set \[$w.list get active\]"
	button $w.donew -text "New event" -command "$object.bindings.new set \[Classy::select Events \[lsort \[concat \[event info\] <<Drop>>\]\]\]"
	Classy::Entry $w.new -command [list invoke value "$object bindings set \$value \"#binding\n\""] -width 5
	grid $w.delete -row 0 -column 0 -in $w.b -sticky we
	grid $w.donew -row 1 -column 0 -in $w.b -sticky we
	grid $w.new -row 2 -column 0 -in $w.b -sticky we
	grid columnconfigure $w.b 0 -weight 1
	listbox $w.list -yscrollcommand [list $w.scroll set] -takefocus 1 -width 5
	scrollbar $w.scroll -orient vertical -command [list $w.list yview]
	Classy::Paned $w.pane -orient horizontal -window $w.list
	frame $w.edit
	grid $w.b -row 1 -column 0 -columnspan 2 -sticky nwse
	grid $w.list -row 2 -column 0 -sticky nwse
	grid $w.scroll -row 2 -column 1 -sticky ns
	grid $w.pane -row 1 -column 2 -rowspan 2 -sticky ns
	grid $w.edit -row 1 -column 3 -rowspan 2 -sticky nwse
	grid columnconfigure $w 3 -weight 1
	grid rowconfigure $w 2 -weight 1
	bind $w.list <<Invoke>> [varsubst {w object} {
		$object bindings select [$w.list get active]
	}]
	bind $w.list <<Action-ButtonRelease>> [varsubst {w object} {
		tk::CancelRepeat
		%W activate @%x,%y
		$object bindings select [$w.list get active]
	}]
}

Classy::WindowBuilder method rename {args} {
	private $object data current
	if {[llength  $args]==2} {
		set old [lindex $args 0]
		set new [lindex $args 1]
	} elseif {[llength  $args]==1} {
		set old $current(w)
		set new [lindex $args 0]
	} else {
		return -code error "wrong # args: should be \"$object rename ?old? new\""
	}
	if ![regexp {^\$object\.} $new] {return -code error "new name should be a child of \$object"}
	set keep $object
	set object $data(base)
	eval set old $old
	eval set new $new
	set object $keep
	if [winfo exists $new] {return -code error "window $new exists"}
	set gridinfo [grid info $old]
	set code [$object copy $old 0]
	$object paste $new $code 0
#	if {"[winfo parent $old]" == "[winfo parent $new]"} {
#		eval grid $new $gridinfo
#	} else {
#		set p [winfo parent $new]
#		grid $new -row [$object newpos $p 0] -column 0 -sticky nwse
#	}
	destroy $old
}

Classy::WindowBuilder method copy {{old {}} {clipboard 1}} {
	private $object data current clipb
	if {"$old" == ""} {
		set old $current(w)
	}
	set keep $data(base)
	set data(base) $old
	set error [catch {
		set gridinfo [grid info $old]
		set data(opt) 0
		set code [$object generate $old]
		set data(opt) 1
		set opt ""
		foreach name [array names data *,$old] {
			regsub ,$old $name ",\$object" newname
			lappend opt $newname $data($name)
		}
		foreach name [array names data *,$old.*] {
			regsub ,$old $name ",\$object" newname
			lappend opt $newname $data($name)
		}
		set result [list $code $opt]
	} result]
	set data(base) $keep
	if $clipboard {
		clipboard clear
		clipboard append $result
		set clipb(code) $result
	}
	return -code $error $result
}

Classy::WindowBuilder method paste {{new {}} {code {}} {grid 1}} {
	private $object data current clipb
	if {"$new" == ""} {
		set new [$object newname [string tolower pasted]]
	}
	if {"$code" == ""} {
		set code $clipb(code)
	}
	set opt [lindex $code 1]
	set code [lindex $code 0]
	set error [catch {
		proc ::Classy::buildertemp object $code
		::Classy::buildertemp $new
		$object parsecode $code $new
		set keep $object
		set object $new
		foreach {name value} $opt {
			eval set name $name
			set data($name) $value
		}
		set object $keep
	} result]
	Classy::delproc ::Classy::buildertemp
	if $error {
		catch {destroy $new}
		return -code error $result
	}
	if $grid {
		set p [winfo parent $new]
		grid $new -row [$object newpos $p 0] -column 0 -sticky nwse
	}
	$object startedit $new
	$object select $new
}

Classy::WindowBuilder method cut {{old {}}} {
	private $object data current
#	set window $data(base)
	if {"$old" == ""} {
		set old $current(w)
	}
	$object copy $old
	catch {destroy $old}
	$object select {}
}

Classy::WindowBuilder method drag {w x y} {
	private $object data current
	if [info exists data(redir,$w)] {
		set rw $data(redir,$w)
	} else {
		set rw $w
	}
	if ![string_equal [winfo manager $rw] grid] {return}
	set name [string tolower [$object itemclass $rw]]
	regsub -all : $name _ name
	if [catch {set image [Classy::geticon Builder/$name]}] {
		set image [Classy::geticon unknown]
	}
	Classy::DragDrop start $x $y [$object outw $rw] -image $image
}

Classy::WindowBuilder method drop {dst} {
	private $object data current
	set border ""
	if [regexp "^$object.work.classy__(c|r)" $dst temp border] {
		if {"[winfo class $dst]" != "Classy::WindowBuilder_tool"} {
			set dst [winfo parent $dst]
		}
		set dst [map_get [grid info $dst] -in]
	}
	if {"[Classy::DragDrop types create]" != ""} {
		set type [Classy::DragDrop get]
		set cmd [Classy::DragDrop get create]
		set ::Classy::targetwindow $dst
		set data(drop) 1
		set src [uplevel #0 $cmd]
		unset data(drop)
		unset ::Classy::targetwindow
		if {"$src" == ""} {return ""}
		set outsrc [$object outw $src]
		set checkrename 0
	} else {
		if [info exists data(redir,$dst)] {
			set dst $data(redir,$dst)
		}
		set outsrc [Classy::DragDrop get]
		set keep $object
		set object $data(base)
		eval set src $outsrc
		set object $keep
		if {"$current(w)" == "$src"} {
			Classy::todo $object select $src
		}
		set checkrename 1
	}
	set outdst [$object outw $dst]
	if {"$src" == "$outsrc"} {error "\"$outsrc\" is not a window in this dialog"}
	set p [winfo parent $src]
	if ![info exists ::Classy::WindowBuilder::parents([$object itemclass $dst])] {
		set newp [winfo parent $dst]
	} else {
		set newp $dst
	}
	if [llength [pack slaves $newp]] {error "destination contains packed widgets"}
	set x [expr {[winfo pointerx $newp]-[winfo rootx $newp]-1}]
	set y [expr {[winfo pointery $newp]-[winfo rooty $newp]-1}]
	foreach {col row} [grid location $newp $x $y] {}
	if {"$newp" != "$p"} {
		regexp {\.([^.]*[^.0-9])[0-9]*$} $src temp base 
		set num 1
		while {[winfo exists $newp.$base$num]} {
			incr num
		}
		set newname $newp.$base$num
		if $checkrename {
			if ![Classy::yorn "Rename from \"$outsrc\" to \"[$object outw $newname]\""] return
		}
		$object rename $src [$object outw $newname]
		set src $newname
	}
	if [info exists current(p)] {
		if {"$newp" == "$current(p)"} {
			if {"$border" == "r"} {incr col -1}
			if {"$border" == "c"} {incr row -1}
		}
	}
	if {$col == -1} {
		$object _indelcol 0
		set col 0
	}
	if {$row == -1} {
		$object _indelrow 0
		set row 0
	}
	$object _place $src $newp $col $row
	Classy::update Classy::WindowBuilder-drop idletasks
	Classy::todo $object _drawselectedw
}

Classy::WindowBuilder method _place {w parent col row} {
	set infostring [grid info $w]
	if {"$infostring" == ""} {
		set colspan 1
		set rowspan 1
		set sticky nsew
	} else {
		array set info $infostring
		set colspan $info(-columnspan)
		set rowspan $info(-rowspan)
		set sticky $info(-sticky)
	}
	if {"[list_remove [Classy::griditem $parent $col $row] $w]" != ""} {
		return
	}
	set ecol [expr {$col+$colspan-1}]
	set erow [expr {$row+$rowspan-1}]
	if {"[list_remove [Classy::griditem $parent $col $row $ecol $erow] $w]" != ""} {
		set i $col
		while {$i <= $ecol} {
			if {"[list_remove [Classy::griditem $parent $i $row] $w]" != ""} break
			incr i
		}
		set colspan [expr {$i-$col}]
		set ecol $i
		incr ecol -1
		set i $row
		while {$i <= $erow} {
			if {"[list_remove [Classy::griditem $parent $col $i $ecol $i] $w]" != ""} break
			incr i
		}
		set rowspan [expr {$i-$row}]
	}
	grid $w -column $col -row $row -in $parent -columnspan $colspan -rowspan $rowspan -sticky $sticky
}

#Classy::WindowBuilder method _dialogoption {option} {
#	private $object data
#	if ![regexp ^- $option] {set option "-$option"}
#	if {[lsearch -exact $data(options) $option] != -1} return
#	lappend data(options) $option
#	set data(options,$option,def) {}
#	set data(options,$option,name) [string range $option 1 end]
#	set data(options,$option,class) [string toupper [string index $option 1]][string range $option 2 end]
#	set data(options,$option,code) {}
#	$object.code.book.options.options configure -content $data(options)
#	$object.code.book.options.options selection set end
#	$object.code.book.options.options activate end
#}
#
#Classy::WindowBuilder method _dialogoptiondelete {option} {
#	private $object data
#	if ![regexp ^- $option] {set option "-$option"}
#	set data(options) [list_remove $data(options) $option]
#	unset -nocomplain data(options,$option,def)
#	unset -nocomplain data(options,$option,name)
#	unset -nocomplain data(options,$option,class)
#	unset -nocomplain data(options,$option,code)
#	$object.code.book.options.options configure -content $data(options)
#}
#
#Classy::WindowBuilder method _optionbrowse {value} {
#	private $object data
#	set window $object.code
#	$window.book.options.edit.default configure \
#		-textvariable [privatevar $object data(options,$value,def)]
#	$window.book.options.edit.name configure \
#		-textvariable [privatevar $object data(options,$value,name)]
#	$window.book.options.edit.class configure \
#		-textvariable [privatevar $object data(options,$value,class)]
#	$window.book.options.edit.code configure \
#		-variable [privatevar $object data(options,$value,code)]
#}
#
#Classy::WindowBuilder method _dialogmethod {method} {
#	private $object data
#	if {[lsearch -exact $data(methods) $method] != -1} return
#	lappend data(methods) $method
#	set data(methods,$method,args) {}
#	set data(methods,$method,code) {}
#	$object.code.book.methods.methods configure -content $data(methods)
#	$object.code.book.methods.methods selection set end
#	$object.code.book.methods.methods activate end
#}
#
#Classy::WindowBuilder method _dialogmethoddelete {method} {
#	private $object data
#	set data(methods) [list_remove $data(methods) $method]
#	unset -nocomplain data(methods,$method,args)
#	unset -nocomplain data(methods,$method,code)
#	$object.code.book.methods.methods configure -content $data(methods)
#}
#
#Classy::WindowBuilder method _methodbrowse {value} {
#puts [list $object _methodbrowse $value]
#	private $object data
#	set window $object.code
#	$window.book.methods.edit.args configure \
#		-textvariable [privatevar $object data(methods,$value,args)]
#	$window.book.methods.edit.code configure \
#		-variable [privatevar $object data(methods,$value,code)]
#}

Classy::WindowBuilder method _createcode {window} {
	private $object data
	frame $window
	Classy::NoteBook $window.book 
	grid $window.book -row 0 -column 0 -sticky nesw
#	# Options
#	# -------
#	frame $window.book.options
#	grid $window.book.options -row 0 -column 0 -in $window.book.book -sticky nesw
#	Classy::Paned $window.book.options.paned1 \
#		-window $window.book.options.options
#	grid $window.book.options.paned1 -row 1 -column 2 -sticky nesw
#	frame $window.book.options.buttons  \
#		-borderwidth 2 \
#		-height 10 \
#		-relief groove \
#		-width 10
#	grid $window.book.options.buttons -row 0 -column 0 -columnspan 4 -sticky nesw
#	button $window.book.options.buttons.delete \
#		-command "$object _dialogoptiondelete \[$window.book.options.options get\]" \
#		-text {Delete Option}
#	grid $window.book.options.buttons.delete -row 1 -column 1 -sticky nesw
#	Classy::Entry $window.book.options.buttons.new \
#		-command [list $object _dialogoption] \
#		-label {New Option} \
#		-highlightthickness 1 \
#		-width 4
#	grid $window.book.options.buttons.new -row 1 -column 0 -sticky nesw
#	grid columnconfigure $window.book.options.buttons 0 -weight 1
#	frame $window.book.options.edit  \
#		-borderwidth 2 \
#		-relief groove
#	grid $window.book.options.edit -row 1 -column 3 -sticky nesw
#	Classy::Entry $window.book.options.edit.default \
#		-label {Default value} \
#		-labelwidth 12
#	grid $window.book.options.edit.default -row 2 -column 3 -sticky nesw
#	Classy::Entry $window.book.options.edit.name \
#		-label {Database Name} \
#		-labelwidth 12
#	grid $window.book.options.edit.name -row 3 -column 3 -sticky nesw
#	Classy::Entry $window.book.options.edit.class \
#		-label {Database Class} \
#		-labelwidth 12
#	grid $window.book.options.edit.class -row 4 -column 3 -sticky nesw
#	Classy::Selector $window.book.options.edit.code \
#		-label {Option code} \
#		-orient vertical \
#		-type text \
#		-width 4
#	grid $window.book.options.edit.code -row 5 -column 3 -sticky news
#	grid columnconfigure $window.book.options.edit 3 -weight 1
#	grid rowconfigure $window.book.options.edit 5 -weight 1
#	Classy::ListBox $window.book.options.options
#	$window.book.options.options configure \
#		-browsecommand [list $object _optionbrowse] \
#		-width 10
#	grid $window.book.options.options -row 1 -column 0 -sticky nesw
#	grid columnconfigure $window.book.options 3 -weight 1
#	grid rowconfigure $window.book.options 1 -weight 1
#	# Methods
#	# -------
#	frame $window.book.methods
#	grid $window.book.methods -row 0 -column 0 -in $window.book.book -sticky nesw
#	Classy::Paned $window.book.methods.paned1 \
#		-window $window.book.methods.methods
#	grid $window.book.methods.paned1 -row 1 -column 2 -sticky nesw
#	frame $window.book.methods.buttons  \
#		-borderwidth 2 \
#		-height 10 \
#		-relief groove \
#		-width 10
#	grid $window.book.methods.buttons -row 0 -column 0 -columnspan 4 -sticky nesw
#	button $window.book.methods.buttons.delete \
#		-command "$object _dialogmethoddelete \[$window.book.methods.methods get\]" \
#		-text {Delete Method}
#	grid $window.book.methods.buttons.delete -row 1 -column 1 -sticky nesw
#	Classy::Entry $window.book.methods.buttons.new \
#		-command [list $object _dialogmethod] \
#		-label {New Method} \
#		-highlightthickness 1 \
#		-width 4
#	grid $window.book.methods.buttons.new -row 1 -column 0 -sticky nesw
#	grid columnconfigure $window.book.methods.buttons 0 -weight 1
#	frame $window.book.methods.edit  \
#		-borderwidth 2 \
#		-relief groove
#	grid $window.book.methods.edit -row 1 -column 3 -sticky nesw
#	Classy::Entry $window.book.methods.edit.args \
#		-label {Arguments}
#	grid $window.book.methods.edit.args -row 2 -column 3 -sticky nesw
#	Classy::Selector $window.book.methods.edit.code \
#		-label {Code} \
#		-orient vertical \
#		-type text \
#		-width 4
#	grid $window.book.methods.edit.code -row 3 -column 3 -sticky news
#	grid columnconfigure $window.book.methods.edit 3 -weight 1
#	grid rowconfigure $window.book.methods.edit 3 -weight 1
#	Classy::ListBox $window.book.methods.methods
#	$window.book.methods.methods configure \
#		-browsecommand [list $object _methodbrowse] \
#		-width 10
#	grid $window.book.methods.methods -row 1 -column 0 -sticky nesw
#	grid columnconfigure $window.book.methods 3 -weight 1
#	grid rowconfigure $window.book.methods 1 -weight 1
	# Finalise
	# --------
	frame $window.book.f3
	Classy::Selector $window.book.f3.finalise  \
		-type text -label Finalise
	grid $window.book.f3.finalise -row 0 -column 0 -sticky nesw
	grid columnconfigure $window.book.f3 0 -weight 1
	grid rowconfigure $window.book.f3 0 -weight 1
	frame $window.book.f2
	# Initialise	
	# ----------
	Classy::Selector $window.book.f2.initialise  \
		-type text -label Initialise
	grid $window.book.f2.initialise -row 0 -column 0 -sticky nesw
	grid columnconfigure $window.book.f2 0 -weight 1
	grid rowconfigure $window.book.f2 0 -weight 1
#	$window.book manage Options $window.book.options
#	$window.book manage Methods $window.book.methods
	$window.book manage Initialise $window.book.f2
	$window.book manage Finalise $window.book.f3
	$window.book select Finalise
	grid columnconfigure $window 0 -weight 1
	grid rowconfigure $window 0 -weight 1
	$window.book select Finalise
}

proc Classy::WindowBuilder_win {w} {
	if ![winfo exists $w] return
	while 1 {
		if [string_equal [winfo class $w] Classy::WindowBuilder] break
		if [string_equal $w .] break
		set w [winfo parent [winfo toplevel $w]]
	}
	return $w
}

Classy::WindowBuilder method _configure {window} {
	set class [$object itemclass $window]
	if {"[info commands ::Classy::WindowBuilder::configure_$class]" != ""} {
		uplevel #0 ::Classy::WindowBuilder::configure_$class $object $window
	}
}

Classy::WindowBuilder method class2cmd {type {w {}}} {
	private $object components
	if {($w ne "") && [info exists components($w)]} {
		set cmd $components($w)
	} elseif {[info exists ::Classy::cmds($type)]} {
		set cmd [set ::Classy::cmds($type)]
	} else {
		if {[string length [info commands ::$type]]} {
			set cmd $type
		} else {
			set cmd [string tolower $type]
		}
	}
	return $cmd
}

#proc cleargi {} {
#	foreach w [winfo children .try.dedit.work] {
#		if [regexp {\.classy__[a-z0-9]+$} $w] {destroy $w}
#	}
#}
#
#proc gi {} {
#	private .try.dedit current
#	set p .try.dedit.work.options
#	foreach slave [grid slaves $p] {
#		set info [grid info $slave]
#		puts "grid $slave -row [map_get $info -row] -column [map_get $info -column]"
#	}	
#	puts "set from $current(-row)"
#	puts "set col $current(-column)"
#}

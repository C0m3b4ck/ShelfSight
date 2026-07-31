#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Classy::ListTable
# ----------------------------------------------------------------------
#doc ListTable title {
#ListTable
#} index {
# Tk improvements
#} shortdescr {
# ListTable with auto scroll bars, and other extras
#} descr {
# subclass of <a href="Widget.html">Widget</a><br>
# creates a ListTable with automatic scrollbars, and some handy extra options.
#}
#doc {ListTable command} h2 {
#	ListTable specific methods
#}

if {[string equal $tcl_platform(platform) windows]} {
	option add *Classy::ListTable.Relief sunken widgetDefault
	option add *Classy::ListTable.BorderWidth 1 widgetDefault
	option add *Classy::ListTable.list.Relief flat widgetDefault
	option add *Classy::ListTable.list.BorderWidth 0 widgetDefault
}
option add *Classy::ListTable.ActiveForeground blue widgetDefault

bind Classy::ListTable <<Action-ButtonRelease>> {
    tk::CancelRepeat
    [Classy::mainw %W] activate @%x,%y
}
bind Classy::ListTable <<Action-Enter>> {
    tk::CancelRepeat
}
bind Classy::ListTable <<Action-Leave>> {
    set tk::Priv(x) %x
    set tk::Priv(y) %y
    tk::ListboxAutoScan [Classy::mainw %W]
}
bind Classy::ListTable <<Action-Motion>> {
    set tk::Priv(x) %x
    set tk::Priv(y) %y
    tk::ListboxMotion [Classy::mainw %W] [[Classy::mainw %W] index @%x,%y]
}
bind Classy::ListTable <<Action>> {
    if {[winfo exists [Classy::mainw %W]]} {
	tk::ListboxBeginSelect [Classy::mainw %W] [[Classy::mainw %W] index @%x,%y]
    }
}
bind Classy::ListTable <<Adjust-Motion>> {
    [Classy::mainw %W] scan dragto %x %y
}
bind Classy::ListTable <<Adjust>> {
    [Classy::mainw %W] scan mark %x %y
}
bind Classy::ListTable <<Bottom>> {
    [Classy::mainw %W] activate end
    [Classy::mainw %W] see end
    [Classy::mainw %W] selection clear 0 end
    [Classy::mainw %W] selection set end
    event generate [Classy::mainw %W] <<ListboxSelect>>
}
bind Classy::ListTable <<Copy>> {
    if {[string equal [selection own -displayof [Classy::mainw %W]] "[Classy::mainw %W]"]} {
	clipboard clear -displayof [Classy::mainw %W]
	clipboard append -displayof [Classy::mainw %W] [selection get -displayof [Classy::mainw %W]]
    }
}
bind Classy::ListTable <<Down>> {
    tk::ListboxUpDown [Classy::mainw %W] 1
}
bind Classy::ListTable <<End>> {
    [Classy::mainw %W] xview moveto 1
}
bind Classy::ListTable <<EndSelect>> {
    tk::ListboxBeginExtend [Classy::mainw %W] [[Classy::mainw %W] index active]
}
bind Classy::ListTable <<Escape>> {
    tk::ListboxCancel [Classy::mainw %W]
}
bind Classy::ListTable <<Home>> {
    [Classy::mainw %W] xview moveto 0
}
bind Classy::ListTable <<Invoke>> {
    tk::ListboxBeginSelect [Classy::mainw %W] [[Classy::mainw %W] index active]
}
bind Classy::ListTable <<Left>> {
    [Classy::mainw %W] xview scroll -1 units
}
bind Classy::ListTable <<MAdd>> {
    tk::ListboxBeginToggle [Classy::mainw %W] [[Classy::mainw %W] index @%x,%y]
}
bind Classy::ListTable <<MExtend>> {
    tk::ListboxBeginExtend [Classy::mainw %W] [[Classy::mainw %W] index @%x,%y]
}
bind Classy::ListTable <<MSelectWord>> {
    # Empty script
}
bind Classy::ListTable <<PageDown>> {
    [Classy::mainw %W] yview scroll 1 pages
    [Classy::mainw %W] activate @0,0
}
bind Classy::ListTable <<PageUp>> {
    [Classy::mainw %W] yview scroll -1 pages
    [Classy::mainw %W] activate @0,0
}
bind Classy::ListTable <<Right>> {
    [Classy::mainw %W] xview scroll 1 units
}
bind Classy::ListTable <<ScrollPageDown>> {
    [Classy::mainw %W] xview scroll 1 pages
}
bind Classy::ListTable <<ScrollPageUp>> {
    [Classy::mainw %W] xview scroll -1 pages
}
bind Classy::ListTable <<SelectAll>> {
    tk::ListboxSelectAll [Classy::mainw %W]
}
bind Classy::ListTable <<SelectBottom>> {
    tk::ListboxDataExtend [Classy::mainw %W] [[Classy::mainw %W] index end]
}
bind Classy::ListTable <<SelectDown>> {
    tk::ListboxExtendUpDown [Classy::mainw %W] 1
}
bind Classy::ListTable <<SelectNone>> {
    if {[string compare [[Classy::mainw %W] cget -selectmode] "browse"]} {
	[Classy::mainw %W] selection clear 0 end
	event generate [Classy::mainw %W] <<ListboxSelect>>
    }
}
bind Classy::ListTable <<SelectTop>> {
    tk::ListboxDataExtend [Classy::mainw %W] 0
}
bind Classy::ListTable <<SelectUp>> {
    tk::ListboxExtendUpDown [Classy::mainw %W] -1
}
bind Classy::ListTable <<Top>> {
    [Classy::mainw %W] activate 0
    [Classy::mainw %W] see 0
    [Classy::mainw %W] selection clear 0 end
    [Classy::mainw %W] selection set 0
    event generate [Classy::mainw %W] <<ListboxSelect>>
}
bind Classy::ListTable <<Up>> {
    tk::ListboxUpDown [Classy::mainw %W] -1
}
bind Classy::ListTable <<WordLeft>> {
    [Classy::mainw %W] xview scroll -1 pages
}
bind Classy::ListTable <<WordRight>> {
    [Classy::mainw %W] xview scroll 1 pages
}
#bind Classy::ListTable <<Invoke>> {[Classy::mainw %W] command}
#bind Classy::ListTable <<Action>> {[Classy::mainw %W] activate @%x,%y}
#bind Classy::ListTable <<MExecute>> {[Classy::mainw %W] command}
bind Classy::ListTable <Configure> {Classy::todo [Classy::mainw %W] redraw}
bind Classy::ListTable <Visibility> {Classy::todo [Classy::mainw %W] redraw}
bind Classy::ListTable <<ListboxSelect>> {[Classy::mainw %W] _browse}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------
Widget subclass Classy::ListTable

Classy::ListTable method init {args} {
	# REM Create object
	# -----------------
	super init
	canvas $object.labels -xscrollcommand "$object.xscroll set" -height 0 \
		-highlightthickness 0 -bd 0
	canvas $object.list -xscrollcommand "$object.xscroll set" -yscrollcommand "$object.yscroll set" \
		-highlightthickness 0 -bd 0
	listbox $object.dummy
	scrollbar $object.xscroll -command "$object xview" -orient horizontal
	scrollbar $object.yscroll -command "$object.list yview" -orient vertical
	$object.xscroll set 0.0 1.0
	$object.yscroll set 0.0 1.0
#	bindtags $object [lreplace [bindtags $object] 2 0 ListBox Classy::ListTable]
	Classy::rebind $object.list $object
	grid $object.labels -column 0 -row 0 -sticky nwse
	grid $object.list -column 0 -row 1 -sticky nwse
	grid columnconfigure $object 0 -weight 1
	grid rowconfigure $object 1 -weight 1
	# REM Configure initial arguments
	# -------------------------------
	private $object data
	set data(maxrow) 0
	set data(maxcol) 0
	set data(active) 0
	set data(x,s) -1
	set data(x,ms) -1
	set data(af) [Classy::optionget $object activeForeground ActiveForeground blue]
	set font [$object.dummy cget -font]
	set data(yh) [expr {[font metrics $font -linespace] + 2+1}]
	$object.labels configure -width [expr {2*$data(yh)}] -height $data(yh)
	$object.list configure -width [expr {2*$data(yh)}] -height [expr {5*$data(yh)}]
	if {"$args" != ""} {eval $object configure $args}
	Classy::todo $object redraw
	return $object
}

# ------------------------------------------------------------------
#  Widget destroy
# ------------------------------------------------------------------

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------
Classy::ListTable chainoptions {$object.dummy}
Classy::ListTable chainoption -background {$object} -background {$object.list} -background
Classy::ListTable chainoption -highlightbackground {$object} -highlightbackground {$object.list} -highlightbackground
Classy::ListTable chainoption -highlightcolor {$object} -highlightcolor {$object.list} -highlightcolor
Classy::ListTable chainoption -width {$object} -width {$object.list} -width

#doc {ListTable options -content} option {-content content Content} descr {
#}
Classy::ListTable addoption -content {content Content {}} {
	private $object data options
	set data(maxrow) [expr {[llength $value]-1}]
	Classy::todo $object _redraw
}

#doc {ListTable options -values} option {-values values Values} descr {
#}
Classy::ListTable addoption -values {values Values {}} {
	private $object data
	set data(maxrow) [expr {[llength $value]-1}]
	Classy::todo $object _redraw
}

Classy::ListTable addoption -height {height Height {}} {
	private $object data
	$object.list configure -height [expr {$value * $data(yh)}]	
}

#doc {ListTable options -command} option {-command command Command} descr {
#}
Classy::ListTable addoption -command {command Command {}} {
}

#doc {ListTable options -browsecommand} option {-browsecommand browseCommand BrowseCommand} descr {
#}
Classy::ListTable addoption -browsecommand {browseCommand BrowseCommand {}} {
}

Classy::ListTable addoption -activeforeground {activeForeground ActiveForeground {}} {
	private $object data
	if {"$value" == ""} {
		set data(af) [Classy::optionget $object activeForeground ActiveForeground blue]
	} else {
		set data(af) [Classy::realcolor $value]
	}
	$object.tree configure -foreground $col
}

#doc {ListTable options -labels} option {-labels labels Labels} descr {
#}
Classy::ListTable addoption -labels {labels Labels {}} {
	Classy::todo $object _redraw
}

#doc {Table options -size} option {-size size Size} descr {
# gives the default column size
#}
Classy::ListTable addoption -size {size Size {}} {
	private $object options data
	if {"$value" == ""} {
		set len [llength $options(-labels)]
		for {set col 0} {$col < $len} {incr col} {
			unset -nocomplain data(x,s,$col)
		}
		if {![string equal $options(-default) ""]} {
			Classy::Default unset app $options(-default)
		}
		set data(x,s) -1
	} else {
		set data(x,s) $value
	}
	Classy::todo $object _redraw
}

#doc {Table options -maxsize} option {-maxsize maxSize MaxSize} descr {
# gives the default column maximum size
#}
Classy::ListTable addoption -maxsize {maxSize MaxSize {}} {
	private $object options data
	if {"$value" == ""} {
		set len [llength $options(-labels)]
		for {set col 0} {$col < $len} {incr col} {
			unset -nocomplain data(x,ms,$col)
		}
		set data(x,ms) -1
	} else {
		set data(x,ms) $value
	}
	Classy::todo $object _redraw
}

Classy::ListTable addoption -xpad {xPad XPad 2} {
	Classy::todo $object _redraw
}

Classy::ListTable addoption -ypad {yPad YPad 1} {
	Classy::todo $object _redraw
}

Classy::ListTable addoption -editcommand {editCommand Command {}} {
}

Classy::ListTable addoption -editable {editable Editable 0} {
	if {[true $value]} {
		bind $object.list <<Action>> "[list $object edit @%x,%y];break"
		catch {$object edit {0 0}}
		$object selection clear 0 end
	} else {
		bind $object.list <<Action>> {}
		$object edit {}
	}
}

#doc {Entry options -default} option {-default default Default} descr {
# Sizes of resizable columns will be managed by the <a href="Defaults.html">Defaults</a> system 
# as type app with the value given as key if this option is not empty.
#}
Classy::ListTable addoption -default {default Default {}} {
	private $object data
	if {[string equal $value {}]} {
		set defdata {}
	} else {
		set col 0
		foreach el [Classy::Default get app $value] {
			if {$el != -1} {
				set data(x,s,$col) $el
			}
			incr col
		}
	}
	Classy::todo $object _redraw
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

#doc {ListTable command get} cmd {
#pathname get ?first? ?last?
#} descr {
#}
Classy::ListTable method get {args} {
	private $object options
	set len [llength $args]
	if {[llength $options(-values)]} {
		set values $options(-values)
	} else {
		set values $options(-content)
	}
	if {$len == 0} {
		return [list_sub $values [$object selection current]]
	} elseif {$len == 1} {
		return [lindex $values [$object index [lindex $args 0]]]
	} elseif {$len == 2} {
		return [lrange $values [$object index [lindex $args 0]] [$object index [lindex $args 1]]]
	} else {
		return -code error "wrong # args: should be \"$object get ?first? ?last?\""
	}
}

#doc {ListTable command set} cmd {
#pathname set ?el? ...
#} descr {
#}
Classy::ListTable method set {args} {
	$object selection clear 0 end
	set c [$object get 0 end]
	foreach el $args {
		set pos [lsearch -exact $c $el]
		if {$pos == -1} {error "element \"$el\" not in listbox"}
		$object.list selection set $pos
	}
}

#doc {ListTable command redraw} cmd {
#pathname redraw 
#} descr {
#}
Classy::ListTable method redraw {} {
	Classy::update Classy::ListTable-redraw idletasks
	if {"[$object.xscroll get]" != "0.0 1.0"} {
		grid $object.xscroll -row 2 -column 0 -sticky we
	} else {
		grid forget $object.xscroll
	}
	if {"[$object.yscroll get]" != "0.0 1.0"} {
		grid $object.yscroll -row 1 -column 1 -sticky ns
	} else {
		grid forget $object.yscroll
	}
}

Classy::ListTable method index {index} {
	private $object data
	if {[isint $index]} {
		set max $data(maxrow)
		if {$index > $max} {
			return $max
		} elseif {$index < 0} {
			return 0
		} else {
			return $index
		}
	}
	switch -regexp -- $index {
		{^@(-?[0-9]+),(-?[0-9]+)$} {
			foreach {canvas_x canvas_y} [split [string range $index 1 end] ,] break
			set canvas_x [$object.list canvasx $canvas_x]
			set canvas_y [$object.list canvasy $canvas_y]
			set tags [$object.list itemcget [$object.list find closest $canvas_x $canvas_y] -tags]
			if {[regexp {row([0-9]+)} $tags temp index]} {
				return $index
			} else {
				return -1
			}
		}
		{^(-?[0-9]+)[, ](-?[0-9]+)$} {
			set table_x [split $index ",. "]
			set table_y [list_pop table_x]
			return [list $table_x $table_y]
		}
		{^active$} {
			return [get data(active) -1]
		}
		{^anchor$} {
			return [get data(anchor) -1]
		}
		{^end$} {
			return $data(maxrow)
		}
		default {
			return -code error "incorrect index: should be @x,y, anchor, active or end"
		}
	}
}

Classy::ListTable method dindex {index} {
	private $object data
	if {([llength $index] == 2) && [isint [lindex $index 0]]} {
		foreach {row col} $index break
		if {$row < 0} {set row 0}
		if {$col < 0} {set col 0}
		if {$row > $data(maxrow)} {set row $data(maxrow)}
		if {$col > $data(maxcol)} {set col $data(maxcol)}
		return [list $row $col]
	}
	switch -regexp -- $index {
		{^@(-?[0-9]+),(-?[0-9]+)$} {
			foreach {canvas_x canvas_y} [split [string range $index 1 end] ,] break
			set canvas_x [$object.list canvasx $canvas_x]
			set canvas_y [$object.list canvasy $canvas_y]
			set tags [$object.list itemcget [$object.list find closest $canvas_x $canvas_y] -tags]
			if {[regexp {row([0-9]+)} $tags temp index]} {
				set row $index
			} else {
				set row -1
			}
			if {[regexp {col([0-9]+)} $tags temp index]} {
				set col $index
			} else {
				set col -1
			}
			return [list $row $col]
		}
		{^(-?[0-9]+)[, ](-?[0-9]+)$} {
			set table_x [split $index ",. "]
			set table_y [list_pop table_x]
			return [list $table_x $table_y]
		}
		{^active$} {
			return [get data(active) -1]
		}
		{^anchor$} {
			return [get data(anchor) -1]
		}
		{^end$} {
			return $data(maxrow)
		}
		default {
			return -code error "incorrect index: should be @x,y, anchor, active or end"
		}
	}
}

Classy::ListTable method activate {index} {
	private $object options data
	$object focus
	set pos [$object index $index]
	if {($pos < 0) || ($pos > $data(maxrow))} return
	if {[info exists data(active)]} {
		$object.list itemconfigure !bg&&row$data(active) -fill [$object.dummy cget -foreground]
	}
	set data(active) $pos
	$object.list itemconfigure !bg&&row$pos -fill $data(af)
	if {"$options(-browsecommand)" != ""} {
		uplevel #0 $options(-browsecommand) [list [$object get active]]
	}
}

Classy::ListTable method _browse {args} {
	private $object options
	if {"$options(-browsecommand)" != ""} {
		uplevel #0 $options(-browsecommand) [list [$object get active]]
	}
}

Classy::ListTable method insert {args} {
	uplevel #0 $object.list insert $args
	Classy::todo $object redraw
}

Classy::ListTable method delete {args} {
	uplevel #0 $object.list delete $args
	Classy::todo $object redraw
}

Classy::ListTable method command {} {
	private $object options
	set command [get options(-command) ""]
	if {"$command" != ""} {	
		uplevel #0 $command [list [$object get]]
	}
}

Classy::ListTable method yview {args} {
	eval $object.list yview $args
}

Classy::ListTable method xview {args} {
	eval $object.list xview $args
	eval $object.labels xview $args
}

Classy::ListTable method curselection {} {
	private $object selection
	return [lsort -integer [array names selection]]
}

Classy::ListTable method _range {list} {
	foreach {first last} $list break
	set first [$object index $first]
	if {[catch {$object index $last} last]} {
		set last $first
	} else {
		set last [$object index $last]
		if {$last < $first} {
			set temp $first
			set first $last
			set last $temp
		}
	}
	return [list $first $last]
}

Classy::ListTable method selection {option args} {
	private $object selection data
	switch $option {
		set {
			foreach {first last} [$object _range $args] break
			for {set i $first} {$i <= $last} {incr i} {
				if {![info exists selection($i)]} {
					set selection($i) 1
					$object.list itemconfigure bg&&row$i -fill [$object.dummy cget -selectbackground]
					$object.list itemconfigure !bg&&row$i -fill [$object.dummy cget -selectforeground]
				}
			}
		}
		anchor {
			private $object options data
			if [llength $args] {
				set index [lindex $args 0]
				set data(anchor) [$object index $index]
			} else {
				set data(anchor) $data(active)
			}
		}
		clear {
			foreach {first last} [$object _range $args] break
			for {set i $first} {$i <= $last} {incr i} {
				if {[info exists selection($i)]} {
					unset selection($i)
					$object.list itemconfigure bg&&row$i -fill [$object.dummy cget -background]
					$object.list itemconfigure !bg&&row$i -fill [$object.dummy cget -foreground]
				}
			}
		}
		includes {
			set index [$object index [lindex $args 0]]
			return [info exists selection($index)]
		}
		current {
			return [lsort -integer [array names selection]]
		}
		default {
			error "unknown option \"$option\", should be add, clear or current"
		}
	}
}

Classy::ListTable method columnconfigure {col args} {
	private $object data
	set len [llength $args]
	if {$len == 0} {
		set result {}
		foreach {type key} {size s resize rs gridwidth gridwidth gridcolor gridcolor} {
			lappend result -$type
			if [info exists data(x,$key,$col)] {
				lappend result $data(x,$key,$col)
			} else {
				lappend result $data(x,$key)
			}
		}
		return $result
	} elseif {$len == 1} {
		set option [lindex $args 0]
		switch -- $option {
			-size {
				if [info exists data(x,s,$col)] {
					return $data(x,s,$col)
				} else {
					return $data(x,s)
				}
			}
			-maxsize {
				if [info exists data(x,ms,$col)] {
					return $data(x,ms,$col)
				} else {
					return $data(x,ms)
				}
			}
			-resize {
				if [info exists data(x,rs,$col)] {
					return $data(x,rs,$col)
				} else {
					return $data(x,rs)
				}
			}
			-gridwidth {
				if [info exists data(x,gridwidth,$col)] {
					return $data(x,gridwidth,$col)
				} else {
					return $data(x,gridwidth)
				}
			}
			-gridcolor {
				if [info exists data(x,gridcolor,$col)] {
					return $data(x,gridcolor,$col)
				} else {
					return $data(x,gridcolor)
				}
			}
			default {
				return {}
			}
		}
	} else {
		set todo ""
		foreach {option value} $args {
			switch -- $option {
				-size {
					if {"$value" == ""} {
						unset data(x,s,$col)
					} else {
						if {$value < 1} {set value 1}
						set data(x,s,$col) $value
						$object _updatedefault
					}
					$object _updatedefault
				}
				-maxsize {
					if {"$value" == ""} {
						unset data(x,ms,$col)
					} else {
						if {$value < 1} {set value 1}
						set data(x,ms,$col) $value
					}
				}
				-resize {
					if {"$value" == ""} {
						unset -nocomplain data(x,rs,$col)
					} else {
						set data(x,rs,$col) [true $value]
					}
				}
				-gridwidth {
					if {"$value" == ""} {
						unset -nocomplain data(x,gridwidth,$col)
					} else {
						set data(x,gridwidth,$col) $value
					}
				}
				-gridcolor {
					if {"$value" == ""} {
						unset -nocomplain data(x,gridcolor,$col)
					} else {
						set data(x,gridcolor,$col) $value
					}
				}
				-fg - -bg - -font {lappend todo $option $value}
				default {
					error "Unknown option \"$option\": should be one of: -size, -resize, -gridwidth, -gridcolor, -fg, -bg, -font"
				}
			}
		}
	}
	Classy::todo $object _redraw
}

Classy::ListTable method _redraw {} {
	private $object data options

	set font [$object.dummy cget -font]
	set bgcol [$object.dummy cget -bg]
	set listdata $options(-content)
	if {![llength $listdata]} {
		set listdata $options(-values)
	}
	set data(maxrow) [expr {[llength $listdata]-1}]
	set data(maxcol) [expr {[llength [lindex $listdata 0]]-1}]
	set canvas $object.list
	set canvas2 $object.labels
	set xpad $options(-xpad)
	set ypad $options(-ypad)
	set xposr 0
	set xpost $xpad
	set col 0
	$canvas2 delete all
	$canvas delete all
	set font [$object.dummy cget -font]
	set yh [expr {[font metrics $font -linespace] + 2*$ypad+1}]
	set data(yh) $yh
	set ypos 0
	foreach label $options(-labels) {
		set list [list_subindex $listdata $col]
		set id [$canvas2 create text $xpost $ypad -text $label -anchor nw -font $font \
			-tags [list label col$col]]
		set row 0
		set ypos $ypad
		foreach el $list {
			$canvas create text $xpost $ypos -text $el -anchor nw -font $font \
				-tags [list col$col row$row]
			incr ypos $yh
			incr row
		}
		set size [get data(x,s,$col) $data(x,s)]
		set maxsize [get data(x,ms,$col) $data(x,ms)]
		if {$size == -1} {
			set bbox [$canvas bbox col$col]
			if {![llength $bbox]} {
				set bbox [$canvas2 bbox col$col]
			}
			set xend [expr {[lindex $bbox 2]+$xpad}]
			if {$maxsize != -1} {
				set temp [expr {$xposr + $maxsize}]
				if {$temp < $xend} {set xend $temp}
			}
		} else {
			set xend [expr {$xposr + $size}]
		}
		set id [$canvas2 create rectangle $xposr 0 $xend $yh -tags [list label bg col$col]]
		$canvas2 lower $id col$col
		set row 0
		set ypos 0
		foreach el $list {
			$canvas create rectangle $xposr $ypos $xend [expr {$ypos+$yh}] \
				-fill $bgcol \
				-tags [list bg col$col row$row]
			incr ypos $yh
			incr row
		}
		$canvas lower bg&&col$col col$col
		set xposr $xend
		set xpost [expr {$xposr + $xpad}]
		set id [$canvas create rectangle [expr {$xposr-1}] 0 [expr {$xposr+1}] $ypos -tags [list pane col[expr {$col+1}]] -fill {} -outline {}]
		$canvas bind $id <Enter> [list $object.list configure -cursor sb_h_double_arrow]
		$canvas bind $id <Leave> [list $object.list configure -cursor {}]
		$canvas bind $id <<Action>> [list $object _startdrag %X %Y $col]
		$canvas bind $id <<Action-Motion>> [list $object _drag %X %Y $col]
		$canvas bind $id <<MExecute>> [list $object columnconfigure $col -size {}]
		set id [$canvas2 create rectangle [expr {$xposr-1}] 0 [expr {$xposr+1}] [expr {$yh+1}] -tags [list pane col[expr {$col+1}]] -fill {} -outline {}]
		$canvas2 bind $id <Enter> [list $canvas2 configure -cursor sb_h_double_arrow]
		$canvas2 bind $id <Leave> [list $canvas2 configure -cursor {}]
		$canvas2 bind $id <<Action>> [list $object _startdrag %X %Y $col]
		$canvas2 bind $id <<Action-Motion>> [list $object _drag %X %Y $col]
		$canvas2 bind $id <<MExecute>> [list $object columnconfigure $col -size {}]
		incr col
	}
	$canvas raise pane
	$canvas create rectangle [expr {$xposr+1}] 0 [expr {$xposr+10000}] $ypos \
		-fill $bgcol -outline $bgcol \
		-tags [list bg bgcover]
	$canvas2 configure -scrollregion [list 0 0 [expr {$xposr+1}] [expr {$yh+1}]]
	$canvas2 configure -height [expr {$yh+1}]
	$canvas configure -scrollregion [list 0 1 [expr {$xposr+1}] [expr {$ypos+1}]]
	$canvas2 itemconfigure bg -fill gray
	Classy::todo $object redraw

}

Classy::ListTable method _startdrag {x y col} {
	private $object data options
	set data(drag,x) $x
	set data(drag,col) $col
	if {![info exists data(x,s,$col)]} {
		set c [$object.labels coords bg&&col$col]
		set data(x,s,$col) [expr {[lindex $c 2]-[lindex $c 0]}]
		$object _updatedefault
	}
}

Classy::ListTable method _drag {x y col} {
	private $object data options
	if {$x < 0} {
		set data(drag,x) 0
		return
	}
	set col $data(drag,col)
	set move [expr {$x - $data(drag,x)}]
	set c [$object.labels coords bg&&col$col]
	set prevsize [expr {[lindex $c 2]-[lindex $c 0]}]
	set newsize [expr {$prevsize + $move}]
	if {$newsize <= 1} {
		set newsize 1
		set move [expr {$newsize - $prevsize}]
		if {$move == 0} {
			set data(drag,x) $x
			return
		}
	}
	set scale [expr {$newsize/double($prevsize)}]
	set data(x,s,$col) $newsize
	$object _updatedefault
	set len [llength $options(-labels)]
	$object.list scale bg&&col$col [lindex $c 0] [lindex $c 1] $scale 1
	$object.labels scale bg&&col$col [lindex $c 0] [lindex $c 1] $scale 1
	incr col
	for {} {$col <= $len} {incr col} {
		$object.list move col$col $move 0
		$object.labels move col$col $move 0
	}
	$object.list move bgcover $move 0
	set data(drag,x) $x
	set c [$object.list coords bgcover]
	set xmax [lindex $c 0]
	set ymax [lindex $c 3]
	$object.labels configure -scrollregion [list 0 0 $xmax $data(yh)]
	$object.list configure -scrollregion [list 0 1 $xmax $ymax]
	Classy::todo $object redraw
}

Classy::ListTable method see {{index {}}} {
	private $object data
	if ![llength $index] {set index $data(active)}
	set index [$object index $index]
	if {$index > $data(maxrow)} {set index $data(maxrow)}
	set ys [expr {$index * $data(yh)}]
	set ye [expr {$ys+$data(yh)}]
	foreach {temp ss temp se} [$object.list cget -scrollregion] break
	foreach {fs fe} [$object.list yview] break
	set h [expr {$se-$ss}]
	set vs [expr {$ss + $fs*$h}]
	set ve [expr {$ss + $fe*$h}]
	if {$ys < $vs || $ys > $ve} {
		$object.list yview moveto [expr {$ys/double($h)}]
	} elseif {$ye < $vs || $ye > $ve} {
		$object.list yview moveto [expr {$ys/double($h)}]
	}
}

Classy::ListTable method focus {} {
	if {[winfo exists $object.list.edit]} {
		focus $object.list.edit
	} else {
		focus $object.list
	}
}

Classy::ListTable method change {row col newvalue} {
	private $object data options
	if {[llength $options(-content)]} {
		lset options(-content) $row $col $newvalue
	} else {
		lset options(-values) $row $col $newvalue
	}
	$object.list itemconfigure row$row&&col$col&&!bg -text $newvalue
}

Classy::ListTable method editcmd {row col} {
	private $object data options
	set oldval [$object get [list $row $col]]
	set newval [$object.list.edit get]
	$object change $row $col $newval
	if {[string length $options(-editcommand)]} {
		uplevel #0 $options(-editcommand) [list $row $col $oldval $newval]
	}
}

Classy::ListTable method _updatedefault {} {
	private $object data options
	if {[string equal $options(-default) ""]} return
	set list {}
	set col 0
	foreach label $options(-labels) {
		lappend list [get data(x,s,$col) -1]
		incr col
	}
	Classy::Default set app $options(-default) $list
}

Classy::ListTable method _editleft {dindex} {
	if {[$object.list.edit index insert] == 0} {
		$object edit $dindex
	}
}

Classy::ListTable method _editright {dindex} {
	if {[$object.list.edit index end] ==	[$object.list.edit index insert]} {
		$object edit $dindex
	}
}

Classy::ListTable method edit {dindex} {
	private $object data options
	set listdata $options(-content)
	if {![llength $listdata]} {
		set listdata $options(-values)
	}
	if {![llength $dindex]} {
		$object.list delete edit
		destroy $object.list.edit
		focus $object.list
		return
	}
	foreach {row col} [$object dindex $dindex] break
	if {($row == -1) || ($col == -1)} return
	set id [$object.list find withtag col$col&&row$row&&bg]
	set c [$object.list coords $id]
	foreach {x1 y1 x2 y2} $c break
	if {![winfo exists $object.list.edit]} {
		entry $object.list.edit
	}
	$object.list delete edit
	$object.list create window $x1 $y1 -anchor nw -window $object.list.edit \
		-height [expr {$y2-$y1+1}] -width [expr {$x2-$x1+1}] -tags edit
	set data(editrow) $row
	set data(editcol) $col
	set el [lindex [lindex $listdata $row] $col]
	$object.list.edit delete 0 end
	$object.list.edit insert end $el
	focus $object.list.edit
	bind $object.list.edit <Escape> [list $object edit {}]
	bind $object.list.edit <<Up>> [list $object edit [list [expr {$row-1}] $col]]
	bind $object.list.edit <<Down>> [list $object edit [list [expr {$row+1}] $col]]
	bind $object.list.edit <<FocusPrev>> [list $object edit [list $row [expr {$col-1}]]]
	bind $object.list.edit <<FocusNext>> [list $object edit [list $row [expr {$col+1}]]]
	bind $object.list.edit <<Return>> [list $object editcmd $row $col]
	bind $object.list.edit <<Left>> [list $object _editleft [list $row [expr {$col-1}]]]
	bind $object.list.edit <<Right>> [list $object _editright [list $row [expr {$col+1}]]]
	$object selection clear 0 end
	$object selection set $row
}

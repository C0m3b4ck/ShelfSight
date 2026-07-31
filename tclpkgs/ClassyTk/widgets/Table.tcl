#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Table
# ----------------------------------------------------------------------
#doc Table title {
#Table
#} index {
# New widgets
#} shortdescr {
# a Table ...
#} descr {
# subclass of <a href="Widget.html">Widget</a><br>
# creates a Table of entries or text fields. This acts much like a 
# spreadsheet. It supports scrollbars using the normal methods. The 
# Table must have an associated command. This is used to get the data 
# to display in the Table and te change data when it
# is edited. The table command will be called with the following 
# parameters:<br>
# <dl>
# <dt>command object x y ?value?
# <dd>the parameter object is the name of the Table.<br>
# When no value is given, the command must return the value to be s
# hown in the given cell.
# When the command fails, the error message will be shown in the affected cell.
# <dd>When value is given, it is the new value of the cell.
# If the setcommand fails, the previous value will be restored.
# </dl>
#}
#doc {Table options} h2 {
#	Table specific options
#}
#doc {Table command} h2 {
#	Table specific methods
#}

option add *GridWidth 1 widgetDefault
option add *xGridColor gray widgetDefault
option add *yGridColor gray widgetDefault

proc Classy::Tableobject {w args} {
	eval [winfo parent $w] $args
}
bind Classy::Table <Configure> {%W _clear ; %W _redraw;break}
bind Classy::Table <<Action>> {%W selection clear ; %W activate @%x,%y;break}
bind Classy::Table <<Action-Motion>> {%W _selectmotion %W %x %y;break}
bind Classy::Table <<Action-Leave>> {%W _autoscan;break}
bind Classy::Table <<Action-Enter>> {%W _cancelrepeat;break}
bind Classy::Table <<Action-ButtonRelease>> {%W _cancelrepeat;break}
bind Classy::Table <<Cut>> {%W cut;break}
bind Classy::Table <<Copy>> {%W copy;break}
bind Classy::Table <<Paste>> {%W paste;break}
bind Classy::Table <<PasteSpecial>> {%W pastespecial;break}
bind Classy::Table <<TableUp>> {%W selection clear ; %W activate;break}
bind Classy::Table <<TableDown>> {%W selection clear ; %W activate;break}
bind Classy::Table <<TableLeft>> {%W selection clear ; %W activate;break}
bind Classy::Table <<TableRight>> {%W selection clear ; %W activate;break}
bind Classy::Table <<SelectTableUp>> {%W movey -1 select;break}
bind Classy::Table <<SelectTableDown>> {%W movey 1 select;break}
bind Classy::Table <<SelectTableLeft>> {%W movex -1 select;break}
bind Classy::Table <<SelectTableRight>> {%W movex 1 select;break}
bind Classy::Table <<MExtend>> {%W selection anchor ; 	%W activate @%x,%y ;	break}
bind Classy::Table <<Return>> {%W activate;break}

bind Classy::Table::single <<TableUp>> {[winfo parent %W] movey -1;break}
bind Classy::Table::single <<TableDown>> {[winfo parent %W] movey 1;break}
bind Classy::Table::single <<TableLeft>> {[winfo parent %W] movex -1;break}
bind Classy::Table::single <<TableRight>> {[winfo parent %W] movex 1;break}
bind Classy::Table::single <<SelectTableUp>> {[winfo parent %W] movey -1 select;break}
bind Classy::Table::single <<SelectTableDown>> {[winfo parent %W] movey 1 select;break}
bind Classy::Table::single <<SelectTableLeft>> {[winfo parent %W] movex -1 select;break}
bind Classy::Table::single <<SelectTableRight>> {[winfo parent %W] movex 1 select;break}
bind Classy::Table::single <<TableReturn>> {[winfo parent %W] movey 1;break}
bind Classy::Table::single <<Return>> {[winfo parent %W] movey 1;break}
bind Classy::Table::single <<PageUp>> {[winfo parent %W] yview scroll -1 pages ;break}
bind Classy::Table::single <<PageDown>> {[winfo parent %W] yview scroll 1 pages ;break}
bind Classy::Table::single <<WordLeft>> {[winfo parent %W] xview scroll -1 pages ;break}
bind Classy::Table::single <<WordRight>> {[winfo parent %W] xview scroll 1 pages ;break}
bind Classy::Table::single <<Action>> {[winfo parent %W] _selectedit %x %y;break}
bind Classy::Table::single <<Action-Motion>> {[winfo parent %W] _selectmotion [winfo parent %W] %x %y edit;break}
bind Classy::Table::single <<Action-ButtonRelease>> {[winfo parent %W] _cancelrepeat;break}
bind Classy::Table::single <<PasteSpecial>> {[winfo parent %W] pastespecial;break}
bind Classy::Table::single <<Escape>> {[winfo parent %W] _restore;break}

bind Classy::Table::multi <<mTableUp>> {[winfo parent %W] movey -1;break}
bind Classy::Table::multi <<mTableDown>> {[winfo parent %W] movey 1;break}
bind Classy::Table::multi <<mTableLeft>> {[winfo parent %W] movex -1;break}
bind Classy::Table::multi <<mTableRight>> {[winfo parent %W] movex 1;break}
bind Classy::Table::multi <<SelectmTableUp>> {[winfo parent %W] movey -1 select;break}
bind Classy::Table::multi <<SelectmTableDown>> {[winfo parent %W] movey 1 select;break}
bind Classy::Table::multi <<SelectmTableLeft>> {[winfo parent %W] movex -1 select;break}
bind Classy::Table::multi <<SelectmTableRight>> {[winfo parent %W] movex 1 select;break}
bind Classy::Table::multi <<TableReturn>> {[winfo parent %W] movey 1;break}
bind Classy::Table::multi <<PageUp>> {[winfo parent %W] yview scroll -1 pages ;break}
bind Classy::Table::multi <<PageDown>> {[winfo parent %W] yview scroll 1 pages ;break}
bind Classy::Table::multi <<WordLeft>> {[winfo parent %W] xview scroll -1 pages ;break}
bind Classy::Table::multi <<WordRight>> {[winfo parent %W] xview scroll 1 pages ;break}
bind Classy::Table::multi <<Action>> {[winfo parent %W] _selectedit %x %y;break}
bind Classy::Table::multi <<Action-Motion>> {[winfo parent %W] _selectmotion [winfo parent %W] %x %y edit;break}
bind Classy::Table::single <<Action-ButtonRelease>> {[winfo parent %W] _cancelrepeat;break}
bind Classy::Table::multi <<PasteSpecial>> {[winfo parent %W] pastespecial;break}
bind Classy::Table::single <<Escape>> {[winfo parent %W] _restore;break}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::Table

Classy::Table method init {args} {
	# REM Create object
	# -----------------
	private $object canvas data redrawing
	set canvas [super init canvas]
	$object configure -width 100 -height 100 -highlightthicknes 0 -bd 0
	Classy::Text $object.edit -bg white -width 1 -height 1
#	Classy::chainw $object.edit $object
	bindtags $object.edit [list $object.edit Classy::Table::single Classy::Text . all]
	set data(edit) [$canvas create window -1000 -1000 -window $object.edit \
		-width 1 -height 1 -anchor nw]
	# REM set variables
	# -----------------
	set redrawing 0
	set data(y,start) 0
	set data(x,start) 0
	set data(x,num) 0
	set data(y,num) 0
	set data(xmin) 0
	set data(xmax) 0
	set data(ymin) 0
	set data(ymax) 0
	set data(active) {0 0}
	set data(font) [Classy::optionget $object font Font Font]
	set data(bg) [Classy::optionget $object background Background Background]
	set data(fg) [Classy::optionget $object foreground Foreground Foreground]
	set data(x,gridcolor) [Classy::optionget $object xGridColor Foreground Foreground]
	set data(y,gridcolor) [Classy::optionget $object yGridColor Foreground Foreground]
	set data(x,gridwidth) [Classy::optionget $object xGridWidth GridWidth 1]
	set data(y,gridwidth) [Classy::optionget $object yGridWidth GridWidth 1]
	entry $object.temp -font [Classy::optionget $object font Font Font]
	set data(x,s) [winfo reqwidth $object.temp]
	set data(y,s) [winfo reqheight $object.temp]
	set data(x,rs) 0
	set data(y,rs) 0
	set data(var) [privatevar $object tabledata]
	set data(style,default) [list -bg [Classy::optionget $object background Background Background] \
		-fg [Classy::optionget $object foreground Foreground Foreground] \
		-font [Classy::optionget $object font Font Font]]
	set data(style,title) {}
	set data(style,sel) [list -bg [Classy::optionget $object selectBackground Foreground selectBackground] \
		-fg [Classy::optionget $object selectForeground Background selectForeground]]
	destroy object.temp
	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
	set data(x,start) $data(xmin)
	set data(y,start) $data(ymin)
	set data(x,start) 0
#	Classy::todo $object _redraw
	return $object
}

Classy::Table chainallmethods {$object.table} Classy::Text

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

Classy::Table addoption -titlecols {titleCols TitleCols 0} {
	private $object data options
	set data(xmin) [expr {$options(-colorigin)+$options(-titlecols)}]
	set data(xmax) [expr {$data(xmin)+$options(-cols)}]
	Classy::todo $object _redraw
}
Classy::Table addoption -colorigin {colOrigin ColOrigin 0} {
	private $object data options
	set data(xmin) [expr {$options(-colorigin)+$options(-titlecols)}]
	set data(xmax) [expr {$data(xmin)+$options(-cols)}]
	Classy::todo $object _redraw
}
Classy::Table addoption -titlerows {titleRows TitleRows 0} {
	private $object data options
	set data(ymin) [expr {$options(-roworigin)+$options(-titlerows)}]
	set data(ymax) [expr {$data(ymin)+$options(-rows)}]
	Classy::todo $object _redraw
}
Classy::Table addoption -roworigin {roqOrigin RowOrigin 0} {
	private $object data options
	set data(ymin) [expr {$options(-roworigin)+$options(-titlerows)}]
	set data(ymax) [expr {$data(ymin)+$options(-rows)}]
	Classy::todo $object _redraw
}

Classy::Table addoption -variable {variable Variable {}} {
	private $object data
	if [string length $value] {
		unset -nocomplain [privatevar $object tabledata]
		set data(var) $value
	} else {
		set data(var) [privatevar $object tabledata]
	}
	Classy::todo $object _redraw
}

#doc {Table options -command} option {-command Command Command} descr {
# gives the command that will be called to get or set the value of a given cell. It must have the 
# following format:<br>
# command object x y ?value?<br>
# The parameters given to the command are the Table objects name, the x and
# y coordinate in the table.
# If the parameter value is not given, the command should return thew current value of the cell
# given by coordinates x and y in the table.
# If value is given, the command should change the value of the cell to this new value.
# If the setcommand fails, the previous value will be restored.
#}
Classy::Table addoption -command {Command Command {}} {}

#doc {Table options -type} option {-type Type Type} descr {
# gives the type of table: this determines the bindings that will be used on the edited cell
# <ul>
# single: no multiline editing is possible (ao: Up and Down move to the next cell)
# multiple: multiline editing is possible (ao: Up and Down move within the cell)
# other values will be used as a bindtag on the editing cell.
# </ul>
#}
Classy::Table addoption -type {type Type single} {
	switch $value {
		single {
			bindtags $object.edit [list $object.edit Classy::Table::single Classy::Text . all]
		}
		multi {
			bindtags $object.edit [list $object.edit Classy::Table::multi Classy::Text . all]
		}
		default {
			bindtags $object.edit [list $object.edit $value Classy::Text . all]
		}
	}
	Classy::todo $object _redraw
}

#doc {Table options -cols} option {-cols cols Cols} descr {
# gives the number of columns in the Table
#}
Classy::Table addoption -cols {cols Cols 5} {
	if {$value < 1} {return -code error "-cols must be larger than 0"}
	Classy::todo $object _redraw
}

#doc {Table options -rows} option {-rows rows rows} descr {
# gives the number of rows in the Table
#}
Classy::Table addoption -rows {rows Rows 20} {
	if {$value < 1} {return -code error "-rows must be larger than 0"}
	Classy::todo $object _redraw
}

#doc {Table options -colsize} option {-colsize colsize colsize} descr {
# gives the default column size
#}
Classy::Table addoption -colsize {colSize ColSize {}} {
	private $object options data
	if {"$value" == ""} {
		catch {destroy $object.temp}
		entry $object.temp -font $options(-font)
		set data(x,s) [winfo reqwidth $object.temp]
		destroy object.temp
	} else {
		set data(x,s) $value
	}
	Classy::todo $object _redraw
}

#doc {Table options -rowsize} option {-rowsize rowsize rowsize} descr {
# gives the default row size
#}
Classy::Table addoption -rowsize {rowSize RowSize {}} {
	private $object options data
	if {"$value" == ""} {
		catch {destroy $object.temp}
		entry $object.temp -font $options(-font)
		set data(y,s) [winfo reqheight $object.temp]
		destroy object.temp
	} else {
		set data(y,s) $value
	}
	Classy::todo $object _redraw
}

#doc {Table options -font} option {-font font Font} descr {
# 
#}
Classy::Table addoption -font {font Font {}} {
	private $object data options
	if [string length $value] {
		set data(font) $value
	} else {
		set data(font) [Classy::optionget $object font Font Font]
	}
	set data(style,default) [map_set $data(style,default) -font $data(font)]
	if ![string length $options(-rowsize)] {
		catch {destroy $object.temp}
		entry $object.temp -font $value
		set data(y,s) [winfo reqheight $object.temp]
		destroy object.temp
	}
	if ![string length $options(-colsize)] {
		catch {destroy $object.temp}
		entry $object.temp -font $value
		set data(x,s) [winfo reqwidth $object.temp]
		destroy object.temp
	}
	$object _clear
	Classy::todo $object _redraw
}

#doc {Table options -background} option {-background background Background} descr {
# 
#}
Classy::Table addoption -background {background Background {}} {
	private $object data
	if [string length $value] {
		set data(bg) $value
	} else {
		set data(bg) [Classy::optionget $object background Background Background]
	}
	set data(style,default) [map_set $data(style,default) -bg $data(bg)]
	Classy::todo $object _redraw
}

#doc {Table options -bg} option {-bg background Background} descr {
# 
#}
Classy::Table addoption -bg {background Background {}} {
	$object configure -background $value
}

#doc {Table options -foreground} option {-foreground foreground Foreground} descr {
# 
#}
Classy::Table addoption -foreground {foreground Foreground {}} {
	private $object data
	if [string length $value] {
		set data(fg) $value
	} else {
		set data(fg) [Classy::optionget $object foreground Foreground Foreground]
	}
	set data(style,default) [map_set $data(style,default) -fg $data(fg)]
	Classy::todo $object _redraw
}

#doc {Table options -fg} option {-fg foreground Foreground} descr {
# 
#}
Classy::Table addoption -fg {foreground Foreground {}} {
	$object configure -foreground $value
}

#doc {Table options -xresize} option {-xresize xResize Resize} descr {
# 
#}
Classy::Table addoption -xresize {xResize Resize {}} {
	private $object data
	set value [true $value]
	set data(x,rs) $value
	Classy::todo $object _redraw
}

#doc {Table options -yresize} option {-yresize yResize Resize} descr {
# 
#}
Classy::Table addoption -yresize {yResize Resize {}} {
	private $object data
	set value [true $value]
	set data(y,rs) $value
	Classy::todo $object _redraw
}

#doc {Table options -xgridwidth} option {-xgridwidth xGridWidth GridWidth} descr {
# 
#}
Classy::Table addoption -xgridwidth {xGridWidth GridWidth 1} {
	private $object data
	if [string length $value] {
		set data(x,gridwidth) $value
	} else {
		set data(x,gridwidth) [Classy::optionget $object xGridWidth GridWidth 1]
	}
	Classy::todo $object _redraw
}

#doc {Table options -ygridwidth} option {-ygridwidth yGridWidth GridWidth} descr {
# 
#}
Classy::Table addoption -ygridwidth {yGridWidth GridWidth 1} {
	private $object data
	if [string length $value] {
		set data(y,gridwidth) $value
	} else {
		set data(y,gridwidth) [Classy::optionget $object yGridWidth GridWidth 1]
	}
	Classy::todo $object _redraw
}

#doc {Table options -xgridcolor} option {-xgridcolor xGridColor GridColor} descr {
# 
#}
Classy::Table addoption -xgridcolor {xGridColor Foreground {}} {
	private $object data
	if [string length $value] {
		set data(x,gridcolor) $value
	} else {
		set data(x,gridcolor) [Classy::optionget $object xGridColor Foreground gray]
	}
	Classy::todo $object _redraw
}

#doc {Table options -ygridcolor} option {-ygridcolor yGridColor GridColor} descr {
# 
#}
Classy::Table addoption -ygridcolor {yGridColor Foreground {}} {
	private $object data
	if [string length $value] {
		set data(y,gridcolor) $value
	} else {
		set data(y,gridcolor) [Classy::optionget $object yGridColor Foreground Foreground]
	}
	Classy::todo $object _redraw
}

#doc {Table options -xscrollcommand} option {-xscrollcommand xscrollcommand xscrollcommand} descr {}
Classy::Table addoption -xscrollcommand {xScrollCommand ScrollCommand {}} {
	if {"$value" != ""} {
		catch {eval $value [$object xview]}
	}
}

#doc {Table options -yscrollcommand} option {-yscrollcommand yscrollcommand yscrollcommand} descr {}
Classy::Table addoption -yscrollcommand {yScrollCommand ScrollCommand {}} {
	if {"$value" != ""} {
		catch {eval $value [$object yview]}
	}
}

#doc {Table options -labels} option {-labels labels Labels} descr {
#}
Classy::Table addoption -labels {labels Labels {}} {
	if {[llength $value]} {
		$object configure -cols [llength $value] -titlerows 1
		$object tag configure title -bg [Classy::realcolor darkBackground] -font [Classy::realfont BoldFont]
	}
	Classy::todo $object _redraw
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

#doc {Table command set} cmd {
#pathname set index value
#} descr {
# set the value of the cell at $index to $value
#}
Classy::Table method set {index value} {
	private $object options data undo
	set table_x [$object index $index]
	set table_y [list_pop table_x]
	set undo(redo) ""
	if [string length [get options(-command) ""]] {
		set code [catch {uplevel #0 $options(-command) $object $table_x $table_y} prev]
		if {$code == 1} {
			set prev "ERROR: $new"
		} elseif {$code != 0} {
			set prev ""
		}
		lappend undo(undo) [list $table_x $table_y $prev]
		set error [catch {uplevel #0 $options(-command) $object $table_x $table_y [list $value]} res]
		$object refreshcell $table_x $table_y
		if {$error == 1} {error $res}
	} else {
		set prev [get ::[set data(var)]($table_x,$table_y) ""]
		lappend undo(undo) [list $table_x $table_y $prev]
		if [string length $value] {
			set ::[set data(var)]($table_x,$table_y) $value
		} else {
			unset -nocomplain ::[set data(var)]($table_x,$table_y)
		}
		$object refreshcell $table_x $table_y
	}
}

Classy::Table method get {index} {
	private $object options data canvas
	set table_x [$object index $index]
	set table_y [list_pop table_x]
	if [string length [get options(-command) ""]] {
		set code [catch {uplevel #0 $options(-command) $object $table_x $table_y} new]
		if {$code == 1} {
			error $new
		} elseif {$code != 0} {
			set new ""
		}
	} else {
		set new [get ::[set data(var)]($table_x,$table_y) ""]
	}
	return $new
}

Classy::Table method undo {} {
	private $object options data undo
	if ![llength $undo(undo)] {
		error "Nothing to undo"
	}
	set current [list_pop undo(undo)]
	foreach {table_x table_y value} $current {}
	if [string length [get options(-command) ""]] {
		set code [catch {uplevel #0 $options(-command) $object $table_x $table_y} prev]
		if {$code == 1} {
			set prev "ERROR: $new"
		} elseif {$code != 0} {
			set prev ""
		}
		if ![string length $value] {
			set sv {{}}
		} else {
			set sv [string_change $value [list { } {\ } \{ \\\{ \} \\\} \$ \\\$ \[ \\\[ \] \\\]]]
		}
		set error [catch {uplevel #0 $options(-command) $object $table_x $table_y [list $value]} res]
		$object refreshcell $table_x $table_y
		if {$error == 1} {error $res}
	} else {
		set prev [get ::[set data(var)]($table_x,$table_y) ""]
		if [string length $value] {
			set ::[set data(var)]($table_x,$table_y) $value
		} else {
			unset -nocomplain ::[set data(var)]($table_x,$table_y)
		}
		$object refreshcell $table_x $table_y
	}
	lappend undo(redo) [list $table_x $table_y $prev]
}

Classy::Table method redo {} {
	private $object options data undo
	if ![llength $undo(redo)] {
		error "Nothing to redo"
	}
	set current [list_pop undo(redo)]
	foreach {table_x table_y value} $current {}
	if [string length [get options(-command) ""]] {
		set code [catch {uplevel #0 $options(-command) $object $table_x $table_y} prev]
		if {$code == 1} {
			set prev "ERROR: $new"
		} elseif {$code != 0} {
			set prev ""
		}
		if ![string length $value] {
			set sv {{}}
		} else {
			set sv [string_change $value [list { } {\ } \{ \\\{ \} \\\} \$ \\\$ \[ \\\[ \] \\\]]]
		}
		set error [catch {uplevel #0 $options(-command) $object $table_x $table_y [list $value]} res]
		$object refreshcell $table_x $table_y
		if {$error == 1} {error $res}
	} else {
		set prev [get ::[set data(var)]($table_x,$table_y) ""]
		if [string length $value] {
			set ::[set data(var)]($table_x,$table_y) $value
		} else {
			unset -nocomplain ::[set data(var)]($table_x,$table_y)
		}
		$object refreshcell $table_x $table_y
	}
	lappend undo(undo) [list $table_x $table_y $prev]
}

Classy::Table method refreshcell {table_x table_y} {
	private $object options data canvas
	if [string length [get options(-command) ""]] {
		set code [catch {uplevel #0 $options(-command) $object $table_x $table_y} new]
		if {$code == 1} {
			error $new
		} elseif {$code != 0} {
			set new ""
		}
	} else {
		set new [get ::[set data(var)]($table_x,$table_y) ""]
	}
	set index [list $table_x $table_y]
	if ![catch {$object _table2canvas $index} x] {
		set y [list_pop x]
		if {($x >= 0)&&($y >= 0)} {
			$canvas itemconfigure $data(fg,$x,$y) -text $new
		}
		if {"$index" == "$data(active)"} {
			$object.edit delete 1.0 end
			$object.edit insert end $new
		}
	}
}

Classy::Table method _redrawcell {cell} {
	private $object data canvas selection options
	foreach {table_y table_x} $cell break
	set pos [$object _table2canvas $cell]
	foreach {y x} $pos break
	if {($x < 0)||($y < 0)} return
	if {($x >= $data(x,num))||($y >= $data(y,num))} return
	set style(-bg) $data(bg)
	set style(-fg) $data(fg)
	set style(-font) $data(font)
	array set style $data(style,default)
	if [info exists data(style,$table_x,)] {array set style $data(style,$table_x,)}
	if [info exists data(style,,$table_y)] {array set style $data(style,,$table_y)}
	if {($x < $options(-titlecols))||($y < $options(-titlerows))} {
		if [info exists data(style,title)] {array set style $data(style,title)}
	}
	if [info exists data(style,$table_y,$table_x)] {array set style $data(style,$table_y,$table_x)}
	if [info exists selection([list $table_x $table_y])] {
		if [info exists data(style,sel)] {array set style $data(style,sel)}
	}
	set fg [list $style(-fg) $style(-font)]
	if {"$fg" != "$data(fgst,$x,$y)"} {
		$canvas itemconfigure $data(fg,$x,$y) -fill $style(-fg) -font $style(-font)
		set data(fgst,$x,$y) [list $style(-fg) $style(-font)]
	}
	set bg [list $style(-bg)]
	if {"$bg" != "$data(bgst,$x,$y)"} {
		$canvas itemconfigure $data(bg,$x,$y) -fill $style(-bg) -outline $style(-bg)
		set data(bgst,$x,$y) [list $style(-bg)]
	}
}

#doc {Table command cut} cmd {
#pathname cut
#} descr {
# puts the data in the selected cells in the selection, and deletes it afterwards
#}
Classy::Table method cut {} {
	private $object options data
	$object copy
	foreach cell [$object selection current] {
		$object set $cell ""
	}
}

#doc {Table command copy} cmd {
#pathname copy
#} descr {
# puts the data in the selected cells in the selection
#}
Classy::Table method copy {} {
	private $object options data
	set result {}
	set prevy {}
	set line {}
	foreach cell [$object selection current] {
		set y [lindex $cell 1]
		if {"$y" != "$prevy"} {
			if [llength $line] {lappend result $line}
			set line {}
			set prevy $y
		}
		lappend line [$object get $cell]
	}
	if [llength $line] {lappend result $line}
	clipboard clear -displayof $object
	clipboard append -displayof $object $result
	return $result
}

#doc {Table command paste} cmd {
#pathname paste ?data?
#} descr {
# paste data in the Table. The data will replace the contents of each selected cell.
#}
Classy::Table method paste {args} {
	private $object options data
	if {"$args" == ""} {
		set pasted [selection get -displayof $object -selection CLIPBOARD]
	} else {
		set pasted $args
	}
	foreach cell [$object selection current] {
		$object set $cell $pasted
	}
}

#doc {Table command pastespecial} cmd {
#pathname paste ?data?
#} descr {
# paste data in the Table. The data must be a list where each element is a list that contains the values
# for one row. If no arguments are given, the data in the clipboard is pasted.
#}
Classy::Table method pastespecial {args} {
	private $object options data
	if {"$args" == ""} {
		set pasted [selection get -displayof $object -selection CLIPBOARD]
	} else {
		set pasted $args
	}
	set cells [$object selection current]
	if ![llength $cells] {lappend cells $data(active)}
	foreach cell $cells {
		set tx $cell
		set y [list_pop tx]
		foreach line $pasted {
			set x $tx
			foreach value $line {
				$object set [list $x $y] $value
				incr x
			}
			incr y
		}
	}
}

#doc {Table command movex} cmd {
#pathname movex w step ?sel?
#} descr {
# 
#}
Classy::Table method movex {step args} {
	private $object options data
	if [llength $args] {
		if {"$args" != "select"} {
			error "wrong syntax: should be \"$object movex step ?select?\""
		}
		$object selection anchor
	}
	set x $data(active)
	set y [list_pop x]
	incr x $step
	set min $data(xmin)
	set max $data(xmax)
	if {$x < $data(xmin)} {set x $data(xmin)}
	if {$x >= $data(xmax)} {set x [expr {$data(xmax)-1}]}
	set pos [$object _table2canvas [list $x 0]]
	list_pop pos
	incr pos
	if {$pos > [expr {$data(x,num)-1}]} {
		set left [expr {$pos - $data(x,num)+1}]
		$object xview scroll $left
		if ![info exists data(select)] {
			$object activate [list $x $y]
		}
	} elseif {$pos <= 0} {
		set left [expr {0 - $pos - 1}]
		$object xview scroll $left
		if ![info exists data(select)] {
			$object activate [list $x $y]
		}
	} else {
		$object activate [list $x $y]
	}
}

#doc {Table command movey} cmd {
#pathname movey w step ?select?
#} descr {
#
#}
Classy::Table method movey {step args} {
	private $object options data
	if [llength $args] {
		if {"$args" != "select"} {
			error "wrong syntax: should be \"$object movey step ?select?\""
		}
		$object selection anchor
	}
	set x $data(active)
	set y [list_pop x]
	incr y $step
	set min $data(ymin)
	set max $data(ymax)
	if {$y < $min} {set y $min}
	if {$y >= $max} {set y [expr {$max-1}]}
	set pos [$object _table2canvas [list 0 $y]]
	list_shift pos
	incr pos
	if {$pos > [expr {$data(y,num)-1}]} {
		set left [expr {$pos - $data(y,num)+1}]
		$object yview scroll $left
		if ![info exists data(select)] {
			$object activate [list $x $y]
		}
	} elseif {$pos <= 0} {
		set left [expr {0 - $pos - 1}]
		$object yview scroll $left
		if ![info exists data(select)] {
			$object activate [list $x $y]
		}
	} else {
		$object activate [list $x $y]
	}
}

#doc {Table command currenty} cmd {
#pathname currenty
#} descr {
#
#}
Classy::Table method currenty {} {
	private $object data
	return [lindex $data(active) 1]
}

#doc {Table command currentx} cmd {
#pathname currentx
#} descr {
#
#}
Classy::Table method currentx {} {
	private $object data
	return [lindex $data(active) 0]
}

#doc {Table command see} cmd {
#pathname see ?index?
#} descr {
#}
Classy::Table method see {{index {}}} {
	private $object data
	if ![llength $index] {set index $data(active)}
	set active $data(active)
	set index [$object index $index]
	set cx [$object _table2canvas $index]
	set cy [list_pop cx]
	set pos [lindex $index 1]
	if {$pos < $data(ymin)} {set pos $data(ymin)}
	if {$pos >= $data(ymax)} {set pos [expr {$data(ymax)-1}]}
	if {$cy >= [expr {$data(y,num)-1}]} {
		set h [winfo height $object]
		set page 0
		while {$pos >= $data(ymin)} {
			if [info exists data(y,s,$pos)] {
				incr page $data(y,s,$pos)
			} else {
				incr page $data(y,s)
			}
			if {$page >= $h} {
				incr pos
				break
			}
			incr pos -1
		}
		incr pos
		set data(y,start) $pos
		Classy::todo $object _redraw
	} elseif {$cy <= 0} {
		set data(y,start) $pos
		Classy::todo $object _redraw
	}
	set pos [lindex $index 0]
	if {$pos < $data(xmin)} {set pos $data(xmin)}
	if {$pos >= $data(xmax)} {set pos [expr {$data(xmax)-1}]}
	if {$cx >= [expr {$data(x,num)-1}]} {
		set w [winfo width $object]
		set page 0
		while {$pos >= $data(xmin)} {
			if [info exists data(x,s,$pos)] {
				incr page $data(x,s,$pos)
			} else {
				incr page $data(x,s)
			}
			if {$page >= $w} {
				incr pos
				break
			}
			incr pos -1
		}
		incr pos
		set data(x,start) $pos
		Classy::todo $object _redraw
	} elseif {$cx <= 0} {
		set data(x,start) $pos
		Classy::todo $object _redraw
	}
}

#doc {Table command xview} cmd {
#pathname xview args
#} descr {
#}
Classy::Table method xview {args} {
	private $object options data
	set size [expr {$data(x,num)-$options(-titlecols)}]
	if {$size <= 0} {return {0 1}}
	set min $data(xmin)
	set max $data(xmax)
	set pos $data(x,start)
	switch [lindex $args 0] {
		"" {
			set end [expr {double($pos-$min+$size)/($max-$min)}]
			if {$end > 1} {set end 1}
			return [list [expr {double($pos-$min)/($max-$min)}] $end]
		}
		moveto {
			set fraction [lindex $args 1]
			set pos [expr {int($fraction*$max)}]
			set newpos [expr {$pos + [lindex $data(active) 0] - $data(x,start)}]
			if {$newpos >= $options(-cols)} {set newpos [expr {$options(-cols)-1}]}
			if {$newpos < $min} {set newpos $min}
		}
		scroll {
			set number [lindex $args 1]
			set what [lindex $args 2]
			if {"$what"=="pages"} {
				set w [winfo width $object]
				set pos $options(-colorigin)
				for {set i 0} {$i < $options(-titlecols)} {incr i} {
					if [info exists data(x,s,$pos)] {
						incr w -$data(x,s,$pos)
					} else {
						incr w -$data(x,s)
					}
					incr pos
				}
				if {$number>0} {set step 1} else {set step -1;set number [expr {-$number}]}
				set pos $data(x,start)
				set page 0
				for {set i 0} {$i < $number} {incr i} {
					while 1 {
						if [info exists data(x,s,$pos)] {
							incr page $data(x,s,$pos)
						} else {
							incr page $data(x,s)
						}
						if {$page >= $w} break
						if {($step < 0)&&($pos < 0)} break
						incr pos $step
					}
				}
				if {$pos == $data(x,start)} {set pos [expr {$data(x,start)+$step}]}
				set newpos [expr {$pos + [lindex $data(active) 0] - $data(x,start)}]
				if {$newpos >= $options(-cols)} {set newpos [expr {$options(-cols)-1}]}
				if {$newpos < $min} {set newpos $min}
			} else {
				set pos [expr {$pos + $number}]
				set newpos [expr {$pos + [lindex $data(active) 0] - $data(x,start)}]
				if {$newpos >= $options(-cols)} {set newpos [expr {$options(-cols)-1}]}
				if {$newpos < $min} {set newpos $min}
			}
		}
	}
	if {$pos >= $max} {set pos [expr {$max-1}]}
	if {$pos < $min} {set pos $min}
	set data(x,start) $pos
	if [info exists newpos] {
		$object activate [list $newpos [lindex $data(active) 1]]
	}
	Classy::todo $object _redraw
	set end [expr {double($pos-$min+$size)/($max-$min)}]
	if {$end > 1} {set end 1}
	return [list [expr {double($pos-$min)/($max-$min)}] $end]
}

#doc {Table command yview} cmd {
#pathname yview args
#} descr {
#}
Classy::Table method yview {args} {
	private $object options data
	set pos $data(y,start)
	set size [expr {$data(y,num)-$options(-titlerows)}]
	if {$size <= 0} {return {0 1}}
	set min $data(ymin)
	set max $data(ymax)
	switch [lindex $args 0] {
		"" {
			set end [expr {double($pos-$min+$size)/($max-$min)}]
			if {$end > 1} {set end 1}
			return [list [expr {double($pos-$min)/($max-$min)}] $end]
		}
		moveto {
			set fraction [lindex $args 1]
			set pos [expr {int($fraction*$max)}]
			set newpos [expr {$pos + [lindex $data(active) 1] - $data(y,start)}]
			if {$newpos >= $options(-rows)} {set newpos [expr {$options(-rows)-1}]}
			if {$newpos < $min} {set newpos $min}
		}
		scroll {
			set number [lindex $args 1]
			set what [lindex $args 2]
			if {"$what"=="pages"} {
				set h [winfo height $object]
				set pos $options(-colorigin)
				for {set i 0} {$i < $options(-titlerows)} {incr i} {
					if [info exists data(y,s,$pos)] {
						incr h -$data(y,s,$pos)
					} else {
						incr h -$data(y,s)
					}
					incr pos
				}
				if {$number>0} {set step 1} else {set step -1;set number [expr {-$number}]}
				set pos $data(y,start)
				set page 0
				for {set i 0} {$i < $number} {incr i} {
					while 1 {
						if [info exists data(y,s,$pos)] {
							incr page $data(y,s,$pos)
						} else {
							incr page $data(y,s)
						}
						if {$page >= $h} break
						if {($step < 0)&&($pos < 0)} break
						incr pos $step
					}
				}
				if {$pos == $data(y,start)} {set pos [expr {$data(y,start)+$step}]}
				set newpos [expr {$pos + [lindex $data(active) 1] - $data(y,start)}]
				if {$newpos >= $options(-rows)} {set newpos [expr {$options(-rows)-1}]}
				if {$newpos < $min} {set newpos $min}
			} else {
				set pos [expr {$pos + $number}]
				set newpos [expr {$pos + [lindex $data(active) 1] - $data(y,start)}]
				if {$newpos >= $options(-rows)} {set newpos [expr {$options(-rows)-1}]}
				if {$newpos < $min} {set newpos $min}
			}
		}
	}
	if {$pos >= $max} {set pos [expr {$max-1}]}
	if {$pos < $min} {set pos $min}
	set data(y,start) $pos
	if [info exists newpos] {
		$object activate [list [lindex $data(active) 0] $newpos]
	}
	Classy::todo $object _redraw
#	if [info exists x] {
#		if [info exists newpos] {
#			$object activate [list $x $newpos]
#		}
#	}
	set end [expr {double($pos-$min+$size)/($max-$min)}]
	if {$end > 1} {set end 1}
	return [list [expr {double($pos-$min)/($max-$min)}] $end]
}

Classy::Table method _clear {} {
	private $object data canvas
	foreach pattern {
		rx,* ry,* rw,* rh,* tx,* ty,* tw,* table_x,* table_y,*
	} {
		foreach name [array names data $pattern] {
			unset data($name)
		}
	}
	set data(x,num) 0
	set data(y,num) 0
	$canvas delete _bg
	$canvas delete _fg
	$canvas delete _grid
}

Classy::Table method index {index} {
	private $object options data
	if {[llength $index] == 2} {
		return $index
	}
	switch -regexp -- $index {
		{^@(-?[0-9]+),(-?[0-9]+)$} {
			set canvas_x [split [string range $index 1 end] ,]
			set canvas_y [list_pop canvas_x]
			set table_x 1
			while {[info exists data(rx,$table_x)]} {
				if {$canvas_x < $data(rx,$table_x)} break
				incr table_x
			}
			if ![info exists data(rx,$table_x)] {
				incr table_x [expr {($canvas_x-$data(rx,[expr {$table_x-1}]))/$data(x,s)}]
			}
			incr table_x -1
			if {$table_x < $options(-titlecols)} {
				incr table_x $options(-colorigin)
			} else {
				incr table_x -$options(-titlecols)
				incr table_x $data(x,start)
			}
			set table_y 1
			while {[info exists data(ry,$table_y)]} {
				if {$canvas_y < $data(ry,$table_y)} break
				incr table_y
			}
			if ![info exists data(ry,$table_y)] {
				incr table_y [expr {($canvas_y-$data(ry,[expr {$table_y-1}]))/$data(y,s)}]
			}
			incr table_y -1
			if {$table_y < $options(-titlerows)} {
				incr table_y $options(-roworigin)
			} else {
				incr table_y -$options(-titlerows)
				incr table_y $data(y,start)
			}
			return [list $table_x $table_y]
		}
		{^(-?[0-9]+)[, ](-?[0-9]+)$} {
			set table_x [split $index ",. "]
			set table_y [list_pop table_x]
			return [list $table_x $table_y]
		}
		{^active$} {
			return $data(active)
		}
		default {
			return -code error "incorrect index: should be x,y , {x y} or @x,y"
		}
	}
}

Classy::Table method _block2cells {block} {
	set result ""
	set len [llength $block]
	if {$len == 0} {
		return ""
	} elseif {$len == 1} {
		set first [$object index [lindex $block 0]]
		set last $first
	} elseif {$len == 2} {
		set first [$object index [lindex $block 0]]
		set last [$object index [lindex $block 1]]
	} else {
		error "error in block definition \"$block\": must be: \"startindex ?endindex?\""
	}
	foreach {startrow startcol} $first {}
	foreach {endrow endcol} $last {}
	
	foreach val $first var {startrow startcol} {set $var $val}
	foreach val $last var {endrow endcol} {set $var $val}
	if {$startrow > $endrow} {set temp $endrow; set endrow $startrow; set startrow $temp}
	if {$startcol > $endcol} {set temp $endcol; set endcol $startcol; set startcol $temp}
	for {set rcol $startcol} {$rcol <= $endcol} {incr rcol} {
		for {set rrow $startrow} {$rrow <= $endrow} {incr rrow} {
			lappend result [list $rrow $rcol]
		}
	}
	return $result
}

Classy::Table method _table2canvas {tablecoords} {
	private $object options data
	set table_x [lindex $tablecoords 0]
	set table_y [lindex $tablecoords 1]
	set temp [expr {$table_x-$options(-colorigin)}]
	if {$temp<$options(-titlecols)} {
		set x $temp
	} elseif {$table_x < $data(x,start)} {
		set x [expr {$table_x-$data(x,start)}]
	} else {
		set x [expr {$table_x-$data(x,start)+$options(-titlecols)}]
	}
	set temp [expr {$table_y-$options(-roworigin)}]
	if {$temp<$options(-titlerows)} {
		set y $temp
	} elseif {$table_y < $data(y,start)} {
		set y [expr {$table_y-$data(y,start)}]
	} else {
		set y [expr {$table_y-$data(y,start)+$options(-titlerows)}]
	}
	return [list $x $y]
}

Classy::Table method activate {{index {}}} {
	private $object data selection
	if [info exists data(resize)] return
	if ![string length $index] {
		set index $data(active)
	}
	set active [$object index $index]
	if ![info exists data(select)] {
		$object selection clear
		$object _edit $index
	} else {
		set old [array names selection]
		set new [$object _block2cells [list $data(select) $active]]
		set clear [list_lremove $old $new]
		foreach cell $clear {
			unset selection($cell)
			$object _redrawcell $cell
		}
		set set [list_lremove $new $old]
		foreach cell $set {
			set selection($cell) 1
			$object _redrawcell $cell
		}
	}
	set data(active) $active
}

Classy::Table method focus {} {
	private $object data
	if [info exists data(editing)] {
		focus $object.edit
	} else {
		focus $object
	}
}

Classy::Table method _restore {} {
	private $object options data canvas
	if ![info exists data(editing)] return
	set value [get data(prevvalue) ""]
	$object set $data(active) $value
}

Classy::Table method _edit {index} {
	private $object options data canvas
	if [info exists data(editing)] {
		set value [$object.edit get 1.0 end-1c]
		if {"$value" != "[get data(prevvalue) ""]"} {
			$object set $data(active) $value
		}
	}
	if [llength $index] {
		set table [$object index $index]
		foreach {table_x table_y} $table {}
	}
	if {[catch {$object _table2canvas $table} x] || ([llength $index] == 0)} {
		unset -nocomplain data(editing)
		unset -nocomplain data(editwidth)
		unset -nocomplain data(editheight)
		$canvas coords $data(edit) -1000 -1000
		$canvas itemconfigure $data(edit) -width 1 -height 1
	} else {
		set y [list_pop x]
		array set style $data(style,default)
		if [info exists data(style,$table_x,)] {array set style $data(style,$table_x,)}
		if [info exists data(style,,$table_y)] {array set style $data(style,,$table_y)}
		if {($x < $options(-titlecols))||($y < $options(-titlerows))} {
			if [info exists data(style,title)] {array set style $data(style,title)}
		}
		if [info exists data(style,$table_y,$table_x)] {array set style $data(style,$table_y,$table_x)}
		if [info exists selection([list $table_x $table_y])] {
			if [info exists data(style,sel)] {array set style $data(style,sel)}
		}
		if [info exists style(-editable)] return
		set bbox [$canvas coords _bg$x,$y]
		if {[llength $bbox] != 4} {
			unset -nocomplain data(editing)
			$canvas coords $data(edit) -1000 -1000
			$canvas itemconfigure $data(edit) -width 1 -height 1
			return
		}
		set data(editing) 1
		set rx [lindex $bbox 0]
		set ry [lindex $bbox 1]
		set rw [expr {[lindex $bbox 2]-$rx}]
		set rh [expr {[lindex $bbox 3]-$ry}]
		set bg [$canvas itemcget _bg$x,$y -fill]
		set fg [$canvas itemcget _fg$x,$y -fill]
		set font [$canvas itemcget _fg$x,$y -font]
		$object.edit configure -bg $bg -font $font -fg $fg
		$canvas coords $data(edit) $rx $ry
		$canvas itemconfigure $data(edit) -window $object.edit \
			-width $rw -height $rh -anchor nw
		$canvas raise $data(edit)
		$object.edit delete 1.0 end
		if [string length [get options(-command) ""]] {
			set code [catch {uplevel #0 $options(-command) $object $table_x $table_y} new]
			if {$code == 1} {
				set new "ERROR: $new"
			} elseif {$code != 0} {
				set new ""
			}
		} else {
			set new [get ::[set data(var)]($table_x,$table_y) ""]
		}
		set data(prevvalue) $new
		$object.edit insert end $new
		if [scan $index @%d,%d x y] {
			set cx [$canvas coords $data(edit)]
			set cy [list_pop cx]
			set x [expr {int($x-$cx)}]
			set y [expr {int($y-$cy)}]
			$object _selectedit $x $y
		}
		$object.edit clearundo
	}
}

Classy::Table method _startresize {dir pos x y} {
	private $object canvas data
	if {"$dir" == "y"} {
		set data(resizesize) [$object rowconfigure $pos -size]
		set data(resize) $y
	} else {
		set data(resizesize) [$object columnconfigure $pos -size]
		set data(resize) $x
	}
	$canvas itemconfigure $data(edit) -width 1 -height 1
	bind $object <<Action-Motion>> "%W _doresize $dir $pos %x %y ; break"
	bind $object <<Action-ButtonRelease>> {%W _stopresize; break}
}

Classy::Table method _doresize {dir pos x y} {
	private $object data
	if ![info exists data(resizesize)] [list $object _stopresize]
	if ![info exists data(resize)] [list $object _stopresize]
	if {"$dir" == "y"} {
		set size [expr {$data(resizesize)+$y-$data(resize)}]
		$object rowconfigure $pos -size $size
	} else {
		set size [expr {$data(resizesize)+$x-$data(resize)}]
		$object columnconfigure $pos -size $size
	}
}

Classy::Table method _stopresize {} {
	private $object data
	bind $object <<Action-Motion>> {}
	bind $object <<Action-ButtonRelease>> {}
	if [info exists data(resizeedit)] {$object activate $data(resizeedit)}
	unset -nocomplain data(resizesize)
	unset -nocomplain data(resize)
	unset -nocomplain data(resizeedit)
	Classy::todo $object _redraw
}

Classy::Table method tag {option tag args} {
	private $class actions
	private $object data
	switch $option {
		configure {
			set len [llength $args]
			if {$len == 0} {
				foreach {option value} $data(style,default) {
					set style($option) ""
				}
				if [info exists data(style,$tag)] {
					foreach {option value} $data(style,$tag) {
						set style($option) $value
					}
				}
				return [array get style]
			} elseif {$len == 1} {
				set option [lindex $args 0]
				if [info exists data(style,$tag)] {
					if ![catch {map_get $data(style,$tag) $option} value] {
						return $value
					}
				}
				return ""
			} else {
				catch {array set style $data(style,$tag)}
				foreach {option value} $args {
					switch -- $option {
						-foreground {set option -fg}
						-background {set option -bg}
						-fg - -bg - -font {} 
						-editable {if [true $value] {set value ""} else {set value 0}}
						default {
							error "Unknown option \"$option\": should be one of: -fg, -bg, -font or -editable"
						}
					}
					if [string length $value] {
						set style($option) $value
					} else {
						unset -nocomplain style($option)
					}
				}
				set data(style,$tag) [array get style]
			}
			Classy::todo $object _redraw
		}
		delete {
			foreach tag $args {
				switch $tag {
					default - sel - {
						error "$tag tag cannot be deleted"
					}
				}
				unset data(style,$tag)
			}
		}
	}
}

Classy::Table method rowconfigure {row args} {
	private $class actions
	private $object data
	set len [llength $args]
	if {$len == 0} {
		set result [$object tag configure $row,]
		foreach {type key} {size s resize rs gridwidth gridwidth gridcolor gridcolor} {
			lappend result -$type
			if [info exists data(y,$key,$row)] {
				lappend result $data(y,$key,$row)
			} else {
				lappend result $data(y,$key)
			}
		}
		return $result
	} elseif {$len == 1} {
		set option [lindex $args 0]
		switch -- $option {
			-size {
				if [info exists data(y,s,$row)] {
					return $data(y,s,$row)
				} else {
					return $data(y,s)
				}
			}
			-resize {
				if [info exists data(y,rs,$row)] {
					return $data(y,rs,$row)
				} else {
					return $data(y,rs)
				}
			}
			-gridwidth {
				if [info exists data(y,gridwidth,$row)] {
					return $data(y,gridwidth,$row)
				} else {
					return $data(y,gridwidth)
				}
			}
			-gridcolor {
				if [info exists data(y,gridcolor,$row)] {
					return $data(y,gridcolor,$row)
				} else {
					return $data(y,gridcolor)
				}
			}
			default {
				return [$object tag configure $row, $option]
			}
		}
	} else {
		set todo ""
		foreach {option value} $args {
			switch -- $option {
				-size {
					if {"$value" == ""} {
						unset data(y,s,$row)
					} else {
						if {$value < 1} {set value 1}
						set data(y,s,$row) $value
					}
				}
				-resize {
					if {"$value" == ""} {
						unset -nocomplain data(y,rs,$row)
					} else {
						set data(y,rs,$row) [true $value]
					}
				}
				-gridwidth {
					if {"$value" == ""} {
						unset -nocomplain data(y,gridwidth,$row)
					} else {
						set data(y,gridwidth,$row) $value
					}
				}
				-gridcolor {
					if {"$value" == ""} {
						unset -nocomplain data(y,gridcolor,$row)
					} else {
						set data(y,gridcolor,$row) $value
					}
				}
				-fg - -bg - -font {lappend todo $option $value}
				default {
					error "Unknown option \"$option\": should be one of: -size, -resize, -gridwidth, -gridcolor, -fg, -bg, -font"
				}
			}
			eval $object tag configure $row, $todo
		}
	}
	Classy::todo $object _redraw
}

Classy::Table method columnconfigure {col args} {
	private $class actions
	private $object data
	set len [llength $args]
	if {$len == 0} {
		set result [$object tag configure ,$col]
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
				return [$object tag configure $col, $option]
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
			eval $object tag configure $col, $todo
		}
	}
	Classy::todo $object _redraw
}

Classy::Table method selection {option args} {
	private $object selection data
	switch $option {
		set {
			foreach cell [$object _block2cells $args] {
				set selection($cell) 1
				$object _redrawcell $cell
			}
		}
		anchor {
			private $object options data
			if [info exists data(select)] return
			if [llength $args] {
				set index [lindex $args 0]
				set data(select) [$object index $index]
			} else {
				set data(select) $data(active)
			}
			$object _edit {}
			$object activate $data(active)
		}
		clear {
			unset -nocomplain data(select)
			set len [llength $args]
			if {$len == 0} {
				set old [array names selection]
			} else {
				set old [$object _block2cells $args]
			}
			foreach cell $old {
				unset selection($cell)
				$object _redrawcell $cell
			}
		}
		current {
			return [lsort -integer -index 1 [array names selection]]
#			unset -nocomplain a
#			set result ""
#			foreach name [array names selection] {
#				lappend a([lindex $name 1]) $name
#			}
#			foreach col [lsort -integer [array names a]] {
#				lappend result [lsort -integer -index 0 $a($col)]
#			}
#			return $result
		}
		default {
			error "unknown option \"$option\", should be add, clear or current"
		}
	}
}

Classy::Table method _redraw {} {
	private $object options data redrawing
	Classy::update Classy::Table-_redraw idletasks
	Classy::canceltodo $object _redrawwindows
	if $redrawing {
		Classy::canceltodo $object _redraw
		set redrawing 0
		Classy::update Classy::Table-_redraw2 idletasks
	}
	set data(xmin) [expr {$options(-colorigin)+$options(-titlecols)}]
	set data(xmax) [expr {$options(-colorigin)+$options(-cols)}]
	set data(ymin) [expr {$options(-roworigin)+$options(-titlerows)}]
	set data(ymax) [expr {$options(-roworigin)+$options(-rows)}]
	set redrawing 1
	$object _draw $data(x,start) $data(y,start) [winfo width $object] [winfo height $object]
	$object _drawvalues $data(x,start) $data(y,start)
	set redrawing 0
	$object activate
	if {"$options(-xscrollcommand)" != ""} {
		eval $options(-xscrollcommand) [$object xview]
	}
	if {"$options(-yscrollcommand)" != ""} {
		eval $options(-yscrollcommand) [$object yview]
	}
	Classy::todo $object _redrawwindows
}

Classy::Table method _draw {sx sy w h} {
set ipadx 2
set ipady 2
	private $object options data canvas selection
	# ---------- Reset default looks ----------
	set xmin $data(xmin)
	set xmax $data(xmax)
	set ymin $data(ymin)
	set ymax $data(ymax)
	$canvas itemconfigure _gridcol -fill $data(x,gridcolor) -width $data(x,gridwidth)
	$canvas itemconfigure _gridrow -fill $data(y,gridcolor) -width $data(y,gridwidth)
	set cw [lindex [$canvas coords _gridrow0] 2]
	if {$cw == ""} {set cw 100}
	set ch [lindex [$canvas coords _gridcol0] 3]
	if {$ch == ""} {set ch 100}
	# ---------- Move columns to the right place and create new where necessary ----------
	set titletodo $options(-titlecols)
	set table_x $options(-colorigin)
	set rx 0  ;# x pixels on canvas
	set x 0   ;# x col on canvas
	while {$rx < $w} {
		if {$titletodo == 0} {
			set table_x $sx
		}
		incr titletodo -1
		if [info exists data(x,s,$table_x)] {
			set rw $data(x,s,$table_x)
		} else {
			set rw $data(x,s)
		}
		set tw [expr {$rw-2*$ipadx}]
		if [info exists data(rx,$x)] {
			# column exists
			set move 0
			if {$data(rx,$x) != $rx} {
				set move [expr {$rx - $data(rx,$x)}]
				$canvas move _col$x $move 0
				set data(rx,$x) $rx
			}
			set move [expr {$rw-$data(rw,$x)}]
			if {$move != 0} {
				$canvas move _gridcol$x $move 0
			}
			if {$data(rw,$x) != $rw} {
				$canvas scale _bgcol$x $rx 1 [expr {double($rw)/$data(rw,$x)}] 1
				set data(rw,$x) $rw
			}
			if {$data(tw,$x) != $tw} {
				$canvas itemconfigure _fgcol$x -width $tw
				set data(tw,$x) $tw
			}
			$canvas raise _col$x
		} else {
			# column has to be made
			set data(rx,$x) $rx
			set data(rw,$x) $rw
			set data(tx,$x) [expr {$rx+$ipadx}]
			set data(tw,$x) $tw
			set y 0
			set cy 0
			set rxe [expr {$rx+$rw}]
			while {[info exists data(ry,$y)]} {
				set ry $data(ry,$y)
				set data(bg,$x,$y) [$canvas create rectangle $rx $ry $rxe [expr {$ry+$data(rh,$y)}] \
					-tags [list _col$x _row$y _bgcol$x _bgrow$y _bg$x,$y _bg] \
					-fill $data(bg) -outline $data(bg)]
				set data(fg,$x,$y) [$canvas create text $data(tx,$x) [expr {$ry+$ipady}] \
					-anchor nw -text "" -width $tw -tags [list _col$x _row$y _fgcol$x _fgrow$y _fg$x,$y _fg] \
					-fill $data(fg) -font $data(font)]
				set data(bgst,$x,$y) [list $data(bg)]
				set data(fgst,$x,$y) [list $data(fg) $data(font)]
				incr y
				incr cy
			}
			$canvas create line $rxe 0 $rxe $ch \
				-tags [list _col$x _gridcol$x _gridcol _grid] \
				-fill $data(x,gridcolor) -width $data(x,gridwidth)
		}
		set data(table_x,$x) $table_x
		# next
		incr rx $rw
		incr x
		if {"$table_x" == "label"} {
			set table_x $sx
		} else {
			incr table_x
		}
		if {$table_x == $xmax} break
	}
	# ---------- Remove columns that are not displayed ----------
	set data(x,num) $x
	set data(table_x,num) $table_x
	while {[info exists data(rx,$x)]} {
		$canvas delete _col$x
		unset data(rx,$x)
		unset data(rw,$x)
		unset data(tx,$x)
		unset data(tw,$x)
		incr x
	}
	# ---------- Move rows to the right place and create new where necessary ----------
	set titletodo $options(-titlerows)
	set table_y $options(-roworigin)
	set ry 0  ;# y pixels on canvas
	set y 0   ;# y col on canvas
	while {$ry < $h} {
		if {$titletodo == 0} {
			set table_y $sy
		}
		incr titletodo -1
		if [info exists data(y,s,$table_y)] {
			set rh $data(y,s,$table_y)
		} else {
			set rh $data(y,s)
		}
		if [info exists data(ry,$y)] {
			# column exists
			if {$data(ry,$y) != $ry} {
				set move [expr {$ry - $data(ry,$y)}]
				$canvas move _row$y 0 $move
				set data(ry,$y) $ry
			}
			set move [expr {$rh-$data(rh,$y)}]
			if {$move != 0} {
				$canvas move _gridrow$y 0 $move
			}
			if {$data(rh,$y) != $rh} {
				$canvas scale _bgrow$y 1 $ry 1 [expr {double($rh)/$data(rh,$y)}]
				set data(rh,$y) $rh
			}
			$canvas raise row$y
		} else {
			# column has to be made
			set data(ry,$y) $ry
			set data(rh,$y) $rh
			set data(ty,$y) [expr {$ry+$ipady}]
			set x 0
			set cx 0
			set rye [expr {$ry+$rh}]
			while {[info exists data(rx,$x)]} {
				set rx $data(rx,$x)
				set data(bg,$x,$y) [$canvas create rectangle $rx $ry [expr {$rx+$data(rw,$x)}] $rye \
					-tags [list _col$x _row$y _bgcol$x _bgrow$y _bg$x,$y _bg] \
					-fill $data(bg) -outline $data(bg)]
				set data(fg,$x,$y) [$canvas create text $data(tx,$x) $data(ty,$y) \
					-anchor nw -text "" -width $tw -tags [list _col$x _row$y _fgcol$x _fgrow$y _fg$x,$y _fg] \
					-fill $data(fg) -font $data(font)]
				set data(bgst,$x,$y) [list $data(bg)]
				set data(fgst,$x,$y) [list $data(fg) $data(font)]
				incr x
				incr cx
			}
			$canvas create line 0 $rye $cw $rye \
				-tags [list _row$y _gridrow$y _gridrow _grid] \
				-fill $data(y,gridcolor) -width $data(y,gridwidth)
		}
		# next
		incr ry $rh
		incr y
		if {"$table_y" == "label"} {
			set table_y $sy
		} else {
			incr table_y
		}
		if {$table_y == $ymax} break
	}
	# ---------- Remove rows that are note displayed ----------
	set data(y,num) $y
	set data(table_y,num) $table_y
	while {[info exists data(ry,$y)]} {
		$canvas delete _row$y
		unset data(ry,$y)
		unset data(rh,$y)
		unset data(ty,$y)
		incr y
	}
	# ---------- resize gridlines ----------
	set y [expr {int($data(y,num)-1)}]
	set x [expr {int($data(x,num)-1)}]
	set w [expr {int($data(rx,$x)+$data(rw,$x)+($data(y,gridwidth)+1)/2)}]
	set h [expr {int($data(ry,$y)+$data(rh,$y)+($data(x,gridwidth)+1)/2)}]
	$canvas scale _gridcol 0 0 1 [expr {double($h)/$ch}]
	$canvas scale _gridrow 0 0 [expr {double($w)/$cw}] 1
	# ---------- Draw and configure x gridlines ----------
	# has to come after the main loop in order to get the raises right
	set ex $data(x,num)
	set ey $data(y,num)
	set x 0
	set y 0
	set titletodo $options(-titlecols)
	set table_x $options(-colorigin)
	while {$x < $ex} {
		if {$titletodo == 0} {
			set table_x $sx
		}
		incr titletodo -1
		set gridwidth [get data(x,gridwidth,$table_x) $data(x,gridwidth)]
		set gridcolor [get data(x,gridcolor,$table_x) $data(x,gridcolor)]
		$canvas itemconfigure _gridcol$x -width $gridwidth -fill $gridcolor
		if [info exists data(x,rs,$table_x)] {set rs $data(x,rs,$table_x)} else {set rs $data(x,rs)}
		if {$rs} {
			$canvas bind _gridcol$x <Enter> [list $canvas configure -cursor sb_h_double_arrow]
			$canvas bind _gridcol$x <Leave> [list $canvas configure -cursor {}]
			$canvas bind _gridcol$x <<Action-ButtonPress>> "%W _startresize x $table_x %x %y; break"
			$canvas bind _gridcol$x <<MExecute>> "%W columnconfigure $table_x -size {}; break"
		} else {
			$canvas bind _gridcol$x <Enter> {}
			$canvas bind _gridcol$x <Leave> {}
			$canvas bind _gridcol$x <<Action-ButtonPress>> {}
			$canvas bind _gridcol$x <<MExecute>> {}
		}
		if $gridwidth {
			$canvas raise _gridcol$x
		}
		incr x
		incr table_x
	}
	# ---------- Draw and configure y gridlines ----------
	set x 0
	set y 0
	set titletodo $options(-titlerows)
	set table_y $options(-roworigin)
	while {$y < $ey} {
		if {$titletodo == 0} {
			set table_y $sy
		}
		incr titletodo -1
		set gridwidth [get data(y,gridwidth,$table_y) $data(y,gridwidth)]
		set gridcolor [get data(y,gridcolor,$table_y) $data(y,gridcolor)]
		$canvas itemconfigure _gridrow$y -width $gridwidth -fill $gridcolor
		if [info exists data(y,rs,$table_y)] {set rs $data(y,rs,$table_y)} else {set rs $data(y,rs)}
		if {$rs} {
			$canvas bind _gridrow$y <Enter> [list $canvas configure -cursor sb_v_double_arrow]
			$canvas bind _gridrow$y <Leave> [list $canvas configure -cursor {}]
			$canvas bind _gridrow$y <<Action-ButtonPress>> "%W _startresize y $table_y %x %y; break"
			$canvas bind _gridrow$y <<MExecute>> "%W rowconfigure $table_y -size {}; break"
		} else {
			$canvas bind _gridrow$y <Enter> {}
			$canvas bind _gridrow$y <Leave> {}
			$canvas bind _gridrow$y <<Action-ButtonPress>> {}
			$canvas bind _gridrow$y <<MExecute>> {}
		}
		if $gridwidth {
			$canvas raise _gridrow$y
		}
		incr y
		incr table_y
	}
	# ---------- style on background ----------
	set x 0
	set table_x $options(-colorigin)
	set titlecolstodo $options(-titlecols)
	while {$x < $ex} {
		if {$titlecolstodo == 0} {set table_x $sx}
		incr titlecolstodo -1
		set y 0
		set table_y $options(-roworigin)
		set titlerowstodo $options(-titlerows)
		while {$y < $ey} {
			if {$titlerowstodo == 0} {set table_y $sy}
			incr titlerowstodo -1
			set style(-bg) $data(bg)
			set style(-fg) $data(fg)
			set style(-font) $data(font)
			array set style $data(style,default)
			if [info exists data(style,$table_x,)] {array set style $data(style,$table_x,)}
			if [info exists data(style,,$table_y)] {array set style $data(style,,$table_y)}
			if {($x < $options(-titlecols))||($y < $options(-titlerows))} {
				if [info exists data(style,title)] {array set style $data(style,title)}
			}
			if [info exists data(style,$table_y,$table_x)] {array set style $data(style,$table_y,$table_x)}
			if [info exists selection([list $table_x $table_y])] {
				if [info exists data(style,sel)] {array set style $data(style,sel)}
			}
			set fg [list $style(-fg) $style(-font)]
			if {"$fg" != "$data(fgst,$x,$y)"} {
				$canvas itemconfigure $data(fg,$x,$y) -fill $style(-fg) -font $style(-font)
				set data(fgst,$x,$y) [list $style(-fg) $style(-font)]
			}
			set bg [list $style(-bg)]
			if {"$bg" != "$data(bgst,$x,$y)"} {
				$canvas itemconfigure $data(bg,$x,$y) -fill $style(-bg) -outline $style(-bg)
				set data(bgst,$x,$y) [list $style(-bg)]
			}
			incr y
			incr table_y
		}
		incr x
		incr table_x
	}
}

Classy::Table method _drawvalues {sx sy} {
	private $object canvas options data redrawing
	if [string length [get options(-command) ""]] {
		set command 1
	} else {
		set var ::$data(var)
		set command 0
	}
	set ex $data(x,num)
	set ey $data(y,num)
	# active
	set ax [$object _table2canvas $data(active)]
	set ay [list_pop ax]
	if {($ax >= 0)&&($ax < $ex)} {
		set x $ax
		set table_x [lindex $data(active) 0]
		set y 0
		set table_y $options(-roworigin)
		set titlerowstodo $options(-titlerows)
		while {$y < $ey} {
			if {$titlerowstodo == 0} {
				set table_y $sy
			}
			incr titlerowstodo -1
			if $command {
				set code [catch {uplevel #0 $options(-command) $object $table_x $table_y} new]
				if {$code == 1} {
					set new "ERROR: $new"
				} elseif {$code != 0} {
					set new ""
				}
			} else {
				set new [get [set var]($table_x,$table_y) ""]
			}
			$canvas itemconfigure $data(fg,$x,$y) -text $new
			incr y
			incr table_y
		}
	}
	if {($ay >= 0)&&($ay < $ey)} {
		set y $ay
		set table_y [lindex $data(active) 1]
		set x 0
		set table_x $options(-colorigin)
		set titlecolstodo $options(-titlecols)
		while {$x < $ex} {
			if {$titlecolstodo == 0} {
				set table_x $sx
			}
			incr titlecolstodo -1
			if {$x != $ax} {
				if $command {
					set code [catch {uplevel #0 $options(-command) $object $table_x $table_y} new]
					if {$code == 1} {
						set new "ERROR: $new"
					} elseif {$code != 0} {
						set new ""
					}
				} else {
					set new [get [set var]($table_x,$table_y) ""]
				}
				$canvas itemconfigure $data(fg,$x,$y) -text $new
			}
			incr x
			incr table_x
		}
	}
	# all
	set x 0
	set table_x $options(-colorigin)
	set titlecolstodo $options(-titlecols)
	while {$x < $ex} {
		if {$titlecolstodo == 0} {
			set table_x $sx
		}
		incr titlecolstodo -1
		if {$x != $ax} {
			set y 0
			set table_y $options(-roworigin)
			set titlerowstodo $options(-titlerows)
			while {$y < $ey} {
				if {$titlerowstodo == 0} {
					set table_y $sy
				}
				incr titlerowstodo -1
				if {$y != $ay} {
					if $command {
						set code [catch {uplevel #0 $options(-command) $object $table_x $table_y} new]
						if {$code == 1} {
							set new "ERROR: $new"
						} elseif {$code != 0} {
							set new ""
						}
					} else {
						set new [get [set var]($table_x,$table_y) ""]
					}
					$canvas itemconfigure $data(fg,$x,$y) -text $new
				}
				incr y
				incr table_y
			}
			Classy::update Classy::Table-_drawvalues
			if !$redrawing {
				return
			}
		}
		incr x
		incr table_x
	}
	$object activate
}

Classy::Table method _selectedit {x y} {
	private $object data
	set data(editwidth) [winfo width $object.edit]
	set data(editheight) [winfo height $object.edit]
	tk::TextButton1 $object.edit $x $y
	$object.edit tag remove sel 0.0 end
	$object selection clear
}

Classy::Table method _selectmotion {w x y {edit {}}} {
	private $object data canvas selection options
	set cx [$canvas coords $data(edit)]
	set cy [list_pop cx]
	if [string length $edit] {
		set x [expr {int($x+$cx)}]
		set y [expr {int($y+$cy)}]
	}
	if [info exists data(editwidth)] {
		if ![string length $edit] {
			set ex [expr {int($x-$cx)}]
			set ey [expr {int($y-$cy)}]
		} else {
			set ex $x
			set ey $y
		}
		if {($ex > 0)&&($ex < $data(editwidth))&&($ey > 0)&&($ey < $data(editheight))} {
			set tk::Priv(x) $ex
			set tk::Priv(y) $ey
			tk::TextSelectTo $object.edit $ex $ey
			set old [array names selection]
			foreach cell $old {
				unset selection($cell)
				$object _redrawcell $cell
			}
			set selection($data(active)) 1
			$object _redrawcell $data(active)
			return 1
		}
	}
	$object selection anchor
	set index [$object index @$x,$y]
	set cx [$object _table2canvas $index]
	set cy [list_pop cx]
	if {$cx < $options(-titlecols)} {
		set index [lreplace $index 0 0 [expr {$data(x,start) - $options(-titlerows) + $cx}]]
	}
	if {$cy < $options(-titlerows)} {
		set index [lreplace $index 1 1 [expr {$data(y,start) - $options(-titlecols) + $cy}]]
	}
	$object activate $index
	$object see $index
	$object _edit {}
}

Classy::Table method _autoscan {} {
	private $object data
	set x [expr {[winfo pointerx $object] - [winfo rootx $object]}]
	set y [expr {[winfo pointery $object] - [winfo rooty $object]}]
	$object _selectmotion $object $x $y
	set data(repeat) [after 50 $object _autoscan]
}

Classy::Table method _cancelrepeat {} {
	private $object data
	catch {after cancel $data(repeat)}
}

Classy::Table method _redrawwindows {} {
#puts _redrawwindows
	private $object canvas windows
	foreach window [array names windows] {
		if {![winfo exists $window]} {
			unset windows($window)
			continue
		}
		set index $windows($window)
		set pos [$object _table2canvas $index]
		foreach {y x} $pos break
		set bbox [$canvas coords _bg$x,$y]
		if {[llength $bbox] != 4} {
			$canvas create window -10000 -10000 -anchor nw -window $window
		} else {
			foreach {x1 y1 x2 y2} $bbox break
			$canvas create window $x1 $y1 -anchor nw -window $window \
				-height [expr {$y2-$y1+1}] -width [expr {$x2-$x1+1}]
		}
	}
}

#doc {Table command window} cmd {
#pathname window configure index options
#} descr {
#}
Classy::Table method window {option args} {
	private $object canvas windows
	switch $option {
	configure {
		foreach {index temp window} $args break
		set index [$object index $index]
		set windows($window) $index
		Classy::todo $object _redrawwindows
	}
	}
}

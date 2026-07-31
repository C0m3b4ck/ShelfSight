# todo
#	undo/redo
#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# TkTable
# ----------------------------------------------------------------------
#doc TkTable title {
#TkTable
#} index {
# New widgets
#} shortdescr {
# a Table based on TkTable
#} descr {
# subclass of <a href="Widget.html">Widget</a><br>
# creates a Table of entries or text fields. This acts much like a 
# spreadsheet. This Table is based on the tktable widget (and needs it to be available
# as a package). Classy::TkTable mimics some of the behaviour/API of the older Classy::Table
# widget. However: the coordinates are in row major order (as in Tktable) and not in
# column major (as in Classy::Table). 
# The Classy::TkTable widget has much better performance (because of the underlying 
# tktable widget), and has some new options not in Classy::Table (all options of tktable,
# and some extra)
# <p>
# The bindings are more like that of most spreadsheets. It hase 2 "modes": a selection where 
# you basically move the cell, and editing will replace the current value in the current cell,
# and a editing mode where you edit within the cell (started by double-clicking or F2).
# Data for Classy::TkTable can be supplied in several ways.
# <dl>
# <dt>a variable
# <dd>the variable is set by using the -variable option. 
# The type of value is set using the -variabletype option, that can have one of the following types:
#	<dl>
#	<dt>array
#	<dd>the same as the default Tktable variable
#	<dt>list
#	<dd>a list of lists: The first element is the first row in the table, etc.
#	<dt>tlist
#	<dd>a list of lists transposed: The first element is the first column in the table, etc.
#	<dt>table
#	<dd>an Extral table
#	</dl>
# <dt>Command
# <dd>The Table can have an associated command. This is used to get the data 
# to display in the Table and te change data when it
# is edited. The table command will be called with the following 
# parameters:<br>
# <dl>
# <dt>command object x y ?value?
# <dd>the parameter object is the name of the Table.<br>
# When no value is given, the command must return the value to be
# shown in the given cell.
# When the command fails, the error message will be shown in the affected cell.
# <dd>When value is given, it is the new value of the cell.
# If the setcommand fails, the previous value will be restored.
# </dl>
# You can have the command behave like the TkTable -command option by specifying -variabletype tktable
# </dl>
#}
#doc {TkTable options} h2 {
#	TkTable specific options
#}
#doc {TkTable command} h2 {
#	TkTable specific methods
#}

package require Tktable

event add <<tableEditCell>> <Double-Button-1>
event add <<tableEditCellKey>> <F2>
bind Classy::TkTable <1> {%W _clearreturns}
bind Classy::TkTable <<tableEditCell>> {%W edit @%x,%y; break}
bind Classy::TkTable <<tableEditCellKey>> {%W edit; break}
bind Classy::TkTable <Return> {%W grow 0 1; %W move down ; break}
bind Classy::TkTable <<TableReturn>> {%W edit_tablereturn ; break}
bind Classy::TkTable <<Copy>> {%W copy ; break}
bind Classy::TkTable <<Cut>> {%W cut ; break}
bind Classy::TkTable <<Paste>> {%W paste ; break}
bind Classy::TkTable <<Empty>> {%W empty}
bind Classy::TkTable <Delete> {%W delete}
bind Classy::TkTable <Shift-Tab> {%W move left ; break}
if {$tcl_platform(platform) eq "unix"} {
	bind Classy::TkTable <ISO_Left_Tab> {%W move left ; break}
}
bind Classy::TkTable <Tab> {%W move right ; break}
bind Classy::TkTable <<Left>> {%W move left ; break}
bind Classy::TkTable <<Right>> {%W grow 1 0 ; %W move right ; break}
bind Classy::TkTable <<Up>> {%W move up ; break}
bind Classy::TkTable <<Down>> {%W grow 0 1 ; %W move down ; break}
bind Classy::TkTable <<WordLeft>> {%W move wordleft ; break}
bind Classy::TkTable <<WordRight>> {%W move wordright ; break}
bind Classy::TkTable <<ParaUp>> {%W move uppara ; break}
bind Classy::TkTable <<ParaDown>> {%W move downpara ; break}
bind Classy::TkTable <<PageUp>> {%W move pageup ; break}
bind Classy::TkTable <<PageDown>> {%W move pagedown ; break}
bind Classy::TkTable <<PageTop>> {%W move pagetop ; break}
bind Classy::TkTable <<PageBottom>> {%W move pagebottom ; break}
bind Classy::TkTable <<Home>> {%W move linestart ; break}
bind Classy::TkTable <<End>> {%W move lineend ; break}
bind Classy::TkTable <<Top>> {%W move textstart ; break}
bind Classy::TkTable <<Bottom>> {%W move textend ; break}
bind Classy::TkTable <<PageLeft>> {%W move pageleft ; break}
bind Classy::TkTable <<PageRight>> {%W move pageright ; break}
# select
bind Classy::TkTable <<SelectLeft>> {%W move left sel ; break}
bind Classy::TkTable <<SelectRight>> {%W grow 1 0 ; %W move right sel ; break}
bind Classy::TkTable <<SelectUp>> {%W move up sel ; break}
bind Classy::TkTable <<SelectDown>> {%W grow 0 1 ; %W move down sel ; break}
bind Classy::TkTable <<SelectWordLeft>> {%W move wordleft sel ; break}
bind Classy::TkTable <<SelectWordRight>> {%W move wordright sel ; break}
bind Classy::TkTable <<SelectParaUp>> {%W move uppara sel ; break}
bind Classy::TkTable <<SelectParaDown>> {%W move downpara sel ; break}
bind Classy::TkTable <<SelectPageLeft>> {%W move pageleft sel ; break}
bind Classy::TkTable <<SelectPageRight>> {%W move pageright sel ; break}
bind Classy::TkTable <<SelectPageUp>> {%W move pageup sel ; break}
bind Classy::TkTable <<SelectPageDown>> {%W move pagedown sel ; break}
bind Classy::TkTable <<SelectPageTop>> {%W move pagetop sel ; break}
bind Classy::TkTable <<SelectPageBottom>> {%W move pagebottom sel ; break}
bind Classy::TkTable <<SelectHome>> {%W move linestart sel ; break}
bind Classy::TkTable <<SelectEnd>> {%W move lineend sel ; break}
bind Classy::TkTable <<SelectTop>> {%W move textstart sel ; break}
bind Classy::TkTable <<SelectBottom>> {%W move textend sel ; break}
bind Classy::TkTable <<SelectAll>> {%W selection set origin end ; break}

Classy::bindmousewheel Classy::TkTable

bind Classy::TkTable::single <F2> {[winfo parent %W] edit_store ; break}
bind Classy::TkTable::single <KeyPress-Escape> {[winfo parent %W] edit_clear ; break}
bind Classy::TkTable::single <KeyPress-Return> {[winfo parent %W] edit_return}

bind Classy::TkTable::single <Return> {[winfo parent %W] edit_movecell 1 0 ;break}
bind Classy::TkTable::single <<TableReturn>> {%W insert insert \n ; break}
bind Classy::TkTable::single <Shift-Tab> {[winfo parent %W] edit_movecell 0 -1 ;break}
catch {bind Classy::TkTable::single <ISO_Left_Tab> {[winfo parent %W] edit_movecell 0 -1 ;break}}
bind Classy::TkTable::single <Tab> {[winfo parent %W] edit_movecell 0 1 ;break}
bind Classy::TkTable::single <Control-Tab> {%W insert insert \t ;break}

bind Classy::TkTable::single <<Left>> {[winfo parent %W] edit_move left ; break}
bind Classy::TkTable::single <<Right>> {[winfo parent %W] edit_move right ; break}
bind Classy::TkTable::single <<Up>> {[winfo parent %W] edit_move up ; break}
bind Classy::TkTable::single <<Down>> {[winfo parent %W] edit_move down ; break}
bind Classy::TkTable::single <<WordLeft>> {[winfo parent %W] edit_move wordleft ; break}
bind Classy::TkTable::single <<WordRight>> {[winfo parent %W] edit_move wordright ; break}
bind Classy::TkTable::single <<ParaUp>> {[winfo parent %W] edit_move uppara ; break}
bind Classy::TkTable::single <<ParaDown>> {[winfo parent %W] edit_move downpara ; break}
bind Classy::TkTable::single <<PageUp>> {[winfo parent %W] edit_move pageup ; break}
bind Classy::TkTable::single <<PageDown>> {[winfo parent %W] edit_move pagedown ; break}
bind Classy::TkTable::single <<PageTop>> {[winfo parent %W] edit_move pagetop ; break}
bind Classy::TkTable::single <<PageBottom>> {[winfo parent %W] edit_move pagebottom ; break}
bind Classy::TkTable::single <<Home>> {[winfo parent %W] edit_move linestart ; break}
bind Classy::TkTable::single <<End>> {[winfo parent %W] edit_move lineend ; break}
bind Classy::TkTable::single <<Top>> {[winfo parent %W] edit_move textstart ; break}
bind Classy::TkTable::single <<Bottom>> {[winfo parent %W] edit_move textend ; break}
# select
bind Classy::TkTable::single <<SelectLeft>> {[winfo parent %W] edit_move left sel ; break}
bind Classy::TkTable::single <<SelectRight>> {[winfo parent %W] edit_move right sel ; break}
bind Classy::TkTable::single <<SelectUp>> {[winfo parent %W] edit_move up sel ; break}
bind Classy::TkTable::single <<SelectDown>> {[winfo parent %W] edit_move down sel ; break}
bind Classy::TkTable::single <<SelectWordLeft>> {[winfo parent %W] edit_move wordleft sel ; break}
bind Classy::TkTable::single <<SelectWordRight>> {[winfo parent %W] edit_move wordright sel ; break}
bind Classy::TkTable::single <<SelectParaUp>> {[winfo parent %W] edit_move uppara sel ; break}
bind Classy::TkTable::single <<SelectParaDown>> {[winfo parent %W] edit_move downpara sel ; break}
bind Classy::TkTable::single <<SelectPageUp>> {[winfo parent %W] edit_move pageup sel ; break}
bind Classy::TkTable::single <<SelectPageDown>> {[winfo parent %W] edit_move pagedown sel ; break}
bind Classy::TkTable::single <<SelectPageTop>> {[winfo parent %W] edit_move pagetop sel ; break}
bind Classy::TkTable::single <<SelectPageBottom>> {[winfo parent %W] edit_move pagebottom sel ; break}
bind Classy::TkTable::single <<SelectHome>> {[winfo parent %W] edit_move linestart sel ; break}
bind Classy::TkTable::single <<SelectEnd>> {[winfo parent %W] edit_move lineend sel ; break}
bind Classy::TkTable::single <<SelectTop>> {[winfo parent %W] edit_move textstart sel ; break}
bind Classy::TkTable::single <<SelectBottom>> {[winfo parent %W] edit_move textend sel ; break}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::TkTable

Classy::TkTable method init {args} {
	# REM Create object
	# -----------------
	private $object table
	set table [super init table]
	$table configure -rows 10 -cols 2 -exportselection 0 -wrap 0 -multiline 1 \
		-titlerows 1 -borderwidth 1 -justify left -anchor w -ellipsis ... \
		-selectmode extended -resizeborders col -selecttype cell -borderwidth 1 \
		-width 1 -height 5 -bordercursor sb_h_double_arrow \
		-exportselection 1 -rowseparator \n -colseparator \t \
		-autoclear 1 -invertselected 1
	$table tag configure active -fg [$table cget -bg] -bg [$table cget -fg]
	$table tag configure uneven -bg [$table cget -bg]
	$table tag configure even -bg [Classy::optionget $object lightBackground LightBackground]
	$table configure -browsecommand [list $object edit_store]
	$table activate 0,0
	Classy::Text $object.edit -bg white -width 1 -height 1 -font [$table cget -font]
	bindtags $object.edit [list $object.edit Classy::TkTable::single Classy::Text . all]
	eval {$object configure} $args
	Classy::todo $object _setupbackend
	$table tag raise sel
	$table tag raise active
	return $object
}

Classy::TkTable method destroy {} {
	private $object table options
	switch $value {
		list - tlist - table {
			trace remove variable $options(-variable) write [list Classy::todo $object redraw]
		}
	}
}

Classy::TkTable chainallmethods {$object} table

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

proc Classy::TkTable_list {object var r c i s} {
	set result ""
	if {$r < 0} {
		if {$c < 0} {return ""} else {return $c}
	}
	if {$c < 0} {return $r}
	catch {
		upvar #0 $var list
		if {$i} {
			private $object options
			if {$options(-changedcommand) ne ""} {
				set s [eval $options(-changedcommand) {$object $r $c $s}]
			}
			if {[catch {lset list $r $c $s}]} {
				if {$r >= [llength $list]} {
					eval lappend list [list_fill [expr {$r - [llength $list]}] {}]
					lappend list [list_fill [expr {$c+1}] {}]
				} elseif {$c >= [llength [lindex $list $r]]} {
					set temp [lindex $list $r]
					eval lappend temp [list_fill [expr {$c - [llength $temp]+1}] {}]
					lset list $r $temp
				}
			}
			lset list $r $c $s
		} else {
			set result [lindex $list $r $c]
		}
	}
	return $result
}

proc Classy::TkTable_table {object var r c i s} {
	set result ""
	if {$r < 0} {
		if {$c < 0} {return ""} else {return $c}
	}
	if {$c < 0} {return $r}
	catch {
		upvar #0 $var ltable
		if {$i} {
			private $object options
			if {$options(-changedcommand) ne ""} {
				set s [eval $options(-changedcommand) {$object $r $c $s}]
			}
			if {[catch {table_set ltable $r $c $s}]} {
				set rlen [table_size $ltable]
				set fields [table_fields $ltable]
				if {$r >= $rlen} {
					set len [expr {$r - $rlen+1}]
					set field [lindex $fields 0]
					for {set i 0} {$i < $len} {incr i} {
						table_append ltable $field {}
					}
				}
				set clen [llength $fields]
				if {$c >= $clen} {
					set len [expr {$c - $clen+1}]
					set num 1
					for {set i 0} {$i < $len} {incr i} {
						while {[inlist $fields f$num]} {incr num}
						table_addfield ltable f$num
						incr num
					}
				}
				table_set ltable $r $c $s
			}
		} else {
			set result [table_get $ltable $r $c]
		}
	}
	return $result
}

Classy::TkTable addoption -lightbackground {lightBackground lightBackground #dfdfdf} {
	private $object table
	$table tag configure even -bg $value
}

Classy::TkTable addoption -titlerows {TitleRows titleRows 0} {
	private $object table options
	set options(-titlerows) $value
	if {$options(-labels) ne ""} {
		$object configure -labels $options(-labels)
	} else {
		$table configure -titlerows $value
	}
}

Classy::TkTable addoption -roworigin {rowOrigin Origin 0} {
	private $object table options
	$table configure -roworigin $value
	set options(-roworigin) $value
	if {$options(-labels) ne ""} {
		$object configure -labels $options(-labels)
	} else {
		$table configure -roworigin $value
	}
}

#doc {TkTable options -autosize} option {-autosize autoSize AutoSize} descr {
# "pathName autosize" will adapt column and row sizes automatically to the data in the table.
# This command is automatically run when defining e.g. a new variable or type. 
# "pathName autosizecol" and "pathName autosizerow" can be used to automatically
# adapt the size of a givven column or row<br>
# The -autosize option consists of a list of numbers giving the minimum 
# and maximum width and heights of the columns and rows respectively.
# <pre>
# colminsize colmaxsize rowminsize rowmaxsize<br>
# </pre>
# if some numbers are not given (the list contains less than 4 items), 
# defaults (1 60 1 4) are used. -1 can be used for unbounded
#}
Classy::TkTable addoption -autosize {autoSize AutoSize {}} {
	Classy::todo $object autosize
}

Classy::TkTable method grow {x y} {
	private $object table options grow
	if {[catch {$table index active row} r]} return
	if {($x > 0) && ([get grow(x) 0])} {
		set c [$table index active col]
		set ccols [$table index end col]
		if {[expr {$c+$x}] > $ccols} {
			$object configure -cols [expr {[$object cget -cols]+1}]
		}
	}
	if {($y > 0) && ([get grow(y) 0])} {
		set crows [$table index end row]
		if {[expr {$r+$y}] > $crows} {
			$object configure -rows [expr {[$object cget -rows]+1}]
		}
	}
}

Classy::TkTable addoption -grow {grow Grow 0} {
	private $object grow
	switch $value {
		none {
			set grow(x) 0
			set grow(y) 0
		}
		both {
			set grow(x) 1
			set grow(y) 1
		}
		column {
			set grow(x) 1
			set grow(y) 0
		}
		row {
			set grow(x) 0
			set grow(y) 1
		}
		default {
			error "-grow must be one of: none, row, column, both"
		}
	}
}

Classy::TkTable addoption -variable {Variable variable {}} {
	private $object table options
	switch $options(-variabletype) {
		list - tlist - table {
			trace remove variable ::$options(-variable) write [list Classy::todo $object redraw]
		}
	}
	Classy::todo $object _setupbackend
	Classy::todo $object fitdata
}

Classy::TkTable addoption -variabletype {VariableType variableType list} {
	private $object table options
	if {![inlist {list tlist array table tktable {}} $value]} {error "unknown -variabletype $value: must be one of list, array, table, tktable or {}"}
	switch $options(-variabletype) {
		list - tlist - table {
			trace remove variable ::$options(-variable) write [list Classy::todo $object redraw]
		}
	}
	Classy::todo $object _setupbackend
	Classy::todo $object fitdata
}

#doc {TkTable options -command} option {-command Command Command} descr {
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
Classy::TkTable addoption -command {Command Command {}} {
	private $object table options
	Classy::todo $object _setupbackend
}

Classy::TkTable method _setupbackend {} {
	private $object table options
	set vartype $options(-variabletype)
	set var $options(-variable)
	set command $options(-command)
	if {$command eq ""} {
		set usecommand 0
	} else {
		set usecommand 1
	}
	if {($var eq "") && ($command ne "")} {
		if {$vartype ne "tktable"} {
			set command [list if {%i} [list [string trim $command] [list $object] %r %c %s] else [list [string trim $command] [list $object] %r %c]]
		}
	} else {
		switch $vartype {
			array {
				set usecommand 0
				set command ""
			}
			list - tlist {
				trace add variable ::$var write [list Classy::todo $object redraw]
				if {![info exists ::$var]} {set ::$var {}}
				if {$vartype eq "list"} {
					set command [list Classy::TkTable_list $object ::$var %r %c %i %s]
				} else {
					set command [list Classy::TkTable_list $object ::$var %c %r %i %s]
				}
				set usecommand 1
			}
			table {
				upvar #0 $var ltable
				trace add variable ::$var write [list Classy::todo $object redraw]
				if {![info exists ltable]} {
					set ltable [table_create $options(-labels) {}]
				} else {
					$object configure -labels [table_fields [get ::$var]]
				}
				set command [list Classy::TkTable_table $object ::$var %r %c %i %s]
				set usecommand 1
				Classy::todo $object redraw
			}
			default {
				error "variabletype must be one of: array, list, tlist, table"
			}
		}
	}
	if {$usecommand} {set var {}}
	$table configure -usecommand $usecommand -command $command -variable $var
	Classy::todo $object autosize
}

Classy::TkTable addoption -browsecommand {browseCommand BrowseCommand {}} {
	private $object table
	$table configure -browsecommand "[list $object edit_store]; $value"
}

Classy::TkTable synonym_option -browsecmd -browsecommand

Classy::TkTable addoption -changedcommand {changedcommand Changedcommand {}} {
}

#doc {TkTable options -cols} option {-cols cols Cols} descr {
# gives the number of columns in the Table
#}
#doc {TkTable options -rows} option {-rows rows rows} descr {
# gives the number of rows in the Table
#}
Classy::TkTable addoption -rows {rows Rows 5} {
	private $object table options
	if {![isint $value]} {
		set value 5
		set options(-rows) 5
	} else {
		set options(-rows) $value
	}
	if {$options(-labels) ne ""} {
		$object configure -labels $options(-labels)
	} else {
		$table configure -rows $value
	}
}

#doc {TkTable options -colsize} option {-colsize colsize colsize} descr {
# gives the default column size
#}
Classy::TkTable addoption -colsize {colSize ColSize {}} {
	private $object table
	$table configure -colwidth $value
}

#doc {TkTable options -rowsize} option {-rowsize rowsize rowsize} descr {
# gives the default row size
#}
Classy::TkTable addoption -rowsize {rowSize RowSize {}} {
	private $object table
	$table configure -rowheight $value
}

#doc {TkTable options -xresize} option {-xresize xResize Resize} descr {
#  allow columns to be resized
#}
Classy::TkTable addoption -xresize {xResize Resize {}} {
	private $object table options
	$table configure -resizeborders [$object _combineoptset $value $options(-yresize)]
}

#doc {TkTable options -yresize} option {-yresize yResize Resize} descr {
# allow rows to be resized
#}
Classy::TkTable addoption -yresize {yResize Resize {}} {
	private $object table options
	$table configure -resizeborders [$object _combineoptset $options(-xresize) $value]
}

Classy::TkTable addoption -xgridwidth {xGridWidth GridWidth 1} {}
Classy::TkTable addoption -ygridwidth {yGridWidth GridWidth 1} {}
Classy::TkTable addoption -xgridcolor {xGridColor Foreground {}} {}
Classy::TkTable addoption -ygridcolor {yGridColor Foreground {}} {}

Classy::TkTable method labelclick {w x y} {
	incr x [winfo x $w]
	incr y [winfo y $w]
	upvar #0 ::tk::table::Priv Priv
	set w $object
	if {$Priv(borderB1) == 1} {
		set Priv(borderInfo) [$w border mark $x $y]
		# account for what resizeborders are set [Bug 876320] (ferenc)
		set rbd [$w cget -resizeborders]
		if {$rbd == "none" || ![llength $Priv(borderInfo)]
		|| ($rbd == "col" && [lindex $Priv(borderInfo) 1] == "")
		|| ($rbd == "row" && [lindex $Priv(borderInfo) 0] == "")} {
			set Priv(borderInfo) ""
		}
	} else {
		set Priv(borderInfo) ""
	}
	if {$Priv(borderInfo) ne ""} {
		return -code break
	}
}

Classy::TkTable method labelB1motion {w x y} {
	incr x [winfo x $w]
	incr y [winfo y $w]
	::tk::table::B1Motion $object $x $y
}

Classy::TkTable method labelmotion {w x y} {
	incr x [winfo x $w]
	incr y [winfo y $w]
	upvar #0 ::tk::table::Priv Priv
	if {$Priv(borderB1) == 1} {
		set borderInfo [$object border mark $x $y]
		# account for what resizeborders are set [Bug 876320] (ferenc)
		set rbd [$object cget -resizeborders]
		if {$rbd == "none" || ![llength $borderInfo]
		|| ($rbd == "col" && [lindex $borderInfo 1] == "")
		|| ($rbd == "row" && [lindex $borderInfo 0] == "")} {
			set borderInfo ""
		}
		if {[winfo parent $w] eq $object} {
			if {$borderInfo ne ""} {
				$w configure -cursor sb_h_double_arrow
			} else {
				$w configure -cursor left_ptr
			}
		}
	}
}

bind Classy::TkTable::label <1> {[winfo parent %W] labelclick %W %x %y}
bind Classy::TkTable::label <B1-Motion> {[winfo parent %W] labelB1motion %W %x %y; break}
bind Classy::TkTable::label <Motion> {[winfo parent %W] labelmotion %W %x %y}

#doc {TkTable options -labels} option {-labels labels Labels} descr {
# Add a title line with the given labels
#}
Classy::TkTable addoption -labels {labels Labels {}} {
	private $object table options
	set num 0
	while 1 {
		if {![winfo exists $object.label$num]} break
		destroy $object.label$num
		incr num
	}
	if {![isint $options(-rows)]} {set rows 5} else {set rows $options(-rows)}
	if {[llength $value]} {
		if {$options(-titlerows) == 0} {
			set row [expr {$options(-roworigin)-1}]
			$table configure -cols [llength $value] -rows [expr {$rows+1}] \
				-titlerows 1 -roworigin $row -padx 0 -pady 0
		} else {
			$table configure -cols [llength $value] -rows $rows \
				-titlerows $options(-titlerows) -roworigin $options(-roworigin) -padx 0 -pady 0
			set row $options(-roworigin)
		}
		$table tag configure title -bg [Classy::realcolor darkBackground] -font [Classy::realfont Font]
		set num 0
		foreach label $value {
			button $object.label$num -text $label -highlightthickness 0 \
				-bg [Classy::realcolor darkBackground] -font [Classy::realfont Font] \
				-bd 1 -cursor left_ptr \
				-command "$options(-labelcommand) [list $object] $num"
			bindtags $object.label$num [list $object.label$num Classy::TkTable::label Button . all]
			$table window configure $row,$num -window $object.label$num -sticky nwse -padx 0
			incr num
		}
	} else {
		$table configure -titlerows $options(-titlerows) -roworigin $options(-roworigin) -rows $rows
		set num 0
		while 1 {
			if {![winfo exists $object.label$num]} break
			destroy $object.label$num
			incr num
		}
	}
}

#doc {TkTable options -labelcommand} {-labelcommand labelCommand LabelCommand} descr {
# command to be executed when a label (title row) is clicked.
# This command will usually sort the table according to the column selected.
# For several variabletypes the command "$object sort" will work correctly.
#}
Classy::TkTable addoption -labelcommand {labelCommand LabelCommand {}} {
	private $object table options
	set num 0
	foreach label $options(-labels) {
		if {![winfo exists $object.label$num]} break
		$object.label$num configure -command "$value [list $object] $num"
		incr num
	}
}

#doc {TkTable -labelsort} {-labelsort labelSort LabelSort} descr {
# display an arrow indicating the current sort order in the labels (title row)
# by giving a value of the form "label +" or "label -"
# the + or - gives the direction of the arrow, "label" is displayed as text.
# This option only works if -labels is defined.
#}
Classy::TkTable addoption -labelsort {labelSort LabelSort {}} {
	private $object table options
	set label ""
	foreach {label dir} [get options(-labelsort) ""] break
	set num [lsearch -exact $options(-labels) $label]
	if {$num != -1} {
		$object.label$num configure -image {} -compound none
	}
	foreach {label dir} $value break
	set num [lsearch -exact $options(-labels) $label]
	if {$num == -1} {
		error "label \"$label\" not found"
	}
	if {$dir eq "+"} {
		$object.label$num configure -image [Classy::geticon down] -compound left
	} elseif {$dir eq "-"} {
		$object.label$num configure -image [Classy::geticon up] -compound left
	} else {
		error "value must be of the form: \"label +\" or  \"label -\""
	}
}

# This command can be used in the -rowtag option to display rows in alternating colors
proc Classy::TkTable_rowtag_stripes {row} {
	if {$row == 0} {
		return even
	} elseif {[expr {$row%2}]} {
		return uneven
	} else {
		return even
	}
}

Classy::TkTable method _clearreturns {} {
	private $object returns
	unset -nocomplain returns
}

Classy::TkTable method move {cell args} {
	private $object table
	$object _clearreturns
	upvar ::tk::table::Priv Priv
	foreach {sr sc} [split [$table index active] ,] break
	switch $cell {
		left {
			set cell $sr,[expr {$sc-1}]
		}
		right {
			set cell $sr,[expr {$sc+1}]
		}
		up {
			set cell [expr {$sr-1}],$sc
		}
		down {
			set cell [expr {$sr+1}],$sc
		}
		linestart {
			set cell $sr,[$table index origin col]
		}
		lineend {
			set cell $sr,[$table index end col]
		}
		wordleft {
			set colorigin [$table index origin col]
			if {$sc > $colorigin} {
				set startval [$table get $sr,$sc]
				incr sc -1
				set nextval [$table get $sr,$sc]
				if {$startval eq ""} {
					set startedblank 1
				} elseif {$nextval eq ""} {
					set startedblank 1
				} else {
					set startedblank 0
				}
				while {$sc >= $colorigin} {
					set nval [$table get $sr,$sc]
					if {[expr {$nval eq ""}] != $startedblank} break
					incr sc -1
				}
				if {!$startedblank && ($nval eq "")} {incr sc 1}
			}
			set cell $sr,$sc
		}
		wordright {
			set colend [$table index end col]
			if {$sc < $colend} {
				set startval [$table get $sr,$sc]
				incr sc
				set nextval [$table get $sr,$sc]
				if {$startval eq ""} {
					set startedblank 1
				} elseif {$nextval eq ""} {
					set startedblank 1
				} else {
					set startedblank 0
				}
				while {$sc <= $colend} {
					set nval [$table get $sr,$sc]
					if {[expr {$nval eq ""}] != $startedblank} break
					incr sc
				}
				if {!$startedblank && ($nval eq "")} {incr sc -1}
			}
			set cell $sr,$sc
		}
		uppara {
			set roworigin [$table index origin row]
			if {$sr > $roworigin} {
				set startval [$table get $sr,$sc]
				incr sr -1
				set nextval [$table get $sr,$sc]
				if {$startval eq ""} {
					set startedblank 1
				} elseif {$nextval eq ""} {
					set startedblank 1
				} else {
					set startedblank 0
				}
				while {$sr >= $roworigin} {
					set nval [$table get $sr,$sc]
					if {[expr {$nval eq ""}] != $startedblank} break
					incr sr -1
				}
				if {!$startedblank && ($nval eq "")} {incr sr 1}
			}
			set cell $sr,$sc
		}
		downpara {
			set rowend [$table index end row]
			if {$sr < $rowend} {
				set startval [$table get $sr,$sc]
				incr sr
				set nextval [$table get $sr,$sc]
				if {$startval eq ""} {
					set startedblank 1
				} elseif {$nextval eq ""} {
					set startedblank 1
				} else {
					set startedblank 0
				}
				while {$sr <= $rowend} {
					set nval [$table get $sr,$sc]
					if {[expr {$nval eq ""}] != $startedblank} break
					incr sr
				}
				if {!$startedblank && ($nval eq "")} {incr sr -1}
			}
			set cell $sr,$sc
		}
		pageleft {
			set cell $sr,[expr {$sc-([$table index bottomright col]-[$table index topleft col])}]
		}
		pageright {
			set cell $sr,[expr {$sc+([$table index bottomright col]-[$table index topleft col])}]
		}
		pageup {
			set cell [expr {$sr-([$table index bottomright row]-[$table index topleft row])}],$sc
		}
		pagedown {
			set cell [expr {$sr+([$table index bottomright row]-[$table index topleft row])}],$sc
		}
		pagetop {
			set cell [$table index origin row],$sc
		}
		pagebottom {
			set cell [$table index end row],$sc
		}
		textstart {
			set cell [$table index origin]
		}
		textend {
			set cell [$table index end]
		}
		default {
		}
	}
	if {[inlist $args sel]} {
		::tk::table::DataExtend $object $cell
		return
	}
	$table activate $cell
	$object see $cell
	switch [$table cget -selectmode] {
		browse {
			$table selection clear all
			$table selection set active
		}
		extended {
			variable Priv
			$table selection clear all
			$table selection set active
			$table selection anchor active
			set Priv(tablePrev) [$table index active]
		}
	}
}

Classy::TkTable method currenty {} {
	private $object table
	$table index active row
}

Classy::TkTable method currentx {} {
	private $object table
	$table index active col
}

# Move the display so that the cell at the given index is visible.
Classy::TkTable method see {index} {
	private $object table
	foreach {y x} [split [$table index $index] ,] break
	foreach {y1 x1} [split [$table index topleft] ,] break
	foreach {y2 x2} [split [$table index bottomright] ,] break
	if {$x < $x1} {
		$table xview scroll [expr {$x-$x1-1}] units
	} elseif {$x >= $x2} {
		$table xview scroll [expr {$x-$x2+1}] units
	}
	if {$y < $y1} {
		$table yview scroll [expr {$y-$y1-1}] units
	} elseif {$y >= $y2} {
		$table yview scroll [expr {$y-$y2+1}] units
	}
}

Classy::TkTable method current {args} {
	private $object table
	set result [$table index active]
	catch {
		lappend result [$table.edit index insert]
	}
	return $result
}

Classy::TkTable method currentsel {args} {
	private $object table edited
	if {[info exists edited]} {
		return [$object.edit get sel.first sel.last]
	} else {
		return [$table get active]
	}
}

Classy::TkTable method tag {option args} {
	private $object table
	switch $option {
		delete {
			foreach tag $args {
				catch {$table tag delete $tag}
			}
			return
		}
		clear {
			foreach tag [$table tag names] {
				catch {$table tag delete $tag}
			}
			return
		}
	}
	set result [eval {$table tag $option} $args]
	set tag [lindex $args 0]
	if {[llength $args] && [regexp {^(-?[0-9]+|),(-?[0-9]+|)$} $tag temp r c]} {
		if {[isint $r]} {
			if {[isint $c]} {
				$table tag celltag $tag $r,$c
				$table tag raise $tag
				$table tag raise sel
				$table tag raise active
			} else {
				$table tag rowtag $tag $r
			}
		} elseif {[isint $c]} {
				$table tag coltag $tag $c
		}
	}
	return $result
}

Classy::TkTable method _combineoptset {xopt yopt} {
	if {[true $xopt]} {
		if {[true $yopt]} {
			return both
		} else {
			return col
		}
	} elseif {[true $yopt]} {
		return row
	} else {
		return none
	}
}

Classy::TkTable method _combineoptget {dir opt} {
	if {$dir eq "x"} {
		if {[inlist {both col} $opt]} {
			return 1
		} else {
			return 0
		}
	} else {
		if {[inlist {both row} $opt]} {
			return 1
		} else {
			return 0
		}
	}
}

Classy::TkTable method rowconfigure {row args} {
	private $class actions
	private $object table autosize
	set len [llength $args]
	if {$len == 0} {
		set result [$object tag configure ,$row]
		lappend result -size [$table height $row] -gridwidth [$object tag configure ,$row -bd] -resize {} -gridcolor {}
		return $result
	} elseif {$len == 1} {
		set option [lindex $args 0]
		switch -- $option {
			-autosize {
				return [get autosize(r,$row) {}]
			}
			-size {
				return [$table height $row] 
			}
			-resize {
				return {}
			}
			-gridwidth {
				return [$object tag configure ,$row -bd]
			}
			-gridcolor {
				return {}
			}
			default {
				return [$object tag configure ,$row $option]
			}
		}
	} else {
		set todo ""
		foreach {option value} $args {
			switch -- $option {
				-autosize {
					if {"$value" == ""} {
						$table height $row default
						unset -nocomplain autosize(r,$row)
					} else {
						$table height $row [lindex $value 0]
						set autosize(r,$row) $value
					}
					Classy::todo $object autosize
				}
				-size {
					if {"$value" == ""} {
						$table height $row default
						unset -nocomplain autosize(r,$row)
					} else {
						if {$value < 1} {set value 1}
						$table height $row $value
					}
				}
				-resize {
				}
				-gridwidth {
					lappend todo -borderwidth $value
				}
				-gridcolor {
				}
				default {
					lappend todo $option $value
				}
			}
			eval $object tag configure $row, $todo
		}
	}
}

Classy::TkTable method columnconfigure {col args} {
	private $class actions
	private $object table autosize
	set len [llength $args]
	if {$len == 0} {
		set result [$object tag configure $col,]
		lappend result -size [$table height $col] -gridwidth [$object tag configure $col, -bd] -resize {} -gridcolor {}
		return $result
	} elseif {$len == 1} {
		set option [lindex $args 0]
		switch -- $option {
			-autosize {
				return [get autosize(c,$col) {}]
			}
			-size {
				if {[info exists autosize(c,$col)]} {return 0}
				return [$table width $col] 
			}
			-resize {
				return {}
			}
			-gridwidth {
				return [$object tag configure $col, -bd]
			}
			-gridcolor {
				return {}
			}
			default {
				return [$object tag configure $col, $option]
			}
		}
	} else {
		set todo ""
		foreach {option value} $args {
			switch -- $option {
				-autosize {
					if {"$value" == ""} {
						$table width $col default
						unset -nocomplain autosize(c,$col)
					} else {
						$table width $col [lindex $value 0]
						set autosize(c,$col) $value
					}
					Classy::todo $object autosize
				}
				-size {
					if {"$value" == ""} {
						$table width $col default
						unset -nocomplain autosize(c,$col)
					} else {
						$table width $col $value
					}
				}
				-resize {
				}
				-gridwidth {
					lappend todo -borderwidth $value
				}
				-gridcolor {
				}
				default {
					lappend todo $option $value
				}
			}
			eval $object tag configure ,$col $todo
		}
	}
}

Classy::TkTable method selection {option args} {
	private $object table
	switch $option {
		clear {
			if {$args eq ""} {set args  all}
			return [eval {$table selection clear} $args]
		}
		anchor - includes - present - set {
			return [eval {$table selection $option} $args]
		}
	}
	set curselection [$table curselection]
	if {![llength $curselection]} {
		set curselection [$table index active]
	}
	switch $option {
		current {
			return $curselection
		}
		rows {
			regsub -all {,[0-9]+} $curselection {} temp
			return [lsort -integer -unique $temp]
		}
		cols {
			regsub -all {[0-9]+,} $curselection {} temp
			return [lsort -integer -unique $temp]
		}
		get {
			set result {}
			regsub -all , $curselection { } curselection
			set ys [list_unmerge $curselection 1 xs]
			set minx [lmath_min $xs]
			set maxx [lmath_max $xs]
			set xsize [expr {$maxx-$minx+1}]
			set empty [list_fill $xsize {}]
			set cury [lindex $ys 0]
			set temp $empty
			foreach {y x} $curselection {
				set index $y,$x
				set x [expr {$x-$minx}]
				if {$y == $cury} {
					lset temp $x [$table get $index]
				} else {
					lappend result $temp
					set temp $empty
					lset temp $x [$table get $index]
					set cury $y
				}
			}
			lappend result $temp
		}
		default {
			error "bad selection option \"$option\": must be current, rows, cols, anchor, clear, includes, present, set or get"
		}
	}
}

Classy::TkTable method edit_clear {} {
	private $object table edited
	if {[info exists edited]} {
		$table window configure $edited -window {}
		unset edited
	}
	focus $object
}

Classy::TkTable method edit_store {{y 0} {x 0}} {
	private $object table edited options
	if {![info exists edited]} return
	set index $edited
	set value [$object.edit get 1.0 "end - 1 char"]
	$object edit_clear
	$table set $index $value
}

Classy::TkTable method edit_move {index args} {
	private $object table options
	if {[inlist $args sel]} {set sel 1} else {set sel 0}
	set pos [$object.edit index insert]
	if {!$sel} {
		$object.edit move $index
	} else {
		$object.edit select $index
	}
	set newpos [$object.edit index insert]
	if {$newpos ne $pos} {
		return -code break
	}
	foreach {sr sc} [split [$table index active] ,] break
	set textindex 1.0
	switch $index {
		left - wordleft {
			set cell $sr,[expr {$sc-1}]
			set textindex end
		}
		right - wordright {
			set cell $sr,[expr {$sc+1}]
			set textindex 1.0
		}
		up - uppara - pageup - pagetop {
			set cell [expr {$sr-1}],$sc
			set textindex [$object.edit index insert]
		}
		down - downpara - pagedown - pagebottom {
			set cell [expr {$sr+1}],$sc
			set textindex [$object.edit index insert]
		}
		linestart {
			set cell $sr,[expr {$sc-1}]
			set textindex [lindex [split [$object.edit index insert] .] 0].0
		}
		lineend {
			set cell $sr,[expr {$sc+1}]
			set textindex [lindex [split [$object.edit index insert] .] 0].end
		}
		textstart {
			set cell [expr {$sr-1}],$sc
			set textindex 1.0
		}
		textend {
			set cell [expr {$sr+1}],$sc
			set textindex end
		}
		default {
			set cell [$table index $cell]
		}
	}
	$object edit $cell $textindex
	return -code break
}


Classy::TkTable method edit_movecell {{diry 0} {dirx 0} {sel 0}} {
	private $object table options
	if {[catch {$table index active row} r]} return
	set c [$table index active col]
	if {[inlist {row both} $options(-grow)]} {$object grow 0 1}
	set start [$object.edit index insert]
	$object edit [incr r $diry],[incr c $dirx] $start
	return -code break
}

Classy::TkTable method cursor_move {dir} {
	private $object table options
	if {!$options(-tabmove)} {
		if {[inlist {row both} $options(-grow)]} {$object grow 0 $dir}
	} else {
		set pos [$table icursor]
		incr pos $dir
		set len [string length [$table get active]]
		if {$pos > $len} {
			::tk::table::MoveCell $table 0 $dir
			$table icursor 0
			return -code break
		} elseif {$pos >= 0} {
			$table icursor $pos
			return -code break
		}
	}
}

Classy::TkTable method edit_tablereturn {} {
	private $object table edited returns
	::tk::table::Insert $object "\n"
	set row [$table index active row]
	if {![info exists returns]} {set returns 0}
	incr returns
	$object autosizerow $row
}

Classy::TkTable method edit {args} {
	private $object table edited
	set start end
	set end end
	if {![llength $args]} {
		set index active
	} else {
		foreach {index start end} $args break
	}
	set index [$table index $index]
	if {[info exists edited]} {
		$object edit_store
	}
	$table activate {}
	$table activate $index
	Classy::update Classy::TkTable-edit
	if {$start eq ""} {set start 1.0+[$table icursor]char}
	if {$end eq ""} {set end $start}
	set value [$table get $index]
	$object.edit delete 1.0 end
	$object.edit insert end $value
	$object.edit tag add sel $start $end
	$object.edit mark set insert $end
	$object.edit see insert
	Classy::todo $table window configure $index -window $object.edit -sticky news
	$object see $index
	set edited $index
	focus $object.edit
}

Classy::TkTable method edit_update {{insert {}}} {
	private $object table edited
	if {![info exists edited]} return
	set value [$table get $edited]
	if {$insert eq ""} {
		set insert [$object.edit index insert]
	}
	if {$value ne [$object.edit get]} {
		set sel [$object.edit tag ranges sel]
		$object.edit delete 1.0 end
		$object.edit insert end $value
		if {[llength $sel]} {
			eval {$object.edit tag add sel} $sel
		}
	}
	$object.edit mark set insert $insert
	$object.edit see insert
}

Classy::TkTable method activate {index} {
	private $object table edited
	set index [$table index $index]
	if {[info exists edited] && ($index ne $edited)} {
		$object edit_store
	}
	$table activate $index
}

Classy::TkTable method redraw {args} {
	private $object table options
	switch $options(-variabletype) {
		table {
			upvar #0 $options(-variable) ltable
			set fields [table_fields $ltable]
			if {$options(-labels) ne $fields} {
				$object configure -labels $fields
				$object configure -cols [llength $fields]
			}
		}
		list {
			upvar #0 $options(-variable) ltable
#			$object configure -rows [llength $ltable]
#			foreach line $ltable {
#				if {[string index [lindex $line 0] 0] ne "\#"} break
#			}
#			$object configure -cols [llength $line]
		}
	}
	$table configure -padx [$table cget -padx]
	$object edit_update
}

Classy::TkTable method autosizerow {row} {
	private $object table options edited returns
	set min 1; set max 4
	if {[info exists autosize(r,$row)]} {
		foreach {min max} $autosize(r,$row) break
	} elseif {[get options(-autosize) ""] ne ""} {
		foreach {min max} [lrange $options(-autosize) 2 3] break
	} else {
		return
	}
	incr min -1
	set nCols [$table cget -cols] 
	set font [$table cget -font] 
	if {$nCols > 1000} {set nCols 1000}
	set colori [$table cget -colorigin]
	set maxheight $min
	if {[isint $max]} {
		set maxmaxheight [expr {$max-1}]
	} else {
		set maxmaxheight -1
	}
	set list [$table get $row,$colori $row,$nCols]
	if {[info exists returns] && ($returns > $min)} {
		list_pop list [expr {[$table index active col]-$colori}]
		set maxheight $returns
	} else {
		set maxheight $min
	}
	foreach val $list {
		set height [regexp -all \n $val]
		if {$height > $maxheight} { 
			set maxheight $height 
		}
		if {($maxmaxheight >= 0) && ($maxheight > $maxmaxheight)} {
			set maxheight $maxmaxheight
			break
		}
	}
	incr maxheight
	$table height $row $maxheight
}

Classy::TkTable method autosizecol {col} {
	private $object table autosize options
	set min 2; set max 80
	if {[info exists autosize(c,$col)]} {
		foreach {min max} $autosize(c,$col) break
	} elseif {[get options(-autosize) ""] ne ""} {
		foreach {min max} $options(-autosize) break
	} else {
		return
	}
	set nRows [$table cget -rows] 
	set font [$table cget -font] 
	if {$nRows > 1000} {set nRows 1000}
	set rowori [$table cget -roworigin]
	set maxwidth $min
	set maxval [string_fill a $min]
	if {[isint $max]} {
		set maxmaxwidth $max
	} else {
		set maxmaxwidth -1
	}
	set list [$table get $rowori,$col $nRows,$col]
	list_unshift list [lindex [get options(-labels) ""] $col]1
	foreach val $list {
		set width [string length $val] 
		if {$width > $maxwidth} { 
			set maxwidth $width 
			set maxval $val
		}
		if {($maxmaxwidth >= 0) && ($maxwidth > $maxmaxwidth)} {
			set maxval [string range $maxval 0 $maxmaxwidth]
			break
		}
	}
	set maxpwidth [font measure [$table cget -font] "$maxval  "]
	# if {$maxpwidth < 40} {set maxpwidth 40}
	$table width $col -$maxpwidth
}

Classy::TkTable method autosize {} {
	private $object table autosize options
	set nCols [$table cget -cols] 
	if {$options(-variabletype) eq "list" && ![info exists autosize]} {
		foreach {min max rmin rmax} {2 60 1 4} break
		foreach {min max rmin rmax} $options(-autosize) break
		if {$min eq ""} {set min 2}
		if {$max eq ""} {set max 60}
		if {$rmin eq ""} {set rmin 1}
		if {$rmax eq ""} {set rmax 4}
		set maxvallist [list_fill $nCols [string_fill a $min]]
		set maxlist [list_fill $nCols $min]
		set row 0
		foreach line [get $options(-variable)] {
			set col 0
			set maxheight $rmin
			foreach val $line cmax $maxlist {
				set width [string length $val]
				if {$width > $cmax} {
					if {$max != -1 && $width > $max} {
						set val [string range $val 0 $max]
					}
					lset maxlist $col $width
					lset maxvallist $col $val
				}
				set height [regexp -all \n $val]
				if {$height > $maxheight} {
					set maxheight $height
				}
				incr col
			}
			if {$rmax != -1 && $maxheight > $rmax} {set maxheigt $rmax}
			$table height $row $maxheight
			incr row
		}
		set col 0
		foreach maxval $maxvallist {
			set maxpwidth [font measure [$table cget -font] "$maxval  "]
			$table width $col -$maxpwidth
			incr col
		} 
	} else {
		for {set i 0} {$i < $nCols} {incr i} { 
			$object autosizecol $i
			$object autosizerow $i
		} 
	}
}

#doc {TkTable command copy} cmd {
#pathname copy
#} descr {
# puts the data in the selected cells in the selection
#}
Classy::TkTable method copy {} {
	set rowsep [$object cget -rowseparator]
	set colsep [$object cget -colseparator]
	set result {}
	foreach line [$object selection get] {
		append result [join $line $colsep]$rowsep
	}
	clipboard clear -displayof $object
	catch {clipboard append -displayof $object $result}
	return $result
}

#doc {TkTable command cut} cmd {
#pathname cut
#} descr {
# puts the data in the selected cells in the selection, and deletes it afterwards
#}
Classy::TkTable method cut {} {
	private $object table
	set result [$object copy]
	catch {
		$table curselection {}
		$table selection clear all
	}
	return $result
}

#doc {TkTable command paste} cmd {
#pathname paste ?data?
#} descr {
# paste data in the Table. The data will replace the contents of each selected cell.
#}
Classy::TkTable method paste {} {
	private $object table
	set list [$table curselection]
	if {![llength $list]} {
		set list [$table index active]
	}
	set data [csv_parse [clipboard get] [$table cget -colseparator]]
	set cols [$table cget -cols]
	set rows [$table cget -rows]
	foreach cell $list {
		set r [$object index $cell row]
		set c [$object index $cell col]
		foreach line $data {
			set cc $c
			foreach el $line {
				$table set $r,$cc $el
				incr cc
				if {$cc == $cols} break
			}
			incr r
			if {$r == $rows} break
		}
		
	}
	if {[$table cget -state] == "normal"} {focus $object}
}

Classy::TkTable method empty {} {
	private $object table
	if {[catch {$table index active row} r]} return
	set c [$table index active col]
	$table set $r,$c {}
}

Classy::TkTable method delete {args} {
	private $object table
	foreach index [$object selection current] {
		$table set $index {}
	}
}

Classy::TkTable method search {args} {
	cmd_args "$object search" {
		-direction {any "forwards/backwards"}
		-type {any "exact/regexp/glob"}
		-nocase {switch "Ignore case differences"}
		-count {any "variable to store number of index positions"}
	} {pattern index} $args
	
}

proc Classy::TkTable_textindex {text index} {
	if {$index == 0} {return 1.0}
	set len [string lengt $text]
	if {$index >= $len} {return end-1c}
	set temp [string range $text 0 $index]
	set list [split $temp \n]
	set line [lindex $list end]
	return [llength $list].[expr {[string length $line]-1}]
}

proc Classy::TkTable_stringindex {text index} {
	foreach {r c} [split $index .] break
	if {$r == 1} {
		set start 0
	} else {
		set start [lindex [string_find $text \n] [expr {$r-2}]]
	}
	if {![isint $start]} {return end}
	return [expr {$start+$c}]
}

proc Classy::TkTable_textfind {dir type text pattern {start {}}} {
	if {$start eq ""} {
		if {$dir == 1} {
			set start 0
		} elseif {$dir == -1} {
			set start end
		} else {
			error "wrong dir $dir"
		}
	}
	set poss {}
	switch $type {
		regexp {
			set poss [regexp -all -inline -indices -start $start $pattern $text]
			if {$dir == 1} {
				set poss [lindex $poss 0]
			} else {
				set poss [lindex $poss 0]
			}
		}
		exact {
			if {$dir == 1} {
				set poss [string first $pattern $text $start]
			} else {
				set poss [string last $pattern $text $start]
			}
			if {$poss == -1} {return {}}
			lappend poss [expr {$poss+[string length $pattern]}]
		}
		default {
			error "unknown search type $type"
		}
	}
	return $poss
}

proc Classy::TkTable_listfind {dir type tdata pattern r c} {
	switch $type {
		regexp {
			set poss [list_find -regexp [lindex $tdata $r] $pattern]
		}
		exact {
			set pattern *$pattern*
			set type glob
			set poss [list_find -glob [lindex $tdata $r] *$pattern*]
		}
		default {
			error "unknown search type $type"
		}
	}
	if {[llength $poss]} {
		if {$dir == 1} {
			foreach pos $poss {
				if {$pos > $c} {
					return [list $r $pos]
				}
			}
		} else {
			foreach pos [list_reverse $poss] {
				if {$pos < $c} {
					return [list $r $pos]
				}
			}
		}
	}
	if {$dir == 1} {
		set end [llength $tdata]
	} else {
		set end -1
	}
	while 1 {
		incr r $dir
		if {$r == $end} break
		set poss [list_find -$type [lindex $tdata $r] $pattern]
		if {[llength $poss]} {
			if {$dir == 1} {
				return [list $r [lindex $poss 0]]
			} else {
				return [list $r [lindex $poss end]]
			}
		}
	}
	return {}
}

Classy::TkTable method fitdata {} {
	private $object table options
	upvar #0 $options(-variable) ltable
	if {![info exists ltable]} return
	switch $options(-variabletype) {
		list {
			set rows [llength $ltable]
			set cols [llength [$object cget -labels]]
			foreach line $ltable {
				if {[llength $line] > $cols} {set cols [llength $line]}
			}
		}
		tlist {
			set cols [llength $ltable]
			set rows [llength [$object cget -labels]]
			set max 0
			foreach line $ltable {
				incr max; if {$max > 1000} break
				if {[llength $line] > $rows} {set rows [llength $line]}
			}
		}
		array - {} {
			set list [list_remove [array names ltable] active]
			set list [list_regsub , $list { }]
			set rows [lindex [lsort -integer [list_subindex $list 0]] end]
			set cols [lindex [lsort -integer [list_subindex $list 1]] end]
			set lcols [llength [$object cget -labels]]
			if {$lcols > $cols} {set cols $lcols}
			incr cols
			incr rows
		}
		table {
			set fields [table_fields $ltable]
			set rows [table_size $ltable]
			set cols [llength $fields]
			set lcols [llength [$object cget -labels]]
			if {$lcols > $cols} {set cols $lcols}
		}
		default {
			return
		}
	}
	if {$rows < 1} {set rows 1}
	if {$cols < 1} {set cols 1}
	$object configure -rows $rows
	$object configure -cols $cols
}

Classy::TkTable method sort {args} {
	if {[llength $args] < 1} {
		error "wrong # args: should be "$object sort ?w? col"
	}
	set col [lindex $args end]
	private $object table options sorted
	upvar #0 $options(-variable) ltable
	if {($col >= [llength $options(-labels)]) || ($col < 0)} {
		error "cannot sort on column $col: out of range"
	}
	set field [lindex $options(-labels) $col]
	if {![info exists sorted] || ($field ne [lindex $sorted 0])} {
		set sorted [list $field -]
	}
	if {[lindex $sorted end] eq "-"} {
		set order -increasing
		set sorted [list $field +]
	} else {
		set order -decreasing
		set sorted [list $field -]
	}
	set titlerows $options(-titlerows)
	switch $options(-variabletype) {
		list {
			if {$titlerows} {
				set header [lrange $ltable 0 [expr {$titlerows-1}]]
				set ltable [list_concat $header [lsort -index $col -dictionary $order [lrange $ltable $titlerows end]]]
			} else {
				set ltable [lsort -index $col -dictionary $order $ltable]
			}
		}
		array {
			unset -nocomplain a
			set s {}
			foreach name [lsort -dict [array names ltable]] {
				foreach {crow ccol} [split $name ,] break
				lappend a($crow) $ccol $ltable($name)
				if {$ccol == $col} {
					lappend s [list $crow $ltable($name)]
				}
			}
			unset -nocomplain a(active)
			set s [list_subindex [lsort -index 1 -dictionary $order $s] 0]
			set rows [lsort -integer $order [array names a]]
			if {$order eq "-increasing"} {
				set rows [list_union [list_lremove $rows $s] $s]
			} else {
				set rows [list_union $s [list_lremove $rows $s]]
			}
			unset -nocomplain ltable
			set pos 0
			list_foreach crow $rows {
				foreach {ccol val} $a($crow) {
					set ltable($pos,$ccol) $val
				}
				unset a($crow)
				incr pos
			}
		}
		table {
			set field [lindex [table_fields $ltable] $col]
			set ltable [table_sort $ltable $field $order -dictionary]
		}
		default {
			error "don't know how to sort (only can sort -variabletype list, array and table)"
		}
	}
	$object configure -labelsort $sorted
}

Classy::TkTable method deleterows {{rows {}}} {
	private $object table options
	if {![llength $rows]} {
		set list [$object curselection]
		if {![llength $list]} {set list [$table index active]}
		regsub -all {,[0-9]+} $list {} rows
	}
	set rows [list_remdup $rows]
	switch $options(-variabletype) {
		list {
			upvar #0 $options(-variable) ltable
			set ltable [list_sub $ltable -exclude $rows]
			$object configure -rows [expr {[$object cget -rows]-[llength $rows]}]
		}
		default {
			foreach row $rows {
				$table delete rows $row 1
			}
		}
	}
	$object selection clear
}

Classy::TkTable method deletecols {{cols {}}} {
	private $object table options
	if {![llength $cols]} {
		set list [$object curselection]
		if {![llength $list]} {set list [$table index active]}
		regsub -all {[0-9]+,} $list {} cols
	}
	set cols [list_remdup $cols]
	switch $options(-variabletype) {
		list {
			upvar #0 $options(-variable) ltable
			set len [llength $ltable]
			for {set r 0} {$r < $len} {incr r} {
				set line [lindex $ltable $r]
				set line [list_sub $line -exclude $cols]
				lset ltable $r $line
			}
			$object configure -cols [expr {[$object cget -cols]-[llength $cols]}]
		}
		default {
			foreach col $cols {
				$table delete cols $col 1
			}
		}
	}
	$object selection clear
}

Classy::TkTable method insertrows {{row {}} {count 1}} {
	private $object table options
	if {![llength $row]} {
		set row [$table index active row]
	}
	switch $options(-variabletype) {
		list {
			upvar #0 $options(-variable) ltable
			set ltable [eval {linsert $ltable $row} [list_fill $count {}]]
			$object configure -rows [expr {[$object cget -rows]+$count}]
		}
		default {
			$table insert rows $rows $count
		}
	}
	$object selection clear
}

Classy::TkTable method insertcols {{col {}} {count 1}} {
	private $object table options
	if {$col eq ""} {
		set col [$table index active col]
	}
	switch $options(-variabletype) {
		list {
			upvar #0 $options(-variable) ltable
			set len [llength $ltable]
			for {set r 0} {$r < $len} {incr r} {
				set line [lindex $ltable $r]
				lset ltable $r [eval {linsert $line $col} [list_fill $count {}]]
			}
			$object configure -cols [expr {[$object cget -cols]+$count}]
		}
		default {
			$table insert cols $cols $count
		}
	}
	$object selection clear
}


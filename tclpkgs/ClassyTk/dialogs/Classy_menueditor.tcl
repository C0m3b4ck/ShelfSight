Classy::Toplevel subclass Classy_menueditor
Classy_menueditor method init args {
	super init
	# Create windows
	Classy::Paned $object.paned1
	grid $object.paned1 -row 1 -column 1 -sticky nesw
	Classy::TreeWidget $object.browse \
		-width 100
	grid $object.browse -row 1 -column 0 -sticky nesw
	frame $object.basic  \
		-borderwidth 2 \
		-height 10 \
		-relief groove \
		-width 10
	grid $object.basic -row 1 -column 2 -sticky nesw
	Classy::Entry $object.basic.name \
		-label Name \
		-labelwidth 11 \
		-width 4
	grid $object.basic.name -row 1 -column 0 -sticky nesw
	Classy::Selector $object.basic.command \
		-label {Command (or options)} \
		-type text
	grid $object.basic.command -row 3 -column 0 -sticky nesw
	Classy::Entry $object.basic.type \
		-combopreset {echo {menu action radio check activemenu separator}} \
		-label Type \
		-labelwidth 11 \
		-combo 0 \
		-width 4
	grid $object.basic.type -row 0 -column 0 -sticky nesw
	Classy::Selector $object.basic.key \
		-label {Key shortcut} \
		-orient vertical \
		-type key
	grid $object.basic.key -row 2 -column 0 -sticky nesw
	grid columnconfigure $object.basic 0 -weight 1
	grid rowconfigure $object.basic 3 -weight 1
	Classy::DynaTool $object.dynatool1  \
		-type Classy_MenuEditor
	grid $object.dynatool1 -row 0 -column 0 -columnspan 3 -sticky nesw
	grid columnconfigure $object 2 -weight 1
	grid rowconfigure $object 1 -weight 1

	if {"$args" == "___Classy::Builder__create"} {return $object}
	# Parse this
	$object configure  \
		-title {Menu Editor}
	$object.paned1 configure \
		-window [varsubst object {$object.browse}]
	$object.browse configure \
		-rootcommand [varsubst object {$object selectroot}] \
		-endnodecommand [varsubst object {$object openendnode}] \
		-opencommand [varsubst object {$object opennode}] \
		-closecommand [varsubst object {$object closenode}]
	$object.basic.name configure \
		-command [varsubst object {$object rename}]
	$object.basic.command configure \
		-command [varsubst object {$object recommand}]
	$object.basic.type configure \
		-command [varsubst object {$object retype}]
	$object.basic.key configure \
		-command [varsubst object {$object rekey}]
	$object.dynatool1 configure \
		-cmdw [varsubst object {$object}]
	Classy::DynaMenu attachmainmenu Classy_MenuEditor $object
	# Configure initial arguments
	if {"$args" != ""} {eval $object configure $args}
# ClassyTk Finalise
$object finalise
	return $object
}

Classy_menueditor addoption -savecommand {savecommand Savecommand {}} {}

Classy_menueditor method finalise {} {
	private $object current
	set current(changed) 0
}

Classy_menueditor method load data {
	private $object menu current
	catch {unset menu}
	set menu() [$object _recload $data {}]
	update idletasks
	$object.browse clearnode {}
	$object.browse configure -rootimage [Classy::geticon newmenu]
	$object opennode {}
	$object changed 0
	set current(changed) 0
}

Classy_menueditor method opennode node {
	private $object menu current
	set entries [map_fields $menu() $node]
	foreach text $entries {
		set base $node
		lappend base $text
		foreach {type command key} $menu($base) break
		set icon new$type
		set newnode $node
		lappend newnode $text
		switch $type {
			menu {
				set type folder
			}
			activemenu {
				set type end
			}
			action {
				set type end
			}
			radio {
				set type end
			}
			check {
				set type end
			}
			separator {
				set type end
			}
			default {
				set type end
				set icon sm_file
			}
		}
		$object.browse addnode $node $newnode -text $text -type $type \
			-image [Classy::geticon $icon]
	}
	$object select $node
}

Classy_menueditor method openendnode node {
	private $object current menu
	if ![llength $node] return
	$object select $node
}

Classy_menueditor method closenode node {
	private $object menu
	$object select $node
	foreach {type command key} $menu($node) break
	set text [lindex $node end]
	$object.basic.type nocmdset menu
	$object.basic.name nocmdset $text
	$object.basic.command configure -state disabled
	$object.basic.key set $key
	$object.browse clearnode $node
}

Classy_menueditor method _recload {data name} {
	private $object menu
	set result {}
	set num 1
	foreach current [cmd_split $data] {
		if ![llength $current] continue
		if [regexp ^# $current] continue
		foreach {type text command key} $current break
		if [string_equal $type separator] {
			set text separator$num
			incr num
		}
		lappend result $text
		set newnode $name
		lappend newnode $text
		if {"$type"=="menu"} {
			set menu($newnode) [list $type {} $key]
			lappend result [$object _recload [lindex $current 2] $newnode]
		} else {
			set menu($newnode) [list $type $command $key]
			lappend result {}
		}
	}
	return $result
}

Classy_menueditor method copy {args} {
	private $object current menu
	if [llength $args] {
		set node [lindex $args 0]
	} else {
		set node $current(node)
	}
	set result [$object _copy $node]
	set current(buffer) $result
	return $result
}

Classy_menueditor method _copy node {
	private $object menu
	set result {}
	if ![llength $node] {
		set type menu
	} else {
		set type [lindex $menu($node) 0]
	}
	if [string_equal $type menu] {
		set data [map_get $menu() $node]
		foreach {entry value} $data {
			set base $node
			lappend base $entry
			if ![llength $value] {
				if [string_equal [lindex $menu($base) 0] separator] {
					append result separator\n
				} else {
					append result [lreplace $menu($base) 1 -1 [lindex $base end]]\n
				}
			} else {
				set sub [$object _copy $base]
				append result $sub\n
			}
		}
		if ![llength $node] {
			return $result
		} else {
			return [lreplace $menu($node) 1 2 [lindex $node end] \n$result]
		}
	} else {
		return [lreplace $menu($node) 1 -1 [lindex $node end]]
	}
}

Classy_menueditor method cut {args} {
	eval $object copy $args
	eval $object delete $args
}

Classy_menueditor method paste {{node {}} {newname {}}} {
	private $object current menu
	set data $current(buffer)
	if ![llength $node] {set node $current(node)}
	set parent $node
	if ![string length $node] {
		set ptype menu
	} elseif ![info exists menu($parent)] {
		set ptype separator
	} else {
		set ptype [lindex $menu($node) 0]
	}
	if [string_equal $ptype menu] {
		set list [map_fields $menu() $parent]
		set pos 0
	} else {
		set tail [list_pop parent]
		set list [map_fields $menu() $parent]
		set pos [lsearch $list $tail]
		incr pos
	}
	if ![llength $newname] {
		set bname [lindex $data 1]
	} else {
		set bname $newname
	}
	set num 0
	set newname $bname
	while 1 {
		if {[lsearch $list $newname] == -1} break
		incr num
		set newname $bname$num
	}
	set newnode $parent
	lappend newnode $newname
	if [string_equal [lindex $data 0] menu] {
		set sub [$object _recload [lreplace $data 1 1 $newname] $parent]
	} else {
		set sub {}
		set menu($newnode) [lreplace $data 1 1]
	}
	set mpart [map_get $menu() $parent]
	set len [llength $mpart]
	set pos [expr {2*$pos}]
	if {$pos < $len} {
		set mpart [lreplace $mpart $pos -1 $newname [lindex $sub 1]]
	} else {
		lappend mpart $newname [lindex $sub 1]
	}
	set menu() [map_set $menu() $parent $mpart]
	$object closenode $parent
	$object opennode $parent
	$object select $newnode
	$object changed 1
}

Classy_menueditor method delete {args} {
	private $object current menu
	if [llength $args] {
		set node [lindex $args 0]
	} else {
		set node $current(node)
	}
	if [info exists menu($node)] {
		if [string_equal [lindex $menu($node) 0] menu] {
			if ![Classy::yorn "Are you sure you want to delete submenu \"$node\""] return
		}
	}
	set parent $node
	set tail [list_pop parent]
	set list [map_fields $menu() $parent]
	set pos [lsearch $list $tail]
	if {$pos == -1} return
	set mpart [map_get $menu() $parent]
	set deleted [lindex $mpart [expr {2*$pos+1}]]
	set mpart [lreplace $mpart [expr {2*$pos}] [expr {2*$pos+1}]]
	set menu() [map_set $menu() $parent $mpart]
	if [llength $parent] {
		$object closenode $parent
		$object opennode $parent
	} else {
		$object.browse clearnode {}
		$object opennode {}
	}
	set list [map_fields $menu() $parent]
	incr pos -1
	if {$pos < 0} {set pos 0}
	set newnode $parent
	set temp [lindex $list $pos]
	if ![llength $temp] {
		set temp [lindex $list end]
	}
	lappend newnode $temp
	$object select $newnode
	$object changed 1
}

Classy_menueditor method changed {changed} {
	private $object current
	if [true $changed] {
		set current(changed) 1
		set title [wm title $object]
		if ![regexp { \*$} $title] {
			wm title $object "[wm title $object] *"
		}
	} else {
		set current(changed) 0
		regsub { \*$} [wm title $object] {} title
		wm title $object $title
	}
}

Classy_menueditor method select {node} {
	private $object current menu
	$object.browse selection clear
	$object.browse selection add $node	
	set current(node) $node
	$object.basic.type configure -state normal
	$object.basic.name configure -state normal
	$object.basic.command configure -state normal
	$object.basic.key configure -state normal
	if ![info exists menu($node)] {
		$object.basic.type nocmdset separator
		$object.basic.name nocmdset {}
		$object.basic.command set {}
		$object.basic.key set {}
		$object.basic.name configure -state disabled
		$object.basic.command configure -state disabled
		$object.basic.key configure -state disabled
		$object.basic.type configure -state disabled
		return
	}
	if [string_equal $node {}] {
		set type menu
		set key {}
	} else {
		foreach {type command key} $menu($node) break
	}
	set text [lindex $node end]
	if [string_equal $type menu] {
		$object.basic.type nocmdset menu
		$object.basic.name nocmdset $text
		$object.basic.key set $key
		$object.basic.command set {}
		$object.basic.command configure -state disabled
	} else {
		$object.basic.type nocmdset $type
		$object.basic.name nocmdset $text
		$object.basic.command set $command
		$object.basic.key set $key
		set current(node) $node
	}
	$object.basic.type configure -state combo
}

Classy_menueditor method retype {value} {
	private $object current menu
	set node $current(node)
	set ctype [lindex $menu($node) 0]
	if [string_equal $value menu] {
		if ![string_equal $ctype menu] {
			$object.basic.type set $ctype
			error "Cannot change other types into menu"
		}
	} else {
		if [string_equal $ctype menu] {
			$object.basic.type set $ctype
			error "Cannot change menu into other types"
		}
	}
	set menu($node) [lreplace $menu($node) 0 0 $value]
	set parent $node
	set tail [list_pop parent]
	$object closenode $parent
	$object opennode $parent
	$object select $node
	$object changed 1
}

Classy_menueditor method rekey {value} {
	private $object current menu
	set node $current(node)
	set menu($node) [lreplace $menu($node) 2 2 $value]
	$object changed 1
}

Classy_menueditor method recommand {value} {
	private $object current menu
	set node $current(node)
	set menu($node) [lreplace $menu($node) 1 1 $value]
	$object changed 1
}

Classy_menueditor method _rename {oldbase newbase list} {
	private $object menu
	foreach {key value} $list {
		set oldnode $oldbase
		lappend oldnode $key
		set newnode $newbase
		lappend newnode $key
		if [llength $value] {
			$object _rename $oldnode $newnode $value
		}
		set menu($newnode) $menu($oldnode)
		unset menu($oldnode)
	}
}

Classy_menueditor method rename newname {
	private $object current menu
	set node $current(node)
	set pnode $node
	set tail [list_pop pnode]
	set newnode $pnode
	lappend newnode $newname
	if ![catch {map_get $menu() $newnode}] {
		error "node \"$newnode\" already exists"
	}
	set sub [map_get $menu() $node]
	if [llength $sub] {
		$object _rename $node $newnode $sub
	}
	set menu($newnode) $menu($node)
	unset menu($node)
	set pdata [map_get $menu() $pnode]
	set list [map_fields $pdata]
	set pos [lsearch $list $tail]
	set pdata [lreplace $pdata [expr {2*$pos}] [expr {2*$pos}] $newname]
	set menu() [map_set $menu() $pnode $pdata]
	$object closenode $pnode
	$object opennode $pnode
	$object select $newnode
	$object changed 1
}

Classy_menueditor method selectroot {} {
	private $object current menu
	$object.browse selection set {}
	set current(node) {}
	$object.basic.type nocmdset {}
	$object.basic.name nocmdset {}
	$object.basic.command set {}
	$object.basic.key set {}
	$object.basic.type configure -state disabled
	$object.basic.name configure -state disabled
	$object.basic.command configure -state disabled
	$object.basic.key configure -state disabled
}

Classy_menueditor method new type {
	private $object current menu
	set node $current(node)
	set pnode $node
	set keep [get current(buffer) ""]
	set current(buffer) [list $type $type {}]
	$object paste
	set current(buffer) $keep
	$object changed 1
}

Classy_menueditor method close {} {
	private $object current
	if [true $current(changed)] {
		if ![Classy::yorn "Closing menueditor, some changes are not saved, close anyway (changes will be lost)?"] return
	}
	destroy $object
}

Classy_menueditor method save {} {
	private $object current options
	set data [$object copy {}]
	set cmd "$options(-savecommand) [list $data]"
	uplevel #0 $cmd
	$object changed 0
}

Classy_menueditor method move {dir args} {
	private $object current menu
	if [llength $args] {
		set node [lindex $args 0]
	} else {
		set node $current(node)
	}
	set parent $node
	set tail [list_pop parent]
	set entries [map_fields $menu() $parent]
	set pos [lsearch $entries $tail]
	set data [map_get $menu() $parent]
	set tpos [expr {2*$pos}]
	set move [lrange $data $tpos [expr {$tpos+1}]]
	set data [lreplace $data $tpos [expr {$tpos+1}]]
	switch $dir {
		up {
			incr tpos -2
			if {$tpos < 0} return
			set data [eval {lreplace $data $tpos -1} $move]
		}
		down {
			set len [llength $entries]
			incr len -1
			if {$pos == $len} return
			incr pos
			if {$pos == $len} {
				eval {lappend data} $move
			} else {
				incr tpos 2
				set data [eval {lreplace $data $tpos -1} $move]
			}
		}
		default {
			error "Unknown direction \"$dir\""
		}
	}
	set menu() [map_set $menu() $parent $data]
	$object closenode $parent
	$object opennode $parent
	$object select $node
	$object changed 1
}

proc Classy::menu_edit {level key} {
	.classy__.menueditor close
	set file [file join $::Classy::dira($level) menu $key]
	set data [file_read $file]
	Classy_menueditor .classy__.menueditor -savecommand [list file_write $file]
	.classy__.menueditor load $data
	wm title .classy__.menueditor "$key ($level)"
}

Classy::Toplevel subclass Classy_toolbareditor
Classy_toolbareditor method init args {
	super init
	# Create windows
	Classy::Paned $object.paned1
	grid $object.paned1 -row 1 -column 1 -sticky nesw
	Classy::TreeWidget $object.browse \
		-width 100 \
		-height 50
	grid $object.browse -row 1 -column 0 -sticky nesw
	frame $object.basic  \
		-borderwidth 2 \
		-relief groove \
		-height 10 \
		-width 10
	grid $object.basic -row 1 -column 2 -sticky nesw
	Classy::Entry $object.basic.name \
		-label {Name (Help)} \
		-labelwidth 11 \
		-width 4
	grid $object.basic.name -row 1 -column 0 -sticky nesw
	Classy::Selector $object.basic.command \
		-label {Command (or options)} \
		-type text
	grid $object.basic.command -row 3 -column 0 -sticky nesw
	Classy::Entry $object.basic.type \
		-combopreset {echo {action actionrepeat radio check widget tool label separator optionmenu}} \
		-label Type \
		-labelwidth 11 \
		-combo 0 \
		-width 4
	grid $object.basic.type -row 0 -column 0 -sticky nesw
	Classy::Selector $object.basic.key \
		-label {Label / icon / proc} \
		-orient vertical \
		-type text
	grid $object.basic.key -row 2 -column 0 -sticky nesw
	Classy::Selector $object.basic.cmdwcommand \
		-label {cmdw command} \
		-type text
	grid $object.basic.cmdwcommand -row 4 -column 0 -sticky nesw
	grid columnconfigure $object.basic 0 -uniform {} -weight 1
	grid columnconfigure $object.basic 1 -uniform {}
	grid columnconfigure $object.basic 2 -uniform {}
	grid rowconfigure $object.basic 0 -uniform {}
	grid rowconfigure $object.basic 1 -uniform {}
	grid rowconfigure $object.basic 2 -uniform {}
	grid rowconfigure $object.basic 3 -uniform {} -weight 1
	grid rowconfigure $object.basic 4 -uniform {}
	grid rowconfigure $object.basic 5 -uniform {}
	grid rowconfigure $object.basic 6 -uniform {}
	Classy::DynaTool $object.dynatool1  \
		-type Classy_ToolbarEditor
	grid $object.dynatool1 -row 0 -column 0 -columnspan 3 -sticky nesw
	grid columnconfigure $object 0 -uniform {}
	grid columnconfigure $object 1 -uniform {}
	grid columnconfigure $object 2 -uniform {} -weight 1
	grid rowconfigure $object 0 -uniform {}
	grid rowconfigure $object 1 -uniform {} -weight 1

	if {"$args" == "___Classy::Builder__create"} {return $object}
	# Parse this
	$object configure  \
		-title {Toolbar Editor}\
		-destroycommand {}
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
	$object.basic.cmdwcommand configure \
		-command [varsubst object {$object recmdwcommand}]
	$object.dynatool1 configure \
		-cmdw [varsubst object {$object}]
	Classy::DynaMenu attachmainmenu Classy_ToolbarEditor $object
	# Configure initial arguments
	if {"$args" != ""} {eval $object configure $args}
# ClassyTk Finalise
$object finalise
	return $object
}

Classy_toolbareditor addoption -savecommand {savecommand Savecommand {}} {}

Classy_toolbareditor method finalise {} {
	private $object current
	set current(changed) 0
}

Classy_toolbareditor method _recload {data name} {
	private $object toolbar
	set result {}
	set num 1
	foreach current [cmd_split $data] {
		if ![llength $current] continue
		if [regexp ^# $current] continue
		foreach {type key text command} $current break
		if [string_equal $type separator] {
			set text separator$num
			incr num
		}
		lappend result $text
		set newnode $name
		lappend newnode $text
		if {"$type"=="toolbar"} {
			set toolbar($newnode) [list $type {} $key]
			lappend result [$object _recload [lindex $current 2] $newnode]
		} else {
			set toolbar($newnode) [list $type $command $key]
			lappend result {}
		}
	}
	return $result
}

Classy_toolbareditor method load data {
	private $object toolbar current
	catch {unset toolbar}
	set toolbar() [$object _recload $data {}]
	update idletasks
	$object.browse clearnode {}
	$object.browse configure -rootimage [Classy::geticon newtoolbar]
	$object opennode {}
	$object changed 0
	set current(changed) 0
}

Classy_toolbareditor method opennode node {
	private $object toolbar current
	set entries [map_fields $toolbar() $node]
	foreach text $entries {
		set base $node
		lappend base $text
		foreach {type command key} $toolbar($base) break
		set icon new$type
		set newnode $node
		lappend newnode $text
		switch $type {
			action {
				set type end
			}
			actionrepeat {
				set type end
			}
			radio {
				set type end
			}
			check {
				set type end
			}
			optionmenu {
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
		if [catch {Classy::geticon $key} icon] {
			set icon [Classy::geticon nothing]
		}
		$object.browse addnode $node $newnode -text $text -type $type \
			-image $icon
	}
	$object select $node
}

Classy_toolbareditor method openendnode node {
	private $object current toolbar
	if ![llength $node] return
	$object select $node
}

Classy_toolbareditor method closenode node {
	private $object toolbar
	$object select $node
	foreach {type command key} $toolbar($node) break
	set text [lindex $node end]
	$object.basic.type nocmdset toolbar
	$object.basic.name nocmdset $text
	$object.basic.command configure -state disabled
	$object.basic.cmdwcommand configure -state disabled
	$object.basic.key set $key
	$object.browse clearnode $node
}

Classy_toolbareditor method _copy node {
	private $object toolbar
	set result {}
	if ![llength $node] {
		set type toolbar
	} else {
		set type [lindex $toolbar($node) 0]
	}
	if {[string_equal $type toolbar]} {
		set data [map_get $toolbar() $node]
		foreach {entry value} $data {
			set base $node
			lappend base $entry
			if ![llength $value] {
				if [string_equal [lindex $toolbar($base) 0] separator] {
					append result separator\n
				} else {
					foreach {type command key cmdwcommand} $toolbar($base) break
					append result [list $type $key [lindex $base end] $command $cmdwcommand]\n
				}
			} else {
				set sub [$object _copy $base]
				append result $sub\n
			}
		}
		if {![llength $node]} {
			return $result
		} else {
			return [lreplace $toolbar($node) 1 2 [lindex $node end] \n$result]
		}
	} else {
		foreach {type command key cmdwcommand} $toolbar($node) break
		return [list $type $key [lindex $node end] $command $cmdwcommand]
	}
}

Classy_toolbareditor method copy {args} {
	private $object current toolbar
	if [llength $args] {
		set node [lindex $args 0]
	} else {
		set node $current(node)
	}
	set result [$object _copy $node]
	set current(buffer) $result
	return $result
}

Classy_toolbareditor method cut {args} {
	eval $object copy $args
	eval $object delete $args
}

Classy_toolbareditor method paste {{node {}} {newname {}}} {
	private $object current toolbar
	set data $current(buffer)
	if {![llength $node]} {set node $current(node)}
	set parent $node
	if {![string length $node]} {
		set ptype toolbar
	} elseif {![info exists toolbar($parent)]} {
		set ptype separator
	} else {
		set ptype [lindex $toolbar($node) 0]
	}
	if {[string_equal $ptype toolbar]} {
		set list [map_fields $toolbar() $parent]
		set pos 0
	} else {
		set tail [list_pop parent]
		set list [map_fields $toolbar() $parent]
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
	if [string_equal [lindex $data 0] toolbar] {
		set sub [$object _recload [lreplace $data 1 1 $newname] $parent]
	} else {
		set sub {}
		set toolbar($newnode) [lreplace $data 1 1]
	}
	set mpart [map_get $toolbar() $parent]
	set len [llength $mpart]
	set pos [expr {2*$pos}]
	if {$pos < $len} {
		set mpart [lreplace $mpart $pos -1 $newname [lindex $sub 1]]
	} else {
		lappend mpart $newname [lindex $sub 1]
	}
	set toolbar() [map_set $toolbar() $parent $mpart]
	$object closenode $parent
	$object opennode $parent
	$object select $newnode
	$object changed 1
}

Classy_toolbareditor method delete {args} {
	private $object current toolbar
	if [llength $args] {
		set node [lindex $args 0]
	} else {
		set node $current(node)
	}
	if [info exists toolbar($node)] {
		if [string_equal [lindex $toolbar($node) 0] toolbar] {
			if ![Classy::yorn "Are you sure you want to delete subtoolbar \"$node\""] return
		}
	}
	set parent $node
	set tail [list_pop parent]
	set list [map_fields $toolbar() $parent]
	set pos [lsearch $list $tail]
	if {$pos == -1} return
	set mpart [map_get $toolbar() $parent]
	set deleted [lindex $mpart [expr {2*$pos+1}]]
	set mpart [lreplace $mpart [expr {2*$pos}] [expr {2*$pos+1}]]
	set toolbar() [map_set $toolbar() $parent $mpart]
	if [llength $parent] {
		$object closenode $parent
		$object opennode $parent
	} else {
		$object.browse clearnode {}
		$object opennode {}
	}
	set list [map_fields $toolbar() $parent]
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

Classy_toolbareditor method changed {changed} {
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

Classy_toolbareditor method select {node} {
	private $object current toolbar
	$object.browse selection clear
	$object.browse selection add $node	
	set current(node) $node
	$object.basic.type configure -state normal
	$object.basic.name configure -state normal
	$object.basic.command configure -state normal
	$object.basic.cmdwcommand configure -state normal
	$object.basic.key configure -state normal
	if [string_equal $node {}] {
		set type toolbar
		set key {}
	} else {
		foreach {type command key cmdwcommand} $toolbar($node) break
	}
	set text [lindex $node end]
	if [string_equal $type toolbar] {
		$object.basic.type nocmdset toolbar
		$object.basic.name nocmdset $text
		$object.basic.key set $key
		$object.basic.command set {}
		$object.basic.cmdwcommand set {}
		$object.basic.command configure -state disabled
	} elseif [string_equal $type separator] {
		$object.basic.type nocmdset separator
		$object.basic.name nocmdset {}
		$object.basic.command set {}
		$object.basic.key set {}
		$object.basic.name configure -state disabled
		$object.basic.command configure -state disabled
		$object.basic.cmdwcommand configure -state disabled
		$object.basic.key configure -state disabled
		$object.basic.type configure -state disabled
	} else {
		$object.basic.type nocmdset $type
		$object.basic.name nocmdset $text
		$object.basic.command set $command
		$object.basic.cmdwcommand set $cmdwcommand
		$object.basic.key set $key
		set current(node) $node
	}
	$object.basic.type configure -state combo
	update idletasks
	$object.basic.key changed 0
	$object.basic.command changed 0
}

Classy_toolbareditor method retype {value} {
	private $object current toolbar
	set node $current(node)
	set ctype [lindex $toolbar($node) 0]
	if [string_equal $value toolbar] {
		if ![string_equal $ctype toolbar] {
			$object.basic.type set $ctype
			error "Cannot change other types into toolbar"
		}
	} else {
		if [string_equal $ctype toolbar] {
			$object.basic.type set $ctype
			error "Cannot change toolbar into other types"
		}
	}
	set toolbar($node) [lreplace $toolbar($node) 0 0 $value]
	set parent $node
	set tail [list_pop parent]
	$object closenode $parent
	$object opennode $parent
	$object select $node
	$object changed 1
}

Classy_toolbareditor method rekey {value} {
	private $object current toolbar
	set node $current(node)
	set toolbar($node) [lreplace $toolbar($node) 2 2 $value]
	$object changed 1
}

Classy_toolbareditor method recommand {value} {
	private $object current toolbar
	set node $current(node)
	set toolbar($node) [lreplace $toolbar($node) 1 1 $value]
	$object changed 1
}

Classy_toolbareditor method _rename {oldbase newbase list} {
	private $object toolbar
	foreach {key value} $list {
		set oldnode $oldbase
		lappend oldnode $key
		set newnode $newbase
		lappend newnode $key
		if [llength $value] {
			$object _rename $oldnode $newnode $value
		}
		set toolbar($newnode) $toolbar($oldnode)
		unset toolbar($oldnode)
	}
}

Classy_toolbareditor method rename newname {
	private $object current toolbar
	set node $current(node)
	set pnode $node
	set tail [list_pop pnode]
	set newnode $pnode
	lappend newnode $newname
	if ![catch {map_get $toolbar() $newnode}] {
		error "node \"$newnode\" already exists"
	}
	set sub [map_get $toolbar() $node]
	if [llength $sub] {
		$object _rename $node $newnode $sub
	}
	set toolbar($newnode) $toolbar($node)
	unset toolbar($node)
	set pdata [map_get $toolbar() $pnode]
	set list [map_fields $pdata]
	set pos [lsearch $list $tail]
	set pdata [lreplace $pdata [expr {2*$pos}] [expr {2*$pos}] $newname]
	set toolbar() [map_set $toolbar() $pnode $pdata]
	$object closenode $pnode
	$object opennode $pnode
	$object select $newnode
	$object changed 1
}

Classy_toolbareditor method selectroot {} {
	private $object current toolbar
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

Classy_toolbareditor method new type {
	private $object current toolbar
	set node $current(node)
	set pnode $node
	set keep [get current(buffer) ""]
	set key $type
	set command {}
	switch $type {
		check {
			set key $type
			set command [list -variable $type -onvalue 1 -ofvalue 0]
		}
		radio {
			set key $type
			set command [list -variable $type -value test]
		}
		optionmenu {
			set key $type
			set command [list -textvariable $type -list {a b}]
		}
	}
	set current(buffer) [list $type $type $command $key]
	$object paste
	set current(buffer) $keep
	$object changed 1
}

Classy_toolbareditor method close {} {
	private $object current
	if [true $current(changed)] {
		if ![Classy::yorn "Closing toolbareditor, some changes are not saved, close anyway (changes will be lost)?"] return
	}
	destroy $object
}

Classy_toolbareditor method save {} {
	private $object current options
	set data [$object copy {}]
	set cmd "$options(-savecommand) [list $data]"
	uplevel #0 $cmd
	$object changed 0
}

Classy_toolbareditor method move {dir args} {
	private $object current toolbar
	if [llength $args] {
		set node [lindex $args 0]
	} else {
		set node $current(node)
	}
	set parent $node
	set tail [list_pop parent]
	set entries [map_fields $toolbar() $parent]
	set pos [lsearch $entries $tail]
	set data [map_get $toolbar() $parent]
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
	set toolbar() [map_set $toolbar() $parent $data]
	$object closenode $parent
	$object opennode $parent
	$object select $node
	$object changed 1
}

proc Classy::toolbar_edit {level key} {
	.classy__.toolbareditor close
	set file [file join $::Classy::dira($level) toolbar $key]
	set data [file_read $file]
	Classy_toolbareditor .classy__.toolbareditor -savecommand [list file_write $file]
	.classy__.toolbareditor load $data
	wm title .classy__.toolbareditor "$key ($level)"
}

Classy_toolbareditor method recmdwcommand value {
	private $object current toolbar
	set node $current(node)
	if {$value eq ""} {
			set toolbar($node) [lrange $toolbar($node) 0 2]
	} else {
		if {[llength $toolbar($node)] == 3} {
			lappend toolbar($node) $value
		} else {
			set toolbar($node) [lreplace $toolbar($node) 3 3 $value]
		}
	}
	$object changed 1
}


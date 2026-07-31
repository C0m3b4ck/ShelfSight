#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Classy::SelectDialog
# ----------------------------------------------------------------------
#doc SelectDialog title {
#SelectDialog
#} index {
# Dialogs
#} shortdescr {
# make a selection out of a list
#} descr {
# subclass of <a href="Dialog.html">Dialog</a><br>
# creates a selection dialog. It allows selection out of a list of
# values. It also optionally allows adding or removing values from 
# the list. Using -selectmode enter, values not in the list can 
# be entered.
#<p>
# When -selectmode is single or browse (only one element can be selected),
# the result is this one element. In selectmodes where multiple elements can be
# selected, the result is always a list, even if only one element was selected.
# (a list of one element in this case)
#<p>
# The command<br>
#<b>Classy::select title list</b><br>
# can be used to easily pop op a dialog for simply selecting a value
# out of a list.
#}
#doc {SelectDialog options} h2 {
#	SelectDialog specific options
#}
#doc {SelectDialog command} h2 {
#	SelectDialog specific methods
#}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Classy::Dialog subclass Classy::SelectDialog

Classy::SelectDialog method init {args} {
	super init
	$object configure -resize {1 1}
	$object add go "Go" [list $object _command] default
	frame $object.options.frame -highlightthickness 0
	Classy::ListBox $object.options.list -selectmode browse -exportselection no -width 5 -height 5 -filtervariable [privatevar $object.options.list filter]
	pack $object.options.frame -fill both -expand yes
	pack $object.options.list -in $object.options.frame -side left -fill both -expand yes
	# REM Create bindings
	# -------------------
	focus $object.options.list
	bind $object.options.list <<Invoke>> "$object invoke go"
	bind $object.options.list <<MExecute>> "$object invoke go Action"
	bind $object.options.list <<MExecuteAjust>> "$object.options.list activate @%x,%y;$object invoke go Adjust"
	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
	focus $object.options.list
	return $object
}

Classy::SelectDialog component addentry {$object.options.add}
Classy::SelectDialog component renameentry {$object.options.rename}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

Classy::SelectDialog addoption -selectmode {selectMode SelectMode browse} {
	if {[inlist {browse single enter} $value]} {
		catch {$object delete all}
		catch {$object delete clear}
		catch {destroy $object.options.other}
		if {$value eq "enter"} {
			Classy::Entry $object.options.other -label "Other value"
			pack $object.options.other -side bottom -fill x
			$object.options.list configure -browsecommand [list $object.options.other set]
		} else {
			$object.options.list configure -browsecommand {}
		}
	} else {
		catch {$object add all "All" [list $object _command all]}
		catch {$object add clear "Clear" [list $object clearselection]}
		$object persistent set clear
	}
	$object.options.list configure -selectmode $value
}

Classy::SelectDialog chainoptions {$object.options.list}

#doc {SelectDialog options -command} option {-command ? ?} descr {
#}
Classy::SelectDialog addoption -command {command Command {}} {}
#Classy::SelectDialog chainoption -command {$object.actions.go} -command

#doc {SelectDialog options -addvariable} option {-command ? ?} descr {
#}
Classy::SelectDialog addoption -addvariable {addvariable AddVariable {}} {
	$object configure -addcommand [getprivate $object options(-addcommand)]
}

#doc {SelectDialog options -default} option {-default default Default} descr {
#}
Classy::SelectDialog addoption -default {default Default {}} {
	if [winfo exists $object.options.add] {
		$object.options.add configure -default $value
	}
	return $value
}

#doc {SelectDialog options -combo} option {-combo combo Combo} descr {
#}
Classy::SelectDialog addoption -combo {combo Combo {}} {
	if [winfo exists $object.options.add] {
		$object.options.add configure -combo $value
	}
	return $value
}

#doc {SelectDialog options -combopreset} option {-combopreset comboPreset ComboPreset} descr {
#}
Classy::SelectDialog addoption -combopreset {comboPreset ComboPreset {}} {
	if [winfo exists $object.options.add] {
		$object.options.add configure -combo $value
	}
	return $value
}

#doc {SelectDialog options -addcommand} option {-addcommand addCommand AddCommand} descr {
#}
Classy::SelectDialog addoption -addcommand {addCommand AddCommand {}} {
	private $object options
	catch {destroy $object.actions.add}
	catch {destroy $object.options.add}
	if {"$value" != ""} {
		Classy::Entry $object.options.add -label "Add" -textvariable $options(-addvariable) \
			-command "$object invoke add" \
			-default [getprivate $object options(-default)] \
			-combo [getprivate $object options(-combo)] \
			-combopreset [getprivate $object options(-combopreset)]
		pack $object.options.add -side bottom -fill x
		$object add add "Add" [list $object _add] Insert
	}
	return $value
} 

#doc {SelectDialog options -deletecommand} option {-deletecommand deleteCommand DeleteCommand} descr {
#}
Classy::SelectDialog addoption -deletecommand {deleteCommand DeleteCommand {}} {
	catch {destroy $object.actions.delete}
	if {"$value" != ""} {
		$object add delete "Delete" [list $object _delete] Delete
	}
	return $value
}

#doc {SelectDialog options -renamecommand} option {-renamecommand renameCommand RenameCommand} descr {
#}
Classy::SelectDialog addoption -renamecommand {renameCommand RenameCommand {}} {
	catch {destroy $object.actions.rename}
	catch {destroy $object.options.rename}
	if {"$value" != ""} {
		Classy::Entry $object.options.rename -label "Rename to" \
			-command "$object invoke rename"
		pack $object.options.rename -side bottom -fill x
		$object add rename "Rename" [list $object _rename]
	}
	return $value
} 

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::SelectDialog chainallmethods {$object.options.list} Classy::ListBox

#doc {SelectDialog command fill} cmd {
#pathname fill names
#} descr {
#}
Classy::SelectDialog method fill {names} {
	$object.options.list delete 0 end
	eval {$object.options.list insert end} $names
}

#doc {SelectDialog command get} cmd {
#pathname get 
#} descr {
#}
Classy::SelectDialog method get {} {
	private $object options
	set selection [$object curselection]
	if {[winfo exists $object.options.other]} {set other [$object.options.other get]} else {set other ""}
	if {([llength $selection] < 2) && ($other ne "")} {
		return $other
	}
	if {![llength $selection]} {
		# return [$object.options.list get active]
		return {}
	} else {
		set result  ""
		if {[inlist {single browse} $options(-selectmode)]} {
			return [$object.options.list get $selection]
		}
		foreach num $selection {
			lappend result [$object.options.list get $num]
		}
		return $result
	}
}

#doc {SelectDialog command set} cmd {
#pathname set name
#} descr {
#}
Classy::SelectDialog method set {name} {
	set pos [lsearch -exact [$object.options.list get 0 end] $name]
	if {$pos != -1} {
		$object.options.list selection clear 0 end
		$object.options.list activate $pos
		$object.options.list selection set $pos
		$object.options.list see $pos
	}
}

Classy::SelectDialog method _command {args} {
	private $object options
	set command [get options(-command) ""]
	if {"$command" != ""} {
		if {[llength $args]} {
			set value [$object.options.list get 0 end]
		} else {
			set value [$object get]
		}
		uplevel #0 $command [list $value]
	}
}

Classy::SelectDialog method _add {} {
	set addcommand [getprivate $object options(-addcommand)]
	if {"$addcommand" != ""} {
		set value [$object.options.add get]
		set res [uplevel #0 $addcommand [list $value]]
		if {[llength $res]==2} {
			$object.options.list insert [$object.options.list index [lindex $res 1]] [lindex $res 0]
		} else {
			$object.options.list insert active $value
		}
	}
}

Classy::SelectDialog method _delete {} {
	set deletecommand [getprivate $object options(-deletecommand)]
	if {"$deletecommand" != ""} {
		uplevel #0 $deletecommand [list [$object get]]
		$object.options.list delete active
	}
}

Classy::SelectDialog method _rename {} {
	set renamecommand [getprivate $object options(-renamecommand)]
	if {"$renamecommand" != ""} {
		uplevel #0 $renamecommand [list [$object get]] [list [$object.options.rename get]]
		$object.options.list insert [expr [$object.options.list index active]+1] [$object.options.rename get]
		$object.options.list delete active
	}
}

Classy::SelectDialog method select {list} {
	$object.options.list selection clear 0 end
	set poss [list_cor [$object.options.list get 0 end] $list]
	foreach pos $poss {
		$object.options.list selection set $pos
	}
}

Classy::SelectDialog method clearselection {} {
	$object.options.list selection clear 0 end
}

proc Classy::select {title list args} {
	global Classy::temp
	destroy .classy__.select
	unset -nocomplain Classy::temp
	Classy::SelectDialog .classy__.select -title $title \
		-command {set Classy::temp} \
		-closecommand {destroy .classy__.select}
	if {[llength $args]} {
		array set a $args
		if {[info exists a(-initialvalue)]} {
			set preselect $a(-initialvalue)
			unset a(-initialvalue)
		}
		eval .classy__.select configure [array get a]
	}
	.classy__.select fill $list
	if {[info exists preselect]} {
		::update
		.classy__.select select $preselect
	}
	tkwait window .classy__.select
	if {![info exists Classy::temp]} {
		error "Nothing selected"
	}
	return $Classy::temp
}

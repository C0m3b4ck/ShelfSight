if { ![package vsatisfies [package provide Tcl] 8.5] } {package require dict}

# This is work in progress, and the api is not stable yet. Especially do not rely on the
# string representation to stay the same

proc table_update {tableVar} {
	upvar $tableVar table
	set fields [dict get $table fields]
	set fieldsi [list_merge $fields [list_fill [llength $fields] 0 1]]
	dict set table fieldsi $fieldsi
	if {![catch {dict keys $table index_*} indexes]} {
		foreach index $indexes {
			set field [string range $index 6 end]
			table_index table $field
		}
	}
	return $table
}

proc table_fieldpos {table field} {
	if {[catch {dict get $table fieldsi $field} fieldpos]} {
		if {[isint $field]} {return $field}
		return -1
	}
	return $fieldpos
}

proc Extral::table_fields_poss {table args} {
	if {[llength $args] == 1} {set args [lindex $args 0]}
	set result {}
	foreach field $args {
		lappend result [table_fieldpos $table $field]
	}
	return $result
}

proc table_index {tableVar field} {
	upvar $tableVar table
	set fieldpos [table_fieldpos $table $field]
	set index {}
	set num 0
	foreach value [lindex [dict get $table data] $fieldpos] {
		dict lappend index $value $num
		incr num
	}
	dict set table index_$field $index
	return $table
}

proc table_delindex {tableVar field} {
	upvar $tableVar table
	catch {dict unset table index_$field}
	return $table
}

proc table_fromlist {fields list} {
	set length [llength $fields]
	set data {}
	for {set i 0} {$i < $length} {incr i} {
		lappend data [list_subindex $list $i]
	}
	set table [dict create type table fields $fields data $data]
	if {[inlist $fields id]} {
		dict set table index_id {}
	}
	table_update table
}

proc table_tolist {table {fields {}} {poss {}}} {
	set result {}
	set len [table_size $table]
	set data [dict get $table data]
	if {![llength $fields]} {
		if {![llength $poss]} {
			for {set pos 0} {$pos < $len} {incr pos} {
				lappend result [list_subindex $data $pos]
			}
		} else {
			foreach pos $poss {
				lappend result [list_subindex $data $pos]
			}
		}
	} else {
		set fieldposs [Extral::table_fields_poss $table $fields]
		if {![llength $poss]} {
			for {set pos 0} {$pos < $len} {incr pos} {
				lappend result [list_subindex [list_sub $data $fieldposs] $pos]
			}
		} else {
			foreach pos $poss {
				lappend result [list_subindex [list_sub $data $fieldposs] $pos]
			}
		}
	}
	return $result
}

proc table_create {fields data} {
	set length [llength $fields]
	set dlen [llength $data]
	if {$dlen == 0} {
		set data [list_fill $length {}]
	} elseif {$dlen != $length} {
		error "number of columns in data differs from number of fields"
	}
	set table [dict create type table fields $fields data $data]
	if {[inlist $fields id]} {
		dict set table index_id {}
	}
	return [table_update table]
}

proc table_size {table} {
	llength [lindex [dict get $table data] 0]
}

proc table_fields {table} {
	dict get $table fields
}

proc table_get {table pos args} {
	if {[llength $args] == 1} {set args [lindex $args 0]}
	set line [list_subindex [dict get $table data] $pos]
	if {$args eq ""} {
		return [list_merge [dict get $table fields] $line]
	} elseif {$args eq "*"} {
		return $line
	} elseif {[llength $args] == 1} {
		set fieldpos [table_fieldpos $table [lindex $args 0]]
		return [lindex $line $fieldpos]
	} else {
		set fieldsposs [Extral::table_fields_poss $table $args]
		return [list_sub $line $fieldsposs]
	}
}

proc table_getid {table id args} {
	if {[llength $args] == 1} {set args [lindex $args 0]}
	set pos [dict get $table index_id $id]
	table_get $table $pos $args
}

proc table_col {table field} {
	set fieldpos [table_fieldpos $table $field]
	return [lindex [dict get $table data] $fieldpos]
}

proc table_find {table field operator pattern args} {
	if {![inlist {== !=} $operator]} {error "operator $operator not supported, must be one of: ==, !="}
	if {[catch {dict get $table index_$field} index]} {
		set poss [list_find [table_col $table $field] $pattern]
	} else {
		if {[catch {dict get $index $pattern} poss]} {
			set poss {}
		} else {
			set poss [lsort -integer $poss]
		}
	}
	if {![llength $args]} {
		return $poss
	} elseif {[llength $args] == 1} {
		return [list_sub [table_col $table [lindex $args 0]] $poss]
	} else {
		set fields [Extral::table_fields_poss $table $args]
		set result {}
		foreach pos $poss {
			lappend result [list_sub [list_subindex [dict get $table data] $pos] $fields]
		}
		return $result
	}
}

proc table_find {table field operator pattern args} {
	if {[string index $operator 0] eq "!"} {
		set invert 1
		set operator [string range $operator 1 end]
	} else {
		set invert 0
	}
	if {($operator eq "==") || ($operator eq "=")} {
		if {[catch {dict get $table index_$field} index]} {
			set poss [list_find [table_col $table $field] $pattern]
		} else {
			if {[catch {dict get $index $pattern} poss]} {
				set poss {}
			} else {
				set poss [lsort -integer $poss]
			}
		}
	} elseif {$operator eq "oneof"} {
		if {[catch {dict get $table index_$field} index]} {
			set col [table_col $table $field]
			set result {}
			foreach p $pattern {
				lappend result [list_find $col $p]
			}
			set poss [lsort -integer [list_remdup [list_concat $result]]]
		} else {
			set result {}
			foreach p $pattern {
				if {![catch {dict get $index $p} list]} {
					lappend result $list
				}
			}
			set poss [lsort -integer [list_remdup [list_concat $result]]]
		}
	} else {
		error "operator $operator not supported, must be one of: ==, !=, oneof, !oneof"
	}
	if {![llength $args]} {
		if {!$invert} {
			return $poss
		} else {
			return [list_lremove [list_fill [table_size $table] 0 1] $poss]
		}
	} elseif {[llength $args] == 1} {
		if {!$invert} {
			return [list_sub [table_col $table [lindex $args 0]] $poss]
		} else {
			return [list_sub [table_col $table [lindex $args 0]] -exclude $poss]
		}
	} else {
		if {$invert} {
			set poss [list_lremove [list_fill [table_size $table] 0 1] $poss]
		}
		set fields [Extral::table_fields_poss $table $args]
		set result {}
		foreach pos $poss {
			lappend result [list_sub [list_subindex [dict get $table data] $pos] $fields]
		}
		return $result
	}
}

proc table_set {tableVar pos args} {
	upvar $tableVar table
	if {[llength $args] == 1} {set args [lindex $args 0]}
	set fieldposs {}
	foreach {field value} $args {
		set fieldpos [table_fieldpos $table $field]
		if {$fieldpos == -1} {
			error "Field $field not present in table"
		}
		lappend fieldposs $fieldpos
	}
	foreach {field value} $args fieldpos $fieldposs {
		catch {set index [dict get $table index_$field]}
		if {[info exists index]} {
			set oldvalue [lindex [dict get $table data] $fieldpos $pos]
			if {![catch {dict get $index $oldvalue} list]} {
				set list [list_remove $list $pos]
				if {![llength $list]} {
					dict unset index $oldvalue
				} else {
					dict set index $oldvalue $list
				}
			}
		}
		dict set table data [lreplace [dict get $table data] $fieldpos $fieldpos [lreplace [lindex [dict get $table data] $fieldpos] $pos $pos $value]]
		if {[info exists index]} {
			dict lappend index $value $pos
			dict set table index_$field $index
		}
	}
	return $table
}

proc table_setid {tableVar id args} {
	upvar $tableVar table
	if {[llength $args] == 1} {set args [lindex $args 0]}
	if {![catch {dict get $table index_id $id} pos]} {
		table_set table $pos $args
	} else {
		lappend args id $id
		table_append table $args
	}
}

proc table_append {tableVar args} {
	upvar $tableVar table
	if {[llength $args] == 1} {set args [lindex $args 0]}
	array set a $args
	set fieldpos 0
	set pos [llength [lindex [dict get $table data] 0]]
	foreach field [dict get $table fields] {
		if {[info exists a($field)]} {set value $a($field)} else {set value {}}
		dict set table data [lreplace [dict get $table data] $fieldpos $fieldpos [linsert [lindex [dict get $table data] $fieldpos] end $value]]
		if {[dict exists $table index_$field]} {
			set index [dict get $table index_$field]
			dict lappend index $value $pos
			dict set table index_$field $index
		}
		incr fieldpos
	}
}

proc table_delete {tableVar args} {
	upvar $tableVar table
	if {[llength $args] == 1} {set args [lindex $args 0]}
	set fieldpos 0
	foreach field [dict get $table fields] {
		dict set table data [lreplace [dict get $table data] $fieldpos $fieldpos [list_sub [lindex [dict get $table data] $fieldpos] -exclude $args]]
		incr fieldpos
	}
	table_update table
}

proc table_deleteids {tableVar args} {
	upvar $tableVar table
	if {[llength $args] == 1} {set args [lindex $args 0]}
	set poss {}
	foreach id $args {
		lappend poss [dict get $table index_id $id]
	}
	table_delete table $poss
}

proc table_slice {table poss args} {
	if {[llength $args] == 1} {set args [lindex $args 0]}
	if {[llength $args]} {
		set fields $args
		set fieldsposs [Extral::table_fields_poss $table $args]
		set data [list_sub [list_subindex [dict get $table data] $poss] $fieldsposs]
	} else {
		set fields [dict get $table fields]
		set data [list_subindex [dict get $table data] $poss] 
	}
	set result [dict create type table fields $fields data $data]
	if {![catch {dict keys $table index_*} indexes]} {
		foreach index $indexes {
			set field [string range $index 6 end]
			if {[inlist $fields $field]} {
				dict set result $index {}
			}
		}
	}
	table_update result
}

proc table_existsid {table id} {
	dict exists $table index_id $id
}

proc table_addfield {tableVar field {def {}}} {
	upvar $tableVar table
	set pre [list_fill [table_size $table] $def]
	dict lappend table fields $field
	dict set table fieldsi $field [llength [dict get $table data]]
	dict lappend table data $pre
	return $table
}

proc table_delfield {tableVar field {def {}}} {
	upvar $tableVar table
	set fieldpos [table_fieldpos $table $field]
	dict set table data [list_sub [dict get $table data] -exclude $fieldpos]
	dict set table fields [list_remove [dict get $table fields] $field]
	dict unset table fieldsi $field
	catch {dict unset table index_$field}
	return $table
}

proc table_renamefield {tableVar field newfield} {
	upvar $tableVar table
	set fieldpos [table_fieldpos $table $field]
	dict set table fields [lreplace [dict get $table fields] $fieldpos $fieldpos $newfield]
	dict unset table fieldsi $field
	dict set table fieldsi $newfield $fieldpos
	return $table
}

proc table_reorderfields {tableVar fieldsnew} {
	upvar $tableVar table
	set fields [dict get $table fields]
	set fieldsnew [list_common $fieldsnew $fields]
	if {[llength $fieldsnew] != [llength $fields]} {
		error "error: not the same fields as in db"
	}
	set cor [list_cor $fields $fieldsnew]
	dict set table data [list_sub [dict get $table data] $cor]
	dict set table fields $fieldsnew
	dict set table fieldsi [list_merge $fieldsnew [list_fill [llength $fieldsnew] 0 1]]
	return $table
}

proc table_foreach {tableVar fields command {poss {}}} {
	upvar $tableVar table
	set fieldsposs [Extral::table_fields_poss $table $fields]
	if {$poss eq ""} {
		set code "foreach"
		foreach field $fields fpos $fieldsposs {
			append code " $field \[lindex \[dict get \$\{$tableVar\} data\] $fpos\]"
		}
		append code " \{$command\}"
	} else {
		set code "foreach"
		foreach field $fields fpos $fieldsposs {
			append code " $field \[list_sub \[lindex \[dict get \$\{$tableVar\} data\] $fpos\] [list $poss]]"
		}
		append code " \{$command\}"
	}
	uplevel $code
}

proc table_sort {table fields args} {
	set s [table_tolist $table $fields]
	set r [list_fill [llength $s] 0 1]
	set s [eval {ssort -reflist $s} $args {$r}]
	set data [dict get $table data]
	set newdata {}
	foreach col $data {
		lappend newdata [list_sub $col $s]
	}
	set newtable $table
	dict set newtable data $newdata
	table_update newtable
	return $newtable
}

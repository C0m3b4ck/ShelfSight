# Copyright (c) 1996 Peter De Rijk
#
# See the file "README.txt" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# =============================================================

#doc infocommands title {
#Info commands
#}

#doc {infocommands dirglob} cmd {
#	info_commands ?pattern?
#} descr {
#	returns a list of all available commands (matching the given pattern). Besides the
#	build in commands, and commands defined by proc, command that may be auto_loaded
#	are also listed.
#}
proc info_commands {{pattern *}} {
	global auto_index
	set result [info commands $pattern]
	if [regexp :: $pattern] {
		set add [array names auto_index [uplevel namespace current]$pattern]
	} else {
		set add ""
		foreach name [array names auto_index $pattern] {
			if ![regexp ^:: $name] {
				lappend add $name
			}
		}
	}
	return [list_union $result $add]
}

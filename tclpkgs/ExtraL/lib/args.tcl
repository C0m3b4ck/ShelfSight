#doc {cmd args_parse} cmd {
#	args_parse format vars args
#} descr {
#	parses the arguments given to a command, deals with options and optional arguments
#	
#}
proc args_parse {cmd options vars arg} {
	set pos 0
	set lengths {}
	set actualvars ""
	foreach var $vars {
		if [regexp {^\?} $var] {
			list_addnew lengths $pos
		}
		if [regexp {\?$} $var] {
			list_addnew lengths [expr {$pos+1}]
		}
		lappend actualvars [string trimright [string trimleft $var "?"] "?"]
		incr pos
	}
	set len [llength $arg]
	foreach num $lengths {
		if {$len == $num} {
			set actualvars [lrange $actualvars 0 [expr {$len-1}]]
			if $len {uplevel [list foreach $actualvars $arg {}]}
			return $len
		}
	}	
	if ![regsub @ $format $vars format] {
		set format "$format $vars"
	}
	return -code error "wrong # of args: should be \"$format\""
}


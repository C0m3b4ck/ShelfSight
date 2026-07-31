set [privatevar Classy::Progress w] .classy__.progress
set [privatevar Classy::Progress display] {}
set [privatevar Classy::Progress cdisplay] {}

Classy::Progress classmethod display {args} {
	private $class level transient display
	if {![llength $args]} {
		return $display
	} else {
		set display [lindex $args 0]
		if {$display ne ""} {
			if {![winfo exists $display]} {
				error "display widget $display does not exist"
			}
			if {[winfo class $display] ne "Classy::ProgressWidget"} {
				error "display widget $display is not a Classy::ProgressWidget"
			}
		}
	}
}

Classy::Progress classmethod _active {} {
	private $class cdisplay w
	if {$cdisplay ne ""} {
		set active [$cdisplay active]
	} else {
		set active [winfo exists $w]
	}
}

Classy::Progress classmethod start {steps {title {}} {message {}}} {
	private $class level transient w display cdisplay
	set cdisplay $display
	if {$display ne ""} {
		if {![winfo exists $display]} {
			error "display widget $display does not exist"
		}
		set w $display
	} else {
		set w .classy__.progress
	}
	set active [$class _active]
	if {![info exists level]} {
		set level -1
	}
	update idletasks
	if {($level == -1) && (!$active)} {
		$class reset
		if {$cdisplay eq ""} {
			Classy::ProgressDialog $w \
				-cancelcommand {Classy::Progress cancel}
			$w persistent add close
			Classy::busy add .
			Classy::busy remove $w
			if {[info exists transient]} {
				$class transient $transient
			}
		} else {
			Classy::busy add .
			Classy::busy remove $display
			$cdisplay start
		}
		set cdisplay $display
	} elseif {!$active} {
		$class _runcheck
	}
	incr level
	$w steps $level $steps
	if {$title ne ""} {
		$class title $title
	}
	$class message $message
}

Classy::Progress classmethod _runcheck {} {
	private $class level
	if {![info exists level] || ($level == -1)} {
		after idle [list $class reset]
		error "action was canceled"
	}
	if {![$class _active]} {
		private $class title
		after idle [list $class reset]
		error "$title canceled"
	}
}

Classy::Progress classmethod steps {{number {}}} {
	private $class level w
	$class _runcheck
	if {[isint $number]} {
		$w steps $level $number
	} else {
		lindex [$w cget -steps] $level
	}
}

Classy::Progress classmethod message {message} {
	private $class w
	$class _runcheck
	$w configure -message $message
}

Classy::Progress classmethod title {text} {
	private $class level title w
	$class _runcheck
	set title $text
	$w configure -title $text
}

Classy::Progress classmethod next {args} {
	private $class level w
	$class _runcheck
	set number ""
	foreach {number message} $args break
	if {![isint $number]} {
		set message $number
		set number 1
	}
	if {[get message ""] ne ""} {
		$w configure -message $message
	}
	set error [catch {
		$w next $level $number
	} e]
	if {$error} {
		after idle [list $class reset]
		if {$e eq "Progress canceled"} {
			private $class title
			error "$title canceled"
		} else {
			error $e
		}
	}
}

Classy::Progress classmethod set {{number 0}} {
	private $class level w
	$class _runcheck
	set error [catch {
		$w set $level $number
	} e]
	if {$error} {
		after idle [list $class reset]
		if {$e eq "Progress canceled"} {
			private $class title
			error "$title canceled"
		} else {
			error $e
		}
	}
}

Classy::Progress classmethod progress {} {
	private $class w
	$class _runcheck
	$w progress 
}

Classy::Progress classmethod stop {} {
	private $class level w
	$class _runcheck
	set max [$class steps]
	if {![isint $max]} {set max [llength $max]}
	$class set $max
	incr level -1
	if {$level == -1} {
		set title [$w cget -title]
		$class reset
		catch {$w configure -message "$title finished"}
	}
}

Classy::Progress classmethod on_error {args} {
	private $class level on_error
	if {[llength $args]} {
		set on_error [lindex $args 0]
	} else {
		return $on_error
	}
}

Classy::Progress classmethod reset {{error 0}} {
	private $class level title on_error w cdisplay
	set title "Progress"
	Classy::busy remove .
	if {$cdisplay eq ""} {
		destroy $w
	} else {
		if {[$w active]} {
			$w stop ""
		}
	}
	set level -1
	if {$error && ([get on_error ""] ne "")} {
		uplevel #0 $on_error
	}
}

Classy::Progress classmethod checkcancel {} {
	private $class w
	$class _runcheck
	set error [catch {
		$w checkcancel
	} e]
	if {$error} {
		Classy::busy remove .
		::Classy::cleartodo
		after idle [list $class reset]
		if {$e eq "Progress canceled"} {
			private $class title
			error "$title canceled"
		} else {
			error $e
		}
	}
}

Classy::Progress classmethod cancel {{message "Progress canceled"}} {
	private $class w cdisplay level
	Classy::busy remove .
	set level -1
	if {$cdisplay eq ""} {
		destroy $w
	} else {
		set title [$cdisplay cget -title]
		$cdisplay stop "$title canceled"
		$cdisplay.progress cancel
	}
}

Classy::Progress classmethod transient {window} {
	private $class transient w
	set transient $window
	catch {
		wm transient $w $window
		wm group $w $window
	}
}

Classy::Progress classmethod protect {code {on_error {}}} {
	set error [catch {uplevel 1 $code} result]
	if {$error} {
		$class reset
		if {$on_error eq ""} {
			set errorInfo $::errorInfo
			return -code error -errorinfo $errorInfo $result
		} else {
			set ::errorResult $result
			uplevel 1 $on_error
		}
	} else {
		return $result
	}
}

Classy::Progress classmethod refresh {{refresh {}}} {
	private $object w
	$class _runcheck
	if {[isint $refresh]} {
		$w configure -refresh $refresh
	} else {
		$w cget -refresh
	}
}

Classy::Progress classmethod level {} {
	private $class level
	get level -1
}

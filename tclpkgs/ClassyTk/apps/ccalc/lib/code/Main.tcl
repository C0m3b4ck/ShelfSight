proc main args {
	global data 
	mainw .mainw
	set data(level) 0
	set data(t,0) plus
	set data(new) 0
	set data(mem) 0
	set data(units) deg
	set data(inv) 0
	.mainw.entry nocmdset 0

}

proc buttonpress w {
global data
set window .mainw
regexp {[^.]+$} $w button
set labelw $window.opt.label
if [regexp {^n([0-9])$} $button temp num] {
	if {[$window.entry get] == 0} {setval $window {}}
	if $data(new) {
		setval $window {}
		set data(new) 0
	}
	$window.entry insert end $num
	$window.entry constrain
} elseif {"$button" == "ac"} {
	unset data
	set data(level) 0
	set data(t,0) plus
	set data(new) 0
	set data(mem) 0
	set data(units) deg
	set data(inv) 0
	setval $window 0
	$labelw configure -text "    DEG"
} elseif {"$button" == "cec"} {
	foreach name [array names data v,*] {
		catch {unset data($name)}
	}
	foreach name [array names data a,*] {
		catch {unset data($name)}
	}
	set data(t,0) plus
	set data(level) 0
	setval $window 0
	set data(new) 1
} elseif {"$button" == "inv"} {
	if $data(inv) {
		set data(inv) 0
		$labelw configure -text "    [string range [$labelw cget -text] 4 end]"
	} else {
		set data(inv) 1
		$labelw configure -text "INV [string range [$labelw cget -text] 4 end]"
	}
} else {
	set value [$window.entry get]
	if [info exists data(v,$data(level))] {
		set prevv $data(v,$data(level))
		set preva $data(a,$data(level))
		set prevt $data(t,$data(level))
		set prev 1
	} else {
		set prevt plus
		set prev 0
	}
	switch $button {
		is {
			while {$data(level) != 0} {
				calc
				decrlevel
			}
			calc
			catch {unset data(v,0)}
			catch {unset data(a,0)}
			set data(t,0) plus
			$labelw configure -text [string range [$labelw cget -text] 0 17]
		}
		parenl {
			if {$data(level) == 0} {
				$labelw configure -text "[string range [$labelw cget -text] 0 17] ()"
			}
			incr data(level)
			set data(t,$data(level)) paren
		}
		parenr {
			calc
			decrlevel
			if {$data(level) == 0} {
				$labelw configure -text [string range [$labelw cget -text] 0 17]
			}
		}
		plusminus {
			set value $value
			if [regexp {E\+} $value] {
				regsub {E\+} $value {E-} value
			} elseif [regexp {E-} $value] {
				regsub {E-} $value {E+} value
			} else {
				catch {expr {-$value}} value
			}
			setval $window $value
		}
		dec {
			$window.entry insert end .
		}
		ee {
			$window.entry insert end E+
		}
		sin - cos - tan {
			switch $data(units) {
				deg {
					set value [expr {$value*acos(-1)/180.0}]
				}
				grad {
					set value [expr {$value*acos(-1)/200.0}]
				}
			}
			if !$data(inv) {
				setval $window [expr "${button}($value)"]
			} else {
				setval $window [expr "a${button}($value)"]
			}
			set data(new) 1
		}
		log10 {
			if !$data(inv) {
				setval $window [expr "log10($value)"]
			} else {
				setval $window [expr {pow(10,$value)}]
			}
			set data(new) 1
		}
		log {
			if !$data(inv) {
				setval $window [expr "log($value)"]
			} else {
				setval $window [expr {pow(,$value)}]
			}
			set data(new) 1
		}
		sqrt {
			if !$data(inv) {
				setval $window [expr "sqrt($value)"]
			} else {
				setval $window [expr {pow($value,2)}]
			}
			set data(new) 1
		}
		pow2 {
			if !$data(inv) {
				setval $window [expr {pow($value,2)}]
			} else {
				setval $window [expr {sqrt($value)}]
			}
			set data(new) 1
		}
		fac {
			set r 1
			for {set i 2} {$i<=$value} {incr i} {
				set r [expr {$r*$i}]
			}
			setval $window $r
			set data(new) 1
		}
		over {
			setval $window [expr {1.0/$value}]
			set data(new) 1
		}
		pi {
			setval $window [expr acos(-1)]
			set data(new) 1
		}
		e {
			setval $window [expr pow(1000,1/(log(1000)))]
			set data(new) 1
		}
		sto {
			set data(mem) $value
			set data(new) 1
		}
		rcl {
			setval $window $data(mem)
			set data(new) 1
		}
		sum {
			set data(mem) [expr {$data(mem)+$value}]
			set data(new) 1
		}
		exc {
			set temp $value
			setval $window $data(mem)
			set data(mem) $temp
			set data(new) 1
		}
		plus {
			if ![inlist {plus minus paren} $data(t,$data(level))] {
				while 1 {
					calc
					decrlevel
					if {$data(level) == 0} break
					if [inlist {plus minus paren} $data(t,$data(level))] break
				}
			}
			calc
			set data(v,$data(level)) [$window.entry get]
			set data(a,$data(level)) $button
			set data(new) 1
		}
		minus {
			if ![inlist {plus minus paren} $data(t,$data(level))] {
				while 1 {
					calc
					decrlevel
					if {$data(level) == 0} break
					if [inlist {plus minus paren} $data(t,$data(level))] break
				}
			}
			calc
			set data(v,$data(level)) [$window.entry get]
			set data(a,$data(level)) $button
			set data(new) 1
		}
		times {
			if [inlist {plus minus paren} $prevt] {
				incr data(level)
				set data(v,$data(level)) [$window.entry get]
				set data(a,$data(level)) $button
				set data(t,$data(level)) times
				set data(new) 1
			} else {
				if {"$prevt" == "pow"} {
					calc
					decrlevel
					calc
					set data(v,$data(level)) [$window.entry get]
					set data(a,$data(level)) $button
					set data(new) 1
				}
				calc
				set data(v,$data(level)) [$window.entry get]
				set data(a,$data(level)) $button
				set data(new) 1
			}
		}
		div {
			if [inlist {plus minus paren} $prevt] {
				incr data(level)
				set data(v,$data(level)) [$window.entry get]
				set data(a,$data(level)) $button
				set data(t,$data(level)) times
				set data(new) 1
			} else {
				if {"$prevt" == "pow"} {
					calc
					decrlevel
					calc
					set data(v,$data(level)) [$window.entry get]
					set data(a,$data(level)) $button
					set data(new) 1
				}
				calc
				set data(v,$data(level)) [$window.entry get]
				set data(a,$data(level)) $button
				set data(new) 1
			}
		}
		pow {
			if [inlist {plus minus times div paren} $prevt] {
				incr data(level)
				set data(v,$data(level)) [$window.entry get]
				set data(a,$data(level)) $button
				set data(t,$data(level)) times
				set data(new) 1
			} else {
				calc
				set data(v,$data(level)) [$window.entry get]
				set data(a,$data(level)) $button
				set data(new) 1
			}
		}
		drg {
			switch $data(units) {
				deg {
					$labelw configure -text "        RAD      [string range [$labelw cget -text] 18 end]"
					set data(units) rad
					if $data(inv) {
						setval $window [expr {$value*acos(-1)/180.0}]
						set data(new) 1
					}
				}
				rad {
					$labelw configure -text "            GRAD [string range [$labelw cget -text] 18 end]"
					set data(units) grad
					if $data(inv) {
						setval $window [expr {$value*200.0/acos(-1)}]
						set data(new) 1
					}
				}
				grad {
					$labelw configure -text "    DEG          [string range [$labelw cget -text] 18 end]"
					set data(units) deg
					if $data(inv) {
						setval $window [expr {$value*180.0/200}]
						set data(new) 1
					}
				}
			}
		}
	}
}
if {("$button"!="inv") && ($data(inv))} {
	set data(inv) 0
	$labelw configure -text "    [string range [$labelw cget -text] 4 end]"
}
}

proc calc {} {
	global data
	set level $data(level)
	set window .mainw
	set value [$window.entry get]
	if [info exists data(v,$level)] {
		set prevv $data(v,$level)
		set preva $data(a,$level)
		set prevt $data(t,$level)
		set prev 1
	} else {
		set prev 0
	}
	if !$prev {
		catch {expr {$value}} r
		$window.entry set $r
		set data(new) 1
	} else {
		switch $preva {
			plus {catch {expr {$prevv+$value}} r}
			minus {catch {expr {$prevv-$value}} r}
			times {catch {expr {$prevv*$value}} r}
			div {catch {expr {$prevv/double($value)}} r}
			pow {catch {expr {pow($prevv,$value)}} r}
		}
		$window.entry set $r
		set data(new) 1
		unset data(v,$level)
		unset data(a,$level)
	}
	
}

proc decrlevel {} {
global data
if {$data(level) == 0} return
set level $data(level)
catch {unset data(v,$level)}
catch {unset data(a,$level)}
catch {unset data(t,$level)}
incr data(level) -1
}

proc setval {w value} {
$w.entry nocmdset [expr {$value}]
}


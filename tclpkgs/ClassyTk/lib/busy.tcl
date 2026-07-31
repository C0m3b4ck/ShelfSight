#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# busy command
# ----------------------------------------------------------------------

proc ::Classy::busy {{action {add}} args} {
	if [regexp {^\.} $action] {list_unshift args $action;set action add}
	if {"$args"==""} {
		set args .
	}
	switch $action {
		remove {
			if ![info exists ::Classy::busy] return
			foreach p $args {
				if {"$p"=="."} {
					set pattern $p*,c
				} else {
					set pattern $p.*,c
				}
				set list [lsort -decreasing [array names ::Classy::busy $pattern]]
				list_addnew list $p,c
				foreach w $list {
					regexp {^(.*),c$} $w temp w
					if {[info exists ::Classy::busy($w,c)]} {
						if {[winfo exists $w]} {
							catch {$w configure -cursor $::Classy::busy($w,c)}
						}
						unset ::Classy::busy($w,c)
					}
					if {[info exists ::Classy::busy($w,bt)]} {
						if {[winfo exists $w]} {
							bindtags $w $::Classy::busy($w,bt)
						}
						unset ::Classy::busy($w,bt)
					}
				}
				set e [catch {winfo parent $p} parent] 
				if {!$e && [info exists ::Classy::busy($parent,c)]} {
					if {[catch {$p cget -cursor} curcursor]} {set curcursor {}}
					if {"$curcursor"==""} {
						catch {$p configure -cursor arrow}
						set ::Classy::busy($p,c) {}
					}
				}
			}
			Classy::update Classy::busy-remove idletasks
		}
		add {
			Classy::update Classy::busy-add idletasks
			foreach p $args {
				if {[string_equal $p .]} {
					set pattern $p*
				} elseif {![catch {winfo ismapped $p} mapped] && $mapped} {
					set pattern $p.*
					if {![info exists ::Classy::busy($p,c)]} {
						if {[catch {$p cget -cursor} ::Classy::busy($p,c)]} {
							set ::Classy::busy($p,c) {}
						}
						catch {$p configure -cursor watch}
					}
					if {![info exists ::Classy::busy($p,bt)]} {
						set ::Classy::busy($p,bt) [bindtags $p]
						if {[lsearch -exact $::Classy::busy($p,bt) Classy::Balloon] == -1} {
							bindtags $p none
						} else {
							bindtags $p Classy::Balloon
						}
					}
				} else {
					continue
				}
				foreach w [lsort [info commands $pattern]] {
					if {[catch {winfo ismapped $w} mapped]} continue
					if {!$mapped} continue
					if {[winfo class $w] eq "Frame"} continue
					if {![info exists ::Classy::busy($w,c)]} {
						if {[catch {$w cget -cursor} ::Classy::busy($w,c)]} {
							set ::Classy::busy($w,c) {}
						}
						catch {$w configure -cursor watch}
					}
					if {![info exists ::Classy::busy($w,bt)]} {
						set ::Classy::busy($w,bt) [bindtags $w]
						if {[lsearch -exact $::Classy::busy($w,bt) Classy::Balloon] == -1} {
							bindtags $w none
						} else {
							bindtags $w Classy::Balloon
						}
					}
				}
			}
			Classy::update Classy::busy-add idletasks
		}
		status {
			if {"$args" == "."} {
				if {[llength [array names Classy::busy]]} {
					return 1
				} else {
					return 0
				}
			} else {
				if {[info exists Classy::busy([lindex $args 0],bt)]} {
					return 1
				} else {
					return 0
				}
			}
		}
		default {
			error "Unkown action $action: should be one of add, remove or status"
		}
	}
}


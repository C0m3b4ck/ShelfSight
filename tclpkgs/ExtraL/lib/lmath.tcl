# Copyright (c) 1996 Peter De Rijk
#
# See the file "README.txt" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# =============================================================
#doc lmath title {
#Mathematical commands on whole lists
#}

#doc {lmath lmath_cumul} cmd {
#	lmath_cumul ?list?
#} descr {
#	returns a list containing the cumulative sums of the numbers in the list
#}
proc lmath_cumul {args} {
	if {[llength $args]!=1} {
		error "wrong # args: should be \"lmath_cumul list\""
	}
	set prev 0
	foreach e1 [lindex $args 0]  {
		set prev [expr {$prev+$e1}]
		lappend result $prev
	}
	return $result
}

#doc {lmath lmath_incr} cmd {
#	lmath_incr ?list? ?value?
#} descr {
#	returns a list containing the numbers in the list incremented by value
#}
proc lmath_incr {args} {
	if {[llength $args]!=2} {
		error "wrong # args: should be \"lmath_incr list value\""
	}
	set result ""
	set incr [lindex $args 1]
	foreach e1 [lindex $args 0]  {
		lappend result [expr {$e1+$incr}]
	}
	return $result
}

#doc {lmath lmath_between} cmd {
#	lmath_between ?list? ?min? ?max?
#} descr {
#	returns a list containing the numbers in the list but with a minimum and maximum:
#	Any value higher than the maximum is changed to the maximum.
#	Any value lower than the minimum is changed to the minimum.
#}
proc lmath_between {args} {
	if {[llength $args]!=3} {
		error "wrong # args: should be \"lmath_between list min max\""
	}
	set result ""
	set min [lindex $args 1]
	set max [lindex $args 2]
	if {$max<$min} {
		return -code error "$max must be larger than $min"
	}
	foreach e1 [lindex $args 0]  {
		if {$e1<$min} {
			lappend result $min
		} elseif {$e1>$max} {
			lappend result $max
		} else {
			lappend result $e1
		}
	}
	return $result
}

#doc {lmath lmath_stdev} cmd {
#	lmath_stdev ?list? ??main??
#} descr {
#	returns the standard deviation of the numbers in the list.
#}
proc lmath_stdev {args} {
	set list [lindex $args 0]
	if {[llength $args] == 2} {
		set mean [lindex $args 1]
	} elseif {[llength $args] != 1} {
		error "wrong # args: should be \"lmath_dev list ?mean?\""
	} else {
		set mean [lmath_average $list]
	}
	set result 0.0
	foreach e1 $list  {
		set result [expr {$result+pow(($e1-$mean),2)}]
	}
	return [expr {sqrt($result/[llength $list])}]
}

#doc {lmath lmath_majority} cmd {
#	lmath_majority ?list?
#} descr {
#	returns the most representative of the numbers in the list.
#	This calculated by using gravity scoring: Each number in the list
#	adds to the score depending on the distance to the supported number
#	The number with the most support is returned.
#	Where more than one number gets the same amount of support (e.g. evenly spaced)
#	The average of the best supported numbers is returned
#}
proc lmath_majority {list} {
	set len [llength $list]
	if {$len == 1} {
		return [lindex $list 0]
	} elseif {$len == 2} {
		return [lmath_average $list]
	}
	set list [lsort -real $list]
	# check if first is equal to last, but take into account floating point generated differences
	if {[expr {abs([lindex $list 0] - [lindex $list end])}] < 0.001} {
		return [lindex $list 0]
	}
	# make histogram first
	set cur [lindex $list 0]
	set hlist $cur
	set num 0
	foreach n $list {
		if {[expr {abs($n - $cur)}] > 0.001} {
			lappend hlist $num
			lappend hlist $n
			set cur $n
			set num 1
		} else {
			incr num
		}
	}
	set temp [list_unmerge $hlist]
	set temp [lmath_calc [lrange $temp 1 end] - [lrange $temp 0 end-1]]
	set mindif [expr {[lmath_min $temp]*0.75}]
	lappend hlist $num
	# calculate score
	set result 0
	set max 0
	foreach v [list_remdup $list] {
#puts "--------------- $v -----------------"
		set score 0.0
		foreach {tv num} $hlist {
			set x [expr {abs($tv-$v)}]
			if {$x <= $mindif} {set x $mindif}
			set score [expr {$score+$num/pow($x,2)}]
#puts "$tv $x ($num) -> [expr {$num/pow($x,2)}]"
		}
		if {abs($score - $max) < 1.0E-5} {
			lappend result $v
		} elseif {$score > $max} {
			set max $score
			set result $v
		}
	}
	return [lmath_average $result]
}

#doc {lmath lmath_majoritydev} cmd {
#	lmath_majoritydev ?list? ?majority?
#} descr {
#	returns the most representative deviation of values in list 
#	from the given ?majority? number
#}
proc lmath_majoritydev {list majority} {
	set list [lsort -real $list]
	set vlist {}
	foreach v $list {
		lappend vlist [expr {abs($v-$majority)}]
	}
	set var [lmath_majority $vlist]
}


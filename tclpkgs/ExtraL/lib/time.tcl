# Tcl version of time_scan and time_format
#
# Copyright (c) 1997 Peter De Rijk
#
# See the file "README.txt" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# =============================================================
#doc time title {
#Date and time
#} shortdescr {
# extra commands for handling dates
#} descr {
#The time_scan transforms a string containing date and/or time into a 
#a list of two integers (number of days since 0, and number of miliseconds in that day). 
#These values can be sorted (-dictionary), compared or stored, and transformed back 
#into a human readable date and time string using the time_format command. The clock scan and
#format commands in Tcl give up before somewhere before 1901 and after
#2037, which is a bit of a bummer (eg. for genealogy). The transformation
#takes into account leap-years properly. However, it extrapolated
#the current rule to the past (so eg. 0004 BC is a leap year), and doesn't
#take into account the meddling that has happened to time over 
#time (missing days, ...) because this is nearly impossible to do
#correctly (I am not an historian).
#The format of the internal time has been changed since a previous version to using a 
#list of two integers instead of one double value because the accuracy was not good 
#enough to store miliseconds
#}

#doc {time time_scan} cmd {
#time_scan time ?date/time/both?
#} descr {
#	!! the year should be specified fully (>=4 numbers)
#} example {
#	% time_scan {9 May 1997 12:30}
#	729152 45000000
#}
proc time_scan {time {musthave date}} {
	foreach {var val} {
		bc 0 year -1 month -1 day -1 hour -1 min -1 sec -1 ms -1
		first -1 second -1 days -1 schrikkel 0
	} {
		set $var $val
	}
	switch $musthave {
		date {set musthavedate 1;set musthavetime 0}
		time {set musthavedate 0;set musthavetime 1}
		both {set musthavedate 1;set musthavetime 1}
	}
	set list [list_remove [split $time "/- _,"] {}]
	foreach item $list {
		switch -glob $item {
			{[0-9][0-9][0-9]*} {
				regexp {0*([0-9]+)(.*)} $item temp year temp
				if {[string match {[bB][cC]} $temp]} {set bc 1}
				if {"$year"==""} {set year 0}
			}
			{*:*} {
				set list [split $item ":."]
				foreach item $list var {hour min sec} {
					set $var [string trimleft $item 0]
				}
				set ms [lindex $list 3]
				set ms [string trimright $ms 0]
				if {[string length $ms]} {
					set level [expr {3-[string length $ms]}]
					set ms [expr {int([string trimleft $ms 0]*pow(10,$level))}]
				} else {
					set ms 0
				}
			}
			{[0-9]*} {
				set temp [string trimleft $item "0"]
				if {"$temp"==""} {set temp 0}
				if {$first == -1} {
					set first $temp
				} else {
					set second $temp
				}
			}
			{[bB][cC]} {
				set bc 1
			}
			default {
				if {$month == -1} {
					set month [lsearch {{} Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec} $item]
				}
			}
		}
	}
	if {$month == -1} {
		set month $first
		set day $second
	} else {
		set day $first
	}
	if $musthavedate {
		if {$year == -1} {error "no year found"}
		if {$month == -1} {error "no month found"}
		if {$day == -1} {error "no day found"} 
	}
	if $musthavetime {
		if {$hour == -1} {error "no hour found"}
		if {$min == -1} {error "no minutes found"}
	}
	foreach var {year month day} {
		if {[set $var] == -1} {set $var 1}
	}
	foreach var {hour min sec ms} {
		if {[set $var] == -1} {set $var 0}
		if {[set $var] == ""} {set $var 0}
	}
	if {($month<1)||($month>12)} {
		error "error while parsing date in \"$time\": invalid month"
	}
#puts "$year $month $day $hour:$min:$sec:$ms"
	# Start calculation
	if {$year == 0} {
		error "error while parsing date in \"$time\": (unfortunately) there is no year 0"
	} elseif $bc {
		set i $year
	} else {
		set i [expr {$year-1}]
	}
	set result [expr {$i*365+int($i/4)-int($i/100)+int($i/400)}]
	set schrikkel 0
	if {[expr {$year%4}] == 0} {
		if {([expr {$year%100}] != 0)||([expr {$year%400}] == 0)} {
			set schrikkel 1;
		}
	}
	if $bc {
		set result [expr {-$result}]
	}
	switch $month {
		1 {
			set days 31
		} 
		2 {
			set days [expr {28+$schrikkel}]
			incr result 31
		}
		3 {
			set days 31
			incr result [expr {59+$schrikkel}]
		}
		4 {
			set days 30
			incr result [expr {90+$schrikkel}]
		}
		5 {
			set days 31
			incr result [expr {120+$schrikkel}]
		}
		6 {
			set days 30
			incr result [expr {151+$schrikkel}]
		}
		7 {
			set days 31
			incr result [expr {181+$schrikkel}]
		}
		8 {
			set days 31
			incr result [expr {212+$schrikkel}]
		} 
		9 {
			set days 30
			incr result [expr {243+$schrikkel}]
		} 
		10 {
			set days 31
			incr result [expr {273+$schrikkel}]
		} 
		11 {
			set days 30
			incr result [expr {304+$schrikkel}]
		} 
		12 {
			set days 31
			incr result [expr {334+$schrikkel}]
		}
	}
	if {($day<1)||($day>$days)} {
		error "error while parsing date in \"$time\": invalid day"
	}
	incr result [expr {$day-1}]
	if {($hour<0)||($hour>23)} {
		set error "invalid hour"
	}
	if {($min<0)||($min>59)} {
		set error "invalid minutes"
	}
	if {$sec == -1} {set sec 0}
	if {($sec<0)||($sec>59)} {
		set error "invalid seconds"
	}
	if {$ms == -1} {set ms 0}
	if {($ms<0)||($ms>999)} {
		set error "invalid miliseconds"
	}
	if [info exists error] {
		return -code error "error while parsing time in \"$time\": $error"
	}
#puts "$days\n$year $month $day $hour:$min:$sec:$ms"
	return [list $result [expr {$hour*3600000 + $min*60000 + $sec*1000 + $ms}]]
}

#doc {time time_format} cmd {
#time_format time ?formatstring?
#} descr {
#	!! not all options of clock scan are supported
#<pre>
#	%% : %
#	%Y : year
#	%d : day (09)
#	%e : day (9)
#	%j : day of year
#	%m : month number
#	%b : abbreviated month name
#	%B : full month name
#	%H : hour
#	%M : minute
#	%S : second
#	%s : miliseconds
#</pre>
#} example {
#	% time_format {729152 45000000}
#	1997-05-09 12:30:00
#	% time_format {729152 45000000} "%B %e %Y"
#	May 9 1997
#}
proc time_format {time {format {%Y-%m-%d %H:%M:%S}}} {
	set bc 0
	if {[llength $time] == 1} {
		return [time_format_old $time $format]
	}
	foreach {date time} $time break
	if {$date<0} {
		set bc 1;
		set date [expr -$date]
	}
	set days $date
	# Start from something likely, try to add 1 year untill we get more days than given
	set year [expr int($date/365.25)]
	while 1 {
		set i [expr {$year+1}]
		set i [expr {$i*365+int($i/4)-int($i/100)+int($i/400)}]
		if $bc {
			if {$i>=$days} break
		} elseif {$i>$days} break
		incr year
	}
	# How many days left after substracting all the days in the years accounted for
	set days [expr $days - ($year*365+int($year/4)-int($year/100)+int($year/400))]
	incr year
	set schrikkel 0
	if {[expr $year%4] == 0} {
		if {([expr $year%100] != 0)||([expr $year%400] == 0)} {
			set schrikkel 1;
		}
	}
	if {$bc == 1} {
		set days [expr {365 + $schrikkel - $days + 1}]
	} else {
		incr days
	}
	if {$days>[expr {334+$schrikkel}]} {
		set day [expr {$days-(334+$schrikkel)}]
		set smonth "December";
		set month 12;
	} elseif {$days>[expr {304+$schrikkel}]} {
		set day [expr {$days-(304+$schrikkel)}]
		set smonth "November";
		set month 11;
	} elseif {$days>[expr {273+$schrikkel}]} {
		set day [expr {$days-(273+$schrikkel)}]
		set smonth "October"
		set month 10
	} elseif {$days>[expr {243+$schrikkel}]} {
		set day [expr {$days-(243+$schrikkel)}]
		set smonth "September"
		set month 9
	} elseif {$days>[expr {212+$schrikkel}]} {
		set day [expr {$days-(212+$schrikkel)}]
		set smonth "August"
		set month 8
	} elseif {$days>[expr {181+$schrikkel}]} {
		set day [expr {$days-(181+$schrikkel)}]
		set smonth "July"
		set month 7
	} elseif {$days>[expr {151+$schrikkel}]} {
		set day [expr {$days-(151+$schrikkel)}]
		set smonth "June"
		set month 6
	} elseif {$days>[expr {120+$schrikkel}]} {
		set day [expr {$days-(120+$schrikkel)}]
		set smonth "May"
		set month 5
	} elseif {$days>[expr {90+$schrikkel}]} {
		set day [expr {$days-(90+$schrikkel)}]
		set smonth "April"
		set month 4
	} elseif {$days>[expr {59+$schrikkel}]} {
		set day [expr {$days-(59+$schrikkel)}]
		set smonth "March"
		set month 3
	} elseif ($days>31) {
		set day [expr {$days-31}]
		set smonth "February"
		set month 2
	} else {
		set day $days
		set smonth "January"
		set month 1
	}
	# get time
	set seconds [expr {int($time/1000.0)}]
	set ms [expr {$time - $seconds*1000}]
	set hour [expr {int($seconds/3600.0)}]
	set seconds [expr {$seconds-($hour*3600.0)}]
	set min [expr {int($seconds/60.0)}]
	set seconds [expr {$seconds - ($min*60.0)}]
	set sec [expr {int($seconds)}]
	set seconds [expr {$seconds - $sec}]
	set buffer ""
	set pos 0
	set len [string length $format]
	while {$pos < $len} {
		set char [string index $format $pos]
		if {"$char" == "%"} {
			incr pos
			set char [string index $format $pos]
			switch $char {
				% {
					append buffer "%"
				}
				Y {
					append buffer [format "%4.4d" $year]
					if $bc {
						append buffer "BC"
					}
				}
				d {
					append buffer [format "%2.2d" $day]
				}
				e {
					append buffer $day
				}
				j {
					append buffer [format "%3.3d" $days]
				}
				m {
					append buffer [format "%2.2d" $month]
				}
				b {
					append buffer [format "%3.3s" $smonth]
				}
				B {
					append buffer [format "%s" $smonth]
				}
				H {
					append buffer [format "%2.2d" $hour]
				}
				M {
					append buffer [format "%2.2d" $min]
				}
				S {
					append buffer [format "%2.2d" $sec]
				}
				s {
					append buffer [format "%3.3d" $ms]
				}
				default {
					error "format option $char not supported"
				}
			}
		} else {
			append buffer $char
		}
		incr pos
	}
	return $buffer
}

proc time_format_old {time {format {%Y %b %d %H:%M:%S}}} {
	set bc 0
	if {[llength $time] == 2} {
		set ms [list_pop time]
	}
	if {$time<0} {
		set bc 1;
		set time [expr -$time]
	}
	set days [expr int($time/86400.0)]
	set year [expr int($days/365.25)]
	while 1 {
		set i [expr $year+1]
		set i [expr $i*365+int($i/4)-int($i/100)+int($i/400)]
		if $bc {
			if {$i>=$days} break
		} elseif {$i>$days} break
		incr year
	}
	set seconds [expr $time - $days*86400.0]
	set days [expr $days - ($year*365+int($year/4)-int($year/100)+int($year/400))]
	incr year
	set schrikkel 0
	if {[expr $year%4] == 0} {
		if {([expr $year%100] != 0)||([expr $year%400] == 0)} {
			set schrikkel 1;
		}
	}
	if {$bc == 1} {
		if {$seconds == 0} {
			set days [expr 365 + $schrikkel - $days + 1]
		} else {
			set days [expr 365 + $schrikkel - $days]
			set seconds [expr 86400.0 - $seconds]
		}
	} else {
		incr days
	}
	if {$days>[expr {334+$schrikkel}]} {
		set day [expr {$days-(334+$schrikkel)}]
		set smonth "December";
		set month 12;
	} elseif {$days>[expr {304+$schrikkel}]} {
		set day [expr {$days-(304+$schrikkel)}]
		set smonth "November";
		set month 11;
	} elseif {$days>[expr {273+$schrikkel}]} {
		set day [expr {$days-(273+$schrikkel)}]
		set smonth "October"
		set month 10
	} elseif {$days>[expr {243+$schrikkel}]} {
		set day [expr {$days-(243+$schrikkel)}]
		set smonth "September"
		set month 9
	} elseif {$days>[expr {212+$schrikkel}]} {
		set day [expr {$days-(212+$schrikkel)}]
		set smonth "August"
		set month 8
	} elseif {$days>[expr {181+$schrikkel}]} {
		set day [expr {$days-(181+$schrikkel)}]
		set smonth "July"
		set month 7
	} elseif {$days>[expr {151+$schrikkel}]} {
		set day [expr {$days-(151+$schrikkel)}]
		set smonth "June"
		set month 6
	} elseif {$days>[expr {120+$schrikkel}]} {
		set day [expr {$days-(120+$schrikkel)}]
		set smonth "May"
		set month 5
	} elseif {$days>[expr {90+$schrikkel}]} {
		set day [expr {$days-(90+$schrikkel)}]
		set smonth "April"
		set month 4
	} elseif {$days>[expr {59+$schrikkel}]} {
		set day [expr {$days-(59+$schrikkel)}]
		set smonth "March"
		set month 3
	} elseif ($days>31) {
		set day [expr {$days-31}]
		set smonth "February"
		set month 2
	} else {
		set day $days
		set smonth "January"
		set month 1
	}

	set hour [expr {int($seconds/3600.0)}]
	set seconds [expr {$seconds-($hour*3600.0)}]
	set min [expr {int($seconds/60.0)}]
	set seconds [expr {$seconds - ($min*60.0)}]
	set sec [expr {int($seconds)}]
	set seconds [expr {$seconds - $sec}]

	set buffer ""
	set pos 0
	set len [string length $format]
	while {$pos < $len} {
		set char [string index $format $pos]
		if {"$char" == "%"} {
			incr pos
			set char [string index $format $pos]
			switch $char {
				% {
					append buffer "%"
				}
				Y {
					append buffer [format "%4.4d" $year]
					if $bc {
						append buffer "BC"
					}
				}
				d {
					append buffer [format "%2.2d" $day]
				}
				e {
					append buffer $day
				}
				j {
					append buffer [format "%3.3d" $days]
				}
				m {
					append buffer [format "%2.2d" $month]
				}
				b {
					append buffer [format "%3.3s" $smonth]
				}
				B {
					append buffer [format "%s" $smonth]
				}
				H {
					append buffer [format "%2.2d" $hour]
				}
				M {
					append buffer [format "%2.2d" $min]
				}
				S {
					append buffer [format "%2.2d" $sec]
				}
				s {
					append buffer [format "%2.2d" $ms]
				}
				default {
					error "format option $char not supported"
				}
			}
		} else {
			append buffer $char
		}
		incr pos
	}
	return $buffer
}

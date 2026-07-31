#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Classy::Printer
# ----------------------------------------------------------------------
#doc Printer title {
#Classy::Printer
#} index {
# Printer
#} shortdescr {
# manage printers / printing
#} descr {
# The command (class) Classy::Printer is used to manage printing. It can be used to open a printer
# call up a printing dialog, print, ...
#}

Class subclass Classy::Printer
set Classy::simagefailed [catch {package require simage}]

catch {canvas .classy__.printcanvas}
catch {Classy::PagedCanvas .classy__.printpcanvas}
catch {pack .classy__.printcanvas}

Classy::Printer method init {args} {
	super init frame
	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
	private $class prescale
	set prescale 10
	return $object
}

#doc {Printer pagesize} cmd {
# Classy::Printer pagesize media
#} descr {
# return the width and height of the media (media is given as e.g. A4)
#}
Classy::Printer classmethod pagesize {{pagesize {}} {orientation portrait}} {
	if {$pagesize eq ""} {
		set pagesize [$class configure -pagesize]
		set orientation [$class configure -orientation]
	}
	array set pagesizes [Classy::optionget . paperSizes PaperSizes]
	if {[info exists pagesizes($pagesize)]} {
		set size $pagesizes($pagesize)
	} elseif {[info exists pagesizes([string toupper $pagesize])]} {
		set size $pagesizes([string toupper $pagesize])
	} else {
		set size $pagesize
	}
	set orientation [string tolower $orientation]
	if {$orientation eq "landscape"} {
		foreach {w h} $size break
		set size [list $h $w]
	} elseif {$orientation ne "portrait"} {
		error "unknown orientation $orientation"
	}
	return $size
}

#doc {Printer media} cmd {
# Classy::Printer media {width height}
#} descr {
# return the media (e.g. A4) given the pagesize (= a list of width and height)
#}
Classy::Printer classmethod media {pagesize} {
	if {[llength $pagesize] == 1} {return $pagesize}
	foreach {w h} $pagesize break
	set pw [winfo fpixels .classy__.printcanvas $w]
	set ph [winfo fpixels .classy__.printcanvas $h]
	if {$pw > $ph} {
		set temp $ph
		set ph $pw
		set pw $temp
	}
	foreach {name size} [Classy::optionget . paperSizes PaperSizes] {
		foreach {w h} $size break
		set w [winfo fpixels .classy__.printcanvas $w]
		set h [winfo fpixels .classy__.printcanvas $h]
		set wdiff [expr {abs($w-$pw)}]
		set hdiff [expr {abs($h-$ph)}]
		if {($wdiff < 1) && ($hdiff < 1)} {
			return $name
		}
	}
	return $pagesize
}

#doc {Printer printhtml} cmd {
# Classy::Printer printhtml ?options?
#} descr {
# prints html to the currently opened printer
#}
Classy::Printer classmethod printhtml {args} {
	private $class pagenum pages pdata prescale
	set pagesize [Classy::Printer pagesize]
	array set opt {
		-css {}
		-margin-top 2c -margin-right 2c -margin-bottom 2c -margin-left 2c
		-imagecmd {} -scale fit
	}
	cmd_args [list $class printhtml] {
		-css {any "base css used for rendering"}
		-margin-top {size "top margin"}
		-margin-right {size "right margin"}
		-margin-bottom {size "bottom margin"}
		-margin-left {size "left margin"}
		-imagecmd {any "will be called for rerendering images with parameters: canvas x y width height scale image"}
		-url {url "url to be printed"}
		-html {html "html to be printed"}
		-file {filename "file to be printed"}
		-scale {any "how to scale if printregion and page do not match: \"fit\" or number giving scale"}
	} {} $args
	if {[info exists opt(-url)]} {
		set type -url
		set src $opt(-url)
	} elseif {[info exists opt(-html)]} {
		set type -html
		set src $opt(-html)
	} elseif {[info exists opt(-file)]} {
		set type -file
		set src $opt(-file)
	} else {
		error "one of the options -url, -html, -file must be given"
	}
	.classy__.printpcanvas delete all
	Classy::Progress start 2 "Printing"
	Classy::Progress message "Printing"
	if {$::tcl_platform(platform) eq "windows"} {
		set prescale 10
	} else {
		set prescale 1
	}
	Classy::html2canvas .classy__.printpcanvas $type $src \
		-page $pagesize -scale $prescale \
		-margin-top $opt(-margin-top) -margin-right $opt(-margin-right) \
		-margin-bottom $opt(-margin-bottom) -margin-left $opt(-margin-left) \
		-imagecmd $opt(-imagecmd) -css $opt(-css)
	Classy::Progress next
	$class printpagedcanvas -scale $opt(-scale) .classy__.printpcanvas
	set prescale 10
	Classy::Progress stop
}

Classy::Printer classmethod printpagedcanvas {args} {
	array set opt {-scale fit -pages all -pagecommand {} -changepagesize 0 -changeorientation 0}
	cmd_args [list $class printpagedcanvas] {
		-scale {any "how to scale if printregion and page do not match: \"fit\" or number giving scale"}
		-pages {list "pages to print"}
		-pagecommand {command "command to execute on starting each page (pagenumber will be added to parameters)"}
		-changepagesize {switch "printpagedcanvas changes the pagesize according to the page currently being processed"}
		-changeorientation {switch "printpagedcanvas changes the orientation according to the page currently being processed"}
	} {canvas} $args
	set page 1
	foreach {prevmedia prevorient} [$canvas pageinfo $page] break
	if {$opt(-changepagesize)} {
		$class configure -pagesize $prevmedia
	}
	if {$opt(-changeorientation)} {
		$class configure -orientation $prevorient
	}
	set pages [$canvas find withtag _paper]
	Classy::Progress start [llength $pages] "Printing"
	while 1 {
		Classy::Progress message "Printing page $page"
		if {[catch {$canvas _scaled_coords page_$page} coords]} {
			set coords [$canvas coords page_$page]
		}
		if {![llength $coords]} break
		foreach {media orient} [$canvas pageinfo $page] break
		if {$opt(-changepagesize)} {
			$class configure -pagesize $media
		}
		if {$opt(-changeorientation)} {
			$class configure -orientation $orient
		}
		eval $canvas dtag _print_
		eval $canvas addtag _print_ enclosed $coords
		if {($opt(-pages) eq "all") || [inlist $opt(-pages) $page]} {
			if {$opt(-pagecommand) ne ""} {
				eval $opt(-pagecommand) $page
			}
			$class printcanvas -printregion $coords -scale $opt(-scale) -tag _print_ $canvas
		}
		incr page
		Classy::Progress next
	}
	Classy::Progress stop
}

if 0 {
	toplevel .t
	canvas .t.try
	.t.try configure -yscrollcommand {.t.vbar set} -xscrollcommand {.t.hbar set}
	scrollbar .t.vbar -command {.t.try yview}
	scrollbar .t.hbar -command {.t.try xview} -orient horizontal
	grid .t.try .t.vbar -sticky nwse
	grid .t.hbar -sticky nwse
	grid columnconfigure .t 0 -weight 1
	grid rowconfigure .t 0 -weight 1
	set d .t.try
	set region [.try cget -scrollregion]
}

Classy::Printer classmethod _copycanvas {w region scale {tag all}} {
	global Classy::simagefailed
	set d .classy__.printcanvas
	$d delete all
	if {[llength $region]} {
		set ids [eval {$w find overlapping} $region]
		if {$tag ne "all"} {
			set ids [list_common $ids [$w find withtag $tag]]
		}
	} elseif {$tag ne "all"} {
		set ids [$w find withtag $tag]
	} else {
		set ids [$w find all]
	}
	foreach id $ids {
		set cmd [list $d create]
		set type [$w type $id]
		set optlist [$w itemconfigure $id]
		switch $type {
			window continue
			image {
				if {!$Classy::simagefailed} {
					eval $cmd simage [$w coords $id] [list_concat [list_subindex $optlist 0 4]]
					continue
				}
			}
		}
		eval lappend cmd $type [$w coords $id]
		unset -nocomplain opts
		foreach opt $optlist {
			set key [lindex $opt 0]
			set value [lindex $opt end]
			if {$key eq "-width"} {
				set value [expr {[winfo fpixels $w $value]*$scale}]
			} elseif {$key eq "-height"} {
				set value [expr {[winfo fpixels $w $value]*$scale}]
			} elseif {$key eq "-font"} {
				set value [Classy::zoomfont $value $scale]
			}
			lappend cmd $key $value
		}
		eval $cmd
	}
	$d scale all 0 0 $scale $scale
	if 0 {
		set newscrollregion {}
		foreach v [$w cget -scrollregion] {
			regexp {^([0-9.]+)(.*)$} $v temp n unit
			lappend newscrollregion [expr {$n*$scale}]$unit
		}
		$d configure -scrollregion $newscrollregion
	}
}

#doc {Printer list} cmd {
# Classy::Printer list
#} descr {
# returns available printers
#}

#doc {Printer pagesizes} cmd {
# Classy::Printer pagesizes
#} descr {
# returns available pagesizes
#}

#doc {Printer dialog} cmd {
# Classy::Printer dialog
#} descr {
# open print dialog
#}

#doc {Printer configure} cmd {
# Classy::Printer configure ?options?
#} descr {
# configure print settings
#}

#doc {Printer open} cmd {
# Classy::Printer open printer
#} descr {
# open printer for sending print data
#}

#doc {Printer printcanvas} cmd {
# Classy::Printer printcanvas ?options?
#} descr {
# print a canvas to the opened printer
#}

if {"[info commands Classy::Export]" != ""} {
# ------------------------------ Classy::Export ------------------------------
source [file join $::Classy::dir widgets Printer-Windows.tcl]
} else {
# ------------------------------ no Classy::Export ------------------------------
source [file join $::Classy::dir widgets Printer-Unix.tcl]
}

Classy::Printer classmethod clearspool {} {
	private $class pagenum
	file mkdir [tempdir]/spool
	catch {eval file delete [glob [tempdir]/spool/*]}
	set pagenum 1
}

Classy::Printer classmethod ps_printcanvas {args} {
	private $class pagenum pages pdata
	array set opt {-scale fit -tile 0 -margins {0 0 0 0} -tag all -colormode color}
	cmd_args [list $class printcanvas] {
		-printregion {{x1 y1 x2 x2} "region of canvas to print"}
		-scale {any "how to scale if printregion and page do not match: \"fit\" or number giving scale"}
		-tile {switch "tile if does not fit page"}
		-margins {{ml mt mr mb} "margins: left, top, right, bottom"}
		-tag {any "only print canvas objects with the given tag"}
		-colormode {{oneof color mono} "print using color or B&W"}
	} {canvas} $args
	if {![info exists opt(-printregion)]} {
		set opt(-printregion) [$canvas cget -scrollregion]
	}
	if {[llength $opt(-printregion)] != 4} {
		set opt(-printregion) [$canvas bbox $opt(-tag)]
	}
	if {[llength $opt(-printregion)] != 4} {
		set opt(-printregion) {0 0 595p 842p}
	}
	if {![info exists pagenum]} {
		error "Classy::Printer dialog needs to be called first"
	}
	if {$opt(-tag) ne "all"} {
		$class _copycanvas $canvas {} 1 $opt(-tag)
		set canvas .classy__.printcanvas
	}
	foreach {pw ph} [$class pagesize [$class configure -pagesize] [$class configure -orientation]] break
	set pw [winfo fpixels $canvas $pw]
	set ph [winfo fpixels $canvas $ph]
	foreach {ox oy x2 y2} $opt(-printregion) break
	set ox [expr {round([winfo fpixels $canvas $ox])}]
	set oy [expr {round([winfo fpixels $canvas $oy])}]
	set x2 [winfo fpixels $canvas $x2]
	set y2 [winfo fpixels $canvas $y2]
	if {$opt(-scale) eq "fit"} {
		set scalex [expr {round(100*$pw/($x2-$ox))/100.0}]
		set scaley [expr {round(100*$ph/($y2-$oy))/100.0}]
		if {$scalex < $scaley} {
			set scaley $scalex
		} elseif {$scaley < $scalex} {
			set scalex $scaley
		}
	} elseif {[isdouble $opt(-scale)]} {
		set scalex $opt(-scale)
		set scaley $opt(-scale)
	} else {
		error "-scale option must be \"fit\" or a number"
	}
	set canvasw [expr {$pw/$scalex}]
	set canvash [expr {$ph/$scaley}]
	set pagewidth [expr {$pw/[winfo fpixels $canvas 1p]}]
	set pageheight [expr {$ph/[winfo fpixels $canvas 1p]}]
	if {$opt(-tile)} {
		set scaledw [expr {($x2-$ox)*$scalex}]
		set scaledh [expr {($y2-$oy)*$scaley}]
		if {($scaledw < $pw) && ($scaledh < $ph)} {
			set opt(-tile) 0
		}
	}
	if {!$opt(-tile)} {
		set f [open [tempdir]/spool/$pagenum.eps w]
		if {$pw < $ph} {
			set rotate 0
			$canvas postscript -channel $f \
				-x $ox -y $oy \
				-width $canvasw -height $canvash \
				-rotate $rotate -colormode $opt(-colormode) \
				-pageanchor center -pagex [expr {$pagewidth/2}]p -pagey [expr {$pageheight/2}]p \
				-pagewidth ${pagewidth}p
		} else {
			set rotate 1
			$canvas postscript -channel $f \
				-x $ox -y $oy \
				-width $canvasw -height $canvash \
				-rotate $rotate -colormode $opt(-colormode) \
				-pageanchor center -pagex [expr {$pageheight/2}]p -pagey [expr {$pagewidth/2}]p \
				-pagewidth ${pagewidth}p
		}
		close $f
		incr pagenum
	} else {
		if {$pw < $ph} {
			set rotate 0
		} else {
			set rotate 1
		}
		foreach {ml mt mr mb} $opt(-margins) break
		set ml [winfo fpixels $canvas $ml]
		set mt [winfo fpixels $canvas $mt]
		set mr [winfo fpixels $canvas $mr]
		set mb [winfo fpixels $canvas $mb]
		set overlapx [expr {round(($ml+$mr+[winfo fpixels $canvas 1c])/$scalex)}]
		if {$overlapx < 5} {set overlapx 5}
		set stepx [expr {round($pw/$scalex-$overlapx)}]
		set overlapy [expr {round(($mt+$mb+[winfo fpixels $canvas 1c])/$scaley)}]
		if {$overlapy < 5} {set overlapy 5}
		set stepy [expr {round($ph/$scaley-$overlapy)}]
		for {set y $oy} {$y < $y2} {incr y $stepy} {
			for {set x $ox} {$x < $x2} {incr x $stepx} {
				set f [open [tempdir]/spool/$pagenum.eps w]
				$canvas postscript -channel $f \
					-x $x -y $y \
					-width $canvasw -height $canvash \
					-rotate $rotate -colormode $opt(-colormode) \
					-pageanchor center -pagex [expr {$pagewidth/2}]p -pagey [expr {$pageheight/2}]p \
					-pagewidth ${pagewidth}p
				close $f
				incr pagenum
			}
		}
	}
}

Classy::Printer classmethod StripPSComments {PSString} {
# Procedure: StripPSComments
  set EOC [string first "%%BeginProlog\n" "$PSString"]
  set EOF [expr [string first "%%EOF\n" "$PSString"] - 1]
  set PSString [string range $PSString $EOC $EOF]
  set result {}
  foreach l [split "$PSString" "\n"] {
#    puts stderr "*** StripPSComments: l = $l"
    set i [string first "%" "$l$"]
    if {$i == 0} {
#      puts stderr "*** replaced with newline"
      set result "$result\n"
    } elseif {$i > 0 && [regexp {(^.*[^\\])(%.*$)} "$l" whole prefix comment]} {
#      puts stderr "*** replaced with $prefix"
      set result "$result$prefix\n"
    } else {
      set result "$result$l\n"
    }
  }
  return "$result"
}

Classy::Printer classmethod strip_postscript {postscript} {
	set start [string first "%%BeginProlog\n" "$postscript"]
	set end [expr [string first "%%EOF\n" "$postscript"] - 1]
	set postscript \n[string range $postscript $start $end]\n
	regsub -all {\n%[^\n]*} $postscript {} postscript
	return $postscript
}

set Classy::Printer_preps {
/BeginEPSF { %def
  /b4_Inc_state save def                       % Save state for cleanup
  /dict_count countdictstack def               % Count objects on dict stack
  /op_count count 1 sub def                    % Count objects on operand stack
  userdict begin                               % Push userdict on dict stack
  /showpage { } def                            % Redefine showpage, { } = null proc
  /erasepage { } def
  /copypage { } def
  0 setgray 0 setlinecap                       % Prepare graphics state
  1 setlinewidth 0 setlinejoin
  10 setmiterlimit [ ] 0 setdash newpath
  /languagelevel where                         % If level not equal to 1 then
  {pop languagelevel                           % set strokeadjust and
  1 ne                                         % overprint to their defaults.
     {false setstrokeadjust false setoverprint
     } if
  } if
} bind def
/EndEPSF { %def
  count op_count sub {pop} repeat            % Clean up stacks
  countdictstack dict_count sub {end} repeat
  b4_Inc_state restore
} bind def
}

Classy::Printer classmethod ps_print {o args} {
	private $class pdata optpdata
	array set options $args
	set pages [lsort -dictionary [glob -nocomplain [tempdir]/spool/*]]
	if {![llength $pages]} return
	set eps [file_read [lindex $pages 0]]
	regexp {%%BoundingBox: [-0-9.]+ [-0-9.]+ ([-0-9.]+ +[-0-9.]+)} $eps temp pagesize
	regexp {%%Orientation: ([A-Za-z]+)} $eps temp orientation
	foreach {pw ph} $pagesize break
	puts $o "%!PS-Adobe-3.0"
	puts $o "%%Creator: ClassyTk"
	puts $o "%%Title: [get options(-title) printout]"
	puts $o "%%CreationDate: [clock format [clock seconds]]"
	puts $o "%%Pages: [llength $pages]"
	puts $o $::Classy::Printer_preps
	# this is supposed to take care of the  font scaling problem
	puts $o "/scalefont \{[tk scaling] mul scalefont\} bind def"
#	if {$::tcl_platform(platform) eq "windows"} {
#		puts $o "/scalefont \{[tk scaling] mul scalefont\} bind def"
#	}
	puts $o "%%EndProlog"
	#
	puts $o "%%BeginSetup"
	puts $o "\[\{"
	puts $o "%%BeginFeature: *PageSize $pagesize"
	if {$orientation eq "portrait"} {
		puts $o "<</PageSize \[$pw $ph\]/ImagingBBox null /Orientation 3 >>setpagedevice"
	} else {
		puts $o "<</PageSize \[$pw $ph\]/ImagingBBox null >>setpagedevice"
	}
	puts $o "%%EndFeature"
	puts $o "\} stopped cleartomark"
	puts $o "%%EndSetup"
	#
	set page 1
	foreach file $pages {
		set eps [file_read $file]
		regexp {%%BoundingBox: 0 0 ([0-9.]+ +[0-9.]+)} $eps temp pagesize
		regexp {%%Orientation: ([A-Za-z]+)} $eps temp orientation
		set orientation [string tolower $orientation]
		set eps [$class strip_postscript $eps]
		puts $o "%%Page: $page $page"
		puts $o "%%PageBoundingBox: 0 0 $pagesize"
		puts $o "%%Orientation: $orientation"
		puts $o "%%BeginPageSetup"
		puts $o "%%BeginFeature: *PageSize $pagesize"
		if {$orientation eq "portrait"} {
			puts $o "<</PageSize \[$pagesize\] >>setpagedevice"
		} else {
			puts $o "<</PageSize \[$pagesize\] /Orientation 3 >>setpagedevice"
		}
		puts $o "%%EndFeature"
		puts $o "%%EndPageSetup"
		puts $o "BeginEPSF"
		puts $o "%%BeginDocument: page $page"
		puts $o $eps
		puts $o "%%EndDocument"
		puts $o "EndEPSF"
		puts $o "showpage"
		incr page
	}
	puts $o "%%EOF"
	close $o
}

Classy::Printer classmethod postscript {{file {}}} {
	private $class pdata
	if {$file eq ""} {
		set file [Classy::savefile -title "Export to postscript"]
	}
	if {$file eq ""} return
	$class clearspool
	set pdata(-printer) "Print to file"
	set pdata(-file) $file
}

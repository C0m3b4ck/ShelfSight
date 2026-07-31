if {"[info commands Classy::Export]" == ""} {

Classy::Printer classmethod list {args} {
	private $class printers
	if {[info exists printers]} {
		return $printers
	}
	if {![catch {Extral::bgexec -timeout 500 lpstat -s} c]} {
		list_unmerge [regexp -all -inline {device for ([^:]+):} $c] 1 result
		if {![llength $result]} {return ""}
		regexp {default destination: ([^\n]+)} $c temp default
		set printers [list_union $default $result]
	} else {
		return ""
	}
	return $printers
}

#sides one-sided two-sided-short-edge two-sided-long-edge

Classy::Printer classmethod _initpdata {} {
	private $class pagenum pdata
	unset -nocomplain pdata
	array set pdata {
		-pagesize A4
		-colormode color
		-printcommand "lp -d %p -o media=%m"
		-file print.ps
		-orientation portrait
	}
	set pdata(-printer) [lindex [lindex [$class list] 0]]
}

Classy::Printer classmethod pagesizes {{printer {}}} {
	if {$printer eq ""} {
		return [list_unmerge [Classy::optionget . paperSizes PaperSizes]]
	}
	private $class pagesizes
	$class _printeroptions $printer
	return $pagesizes($printer)
}

Classy::Printer classmethod _printeroptions {printer} {
	private $class printeropts pagesizes
	if {![info exists printeropts($printer)]} {
		set printeropts($printer) {}
		if {![catch [list exec lpoptions -p $printer -l] c]} {
			foreach line [split $c \n] {
				if {![regexp {^([^/]+)/([^:]+): (.*)$} $line temp option name choices]} continue
				set pos [list_find -regexp $choices {\*.*}]
				if {![isint $pos]} {
					set default [lindex $choices 0]
				} else {
					set default [string range [lindex $choices $pos] 1 end]
					set choices [lreplace $choices $pos $pos $default]
				}
				lappend printeropts($printer) [list $option $name $choices $default]
				if {$option eq "PageSize"} {
					set choices [list_remove $choices $default]
					set pagesizes($printer) [list_concat $default $choices]
				}
			}
		}
	}
	return $printeropts($printer)
}

Classy::Printer classmethod open {{printer {}}} {
	private $class pdata
	$class clearspool
	if {$printer eq ""} {set printer [get pdata(-printer) [lindex [$class list] 0]]}
	set pdata(-printer) $printer
}

Classy::Printer classmethod configure {args} {
	private $class pdata
	if {![llength $args]} {
		return [array get pdata]
	} elseif {[llength $args] == 1} {
		return $pdata([lindex $args 0])
	} else {
		foreach {key value} $args {
			if {![info exists pdata($key)]} {error "Unknown option $key"}
			set pdata($key) $value
		} 
	}
}

Classy::Printer classmethod dialog {args} {
	private $class pdata go
	set go 0
	$class clearspool
	if [winfo exists .classy__.printdialog] {
		destroy .classy__.printdialog
	}
	Classy_printdialog .classy__.printdialog
	tkwait window .classy__.printdialog
	return $go
}


Classy::Printer classmethod printcanvas {args} {
	private $class pagenum pdata
	eval $class ps_printcanvas -colormode $pdata(-colormode) $args
}

Classy::Printer classmethod print {args} {
	private $class pagenum pdata optpdata
	array set options $args
	if {$pdata(-printcommand) eq ""} {
		set pdata(-printcommand) "lp -d %p -o media=%m"
	}
	set pages [lsort -dictionary [glob -nocomplain [tempdir]/spool/*]]
	if {![llength $pages]} return
	set eps [file_read [lindex $pages 0]]
	regexp {%%BoundingBox: [-0-9.]+ [-0-9.]+ ([-0-9.]+ +[-0-9.]+)} $eps temp pagesize
	regexp {%%Orientation: ([A-Za-z]+)} $eps temp orientation
	foreach {pw ph} $pagesize break
	if {$pdata(-printer) eq "Print to file"} {
		set o [open $pdata(-file) w]
	} else {
		# set o [open "|kprinter --stdin" w]
		set media [$class media $pagesize]
		if {[llength $media] == 2} {set media A4}
		set cmd [string_change "$pdata(-printcommand)" [list %p $pdata(-printer) %m $media]]
		if {[string range $cmd 0 2] eq "lp "} {
			foreach line [$class _printeroptions $pdata(-printer)] {
				set option [lindex $line 0]
				if {[info exists optpdata($option)]} {
					append cmd " -o $option=$optpdata($option)"
				}
			}
		}
		set o [open "|$cmd" w]
	}
	eval $class ps_print $o $args
}

Classy::Printer _initpdata

}


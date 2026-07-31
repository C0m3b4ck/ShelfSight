Classy::Dialog subclass Classy_printdialog
Classy_printdialog method init args {
	super init
	# Create windows
	Classy::Entry $object.options.entry1 \
		-label label \
		-width 4
	
	Classy::Entry $object.options.entry2 \
		-label label \
		-width 4
	
	Classy::Entry $object.options.entry3 \
		-label label \
		-width 4
	
	entry $object.options.entry4 \
		-width 4
	
	frame $object.options.frame1  \
		-borderwidth 2 \
		-relief groove \
		-height 10 \
		-width 10
	
	label $object.options.label1 \
		-anchor w \
		-text Printer
	grid $object.options.label1 -row 0 -column 0 -sticky nesw
	label $object.options.label2 \
		-anchor w \
		-text Pagesize
	grid $object.options.label2 -row 1 -column 0 -sticky nesw
	Classy::OptionMenu $object.options.pagesize  \
		-text Statement
	grid $object.options.pagesize -row 1 -column 1 -columnspan 4 -sticky nesw
	label $object.options.label3 \
		-anchor w \
		-text Orientation
	grid $object.options.label3 -row 3 -column 0 -sticky nesw
	label $object.options.label4 \
		-anchor w \
		-text {Color mode}
	grid $object.options.label4 -row 4 -column 0 -sticky nesw
	radiobutton $object.options.radiobutton1 \
		-anchor w \
		-text Color \
		-value color
	grid $object.options.radiobutton1 -row 4 -column 1 -sticky nesw
	radiobutton $object.options.radiobutton2 \
		-anchor w \
		-text Gray \
		-value gray
	grid $object.options.radiobutton2 -row 4 -column 2 -sticky nesw
	radiobutton $object.options.radiobutton3 \
		-anchor w \
		-text Mono \
		-value mono
	grid $object.options.radiobutton3 -row 4 -column 3 -sticky nesw
	radiobutton $object.options.radiobutton4 \
		-anchor w \
		-text Portrait \
		-value portrait
	grid $object.options.radiobutton4 -row 3 -column 1 -sticky nesw
	radiobutton $object.options.radiobutton5 \
		-anchor w \
		-text Landscape \
		-value landscape
	grid $object.options.radiobutton5 -row 3 -column 2 -sticky nesw
	label $object.options.label5 \
		-anchor w \
		-text {Print command}
	grid $object.options.label5 -row 2 -column 0 -sticky nesw
	Classy::OptionMenu $object.options.printer  \
		-text postscript
	grid $object.options.printer -row 0 -column 1 -columnspan 4 -sticky nesw
	Classy::Entry $object.options.printcommand \
		-combo 10 \
		-width 4
	grid $object.options.printcommand -row 2 -column 1 -columnspan 4 -sticky nesw
	grid columnconfigure $object.options 0 -uniform {}
	grid columnconfigure $object.options 1 -uniform {}
	grid columnconfigure $object.options 2 -uniform {}
	grid columnconfigure $object.options 3 -uniform {}
	grid columnconfigure $object.options 4 -uniform {} -weight 1
	grid columnconfigure $object.options 5 -uniform {}
	grid columnconfigure $object.options 6 -uniform {}
	grid rowconfigure $object.options 0 -uniform {}
	grid rowconfigure $object.options 1 -uniform {}
	grid rowconfigure $object.options 2 -uniform {}
	grid rowconfigure $object.options 3 -uniform {}
	grid rowconfigure $object.options 4 -uniform {}
	grid rowconfigure $object.options 5 -uniform {}
	grid rowconfigure $object.options 6 -uniform {}

	if {"$args" == "___Classy::Builder__create"} {return $object}
	# Parse this
	$object.options.pagesize configure \
		-textvariable [privatevar Classy::Printer pdata(-pagesize)] \
		-list [list_unmerge [option get $object paperSizes PaperSizes]]
	$object.options.radiobutton1 configure \
		-variable [privatevar Classy::Printer pdata(-colormode)]
	$object.options.radiobutton2 configure \
		-variable [privatevar Classy::Printer pdata(-colormode)]
	$object.options.radiobutton3 configure \
		-variable [privatevar Classy::Printer pdata(-colormode)]
	$object.options.radiobutton4 configure \
		-variable [privatevar Classy::Printer pdata(-orientation)]
	$object.options.radiobutton5 configure \
		-variable [privatevar Classy::Printer pdata(-orientation)]
	$object.options.printer configure \
		-list [Classy::Printer list] \
		-textvariable [privatevar Classy::Printer pdata(-printer)] \
		-command [varsubst object {$object change_printer}]
	$object.options.printcommand configure \
		-textvariable [privatevar Classy::Printer pdata(-printcommand)]
	$object add print Print [list $object print] default
	$object persistent set save
	# Configure initial arguments
	if {"$args" != ""} {eval $object configure $args}
# ClassyTk Finalise
$object initialize
	return $object
}

Classy_printdialog addoption -askscale {askScale AskScale 0} {
}

#Classy_printdialog addoption -asktile {askTile AskTile 0} {
#}

Classy_printdialog method initialize {} {
	private Classy::Printer go
	set go 0
	$object.options.printcommand configure -combopreset {invoke {} {return {{lp -d %p -o media=%m -o sides=%s} {kprinter --stdin} lpr}}}
	set list [Classy::Printer list]
	lappend list "Print to file"
	$object.options.printer configure -list $list
	$object change_printer
}

Classy_printdialog method print {} {
	private Classy::Printer go pdata
	set go 1
	if {$pdata(-printer) eq "Print to file"} {
		if {[catch {
			set pdata(-file) [Classy::selectfile -title "Print to file" -initialdir [file dir $pdata(-file)] -initialfile $pdata(-file)]
		}]} {
			return
		}
	}
}

Classy_printdialog method change_printer {args} {
	private Classy::Printer pdata optpdata
	private $object options
	set allsizes [list_unmerge [option get $object paperSizes PaperSizes]]
	if {$pdata(-printer) eq "Print to file"} {
		set sizes $allsizes
	} else {
		set sizes [Classy::Printer pagesizes $pdata(-printer)]
	}
	if {![inlist $sizes $pdata(-pagesize)]} {
		set pdata(-pagesize) [lindex $sizes 0]
	}
	$object.options.pagesize configure -list $sizes
	# create extra options
	set list [winfo children $object.options]
	foreach w $list {
		if {[string range $w end-2 end] eq "opt"} {
			destroy $w
		}
	}
	unset -nocomplain optpdata
	set row 5
	if {$options(-askscale)} {
		label $object.options.label${row}_opt -anchor w -text Scale
		grid $object.options.label${row}_opt -row $row -column 0 -sticky nesw
		set w $object.options.choice${row}-1_opt
		radiobutton $w -anchor w -text "Fit" -variable [privatevar Classy::Printer pdata(-scale_fit)] -value fit
		grid $w -row $row -column 1 -sticky nesw
		set w $object.options.choice${row}-2_opt
		radiobutton $w -anchor w -text "Scale" -variable [privatevar Classy::Printer pdata(-scale_fit)] -value scale
		grid $w -row $row -column 2 -sticky nesw
		set w $object.options.choice${row}-3_opt
		Classy::NumEntry $w -textvariable [privatevar Classy::Printer pdata(-scale)]
		grid $w -row $row -column 3 -columnspan 2 -sticky nesw
		incr row
	}
	foreach line [Classy::Printer _printeroptions $pdata(-printer)] {
		foreach {option name choices default} $line break
		if {[inlist {ColorModel PageSize} $option]} continue
		if {[llength $choices] <= 1} continue
		if {[llength $choices] <= 3} {
			label $object.options.label${row}_opt -anchor w -text $name
			grid $object.options.label${row}_opt -row $row -column 0 -sticky nesw
			set col 1
			foreach choice $choices {
				set w $object.options.choice${row}-${col}_opt
				radiobutton $w -anchor w -text $choice -value $choice -variable [privatevar Classy::Printer optpdata($option)]
				grid $w -row $row -column $col -sticky nesw
				incr col
			}
			if {![inlist $choices $optpdata($option)]} {	
				set optpdata($option) $default
			}			
			incr row
		} else {
			label $object.options.label${row}_opt -anchor w -text $name
			grid $object.options.label${row}_opt -row $row -column 0 -sticky nesw
			Classy::OptionMenu $object.options.choices${row}_opt \
				-list $choices -textvariable [privatevar Classy::Printer optpdata($option)]
			grid $object.options.choices${row}_opt -row $row -column 1 -columnspan 4 -sticky nesw
			if {![inlist $choices $optpdata($option)]} {	
				set optpdata($option) $default
			}			
			incr row
		}
	}
	update
	set width [winfo width $object]
	set rwidth [winfo reqwidth $object]
	set rheight [winfo reqheight $object]
	if {$width < $rwidth} {set width $rwidth}
	wm geometry $object ${width}x$rheight
	wm minsize $object $rwidth $rheight
}

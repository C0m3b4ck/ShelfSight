#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Editor
# ----------------------------------------------------------------------
#doc TableEditor title {
#TableEditor
#} index {
# New widgets
#} shortdescr {
# table editor in a widget
#} descr {
# subclass of <a href="Widget.html">Widget</a><br>
# The TableEditor widget provides a table editor
#}
#doc {TableEditor options} h2 {
#	TableEditor specific options
#}
#doc {TableEditor command} h2 {
#	TableEditor specific methods
#}
# These will be added to tclIndex by Class::auto_mkindex

option add *Classy::TableEditor.KeySearchReopen Control-Alt-r widgetDefault
option add *Classy::TableEditor.KeyMatchingBrackets "Alt-bracketleft" widgetDefault
option add *Classy::TableEditor.KeyIndentCr Control-j widgetDefault
option add *Classy::TableEditor.KeyComment "Alt-numbersign" widgetDefault
option add *Classy::TableEditor.KeyDelComment "Control-Alt-numbersign" widgetDefault

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------
Widget subclass Classy::TableEditor

Classy::TableEditor method init {args} {
	super init
	set w [::Classy::window $object]
	$w configure -highlightthickness 0 -borderwidth 0
	Classy::TkTable $object.edit -wrap 0 -yscrollcommand [list $object.vbar set] \
		-xscrollcommand [list $object.hbar set] -changedcommand [list $object _tablechanged] \
		-autosize {2 80} -resizeborders both
	bindtags $object [list $object Classy::Menu_macro Classy::Menu_pattern Classy::TableEditor Classy::TkTable all]
	Classy::DynaMenu attachmainmenu Classy_TableEditor $object
	Classy::rebind $object.edit $object
	scrollbar $object.vbar -orient vertical -command "$object.edit yview"
	scrollbar $object.hbar -orient horizontal -command "$object.edit xview"
	Classy::DynaTool $object.tool -type Classy_TableEditor -cmdw $object
	grid $object.tool - -sticky we
	grid rowconfigure $object 1 -weight 1
	if {"[option get $object scrollSide ScrollSide]"=="left"} {
		grid $object.vbar $object.edit -sticky nswe
		grid $object.hbar -column 1 -sticky nswe
		grid columnconfigure $object 1 -weight 1
	} else {
		grid $object.edit $object.vbar -sticky nswe
		grid $object.hbar -column 0 -sticky nswe
		grid columnconfigure $object 0 -weight 1
	}
	# REM Initialise options and variables
	# ------------------------------------
	private $object curfile reopenlist findwhat replace settings
	set curfile {}
	set reopenlist {}
	set findwhat {}
	set replace {}
	array set settings {growx 0 growy 0 titlerow 1 titlecolumn 0 numberrow 0 numbercolumn 0}
	# REM Create bindings
	# --------------------
	# REM Configure initial arguments
	# -------------------------------
	$object.edit configure -variabletype list -variable [privatevar $object table] -multiline 1 -wrap 1 -width 40
	if {"$args" != ""} {eval $object configure $args}
	focus $object.edit
	bindtags $object.edit.edit [list $object.edit.edit Classy::Menu_Classy_TableEditor Classy::Menu_macro Classy::TkTable::single Classy::Text . all]
	bind $object.edit.edit <FocusIn> "[list Classy::DynaMenu cmdw Classy_TableEditor $object] ; break"
	return $object
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------
Classy::TableEditor chainoptions {$object.edit}
Classy::TableEditor chainoption -background {$object} -background {$object.edit} -background
Classy::TableEditor chainoption -highlightbackground {$object} -highlightbackground {$object.edit} -highlightbackground
Classy::TableEditor chainoption -highlightcolor {$object} -highlightcolor {$object.edit} -highlightcolor

#doc {TableEditor options -loadcommand} option {-loadcommand loadCommand LoadCommand} descr {
#}
Classy::TableEditor addoption -loadcommand {loadCommand LoadCommand {}}

#doc {TableEditor options -savecommand} option {-savecommand saveCommand SaveCommand} descr {
#}
Classy::TableEditor addoption -savecommand {saveCommand SaveCommand {}}

#doc {TableEditor options -icon} option {-icon icon Icon} descr {
#}
Classy::TableEditor addoption -icon {icon Icon blank}

#doc {TableEditor options -searchtype} option {-searchtype searchType SearchType} descr {
#}
Classy::TableEditor addoption -searchtype {searchType SearchType exact}

#doc {TableEditor options -searchdir} option {-searchdir searchDir SearchDir} descr {
#}
Classy::TableEditor addoption -searchdir {searchDir SearchDir forward}

#doc {TableEditor options -searchcase} option {-searchcase searchCase SearchCase} descr {
#}
Classy::TableEditor addoption -searchcase {searchCase SearchCase nocase}

#doc {TableEditor options -searchreopen} option {-searchreopen SearchReopen searchReopen} descr {
#}
Classy::TableEditor addoption -searchreopen {SearchReopen searchReopen 0}
Classy::TableEditor addoption -connection [list connection Connection [tk appname]]

#doc {TableEditor options -closecommand} option {-closecommand closeCommand CloseCommand} descr {
#}
Classy::TableEditor addoption -closecommand {closeCommand CloseCommand {}}

# ------------------------------------------------------------------
#  destroy
# ------------------------------------------------------------------

#doc {TableEditor command destroy} cmd {
#pathname destroy 
#} descr {
#}
Classy::TableEditor method destroy {} {
	$object close
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::TableEditor chainallmethods {$object.edit} Classy::TkTable

Classy::TableEditor method cut {} {
	private $object replace
	set replace [tk_tableCut $object.edit]
}

Classy::TableEditor method copy {} {
	private $object replace
	set replace [tk_tableCopy $object.edit]
}

Classy::TableEditor method paste {} {
	$object.edit paste
}

#doc {TableEditor command save} cmd {
#pathname save 
#} descr {
#}
Classy::TableEditor method save {} {
	private $object curfile options passwd
	upvar #0 [$object.edit cget -variable] tdata
	if {"$options(-savecommand)" != ""} {
		uplevel #0 $options(-savecommand) [list $tdata]
	} else {
		if {$curfile eq ""} {
			$object savedialog
			return
		}
		set f [open $curfile w]
		csv_write $f  $tdata \t ""
		close $f
		catch {wm title [winfo toplevel $object] "$curfile"}
	}
	$object editchanged 0
}

#doc {TableEditor command saveas} cmd {
#pathname saveas file
#} descr {
#}
Classy::TableEditor method saveas {file} {
	private $object options
	if {"$file" == ""} return
	if {"$options(-savecommand)" != ""} {
		return -code error "\"Save as\" not supported from this TableEditorwindow"
	}
	if ![Classy::overwriteyn $file 0] return
	private $object curfile reopenlist
	set curfile $file
	lappend reopenlist $file
	set reopenlist [lsort $reopenlist]
	$object save
	$object editchanged 0
	catch {wm title [winfo toplevel $object] "$curfile"}
}

#doc {TableEditor command savedialog} cmd {
#pathname savedialog 
#} descr {
#}
Classy::TableEditor method savedialog {} {
	private $object curfile
	$object saveas [Classy::savefile -title "Save as" -initialfile $curfile]
}

#doc {TableEditor command loadnext} cmd {
#pathname loadnext 
#} descr {
#}
Classy::TableEditor method loadnext {} {
	private $object curfile reopenlist
	set pos [lsearch -exact $reopenlist $curfile]
	incr pos
	if {$pos==[llength $reopenlist]} {set pos 0}
	set file [lindex $reopenlist $pos]
	$object load $file
}

#doc {TableEditor command loadprev} cmd {
#pathname loadprev 
#} descr {
#}
Classy::TableEditor method loadprev {} {
	private $object curfile reopenlist
	set pos [lsearch -exact $reopenlist $curfile]
	if {$pos==0} {set pos [llength $reopenlist]}
	incr pos -1
	set file [lindex $reopenlist $pos]
	$object load $file
}

#doc {TableEditor command close} cmd {
#pathname close 
#} descr {
#}
Classy::TableEditor method close {} {
	private $object curfile
	private $class count_$curfile
	if [true [$object closefile]] {
		eval [getprivate $object options(-closecommand)]
	}
	set var [privatevar $class file_$curfile]
	upvar #0 $var tdata
	if {[info exists tdata] && ![incr count_$curfile -1]} {
		unset tdata
	}
	
}

#doc {TableEditor command closefile} cmd {
#pathname closefile 
#} descr {
#}
Classy::TableEditor method closefile {} {
	private $object curfile cur
	private $class editing
	set var [privatevar $class file_$curfile]
	upvar #0 $var tdata
	if [true [$object editchanged]] {
		set temp [Classy::yorn "File not saved!\nSave file first?" -close yes]
		switch $temp {
			1 {$object save}
			close {return false}
		}
	}
#	set cur(pos,$curfile) [$object index insert]
	set temp [file_fullpath $curfile]
	if {[info exists editing($temp)]} {
		set editing($temp) [list_remove $editing($temp) $object]
		if {![llength $editing($temp)]} {
			unset editing($temp)
		}
	}
	if {![info exists editing($temp)]} {
		unset -nocomplain tdata
		$object.edit configure -variable [privatevar $object table]
	}
	Classy::todo $object.edit activate 0,0
	return true
}

#doc {TableEditor command load} cmd {
#pathname load ?filename? ?filename ...?
#} descr {
#}
Classy::TableEditor method load {{file {}} args} {
	if {$file eq ""} {
		if {[catch {
			set args [Classy::selectfile -title Open -selectmode persistent]
		}]} return
		set file [list_shift args]
	}
	if {$file eq ""} return
	private $object curfile reopenlist cur options passwd
	private $class editing
	set options(-savecommand) ""
	if {"[$object closefile]" != "true"} {return}
	set curfile [file_fullpath $file]
	set var [privatevar $class file_$curfile]
	upvar #0 $var tdata
	private $class count_$curfile
	if {![info exists tdata]} {
		if [file exists $curfile] {
			if {[file isdir $curfile]} {
				error "Cannot open directory \"$curfile\""
			}
			set f [open $curfile r]
			set tdata [csv_file $f \t]
			close $f
		} else {
			error "File $file does not exist"
		}
		# $object clearundo
		$object editchanged 0
		set count_$curfile 1
	} elseif {[info exists count_$curfile]} {
		incr count_$curfile
	} else {
		set count_$curfile 1
	}
	set cols 0
	foreach line $tdata {
		set len [llength $line]
		if {$len > $cols} {set cols $len}
	}
	$object.edit configure -rows [llength $tdata] -cols $cols
	$object.edit configure -variable $var
	list_addnew editing($curfile) $object
	list_addnew reopenlist $curfile
	if {"$args" != ""} {
		foreach otherfile $args {
			lappend reopenlist [file_fullpath $otherfile]
		}
	}
	set reopenlist [list_remdup $reopenlist]
	set reopenlist [lsort $reopenlist]
	set loadcommand [getprivate $object options(-loadcommand)]
	if {"$loadcommand" != ""} {
		 eval $loadcommand [list $curfile]
	}
#	::Classy::busy remove $object
	$object editchanged 0
	return $curfile
}

#doc {TableEditor command set} cmd {
#pathname set data
#} descr {
#}
Classy::TableEditor method loaddata {data} {
	private $object curfile cur
	if {"[$object closefile]" != "true"} {return}
	upvar #0 [$object.edit cget -variable] tdata
	set curfile ""
	set tdata $data
	set cols 0
	foreach line $tdata {
		set len [llength $line]
		if {$len > $cols} {set cols $len}
	}
	$object.edit configure -rows [llength $tdata] -cols $cols
}

#doc {TableEditor command reopenlist} cmd {
#pathname reopenlist 
#} descr {
#}
Classy::TableEditor method reopenlist {} {
	private $object curfile reopenlist
	set w $object.reopenlist
	destroy $w
	# use listvariable, so -deletecommand does not actually have to do something
	Classy::SelectDialog $w -title "Reopen list" \
		-command "$object load" \
		-deletecommand "Classy::nop" \
		-listvariable [privatevar $object reopenlist]
	set reopenlist [lsort $reopenlist]
	$w fill $reopenlist
	$w set $curfile
}

#doc {TableEditor command findsel} cmd {
#pathname findsel direction
#} descr {
# direction can be -forwards or -backwards
#}
Classy::TableEditor method findsel {dir} {
	private $object findwhat
	catch {set findwhat [$object.edit currentsel]}
	$object find -direction [string trimleft $dir -] $findwhat
}

Classy::TableEditor method replace-find {dir} {
	private $object findwhat replace
	catch {set findwhat [$object.edit currentsel]}
	if {[winfo exists $object.edit.edit]} {
		catch {eval $object.edit.edit delete sel.first sel.last}
		$object.edit.edit insert insert $replace
	} else {
		$object.edit set $replace
	}
	$object find -direction [string trimleft $dir -] $findwhat
}

#doc {TableEditor command find} cmd {
#pathname find what ?option? ?value? ?option value?
#} descr {
#}
Classy::TableEditor method find {args} {
	private $object options curfile
	upvar #0 [$object.edit cget -variable] tdata
	cmd_args "$object find" {
		-direction {{oneof forwards backwards} "forwards/backwards"}
		-type {{oneof exact regexp} "exact/regexp"}
		-nocase {switch "Ignore case differences"}
		-count {any "variable to store number of index positions"}
	} {pattern ?index?} $args
	if {[get opt(-direction) forwards] eq "forwards"} {
		set dir 1
	} else {
		set dir -1
	}
	if {![info exists index]} {
		set index [$object.edit current]
	}
	set type [get opt(-type) exact]
	set tindex {}
	foreach {index tindex} $index break
	foreach {r c} [split [$object.edit index $index] ,] break
	if {[winfo exists $object.edit.edit]} {
		set text [$object.edit.edit get 1.0 end-1c]
	} else {
		set text [lindex $tdata $r $c]
	}
	if {$tindex ne ""} {
		set tpos [Classy::TkTable_stringindex $text $tindex]
		if {$dir == 1} {incr tpos} else {incr tpos -1}
		set found [Classy::TkTable_textfind $dir $type $text $pattern $tpos]
	} else {
		set found {}
	}
	set startfile $curfile
	while {![llength $found]} {
		set found [Classy::TkTable_listfind $dir $type $tdata $pattern $r $c]
		if {[llength $found]} {
			foreach {r c} $found break
			set text [lindex $tdata $r $c]
			set found [Classy::TkTable_textfind $dir $type $text $pattern]
			break
		}
		if {!$options(-searchreopen)} break
		if {$dir == 1} {
			$object loadnext
		} else {
			$object loadprev
		}
		if {"$curfile" == "$startfile"} break
		upvar #0 [$object.edit cget -variable] tdata
		set r 0
		set c 0
	}
	if {![llength $found]} return
	foreach {pos1 pos2} $found break
	set pos1 [Classy::TkTable_textindex $text $pos1]
	set pos2 [Classy::TkTable_textindex $text $pos2]
	Classy::update Classy::TableEditor-find
	$object.edit edit $r,$c $pos1 $pos2
}

Classy::TableEditor method _search {} {
}

#doc {TableEditor command gotoline} cmd {
#pathname gotoline line
#} descr {
#}
Classy::TableEditor method gotoline {line {pos 0}} {
	if {[catch {set c [$object.edit index active col]}]} {set c 0}
	$object.edit activate $line,$c
	$object.edit see $line,$c
}

#doc {TableEditor command command} cmd {
#pathname command command
#} descr {
#}
Classy::TableEditor method command {command} {
	eval $command
}

#doc {TableEditor command replace} cmd {
#pathname replace ?all?
#} descr {
#}
Classy::TableEditor method replace {args} {
	private $object options replace findwhat
	if {"$args" == "all"} {
		set start [$object index insert]
		if {"$options(-searchdir)"=="forwards"} {
			set stop end
		} else {
			set stop 1.0
		}
		while 1 {
			set pos [eval {$object search -count ::Classy::number} -$options(-searchdir) -$options(-searchtype) -$options(-searchcase) \
				-- {$findwhat} $start $stop]
			if {"$pos"==""} {break}
			$object delete $pos "$pos + $::Classy::number c"
			$object insert $pos $replace
			set start [$object index "$pos + [string length $replace] c"]
		}
		$object mark set insert $start
	} else { 
		set sel ""
		catch {set sel [$object get sel.first sel.last]}
		$object delete sel.first sel.last
		$object insert insert $replace
		$object find -$options(-searchdir) $findwhat
	}
}

#doc {TableEditor command finddialog} cmd {
#pathname finddialog 
#} descr {
#}
Classy::TableEditor method finddialog {} {
	private $object options
	set options(-searchdir) forwards
	set w $object.find
	if ![winfo exists $w] {
		Classy::Dialog $w -cache 1
		wm title $w Find
		set what "\[$w.options.find get\] "
		$w add find Find "$object find -direction \[set [privatevar $object options(-searchdir)]\] $what" default
		$w add repl Replace "$object replace"
		$w add replall "Replace all" "$object replace all"
	
		Classy::Entry $w.options.find -label Find -textvariable [privatevar $object findwhat] -combo 20
		Classy::Entry $w.options.replace -label Replace -textvariable [privatevar $object replace] -combo 20
		frame $w.options.frame
		Classy::OptionBox $w.options.type -label "Type" -orient vertical -variable [privatevar $object options(-searchtype)]
		$w.options.type add exact Exact
		$w.options.type add regexp Regexp
		Classy::OptionBox $w.options.case -label "Case" -orient vertical -variable [privatevar $object options(-searchcase)]
		$w.options.case add nocase "No case"
		$w.options.case add case "Case sensitive"
		Classy::OptionBox $w.options.dir -label "Direction" -orient horizontal -variable [privatevar $object options(-searchdir)]
		$w.options.dir add forwards "Forward"
		$w.options.dir add backwards "Backwards"
		checkbutton $w.options.searchreopen -text "Search Reopen" -variable [privatevar $object options(-searchreopen)]
		pack $w.options.find -fill x
		pack $w.options.replace -fill x
		pack $w.options.frame -fill x
		pack $w.options.searchreopen -in $w.options.frame -side bottom -fill x -expand yes
		pack $w.options.dir -in $w.options.frame -side bottom -fill x -expand yes
		pack $w.options.type -in $w.options.frame -side left -fill x -expand yes
		pack $w.options.case -in $w.options.frame -side left -fill x -expand yes
	} else {
		$w place
	}
	focus $w.options.find.entry
#	$w.options.find.entry select range 0 end
}

array set Classy::TableEditor_trace_ignore {
	finddialog 1
	savedialog 1
}

proc Classy::TableEditor_trace {object var command} {
	set w [list_shift command]
	set level [info level]
	if [info exists ::Classy::TableEditor_trace_ignore($command)] return
	if {$level == 1} {
		if {[lsearch -exact {trace index} [lindex $command 0]] == -1} {
			lappend $var "\$object $command"
		}
	}
}

#doc {TableEditor command macro} cmd {
#pathname macro 
#} descr {
#}
Classy::TableEditor method macro {} {
	set obj $object
	Classy::Dialog $object.macro -title "Make macro" -closecommand [varsubst object {
		$object trace {}
		unset -nocomplain [privatevar $object macro]
		destroy $object.macro
	}] -resize {1 1}
	set record [$object.macro add record Record {}]
	set stop [$object.macro add stop "Stop" {}]
	$record configure -command [varsubst {stop record object} {
		set [privatevar $object macro] ""
		$object.macro.options.text delete 1.0 end
		$record configure -text "Recording ..." -state disabled
		$stop configure -state normal
		focus $object
		$object trace [list Classy::TableEditor_trace $object [privatevar $object macro]]
	}]
	$stop configure -command [varsubst {stop record object} {
		$record configure -text "Record" -state normal
		$stop configure -state disabled
		$object trace {}
		$object.macro.options.text insert end [join [set [privatevar $object macro]] "\n"]
		unset -nocomplain [privatevar $object macro]
	}]
	$stop configure -state disabled
	$object.macro add set Set [concat $object setmacro "\[$object.macro.options.name get\]" \
		"\[$object.macro.options.text get 1.0 end\]" \
		"\[$object.macro.options.key get\]"]
	$object.macro add delete Delete [concat $object deletemacro "\[$object.macro.options.name get\]"]
	$object.macro add exec Execute [varsubst {} {
		set object $object
		eval [$object.macro.options.text get 1.0 end]
	}]
	$object.macro add get Get "$object getmacro"
	set key [privatevar $object macrokey]
	$object.macro add save "Save now" {Classy::Default save}
	# Options
	#--------
	private $object macrokey macroname
	Classy::Entry $object.macro.options.name -label "Name" \
		-combo 10 \
		-combopreset {Classy::Default get app Classy::TableEditor_macros} \
		-textvariable [privatevar $object macroname] \
		-command [list $object.macro invoke get]
	Classy::Entry $object.macro.options.key -label "Key-code" \
		-combo 10 \
		-textvariable [privatevar $object macrokey]
	scrollbar $object.macro.options.scroll -command "$object.macro.options.text yview"
	Classy::Text $object.macro.options.text -yscrollcommand "$object.macro.options.scroll set" -width 20 -height 10
	if {"$macroname"==""} {set macroname temp}
	pack $object.macro.options.key -side bottom -fill x
	pack $object.macro.options.name -side bottom -fill x
	pack $object.macro.options.scroll -fill y -side right
	pack $object.macro.options.text -fill both -expand yes
	$object getmacro
	if {"$macrokey"==""} {set macrokey F5}
}

#doc {TableEditor command setmacro} cmd {
#pathname setmacro name command ?key?
#} descr {
#}
Classy::TableEditor method setmacro {name command {key {}}} {
	if {"$name"==""} {
		error "No name selected"
		return
	}
	set macros [Classy::Default get app Classy::TableEditor_macros]
	list_addnew macros $name
	Classy::Default set app Classy::TableEditor_macros $macros
	Classy::Default set app Classy::TableEditor_macro_$name [list $command $key]
	Classy::update Classy::TableEditor-setmacro idletasks
	Classy::DynaMenu updateactive Classy_TableEditor
}

#doc {TableEditor command deletemacro} cmd {
#pathname deletemacro
#} descr {
#}
Classy::TableEditor method deletemacro {name} {
	if {"$name"==""} {
		error "No name selected"
		return
	}
	Classy::Default unset app Classy::TableEditor_macro_$name
	Classy::DynaMenu updateactive Classy_TableEditor
}

#doc {TableEditor command getmacromenu} cmd {
#pathname getmacromenu
#} descr {
#}
Classy::TableEditor method getmacromenu {} {
	set data {action "Manage Macros" "%W macro" <<Macro>>}
	append data "\n"
	set names ""
	foreach m [Classy::Default names app Classy::TableEditor_macro_*] {
		regexp {^Classy::TableEditor_macro_(.*)$} $m temp name
		set temp [Classy::Default get app Classy::TableEditor_macro_$name]
		set key [lindex $temp 1]
		append data "action \"$name\" \{[list %W runmacro $name]\}"
		if {"$key" == ""} {
			append data "\n"
		} else {
			append data " <$key>\n"
		}
		lappend names $name
	}
	Classy::Default set app Classy::TableEditor_macros $names
	return [list $data Classy::Menu_macro]
}

#doc {TableEditor command getmacro} cmd {
#pathname getmacro 
#} descr {
#}
Classy::TableEditor method getmacro {} {
	set name [$object.macro.options.name get]
	set temp [Classy::Default get app Classy::TableEditor_macro_$name]
	$object.macro.options.text delete 1.0 end
	$object.macro.options.text insert end [lindex $temp 0]
	$object.macro.options.key set [lindex $temp 1]
}

#doc {TableEditor command runmacro} cmd {
#pathname runmacro name
#} descr {
#}
Classy::TableEditor method runmacro {name} {
	set temp [Classy::Default get app Classy::TableEditor_macro_$name]
	eval [lindex $temp 0]
}

#doc {TableEditor command transpose} cmd {
#pathname transpose pos
#} descr {
#}
Classy::TableEditor method transpose {{pos {}}} {
}

Classy::TableEditor method _reconfigure {} {
	foreach w [list $object $object.edit $object.vbar $object.hbar] {
		foreach {option name class} {
			-font font Font
			-foreground foreground Foreground
			-background background Background
			-highlightbackground highlightBackground HighlightBackground
			-highlightcolor highlightColor HighlightColor
			-highlightthickness highlightThickness HighlightThickness
			-borderwidth borderWidth BorderWidth
			-disabledforeground disabledForeground DisabledForeground
			-insertbackground insertBackground Foreground
	 		-insertborderwidth insertBorderWidth BorderWidth
			-selectbackground selectBackground Foreground
			-selectborderwidth selectBorderWidth BorderWidth
	 		-selectforeground selectForeground Background
			-troughcolor troughColor Background
		} {
			catch {[::Classy::window $w] configure $option [Classy::optionget $w $name $class]}
		}
	}
	[::Classy::window $object] configure -highlightthickness 0 -borderwidth 0
	eval grid forget [winfo children $object]
	set row 1
	grid $object.tool -row 0 -column 0 -columnspan 2 -sticky we
	grid rowconfigure $object 0 -weight 0
	grid rowconfigure $object 1 -weight 1
	if {"[option get $object scrollSide ScrollSide]"=="left"} {
		grid $object.vbar -row $row -column 0 -sticky ns
		grid $object.edit -row $row -column 1 -sticky nswe
		incr row
		grid $object.hbar -row $row -column 1 -sticky we
		grid columnconfigure $object 0 -weight 0
		grid columnconfigure $object 1 -weight 1
	} else {
		grid $object.edit -row $row -column 0 -sticky nswe
		grid $object.vbar -row $row -column 1 -sticky ns
		incr row
		grid $object.hbar -row $row -column 0 -sticky we
		grid columnconfigure $object 0 -weight 1
		grid columnconfigure $object 1 -weight 0
	}
	Classy::update Classy::TableEditor-_reconfigure idletasks
}

Classy::TableEditor method undo {} {
	$object.edit undo
}

Classy::TableEditor method redo {} {
	$object.edit redo
}

#doc {TableEditor command editchanged} cmd {
#pathname editchanged
#} descr {
#}
Classy::TableEditor method editchanged {{bool {}}} {
	private $object textchanged
	if ![llength $bool] {
		return [get textchanged 0]
	}
	set textchanged $bool
	if $bool {
		set top [winfo toplevel $object]
		set title [wm title $top]
		if ![regexp { \*$} $title] {catch [wm title $top "$title *"]}
	} else {
		set top [winfo toplevel $object]
		regsub { *$} [wm title $top] {} title
		catch {wm title $top $title}
	}
}

Classy::TableEditor method _tablechanged {w r c value} {
	$object editchanged 1
	return $value
}

Classy::TableEditor method _refresh {} {
	private $object settings
	if {[get settings(growx) 0] && [get settings(growy) 0]} {
		$object.edit configure -grow both
	} elseif {[get settings(growx) 0]} {
		$object.edit configure -grow column
	} elseif {[get settings(growy) 0]} {
		$object.edit configure -grow row
	} else {
		$object.edit configure -grow none
	}
	if {!$settings(transpose)} {
		set titlerows [get settings(titlerow) 1]
		set titlecols [get settings(titlecolumn) 1]
	} else {
		set titlecols [get settings(titlerow) 1]
		set titlerows [get settings(titlecolumn) 1]
	}
	if {[get settings(numberrow) 1]} {
		set roworigin -1
		incr titlerows
	} else {
		set roworigin 0
	}
	if {[get settings(numbercolumn) 1]} {
		set colorigin -1
		incr titlecols
	} else {
		set colorigin 0
	}
	set diff [expr {[$object.edit cget -roworigin] - $roworigin}]
	if {$diff != 0} {
		$object.edit configure -rows [expr {[$object.edit cget -rows]+$diff}]
	}
	set diff [expr {[$object.edit cget -colorigin] - $colorigin}]
	if {$diff != 0} {
		$object.edit configure -cols [expr {[$object.edit cget -cols]+$diff}]
	}
	$object.edit configure -titlerows $titlerows
	$object.edit configure -titlecols $titlecols
	$object.edit configure -roworigin $roworigin
	$object.edit configure -colorigin $colorigin
}

Classy::TableEditor method transposeview {} {
	private $object settings
	set transpose $settings(transpose)
	if {$transpose} {set new tlist} else {set new list}
	set cur [$object.edit cget -variabletype]
	if {$cur eq $new} return
	Classy::todo $object _refresh
	if {$transpose} {
		$object.edit configure -variabletype tlist
	} else {
		$object.edit configure -variabletype list
	}
}

proc Classy::title {w title} {
	wm title $w $title
	wm iconname $w $title
}

proc Classy::tableedit {args} {
	set w .classy__.tableedit
	set num 1
	while {[winfo exists $w$num] == 1} {incr num}
	set w $w$num
	catch {destroy $w}
	Classy::Toplevel $w -bd 0 -highlightthickness 0 -keepgeometry 1
	wm protocol $w WM_DELETE_WINDOW "destroy $w"
	Classy::TableEditor $w.editor \
		-loadcommand "Classy::title $w" \
		-closecommand "after idle \{destroy $w\}" \
		-rows 20 -cols 5
	pack $w.editor -fill both -expand yes
	if {[llength $args]} {
		eval $w.editor load $args
	}
	return $w
}

proc tableedit {args} {
	eval Classy::tableedit $args
}

#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Editor
# ----------------------------------------------------------------------
#doc Editor title {
#Editor
#} index {
# New widgets
#} shortdescr {
# reasonably advanced text editor in a widget
#} descr {
# subclass of <a href="Widget.html">Widget</a><br>
# The Editor widget provides a fairly complete editor with undo redo
# search, menus and toolbar, invoke Tcl commands, macros, etc. ...
#}
#doc {Editor options} h2 {
#	Editor specific options
#}
#doc {Editor command} h2 {
#	Editor specific methods
#}
# These will be added to tclIndex by Class::auto_mkindex

option add *Classy::Editor.KeySearchReopen Control-Alt-r widgetDefault
option add *Classy::Editor.KeyMatchingBrackets "Alt-bracketleft" widgetDefault
option add *Classy::Editor.KeyIndentCr Control-j widgetDefault
option add *Classy::Editor.KeyComment "Alt-numbersign" widgetDefault
option add *Classy::Editor.KeyDelComment "Control-Alt-numbersign" widgetDefault

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------
Widget subclass Classy::Editor

Classy::Editor method init {args} {
	super init
	set w [::Classy::window $object]
	$w configure -highlightthickness 0 -borderwidth 0
	Classy::Text $object.edit -wrap none -yscrollcommand [list $object.vbar set] \
		-xscrollcommand [list $object.hbar set] -changedcommand [list $object editchanged]
	bindtags $object [list $object Classy::Menu_macro Classy::Menu_pattern Classy::Editor Classy::Text all]
	Classy::DynaMenu attachmainmenu Classy_Editor $object
	Classy::rebind $object.edit $object
	scrollbar $object.vbar -orient vertical -command "$object.edit yview"
	scrollbar $object.hbar -orient horizontal -command "$object.edit xview"
	Classy::DynaTool $object.tool -type Classy_Editor -cmdw $object
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
	private $object curfile reopenlist findwhat replace marker curmarker prevmarker
	set curfile {}
	set reopenlist {}
	set findwhat {}
	set replace {}
	set marker Mark
	set curmarker {}
	set prevmarker {}
	# REM Create bindings
	# --------------------
	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
	return $object
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------
Classy::Editor chainoptions {$object.edit}
Classy::Editor chainoption -background {$object} -background {$object.edit} -background
Classy::Editor chainoption -highlightbackground {$object} -highlightbackground {$object.edit} -highlightbackground
Classy::Editor chainoption -highlightcolor {$object} -highlightcolor {$object.edit} -highlightcolor

#doc {Editor options -loadcommand} option {-loadcommand loadCommand LoadCommand} descr {
#}
Classy::Editor addoption -loadcommand {loadCommand LoadCommand {}}

#doc {Editor options -savecommand} option {-savecommand saveCommand SaveCommand} descr {
#}
Classy::Editor addoption -savecommand {saveCommand SaveCommand {}}

#doc {Editor options -icon} option {-icon icon Icon} descr {
#}
Classy::Editor addoption -icon {icon Icon blank}

#doc {Editor options -searchtype} option {-searchtype searchType SearchType} descr {
#}
Classy::Editor addoption -searchtype {searchType SearchType exact}

#doc {Editor options -searchdir} option {-searchdir searchDir SearchDir} descr {
#}
Classy::Editor addoption -searchdir {searchDir SearchDir forward}

#doc {Editor options -searchcase} option {-searchcase searchCase SearchCase} descr {
#}
Classy::Editor addoption -searchcase {searchCase SearchCase nocase}

#doc {Editor options -searchreopen} option {-searchreopen SearchReopen searchReopen} descr {
#}
Classy::Editor addoption -searchreopen {SearchReopen searchReopen 0}
Classy::Editor addoption -connection [list connection Connection [tk appname]]

#doc {Editor options -closecommand} option {-closecommand closeCommand CloseCommand} descr {
#}
Classy::Editor addoption -closecommand {closeCommand CloseCommand {}}

#doc {Editor options -wrap} option {-wrap wrap Wrap} descr {
#}
Classy::Editor addoption -wrap {wrap Wrap none} {
	$object.edit configure -wrap $value
}

#doc {Editor options -formatlength} option {-formatlength formatLength FormatLength} descr {
#}
Classy::Editor addoption -formatlength {formatLength FormatLength 76}

# ------------------------------------------------------------------
#  destroy
# ------------------------------------------------------------------

#doc {Editor command destroy} cmd {
#pathname destroy 
#} descr {
#}
Classy::Editor method destroy {} {
	private $object curfile
	private $class editing
	set temp [file_fullpath $curfile]
	if [info exists editing($temp)] {
		set editing($temp) [list_remove $editing($temp) $object]
		if {"$editing($temp)"==""} {unset editing($temp)}
	}
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::Editor chainallmethods {$object.edit} Classy::Text

#doc {Editor command cut} cmd {
#pathname cut 
#} descr {
#}
Classy::Editor method cut {} {
	private $object replace
	clipboard clear -displayof $object
	catch {									
		set replace [$object get sel.first sel.last]
		clipboard append -displayof $object $replace
		$object delete sel.first sel.last
	}
}

#doc {Editor command copy} cmd {
#pathname copy 
#} descr {
#}
Classy::Editor method copy {} {
	private $object replace
	clipboard clear -displayof $object			  
	catch {									
		set replace [$object get sel.first sel.last]
		clipboard append -displayof $object $replace
	}										  
}

#doc {Editor command connectto} cmd {
#pathname connectto 
#} descr {
#}
Classy::Editor method connectto {} {
	set w $object.connectto
	Classy::SelectDialog $w -title "Connect execution to" \
		-command "$object configure -connection"
	$w fill [winfo interps]
	$w set [getprivate $object options(-connection)]
}

#doc {Editor command execute} cmd {
#pathname execute 
#} descr {
#}
Classy::Editor method execute {} {
	if {"[$object tag ranges sel]" != ""} {
		set command [$object get sel.first sel.last]
		send -- [getprivate $object options(-connection)] $command
	}
}

#doc {Editor command findfunction} cmd {
#pathname findfunction ?function?
#} descr {
#load the file containing function $function (must be auto loadable),
#and find the function definition.
#if function is not given, the current selection will be searched.
#}
Classy::Editor method findfunction {args} {
	if {"$args"!=""} {
		set function $args
	} elseif {"[$object tag ranges sel]"!=""} {
		set function [$object get sel.first sel.last]
	} else {
		Classy::InputDialog $object.findfunction -command "$object findfunction"
		return
	}
	set index [send -- [getprivate $object options(-connection)] setglobal auto_index($function)]
	$object load [lindex $index 1]
	$object find "proc $function"
}

#doc {Editor command save} cmd {
#pathname save 
#} descr {
#}
Classy::Editor method save {} {
	private $object curfile options passwd
	if {"$options(-savecommand)" != ""} {
		set temp [$object get 1.0 "end-1c"]
		uplevel #0 $options(-savecommand) [list $temp]
	} else {
		if {$curfile eq ""} {
			$object savedialog
			return
		}
		set temp [$object get 1.0 "end-1c"]
		if {[file extension $curfile] eq ".bf"} {
			if {[info exists passwd]} {
				set newpasswd [Classy::getpasswd $passwd]
				while {$newpasswd ne $passwd} {
					set changepw [Classy::yorn "Do you really want to change your password"]
					putsvars changepw
					if {$changepw} break
					set newpasswd [Classy::getpasswd $passwd]
				}
			} else {
				set passwd [Classy::getpasswd]
			}
			set ::env(CLASSY_PASS) $passwd
			set f [open "|openssl enc -bf -pass env:CLASSY_PASS > $curfile" w]
			fconfigure $f -translation binary
			puts -nonewline $f $temp
			catch {close $f}
			unset ::env(CLASSY_PASS)
		} elseif {[file extension $curfile] eq ".gpg"} {
			if {[info exists passwd]} {
				set newpasswd [Classy::getpasswd $passwd]
				while {$newpasswd ne $passwd} {
					set changepw [Classy::yorn "Do you really want to change your password"]
					putsvars changepw
					if {$changepw} break
					set newpasswd [Classy::getpasswd $passwd]
				}
			} else {
				set passwd [Classy::getpasswd]
			}
			file_write $::Classy::dira(user)/ed_temp $passwd
			set f [open "| [list gpg \
				--batch --yes --symmetric \
				--passphrase-file $::Classy::dira(user)/ed_temp \
				-o $curfile]" w]
			fconfigure $f -translation binary
			puts -nonewline $f $temp
			catch {close $f}
		} else {
			set f [open $curfile w]
			puts -nonewline $f $temp
			close $f
		}
		$object editchanged 0
		catch {wm title [winfo toplevel $object] "$curfile"}
		foreach w [$object.edit link] {
			catch {wm title [winfo toplevel $w] "$curfile"}
		}
	}
}

#doc {Editor command saveas} cmd {
#pathname saveas file
#} descr {
#}
Classy::Editor method saveas {file} {
	private $object options
	if {"$file" == ""} return
	if {"$options(-savecommand)" != ""} {
		return -code error "\"Save as\" not supported from this editorwindow"
	}
	if ![Classy::overwriteyn $file 0] return
	private $object curfile reopenlist
	$object unlink
	set curfile $file
	lappend reopenlist $file
	set reopenlist [lsort $reopenlist]
	$object save
	$object editchanged 0
	catch {wm title [winfo toplevel $object] "$curfile"}
}

#doc {Editor command savedialog} cmd {
#pathname savedialog 
#} descr {
#}
Classy::Editor method savedialog {} {
	private $object curfile
	$object saveas [Classy::savefile -title "Save as" \
		-transfercommand "$object transfercommand" -initialfile $curfile]
}

#doc {Editor command transfercommand} cmd {
#pathname transfercommand 
#} descr {
#}
Classy::Editor method transfercommand {} {
	set type [string trimleft [file extension [$object.savedialog get]] "."]
	return [varsubst {type object} {$type {$object get 1.0 end}}]
}

#doc {Editor command loadnext} cmd {
#pathname loadnext 
#} descr {
#}
Classy::Editor method loadnext {} {
	private $object curfile reopenlist
	set pos [lsearch -exact $reopenlist $curfile]
	incr pos
	if {$pos==[llength $reopenlist]} {set pos 0}
	set file [lindex $reopenlist $pos]
	$object load $file
}

#doc {Editor command loadprev} cmd {
#pathname loadprev 
#} descr {
#}
Classy::Editor method loadprev {} {
	private $object curfile reopenlist
	set pos [lsearch -exact $reopenlist $curfile]
	if {$pos==0} {set pos [llength $reopenlist]}
	incr pos -1
	set file [lindex $reopenlist $pos]
	$object load $file
}

#doc {Editor command close} cmd {
#pathname close 
#} descr {
#}
Classy::Editor method close {} {
	if [true [$object closefile]] {
		eval [getprivate $object options(-closecommand)]
	}
}

#doc {Editor command closefile} cmd {
#pathname closefile 
#} descr {
#}
Classy::Editor method closefile {} {
	private $object curfile curmarkers curmarker prevmarker cur
	private $class editing
	if [true [$object editchanged]] {
		set temp [Classy::yorn "File not saved!\nSave file first?" -close yes]
		switch $temp {
			1 {$object save}
			close {return false}
		}
	}
	set cur(pos,$curfile) [$object index insert]
	set cur(curmarker,$curfile) $curmarker
	set cur(prevmarker,$curfile) $prevmarker
	set curmarkers($curfile) [$object marker lget]
	if {"$curmarkers($curfile)" == ""} {unset curmarkers($curfile)}
	$object.edit unlink
	$object.edit delete 1.0 end
	set temp [file_fullpath $curfile]
	if [info exists editing($temp)] {
		set editing($temp) [list_remove $editing($temp) $object]
		if {"$editing($temp)"==""} {unset editing($temp)}
	}
	return true
}

#doc {Editor command load} cmd {
#pathname load ?filename? ?filename ...?
#} descr {
#}
Classy::Editor method load {{file {}} args} {
	if {$file eq ""} {
		if {[catch {
			set args [Classy::selectfile -title Open -selectmode persistent]
		}]} return
		set file [list_shift args]
	}
	if {$file eq ""} return
	private $object curfile curmarkers curmarker prevmarker reopenlist cur options passwd
	private $class editing
	set options(-savecommand) ""
	if {"[$object closefile]" != "true"} {return}
	set curfile [file_fullpath $file]
#	::Classy::busy add $object
	if [info exists editing($curfile)] {
		$object editchanged 0
		set w [lindex $editing($curfile) 0]
		$object.edit link $w.edit
	} else {
		if [file exists $curfile] {
			if {[file isdir $curfile]} {
				error "Cannot open directory \"$curfile\""
			}
			if {[file extension $curfile] eq ".bf"} {
				if {[info exists passwd]} {
					set passwd [Classy::getpasswd $passwd]
				} else {
					set passwd [Classy::getpasswd]
				}
				set ::env(CLASSY_PASS) $passwd
				set f [open "|openssl enc -d -bf -pass env:CLASSY_PASS < $curfile" r]
				fconfigure $f -translation binary
				set temp [read $f]
				catch {close $f}
				unset ::env(CLASSY_PASS)
			} elseif {[file extension $curfile] eq ".gpg"} {
				if {[info exists passwd]} {
					set passwd [Classy::getpasswd $passwd]
				} else {
					set passwd [Classy::getpasswd]
				}
				set f [open "| [list echo $passwd \
					| gpg -d \
						--batch --yes --passphrase-fd 0 \
						$curfile]" r]
				fconfigure $f -translation binary
				set temp [read $f]
				catch {close $f}
			} else {
				unset -nocomplain passwd
				set f [open $curfile r]
				set temp [read $f]
				close $f
			}
			$object.edit insert end $temp
		}
		$object clearundo
		$object editchanged 0
	}
	if [info exists cur(pos,$curfile)] {
		$object mark set insert $cur(pos,$curfile)
		$object see insert
	} else {
		$object mark set insert 1.0
		$object see insert
	}
	if [info exists curmarkers($curfile)] {
		eval $object marker list_set $curmarkers($curfile)
	}
	if [info exists cur(curmarker,$curfile)] {
		set curmarker $cur(curmarker,$curfile)
	}
	if [info exists cur(prevmarker,$curfile)] {
		set prevmarker $cur(prevmarker,$curfile)
	}
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
	lappend editing($curfile) $object
#	::Classy::busy remove $object
	$object editchanged 0
	return $curfile
}

#doc {Editor command set} cmd {
#pathname set data
#} descr {
#}
Classy::Editor method set {data} {
	private $object curfile curmarkers curmarker prevmarker cur

	if {"[$object closefile]" != "true"} {return}
	set curfile ""
	$object insert 0.0 $data
	$object clearundo
	$object editchanged 0
}

#doc {Editor command reopenlist} cmd {
#pathname reopenlist 
#} descr {
#}
Classy::Editor method reopenlist {} {
	private $object curfile reopenlist
	set w $object.reopenlist
	destroy $w
	# use listvariable, so -deletecommand does not actually have to do something
	Classy::SelectDialog $w -title "Reopen list" \
		-command "$object load" \
		-deletecommand "Classy::nop" \
		-listvariable [privatevar $object reopenlist] \
		-filtervariable [privatevar $object reopenfilter]
	set reopenlist [lsort $reopenlist]
	update
	$w set $curfile
}

#doc {Editor command findsel} cmd {
#pathname findsel direction
#} descr {
# direction can be -forwards or -backwards
#}
Classy::Editor method findsel {dir} {
	private $object findwhat
	if {"[$object tag ranges sel]" != ""} {
		if {"$dir" == "-forwards"} {set index sel.last} else {set index sel.first}
		set findwhat [$object get sel.first sel.last]
	}
	$object find $findwhat $dir
}

Classy::Editor method replace-find {dir} {
	private $object findwhat replace
	if {"[$object tag ranges sel]"==""} {
		if {"$dir" == "-forwards"} {set index sel.last} else {set index sel.first}
		set findwhat [$object get sel.first sel.last]
	}
	eval $object delete sel.first sel.last
	$object insert insert $replace
	$object find $findwhat $dir -exact
}

#doc {Editor command find} cmd {
#pathname find what ?option? ?value? ?option value?
#} descr {
#}
Classy::Editor method find {what args} {
	private $object options
	if ![regexp -- {-case|-nocase} $args] {
		lappend args -$options(-searchcase)
	}
	regsub -- {-case} $args {} args
	if ![regexp -- {-exact|-regexp} $args] {
		lappend args -$options(-searchtype)
	}
	set stopindex {}
	if [regexp -- {-backwards} $args] {
		set nextcmd "$object loadprev"
		set index "insert"
		set startindex end
		set stopindex 1.0
	} else {
		set nextcmd "$object loadnext"
		set index "insert+1c"
		set startindex 1.0
		set stopindex end
	}
	set ::Classy::number 0
	if $options(-searchreopen) {
		private $object curfile
		set startfile $curfile
		set startpos [$object index $index]
		if [$object compare $startpos != $stopindex] {
			set pos [eval {$object search -count ::Classy::number} $args -- {$what} $index $stopindex]
		} else {
			set pos ""
		}
		while {"$pos" == ""} {
			eval $nextcmd
			if {"$curfile" != "$startfile"} {
				set pos [eval {$object search -count ::Classy::number} $args -- {$what} $startindex $stopindex]
			} else {
				set pos [eval {$object search -count ::Classy::number} $args -- {$what} $startindex $startpos]
				break
			}
		}
		unset -nocomplain startfile
		unset -nocomplain startpos
	} else {
		set pos [eval {$object search -count ::Classy::number} $args -- {$what} $index]
	}
	if {"$pos" == ""} {error "Not found"}
	$object mark set insert $pos
	catch {$object tag remove sel sel.first sel.last}
	$object tag add sel insert "insert + $::Classy::number c"
	$object see insert
}

#doc {Editor command gotoline} cmd {
#pathname gotoline line
#} descr {
#}
Classy::Editor method gotoline {line {pos 0}} {
	$object mark set insert $line.$pos
	catch {$object tag remove sel sel.first sel.last}
	$object see insert
}

Classy::Editor method goto {spec {pattern {}}} {
	private $object curfile
	if ![regexp {^(.+):([0-9]+)} $spec temp file line] {return}
	set file [file_fullpath $file]
	if {![string_equal $file $curfile]} {
		$object load $file
	}
	$object gotoline $line
	if {![string_equal $pattern ""]} {
		set sline [$object get insert "insert lineend"]
		regexp -indices -- $pattern $sline poss
		set start [lindex $poss 0]
		set end [expr {[lindex $poss 1]+1}]
	} else {
		set start 0
		set end end
	}
	focus $object
	catch {$object gotoline $line $start}
	catch {$object tag add sel $line.$start $line.$end}
}

#doc {Editor command command} cmd {
#pathname command command
#} descr {
#}
Classy::Editor method command {command} {
	eval $command
}

#doc {Editor command replace} cmd {
#pathname replace ?all?
#} descr {
#}
Classy::Editor method replace {args} {
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
		$object find $findwhat -$options(-searchdir)
	}
}

#doc {Editor command finddialog} cmd {
#pathname finddialog 
#} descr {
#}
Classy::Editor method finddialog {} {
	private $object options
	set options(-searchdir) forwards
	set w $object.find
	if ![winfo exists $w] {
		Classy::Dialog $w -cache 1
		wm title $w Find
		set what "\[$w.options.find get\] "
		$w add find Find "$object find $what -\[set [privatevar $object options(-searchdir)]\]" default
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

#doc {Editor command indentedcr} cmd {
#pathname indentedcr 
#} descr {
#}
Classy::Editor method indentedcr {} {
	set line [$object get "insert linestart" "insert lineend"]
	$object insert insert "\n"
	if [regexp "(^\[ \t\]+)" $line prefix] {
		$object insert insert $prefix
	}
}

#doc {Editor command indent} cmd {
#pathname indent number
#} descr {
#}
Classy::Editor method indent {number} {
	if {[$object tag ranges sel] == ""} return
	regexp {^([0-9]+)\.} [$object index sel.first] temp begin
	regexp {^([0-9]+)\.} [$object index sel.last] temp end
	if {$number>=0} {
		set insert ""
		for {set i 0} {$i<$number} {incr i} {
			append insert "\t"
		}
		for {set i $begin} {$i<$end} {incr i} {
			$object insert $i.0 $insert
		}
	} else {
		set number [expr -$number]
		for {set i $begin} {$i<$end} {incr i} {
			set temp [$object get $i.0 $i.$number]
			if [regexp "^\[\t \]*$" $temp] {
				$object delete $i.0 $i.$number
			}
		}
	}
}

array set Classy::Editor_trace_ignore {
	finddialog 1
	savedialog 1
}

proc Classy::Editor_trace {object var command} {
	set w [list_shift command]
	set level [info level]
	if [info exists ::Classy::Editor_trace_ignore($command)] return
	if {$level == 1} {
		if {[lsearch -exact {trace index} [lindex $command 0]] == -1} {
			lappend $var "\$object $command"
		}
	}
}

#doc {Editor command macro} cmd {
#pathname macro 
#} descr {
#}
Classy::Editor method macro {} {
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
		$object trace [list Classy::Editor_trace $object [privatevar $object macro]]
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
		-combopreset {Classy::Default get app Classy::Editor_macros} \
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

#doc {Editor command setmacro} cmd {
#pathname setmacro name command ?key?
#} descr {
#}
Classy::Editor method setmacro {name command {key {}}} {
	if {"$name"==""} {
		error "No name selected"
		return
	}
	set macros [Classy::Default get app Classy::Editor_macros]
	list_addnew macros $name
	Classy::Default set app Classy::Editor_macros $macros
	Classy::Default set app Classy::Editor_macro_$name [list $command $key]
	Classy::update Classy::Editor-setmacro idletasks
	Classy::DynaMenu updateactive Classy_Editor
}

#doc {Editor command deletemacro} cmd {
#pathname deletemacro
#} descr {
#}
Classy::Editor method deletemacro {name} {
	if {"$name"==""} {
		error "No name selected"
		return
	}
	Classy::Default unset app Classy::Editor_macro_$name
	Classy::DynaMenu updateactive Classy_Editor
}

#doc {Editor command getmacromenu} cmd {
#pathname getmacromenu
#} descr {
#}
Classy::Editor method getmacromenu {} {
	set data {action "Manage Macros" "%W macro" <<Macro>>}
	append data "\n"
	set names ""
	foreach m [Classy::Default names app Classy::Editor_macro_*] {
		regexp {^Classy::Editor_macro_(.*)$} $m temp name
		set temp [Classy::Default get app Classy::Editor_macro_$name]
		set key [lindex $temp 1]
		append data "action \"$name\" \{[list %W runmacro $name]\}"
		if {"$key" == ""} {
			append data "\n"
		} else {
			append data " <$key>\n"
		}
		lappend names $name
	}
	Classy::Default set app Classy::Editor_macros $names
	return [list $data Classy::Menu_macro]
}

#doc {Editor command pattern args} cmd {
#pathname pattern ?value?
#} descr {
#}
Classy::Editor method pattern {args} {
	private $object pattern temppattern
	if {"$args" != ""} {
		set pattern [lindex $args 0]
	} else {
		set temppattern $pattern
		Classy::InputDialog $object.pattern -label Pattern \
			-textvariable [privatevar $object temppattern] -combo 20 \
			-command "[list $object] pattern \[get [list [privatevar $object temppattern]]\]"
	}
}

#doc {Editor command getpatternmenu} cmd {
#pathname getpatternmenu
#} descr {
#}
Classy::Editor method getpatternmenu {} {
	private $object pattern
	if ![info exists pattern] {
		set pattern {^proc |^Classy }
	}
	set data {action "Set pattern" "%W pattern"}
	append data "\n"
	set names ""
	set index 1.0
	set num 1
	set end [$object.edit index end]
	while 1 {
		set r [$object.edit search -regexp -- $pattern $index end]
		if {$r eq ""} break
		set line [$object.edit get "$r linestart" "$r lineend"]
		append data [list action $line "[list %W see $r]\n[list %W mark set insert $r]" <<Pattern$num>>]\n
		incr num
		set line [lindex [split $r .] 0]
		incr line
		set index $line.0
		if {$index eq $end} break
	}
	return [list $data Classy::Menu_pattern]
}

#doc {Editor command getmacro} cmd {
#pathname getmacro 
#} descr {
#}
Classy::Editor method getmacro {} {
	set name [$object.macro.options.name get]
	set temp [Classy::Default get app Classy::Editor_macro_$name]
	$object.macro.options.text delete 1.0 end
	$object.macro.options.text insert end [lindex $temp 0]
	$object.macro.options.key set [lindex $temp 1]
}

#doc {Editor command runmacro} cmd {
#pathname runmacro name
#} descr {
#}
Classy::Editor method runmacro {name} {
	set temp	[Classy::Default get app Classy::Editor_macro_$name]
	eval [lindex $temp 0]
}

#doc {Editor command comment} cmd {
#pathname comment add/remove
#} descr {
#}
Classy::Editor method comment {command} {
	set w $object
	switch $command {
		add {
			if {[$w tag ranges sel] == ""} {
				$w insert "insert linestart" "#"
				tk::TextSetCursor $w [tk::TextUpDownLine $w 1]
			} else {
				regexp {^([0-9]+)\.} [$w index sel.first] temp begin
				regexp {^([0-9]+)\.} [$w index sel.last] temp end
				for {set i $begin} {$i<$end} {incr i} {
					$w insert $i.0 "#"
				}
			}
		}
		remove {
			if {[$w tag ranges sel] == ""} {
				if {[$w get "insert linestart"] == "#"} {
					$w delete "insert linestart"
					tk::TextSetCursor $w [tk::TextUpDownLine $w 1]
				}
			} else {
				regexp {^([0-9]+)\.} [$w index sel.first] temp begin
				regexp {^([0-9]+)\.} [$w index sel.last] temp end
				for {set i $begin} {$i<$end} {incr i} {
					if {[$w get $i.0] == "#"} {
						$w delete $i.0
					}
				}
			}
		}
	}
}

#doc {Editor command format} cmd {
#pathname format length
#} descr {
#}
Classy::Editor method format {{length {}}} {
	set w $object
	if {![isint $length]} {
		set length [$object cget -formatlength]
	}
	set index [$w index "insert linestart"]
	set spos [lindex [split $index .] 0]
	set lpos $spos
	set list {}
	while 1 {
		set line [$w get "$lpos.0" "$lpos.end"]
		if {$line eq ""} break
		lappend list [string trim $line]
		incr lpos
	}
	set line [join $list " "]
	set line [split $line " "]
	set pos 0
	set result {}
	set list {}
	foreach el $line {
		set len [string length $el]
		set pos [expr {$pos+$len+1}]
		if {$pos < $length} {
			lappend list $el
		} else {
			lappend result [join $list " "]
			set list [list $el]
			set pos [expr $len+1]
		}
	}
	lappend result [join $list " "]
	$w delete $index "$lpos.0-1c"
	$w insert $spos.end [join $result \n]
	$w mark set insert $index
}

#doc {Editor command transpose} cmd {
#pathname transpose pos
#} descr {
#}
Classy::Editor method transpose {{pos {}}} {
	if {![isint $pos]} {
		set pos [$object index insert]
	}
	if [$object compare $pos != "$pos lineend"] {
		set pos [$object index "$pos + 1 char"]
	}
	set new [$object get "$pos - 1 char"][$object get  "$pos - 2 char"]
	if [$object compare "$pos - 1 char" == 1.0] {
		return
	}
	$object delete "$pos - 2 char" $pos
	$object insert insert $new
	$object see insert
}

#doc {Editor command case} cmd {
#pathname case type
#} descr {
#}
Classy::Editor method case {{type tolower}} {
	foreach {start end} [$object tag ranges sel] break
	if {![info exists start]} {
		set start [$object index insert]
		set end [$object index "insert + 1 char"]
	} else {
		set sel 1
	}
	set value [$object get $start $end]
	set value [string $type $value]
	$object delete $start $end
	$object insert insert $value
	if {[info exists sel]} {
		$object tag add sel $start $end
	}
}

#doc {Editor command matchingbrackets} cmd {
#pathname matchingbrackets 
#} descr {
#}
Classy::Editor method matchingbrackets {} {
	set w $object
	set startpattern "\{|\\\(|\\\["
	set endpattern "\}|\\\)|\\\]"
	if {[$w tag ranges sel] == ""} {
		set curstart [$w index insert]
		set curend [$w index insert]
	} else {
		set curstart [$w index sel.first]
		set curend [$w index sel.last]
	}
	set num 1
	while 1 {
		set start [$w search -backwards -regexp -- "$startpattern|$endpattern" $curstart 1.0]
		if {"$start" == ""} {
			set start 1.0
			break
		}
		if [regexp $endpattern [$w get $start]] {
			set curstart $start
			incr num
		} elseif [regexp $startpattern [$w get $start]] {
			set curstart $start
			incr num -1
		}
		if {$num==0} break
	}
	set num 1
	while 1 {
		set end [$w search -forwards -regexp -- "$startpattern|$endpattern" $curend end]
		if {"$end" == ""} {
			set end end
			break
		}
		if [regexp $startpattern [$w get $end]] {
			set curend [$w index "$end +1 c"]
			incr num
		} elseif [regexp $endpattern [$w get $end]] {
			set curend [$w index "$end +1 c"]
			incr num -1
		}
		if {$num==0} break
	}
	$w tag add sel $start "$end +1 c"
}

#doc {Editor command marker} cmd {
#pathname marker command ?args?
#} descr {
#command must be one of
#<dl>
#<dt>set
#<dt>delete
#<dt>goto
#<dt>current
#<dt>previous
#<dt>select
#<dt>refresh
#<dt>list_set
#<dt>lget
#</dl>
#}
Classy::Editor method marker {command args} {
	private $object marker
	set we $object.edit
	set arg [lindex $args 0]
	switch $command {
		set {
			private $object curmarker prevmarker
			if {"$arg" != ""} {
				set newmarker $arg
			} else {
				set newmarker mark
			}
			set names [$we mark names]
			set names [list_remove $names anchor current insert]
			if {[lsearch -exact $names $newmarker] != -1} {
				set num 1
				regsub { [0-9]+$} $newmarker {} base
				while {[lsearch -exact $names "$newmarker $num"] != -1} {
					incr num
				}
				set newmarker "$newmarker $num"
			}
			if {"[$we tag ranges sel]"==""} {
				$we mark set $newmarker insert
			} else {
				set select [$we get sel.first sel.last]
				$we mark set $newmarker sel.first
				$we mark set $newmarker' sel.last
			}
			set prevmarker $curmarker
			set curmarker $newmarker
			$object marker refresh
			return {}
		}
		delete {
			private $object curmarker prevmarker
			if {"$curmarker"=="$arg"} {set curmarker {}}
			if {"$prevmarker"=="$arg"} {set prevmarker {}}
			$we mark unset $arg
			$object marker refresh
		}
		goto {
			private $object curmarker prevmarker
			if {"$arg"==""} {return}
			if {"$curmarker" != "$arg"} {
				set prevmarker $curmarker
			}
			set curmarker $arg
			catch {$we tag remove sel 0.0 end}
			$we mark set insert [$object index $arg]
			catch {$we tag add sel insert [$object index $arg']}
			$we see insert
		}
		current {
			private $object curmarker
			$object marker goto $curmarker
		}
		previous {
			private $object prevmarker
			$object marker goto $prevmarker
		}
		select {
			set w $object.selectmark
			if [winfo exists $w] {
				$w place
			} else {
				if ![winfo exists $w] {
					Classy::SelectDialog $w -title "Select mark" -cache 1 \
						-command "$object marker goto" \
						-addcommand "$object marker set" \
						-deletecommand "$object marker delete"
				} else {
					$w place
				}
			}
			private $object curmarker
			if [info exists $curmarker] {
				$w set $curmarker
			 }
			$object marker refresh
		}
		refresh {
			set w $object.selectmark
			set names [$we mark names]
			set names [list_remove $names anchor current insert]
			set names [list_sub $names -exclude [list_find -regexp $names {'$}]]
			if {"$names" != ""} {$w fill $names}
		}
		list_set {
			array set temp $args
			foreach name [array names temp] {
				$we mark set $name $temp($name)
			}
			$object marker refresh
		}
		lget {
			set result ""
			set names [$we mark names]
			set names [list_remove $names anchor current insert]
			foreach name $names {
				lappend result $name
				lappend result [$we index $name]
				$we mark unset $name
			}
			return $result
			$object marker refresh
		}
	}
}

Classy::Editor method _reconfigure {} {
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
	Classy::update Classy::Editor-_reconfigure idletasks
}

Classy::Editor method cut {} {
	$object.edit cut
}

Classy::Editor method paste {} {
	$object.edit paste
}

Classy::Editor method undo {} {
	$object.edit undo
}

Classy::Editor method redo {} {
	$object.edit redo
}

#doc {Editor command editchanged} cmd {
#pathname editchanged
#} descr {
#}
Classy::Editor method editchanged {{bool {}}} {
	if ![llength $bool] {
		return [$object.edit textchanged]
	}
	if $bool {
		set top [winfo toplevel $object]
		set title [wm title $top]
		if ![regexp { \*$} $title] {catch [wm title $top "$title *"]}
		$object.edit configure -changedcommand {}
		$object.edit textchanged $bool
	} else {
		set top [winfo toplevel $object]
		regsub { *$} [wm title $top] {} title
		catch {wm title $top $title}
		$object.edit configure -changedcommand [list $object editchanged]
		$object.edit textchanged 0
	}
}

proc Classy::title {w title} {
	wm title $w $title
	wm iconname $w $title
}

proc Classy::edit {args} {
#	if {"$args"==""} {set args "Newfile"}
	set w .classy__.edit
	set num 1
	while {[winfo exists $w$num] == 1} {incr num}
	set w $w$num
	catch {destroy $w}
	toplevel $w -bd 0 -highlightthickness 0
	wm protocol $w WM_DELETE_WINDOW "destroy $w"
	Classy::Editor $w.editor -loadcommand "Classy::title $w" -closecommand "after idle \{destroy $w\}" -setgrid yes
	pack $w.editor -fill both -expand yes
	if {"$args"!=""} {
		eval $w.editor load $args
	}
	return $w
}

proc edit {args} {
	eval Classy::edit $args
}

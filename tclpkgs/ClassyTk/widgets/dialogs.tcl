#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Classy::yorn
# ----------------------------------------------------------------------
#doc yorn title {
#Classy::yorn
#} index {
# Dialogs
#} shortdescr {
# select yes or no
#}
#doc {yorn yorn} cmd {
#Classy::yorn message ?option value ...?
#} descr {
# displays $message with a choice of yes or no (or close).
# returns 1 if the the user answers yes, 0 if the user answers no
# and close if the user clicked the close button.
#<dl>
#<dt>-close<dd>must be 1 or 0
#</dl>
#}
proc Classy::yorn {message args} {
	Classy::parseopt $args opt {
		-close {1 0 yes no true false} no
		-title {} "Yes or No"
	} remain
	if {"$remain" != ""} {error "bad options \"$remain\""}
	if {("[option get . messageDialog MessageDialog]"=="Classy") || ([string length $message] > 1000)} {
		Classy::yornDialog .classy__.yorn -yescommand {set ::Classy::yorn 1} \
			  -nocommand {set ::Classy::yorn 0} \
			  -closecommand {set ::Classy::yorn close} \
			  -title $opt(-title) -message $message -keepgeometry 0
		if {![true $opt(-close)]} {
			destroy .classy__.yorn.actions.close
			bind .classy__.yorn <Escape> {.classy__.yorn invoke no}
		}
		if [info exists opt(-help)] {.classy__.yorn configure -help $opt(-help)}
		Classy::update Classy::yorn idletasks
		grab set .classy__.yorn
		tkwait window .classy__.yorn
		Classy::update Classy::yorn2 idletasks
	} else {
		if {![true $opt(-close)]} {
			set result [tk_messageBox -type yesno -title $opt(-title) -message $message]
		} else {
			set result [tk_messageBox -type yesnocancel -title $opt(-title) -message $message]
		}		
		switch $result {
			yes {set ::Classy::yorn 1}
			no {set ::Classy::yorn 0}
			cancel {set ::Classy::yorn close}
		}
	}
	return $::Classy::yorn
}

#doc messageBox title {
#Classy::messageBox
#} index {
# Dialogs
#} shortdescr {
# show a message dialog
#}
#doc {messageBox messageBox} cmd {
#Classy::messageBox message ?option value ...?
#} descr {
# displays $message.
#<dl>
#<dt>-title<dd>title of dialog
#</dl>
#}
proc Classy::messageBox {message args} {
	Classy::parseopt $args opt {
		-title {} Message
	} remain
	if {"[option get . messageDialog MessageDialog]"=="Classy"} {
		set w .classy__.message
		Classy::Dialog $w -title $opt(-title) -closebutton 0
		$w add ok "Ok" {} default
		Classy::Message $w.options.message -width 200 -justify center -text $message
		pack $w.options.message -fill both -expand yes
		Classy::update Classy::messageBox idletasks
		grab set $w
		tkwait window $w
	} else {
		tk_messageBox -title $opt(-title) -message $message
	}
}

#doc getvalue title {
#Classy::getvalue
#} index {
# Dialogs
#} shortdescr {
# Let user enter a value
#}
#doc {getvalue getvalue} cmd {
#Classy::getvalue ?option value ...?
#} descr {
# Let user enter a value, the type of which is determined by the option -type (string for string values)
#<dl>
#<dt>-title<dd>any
#<dt>-type<dd>string or number
#<dt>-label<dd>any
#<dt>-initialvalue<dd>any
#<dt>-close<dd>must be 1 or 0
#</dl>
#}
proc Classy::getvalue {args} {
	Classy::parseopt $args opt {
		-close {1 0 yes no true false} no
		-title {} "Enter value"
		-label {} "Enter value"
		-type {} string
		-initialvalue {} {}
	} remain
	if {[string equal $opt(-type) string]} {
		Classy::InputDialog .classy__.getvalue -command {set ::Classy::getvalue} \
			  -closecommand {unset -nocomplain ::Classy::getvalue} \
			  -title $opt(-title) -label $opt(-label)
	} else {
		Classy::NumInputDialog .classy__.getvalue -command {set ::Classy::getvalue} \
			  -closecommand {unset -nocomplain ::Classy::getvalue} \
			  -title $opt(-title) -label $opt(-label)
	}
	eval .classy__.getvalue configure $remain
	.classy__.getvalue set $opt(-initialvalue)
	if {![true $opt(-close)]} {
		destroy .classy__.getvalue.actions.close
		bind .classy__.getvalue <Escape> {.classy__.getvalue destroy}
	}
	if [info exists opt(-help)] {.classy__.getvalue configure -help $opt(-help)}
	Classy::update Classy::getvalue idletasks
	grab set .classy__.getvalue
	tkwait window .classy__.getvalue
	Classy::update Classy::getvalue2 idletasks
	return [get ::Classy::getvalue ""]
}

#doc selectoption title {
#Classy::selectoption
#} index {
# Dialogs
#} shortdescr {
# select on of several options
#}
#doc {selectoption selectoption} cmd {
#Classy::selectoption ?option value ...? list
#} descr {
# Presents the user with a dialog showing an optionbox
# The list of possible options is given by list:
# it presents alternatingly the text to be shown in the optionbox
# and the value to be returned when this option is chosen
#<dl>
#<dt>-title<dd>any
#<dt>-initialvalue<dd>any
#</dl>
#}
proc Classy::selectoption {args} {
# Classy::selectoption -title Test -initialvalue 2 {{First choice} 1 {Second choice} 2}
# set args {{First choice} 1 {Second choice} 2}
	set opt(-initialvalue) ""
	set opt(-title) "Select option"
	cmd_args "Classy::selectoption" {
		-initialvalue {any "Initial selection" {}}
		-title {any "Title of the dialog" "Select option"}
	} {list} $args
	if {$opt(-initialvalue) eq ""} {
		set ::Classy::selectoption [lindex $list 1]
	} else {
		set ::Classy::selectoption $opt(-initialvalue)
	}
	set w .classy__.optiondialog
	destroy $w
	Classy::Dialog $w -title $opt(-title) -keepgeometry 0 -resize {0 0} -closecommand {destroy .classy__.optiondialog ; unset -nocomplain ::Classy::selectoption}
	$w add go OK {} default
	set w $w.options
	Classy::OptionBox $w.optionbox -label "$opt(-title)" -orient vertical -variable ::Classy::selectoption
	foreach {text value} $list {
		$w.optionbox add $value $text
	}
	pack $w.optionbox -fill x
	tkwait window .classy__.optiondialog
	if {![info exists ::Classy::selectoption]} {
		error "Nothing selected"
	}
	return $::Classy::selectoption
}

#doc selectaction title {
#Classy::selectaction
#} index {
# Dialogs
#} shortdescr {
# select on of several actions (on buttons)
#}
#doc {selectaction selectaction} cmd {
#Classy::selectaction ?option value ...? list
#} descr {
# Presents the user with a dialog showing a message
# Possible actions are given as buttons
#<dl>
#<dt>-message<dd>any
#<dt>-title<dd>any
#<dt>-default<dd>any
#</dl>
#}
proc Classy::selectaction {args} {
# Classy::selectaction -title Test -default {Second choice} {{First choice} {Second choice}}
# set args {{{First choice} {Second choice}}}
	set opt(-default) ""
	set opt(-title) "Select Action"
	set opt(-message) "Select an action"
	cmd_args "Classy::selectoption" {
		-default {any "Default action" {}}
		-title {any "Title of the dialog" "Select Action"}
		-message {any "Message" "Select an action"}
	} {list} $args
	if {$opt(-default) eq ""} {
		set default [lindex $list 0]
	} else {
		set default $opt(-default)
	}
	set w .classy__.actiondialog
	destroy $w
	Classy::Dialog $w -title $opt(-title) -keepgeometry 0 -resize {0 0} -closecommand {destroy .classy__.optiondialog ; unset -nocomplain ::Classy::selectaction}
	Classy::Message $w.options.msg -text $opt(-message)
	pack $w.options.msg -fill both -expand yes
	set num 1
	foreach action $list {
		if {$action eq $default} {
			$w add b$num $action [list set ::Classy::selectaction $action] default
		} else {
			$w add b$num $action [list set ::Classy::selectaction $action]
		}
		$w persistent remove b$num
		incr num
	}
	tkwait window .classy__.actiondialog
	if {![info exists ::Classy::selectaction]} {
		error "Action canceled"
	}
	return $::Classy::selectaction
}

proc main args {
source [file join $::Classy::dir widgets WindowBuilderTypes.tcl]
mainw .mainw
}

proc drawwidget {window type} {
global grid
catch {destroy $window.test.widget}
$type $window.test.widget
set sticky nw
if $grid(hor) {append sticky e}
if $grid(vert) {append sticky s}
grid $window.test.widget -row 0 -column 0 -sticky $sticky
grid columnconfigure $window.test 0 -weight 1
grid rowconfigure $window.test 0 -weight 1

set list ""
foreach conf [$window.test.widget configure] {
	lappend list [lindex $conf 0]
}

$window.frame.options configure -content $list

catch {destroy $window.test.vscroll}
catch {destroy $window.test.hscroll}
if $grid(vscroll) {
	scrollbar $window.test.vscroll -orient vertical \
		-command [list $window.test.widget yview]
	$window.test.widget configure \
		-yscrollcommand [list $window.test.vscroll set]
	grid $window.test.vscroll -row 0 -column 1 -sticky ns
}

if $grid(hscroll) {
	scrollbar $window.test.hscroll -orient horizontal \
		-command [list $window.test.widget xview]
	$window.test.widget configure \
		-xscrollcommand [list $window.test.hscroll set]
	grid $window.test.hscroll -row 1 -column 0 -sticky we
}

catch {$window.test.widget {}} result
regsub {,? or ([^,]*)$} $result {, \1} result
regexp {^(bad|ambiguous) option "": must be (.*)$} $result temp t f l
set list [list_remove [split $f ", "] {}]
lappend list $l
$window.cmds configure -content $list

set ::w $window.test.widget

}

proc selectoption {window option} {
#putsvars window option
$window.optionvalue configure -label $option
if [info exists ::Classy::WindowBuilder::options($option)] {
	$window.optionvalue configure -type [lindex $::Classy::WindowBuilder::options($option) end]
} else {
	$window.optionvalue configure -type line
}
$window.optionvalue set [$window.test.widget cget $option]
}

proc changeattribute {object value} {
$object.test.widget configure [$object.frame.options get] $value


}


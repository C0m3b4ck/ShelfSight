Classy::Toplevel subclass mainw
mainw method init args {
	super init
	# Create windows
	frame $object.test  \
		-borderwidth 2 \
		-height 80 \
		-relief groove \
		-width 10
	grid $object.test -row 0 -column 1 -sticky nesw
	Classy::Paned $object.paned2 \
		-orient vertical \
		-cursor sb_v_double_arrow
	grid $object.paned2 -row 2 -column 0 -columnspan 2 -sticky nesw
	Classy::CmdWidget $object.cmd \
		-prompt {[file tail [pwd]] % } \
		-height 8 \
		-width 40
	grid $object.cmd -row 3 -column 1 -sticky nesw
	frame $object.frame  \
		-borderwidth 2 \
		-height 10 \
		-relief groove \
		-width 10
	grid $object.frame -row 0 -column 0 -rowspan 2 -sticky nesw
	Classy::ListBox $object.frame.widgets  \
		-content {frame
entry
button
checkbutton
radiobutton
label
message
scrollbar
listbox
text
canvas
scale
Classy::Entry
Classy::NumEntry
Classy::Message
Classy::ListBox
Classy::Text
Classy::Table
Classy::ScrolledText
Classy::Canvas
Classy::NoteBook
Classy::OptionBox
Classy::OptionMenu
Classy::Paned
Classy::Progress
Classy::ScrolledFrame
Classy::Table
Classy::Fold
Classy::Selector
Classy::TreeWidget
Classy::Browser
Classy::CmdWidget
Classy::DynaTool} \
		-exportselection 0 \
		-height 5 \
		-width 17
	grid $object.frame.widgets -row 0 -column 0 -columnspan 5 -sticky nesw
	Classy::ListBox $object.frame.options  \
		-exportselection 0 \
		-height 4 \
		-width 10
	grid $object.frame.options -row 3 -column 0 -columnspan 5 -sticky nesw
	checkbutton $object.frame.vscroll \
		-indicatoron 0 \
		-text button \
		-variable grid(vscroll)
	grid $object.frame.vscroll -row 2 -column 2 -sticky nesw
	checkbutton $object.frame.hscroll \
		-indicatoron 0 \
		-text button \
		-variable grid(hscroll)
	grid $object.frame.hscroll -row 2 -column 3 -sticky nesw
	checkbutton $object.frame.hresize \
		-indicatoron 0 \
		-text hor \
		-variable grid(hor)
	grid $object.frame.hresize -row 2 -column 1 -sticky nesw
	checkbutton $object.frame.vresize \
		-indicatoron 0 \
		-text vert \
		-variable grid(vert)
	grid $object.frame.vresize -row 2 -column 0 -sticky nesw
	Classy::Entry $object.frame.entry1 \
		-label Other \
		-width 4
	grid $object.frame.entry1 -row 1 -column 0 -columnspan 5 -sticky nesw
	grid columnconfigure $object.frame 4 -weight 1
	grid rowconfigure $object.frame 0 -weight 1
	grid rowconfigure $object.frame 3 -weight 1
	Classy::Selector $object.optionvalue \
		-label Attribute \
		-type line
	grid $object.optionvalue -row 1 -column 1 -sticky nesw
	Classy::ListBox $object.cmds  \
		-height 4 \
		-width 10
	grid $object.cmds -row 3 -column 0 -sticky nesw
	grid columnconfigure $object 1 -weight 1
	grid rowconfigure $object 0 -weight 1

	if {"$args" == "___Classy::Builder__create"} {return $object}
	# Parse this
	$object configure \
		-title [tk appname]
	$object.paned2 configure \
		-window [varsubst object {$object.cmd}]
	$object.frame.widgets configure \
		-browsecommand [varsubst object {drawwidget $object}]
	$object.frame.options configure \
		-browsecommand [varsubst object {selectoption $object}]
	$object.frame.vscroll configure \
		-command [varsubst object catch\ \{\n\t\$object.test.widget\ configure\ \\\n\t\t-xscrollcommand\ \{\}\n\tdestroy\ \$object.test.vscroll\n\}\nif\ \$grid(vscroll)\ \{\n\tscrollbar\ \$object.test.vscroll\ -orient\ vertical\ \\\n\t\t-command\ \[list\ \$object.test.widget\ yview\]\n\t\$object.test.widget\ configure\ \\\n\t\t-yscrollcommand\ \[list\ \$object.test.vscroll\ set\]\n\tgrid\ \$object.test.vscroll\ -row\ 0\ -column\ 1\ -sticky\ ns\n\}] \
		-image [Classy::geticon Builder/vscroll]
	$object.frame.hscroll configure \
		-command [varsubst object catch\ \{\n\t\$object.test.widget\ configure\ \\\n\t\t-xscrollcommand\ \{\}\n\tdestroy\ \$object.test.hscroll\n\}\nif\ \$grid(hscroll)\ \{\n\tscrollbar\ \$object.test.hscroll\ -orient\ horizontal\ \\\n\t\t-command\ \[list\ \$object.test.widget\ xview\]\n\t\$object.test.widget\ configure\ \\\n\t\t-xscrollcommand\ \[list\ \$object.test.hscroll\ set\]\n\tgrid\ \$object.test.hscroll\ -row\ 1\ -column\ 0\ -sticky\ we\n\}] \
		-image [Classy::geticon Builder/hscroll]
	$object.frame.hresize configure \
		-command [varsubst object {set sticky nw
if $grid(hor) {append sticky e}
if $grid(vert) {append sticky s}
grid $object.test.widget -row 0 -column 0 -sticky $sticky}] \
		-image [Classy::geticon orient_horizontal]
	$object.frame.vresize configure \
		-command [varsubst object {set sticky nw
if $grid(hor) {append sticky e}
if $grid(vert) {append sticky s}
grid $object.test.widget -row 0 -column 0 -sticky $sticky}] \
		-image [Classy::geticon orient_vertical]
	$object.frame.entry1 configure \
		-command [varsubst object {drawwidget $object}]
	$object.optionvalue configure \
		-command [varsubst object {changeattribute $object}]
	$object.cmds configure \
		-browsecommand [varsubst object {invoke value {
	$object.cmd insert end "\$w $value"
	focus $object.cmd
}}]
	# Configure initial arguments
	if {"$args" != ""} {eval $object configure $args}
# ClassyTk Finalise
set ::grid(hor) 1
set ::grid(vert) 1
	return $object
}


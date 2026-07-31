namespace eval ::Classy::WindowBuilder {}
namespace eval ::Classy::WindowBuilder::start_Classy {}
namespace eval ::Classy::WindowBuilder::stop_Classy {}
namespace eval ::Classy::WindowBuilder::edit_Classy {}
namespace eval ::Classy::WindowBuilder::generate_Classy {}
namespace eval ::Classy::WindowBuilder::attr_Classy {}
namespace eval ::Classy::WindowBuilder::add_Classy {}
namespace eval ::Classy::WindowBuilder::delete_Classy {}
namespace eval ::Classy::WindowBuilder::configure_Classy {}
namespace eval ::Classy::WindowBuilder::parse_Classy {}

lappend auto_path [file join $Classy::dir widgets Builder]
array set ::Classy::WindowBuilder::parents {
	Toplevel 1 Frame 1 Classy::Toplevel 1
}

array set ::Classy::WindowBuilder::options {
	-activeborderwidth {Sizes int}
	-anchor {Display anchor}
	-bitmap {Display bitmap}
	-borderwidth {Display int}
	-cursor {Display cursor}
	-exportselection bool
	-font {Display font}
	-highlightthickness {Sizes int}
	-image {Display image}
	-insertborderwidth {Sizes int}
	-insertofftime int
	-insertontime int
	-insertwidth {Sizes int}
	-jump bool
	-justify {Display justify}
	-orient {Display orient}
	-padx {Sizes int}
	-pady {Sizes int}
	-relief {Display relief}
	-repeatdelay int
	-repeatinterval int
	-selectborderwidth {Sizes int}
	-setgrid bool
	-takefocus int
	-text {Display text}
	-textvariable {Code string}
	-underline int
	-wraplength {Sizes int}
	-height {Sizes int}
	-width {Sizes int}
	-offset {Sizes string}
	-label {Display text}
	-keepgeometry {Display line}
	-title {Display line}
	-value {Code line}
	-list {Code text}
	-changedcommand {Code text}
	-xscrollcommand {Code text}
	-yscrollcommand {Code text}
	-xlabelcommand {Code text}
	-ylabelcommand {Code text}
	-setxlabelcommand {Code text}
	-setylabelcommand {Code text}
	-getcommand {Code text}
	-setcommand {Code text}
	-browsecommand {Code text}
	-command {Code text}
	-destroycommand {Code text}
	-closecommand {Code text}
	-opencommand {Code text}
	-endnodecommand {Code text}
	-getimage {Code text}
	-gettext {Code text}
	-getdata {Code text}
	-variable {Code line}
	-selectimage {Display image}
	-indicatoron {Display bool}
	-snaptoborder {Code bool}
	-activebackground {Colors color}
	-activeforeground {Colors color}
	-background {Colors color}
	-disabledforeground {Colors color}
	-foreground {Colors color}
	-highlightbackground {Colors color}
	-highlightcolor {Colors color}
	-insertbackground {Colors color}
	-selectbackground {Colors color}
	-selectforeground {Colors color}
	-selectcolor {Colors color}
	-troughcolor {Colors color}
	-labelbackground {Colors color}
	-menu {Display menu}
	-content {Code text}
	command text
	content text
	persistent bool
}
set ::Classy::WindowBuilder::options(common) {
	-textvariable -text -command -justify -image -orient -variable 
	-label -title -destroycommand -closecommand -value -menu -content
}

proc ::Classy::WindowBuilder::attredit_line {object v option title {wide 0}} {
	set var [privatevar $object attredit($v)]
	set $var [$object attribute get $option]
	Classy::Selector $v -type line -label $title -labelwidth $wide \
		-command [varsubst {object v option} {
			$object attribute setf? $option [$v get]
		}] -variable $var
}

proc ::Classy::WindowBuilder::attredit_int {object v option title {wide 0}} {
	set var [privatevar $object attredit($v)]
	set $var [$object attribute get $option]
	Classy::Selector $v -type int -label $title -labelwidth $wide \
		-command [varsubst {object v option} {
			$object attribute setf? $option [$v get]
		}] -variable $var
}

proc ::Classy::WindowBuilder::attredit_text {object v option title {wide 0}} {
	set var [privatevar $object attredit($v)]
	set $var [$object attribute get $option]
	Classy::Selector $v -type text -label $title \
		-command [varsubst {object v option} {
			$object attribute setf? $option [$v get]
		}] -variable $var
}

proc ::Classy::WindowBuilder::attredit_color {object v option title {wide 0}} {
	set var [privatevar $object attredit($v)]
	set $var [$object attribute get $option]
	regexp {\[Classy::realcolor (.+)\]} [set $var] t $var
	Classy::Selector $v -type color -label $title \
		-command [varsubst {object v option} {
			$object attribute setf? $option "\[Classy::realcolor [$v get]\]"
		}] -variable $var
}

proc ::Classy::WindowBuilder::attredit_font {object v option title {wide 0}} {
	set var [privatevar $object attredit($v)]
	set $var [$object attribute get $option]
	Classy::Selector $v -type font -label $title \
		-command [varsubst {object v option} {
			$object attribute setf? $option [$v get]
		}] -variable $var
}

proc ::Classy::WindowBuilder::attredit_justify {object v option title {wide 0}} {
	set var [privatevar $object attredit($v)]
	set $var [$object attribute get $option]
	Classy::Selector $v -type justify -label $title \
		-command [varsubst {object v option} {
			$object attribute setf? $option [$v get]
		}] -variable $var
}

proc ::Classy::WindowBuilder::attredit_bool {object v option title {wide 0}} {
	set var [privatevar $object attredit($v)]
	set $var [$object attribute get $option]
	Classy::Selector $v -type bool -label $title \
		-command [varsubst {object v option} {
			$object attribute setf? $option [$v get]
		}] -variable $var
}

proc ::Classy::WindowBuilder::attredit_orient {object v option title {wide 0}} {
	set var [privatevar $object attredit($v)]
	set $var [$object attribute get $option]
	Classy::Selector $v -type orient -label $title \
		-command [varsubst {object v option} {
			$object attribute setf? $option [$v get]
		}] -variable $var
}

proc ::Classy::WindowBuilder::attredit_relief {object v option title {wide 0}} {
	set var [privatevar $object attredit($v)]
	set $var [$object attribute get $option]
	Classy::Selector $v -type relief -label $title \
		-command [varsubst {object v option} {
			$object attribute setf? $option [$v get]
		}] -variable $var
}

proc ::Classy::WindowBuilder::attredit_anchor {object v option title {wide 0}} {
	set var [privatevar $object attredit($v)]
	set $var [$object attribute get $option]
	Classy::Selector $v -type anchor -label $title \
		-command [varsubst {object v option} {
			$object attribute setf? $option [$v get]
		}] -variable $var
}

proc ::Classy::WindowBuilder::menuset {object args} {
	private $object data bindtags current
	set window $data(base)
	eval set base $window
	set menutype $data(opt-mainmenu,$base)
	if {"$menutype" != ""} {
		set cmdws data(opt-menuwin,$base)
		$base configure -menu [eval Classy::DynaMenu menu $menutype [lindex $cmdws 0]]
		set menu ""
		foreach win [winfo children $base] {
			if [regexp ^$base.#classy__#menu_ $win] {
				set menu $win
				break
			}
		}
		set data(menu,$base) $menu
		set data(class,$menu) Classy::DynaMenu
		bindtags $menu $data(tags)
		set data(redir,$menu) $base
		return $menu
	} else {
		$base configure -menu {}
		set data(opt-menuwin,$base) ""
		return ""
	}
}

proc ::Classy::WindowBuilder::select_menu {object v option title} {
	set w .classy__.temp
	catch {destroy $w}
	Classy::SelectDialog $w
	$w fill [Classy::DynaMenu types]
	$w configure -addcommand "Classy::Config new menu appdef"
	$w configure -deletecommand "puts"
	set ::Classy::temp [Classy::select Menu [Classy::DynaMenu types]]
	if {"$::Classy::temp" != ""} {
		$v.menutype set $::Classy::temp
	}
}

proc ::Classy::WindowBuilder::new_menu {v} {
	set menu [$v.menutype get]
	Classy::Config new menu appdef [list Menus Application] $menu
}

proc ::Classy::WindowBuilder::attredit_menu {object v option title {wide 0}} {
	private $object current
	frame $v
	set class [$object itemclass $current(w)]
	if {("$class" != "Classy::Toplevel")&&("$class" != "Classy::Dialog")} {
		::Classy::WindowBuilder::attredit_line $object $v $option $title $wide
		return
	}
	Classy::Entry $v.menutype -width 2 -label "Menutype"	-orient stacked \
		-command "::Classy::WindowBuilder::menuset $object" \
		-textvariable [privatevar $object data(opt-mainmenu,$current(w))]
	if $wide {$v.menutype configure -orient horizontal -labelwidth $wide}
	button $v.select -text "Select menu" -command [varsubst v {
		set ::Classy::temp [Classy::select Menu [Classy::DynaMenu types]]
		if {"$::Classy::temp" != ""} {
			$v.menutype set $::Classy::temp
		}
	}]
	button $v.edit -text "Edit menu" -command "Classy::Config dialog -key menu,\[$v.menutype get\] -level appdef"
	button $v.new -text "New menu" -command "Classy::WindowBuilder::new_menu $v"
	Classy::Entry $v.cmdw -width 2 -label "Menu window(s)"	-orient stacked \
		-command "::Classy::WindowBuilder::menuset $object" \
		-textvariable [privatevar $object data(opt-menuwin,$current(w))]
	if $wide {$v.cmdw configure -orient horizontal -labelwidth $wide}
	grid $v.select -row 2 -column 0 -sticky we
	grid $v.edit -row 2 -column 1 -sticky we
	grid $v.new -row 2 -column 2 -sticky we
	grid $v.menutype -row 3 -column 0 -sticky we -columnspan 4
	grid $v.cmdw -row 4 -column 0 -sticky we -columnspan 4
	grid rowconfigure $v 5 -weight 1
	grid columnconfigure $v 3 -weight 1
}

#
# Def tool
#

proc ::Classy::WindowBuilder::defattredit {object w list wide {fill 1}} {
	private $object attredit
	unset -nocomplain attredit
	set c [$object current]
	eval destroy [winfo children $w]
	Classy::cleargrid $w
	set row 0
	foreach {option title resize} $list {
		set win $w.w$row
		$object _createattributeedit $win $option $title $wide
		grid $win -sticky nwse -row [incr row] -column 0
		grid rowconfigure $w $row -weight $resize
	}
	grid columnconfigure $w 0 -weight 1
	if !$fill {grid rowconfigure $w [incr row] -weight 1}
	return $row
}



#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Classy::DynaMenu
# ----------------------------------------------------------------------
#doc DynaMenu title {
#DynaMenu
#} index {
# Common tools
#} shortdescr {
# Class used to easily create menus, that can be easily changed, and handle key-shortcuts
#} descr {
# subclass of <a href="Class.html">Class</a><br>
# DynaMenu is not a widget and is not intended to produce instances. 
# It is a class that manages menus in an easy and dynamic way.
# Dynamenu can handle several menutypes.
#<p>
# Each menutype is defined by a <a href="../classy_dynamenu.html">menu 
# definition</a>. Dynamenu can create one or more popup or top menus for each
# menutype. When the definition of the menutype is redefined
# all menus of that type will be changed accordingly.
#<p>
# Menu definitions for menutype are usually controlled from the
# Menus part of the <a href="../classy_configure.html">configuration 
# system</a>.
#<p>
# A menu managed by DynaMenu can control several widgets: The commands 
# associated with the menu can include a %W, that on invocation is
# changed to the current cmdw (command widget). The cmdw of a menu can be
# changed at any time. DynaMenu also handles key shortcuts.
#}

option add *Menu.BorderWidth 1 widgetDefault
option add *Menu.Relief raised widgetDefault
option add *Classy::TopMenu.Button.padY 0 widgetDefault
option add *Classy::TopMenu.Checkbutton.padY 1 widgetDefault
option add *Classy::TopMenu.Menubutton.padY 1 widgetDefault

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------
Class subclass Classy::DynaMenu

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------
#doc {DynaMenu attachmainmenu} cmd {
#DynaMenu attachmainmenu menutype window ?menuroot?
#} descr {
# create a top menu of type $menutype and attach it to the given window. $window will
# be the initial cmdw for the menu. The menu will be added to the toplevel of $window,
# unless menuroot is specified.
#}
Classy::DynaMenu classmethod attachmainmenu {menutype cmdw {menuroot {}}} {
	private $class menus
	$class define $menutype
	set menu $menus($menutype)
	if {"$menuroot" == ""} {
		set root [winfo toplevel $cmdw]
	} else {
		set root [winfo toplevel $menuroot]
	}
	if {![winfo exists $menu]} {
		$class makemenu $menutype $menu $cmdw Classy::Menu_$menutype
	}
	$class cmdw $menutype $cmdw
	catch {bindtags [Classy::rebindw $cmdw] [lreplace [bindtags [Classy::rebindw $cmdw]] 1 0 Classy::Menu_$menutype]}
	if {[string_equal [option get $root menuType MenuType] popup]} {
		bind $cmdw <<MainMenu>> "$class popup $menutype %X %Y"
	} else {
		[Classy::window $root] configure -menu $menu
	}
}

#doc {DynaMenu attachmenu} cmd {
#DynaMenu attachmenu menutype window
#} descr {
# create a popup menu of type $menutype and attach it to the given window. $window will
# be the initial cmdw for the menu.
#}
Classy::DynaMenu classmethod attachmenu {menutype cmdw} {
	private $class menus
	$class define $menutype
	set menu $menus($menutype)
	if {![winfo exists $menu]} {
		$class makemenu $menutype $menu $cmdw Classy::Menu_$menutype
	} else {
		$class cmdw $menutype $cmdw
	}
	bindtags [Classy::rebindw $cmdw] [lreplace [bindtags [Classy::rebindw $cmdw]] 1 0 Classy::Menu_$menutype]
	bind $cmdw <<Menu>> "$class popup $menutype %X %Y $cmdw"
	return {}
}

#doc {DynaMenu cmdw} cmd {
#DynaMenu cmdw menutype ?cmdw?
#} descr {
# change the current cmdw for $menutype to $cmdw. If the cmdw argument is
# not given, the method returns the current cmdw for $menutype.
# This method is automatically called when a widget which has bindtags
# defined by DynaMenu recieves the focus.
#}
Classy::DynaMenu classmethod cmdw {menutype {cmdw {}}} {
	private $class cmdws nocmdws
	if {[info exists nocmdws($cmdw,$menutype)]} return
	if {"$cmdw"==""} {
		return [Classy::mainw $cmdws($menutype)]
	} else {
		set cmdw [Classy::mainw $cmdw]
		if {"$cmdws($menutype)"=="$cmdw"} {return $cmdw}
		set cmdws($menutype) $cmdw
		private $class checks
		if {[info exists checks($menutype)]} {
			regsub -all {%W} $checks($menutype) $cmdw command
			regsub -all {%%} $command % command
			eval $command
		}
		return [Classy::mainw $cmdw]
	}
}

#doc {DynaMenu define} cmd {
#DynaMenu define menutype ?data?
#} descr {
# set the definition describing the menus that will be generated 
# for $menutype to $data. If data is empty, the data for $menutype
# will be removed. If data is not given, the current definition for
# $menutype will be returned.
#}
Classy::DynaMenu classmethod define {menutype args} {
	private $class menudata cmdws checks bindtags flag menus
	switch [llength $args] {
		0 {
			if {![info exists menus($menutype)]} {
				set file [file join $::Classy::dira(appuser) menu $menutype]
				$class define $menutype [file_read $file]
			}
			return $menudata($menutype)
		}
		1 {
			set data [lindex $args 0]
		}
		default {
			return -code error "wrong # args: should be \"$class define menutype ?data?\""
		}
	}
	regsub -all :: $menutype __ temp
	set menus($menutype) .classy__.menu_$temp
	set menu $menus($menutype)
	if {"$data" == ""} {
		catch {destroy $menu}
		unset -nocomplain checks($menutype)
		unset -nocomplain menudata($menutype)
		unset -nocomplain cmdws($menutype)
		unset -nocomplain bindtags($menutype)
		return ""
	} elseif {[winfo exists $menu]} {
		unset -nocomplain checks($menutype)
		eval destroy [winfo children $menu]
		if {[catch {$class makepopup $menutype $menu $menu $data $cmdws($menutype) $bindtags($menutype)} error]} {
			set errorInfo $::errorInfo
			if {[info exists flag]} {
				unset flag
				return -code error -errorinfo $::errorInfo \
					"error while defining menu; could not restore old: $error"
			} else {
				if {[info exists menudata($menutype)]} {
					set flag 1
					eval destroy [winfo children $menu]
					$class define $menutype $menudata($menutype)
					unset flag
				}
			}
			return -code error -errorinfo $errorInfo \
				"error while defining menu; restored old: $error"
		}
	}
	set menudata($menutype) $data
}

#doc {DynaMenu types} cmd {
#DynaMenu types 
#} descr {
# returns a list of menutypes managed by Dynamenu
#}
Classy::DynaMenu classmethod types {{pattern *}} {
	private $class menudata
	set list ""
	foreach dir $Classy::dirs {
		foreach tool [dirglob [file join $dir menu] *] {
			if {[string match $pattern $tool]} {
				list_addnew list $tool
			}
		}
	}
	foreach tool [array names ::Classy::configmenu] {
		if {[string match $pattern $tool]} {
			list_addnew list $tool
		}
	}
	foreach tool [array names menudata] {
		if {[string match $pattern $tool]} {
			list_addnew list $tool
		}
	}
	return $list
	return [array names menudata]
}

#doc {DynaMenu delete} cmd {
#DynaMenu delete menutype
#} descr {
# delete the current definition and all menus of $menutype
#}
Classy::DynaMenu classmethod delete {menutype} {
	private $class menudata cmdws checks bindtags menus
	unset menudata($menutype)
	unset menus($menutype)
	unset cmdws($menutype)
	unset checks($menutype)
	unset bindtags($menutype)
	catch {destroy .classy__.menu_$menutype}
}

#doc {DynaMenu menu} cmd {
#DynaMenu menu menutype
#} descr {
# returns the window name of the menu of type $menutype for use in a program.
#}
Classy::DynaMenu classmethod menu {menutype {cmdw {}}} {
	private $class cmdws menus
	$class define $menutype
	set menu $menus($menutype)
	if {"$cmdw" == ""} {
		if {[info exists cmdws($menutype)]} {
			set cmdw $cmdws($menutype)
		} else {
			set cmdw .
		}
	}
	if {![winfo exists $menu]} {
		$class makemenu $menutype $menu $cmdw Classy::Menu_$menutype
	} else {
		$class cmdw $menutype $cmdw
	}
	return $menu
}

#doc {DynaMenu menu} cmd {
#DynaMenu bindtag menutype
#} descr {
# returns the sequence to which all key-shortcuts for $menutype are bound.
# add this to the bindtags of the window that must be controlled by the menu.
#}
Classy::DynaMenu classmethod bindtag {menutype} {
	private $class menus
	$class define $menutype
	set menu $menus($menutype)
	if {![winfo exists $menu]} {
		$class makemenu $menutype $menu . Classy::Menu_$menutype
	}
	return Classy::Menu_$menutype
}

#doc {DynaMenu popup} cmd {
#DynaMenu popup menutype ?x y?
#} descr {
# popup menu of type $menutype
#}
Classy::DynaMenu classmethod popup {menutype x y {cmdw {}}} {
	private $class cmdws menus
	$class define $menutype
	set menu $menus($menutype)
	if {"$cmdw" == ""} {
		if {[info exists cmdws($menutype)]} {
			set cmdw $cmdws($menutype)
		} else {
			set cmdw .
		}
	}
	if {![winfo exists $menu]} {
		$class makemenu $menutype $menu $cmdw Classy::Menu_$menutype
	} else {
		$class cmdw $menutype $cmdw
	}
	tk_popup $menu $x $y 1
}

#doc {DynaMenu invoke} cmd {
#DynaMenu invoke curmenu index
#} descr {
# invoke the item given by $index in $curmenu
#}
Classy::DynaMenu classmethod invoke {curmenu index} {
	uplevel 1 $curmenu invoke $index
}

#doc {DynaMenu makemenu} cmd {
#DynaMenu makemenu menutype menu cmdw bindtag
#} descr {
# You don't usually have to call this method. The above commands will do. It
# creates a menu named $menu of type $menutype if $menu does not exist yet.
# $cmdw determines the initial command widget. All key bindings 
# from key shortcuts
# are bound to $bindtag. Adding $bindtag to the bindtags of a widget
# will make all shortcuts available from that widget.
#}
Classy::DynaMenu classmethod makemenu {menutype menu cmdw bindtag} {
	private $class cmdws checks bindtags
	private $class menudata
	if {![info exists menudata($menutype)]} {
		if {[info exists ::Classy::configmenu($menutype)]} {
			$class define $menutype $::Classy::configmenu($menutype)
		} else {
			return -code error "Menu type \"$menutype\" not defined"
		}
	}
	set bindtags($menutype) $bindtag
	set cmdws($menutype) $cmdw
	set checks($menutype) ""
	bind $bindtag <FocusIn> [list $class cmdw $menutype %W]
	if {![winfo exists $menu]} {
		menu $menu -title [lindex $menutype 0]
		set error [catch {$class makepopup $menutype $menu $menu $menudata($menutype) $cmdw $bindtag} result]
		if {$error} {
			set file [file join $::Classy::dira(appdef) conf]
			array set a [file_read $file]
			set defmenu $a(menu,$menutype)
			if {$defmenu ne $menudata($menutype)} {
				destroy $menu
				menu $menu -title [lindex $menutype 0]
				set error [catch {$class makepopup $menutype $menu $menu $defmenu $cmdw $bindtag} result]
				if {$error} {
					error "error in personalized and default menu definition for $menutype: $result"
				}
				set menudata($menutype) $defmenu
			} else {
				if {$error} {
					error "error in menu definition for $menutype: $result"
				}
			}
		}
	}
}

Classy::DynaMenu classmethod makepopup {menutype menu curmenu data cmdw bindtag} {
	private $class checks base bindings actives
	if {[info exists bindings($curmenu)]} {
		foreach binding $bindings($curmenu) {
			bind $bindtag $binding {}
		}
	}
	$curmenu delete 0 end
	set bindings($curmenu) ""
	set num 1
	set list {}
	foreach line [cmd_split $data] {
		if {"[lindex $line 0]" == "if"} {
			if {[uplevel #0 [list expr [lindex $line 1]]]} {
				eval lappend list [cmd_split [lindex $line 2]]
			} else {
				eval lappend list [cmd_split [lindex $line 4]]
			}
		} else {
			lappend list $line
		}
	}
	foreach current $list {
		set type [lindex $current 0]
		set text [lindex $current 1]
		if {"$type"=="menu"} {
			menu $curmenu.b$num -title $text
			$class makepopup $menutype $menu $curmenu.b$num [lindex $current 2] $cmdw $bindtag
			set shortcut [lindex $current 3]
			if {"$shortcut"!=""} {
				bind $bindtag $shortcut "tk_popup $curmenu.b$num %X %Y 1;break"
			}
			$curmenu add cascade -label $text -menu $curmenu.b$num -accelerator [::Classy::shrink_accelerator $shortcut]
			incr num
		} elseif {"$type"=="activemenu"} {
			set command [lindex $current 2]
			regsub -all {%W} $command "\[$class cmdw $menutype\]" command
			regsub -all {%%} $command % command
			set data {}
			catch {set data [uplevel #0 $command]}
			menu $curmenu.b$num -title $text -postcommand [list $class _activemenu $menutype $menu $curmenu.b$num b$num $command]
			$class _activemenu $menutype $menu $curmenu.b$num b$num $command
			append checks($menutype) "[list $class _activemenu $menutype $menu $curmenu.b$num b$num $command]\n"
			set shortcut [lindex $current 3]
			if {"$shortcut"!=""} {
				bind $bindtag $shortcut "tk_popup $curmenu.b$num %X %Y 1;break"
			}
			$curmenu add cascade -label $text -menu $curmenu.b$num -accelerator [::Classy::shrink_accelerator $shortcut]
			lappend actives($menutype) $curmenu.b$num
			incr num
		} elseif {"$type"=="separator"} {
			$curmenu add separator
			incr num
		} elseif {"$type"=="action"} {
			set command [lindex $current 2]
			set shortcuts [lindex $current 3]
			regsub -all {%W} $command "\[$class cmdw $menutype\]" command
			regsub -all {%%} $command % command
			foreach shortcut $shortcuts {
				bind $bindtag $shortcut "$class invoke $curmenu $num;break"
			}
			$curmenu add command -label $text -command [list Classy::check $command] -accelerator [::Classy::shrink_accelerator $shortcuts]
			incr num
		} elseif {"$type"=="check"} {
			set command [lindex $current 2]
			set shortcuts [lindex $current 3]
			regsub -all {%W} $command $cmdw temp
			regsub -all {%%} $temp % temp
			foreach shortcut $shortcuts {
				bind $bindtag $shortcuts "$class invoke $curmenu $num;break"
			}
			eval {$curmenu add check -label $text -accelerator [::Classy::shrink_accelerator $shortcuts]} $temp
			append checks($menutype) "$curmenu entryconfigure [$curmenu index last] $command\n"
			incr num
		} elseif {"$type"=="radio"} {
			set command [lindex $current 2]
			set shortcuts [lindex $current 3]
			regsub -all {%W} $command $cmdw temp
			regsub -all {%%} $temp % temp
			foreach shortcut $shortcuts {
				bind $bindtag $shortcut "$class invoke $curmenu $num;break"
			}
			eval {$curmenu add radio -label $text -accelerator [::Classy::shrink_accelerator $shortcuts]} $temp
			append checks($menutype) "$curmenu entryconfigure [$curmenu index last] $command\n"
			incr num
		} elseif {[regexp ^# $type]} {
		} elseif {"$type" == "if"} {
		} elseif {"$type" == ""} {
		} else {
			error "Unknown entrytype $type" 
		}
	}
}

Classy::DynaMenu classmethod _activemenu {menutype menu curmenu key command} {
	private $class cmdws bindtags bindings
	set data {}
	catch {set data [uplevel #0 $command]}
	set bindtag [lindex $data 1]
	set data [lindex $data 0]
	set cmdw $cmdws($menutype)
	foreach event [bind $bindtag] {bind $bindtag $event {}}
	$class makepopup $menutype $menu $curmenu $data $cmdw $bindtag
}

Classy::DynaMenu classmethod updateactive {menutype} {
	private $class actives
	foreach active $actives($menutype) {
		if {[winfo exists $active]} {
			uplevel #0 [$active cget -postcommand]
		} else {
			set actives($menutype) [list_remove $actives($menutype) $active]
		}
	}
}

#doc {DynaMenu attachbindings} cmd {
#DynaMenu attachbindings menutype window ?window? ...
#} descr {
# add the bindings (keys, etc) of the given menu to the given windows
#}
Classy::DynaMenu classmethod attachbindings {menutype args} {
	private $class menus nocmdws
	$class define $menutype
	set menu $menus($menutype)
	if {![winfo exists $menu]} {
		$class makemenu $menutype $menu $cmdw Classy::Menu_$menutype
	}
	foreach w $args {
		set nocmdws($w,$menutype) 1
		set bindtags [bindtags $w]
		if {![inlist $bindtags Classy::Menu_$menutype]} {
			catch {bindtags $w [lreplace $bindtags 1 0 Classy::Menu_$menutype]}
		}
	}
}


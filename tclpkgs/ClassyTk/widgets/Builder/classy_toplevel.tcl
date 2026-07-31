#
# Classy::Toplevel
#

proc ::Classy::WindowBuilder::start_Classy::Toplevel {object base} {
	private $object data bindtags
	set bindtags($base) [bindtags $base]
	$object startedit [winfo children $base]
	foreach child [winfo children $base] {
		if [regexp "^$base.#classy__#menu_" $child] {
			set data(redir,$child) $base
		}
	}
	bindtags $base $data(tags)
	if ![info exists data(opt-destroycommand,$base)] {
		set data(opt-destroycommand,$base) ""
	}
	$base configure -destroycommand ""
	$object select $base
	wm protocol $base WM_DELETE_WINDOW [varsubst base {
		catch {$base configure -destroycommand {}}
		catch {destroy $base}
	}]
}

proc ::Classy::WindowBuilder::attr_Classy::Toplevel_-destroycommand {object w args} {
	private $object data
	if {"$args" == ""} {
		if [info exists data(opt-destroycommand,$w)] {
			return $data(opt-destroycommand,$w)
		} else {
			return ""
		}
	} else {
		set value [lindex $args 0]
		if ![info exists data(opt-destroycommand,$w)] {
			if {"$value" != ""} {
				set data(opt-destroycommand,$w) "$value"
			}
		}
	}
}

proc ::Classy::WindowBuilder::edit_Classy::Toplevel {object w} {
	set c [$object current]
	eval destroy [winfo children $w]
	frame $w.general
	::Classy::WindowBuilder::defattredit $object $w.general {
		-title Title 0 -menu Menu 0 -keepgeometry Keepgeometry 0 -resize Resize 0 -destroycommand destroycommand 1
	} 12 0
	set ::Classy::WindowBuilder::error {}
	grid $w.general -sticky nswe
	grid columnconfigure $w 0 -weight 1
	grid rowconfigure $w 0 -weight 1
}

proc ::Classy::WindowBuilder::generate_Classy::Toplevel {object base} {
	private $object current data
	set body ""
	set outw [$object outw $base]
#	set opt [eval $object getoptions $base -menu -destroycommand $data(options)]
	set opt [$object getoptions $base -menu -destroycommand]
	if [info exists data(opt-destroycommand,$base)] {
		switch -regexp -- $data(opt-destroycommand,$base) {
			{^".*"$} - {^\[.*\]$} {
				append opt "\\\n\t\t-destroycommand $data(opt-destroycommand,$base)"
			}
			default {
				append opt "\\\n\t\t[list -destroycommand $data(opt-destroycommand,$base)]"
			}
		}
	}
	if {$opt ne ""} {
		append data(parse) "\t\$object configure $opt\n"
	}
	append body [$object generatebindings $base $outw]
	set children ""
	foreach child [winfo children $base] {
		if [regexp "^$base.classy__\[a-z0-9\]+\$" $child] continue
		if [regexp "^$base.#classy__#menu_" $child] continue
		lappend children $child
	}
	append body [$object generate $children]
	if [info exists data(opt-mainmenu,$base)] {
		if {"$data(opt-mainmenu,$base)" != ""} {
			if {"$data(opt-menuwin,$base)" != ""} {
				foreach win $data(opt-menuwin,$base) {
					append data(parse) "\tClassy::DynaMenu attachmainmenu $data(opt-mainmenu,$base) $win\n"
				}
			} else {
				append data(parse) "\tClassy::DynaMenu attachmainmenu $data(opt-mainmenu,$base) $outw\n"
			}
		}
	}
	append body [$object gridconf $base]
	append body "\n"
	return $body
}


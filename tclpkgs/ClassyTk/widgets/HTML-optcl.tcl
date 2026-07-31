#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# HTML
# ----------------------------------------------------------------------
package require http

if ![string_equal [Classy::HTML private type] optcl] break

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Classy::HTML method init {args} {
	private $object htm history 
	set w [super init]
	$object configure -width 600 -height 400
	set htm [optcl::new -window $object.htm Shell.Explorer.2]
	#set htm [optcl::new -window $object.htm [file join $Classy::dir help ClassyTk.html]]
	$object.htm config -width 400 -height 400
	pack $object.htm -fill both -expand yes
	bindtags $object [list $object Classy::HTML . all]
	bindtags $object.htm [list $object Classy::HTML . all]
	bind $object.htm <Enter> [list setprivate $object keepfocus %W]
	bind $object.htm <Leave> [list catch [list forceFocus \[getprivate $object keepfocus\]]]
	optcl::bind $htm StatusTextChange [list $object _linkchanged]
	set history(url) ""
	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval {$object configure} $args}
	return $object
}

Classy::HTML method destroy {} {
	private $object w
	$w _clear
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

Classy::HTML chainoptions {$object}

#doc {HTML options -url} option {-url url Url} descr {
#}
Classy::HTML addoption -url {url Url {}} {
	set value [$object geturl $value]
}

#doc {HTML options -indent} option {-indent indent Indent} descr {
#}
Classy::HTML addoption -indent {indent Indent {}} {
	html::set_indent $object $value
}

#doc {HTML options -update} option {-update update Update} descr {
#}
Classy::HTML addoption -update {update Update {}} {
	html::set_state $object -update $value
}

#doc {HTML options -tab} option {-tab tab Tab} descr {
#}
Classy::HTML addoption -tab {tab Tab {}} {
	html::set_state $object -tab $value
}

#doc {HTML options -unknown} option {-unknown unknown Unknown} descr {
#}
Classy::HTML addoption -unknown {unknown Unknown {}} {
	html::set_state $object -unknown $value
}

#doc {HTML options -size} option {-size size Size} descr {
#}
Classy::HTML addoption -size {size Size {}} {
	html::set_state $object -size $value
}

#doc {HTML options -symbols} option {-symbols symbols Symbols} descr {
#}
Classy::HTML addoption -symbols {symbols Symbols {}} {
	html::set_state $object -symbols $value
}

#doc {HTML options -tagmap} option {-tagmap tagMap TagMap} descr {
#}
Classy::HTML addoption -tagmap {tagMap TagMap {}}

#doc {HTML options -insertmap} option {-insertmap insertMap InsertMap} descr {
#}
Classy::HTML addoption -insertmap {insertMap InsertMap {}}

#doc {HTML options -errorcommand} option {-errorcommand errorCommand Command} descr {
#}
Classy::HTML addoption -errorcommand {errorCommand Command {}}

#doc {HTML options -state} option {-state state State} descr {
#}
Classy::HTML addoption -state {state State {}}

#doc {HTML options -wrap} option {-wrap wrap Wrap} descr {
#}
Classy::HTML addoption -wrap {wrap Wrap {}} {}

#doc {HTML options -hyperlinkcommand} option {-hyperlinkcommand hyperlinkCommand HyperlinkCommand} descr {
#}
Classy::HTML addoption -hyperlinkcommand {hyperlinkCommand HyperlinkCommand {}} {}

#doc {HTML options -yscrollcommand} option {-yscrollcommand yscrollCommand Command} descr {
#}
Classy::HTML addoption -yscrollcommand {yscrollCommand Command {}} {
	private $object w
	$w configure -yscrollcommand $value
}

#doc {HTML options -xscrollcommand} option {-xscrollcommand xscrollCommand Command} descr {
#}
Classy::HTML addoption -xscrollcommand {xscrollCommand Command {}} {
	private $object w
	$w configure -xscrollcommand $value
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::HTML chainallmethods {$object} text

#doc {HTML command geturl} cmd {
#pathname geturl url
#} descr {
#}
Classy::HTML method geturl {url {query {}}} {
	private $object htm options
	$htm navigate $url
	set options(-url) [$htm : LocationURL]
}

Classy::HTML method _linkchanged {id page} {
	private $object htm options history
	if {($page == "") || [string equal -nocase "done" $page]} {
		set options(-url) [$htm : LocationURL]
		set history(url) [list_remove $history(url) $options(-url)]
		lappend history(url) $options(-url)
	} else {
		set options(-url) $page
	}
	return
}

Classy::HTML method print {} {
	private $object htm
	set rkey {HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\PageSetup}
	set header [registry get $rkey header]
	set footer [registry get $rkey footer]
	registry set $rkey header ""
	registry set $rkey footer ""
	catch {
		#$htm ExecWB "OLECMDID_PRINTPREVIEW" "OLECMDEXECOPT_PROMPTUSER"
		$htm ExecWB "OLECMDID_PRINT" "OLECMDEXECOPT_PROMPTUSER"
		#$htm ExecWB "OLECMDID_PAGESETUP" "OLECMDEXECOPT_PROMPTUSER"
	}
	registry set $rkey header $header
	registry set $rkey footer $footer
}

Classy::HTML method yview {args} {
}

Classy::HTML method xview {args} {
}

Classy::HTML method seeanchor {fragment} {
}

#doc {HTML command reload} cmd {
#pathname reload 
#} descr {
#}
Classy::HTML method reload {} {
	private $object htm
	$htm Refresh
}

#doc {HTML command back} cmd {
#pathname back 
#} descr {
#}
Classy::HTML method back {} {
	private $object htm
	$htm GoBack
}

#doc {HTML command forward} cmd {
#pathname forward 
#} descr {
#}
Classy::HTML method forward {} {
	private $object htm
	$htm GoForward
}

#doc {HTML command history} cmd {
#pathname history
#} descr {
#}
Classy::HTML method history {} {
	private $object history
	return $history(url)
}

#doc {HTML command load} cmd {
#pathname load file
#} descr {
#}
Classy::HTML method load {file} {
	if {"[file pathtype $file]" != "absolute"} {
		set file [file join [pwd] $file]
	}
	$object geturl file:$file
}

#doc {HTML command set} cmd {
#pathname set html
#} descr {
#}
Classy::HTML method set {html} {
	set tempfile [tempfile]
	file_write -encoding binary $tempfile $html
	$object geturl "file://$tempfile"
}

#doc {HTML command source} cmd {
#pathname source
#} descr {
# returns current source
#}
Classy::HTML method source {} {
error
	private $object htm
	return $source
}

#doc {HTML command clearcache} cmd {
#pathname clearcache
#} descr {
# clears the image cache
#}
Classy::HTML method clearcache {} {
}

#doc {HTML command stop} cmd {
#pathname stop
#} descr {
# stop loading current page
#}
Classy::HTML method stop {} {
}

Classy::HTML method _clear {} {
}

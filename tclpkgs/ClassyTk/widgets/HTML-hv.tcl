#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# HTML
# ----------------------------------------------------------------------
catch {package require Img}
package require http
package require hv

Widget subclass Classy::HTML-hv

#bind Classy::HTML-hv <<Action-ButtonPress>> {%W _position %x %y}
#bind Classy::HTML-hv <<Action-Motion>> {%W _motion %x %y}
#bind Classy::HTML-hv <<Action-ButtonRelease>> {%W _release %x %y}
#Classy::bindmousewheel Classy::HTML-hv

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Classy::HTML-hv method init {args} {
	private $object myProtocol
	super init
	::hv3::hv3 $object.hv
	pack $object.hv -fill both -expand yes
#	bindtags $object [list $object Classy::HTML-hv . all]
	# REM Initialise options and variables
	# ------------------------------------
	private $object history options
	setprivate $object options(-url) "file:/"
	setprivate $object tempfile [tempfile]
	setprivate $object currentquery ""
	set history(pos) -1
	set history(len) -1
	set history(url) ""
	set history(query) ""
	# REM handlers
	# ------------
	set myProtocol [::hv3::protocol %AUTO%]
	::hv3::cookies_scheme_init $myProtocol
	$object.hv configure -requestcmd "[list $myProtocol requestcmd]"
	bind $object.hv <<Location>> [list $object _goto]
	
	# REM Create bindings
	# --------------------
#	bindtags $object [list $object Classy::HTML-hv [winfo toplevel $object] all]
	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval {$object configure} $args}
	return $object
}

Classy::HTML-hv method destroy {} {
	private $object myProtocol
	$myProtocol destroy
	$object.hv _clear
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

Classy::HTML-hv chainoptions {$object}

#doc {HTML options -url} option {-url url Url} descr {
#}
Classy::HTML-hv addoption -url {url Url {}} {
	set value [$object geturl $value]
}

#doc {HTML options -indent} option {-indent indent Indent} descr {
#}
Classy::HTML-hv addoption -indent {indent Indent {}} {
	html::set_indent $object $value
}

#doc {HTML options -update} option {-update update Update} descr {
#}
Classy::HTML-hv addoption -update {update Update {}} {
	html::set_state $object -update $value
}

#doc {HTML options -tab} option {-tab tab Tab} descr {
#}
Classy::HTML-hv addoption -tab {tab Tab {}} {
	html::set_state $object -tab $value
}

#doc {HTML options -unknown} option {-unknown unknown Unknown} descr {
#}
Classy::HTML-hv addoption -unknown {unknown Unknown {}} {
	html::set_state $object -unknown $value
}

#doc {HTML options -size} option {-size size Size} descr {
#}
Classy::HTML-hv addoption -size {size Size {}} {
	html::set_state $object -size $value
}

#doc {HTML options -symbols} option {-symbols symbols Symbols} descr {
#}
Classy::HTML-hv addoption -symbols {symbols Symbols {}} {
	html::set_state $object -symbols $value
}

#doc {HTML options -tagmap} option {-tagmap tagMap TagMap} descr {
#}
Classy::HTML-hv addoption -tagmap {tagMap TagMap {}}

#doc {HTML options -insertmap} option {-insertmap insertMap InsertMap} descr {
#}
Classy::HTML-hv addoption -insertmap {insertMap InsertMap {}}

#doc {HTML options -errorcommand} option {-errorcommand errorCommand Command} descr {
#}
Classy::HTML-hv addoption -errorcommand {errorCommand Command {}}

#doc {HTML options -state} option {-state state State} descr {
#}
Classy::HTML-hv addoption -state {state State {}}

#doc {HTML options -wrap} option {-wrap wrap Wrap} descr {
#}
Classy::HTML-hv addoption -wrap {wrap Wrap {}} {}

#doc {HTML options -hyperlinkcommand} option {-hyperlinkcommand hyperlinkCommand HyperlinkCommand} descr {
#}
Classy::HTML-hv addoption -hyperlinkcommand {hyperlinkCommand HyperlinkCommand {}} {}

#doc {HTML options -yscrollcommand} option {-yscrollcommand yscrollCommand Command} descr {
#}
Classy::HTML-hv addoption -yscrollcommand {yscrollCommand Command {}} {
	$object.hv configure -yscrollcommand $value
}

#doc {HTML options -xscrollcommand} option {-xscrollcommand xscrollCommand Command} descr {
#}
Classy::HTML-hv addoption -xscrollcommand {xscrollCommand Command {}} {
	$object.hv configure -xscrollcommand $value
}

#doc {HTML options -font} option {-font font Font} descr {
#}
Classy::HTML-hv addoption -font {font Font {}} {
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::HTML-hv method primitives {args} {
	eval {$object.hv primitives} $args
}

Classy::HTML-hv method style {args} {
	eval {$object.hv style} $args
}

Classy::HTML-hv method yview {args} {
	if {[llength $args] == 1} {
		$object.hv yview scroll [lindex $args 0] units
	} else {
		eval {$object.hv yview} $args
	}
}

Classy::HTML-hv method xview {args} {
	eval {$object.hv xview} $args
}

Classy::HTML-hv method seeanchor {fragment} {
	set selector [format {[name="%s"]} $fragment]
	set goto_node [lindex [$object.hv search $selector] 0]
	if {$goto_node eq ""} return
	set coords2 [$object.hv bbox [$object.hv node]]
	set coords  [$object.hv bbox $goto_node]
	while {[llength $coords] == 0 && ($goto_node ne [$object.hv node])} {
		set next_node [$goto_node right_sibling]
		if {$next_node eq ""} {
			set next_node [$goto_node parent]
		}
		set goto_node $next_node
		set coords [$object.hv bbox $goto_node]
	}
	if {[llength $coords] > 0} {
		set ypix [lindex $coords 1]
		set ycanvas [lindex $coords2 3]
		$object.hv yview moveto [expr double($ypix) / double($ycanvas)]
	}
}

Classy::HTML-hv method geturlnow {url {query {}}} {
	set error [catch {$object geturl $url $query} msg]
	if {$error} {error $msg}
}

#doc {HTML command geturl} cmd {
#pathname geturl url
#} descr {
#}
Classy::HTML-hv method geturl {url {query {}}} {
	$object.hv goto $url
	return $url
}

#doc {HTML command reload} cmd {
#pathname reload 
#} descr {
#}
Classy::HTML-hv method reload {} {
	private $object options history currentquery
	set history(reload) 1
	$object geturl $options(-url) $currentquery
}

#doc {HTML command back} cmd {
#pathname back 
#} descr {
#}
Classy::HTML-hv method back {} {
	private $object options history
	incr history(pos) -1
	if {$history(pos) < 0} {set history(pos) 0;return}
	set url [lindex $history(url) $history(pos)]
	set query [lindex $history(query) $history(pos)]
	set history(direction) 1
	if [regexp ^data: $url] {
		set query {}
	}
	$object geturl $url $query
}

#doc {HTML command forward} cmd {
#pathname forward 
#} descr {
#}
Classy::HTML-hv method forward {} {
	private $object options history
	if {$history(pos) == $history(len)} return
	incr history(pos)
	set url [lindex $history(url) $history(pos)]
	set query [lindex $history(query) $history(pos)]
	set history(direction) 1
	if [regexp ^data: $url] {
		set query {}
	}
	$object geturl $url $query
}

#doc {HTML command history} cmd {
#pathname history
#} descr {
#}
Classy::HTML-hv method history {} {
	private $object history
	return $history(url)
}

Classy::HTML-hv method addhistory {url query} {
	private $object history
	if [info exists history(reload)] {
		unset history(reload)
		return
	} elseif [info exists history(direction)] {
		unset history(direction)
		return
	}
	if {$history(pos) != $history(len)} {
		set history(url) [lrange $history(url) 0 $history(pos)]
		set history(query) [lrange $history(query) 0 $history(pos)]
		set history(len) $history(pos)
	}
	if {$history(len) > 50} {
		list_shift history(url)
		list_shift history(query)
		lappend history(url) $url
		lappend history(query) $query
	} else {
		lappend history(url) $url
		lappend history(query) $query
		incr history(len)
		incr history(pos)
	}
}

#doc {HTML command fullurl} cmd {
#pathname fullurl url
#} descr {
#}
Classy::HTML-hv method fullurl {args} {
	private $object options
	if {[llength $args] == 1} {
		set baseurl $options(-url)
		foreach {url} $args break
		if {[regexp ^data: $baseurl]} {
			set baseurl data:/
		}
	} elseif {[llength $args] == 2} {
		foreach {baseurl url} $args break
	} else {
		error "wrong # args: should be \"object fullurl ?baseurl? url\""
	}
	# make url fully specified
	# ------------------------
	if [regexp ^# $url] {
		set base $baseurl
		regexp {([^#]*)#(.+)} $baseurl dummy base fragment
		return $base$url
	}
	if {[regexp {^[^/]+://[^/]+$} $url]} {append url /}
	regsub {/[^/]*$} $baseurl {} dir
	switch -regexp $url {
		{^(http|ftp|file|data)://} {
		}
		{^(http|ftp|file|data):/} {
			regsub {^(http|ftp|file|data):/} $url {\0/localhost/} url
		}
		{^file:} {
			regsub {^file:} $url {file://localhost/} url
		}
		^// {
			regexp {^([^:]*)://([^/]+)(/.*)$} $baseurl dummy protocol host file
			set url $protocol:$url
		}
		^/ {
			regexp {^([^:]*)://([^/]+)(/.*)$} $baseurl dummy protocol host file
			set url $protocol://$host$url
		}
		default {
			set url $dir/$url
		}
	}
	return $url
}

#doc {HTML command spliturl} cmd {
#pathname spliturl url
#} descr {
# splits the given url into a list containing {protocol host file name}
#}
Classy::HTML-hv method spliturl {url} {
	set part {}
	set url [$object fullurl $url]
	regexp {([^#]*)#(.+)} $url dummy url part
	regexp {^([^:]*)://([^/]+)(/.*)$} $url dummy protocol host file
	return [list $protocol $host $file $part]
}

#doc {HTML command load} cmd {
#pathname load file
#} descr {
#}
Classy::HTML-hv method load {file} {
	if {"[file pathtype $file]" != "absolute"} {
		set file [file join [pwd] $file]
	}
	$object geturl file:$file
}

#doc {HTML command set} cmd {
#pathname set html
#} descr {
#}
Classy::HTML-hv method set {html} {
	set tempfile [tempfile]
	file_write -encoding binary $tempfile $html
	$object geturl "file://$tempfile"
}

#doc {HTML command source} cmd {
#pathname source
#} descr {
# returns current source
#}
Classy::HTML-hv method source {} {
return
	private $object source
	return $source
}

#doc {HTML command stop} cmd {
#pathname stop
#} descr {
# stop loading current page
#}
Classy::HTML-hv method stop {} {
	$object.hv stop
}

Classy::HTML-hv method _clear {} {
	$object.hv reset 0
}

Classy::HTML-hv method _goto {} {
	private $object options currentquery
	set url [$object.hv location]
	set query {}
	if {$url ne $options(-url)} {
		$object addhistory $url $query
		set options(-url) $url
	}
}

Classy::HTML-hv method bindlink {args} {
	
}


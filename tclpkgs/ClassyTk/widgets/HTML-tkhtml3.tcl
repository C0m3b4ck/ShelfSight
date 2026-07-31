#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# HTML
# ----------------------------------------------------------------------
catch {package require Img}
package require http
package require Tkhtml 3
set Classy::simagefailed [catch {package require simage}]

Widget subclass Classy::HTML3

bind Classy::HTML3 <<Action-ButtonPress>> {%W _position %x %y}
bind Classy::HTML3 <<Action-Motion>> {%W _motion %x %y}
bind Classy::HTML3 <<Action-ButtonRelease>> {%W _release %x %y}
Classy::bindmousewheel Classy::HTML3

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Classy::HTML3 method init {args} {
	private $object oriw
	set oriw [super init html]
	bindtags $object [list $object Classy::HTML3 . all]
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
	$oriw configure -imagecmd [list $object _getimage]
	$oriw configure -defaultstyle [::tkhtml::htmlstyle]
	$oriw handler script script [list $object _script]
	# $oriw handler node img [list $object _image $PATH]
	$oriw handler node link [list $object _link]
	$oriw handler script style  [list $object _style]
	$oriw handler node form  [list $object _form_form]
	$oriw handler node input  [list $object _form_input]
	$oriw handler node select  [list $object _form_select]
	$oriw handler node textarea  [list $object _form_textarea]
	$oriw handler node button  [list $object _form_button]
	
	# REM Create bindings
	# --------------------
	$object clearcache
	bindtags $object [list $object Classy::HTML3 [winfo toplevel $object] all]
	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval {$object configure} $args}
	return $object
}

Classy::HTML3 method destroy {} {
	private $object oriw
	$oriw _clear
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

Classy::HTML3 chainoptions {$object}

#doc {HTML options -url} option {-url url Url} descr {
#}
Classy::HTML3 addoption -url {url Url {}} {
	set value [$object geturl $value]
}

#doc {HTML options -indent} option {-indent indent Indent} descr {
#}
Classy::HTML3 addoption -indent {indent Indent {}} {
	html::set_indent $object $value
}

#doc {HTML options -update} option {-update update Update} descr {
#}
Classy::HTML3 addoption -update {update Update {}} {
	html::set_state $object -update $value
}

#doc {HTML options -tab} option {-tab tab Tab} descr {
#}
Classy::HTML3 addoption -tab {tab Tab {}} {
	html::set_state $object -tab $value
}

#doc {HTML options -unknown} option {-unknown unknown Unknown} descr {
#}
Classy::HTML3 addoption -unknown {unknown Unknown {}} {
	html::set_state $object -unknown $value
}

#doc {HTML options -size} option {-size size Size} descr {
#}
Classy::HTML3 addoption -size {size Size {}} {
	html::set_state $object -size $value
}

#doc {HTML options -symbols} option {-symbols symbols Symbols} descr {
#}
Classy::HTML3 addoption -symbols {symbols Symbols {}} {
	html::set_state $object -symbols $value
}

#doc {HTML options -tagmap} option {-tagmap tagMap TagMap} descr {
#}
Classy::HTML3 addoption -tagmap {tagMap TagMap {}}

#doc {HTML options -insertmap} option {-insertmap insertMap InsertMap} descr {
#}
Classy::HTML3 addoption -insertmap {insertMap InsertMap {}}

#doc {HTML options -errorcommand} option {-errorcommand errorCommand Command} descr {
#}
Classy::HTML3 addoption -errorcommand {errorCommand Command {}}

#doc {HTML options -state} option {-state state State} descr {
#}
Classy::HTML3 addoption -state {state State {}}

#doc {HTML options -wrap} option {-wrap wrap Wrap} descr {
#}
Classy::HTML3 addoption -wrap {wrap Wrap {}} {}

#doc {HTML options -hyperlinkcommand} option {-hyperlinkcommand hyperlinkCommand HyperlinkCommand} descr {
#}
Classy::HTML3 addoption -hyperlinkcommand {hyperlinkCommand HyperlinkCommand {}} {}

#doc {HTML options -yscrollcommand} option {-yscrollcommand yscrollCommand Command} descr {
#}
Classy::HTML3 addoption -yscrollcommand {yscrollCommand Command {}} {
	private $object oriw
	$oriw configure -yscrollcommand $value
}

#doc {HTML options -xscrollcommand} option {-xscrollcommand xscrollCommand Command} descr {
#}
Classy::HTML3 addoption -xscrollcommand {xscrollCommand Command {}} {
	private $object oriw
	$oriw configure -xscrollcommand $value
}

#doc {HTML options -font} option {-font font Font} descr {
#}
Classy::HTML3 addoption -font {font Font {}} {
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::HTML3 method primitives {args} {
	private $object oriw
	eval {$oriw primitives} $args
}

Classy::HTML3 method style {args} {
	private $object oriw
	eval {$oriw style} $args
}

Classy::HTML3 method yview {args} {
	private $object oriw
	if {[llength $args] == 1} {
		$oriw yview scroll [lindex $args 0] units
	} else {
		eval {$oriw yview} $args
	}
}

Classy::HTML3 method xview {args} {
	private $object oriw
	eval {$oriw xview} $args
}

Classy::HTML3 method seeanchor {fragment} {
	private $object oriw
	set selector [format {[name="%s"]} $fragment]
	set goto_node [lindex [$oriw search $selector] 0]
	if {$goto_node eq ""} return
	set coords2 [$oriw bbox [$oriw node]]
	set coords  [$oriw bbox $goto_node]
	while {[llength $coords] == 0 && ($goto_node ne [$oriw node])} {
		set next_node [$goto_node right_sibling]
		if {$next_node eq ""} {
			set next_node [$goto_node parent]
		}
		set goto_node $next_node
		set coords [$oriw bbox $goto_node]
	}
	if {[llength $coords] > 0} {
		set ypix [lindex $coords 1]
		set ycanvas [lindex $coords2 3]
		$oriw yview moveto [expr double($ypix) / double($ycanvas)]
	}
}

Classy::HTML3 method geturlnow {url {query {}}} {
	private $object usesync
	set usesync 1
	set error [catch {$object geturl $url $query} msg]
	unset usesync
	if {$error} {error $msg}
}

#doc {HTML command geturl} cmd {
#pathname geturl url
#} descr {
#}
Classy::HTML3 method geturl {url {query {}}} {
	private $object options history currentquery html source loading oriw usesync
	Classy::busy add $object
	set url [$object fullurl $url]
	# if it is the same url as the current, don't reload
	# --------------------------------------------------
	set base $url
	set currentbase $options(-url)
	set fragment ""
	set currentfragment ""
	regexp {([^#]*)#(.+)} $url dummy base fragment
	regexp {([^#]*)#(.+)} $options(-url) dummy currentbase currentfragment
	if ![info exists history(reload)] {
		if {"$query" == ""} {
			if {"$currentbase" == "$base"} {
				if {"$currentfragment" != "$fragment"} {
					if {"$fragment" != ""} {$object seeanchor $fragment}
					$object addhistory $url $query
					set options(-url) $url
				}
				set currentquery $query
				Classy::busy remove $object
				return $url
			}
		}
	}
	# get the html data according to protocol
	# ---------------------------------------
	if [info exists loading] {
		# stop if already busy loading something, and try again
		$object stop
		Classy::todo $object geturl $url $query
		return
	}
	set loading 1
	foreach {protocol host file fragment} [$object spliturl $url] break
	if {![info exists usesync] && [string_equal $protocol http]} {
		set source ""
		set code [catch {
			$object _async_httpget -query $query $url
		} result]
		set async 1
	} else {
		set code [catch {set source [$object getdata -query $query -typevar type $url]} result]
		set async 0
	}
	if $code {
		private $object options
		if {"$options(-errorcommand)" == ""} {
			Classy::busy remove $object
			unset loading
			return -code $code $result
		} else {
			set code [catch {eval $options(-errorcommand) {$url $query $result}} result]
			Classy::busy remove $object
			unset loading
			return -code $code $result
		}
	}
	# adjust history
	# --------------
	$object addhistory $url $query
	set options(-url) $url
	# render
	# ------
	$object _clear
	# http pages are being transfered asynchronously
	if {!$async} {
		if {![string_equal $type text/html]} {
			$oriw parse <pre>
		}
		set pos 0
		set len [string length $source]
		if {[info exists usesync]} {
			$oriw parse $source
		} else {
			while {$pos < $len} {
				$oriw parse [string range $source $pos [expr {$pos+19999}]]
				incr pos 20000
				Classy::update Classy::tkhtml3-geturl
				if {![info exists loading]} {
					Classy::busy remove $object
					return
				}
			}
		}
		if {![string_equal $type text/html]} {
			$oriw parse </pre>
		}
		if {[string length $fragment]} {
			$oriw yview $fragment
		}
		unset loading
	}
	set currentquery $query
	Classy::busy remove $object
}

#doc {HTML command reload} cmd {
#pathname reload 
#} descr {
#}
Classy::HTML3 method reload {} {
	private $object options history currentquery
	set history(reload) 1
	$object geturl $options(-url) $currentquery
}

#doc {HTML command back} cmd {
#pathname back 
#} descr {
#}
Classy::HTML3 method back {} {
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
Classy::HTML3 method forward {} {
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
Classy::HTML3 method history {} {
	private $object history
	return $history(url)
}

Classy::HTML3 method addhistory {url query} {
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
Classy::HTML3 method fullurl {args} {
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
Classy::HTML3 method spliturl {url} {
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
Classy::HTML3 method load {file} {
	if {"[file pathtype $file]" != "absolute"} {
		set file [file join [pwd] $file]
	}
	$object geturl file:$file
}

#doc {HTML command set} cmd {
#pathname set html
#} descr {
#}
Classy::HTML3 method set {html} {
	$object geturl "data://localhost/$html"
}

#doc {HTML command linkat} cmd {
#pathname linkat x y
#} descr {
# returns the link (href) at position x,y.
# This is used in comination with bindlink to change the behaviour
# of links.
#} example {
# objectName bindlink <3> {puts [%W linkat %x %y]}
#}
Classy::HTML3 method linkat {x y} {
	private $object oriw
	set node [$oriw node $x $y]
	for {set n $node} {$n!=""} {set n [$n parent]} {
		set url [$n attr -default "" href]
		if {[$n tag] eq "a" && $url ne ""} {
			break
		}
	}
	return $url
}

#doc {HTML command bindlink} cmd {
#pathname bindlink ?event? ?sequence?
#} descr {
# binds action to a certain event happening on a link
#} example {
# objectName bindlink <3> {puts [%W linkat %x %y]}
#}
Classy::HTML3 method bindlink {args} {
return
	eval {bind $object} $args
}

#doc {HTML command source} cmd {
#pathname source
#} descr {
# returns current source
#}
Classy::HTML3 method source {} {
	private $object source
	return $source
}

#doc {HTML command clearcache} cmd {
#pathname clearcache
#} descr {
# clears the image cache
#}
Classy::HTML3 method clearcache {} {
	private $object cachedata cache
	set cache(dir) [file join $::Classy::dira(user) HTML-cache]
	if ![file exists $cache(dir)] {
		file mkdir $cache(dir)
	} else {
		catch {eval file delete -force [glob [file join $cache(dir) *]]}
	}
	set cache(pos) 1
	unset -nocomplain cachedata
}

#doc {HTML command clearcache} cmd {
#pathname stop
#} descr {
# stop loading current page
#}
Classy::HTML3 method stop {} {
	private $object loading
	unset -nocomplain loading
}

#doc {HTML command getdata} cmd {
#pathname getdata ?options? url
#} descr {
# gets data from a certain url
#}
Classy::HTML3 method getdata {args} {
	set opt(-typevar) ::Classy::temp
	set opt(-query) {}
	cmd_args "$object getdata" {
		-typevar {any "set given variable to type of data obtained"}
		-channel {any "Save data to channel instead of returning it"}
		-query {any "query data"}
	} url $args
	set query $opt(-query)
	foreach {protocol host file fragment} [$object spliturl $url] break
	upvar $opt(-typevar) type
		# This is usually not used for http, but we include it anyway
	switch $protocol {
		http {
			set base $url
			regexp {([^#]*)#(.+)} $url dummy base fragment
			if {[string_equal $query {}]} {
				set id [http::geturl $base]
			} else {
				set id [http::geturl $base -query $query]
			}
			set data [http::data $id]
			array set state [set [set id](meta)]
			if [info exists state(Content-Type)] {
				set type [string trimright [string trimleft $state(Content-Type)]]
			} else {
				set type text/html
			}
			::http::cleanup $id
		}
		file {
			if {"$::tcl_platform(platform)" == "windows"} {
				regsub {^/([A-Za-z]:/)} $file {\1} file
			}
			set data [file_read -translation binary $file]
			if [regexp {html?$} $file] {
				set type text/html
			} else {
				set type unknown/unknown
			}
		}
		data {
			set data [string range $file 1 end]
			set type text/html
		}
		ftp {
			error "not yet"
		}
		default {
			error "unsupported protocol"
		}
	}
	return $data
}

Classy::HTML3 method _clear {} {
	private $object oriw imgstoget form
	$oriw reset
	foreach image [info commands ::Classy::${object}_*] {
		image delete $image
	}
	set imgstoget {}
	foreach {option attr} {
		-bg Background
		-fg Foreground
	} {
		catch {$oriw configure $option [option get $object Classy::HTML3 $attr]}
	}
	unset -nocomplain form
	foreach ww [winfo children $object] {
		destroy $ww
	}
}

Classy::HTML3 method _getimage {args} {
	private $object cachedata cache imgstoget
	set src [lindex $args 0]
	set info(width) 0
	set info(height) 0
	set src [$object fullurl $src]
	set imagename ::Classy::${object}_${src}
	if {[llength [info commands $imagename]]} {
		#return $imagename
	} else {
		image create photo $imagename
	}
	foreach {protocol host file fragment} [$object spliturl $src] break
	set data [$object getdata $src]
	set unknown 1
	if {![catch {$imagename configure -data $data}]} {
		set unknown 0
	} else {
		array set trans {jpg jpeg tif tiff}
		set ext [string range [file extension $src] 1 end]
		if {![catch {package require img::$trans([string tolower $ext])}]} {
			if {![catch {$imagename configure -data $data}]} {
				set unknown 0
			}
		}
	}
	if {$unknown} {
		$imagename read $::Classy::dir/conf/icons/unknown.gif
	}
	return $imagename
}

Classy::HTML3 method _styleid {parentid} {
	private $object stylecount
	if {![info exists stylecount]} {set stylecount 0}
	format %s.%.4d $parentid [incr stylecount]
}

Classy::HTML3 method _script {args} {
	# not supported yet
	return ""
}

Classy::HTML3 method _styleload {url id style} {
	private $object oriw
	set url [$object fullurl $url]
	$oriw style -id $id -importcmd [list $object _styleimport $id] -urlcmd [list $object fullurl $url] $style
}

Classy::HTML3 method _styleimport {parentid url} {
	set id [$object _styleid $parentid]
	set url [$object fullurl $url]
	$object _styleload $url $id [$object getdata $url]
}

Classy::HTML3 method _link {node} {
	set rel   [$node attr -default "" rel]
	set media [$node attr -default all media]
	if {$rel eq "stylesheet" && [regexp all|screen $media]} {
		set url [$object fullurl [$node attr href]]
		set id [$object _styleid author]
		$object _styleload $url $id [$object getdata $url]
	}
}

Classy::HTML3 method _style {style} {
	private $object options
	set id [$object _styleid author]
	$object _styleload $options(-url) $id $style
}

#Classy::HTML3 method _body {args} {
#	private $object oriw
#	foreach {tag attrs} $args break
#	array set info $attrs
#	foreach {option attr} {
#		-bg bgcolor
#		-fg text
#		-visitedcolor vlink
#		-unvisitedcolor link
#	} {
#		if [info exists info($attr)] {
#			$oriw configure $option $info($attr)
#		}
#	}
#}
#
Classy::HTML3 method _form_flush {args} {
	private $object form
	foreach {token cmd} $args break
	foreach name [array names form $token,*] {
		unset form($name)
	}
}

Classy::HTML3 method _form_form {node} {
	private $object form
	set token [$object _form_token $node]
	array set info [$node attr]
	set form($token,method) [string tolower [get info(method) get]]
	set form($token,url) $info(action)
	set form($token,name) [get info(name)]
	set form($token,attrs) {}
	set form($token,id) 1
	set form($token,ids) {}
}

Classy::HTML3 method _form_token {node} {
	set token $node
	while 1 {
		if {[$token attr -default "" action] ne ""} break
		set token [$token parent]
		if {$token eq ""} break
	}
	return $token
}

Classy::HTML3 method _form_input {node} {
	private $object form
	set token [$object _form_token $node]
	set ww $object.[string map {: _} $node] 
	set id $ww
	if {[info commands $ww] != ""} {destroy $ww}
	array set info {
		type text value {} size 20 color white 
		multiple 0 checked 0 rows 1 cols 20 alt Alt
	}
	if {![info exists info(name)]} {set info(name) $ww}
	array set info [$node attr]
	list_addnew form($token,ids) $id
	set form($token,$id,type) $info(type)
	set form($token,$id,name) $info(name)
	set form($token,$id,w) $ww
	if {![inlist {radio checkbox} $info(type)]} {
		set form($token,$id,defvalue) $info(value)
		if {![info exists form($token,$id,value)]} {
			set form($token,$id,value) $info(value)
		}
		set value $form($token,$id,value)
	}
	set widget ""
	set cw ""
	switch $info(type) {
		submit {
			set widget button
			if {[string_equal $value {}]} {set value Submit}
			button $ww -text $value -command [list $object _formsubmit $token $id] \
				-borderwidth 0 -highlightthickness 0

			set cw $ww
			if {[info exists info(name)]} {
				set form($token,$id,value) $value
			}
		}
		reset {
			set widget button
			if {[string_equal $value {}]} {set value Reset}
			button $ww -text $value -command [list $object _formreset $token $id] \
				-borderwidth 0 -highlightthickness 0
			set cw $ww
		}
		hidden {}
		name -
		text {
			set widget entry
			entry $ww -width $info(size) -bg $info(color) \
				-textvariable [privatevar $object form($token,$id,value)] \
				-borderwidth 0 -highlightthickness 0
			setprivate $object form($token,$id,value) [$node attr -default "" value]
			set cw $ww
			bind $ww <Return> [list $object _formsubmit $token $id]
		}
		image {
			set widget button
			set image [$object _getimage $info(src)]
			button $ww -image $image -relief flat -bd 0 -highlightthickness 0
			set cw $ww
			bind $ww <<Action>> "puts ok%x,%y;[list $object _formsubmit $token $id image %x %y];break"
		}
		file {
			set widget Classy::FileEntry
			Classy::FileEntry $ww -width $info(size) -bg $info(color) \
				-textvariable [privatevar $object form($token,$id,value)] \
				-command [list $object _formsubmit $token $id]
			set cw $ww
		}
		password {
			set widget entry
			entry $ww -width $info(size) -bg $info(color) \
				-show * \
				-textvariable [privatevar $object form($token,$id,value)]
			set cw $ww
			bind $ww <Return> [list $object _formsubmit $token $id]
		}
		checkbox {
			set widget checkbutton
			checkbutton $ww -highlightthickness 0 \
				-variable [privatevar $object form($token,$id,$info(value),value)] \
				-borderwidth 0 -highlightthickness 0 -padx 0 -pady 0
			set cw $ww
			if {"$info(checked)" != "0"} {
				if {![info exists form($token,$id,value)]} {
					$ww select
				}
				$ww select
				set form($token,$id,$info(value),defvalue) 1
			} else {
				set form($token,$id,$info(value),defvalue) 0
			}
		}
		radio {
			set widget radiobutton
			radiobutton $ww -value $info(value) -highlightthickness 0 \
				-variable [privatevar $object form($token,$id,value)] \
				-borderwidth 0 -highlightthickness 0 -padx 0 -pady 0
			set cw $ww
			if {"$info(checked)" != "0"} {
				set form($token,$id,defvalue) $info(value)
				if {[string_equal $form($token,$id,value) ""]} {
					set form($token,$id,value) $info(value)
				}
			}
		}
	}
	if {$cw ne ""} {
		$node replace $cw \
			-configurecmd [list $object _form_config $ww $widget] \
			-deletecmd    [list $object _form_delete $ww]
	}
}

Classy::HTML3 method _form_config {oriw widget props} {
	array set p $props
	set font [option get $object font Font]
	set bg [option get $object background Background]
	set fg [option get $object foreground Foreground]
	switch -- $widget {
		button {
			$oriw configure -font [get p(font) $font]
			$oriw configure -activeforeground [get p(color) $fg]
			$oriw configure -background [get p(background-color) $bg]
			$oriw configure -foreground [get p(color) $fg]
		}
		entry {
			$oriw configure -font [get p(font) $font]
			$oriw configure -foreground [get p(color) $fg]
			$oriw configure -background [get p(background-color) $bg]
		}
		radiobutton {
			$oriw configure -offrelief flat
			$oriw configure -padx 0
			$oriw configure -pady 0
			$oriw configure -foreground [get p(color) $fg]
			$oriw configure -background [get p(background-color) $bg]
			$oriw configure -activeforeground [get p(color) $fg]
			$oriw configure -activebackground [get p(background-color) $bg]
			$oriw configure -highlightbackground [get p(background-color) $bg]
		}
	}
}

Classy::HTML3 method _form_delete {ww} {
	private $object form
	foreach name [array names form *,$ww,*] {
		unset form($name)
	}
	set form($token,ids) [list_remove $form($token,ids) $ww]
	destroy $ww
}

Classy::HTML3 method _form_select {node} {
	private $object form
	set token [$object _form_token $node]
	set ww $object.[string map {: _} $node] 
	set id $ww
	if {[info commands $ww] != ""} {destroy $ww}
	array set info {multiple 0}
	array set info [$node attr]
	list_addnew form($token,ids) $id
	set form($token,$id,type) select
	set form($token,$id,name) $info(name)
	set form($token,$id,w) $ww
	set width 5
	set choicelist {}
	set valuelist {}
	foreach child [$node children] {
		if {[$child tag] == "option"} {
			set label ???
			catch {set label [[$child child 0] text]}
			set value $label
			catch {set value [$child attr -default $label value]}
			lappend choices [list 0 $value $label]
		}
	}
	foreach line $choices {
		foreach {sel value label} $line break
		set label [string trimright [string trimleft $label]]
		lappend choicelist $label
		lappend valuelist $value
		if {$sel} {lappend form($token,$id,defvalue) $label}
		set cw [string length $label]
		if {$cw > $width} {set width $cw}
	}
	set form($token,$id,valuelist) $valuelist
	set form($token,$id,choicelist) $choicelist
	if {![info exists form($token,$id,defvalue)]} {
		set form($token,$id,defvalue) [lindex $choicelist 0]
	}
	if {![info exists form($token,$id,value)]} {
		set form($token,$id,value) $form($token,$id,defvalue)
	}
	if {("$info(multiple)" == "0") && (![info exists info(size)] || ($info(size) == 1))} {
		set form($token,$id,type) select
		set form($token,$id,defvalue) [lindex $form($token,$id,defvalue) 0]
		set form($token,$id,value) [lindex $form($token,$id,value) 0]
		menubutton $ww -width $width -menu $ww.menu \
			-indicatoron 1 -relief raised \
			-textvariable [privatevar $object form($token,$id,value)]
		menu $ww.menu -tearoff 0
		foreach label $choicelist {
			$ww.menu add command -label $label \
				-command [list set [privatevar $object form($token,$id,value)] $label]
		}
	} else {
		set form($token,$id,type) selectmulti
		if {$width > 50} {
			set scrollx 1
			set width 50
		} else {
			set scrollx 0
		}
		frame $ww
		if {![info exists info(size)]} {
			set info(size) [llength $choicelist]
		}
		if {$info(size) > 50} {set info(size) 50}
		listbox $ww.list -height $info(size) -width $width -exportselection no
		if {"$info(multiple)" != "0"} {
			$ww.list configure -selectmode multiple
		}
		grid $ww.list -sticky nwse
		set rw [winfo reqwidth $ww.list]
		set rh [winfo reqheight $ww.list]
		if {[llength $choicelist] > $info(size)} {
			scrollbar $ww.vbar -orient vertical -command [list $ww.list yview]
			$ww.list configure -yscrollcommand [list $ww.vbar set]
			grid $ww.vbar -sticky nwse -row 0 -column 1
			incr rw [winfo reqwidth $ww.vbar]
		}
		if {$scrollx} {
			scrollbar $ww.hbar -orient horizontal -command [list $ww.list xview]
			$ww.list configure -xscrollcommand [list $ww.hbar set]
			grid $ww.hbar -sticky nwse -row 1 -column 0
			incr rh [winfo reqheight $ww.hbar]
		}
		grid rowconfigure $ww 0 -weight 1
		grid columnconfigure $ww 0 -weight 1
		$ww configure -width $rw -height $rh
		eval $ww.list insert end $choicelist
		foreach label $form($token,$id,value) {
			$ww.list selection set [lsearch -exact $choicelist $label]
		}
	}
	$node replace $ww \
		-configurecmd [list $object _form_config $ww menubutton] \
		-deletecmd    [list $object _form_delete $ww]
}

Classy::HTML3 method _form_textarea {node} {
	private $object form
	set token [$object _form_token $node]
	set ww $object.[string map {: _} $node] 
	set id $ww
	if {[info commands $ww] != ""} {
		catch {destroy $ww}
		catch {destroy $ww.text}
		catch {destroy $ww.vbar}
		catch {destroy $ww.hbar}
	}
	array set info {size 20 multiple 0}
	array set info [$node attr]
	set initial [[lindex [$node children] 0] text]
	list_addnew form($token,ids) $id
	set form($token,$id,type) textarea
	set form($token,$id,name) $info(name)
	set form($token,$id,w) $ww
	set form($token,$id,defvalue) $initial
	frame $ww
	text $ww.text -width $info(cols) -height $info(rows)
	scrollbar $ww.vbar -orient vertical -command [list $ww.text yview]
	scrollbar $ww.hbar -orient horizontal -command [list $ww.text xview]
	$ww.text configure \
		-yscrollcommand [list $ww.vbar set] \
		-xscrollcommand [list $ww.hbar set]
	grid $ww.text $ww.vbar -sticky nwse
	grid $ww.hbar -sticky nwse
	grid rowconfigure $ww 0 -weight 1
	grid columnconfigure $ww 0 -weight 1
	$ww configure \
		-width [expr {[winfo reqwidth $ww.text]+[winfo reqwidth $ww.vbar]}] \
		-height [expr {[winfo reqheight $ww.text]+[winfo reqheight $ww.hbar]}]
	$ww.text insert end $initial
	$node replace $ww \
		-configurecmd [list $object _form_config $ww menubutton] \
		-deletecmd    [list $object _form_delete $ww]
}

Classy::HTML3 method _formsubmit {token id args} {
	private $object form
	set query {}
	switch [lindex $args 0] {
		image {
			lappend query $id.x [lindex $args 1]
			lappend query $id.y [lindex $args 2]
		}
	}
	if {[info exists form($token,$id,value)]} {
		lappend query $id $form($token,$id,value)
	}
	foreach id $form($token,ids) {
		switch $form($token,$id,type) {
			selectmulti {
				set ww $form($token,$id,w)
				foreach index [$ww.list curselection] {
					set value [lindex $form($token,$id,valuelist) $index]
					if {[string_equal $value ""]} {
						set value [lindex $form($token,$id,choicelist) $index]
					}
					lappend query $id $value
				}
			}
			select {
				set index [lsearch -exact $form($token,$id,choicelist) $form($token,$id,value)]
				set value [lindex $form($token,$id,valuelist) $index]
				if {[string_equal $value ""]} {
					set value [lindex $form($token,$id,choicelist) $index]
				}
				lappend query $id $value
			}
			textarea {
				set ww $form($token,$id,w)
				lappend query $id [$ww.text get 1.0 end]
			}
			reset - submit {}
			checkbox {
				foreach name [array names form $token,$id,*,value] {
					if {$form($name) == 1} {
						regexp {,([^,]*),value$} $name temp value
						lappend query $id $value
					}
				}
			}
			default {
				lappend query $id $form($token,$id,value)
			}
		}
	}
	if {[string_equal $form($token,method) post]} {
		$object geturl $form($token,url) [eval ::http::formatQuery $query]
	} else {
		$object geturl $form($token,url)?[eval ::http::formatQuery $query]
	}
}

Classy::HTML3 method _formreset {token id} {
	private $object form
	foreach id $form($token,ids) {
		switch $form($token,$id,type) {
			selectmulti {
				set ww $form($token,$id,w)
				$ww.list selection clear 0 end
				set choicelist [$ww.list get 0 end]
				foreach label [get form($token,$id,defvalue) ""] {
					$ww.list selection set [lsearch -exact $choicelist $label]
				}
			}
			textarea {
				set ww $form($token,$id,w)
				$ww.text delete 1.0 end
				$ww.text insert end [get form($token,$id,defvalue) ""]
			}
			checkbox {
				foreach name [array names form $token,$id,*,defvalue] {
					regsub {,defvalue$} $name {,value} vname
					set form($vname) $form($name)
				}
			}
			default {
				set form($token,$id,value) [get form($token,$id,defvalue) ""]
			}
		}
	}
}

Classy::HTML3 method _async_httpget {args} {
	private $object currenttype
	package require http
	set opt(-query) {}
	cmd_args "$object getdata" {
		-query {any "query data"}
	} url $args
	set query $opt(-query)
	foreach {protocol host file fragment} [$object spliturl $url] break
	if {"$query" == ""} {
		set id [http::geturl http://$host$file \
			-command [list $object _async_httpget_done] \
			-handler [list $object _async_httpget_handler] \
			-timeout 100000]
	} else {
		set id [http::geturl http://$host$file \
			-command [list $object _async_httpget_done] \
			-handler [list $object _async_httpget_handler] \
			-query $query \
			-timeout 100000]
	}
	array set state [set [set id](meta)]
	if [info exists state(Content-Type)] {
		set currenttype [string trimright [string trimleft $state(Content-Type)]]
	} else {
		set currenttype text/html
	}
	if ![string_equal $currenttype text/html] {
		$oriw parse $html <pre>
	}
}

Classy::HTML3 method _async_httpget_handler {sock token} {
	private $object oriw loading source
	upvar #0 $token state
	if ![info exists loading] {
		close $sock
		unset -nocomplain state
		return
	}
	set html [read $sock $state(-blocksize)]
	# doing this completely async gives problems on some sites
#	$oriw parse $html
	append source $html
	Classy::update Classy::HTML3-_async_httpget_handler idletasks
	return
}

Classy::HTML3 method _async_httpget_done {token} {
	private $object oriw currenttype imgstoget cache cachedata loading source
	if ![string_equal $currenttype text/html] {
#		$oriw parse $html </pre>
		append source $html
	}
	$oriw parse $source
	set ncode [http::ncode $token]
	if {[regexp ^3 $ncode]} {
		upvar #0 $token state
		$object geturl [map_get $state(meta) Location]
	}
	if ![info exists loading] {return}
	::http::cleanup $token
	# get images after loading the html page
	# _async_getimage_done gets called when the image has been gotten
	# it starts loading the next image if there are still to done
	if ![llength $imgstoget] {
		unset loading
		return
	}
	set image [list_shift imgstoget]
	if [info exists cachedata($image)] {
		set file $cachedata($image)
	} else {
		set file $cache(pos)
		set cachedata($image) $file
		incr cache(pos)
	}
	set f [open $file w]
	http::geturl $image -channel $f -command [list $object _async_getimage_done $image $f]
	return
}

Classy::HTML3 method _async_getimage_done {image f token} {
	private $object cache cachedata imgstoget loading
	close $f
	::http::cleanup $token
	if ![info exists loading] {return}
	set imagename ::Classy::${object}_${image}
	$imagename	blank
	catch {$imagename	read $cachedata($image)}
	if ![llength $imgstoget] {
		unset loading
		return
	}
	set image [list_shift imgstoget]
	if [info exists cachedata($image)] {
		set file $cachedata($image)
	} else {
		set file $cache(pos)
		set cachedata($image) $file
		incr cache(pos)
	}
	set f [open $file w]
	http::geturl $image -channel $f -command [list $object _async_getimage_done $image $f]
	return
}

Classy::HTML3 method _position {x y} {
	private $object cpos oriw
	set cpos(x) $x
	set cpos(y) $y
	set cpos(index) [$oriw node $x $y]
}

Classy::HTML3 method _motion {x y} {
	private $object cpos oriw
	if ![info exists cpos(index)] {
		set cpos(x) $x
		set cpos(y) $y
		set cpos(index) [$oriw node $x $y]
	}
}

Classy::HTML3 method _release {x y} {
	private $object options cpos oriw
	unset -nocomplain cpos(index)
	set node [$oriw node $x $y]
	for {set n $node} {$n!=""} {set n [$n parent]} {
		set url [$n attr -default "" href]
		if {[$n tag] eq "a" && $url ne ""} {
			break
		}
	}
	if {$url ne ""} {
		if {[string_equal $options(-hyperlinkcommand) ""]} {
			$object geturl $url
		} else {
			eval $options(-hyperlinkcommand) {$url}
		}
	}
}

Classy::HTML3 method _draw_box_width {c paVar side} {
	upvar $paVar pa
	set w [? {$pa(border-$side-style) ne "none"} $pa(border-$side-width) 0]
	regsub px $w {} w
	set w [winfo fpixels $c $w]
	
}

Classy::HTML3 method render2canvas {c {x 0} {y 0} {scale 1} {imagecmd {}}} {
	private $object oriw inum
	if {![info exists inum]} {set inum 1}
	upvar #0 Classy::canvasdata.$c cdata
	set X $x
	set Y $y
	set code [$oriw primitives]
	Classy::Progress start [llength $code]
	foreach line $code {
		set cmd [lindex $line 0]
		switch $cmd {
			draw_origin_start - draw_origin_end {
				foreach {cmd x y horizontal vertical} $line break
				if {$scale != 1} {
					set x [expr {$x*$scale}]
					set y [expr {$y*$scale}]
				}
				incr X $x
				incr Y $y
			}
			draw_text {
				foreach {cmd x y w node index string} $line break
				array set pa [$node prop]
				set font $pa(font)
				set color $pa(color)
				if {$scale != 1} {
					set x [expr {$X+$x*$scale}]
					set y [expr {$Y+$y*$scale}]
					set font [Classy::zoomfont $font $scale]
				} else {
					incr x $X
					incr y $Y
				}
				# The Y coordinate supplied by the layout code is for the baseline of the
				# text item. The canvas widget doesn't support this, so decrement Y by
				# the font metric 'ascent' value and anchor the nw corner of the text to
				# simulate it.
				set ascent [font metrics $font -ascent]
				incr y [expr -1*$ascent]
				$c create text $x $y -font $font -fill $color -text $string -anchor nw -tags [list [list _t text] [list _f $font]]
				set cdata([list _f $font]) 1
			}
			draw_quad {
				foreach {cmd x1 y1 x2 y2 x3 y3 x4 y4 color} $line break
				if {$scale != 1} {
					foreach v {x1 x2 x3 x4} {set v [expr {[set $v]*$scale + $X}]}
					foreach v {y1 y2 y3 y4} {set v [expr {[set $v]*$scale + $Y}]}
				} else {
					foreach v {x1 x2 x3 x4} {incr $v $X}
					foreach v {y1 y2 y3 y4} {incr $v $Y}
				}
				$c create polygon $x1 $y1 $x2 $y2 $x3 $y3 $x4 $y4 -fill $color
			}
			draw_image {
				foreach {cmd x y width height node image} $line break
				if {$scale != 1} {
					set x [expr {$X+$x*$scale}]
					set y [expr {$Y+$y*$scale}]
				} else {
					incr x $X
					incr y $Y
				}
				set width [expr {$width*$scale}]
				set height [expr {$height*$scale}]
				if {$imagecmd ne ""} {
					set drawn [$imagecmd $c $x $y $width $height $scale $image]
				} else {
					set drawn 0
				}
				if {$drawn ne "1"} {
					$c create simage $x $y -image $image -anchor nw -width $width -height $height
				}
			}
			draw_window {
				continue
				foreach {cmd x y window} $line break
				if {$scale != 1} {
					set x [expr {$X+$x*$scale}]
					set y [expr {$Y+$y*$scale}]
				} else {
					incr x $X
					incr y $Y
				}
				$c create window $x $y -window $window -anchor nw
			}
			draw_box {
				foreach {cmd x y width height node} $line break
				array set pa [$node prop]
				if {$scale != 1} {
					set x [expr {$X+$x*$scale}]
					set y [expr {$Y+$y*$scale}]
					set width [expr {$width*$scale}]
					set height [expr {$height*$scale}]
				} else {
					incr x $X
					incr y $Y
				}
				set tw [$object _draw_box_width $c pa top]
				set bw [$object _draw_box_width $c pa bottom]
				set lw [$object _draw_box_width $c pa left]
				set rw [$object _draw_box_width $c pa right]
				set tc $pa(border-top-color)
				set bc $pa(border-bottom-color)
				set lc $pa(border-left-color)
				set rc $pa(border-right-color)
				if {$pa(background-image) eq "none"} {
					set color $pa(color)
					if {$color eq "transparent"} {set color {}}
					set color {}
					set fill $pa(background-color)
					if {$fill ne "transparent"} {
						$c create rectangle $x $y [expr {$x+$width}] [expr {$y+$height}] -outline $color -fill $fill -tags box
					}
				} else {
					set imageurl $pa(background-image)
					if {$imagecmd ne ""} {
						set drawn [$imagecmd $c $x $y $width $height $scale $imageurl]
					} else {
						set drawn 0
					}
					if {$drawn ne "1"} {
						set image [$object _getimage $imageurl]
						set ow [image width $image]
						set oh [image height $image]
						foreach {px py} $pa(background-position) break
						if {$py eq "100.00%"} {
							set anchor s
							set y [expr {$y+$height}]
						} else {
							set anchor n
						}
						if {$px eq "100.00%"} {
							append anchor e
							set x [expr {$x+$width}]
						} else {
							append anchor w
						}
						$c create simage $x $y -image $image -anchor $anchor -width [expr {$ow*$scale}] -height [expr {$oh*$scale}]
					}
				}
				if {$tw > 0} {
					$c create line $x $y [expr {$x+$width}] $y -fill $tc -width $tw
				}
				if {$bw > 0} {
					$c create line $x [expr {$y+$height}] [expr {$x+$width}] [expr {$y+$height}] -fill $bc -width $bw
				}
				if {$lw > 0} {
					$c create line $x $y $x [expr {$y+$height}] -fill $lc -width $lw
				}
				if {$rw > 0} {
					$c create line [expr {$x+$width}] $y [expr {$x+$width}] [expr {$y+$height}] -fill $rc -width $rw
				}
			}
			draw_line {
				foreach {cmd x y width y_linethrough y_underline node} $line break
				array set pa [$node prop]
				set color $pa(color)
				if {$pa(text-decoration) eq "underline"} {
					set y [expr {$y+$y_underline}]
				} elseif {$pa(text-decoration) eq "linethrough"} {
					set y [expr {$y+$y_linethrough}]
				} elseif {$pa(text-decoration) eq "overline"} {
					set y $y
				} else {
					continue
				}
				if {$scale != 1} {
					set x [expr {$X+$x*$scale}]
					set y [expr {$Y+$y*$scale}]
					set width [expr {$width*$scale}]
					set height [expr {$height*$scale}]
				} else {
					incr x $X
					incr y $Y
				}
				$c create line $x $y [expr {$x+$width}] $y -fill $color
			}
			draw_background {
				foreach {cmd color} $line break
				$c configure -background $color
			}
		}
		Classy::Progress next
	}
	Classy::Progress stop
}

proc Classy::html2canvas {c args} {
	set tkhtml .classy__.tkhtml.tkhtml 
	Classy::Progress start {1 5 2}
	if {![winfo exists $tkhtml]} {
		toplevel .classy__.tkhtml
		wm withdraw .classy__.tkhtml
		Classy::HTML3 $tkhtml
		pack $tkhtml -fill both -expand yes
	}
	array set options {-x 0 -y 0 -width 400 -css {} -imagecmd {} -scale 1 -margin-top 2c -margin-right 2c -margin-bottom 2c -margin-left 2c}
	set options(-width) 595p
	set options(-base) [pwd]
	array set options $args
	if {[info exists options(-page)]} {
		foreach {pwidth pheight} $options(-page) break
		set paged 1
		set options(-width) [winfo pixels $tkhtml $pwidth]
#		set style {}
#		foreach key {margin-top margin-right margin-bottom margin-left} {
#			set temp $options(-$key)
#			switch [string index $temp end] {
#				c - m {append temp m}
#				p {append temp t}
#				i {append temp n}
#				default {append temp px}
#			}
#			append style "$key: $temp; "
#		}
#		append options(-css) \n[list BODY $style]
	} else {
		set paged 0
	}
	if {![isint $options(-width)]} {
		set options(-width) [winfo pixels $tkhtml $options(-width)]
	}
	set mtop [winfo pixels $tkhtml $options(-margin-top)]
	set mbottom [winfo pixels $tkhtml $options(-margin-bottom)]
	set mleft [winfo pixels $tkhtml $options(-margin-left)]
	set mright [winfo pixels $tkhtml $options(-margin-right)]
	set usewidth [expr {$options(-width) - $mleft - $mright}]
	$tkhtml configure -width $usewidth
	if {$::tcl_platform(platform) eq "windows"} {
		wm geometry .classy__.tkhtml ${usewidth}x$usewidth+100000+100000
		wm deiconify  .classy__.tkhtml
		wm withdraw .classy__.tkhtml
	} else {
		wm geometry .classy__.tkhtml ${usewidth}x$usewidth
		Classy::update Classy::html2canvas
	}
	if {[info exists options(-html)]} {
		$tkhtml set $options(-html)
	} elseif {[info exists options(-url)]} {
		$tkhtml geturlnow $options(-url)
	} elseif {[info exists options(-file)]} {
		$tkhtml geturlnow file:$options(-file)
	} else {
		error "no -html, -url or -file option given"
	}
	if {$options(-css) ne ""} {
		$tkhtml style -id user $options(-css)
	}
	event generate $tkhtml <Configure>
	Classy::Progress next
	Classy::update Classy::html2canvas2
	$tkhtml render2canvas $c [expr {$options(-x)+$mleft}] [expr {$options(-y)+$mtop}] $options(-scale) $options(-imagecmd)
	Classy::Progress next
	if {$paged} {
		set bbox [$c bbox all]
		set id [lindex [$c find withtag box] 0]
		if {[isint $id]} {
			set bg [$c itemcget $id -fill]
			$c delete $id
		} else {
			set bg white
		}
		$c configure -bg gray
		set pwidth [winfo fpixels $tkhtml $pwidth]
		set pheight [winfo fpixels $tkhtml $pheight]
		set gap [winfo fpixels $tkhtml 5m]
		set mtop [winfo fpixels $tkhtml $options(-margin-top)]
		set mbottom [winfo fpixels $tkhtml $options(-margin-bottom)]
		set page 1
		set cur 0
		set load [expr {round(([lindex $bbox end]-[lindex $bbox 1])/$pheight)}]
		Classy::Progress start $load
		while 1 {
			# move everything after the page to the next page
			set pageend [expr {$cur+$pheight}]
			set end [expr {$pageend-$mbottom}]
			set nextpage [expr {$pageend+$gap}]
			set bboxall [$c bbox all]
			set minx [expr {[lindex $bboxall 0]-10}]
			set maxx [expr {[lindex $bboxall 2]+10}]
			set maxy [expr {[lindex $bboxall end]+10}]
			set newend $end
			while 1 {
				# the part to be moved is after the end of the current page (newend)
				# tag with move: overlapping to get items sticking over to what will
				# become the current page
				$c dtag move
				$c addtag move overlapping $minx $newend $maxx $maxy
				$c dtag done move
				# pmax is the max y pos of items that will remain on the current page
				set pmax [lindex [$c bbox !move&&!done] end]
				# mmin is the min y pos of items that will be moved to the next page
				set mmin [lindex [$c bbox move] 1]
				if {$mmin <= $cur} {
					# some objects to be moved to the next page start before
					# the current page: reset end of current page to default 
					# end pos, and select only enclosed to be moved
					$c dtag move
					$c addtag move enclosed $minx $end $maxx $maxy
					break
				}
				# If there is little or no overlap among items from current and 
				# next page, we can do the move
				if {$mmin > $pmax} break
				if {[expr {abs($mmin-$pmax)}] < 5} break
				# try again with the end of the current page (newend) set to mmin
				set newend $mmin
			}
			$c addtag done overlapping $minx 0 $maxx $end
			set bbox [$c bbox move]
			if {![llength $bbox]} {
				set id [$c create rectangle 0 $cur $pwidth $pageend -fill $bg -outline {} -tags [list page page_$page]]
				$c lower $id
				break
			}
			set topmove [lindex $bbox 1]
			set move [expr {$nextpage+$mtop-$topmove}]
			$c move move 0 $move
			set id [$c create rectangle 0 $cur $pwidth $pageend -fill $bg -outline {} -tags [list page _paper page_$page]]
			$c lower $id
			incr page
			set cur $nextpage
			Classy::Progress next
		}
		Classy::Progress stop
	}
	Classy::Progress stop
}

if 0 {

package require ClassyTk
canvas .c -xscrollcommand {.hbar set} -yscrollcommand {.vbar set}
scrollbar .hbar -orient horizontal -command {.c xview}
scrollbar .vbar -orient vertical -command {.c yview}
grid .c .vbar -row 0 -sticky nwse
grid .hbar -row 1 -sticky we
grid columnconfigure . 0 -weight 1
grid columnconfigure . 1 -weight 0
grid rowconfigure . 0 -weight 1
grid rowconfigure . 1 -weight 0
.c configure -scrollregion {0 0 400 800}
set tkhtml .classy__.tkhtml.tkhtml 
set object $tkhtml

proc imgcmd {c x y width height scale image} {
	$c create rectangle $x $y [expr {$x+$width}] [expr {$y+$height}]
	return 1
}

set c .c
set x 0
set y 0
set width 400

$c delete all
Classy::html2canvas $c -file /home/peter/bin/tca-win/apps/maq1.2.0/help/MAQs-Manual.html \
	 -page {210m 297m} -margin-top 2c -margin-right 2c -margin-bottom 2c -margin-left 2c
.c configure -scrollregion [list_concat 0 0 210m 297m]
.c configure -scrollregion [list_concat 0 0 [lrange [$c bbox all] 2 end]]


set html {
<html>
<h1>Test</h1>
testingaverylonglinetoseeifitissplitsomewhereoriskeptasonecontinoustext
<img src="test.test" width=50 height=50>
testing a very long line to see if it is split properly somewhere or is kept as one continous text
<img src="test.test" width=100 height=50>
<img src="test.test">
</html>}
foreach i [info commands $c.*] {image delete $i}
$c delete all
Classy::html2canvas $c -width 50 -x 0 -y 0 -html $html -imagecmd imgcmd

$c delete all
Classy::html2canvas $c -file /home/peter/data/peter/Net/iap-www/iap/pub/colab.html \
	 -page {210m 297m} -margin-top 2c -margin-right 2c -margin-bottom 2c -margin-left 2c
.c configure -scrollregion [list_concat 0 0 [lrange [$c bbox all] 2 end]]

$c delete all
Classy::html2canvas $c -url http://www.csszengarden.com/ \
	 -page {210m 297m} -margin-top 2c -margin-right 2c -margin-bottom 2c -margin-left 2c
.c configure -scrollregion [list_concat 0 0 [lrange [$c bbox all] 2 end]]

$c delete all
Classy::html2canvas $c -url file:/home/peter/tmp/www.csszengarden.com/index.html -width 800
#	 -page {210m 297m} -margin-top 2c -margin-right 2c -margin-bottom 2c -margin-left 2c
.c configure -scrollregion [list_concat 0 0 [lrange [$c bbox all] 2 end]]

}


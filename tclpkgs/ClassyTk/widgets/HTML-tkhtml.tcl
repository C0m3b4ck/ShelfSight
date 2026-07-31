#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# HTML
# ----------------------------------------------------------------------
package require http

if ![string_equal [Classy::HTML private type] tkhtml] break

	bind Classy::HTML <<Action-ButtonPress>> {[winfo parent %W] _position %x %y}
	bind Classy::HTML <<Action-Motion>> {[winfo parent %W] _motion %x %y}
	bind Classy::HTML <<Action-ButtonRelease>> {[winfo parent %W] _release %x %y}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Classy::HTML method init {args} {
	super init html
	html $object.html
	bindtags $object [list $object Classy::HTML . all]
	private $object w
	set w [Classy::window $object]
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
	# REM Create bindings
	# --------------------
	$w configure \
		-hyperlinkcommand [list $object geturl] \
		-imagecommand [list $object _getimage] \
		-formcommand [list $object _form] \
		-scriptcommand [list $object _script] \
		-visitedcolor blue3 \
		-unvisitedcolor blue1 \
		-selectioncolor skyblue \
		-exportselection yes
#	$w token handler BODY [list $object _body]
	$object clearcache
	bindtags $object.x [list $object.x Classy::HTML [winfo toplevel $object] all]
	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
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

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::HTML chainallmethods {$object} text

#doc {HTML command geturl} cmd {
#pathname geturl url
#} descr {
#}
Classy::HTML method geturl {url {query {}}} {
	private $object options history currentquery html w source loading
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
					if {"$fragment" != ""} {$object yview $fragment}
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
	if [string_equal $protocol http] {
		set source ""
		set code [catch {
			$object _async_httpget -query $query $url
		} result]
	} else {
		set code [catch {set source [$object getdata -query $query -typevar type $url]} result]
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
	$w configure -base $url
	$object _clear
	# http pages are being transfered asynchronously
	if ![string_equal $protocol http] {
		if ![string_equal $type text/html] {
			$w parse <pre>
		}
		set pos 0
		set len [string length $source]
		while {$pos < $len} {
			$w parse [string range $source $pos [expr {$pos+19999}]]
			incr pos 20000
			Classy::update Classy::tkhtml-geturl
			if ![info exists loading] {
				Classy::busy remove $object
				return
			}
		}
		if ![string_equal $type text/html] {
			$w parse </pre>
		}
		if [string length $fragment] {
			$w yview $fragment
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
Classy::HTML method reload {} {
	private $object options history currentquery
	set history(reload) 1
	$object geturl $options(-url) $currentquery
}

#doc {HTML command back} cmd {
#pathname back 
#} descr {
#}
Classy::HTML method back {} {
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
Classy::HTML method forward {} {
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
Classy::HTML method history {} {
	private $object history
	return $history(url)
}

Classy::HTML method addhistory {url query} {
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
Classy::HTML method fullurl {url} {
	private $object options

	# make url fully specified
	# ------------------------
	if [regexp ^# $url] {
		set base $options(-url)
		regexp {([^#]*)#(.+)} $options(-url) dummy base fragment
		return $base$url
	}
	regsub {/[^/]*$} $options(-url) {} dir
	switch -regexp $url {
		{^(http|ftp|file|data)://} {
		}
		{^(http|ftp|file|data):/} {
			regsub {^(http|ftp|file|data):/} $url {\0/localhost/} url
		}
		{^file:} {
			regsub {^file:} $url {file://localhost/} url
		}
		^/ {
			regexp {^([^:]*)://([^/]+)(/.*)$} $options(-url) dummy protocol host file
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
Classy::HTML method spliturl {url} {
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
Classy::HTML method linkat {x y} {
	private $object w
	$w href $x $y
}

#doc {HTML command bindlink} cmd {
#pathname bindlink ?event? ?sequence?
#} descr {
# binds action to a certain event happening on a link
#} example {
# objectName bindlink <3> {puts [%W linkat %x %y]}
#}
Classy::HTML method bindlink {args} {
	bind $object.x $args
}

#doc {HTML command source} cmd {
#pathname source
#} descr {
# returns current source
#}
Classy::HTML method source {} {
	private $object source
	return $source
}

#doc {HTML command clearcache} cmd {
#pathname clearcache
#} descr {
# clears the image cache
#}
Classy::HTML method clearcache {} {
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
Classy::HTML method stop {} {
	private $object loading
	unset -nocomplain loading
}

#doc {HTML command getdata} cmd {
#pathname getdata ?options? url
#} descr {
# gets data from a certain url
#}
Classy::HTML method getdata {args} {
	set opt(-typevar) ::Classy::temp
	set opt(-query) {}
	cmd_args "$object getdata" {
		-typevar {any "set given variable to type of data obtained"}
		-channel {any "Save data to channel instead of returning it"}
		-query {any "query data"}
	} url $args
	set query $opt(-query)
	if ![regexp {^([^:]*)://([^/]+)(/.*)$} $url dummy protocol host file] {
		error "error in url format of \"$url\""
	}
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

Classy::HTML method _clear {} {
	private $object w imgstoget
	$w clear
	foreach image [info commands ::Classy::${object}_*] {
		image delete $image
	}
	set imgstoget {}
	foreach {option attr} {
		-bg Background
		-fg Foreground
	} {
		catch {$w configure $option [option get $object Classy::HTML $attr]}
	}
}

Classy::HTML method _getimage {args} {
	private $object cachedata cache imgstoget
	foreach {src width height attrs} $args break
	set info(width) 0
	set info(height) 0
    array set info $attrs
    set src [$object fullurl $src]
	set imagename ::Classy::${object}_${src}
	if [llength [info commands $imagename]] {return $imagename}
	if [info exists cachedata($src)] {
		if ![catch {image create photo $imagename -file $cachedata($src)} image] {
			return $image
		}
	}
	foreach {protocol host file fragment} [$object spliturl $src] break
	if [string_equal $protocol http] {
		# get images later (asynchronously)
		lappend imgstoget $src
		if ![isint $info(width)] {set info(width) 0}
		if ![isint $info(height)] {set info(height) 0}
		image create photo $imagename -width $info(width) -height $info(height)
	} else {
		set data [$object getdata $src]
		if [catch {image create photo $imagename -data $data} image] {
			return {}
		} else {
			return $image
		}
	}
}

Classy::HTML method _script {args} {
}

#Classy::HTML method _body {args} {
#	private $object w
#	foreach {tag attrs} $args break
#	array set info $attrs
#	foreach {option attr} {
#		-bg bgcolor
#		-fg text
#		-visitedcolor vlink
#		-unvisitedcolor link
#	} {
#		if [info exists info($attr)] {
#			$w configure $option $info($attr)
#		}
#	}
#}
#
Classy::HTML method _form {args} {
#putsvars args
	private $object form
	switch [lindex $args 1] {
		flush {
			foreach {token cmd} $args break
			foreach name [array names form $token,*] {
				unset form($name)
			}
		}
		form {
			foreach {token cmd url method attrs} $args break
			set form($token,method) [string tolower $method]
			set form($token,url) $url
			set form($token,attrs) $attrs
			set form($token,id) 1
			set form($token,ids) {}
		}
		input {
			foreach {token cmd w attrs} $args break
		    if {[info commands $w] != ""} {destroy $w}
			array set info {
				type text value {} size 20 color white 
				multiple 0 checked 0 rows 1 cols 20 alt Alt
			}
			foreach {key value} $attrs {
				set info([string tolower $key]) $value
			}
			if {[info exists info(name)]} {
				set id $info(name)
			} else {
				set id $form($token,id)
				incr form($token,id)
			}
			list_addnew form($token,ids) $id
			set form($token,$id,type) $info(type)
			set form($token,$id,w) $w
			if {![inlist {radio checkbox} $info(type)]} {
				set form($token,$id,defvalue) $info(value)
				if {![info exists form($token,$id,value)]} {
					set form($token,$id,value) $info(value)
				}
				set value $form($token,$id,value)
			}
			switch $info(type) {
				submit {
					if {[string_equal $value {}]} {set value Submit}
					button $w -text $value -command [list $object _formsubmit $token $id]
					if {[info exists info(name)]} {
						set form($token,$id,value) $value
					}
				}
				reset {
					if {[string_equal $value {}]} {set value Reset}
					button $w -text $value -command [list $object _formreset $token $id]
				}
				hidden {}
				name -
				text {
					entry $w -width $info(size) -bg $info(color) \
						-textvariable [privatevar $object form($token,$id,value)]
					bind $w <Return> [list $object _formsubmit $token $id]
					return $w
				}
				image {
					set image [$object _getimage $info(src)]
					button $w -image $image -relief flat -bd 0 -highlightthickness 0
					bind $w <<Action>> "puts ok%x,%y;[list $object _formsubmit $token $id image %x %y];break"
				}
				file {
					Classy::FileEntry $w -width $info(size) -bg $info(color) \
						-textvariable [privatevar $object form($token,$id,value)] \
						-command [list $object _formsubmit $token $id]
				}
				password {
					entry $w -width $info(size) -bg $info(color) \
						-show * \
						-textvariable [privatevar $object form($token,$id,value)]
					bind $w <Return> [list $object _formsubmit $token $id]
				}
				checkbox {
					checkbutton $w -highlightthickness 0 \
						-variable [privatevar $object form($token,$id,$info(value),value)]
					if {"$info(checked)" != "0"} {
						if {![info exists form($token,$id,value)]} {
							$w select
						}
						$w select
						set form($token,$id,$info(value),defvalue) 1
					} else {
						set form($token,$id,$info(value),defvalue) 0
					}
				}
				radio {
					radiobutton $w -value $info(value) -highlightthickness 0 \
						-variable [privatevar $object form($token,$id,value)]
					if {"$info(checked)" != "0"} {
						set form($token,$id,defvalue) $info(value)
						if {[string_equal $form($token,$id,value) ""]} {
							set form($token,$id,value) $info(value)
						}
					}
				}
			}
		}
		select {
			foreach {token cmd w attrs choices initial} $args break
		    if {[info commands $w] != ""} {destroy $w}
			array set info {multiple 0}
			foreach {key value} $attrs {
				set info([string tolower $key]) $value
			}
			if {[info exists info(name)]} {
				set id $info(name)
			} else {
				set id $form($token,id)
				incr form($token,id)
			}
			list_addnew form($token,ids) $id
			set form($token,$id,w) $w
			set width 5
			set choicelist {}
			set valuelist {}
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
				menubutton $w -width $width -menu $w.menu \
					-indicatoron 1 -relief raised \
					-textvariable [privatevar $object form($token,$id,value)]
				menu $w.menu -tearoff 0
				foreach label $choicelist {
					$w.menu add command -label $label \
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
				frame $w
				if {![info exists info(size)]} {
					set info(size) [llength $choicelist]
				}
				if {$info(size) > 50} {set info(size) 50}
				listbox $w.list -height $info(size) -width $width -exportselection no
				if {"$info(multiple)" != "0"} {
					$w.list configure -selectmode multiple
				}
				grid $w.list -sticky nwse
				set rw [winfo reqwidth $w.list]
				set rh [winfo reqheight $w.list]
				if {[llength $choicelist] > $info(size)} {
					scrollbar $w.vbar -orient vertical -command [list $w.list yview]
					$w.list configure -yscrollcommand [list $w.vbar set]
					grid $w.vbar -sticky nwse -row 0 -column 1
					incr rw [winfo reqwidth $w.vbar]
				}
				if {$scrollx} {
					scrollbar $w.hbar -orient horizontal -command [list $w.list xview]
					$w.list configure -xscrollcommand [list $w.hbar set]
					grid $w.hbar -sticky nwse -row 1 -column 0
					incr rh [winfo reqheight $w.hbar]
				}
				grid rowconfigure $w 0 -weight 1
				grid columnconfigure $w 0 -weight 1
				$w configure -width $rw -height $rh
				eval $w.list insert end $choicelist
				foreach label $form($token,$id,value) {
					$w.list selection set [lsearch -exact $choicelist $label]
				}
			}
		}
		textarea {
			foreach {token cmd w attrs initial} $args break
			catch {destroy $w}
			catch {destroy $w.text}
			catch {destroy $w.vbar}
			catch {destroy $w.hbar}
			array set info {size 20 multiple 0}
			foreach {key value} $attrs {
				set info([string tolower $key]) $value
			}
			if {[info exists info(name)]} {
				set id $info(name)
			} else {
				set id $form($token,id)
				incr form($token,id)
			}
			list_addnew form($token,ids) $id
			set form($token,$id,type) textarea
			set form($token,$id,w) $w
			set form($token,$id,defvalue) $initial
			frame $w
			text $w.text -width $info(cols) -height $info(rows)
			scrollbar $w.vbar -orient vertical -command [list $w.text yview]
			scrollbar $w.hbar -orient horizontal -command [list $w.text xview]
			$w.text configure \
				-yscrollcommand [list $w.vbar set] \
				-xscrollcommand [list $w.hbar set]
			grid $w.text $w.vbar -sticky nwse
			grid $w.hbar -sticky nwse
			grid rowconfigure $w 0 -weight 1
			grid columnconfigure $w 0 -weight 1
			$w configure \
				-width [expr {[winfo reqwidth $w.text]+[winfo reqwidth $w.vbar]}] \
				-height [expr {[winfo reqheight $w.text]+[winfo reqheight $w.hbar]}]
			$w.text insert end $initial
			return $w
		}
    }
}

Classy::HTML method _formsubmit {token id args} {
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
				set w $form($token,$id,w)
				foreach index [$w.list curselection] {
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
				set w $form($token,$id,w)
				lappend query $id [$w.text get 1.0 end]
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

Classy::HTML method _formreset {token id} {
	private $object form
	foreach id $form($token,ids) {
		switch $form($token,$id,type) {
			selectmulti {
				set w $form($token,$id,w)
				$w.list selection clear 0 end
				set choicelist [$w.list get 0 end]
				foreach label [get form($token,$id,defvalue) ""] {
					$w.list selection set [lsearch -exact $choicelist $label]
				}
			}
			textarea {
				set w $form($token,$id,w)
				$w.text delete 1.0 end
				$w.text insert end [get form($token,$id,defvalue) ""]
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

Classy::HTML method _async_httpget {args} {
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
	    $w parse $html <pre>
	}
}

Classy::HTML method _async_httpget_handler {sock token} {
	private $object w loading source
    upvar #0 $token state
	if ![info exists loading] {
		close $sock
		unset -nocomplain state
		return
	}
    set html [read $sock $state(-blocksize)]
	# doing this completely async gives problems on some sites
#	$w parse $html
	append source $html
	Classy::update Classy::HTML-_async_httpget_handler idletasks
	return
}

Classy::HTML method _async_httpget_done {token} {
	private $object w currenttype imgstoget cache cachedata loading source
	if ![string_equal $currenttype text/html] {
#		$w parse $html </pre>
		append source $html
	}
$w parse $source
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

Classy::HTML method _async_getimage_done {image f token} {
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

Classy::HTML method _position {x y} {
	private $object cpos w
	set cpos(x) $x
	set cpos(y) $y
	set cpos(index) [$w index @$x,$y]
	$w selection clear
}

Classy::HTML method _motion {x y} {
	private $object cpos w
	if ![info exists cpos(index)] {
		set cpos(x) $x
		set cpos(y) $y
		set cpos(index) [$w index @$x,$y]
	}
	$w selection set $cpos(index) @$x,$y
}

Classy::HTML method _release {x y} {
	private $object options cpos
	unset -nocomplain cpos(index)
	set url [$object linkat $x $y]
	if [string length $url] {
		if {[string_equal $options(-hyperlinkcommand) ""]} {
			$object geturl $url
		} else {
			eval $options(-hyperlinkcommand) {$url}
		}
	}
}


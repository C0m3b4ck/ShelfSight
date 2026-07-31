#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Classy::getcolor
# ----------------------------------------------------------------------
#doc getcolor title {
#getcolor
#} index {
# Dialogs
#} shortdescr {
# select a color
#getcolor
#}

#doc {getcolor getcolor} cmd {
#getcolor ?option value ...?
#} index {
# Dialogs
#} shortdescr {
# returns a color selected by the user
#} descr {
# returns a color selected by the user. The selectmethod depends om the
# ClassyTk configuration. Possible options are
#<dl>
#<dt>-initialcolor
#<dt>-title
#</dl>
#}
proc Classy::getcolor {args} {
	Classy::parseopt $args opt {
		-initialcolor {} white
		-title {} "Set color"
		-command {} {}
	} remain
	if {"$remain" != ""} {
		error "unknown options \"$remain\": must be -initialcolor or -title"
	}
	array set opt $args
	if {"$opt(-initialcolor)" == ""} {
		set opt(-initialcolor) white
	}
	if {("[option get . getColor GetColor]"=="Tk")&&![string length $opt(-command)]} {
		return [tk_chooseColor -initialcolor $opt(-initialcolor) -title $opt(-title)]
	}
	set ::Classy::temp $opt(-initialcolor)
	catch {destroy .classy__.getcolor}
	Classy::Dialog .classy__.getcolor -title $opt(-title) -resize {1 1} -closecommand {
		set ::Classy::temp ""
		destroy .classy__.getcolor
	}
	Classy::ColorSelect .classy__.getcolor.options.select
	if [string length $opt(-command)] {
		.classy__.getcolor.options.select configure -command "$opt(-command)"
		.classy__.getcolor add none "None" "$opt(-command) {}"
	} else {
		.classy__.getcolor add go "Select" {set ::Classy::temp [.classy__.getcolor.options.select get]} default
		.classy__.getcolor add none "None" {set ::Classy::temp {}}
		.classy__.getcolor persistent remove none
	}
	catch {.classy__.getcolor.options.select nocmdset $opt(-initialcolor)}
	pack .classy__.getcolor.options.select -fill both -expand yes
	Classy::update Classy::getcolor idletasks
	set reqheight [winfo reqheight .classy__.getcolor]
	set reqwidth [winfo reqwidth .classy__.getcolor]
	if {([winfo height .classy__.getcolor] < $reqheight)||([winfo width .classy__.getcolor] < $reqwidth)} {
		.classy__.getcolor configure -resize [list $reqwidth $reqheight]
	}
	if ![string length $opt(-command)] {
		tkwait window .classy__.getcolor
		if {"$::Classy::temp"==""} {
			return -code return ""
		} else {
			return $::Classy::temp
		}
	}
	return .classy__.getcolor
}



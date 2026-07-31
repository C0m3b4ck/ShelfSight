proc Classy::defaultbrowser {url} {
	global tcl_platform
	
	# It *is* generally a mistake to switch on $tcl_platform(os), particularly
	# in comparison to $tcl_platform(platform).  For now, let's just regard it
	# as a stylistic variation subject to debate.
	switch $tcl_platform(platform) {
		unix {
			set list {firefox mozilla netscape iexplorer opera lynx w3m links epiphany galeon konqueror mosaic amaya browsex elinks}
			if {[info exists ::env(BROWSER)]} {
				list_unshift list $::env(BROWSER)
			}
			foreach executable $list {
				set executable [auto_execok $executable]
				if [string length $executable] {
					set command [list $executable $url]
					break
				}
			}
		}
		windows {
			set command "[auto_execok start] {} [list $url]"
		}
	}
	if {[info exists command]} {
		if [catch {eval exec $command &} err] {
			tk_messageBox -icon error -message "error '$err' with '$command'"
		}
	} else {
		tk_messageBox -icon error -message "Couldn't start browser to view \"$url\""
	}
}

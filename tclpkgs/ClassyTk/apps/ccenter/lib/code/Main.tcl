proc main args {
	set ::clock(format) [Classy::Default get app clock_format "%b %d %H:%M:%S"]
	mainw .mainw
	clock_update
}


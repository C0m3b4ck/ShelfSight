proc changecursor {w cursor {backup {}}} {
	if [catch {$w configure -cursor $cursor}] {
		set file [Classy::findicon ${cursor}.xbm]
		if [catch {$w configure -cursor [list @$file black]}] {
			$w configure -cursor $backup
		}
	}
}
